/*******************************************************************************
 * Copyright (C) 2005-2017 Alfresco Software Limited.
 *
 * This file is part of the Alfresco Activiti Mobile SDK.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 ******************************************************************************/

#import "ASDKProfileDataAccessor.h"

// Constants
#import "ASDKLogConfiguration.h"

// Managers
#import "ASDKBootstrap.h"
#import "ASDKProfileNetworkServices.h"
#import "ASDKServiceLocator.h"
#import "ASDKProfileCacheServices.h"

// Operations
#import "ASDKAsyncBlockOperation.h"

// Model
#import "ASDKDataAccessorResponseModel.h"

static const int activitiSDKLogLevel = ASDK_LOG_LEVEL_VERBOSE; // | ASDK_LOG_FLAG_TRACE;

@implementation ASDKProfileDataAccessor

- (instancetype)initWithDelegate:(id<ASDKDataAccessorDelegate>)delegate {
    self = [super initWithDelegate:delegate];
    
    if (self) {
        _cachePolicy = ASDKServiceDataAccessorCachingPolicyHybrid;
        
        dispatch_queue_t profileUpdatesProcessingQueue = dispatch_queue_create([[NSString stringWithFormat:@"%@.`%@ProcessingQueue",
                                                                                 [NSBundle bundleForClass:[self class]].bundleIdentifier,
                                                                                 NSStringFromClass([self class])] UTF8String],
                                                                               DISPATCH_QUEUE_SERIAL);
        
        // Acquire and set up the app network service
        ASDKBootstrap *sdkBootstrap = [ASDKBootstrap sharedInstance];
        _networkService = (ASDKProfileNetworkServices *)[sdkBootstrap.serviceLocator serviceConformingToProtocol:@protocol(ASDKProfileNetworkServiceProtocol)];
        _networkService.resultsQueue = profileUpdatesProcessingQueue;
        _cacheService = [ASDKProfileCacheServices new];
    }
    
    return self;
}


#pragma mark - 
#pragma mark Service - Current user profile

- (void)fetchCurrentUserProfile {
    NSOperationQueue *processingQueue = [self serialOperationQueue];
    
    // Define operations
    ASDKAsyncBlockOperation *remoteUserProfileOperation = [self remoteUserProfileOperation];
    ASDKAsyncBlockOperation *cachedUserProfileOperation = [self cachedUserProfileOperation];
    ASDKAsyncBlockOperation *storeInCacheOperation = [self userProfileStoreInCacheOperation];
    ASDKAsyncBlockOperation *completionOperation = [self userProfileCompletionOperation];
    
    // Handle cache policies
    switch (self.cachePolicy) {
        case ASDKServiceDataAccessorCachingPolicyCacheOnly: {
            [completionOperation addDependency:cachedUserProfileOperation];
            [processingQueue addOperations:@[cachedUserProfileOperation, completionOperation]
                         waitUntilFinished:NO];
        }
            break;
            
        case ASDKServiceDataAccessorCachingPolicyAPIOnly: {
            [completionOperation addDependency:remoteUserProfileOperation];
            [processingQueue addOperations:@[remoteUserProfileOperation, completionOperation]
                         waitUntilFinished:NO];
        }
            break;
            
        case ASDKServiceDataAccessorCachingPolicyHybrid: {
            [remoteUserProfileOperation addDependency:cachedUserProfileOperation];
            [storeInCacheOperation addDependency:remoteUserProfileOperation];
            [completionOperation addDependency:storeInCacheOperation];
            [processingQueue addOperations:@[cachedUserProfileOperation, remoteUserProfileOperation, storeInCacheOperation, completionOperation]
                         waitUntilFinished:NO];
        }
            break;
            
        default:
            break;
    }
}

- (ASDKAsyncBlockOperation *)remoteUserProfileOperation {
    if (self.delegate) {
        [self.delegate dataAccessorDidStartFetchingRemoteData:self];
    }
    
    __weak typeof(self) weakSelf = self;
    ASDKAsyncBlockOperation *remoteUserProfileOperation = [ASDKAsyncBlockOperation blockOperationWithBlock:^(ASDKAsyncBlockOperation *operation) {
        __strong typeof(self) strongSelf = weakSelf;
        
        [strongSelf.profileNetworkService fetchProfileWithCompletionBlock:^(ASDKModelProfile *profile, NSError *error) {
            ASDKDataAccessorResponseModel *responseModel = [[ASDKDataAccessorResponseModel alloc] initWithModel:profile
                                                                                                   isCachedData:NO
                                                                                                          error:error];
            if (strongSelf.delegate) {
                [strongSelf.delegate dataAccessor:strongSelf
                              didLoadDataResponse:responseModel];
            }
            
            operation.result = responseModel;
            [operation complete];
        }];
    }];
    
    return remoteUserProfileOperation;
}

- (ASDKAsyncBlockOperation *)cachedUserProfileOperation {
    __weak typeof(self) weakSelf = self;
    ASDKAsyncBlockOperation *cachedUserProfileOperation = [ASDKAsyncBlockOperation blockOperationWithBlock:^(ASDKAsyncBlockOperation *operation) {
        __strong typeof(self) strongSelf = weakSelf;
        
        [[strongSelf profileCacheService] fetchCurrentUserProfile:^(ASDKModelProfile *profile, NSError *error) {
            if (profile) {
                ASDKDataAccessorResponseModel *response = [[ASDKDataAccessorResponseModel alloc] initWithModel:profile
                                                                                                  isCachedData:YES
                                                                                                         error:nil];
                if (weakSelf.delegate) {
                    [weakSelf.delegate dataAccessor:weakSelf
                                didLoadDataResponse:response];
                }
            }
            
            [operation complete];
        }];
    }];
    
    return cachedUserProfileOperation;
}

- (ASDKAsyncBlockOperation *)userProfileStoreInCacheOperation {
    __weak typeof(self) weakSelf = self;
    ASDKAsyncBlockOperation *storeInCacheOperation = [ASDKAsyncBlockOperation blockOperationWithBlock:^(ASDKAsyncBlockOperation *operation) {
        __strong typeof(self) strongSelf = weakSelf;
        ASDKAsyncBlockOperation *dependencyOperation = (ASDKAsyncBlockOperation *)operation.dependencies.firstObject;
        ASDKDataAccessorResponseModel *remoteResponse = dependencyOperation.result;
        
        if (remoteResponse.model) {
            [[strongSelf profileCacheService] cacheCurrentUserProfile:remoteResponse.model
                                                  withCompletionBlock:^(NSError *error) {
                                                      if (!error) {
                                                          [weakSelf saveChanges];
                                                      } else {
                                                          ASDKLogError(@"Encountered an error while caching the current user profile. Reason:%@", error.localizedDescription);
                                                      }
            }];
        }
        
        [operation complete];
    }];
    
    return storeInCacheOperation;
}

- (ASDKAsyncBlockOperation *)userProfileCompletionOperation {
    __weak typeof(self) weakSelf = self;
    ASDKAsyncBlockOperation *completionOperation = [ASDKAsyncBlockOperation blockOperationWithBlock:^(ASDKAsyncBlockOperation *operation) {
        __strong typeof(self) strongSelf = weakSelf;
        
        if (strongSelf.delegate) {
            [strongSelf.delegate dataAccessorDidFinishedLoadingDataResponse:strongSelf];
        }
        
        [operation complete];
    }];
    
    return completionOperation;
}


#pragma mark -
#pragma mark Private interface

- (ASDKProfileNetworkServices *)profileNetworkService {
    return (ASDKProfileNetworkServices *)self.networkService;
}

- (ASDKProfileCacheServices *)profileCacheService {
    return (ASDKProfileCacheServices *)self.cacheService;
}

@end
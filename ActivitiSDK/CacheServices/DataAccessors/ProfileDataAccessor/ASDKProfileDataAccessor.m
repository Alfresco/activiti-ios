/*******************************************************************************
 * Copyright (C) 2005-2020 Alfresco Software Limited.
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
#import "ASDKDataAccessorResponseProgress.h"


static const int activitiSDKLogLevel = ASDK_LOG_LEVEL_VERBOSE; // | ASDK_LOG_FLAG_TRACE;

@interface ASDKProfileDataAccessor ()

@property (strong, nonatomic) NSOperationQueue *processingQueue;

@end

@implementation ASDKProfileDataAccessor

- (instancetype)initWithDelegate:(id<ASDKDataAccessorDelegate>)delegate {
    self = [super initWithDelegate:delegate];
    
    if (self) {
        _processingQueue = [self serialOperationQueue];
        _cachePolicy = ASDKServiceDataAccessorCachingPolicyHybrid;
        dispatch_queue_t profileUpdatesProcessingQueue = dispatch_queue_create([[NSString stringWithFormat:@"%@.`%@ProcessingQueue",
                                                                                 [NSBundle bundleForClass:[self class]].bundleIdentifier,
                                                                                 NSStringFromClass([self class])] UTF8String],
                                                                               DISPATCH_QUEUE_SERIAL);
        
        // Acquire and set up the profile network service
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
    // Define operations
    ASDKAsyncBlockOperation *remoteUserProfileOperation = [self remoteUserProfileOperation];
    ASDKAsyncBlockOperation *cachedUserProfileOperation = [self cachedUserProfileOperation];
    ASDKAsyncBlockOperation *storeInCacheOperation = [self userProfileStoreInCacheOperation];
    ASDKAsyncBlockOperation *completionOperation = [self userProfileCompletionOperation];
    
    // Handle cache policies
    switch (self.cachePolicy) {
        case ASDKServiceDataAccessorCachingPolicyCacheOnly: {
            [completionOperation addDependency:cachedUserProfileOperation];
            [self.processingQueue addOperations:@[cachedUserProfileOperation, completionOperation]
                              waitUntilFinished:NO];
        }
            break;
            
        case ASDKServiceDataAccessorCachingPolicyAPIOnly: {
            [completionOperation addDependency:remoteUserProfileOperation];
            [self.processingQueue addOperations:@[remoteUserProfileOperation, completionOperation]
                              waitUntilFinished:NO];
        }
            break;
            
        case ASDKServiceDataAccessorCachingPolicyHybrid: {
            [remoteUserProfileOperation addDependency:cachedUserProfileOperation];
            [storeInCacheOperation addDependency:remoteUserProfileOperation];
            [completionOperation addDependency:storeInCacheOperation];
            [self.processingQueue addOperations:@[cachedUserProfileOperation, remoteUserProfileOperation, storeInCacheOperation, completionOperation]
                              waitUntilFinished:NO];
        }
            break;
            
        default: break;
    }
}

- (ASDKAsyncBlockOperation *)remoteUserProfileOperation {
    if ([self.delegate respondsToSelector:@selector(dataAccessorDidStartFetchingRemoteData:)]) {
        [self.delegate dataAccessorDidStartFetchingRemoteData:self];
    }
    
    __weak typeof(self) weakSelf = self;
    ASDKAsyncBlockOperation *remoteUserProfileOperation = [ASDKAsyncBlockOperation blockOperationWithBlock:^(ASDKAsyncBlockOperation *operation) {
        __strong typeof(self) strongSelf = weakSelf;
        
        [strongSelf.profileNetworkService fetchProfileWithCompletionBlock:^(ASDKModelProfile *profile, NSError *error) {
            if (operation.isCancelled) {
                [operation complete];
                return;
            }
            
            ASDKDataAccessorResponseModel *responseModel = [[ASDKDataAccessorResponseModel alloc] initWithModel:profile
                                                                                                   isCachedData:NO
                                                                                                          error:error];
            if (weakSelf.delegate) {
                [weakSelf.delegate dataAccessor:weakSelf
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
        
        [strongSelf.profileCacheService fetchCurrentUserProfile:^(ASDKModelProfile *profile, NSError *error) {
            if (operation.isCancelled) {
                [operation complete];
                return;
            }
            
            if (!error) {
                if (profile) {
                    ASDKLogVerbose(@"Profile information successfully fetched from cache for user :%@", [profile normalisedName]);
                    
                    ASDKDataAccessorResponseModel *response = [[ASDKDataAccessorResponseModel alloc] initWithModel:profile
                                                                                                      isCachedData:YES
                                                                                                             error:error];
                    if (weakSelf.delegate) {
                        [weakSelf.delegate dataAccessor:weakSelf
                                    didLoadDataResponse:response];
                    }
                }
            } else {
                ASDKLogError(@"An error occured while fetching cached profile information for the current user. Reason:%@", error.localizedDescription);
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
        ASDKModelProfile *currentProfile = remoteResponse.model;
        
        if (remoteResponse.model) {
            [strongSelf.profileCacheService cacheCurrentUserProfile:currentProfile
                                                  withCompletionBlock:^(NSError *error) {
                                                      if (operation.isCancelled) {
                                                          [operation complete];
                                                          return;
                                                      }
                                                      
                                                      if (!error) {
                                                          ASDKLogVerbose(@"Successfully cached the current profile for: %@.", [currentProfile normalisedName]);
                                                          
                                                          [[weakSelf profileCacheService] saveChanges];
                                                      } else {
                                                          ASDKLogError(@"Encountered an error while caching the current user profile. Reason:%@", error.localizedDescription);
                                                      }
                                                      
                                                      [operation complete];
                                                  }];
        }
    }];
    
    return storeInCacheOperation;
}

- (ASDKAsyncBlockOperation *)userProfileCompletionOperation {
    __weak typeof(self) weakSelf = self;
    ASDKAsyncBlockOperation *completionOperation = [ASDKAsyncBlockOperation blockOperationWithBlock:^(ASDKAsyncBlockOperation *operation) {
        __strong typeof(self) strongSelf = weakSelf;
        
        if (operation.isCancelled) {
            [operation complete];
            return;
        }
        
        if (strongSelf.delegate) {
            [strongSelf.delegate dataAccessorDidFinishedLoadingDataResponse:strongSelf];
        }
        
        [operation complete];
    }];
    
    return completionOperation;
}


#pragma mark -
#pragma mark Service - Current user profile image

- (void)fetchCurrentUserProfileImage {
    if ([self.delegate respondsToSelector:@selector(dataAccessorDidStartFetchingRemoteData:)]) {
        [self.delegate dataAccessorDidStartFetchingRemoteData:self];
    }
    
    __weak typeof(self) weakSelf = self;
    [self.profileNetworkService fetchProfileImageWithCompletionBlock:^(UIImage *profileImage, NSError *error) {
        __strong typeof(self) strongSelf = weakSelf;
        
        ASDKDataAccessorResponseModel *responseModel = [[ASDKDataAccessorResponseModel alloc] initWithModel:profileImage
                                                                                               isCachedData:NO
                                                                                                      error:error];
        if (strongSelf.delegate) {
            [strongSelf.delegate dataAccessor:strongSelf
                          didLoadDataResponse:responseModel];
            
            [strongSelf.delegate dataAccessorDidFinishedLoadingDataResponse:strongSelf];
        }
    }];
}


#pragma mark -
#pragma mark Service - Update current profile

- (void)updateCurrentProfileWithModel:(ASDKModelProfile *)profileModel {
    NSParameterAssert(profileModel);
    
    if ([self.delegate respondsToSelector:@selector(dataAccessorDidStartFetchingRemoteData:)]) {
        [self.delegate dataAccessorDidStartFetchingRemoteData:self];
    }
    
    __weak typeof(self) weakSelf = self;
    [self.profileNetworkService updateProfileWithModel:profileModel
                                       completionBlock:^(ASDKModelProfile *profile, NSError *error) {
                                           __strong typeof(self) strongSelf = weakSelf;
                                           
                                           ASDKDataAccessorResponseModel *responseModel =
                                           [[ASDKDataAccessorResponseModel alloc] initWithModel:profile
                                                                                   isCachedData:NO
                                                                                          error:error];
                                           if (strongSelf.delegate) {
                                               [strongSelf.delegate dataAccessor:strongSelf
                                                             didLoadDataResponse:responseModel];
                                               
                                               [strongSelf.delegate dataAccessorDidFinishedLoadingDataResponse:strongSelf];
                                           }
                                       }];
}


#pragma mark -
#pragma mark Service - Update current profile password

- (void)updateCurrentProfileWithNewPassword:(NSString *)newPassword
                                oldPassword:(NSString *)oldPassword {
    NSParameterAssert(newPassword);
    NSParameterAssert(oldPassword);
    
    if ([self.delegate respondsToSelector:@selector(dataAccessorDidStartFetchingRemoteData:)]) {
        [self.delegate dataAccessorDidStartFetchingRemoteData:self];
    }
    
    __weak typeof(self) weakSelf = self;
    [self.profileNetworkService updateProfileWithNewPassword:newPassword
                                                 oldPassword:oldPassword
                                             completionBlock:^(BOOL isPasswordUpdated, NSError *error) {
                                                 __strong typeof(self) strongSelf = weakSelf;
                                                 
                                                 ASDKDataAccessorResponseModel *responseModel =
                                                 [[ASDKDataAccessorResponseModel alloc] initWithModel:newPassword
                                                                                         isCachedData:NO
                                                                                                error:error];
                                                 if (strongSelf.delegate) {
                                                     [strongSelf.delegate dataAccessor:strongSelf
                                                                   didLoadDataResponse:responseModel];

                                                     [strongSelf.delegate dataAccessorDidFinishedLoadingDataResponse:strongSelf];
                                                 }
                                             }];
}


#pragma mark -
#pragma mark Service - Upload current profile image

- (void)uploadCurrentProfileImageForContentModel:(ASDKModelFileContent *)fileContentModel
                                     contentData:(NSData *)contentData {
    NSParameterAssert(fileContentModel);
    NSParameterAssert(contentData);
    
    if ([self.delegate respondsToSelector:@selector(dataAccessorDidStartFetchingRemoteData:)]) {
        [self.delegate dataAccessorDidStartFetchingRemoteData:self];
    }
    
    __weak typeof(self) weakSelf = self;
    [self.profileNetworkService uploadProfileImageWithModel:fileContentModel
                                                contentData:contentData
                                              progressBlock:^(NSUInteger progress, NSError *error) {
                                                  __strong typeof(self) strongSelf = weakSelf;
                                                  
                                                  ASDKDataAccessorResponseProgress *responseProgress =
                                                  [[ASDKDataAccessorResponseProgress alloc] initWithProgress:progress
                                                                                                       error:error];
                                                  if (strongSelf.delegate) {
                                                      [strongSelf.delegate dataAccessor:strongSelf
                                                                    didLoadDataResponse:responseProgress];
                                                  }
                                              } completionBlock:^(ASDKModelContent *profileImageContent, NSError *error) {
                                                  __strong typeof(self) strongSelf = weakSelf;
                                                  
                                                  ASDKDataAccessorResponseModel *responseModel =
                                                  [[ASDKDataAccessorResponseModel alloc] initWithModel:profileImageContent
                                                                                          isCachedData:NO
                                                                                                 error:error];
                                                  if (strongSelf.delegate) {
                                                      [strongSelf.delegate dataAccessor:strongSelf
                                                                    didLoadDataResponse:responseModel];
                                                      
                                                      [strongSelf.delegate dataAccessorDidFinishedLoadingDataResponse:strongSelf];
                                                  }
                                              }];
}


#pragma mark -
#pragma mark Cancel operations

- (void)cancelOperations {
    [super cancelOperations];
    [self.processingQueue cancelAllOperations];
    [self.profileNetworkService cancelAllNetworkOperations];
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

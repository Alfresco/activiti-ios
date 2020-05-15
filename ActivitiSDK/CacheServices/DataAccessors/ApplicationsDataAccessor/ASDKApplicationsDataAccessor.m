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

#import "ASDKApplicationsDataAccessor.h"
// Constants
#import "ASDKLogConfiguration.h"

// Managers
#import "ASDKBootstrap.h"
#import "ASDKServiceLocator.h"
#import "ASDKAppNetworkServices.h"
#import "ASDKApplicationCacheService.h"

// Operations
#import "ASDKAsyncBlockOperation.h"

// Model
#import "ASDKDataAccessorResponseCollection.h"


static const int activitiSDKLogLevel = ASDK_LOG_LEVEL_VERBOSE; // | ASDK_LOG_FLAG_TRACE;

@interface ASDKApplicationsDataAccessor ()

@property (strong, nonatomic) NSOperationQueue *processingQueue;

@end

@implementation ASDKApplicationsDataAccessor

- (instancetype)initWithDelegate:(id<ASDKDataAccessorDelegate>)delegate {
    self = [super initWithDelegate:delegate];
    
    if (self) {
        _processingQueue = [self serialOperationQueue];
        _cachePolicy = ASDKServiceDataAccessorCachingPolicyHybrid;
        dispatch_queue_t applicationsProcessingQueue = dispatch_queue_create([[NSString stringWithFormat:@"%@.`%@ProcessingQueue",
                                                                               [NSBundle bundleForClass:[self class]].bundleIdentifier,
                                                                               NSStringFromClass([self class])] UTF8String],
                                                                             DISPATCH_QUEUE_SERIAL);
        
        // Acquire and set up the app network service
        ASDKBootstrap *sdkBootstrap = [ASDKBootstrap sharedInstance];
        _networkService = (ASDKAppNetworkServices *)[sdkBootstrap.serviceLocator serviceConformingToProtocol:@protocol(ASDKAppNetworkServiceProtocol)];
        _networkService.resultsQueue = applicationsProcessingQueue;
        _cacheService = [ASDKApplicationCacheService new];
    }
    
    return self;
}


#pragma mark -
#pragma mark Service - Runtime application definitions

- (void)fetchRuntimeApplicationDefinitions {
    // Define operations
    ASDKAsyncBlockOperation *remoteRuntimeApplicationDefinitionsOperation = [self remoteRuntimeApplicationDefinitionsOperation];
    ASDKAsyncBlockOperation *cachedRuntimeApplicationDefinitionsOperation = [self cachedRuntimeApplicationDefinitionsOperation];
    ASDKAsyncBlockOperation *storeInCacheRuntimeApplicationDefinitionsOperation = [self runtimeApplicationDefinitionsStoreInCacheOperation];
    ASDKAsyncBlockOperation *completionOperation = [self runtimeApplicationDefinitionsCompletionOperations];
    
    // Handle cache policies
    switch (self.cachePolicy) {
        case ASDKServiceDataAccessorCachingPolicyCacheOnly: {
            [completionOperation addDependency:cachedRuntimeApplicationDefinitionsOperation];
            [self.processingQueue addOperations:@[cachedRuntimeApplicationDefinitionsOperation,
                                                  completionOperation]
                              waitUntilFinished:NO];
        }
            break;
            
        case ASDKServiceDataAccessorCachingPolicyAPIOnly: {
            [completionOperation addDependency:remoteRuntimeApplicationDefinitionsOperation];
            [self.processingQueue addOperations:@[remoteRuntimeApplicationDefinitionsOperation,
                                                  completionOperation]
                              waitUntilFinished:NO];
        }
            break;
            
        case ASDKServiceDataAccessorCachingPolicyHybrid: {
            [remoteRuntimeApplicationDefinitionsOperation addDependency:cachedRuntimeApplicationDefinitionsOperation];
            [storeInCacheRuntimeApplicationDefinitionsOperation addDependency:remoteRuntimeApplicationDefinitionsOperation];
            [completionOperation addDependency:storeInCacheRuntimeApplicationDefinitionsOperation];
            [self.processingQueue addOperations:@[cachedRuntimeApplicationDefinitionsOperation,
                                                  remoteRuntimeApplicationDefinitionsOperation,
                                                  storeInCacheRuntimeApplicationDefinitionsOperation,
                                                  completionOperation]
                              waitUntilFinished:NO];
        }
            break;
            
        default: break;
    }
}

- (ASDKAsyncBlockOperation *)remoteRuntimeApplicationDefinitionsOperation {
    if ([self.delegate respondsToSelector:@selector(dataAccessorDidStartFetchingRemoteData:)]) {
        [self.delegate dataAccessorDidStartFetchingRemoteData:self];
    }
    
    __weak typeof(self) weakSelf = self;
    ASDKAsyncBlockOperation *remoteUserProfileOperation = [ASDKAsyncBlockOperation blockOperationWithBlock:^(ASDKAsyncBlockOperation *operation) {
        __strong typeof(self) strongSelf = weakSelf;
        
        [strongSelf.appNetworkService fetchRuntimeAppDefinitionsWithCompletionBlock:^(NSArray *runtimeAppDefinitions, NSError *error, ASDKModelPaging *paging) {
            if (operation.isCancelled) {
                [operation complete];
                return;
            }
            
            // Filter any unused values from the application list i.e. apps that should
            // not be visible to the user
            NSPredicate *userApplicationsPredicate = [NSPredicate predicateWithFormat:@"deploymentID != nil"];
            NSArray *userApplicationsArr = [runtimeAppDefinitions filteredArrayUsingPredicate:userApplicationsPredicate];
            
            ASDKDataAccessorResponseCollection *responseCollection =
            [[ASDKDataAccessorResponseCollection alloc] initWithCollection:userApplicationsArr
                                                              isCachedData:NO
                                                                     error:error];
            if (strongSelf.delegate) {
                [strongSelf.delegate dataAccessor:strongSelf
                              didLoadDataResponse:responseCollection];
            }
            
            operation.result = responseCollection;
            [operation complete];
        }];
    }];
    
    return remoteUserProfileOperation;
}

- (ASDKAsyncBlockOperation *)cachedRuntimeApplicationDefinitionsOperation {
    __weak typeof(self) weakSelf = self;
    ASDKAsyncBlockOperation *cachedUserProfileOperation = [ASDKAsyncBlockOperation blockOperationWithBlock:^(ASDKAsyncBlockOperation *operation) {
        __strong typeof(self) strongSelf = weakSelf;
        
        [[strongSelf appCacheService] fetchRuntimeApplicationDefinitions:^(NSArray *appDefinitionList, NSError *error) {
            if (operation.isCancelled) {
                [operation complete];
                return;
            }
            
            if (!error) {
                if (appDefinitionList.count) {
                    ASDKLogVerbose(@"Fetched %lu runtime application definitions from cache", (unsigned long)appDefinitionList.count);
                    
                    ASDKDataAccessorResponseCollection *response = [[ASDKDataAccessorResponseCollection alloc] initWithCollection:appDefinitionList
                                                                                                                     isCachedData:YES
                                                                                                                            error:error];
                    if (weakSelf.delegate) {
                        [weakSelf.delegate dataAccessor:weakSelf
                                    didLoadDataResponse:response];
                    }
                }
            } else {
                ASDKLogError(@"An error occured while fetching cached runtime application definitions. Reason:%@", error.localizedDescription);
            }
            
            [operation complete];
        }];
    }];
    
    return cachedUserProfileOperation;
}

- (ASDKAsyncBlockOperation *)runtimeApplicationDefinitionsStoreInCacheOperation {
    __weak typeof(self) weakSelf = self;
    ASDKAsyncBlockOperation *storeInCacheOperation = [ASDKAsyncBlockOperation blockOperationWithBlock:^(ASDKAsyncBlockOperation *operation) {
        __strong typeof(self) strongSelf = weakSelf;
        ASDKAsyncBlockOperation *dependencyOperation = (ASDKAsyncBlockOperation *)operation.dependencies.firstObject;
        ASDKDataAccessorResponseCollection *remoteResponse = dependencyOperation.result;
        
        if (remoteResponse.collection) {
            [[strongSelf appCacheService] cacheRuntimeApplicationDefinitions:remoteResponse.collection
                                                        withtCompletionBlock:^(NSError *error) {
                                                            if (operation.isCancelled) {
                                                                [operation complete];
                                                                return;
                                                            }
                                                            
                                                            if (!error) {
                                                                ASDKLogVerbose(@"Successfully cached runtime applications");
                                                                
                                                                [[weakSelf appCacheService] saveChanges];
                                                            } else {
                                                                ASDKLogError(@"Encountered an error while caching the runtime application definitions. Reason %@", error.localizedDescription);
                                                            }
                                                            
                                                            [operation complete];
                                                        }];
        }
    }];
    
    return storeInCacheOperation;
}

- (ASDKAsyncBlockOperation *)runtimeApplicationDefinitionsCompletionOperations {
    __weak typeof(self) weakSelf = self;
    ASDKAsyncBlockOperation *completionOperation = [ASDKAsyncBlockOperation blockOperationWithBlock:^(ASDKAsyncBlockOperation *operation) {
        __strong typeof(self) strongSelf = weakSelf;
        
        if (operation.isCancelled) {
            [operation complete];
            return ;
        }
        
        if (strongSelf.delegate) {
            [strongSelf.delegate dataAccessorDidFinishedLoadingDataResponse:strongSelf];
        }
        
        [operation complete];
    }];
    
    return completionOperation;
}


#pragma mark -
#pragma mark Cancel operations

- (void)cancelOperations {
    [super cancelOperations];
    [self.processingQueue cancelAllOperations];
    [self.appNetworkService cancelAllNetworkOperations];
}


#pragma mark -
#pragma mark Private interface

- (ASDKAppNetworkServices *)appNetworkService {
    return (ASDKAppNetworkServices *)self.networkService;
}

- (ASDKApplicationCacheService *)appCacheService {
    return (ASDKApplicationCacheService *)self.cacheService;
}

@end

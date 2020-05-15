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

#import "ASDKProcessDefinitionDataAccessor.h"

// Constants
#import "ASDKLogConfiguration.h"

// Operations
#import "ASDKAsyncBlockOperation.h"

// Managers
#import "ASDKBootstrap.h"
#import "ASDKProcessDefinitionNetworkServices.h"
#import "ASDKServiceLocator.h"
#import "ASDKProcessDefinitionCacheService.h"

// Model
#import "ASDKDataAccessorResponseCollection.h"

static const int activitiSDKLogLevel = ASDK_LOG_LEVEL_VERBOSE; // | ASDK_LOG_FLAG_TRACE;

@interface ASDKProcessDefinitionDataAccessor ()

@property (strong, nonatomic) NSOperationQueue *processingQueue;

@end

@implementation ASDKProcessDefinitionDataAccessor

- (instancetype)initWithDelegate:(id<ASDKDataAccessorDelegate>)delegate {
    self = [super initWithDelegate:delegate];
    
    if (self) {
        _processingQueue = [self serialOperationQueue];
        _cachePolicy = ASDKServiceDataAccessorCachingPolicyHybrid;
        dispatch_queue_t processUpdatesProcessingQueue = dispatch_queue_create([[NSString stringWithFormat:@"%@.`%@ProcessingQueue",
                                                                                 [NSBundle bundleForClass:[self class]].bundleIdentifier,
                                                                                 NSStringFromClass([self class])] UTF8String],
                                                                               DISPATCH_QUEUE_SERIAL);
        // Acquire and set up the process instance network service
        ASDKBootstrap *sdkBootstrap = [ASDKBootstrap sharedInstance];
        _networkService = (ASDKProcessDefinitionNetworkServices *)[sdkBootstrap.serviceLocator serviceConformingToProtocol:@protocol(ASDKProcessDefinitionNetworkServiceProtocol)];
        _networkService.resultsQueue = processUpdatesProcessingQueue;
        _cacheService = [ASDKProcessDefinitionCacheService new];
    }
    
    return self;
}


#pragma mark -
#pragma mark Service - Process definition list

- (void)fetchProcessDefinitionList {
    // Define operations
    ASDKAsyncBlockOperation *remoteProcessDefinitionListOperation = [self remoteProcessDefinitionListOperation];
    ASDKAsyncBlockOperation *cachedProcessDefinitionListOperation = [self cachedProcessDefinitionListOperation];
    ASDKAsyncBlockOperation *storeInCacheProcessDefinitionListOperation = [self processDefinitionListStoreInCacheOperation];
    ASDKAsyncBlockOperation *completionOperation = [self defaultCompletionOperation];
    
    // Handle cache policies
    switch (self.cachePolicy) {
        case ASDKServiceDataAccessorCachingPolicyCacheOnly: {
            [completionOperation addDependency:cachedProcessDefinitionListOperation];
            [self.processingQueue addOperations:@[cachedProcessDefinitionListOperation,
                                                  completionOperation]
                              waitUntilFinished:NO];
        }
            break;
            
        case ASDKServiceDataAccessorCachingPolicyAPIOnly: {
            [completionOperation addDependency:remoteProcessDefinitionListOperation];
            [self.processingQueue addOperations:@[remoteProcessDefinitionListOperation,
                                                  completionOperation]
                              waitUntilFinished:NO];
        }
            break;
            
        case ASDKServiceDataAccessorCachingPolicyHybrid: {
            [remoteProcessDefinitionListOperation addDependency:cachedProcessDefinitionListOperation];
            [storeInCacheProcessDefinitionListOperation addDependency:remoteProcessDefinitionListOperation];
            [completionOperation addDependency:storeInCacheProcessDefinitionListOperation];
            [self.processingQueue addOperations:@[cachedProcessDefinitionListOperation,
                                                  remoteProcessDefinitionListOperation,
                                                  storeInCacheProcessDefinitionListOperation,
                                                  completionOperation]
                              waitUntilFinished:NO];
        }
            break;
            
        default: break;
    }
}

- (ASDKAsyncBlockOperation *)remoteProcessDefinitionListOperation {
    if ([self.delegate respondsToSelector:@selector(dataAccessorDidStartFetchingRemoteData:)]) {
        [self.delegate dataAccessorDidStartFetchingRemoteData:self];
    }
    
    __weak typeof(self) weakSelf = self;
    ASDKAsyncBlockOperation *remoteProcessDefinitionListOperation = [ASDKAsyncBlockOperation blockOperationWithBlock:^(ASDKAsyncBlockOperation *operation) {
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf.processDefinitionNetworkService fetchProcessDefinitionListWithCompletionBlock:^(NSArray *processDefinitions, NSError *error, ASDKModelPaging *paging) {
            if (operation.isCancelled) {
                [operation complete];
                return;
            }
            
            ASDKDataAccessorResponseCollection *responseCollection = [[ASDKDataAccessorResponseCollection alloc] initWithCollection:processDefinitions
                                                                                                                             paging:paging
                                                                                                                       isCachedData:NO
                                                                                                                              error:error];
            if (weakSelf.delegate) {
                [weakSelf.delegate dataAccessor:weakSelf
                            didLoadDataResponse:responseCollection];
            }
            
            operation.result = responseCollection;
            [operation complete];
        }];
    }];
    
    return remoteProcessDefinitionListOperation;
}

- (ASDKAsyncBlockOperation *)cachedProcessDefinitionListOperation {
    __weak typeof(self) weakSelf = self;
    ASDKAsyncBlockOperation *cachedProcessDefinitionListOperation = [ASDKAsyncBlockOperation blockOperationWithBlock:^(ASDKAsyncBlockOperation *operation) {
        __strong typeof(self) strongSelf = weakSelf;
        
        [strongSelf.processDefinitionCacheService
         fetchProcessDefinitionListForAppID:nil
         withCompletionBlock:^(NSArray *processDefinitions, NSError *error, ASDKModelPaging *paging) {
             if (operation.isCancelled) {
                 [operation complete];
                 return;
             }
             
             if (!error) {
                 ASDKLogVerbose(@"Ad-hoc process definition list information successfully fetched from the cache.");
                 
                 ASDKDataAccessorResponseCollection *response = [[ASDKDataAccessorResponseCollection alloc] initWithCollection:processDefinitions
                                                                                                                        paging:paging
                                                                                                                  isCachedData:YES
                                                                                                                         error:error];
                 if (weakSelf.delegate) {
                     [weakSelf.delegate dataAccessor:weakSelf
                                 didLoadDataResponse:response];
                 }
             } else {
                 ASDKLogError(@"An error occured while fetching cache ad-hoc process definition list information. Reason: %@", error.localizedDescription);
             }
             
             [operation complete];
         }];
    }];
    
    return cachedProcessDefinitionListOperation;
}

- (ASDKAsyncBlockOperation *)processDefinitionListStoreInCacheOperation {
    __weak typeof(self) weakSelf = self;
    ASDKAsyncBlockOperation *storeInCacheOperation = [ASDKAsyncBlockOperation blockOperationWithBlock:^(ASDKAsyncBlockOperation *operation) {
        __strong typeof(self) strongSelf = weakSelf;
        
        ASDKAsyncBlockOperation *dependencyOperation = (ASDKAsyncBlockOperation *)operation.dependencies.firstObject;
        ASDKDataAccessorResponseCollection *remoteResponse = dependencyOperation.result;
        
        if (remoteResponse.collection) {
            [strongSelf.processDefinitionCacheService cacheProcessDefinitionList:remoteResponse.collection
                                                                        forAppID:nil
                                                             withCompletionBlock:^(NSError *error) {
                                                                 if (operation.isCancelled) {
                                                                     [operation complete];
                                                                     return;
                                                                 }
                                                                 
                                                                 if (!error) {
                                                                     ASDKLogVerbose(@"Ad-hoc process definition list was successfully cached.");
                                                                     [weakSelf.processDefinitionCacheService saveChanges];
                                                                 } else {
                                                                     ASDKLogError(@"Encountered an error while caching the ad-hoc process definition list. Reason: %@", error.localizedDescription);
                                                                 }
                                                                 
                                                                 [operation complete];
            }];
        }
    }];
    
    return storeInCacheOperation;
}


#pragma mark -
#pragma mark Service - Process definition list for application

- (void)fetchProcessDefinitionListForAppID:(NSString *)appID {
    NSParameterAssert(appID);
    
    // Define operations
    ASDKAsyncBlockOperation *remoteProcessDefinitionListOperation = [self remoteProcessDefinitionListOperationForAppID:appID];
    ASDKAsyncBlockOperation *cachedProcessDefinitionListOperation = [self cachedProcessDefinitionListOperationForAppID:appID];
    ASDKAsyncBlockOperation *storeInCacheProcessDefinitionListOperation = [self processDefinitionListStoreInCacheOperationForAppID:appID];
    ASDKAsyncBlockOperation *completionOperation = [self defaultCompletionOperation];
    
    switch (self.cachePolicy) {
        case ASDKServiceDataAccessorCachingPolicyCacheOnly: {
            [completionOperation addDependency:cachedProcessDefinitionListOperation];
            [self.processingQueue addOperations:@[cachedProcessDefinitionListOperation,
                                                  completionOperation]
                              waitUntilFinished:NO];
        }
            break;
            
        case ASDKServiceDataAccessorCachingPolicyAPIOnly: {
            [completionOperation addDependency:remoteProcessDefinitionListOperation];
            [self.processingQueue addOperations:@[remoteProcessDefinitionListOperation,
                                                  completionOperation]
                              waitUntilFinished:NO];
        }
            break;
            
        case ASDKServiceDataAccessorCachingPolicyHybrid: {
            [remoteProcessDefinitionListOperation addDependency:cachedProcessDefinitionListOperation];
            [storeInCacheProcessDefinitionListOperation addDependency:remoteProcessDefinitionListOperation];
            [completionOperation addDependency:storeInCacheProcessDefinitionListOperation];
            [self.processingQueue addOperations:@[cachedProcessDefinitionListOperation,
                                                  remoteProcessDefinitionListOperation,
                                                  storeInCacheProcessDefinitionListOperation,
                                                  completionOperation]
                              waitUntilFinished:NO];
        }
            break;
            
        default: break;
    }
}

- (ASDKAsyncBlockOperation *)remoteProcessDefinitionListOperationForAppID:(NSString *)applicationID {
    if ([self.delegate respondsToSelector:@selector(dataAccessorDidStartFetchingRemoteData:)]) {
        [self.delegate dataAccessorDidStartFetchingRemoteData:self];
    }
    
    __weak typeof(self) weakSelf = self;
    ASDKAsyncBlockOperation *remoteProcessDefinitionListOperation = [ASDKAsyncBlockOperation blockOperationWithBlock:^(ASDKAsyncBlockOperation *operation) {
        __strong typeof(self) strongSelf = weakSelf;
        
        [strongSelf.processDefinitionNetworkService
         fetchProcessDefinitionListForAppID:applicationID
         completionBlock:^(NSArray *processDefinitions, NSError *error, ASDKModelPaging *paging) {
             if (operation.isCancelled) {
                 [operation complete];
                 return;
             }
             
             ASDKDataAccessorResponseCollection *responseCollection = [[ASDKDataAccessorResponseCollection alloc] initWithCollection:processDefinitions
                                                                                                                              paging:paging
                                                                                                                        isCachedData:NO
                                                                                                                               error:error];
             if (weakSelf.delegate) {
                 [weakSelf.delegate dataAccessor:weakSelf
                             didLoadDataResponse:responseCollection];
             }
             
             operation.result = responseCollection;
             [operation complete];
         }];
    }];
    
    return remoteProcessDefinitionListOperation;
}

- (ASDKAsyncBlockOperation *)cachedProcessDefinitionListOperationForAppID:(NSString *)applicationID {
    __weak typeof(self) weakSelf = self;
    ASDKAsyncBlockOperation *cachedProcessDefinitionListOperation = [ASDKAsyncBlockOperation blockOperationWithBlock:^(ASDKAsyncBlockOperation *operation) {
        __strong typeof(self) strongSelf = weakSelf;
        
        [strongSelf.processDefinitionCacheService
         fetchProcessDefinitionListForAppID:applicationID
         withCompletionBlock:^(NSArray *processDefinitions, NSError *error, ASDKModelPaging *paging) {
             if (operation.isCancelled) {
                 [operation complete];
                 return;
             }
             
             if (!error) {
                 ASDKLogVerbose(@"Process definition list information successfully fetched from the cache for applicationID: %@.", applicationID);
                 
                 ASDKDataAccessorResponseCollection *response = [[ASDKDataAccessorResponseCollection alloc] initWithCollection:processDefinitions
                                                                                                                        paging:paging
                                                                                                                  isCachedData:YES
                                                                                                                         error:error];
                 if (weakSelf.delegate) {
                     [weakSelf.delegate dataAccessor:weakSelf
                                 didLoadDataResponse:response];
                 }
             } else {
                 ASDKLogError(@"An error occured while fetching cache process definition list information for applicationID: %@. Reason: %@", applicationID, error.localizedDescription);
             }
             
             [operation complete];
         }];
    }];
    
    return cachedProcessDefinitionListOperation;
}

- (ASDKAsyncBlockOperation *)processDefinitionListStoreInCacheOperationForAppID:(NSString *)applicationID {
    __weak typeof(self) weakSelf = self;
    ASDKAsyncBlockOperation *storeInCacheOperation = [ASDKAsyncBlockOperation blockOperationWithBlock:^(ASDKAsyncBlockOperation *operation) {
        __strong typeof(self) strongSelf = weakSelf;
        
        ASDKAsyncBlockOperation *dependencyOperation = (ASDKAsyncBlockOperation *)operation.dependencies.firstObject;
        ASDKDataAccessorResponseCollection *remoteResponse = dependencyOperation.result;
        
        if (remoteResponse.collection) {
            [strongSelf.processDefinitionCacheService cacheProcessDefinitionList:remoteResponse.collection
                                                                        forAppID:applicationID
                                                             withCompletionBlock:^(NSError *error) {
                                                                 if (operation.isCancelled) {
                                                                     [operation complete];
                                                                     return;
                                                                 }
                                                                 
                                                                 if (!error) {
                                                                     ASDKLogVerbose(@"Process definition list was successfully cached for applicationID: %@.", applicationID);
                                                                     [weakSelf.processDefinitionCacheService saveChanges];
                                                                 } else {
                                                                     ASDKLogError(@"Encountered an error while caching the process definition list for applicationID: %@. Reason: %@", applicationID, error.localizedDescription);
                                                                 }
                                                                 
                                                                 [operation complete];
                                                             }];
        }
    }];
    
    return storeInCacheOperation;
}


#pragma mark -
#pragma mark Cancel operations

- (void)cancelOperations {
    [super cancelOperations];
    [self.processingQueue cancelAllOperations];
}


#pragma mark -
#pragma mark Private interface

- (ASDKProcessDefinitionNetworkServices *)processDefinitionNetworkService {
    return (ASDKProcessDefinitionNetworkServices *)self.networkService;
}

- (ASDKProcessDefinitionCacheService *)processDefinitionCacheService {
    return (ASDKProcessDefinitionCacheService *)self.cacheService;
}

- (ASDKAsyncBlockOperation *)defaultCompletionOperation {
    __weak typeof(self) weakSelf = self;
    ASDKAsyncBlockOperation *completionOperation = [ASDKAsyncBlockOperation blockOperationWithBlock:^(ASDKAsyncBlockOperation *operation) {
        __strong typeof(self) strongSelf = weakSelf;
        
        if (operation.isCancelled) {
            [operation complete];
        }
        
        if (strongSelf.delegate) {
            [strongSelf.delegate dataAccessorDidFinishedLoadingDataResponse:strongSelf];
        }
        
        [operation complete];
    }];
    
    return completionOperation;
}

@end

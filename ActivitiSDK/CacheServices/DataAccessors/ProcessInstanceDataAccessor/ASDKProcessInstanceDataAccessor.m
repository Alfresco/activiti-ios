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

#import "ASDKProcessInstanceDataAccessor.h"

// Constants
#import "ASDKLogConfiguration.h"

// Operations
#import "ASDKAsyncBlockOperation.h"

// Managers
#import "ASDKBootstrap.h"
#import "ASDKProcessInstanceNetworkServices.h"
#import "ASDKServiceLocator.h"
#import "ASDKProcessInstanceCacheService.h"

// Model
#import "ASDKDataAccessorResponseCollection.h"
#import "ASDKDataAccessorResponseModel.h"
#import "ASDKDataAccessorResponseConfirmation.h"
#import "ASDKDataAccessorResponseProgress.h"

static const int activitiSDKLogLevel = ASDK_LOG_LEVEL_VERBOSE; // | ASDK_LOG_FLAG_TRACE;

@interface ASDKProcessInstanceDataAccessor ()

@property (strong, nonatomic) NSOperationQueue *processingQueue;

@end

@implementation ASDKProcessInstanceDataAccessor

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
        _networkService = (ASDKProcessInstanceNetworkServices *)[sdkBootstrap.serviceLocator serviceConformingToProtocol:@protocol(ASDKProcessInstanceNetworkServiceProtocol)];
        _networkService.resultsQueue = processUpdatesProcessingQueue;
        _cacheService = [ASDKProcessInstanceCacheService new];
    }
    
    return self;
}


#pragma mark -
#pragma mark Service - Process instance list

- (void)fetchProcessInstancesWithFilter:(ASDKFilterRequestRepresentation *)filter {
    NSParameterAssert(filter);
    
    // Define operations
    ASDKAsyncBlockOperation *remoteProcessInstanceListOperation = [self remoteProcessInstanceListOperationForFilter:filter];
    ASDKAsyncBlockOperation *cachedProcessInstanceListOperation = [self cachedProcessInstanceListOperationForFilter:filter];
    ASDKAsyncBlockOperation *storeInCacheProcessInstanceListOperation = [self processInstanceListStoreInCacheOperationWithFilter:filter];
    ASDKAsyncBlockOperation *completionOperation = [self defaultCompletionOperation];
    
    // Handle cache policies
    switch (self.cachePolicy) {
        case ASDKServiceDataAccessorCachingPolicyCacheOnly: {
            [completionOperation addDependency:cachedProcessInstanceListOperation];
            [self.processingQueue addOperations:@[cachedProcessInstanceListOperation,
                                                  completionOperation]
                              waitUntilFinished:NO];
        }
            break;
            
        case ASDKServiceDataAccessorCachingPolicyAPIOnly: {
            [completionOperation addDependency:remoteProcessInstanceListOperation];
            [self.processingQueue addOperations:@[remoteProcessInstanceListOperation,
                                                  completionOperation]
                              waitUntilFinished:NO];
        }
            break;
            
        case ASDKServiceDataAccessorCachingPolicyHybrid: {
            [remoteProcessInstanceListOperation addDependency:cachedProcessInstanceListOperation];
            [storeInCacheProcessInstanceListOperation addDependency:remoteProcessInstanceListOperation];
            [completionOperation addDependency:storeInCacheProcessInstanceListOperation];
            [self.processingQueue addOperations:@[cachedProcessInstanceListOperation,
                                                  remoteProcessInstanceListOperation,
                                                  storeInCacheProcessInstanceListOperation,
                                                  completionOperation]
                              waitUntilFinished:NO];
        }
            break;
            
        default: break;
    }
}

- (ASDKAsyncBlockOperation *)remoteProcessInstanceListOperationForFilter:(ASDKFilterRequestRepresentation *)filter {
    if ([self.delegate respondsToSelector:@selector(dataAccessorDidStartFetchingRemoteData:)]) {
        [self.delegate dataAccessorDidStartFetchingRemoteData:self];
    }
    
    __weak typeof(self) weakSelf = self;
    ASDKAsyncBlockOperation *remoteProcessInstanceListOperation = [ASDKAsyncBlockOperation blockOperationWithBlock:^(ASDKAsyncBlockOperation *operation) {
        __strong typeof(self) strongSelf = weakSelf;
        
        [strongSelf.processInstanceNetworkService
         fetchProcessInstanceListWithFilterRepresentation:filter
         completionBlock:^(NSArray *processes, NSError *error, ASDKModelPaging *paging) {
             if (operation.isCancelled) {
                 [operation complete];
                 return;
             }
             
             ASDKDataAccessorResponseCollection *responseCollection = [[ASDKDataAccessorResponseCollection alloc] initWithCollection:processes
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
    
    return remoteProcessInstanceListOperation;
}

- (ASDKAsyncBlockOperation *)cachedProcessInstanceListOperationForFilter:(ASDKFilterRequestRepresentation *)filter {
    __weak typeof(self) weakSelf = self;
    ASDKAsyncBlockOperation *cachedProcessInstanceListOperation = [ASDKAsyncBlockOperation blockOperationWithBlock:^(ASDKAsyncBlockOperation *operation) {
        __strong typeof(self) strongSelf = weakSelf;
        
        [strongSelf.processInstanceCacheService fetchProcessInstanceList:^(NSArray *processes, NSError *error, ASDKModelPaging *paging) {
            if (operation.isCancelled) {
                [operation complete];
                return;
            }
            
            if (!error) {
                ASDKLogVerbose(@"Process instance list information successfully fetched from the cache for filter.\nFilter:%@", filter);
                
                ASDKDataAccessorResponseCollection *response = [[ASDKDataAccessorResponseCollection alloc] initWithCollection:processes
                                                                                                                       paging:paging
                                                                                                                 isCachedData:YES
                                                                                                                        error:error];
                if (weakSelf.delegate) {
                    [weakSelf.delegate dataAccessor:weakSelf
                                didLoadDataResponse:response];
                }
            } else {
                ASDKLogError(@"An error occured while fetching cache process instance list information. Reason: %@", error.localizedDescription);
            }
            
            [operation complete];
        } usingFilter:filter];
    }];
    
    return cachedProcessInstanceListOperation;
}

- (ASDKAsyncBlockOperation *)processInstanceListStoreInCacheOperationWithFilter:(ASDKFilterRequestRepresentation *)filter {
    __weak typeof(self) weakSelf = self;
    ASDKAsyncBlockOperation *storeInCacheOperation = [ASDKAsyncBlockOperation blockOperationWithBlock:^(ASDKAsyncBlockOperation *operation) {
        __strong typeof(self) strongSelf = weakSelf;
        
        ASDKAsyncBlockOperation *dependencyOperation = (ASDKAsyncBlockOperation *)operation.dependencies.firstObject;
        ASDKDataAccessorResponseCollection *remoteResponse = dependencyOperation.result;
        
        if (remoteResponse.collection) {
            [strongSelf.processInstanceCacheService cacheProcessInstanceList:remoteResponse.collection
                                                                 usingFilter:filter
                                                         withCompletionBlock:^(NSError *error) {
                                                             if (operation.isCancelled) {
                                                                 [operation complete];
                                                                 return;
                                                             }
                                                             
                                                             if (!error) {
                                                                 ASDKLogVerbose(@"Process intance list was successfully cached for filter.\nFilter: %@", filter);
                                                                 
                                                                 [weakSelf.processInstanceCacheService saveChanges];
                                                             } else {
                                                                 ASDKLogError(@"Encountered an error while caching the process instance list for filter: %@. Reason: %@", filter, error.localizedDescription);
                                                             }
                                                             
                                                             [operation complete];
                                                         }];
        }
    }];
    
    return storeInCacheOperation;
}


#pragma mark -
#pragma mark Service - Process instance details

- (void)fetchProcessInstanceDetailsForProcessInstanceID:(NSString *)processInstanceID {
    NSParameterAssert(processInstanceID);
    
    // Define operations
    ASDKAsyncBlockOperation *remoteProcessInstanceDetailsOperation = [self remoteProcessInstanceDetailsForProcessInstanceID:processInstanceID];
    ASDKAsyncBlockOperation *cachedProcessInstanceDetailsOperation = [self cachedProcessInstanceDetailsForProcessInstanceID:processInstanceID];
    ASDKAsyncBlockOperation *storeInCacheProcessInstanceDetailsOperation = [self processInstanceDetailsStoreInCacheOperationForProcessInstanceID:processInstanceID];
    ASDKAsyncBlockOperation *completionOperation = [self defaultCompletionOperation];
    
    // Handle cache policies
    switch (self.cachePolicy) {
        case ASDKServiceDataAccessorCachingPolicyCacheOnly: {
            [completionOperation addDependency:cachedProcessInstanceDetailsOperation];
            [self.processingQueue addOperations:@[cachedProcessInstanceDetailsOperation,
                                                  completionOperation]
                              waitUntilFinished:NO];
        }
            break;
            
        case ASDKServiceDataAccessorCachingPolicyAPIOnly: {
            [completionOperation addDependency:remoteProcessInstanceDetailsOperation];
            [self.processingQueue addOperations:@[remoteProcessInstanceDetailsOperation,
                                                  completionOperation]
                              waitUntilFinished:NO];
        }
            break;
            
        case ASDKServiceDataAccessorCachingPolicyHybrid: {
            [remoteProcessInstanceDetailsOperation addDependency:cachedProcessInstanceDetailsOperation];
            [storeInCacheProcessInstanceDetailsOperation addDependency:remoteProcessInstanceDetailsOperation];
            [completionOperation addDependency:storeInCacheProcessInstanceDetailsOperation];
            [self.processingQueue addOperations:@[cachedProcessInstanceDetailsOperation,
                                                  remoteProcessInstanceDetailsOperation,
                                                  storeInCacheProcessInstanceDetailsOperation,
                                                  completionOperation]
                              waitUntilFinished:NO];
        }
            break;
            
        default: break;
    }
}

- (ASDKAsyncBlockOperation *)remoteProcessInstanceDetailsForProcessInstanceID:(NSString *)processInstanceID {
    if ([self.delegate respondsToSelector:@selector(dataAccessorDidStartFetchingRemoteData:)]) {
        [self.delegate dataAccessorDidStartFetchingRemoteData:self];
    }
    
    __weak typeof(self) weakSelf = self;
    ASDKAsyncBlockOperation *remoteProcessInstanceDetailsOperation = [ASDKAsyncBlockOperation blockOperationWithBlock:^(ASDKAsyncBlockOperation *operation) {
        __strong typeof(self) strongSelf = weakSelf;
        
        [strongSelf.processInstanceNetworkService fetchProcessInstanceDetailsForID:processInstanceID
                                                                   completionBlock:^(ASDKModelProcessInstance *processInstance, NSError *error) {
                                                                       if (operation.isCancelled) {
                                                                           [operation complete];
                                                                           return;
                                                                       }
                                                                       
                                                                       ASDKDataAccessorResponseModel *response = [[ASDKDataAccessorResponseModel alloc] initWithModel:processInstance
                                                                                                                                                         isCachedData:NO
                                                                                                                                                                error:error];
                                                                       if (weakSelf.delegate) {
                                                                           [weakSelf.delegate dataAccessor:weakSelf
                                                                                       didLoadDataResponse:response];
                                                                       }
                                                                       
                                                                       operation.result = response;
                                                                       [operation complete];
                                                                   }];
    }];
    
    return remoteProcessInstanceDetailsOperation;
}

- (ASDKAsyncBlockOperation *)cachedProcessInstanceDetailsForProcessInstanceID:(NSString *)processInstanceID {
    __weak typeof(self) weakSelf = self;
    ASDKAsyncBlockOperation *cachedProcessInstanceDetailsOperation = [ASDKAsyncBlockOperation blockOperationWithBlock:^(ASDKAsyncBlockOperation *operation) {
        __strong typeof(self) strongSelf = weakSelf;
        
        [strongSelf.processInstanceCacheService
         fetchProcesInstanceDetailsForID:processInstanceID
         withCompletionBlock:^(ASDKModelProcessInstance *processInstance, NSError *error) {
             if (operation.isCancelled) {
                 [operation complete];
                 return;
             }
             
             if (!error) {
                 if (processInstance) {
                     ASDKLogVerbose(@"Process instance details information successfully fetched from cache for processInstanceID:%@", processInstanceID);
                     
                     ASDKDataAccessorResponseModel *response = [[ASDKDataAccessorResponseModel alloc] initWithModel:processInstance
                                                                                                       isCachedData:YES
                                                                                                              error:error];
                     
                     if (weakSelf.delegate) {
                         [weakSelf.delegate dataAccessor:weakSelf
                                     didLoadDataResponse:response];
                     }
                 }
             } else {
                 ASDKLogError(@"An error occured while fetching cached process instance details for processInstanceID:%@. Reason:%@", processInstanceID, error.localizedDescription);
             }
             
             [operation complete];
         }];
    }];
    
    return cachedProcessInstanceDetailsOperation;
}

- (ASDKAsyncBlockOperation *)processInstanceDetailsStoreInCacheOperationForProcessInstanceID:(NSString *)processInstanceID {
    __weak typeof(self) weakSelf = self;
    ASDKAsyncBlockOperation *storeInCacheOperation = [ASDKAsyncBlockOperation blockOperationWithBlock:^(ASDKAsyncBlockOperation *operation) {
        __strong typeof(self) strongSelf = weakSelf;
        ASDKAsyncBlockOperation *dependencyOperation = (ASDKAsyncBlockOperation *)operation.dependencies.firstObject;
        ASDKDataAccessorResponseModel *remoteResponse = dependencyOperation.result;
        
        if (remoteResponse.model) {
            [strongSelf.processInstanceCacheService cacheProcessInstanceDetails:remoteResponse.model
                                                            withCompletionBlock:^(NSError *error) {
                                                                if (operation.isCancelled) {
                                                                    [operation complete];
                                                                    return;
                                                                }
                                                                
                                                                if (!error) {
                                                                    ASDKLogVerbose(@"Process instance details successfully cached for processInstanceID: %@", processInstanceID);
                                                                    [[weakSelf processInstanceCacheService] saveChanges];
                                                                } else {
                                                                    ASDKLogError(@"Encountered an error while caching the process instance details for processInstanceID: %@. Reason: %@", processInstanceID, error.localizedDescription);
                                                                    
                                                                    [operation complete];
                                                                }
                                                            }];
        }
    }];
    
    return storeInCacheOperation;
}


#pragma mark -
#pragma mark Service - Process instance content

- (void)fetchProcessInstanceContentForProcessInstanceID:(NSString *)processInstanceID {
    NSParameterAssert(processInstanceID);
    
    // Define operations
    ASDKAsyncBlockOperation *remoteProcessInstanceContentOperation = [self remoteProcessInstanceContentForProcessInstanceID:processInstanceID];
    ASDKAsyncBlockOperation *cachedProcessInstanceContentOperation = [self cachedProcessInstanceContentForProcessInstanceID:processInstanceID];
    ASDKAsyncBlockOperation *storeInCacheProcessInstanceContentOperation = [self processInstanceContentStoreInCacheOperationForProcessInstanceID:processInstanceID];
    ASDKAsyncBlockOperation *completionOperation = [self defaultCompletionOperation];
    
    // Handle cache policies
    switch (self.cachePolicy) {
        case ASDKServiceDataAccessorCachingPolicyCacheOnly: {
            [completionOperation addDependency:cachedProcessInstanceContentOperation];
            [self.processingQueue addOperations:@[cachedProcessInstanceContentOperation,
                                                  completionOperation]
                              waitUntilFinished:NO];
        }
            break;
            
        case ASDKServiceDataAccessorCachingPolicyAPIOnly: {
            [completionOperation addDependency:remoteProcessInstanceContentOperation];
            [self.processingQueue addOperations:@[remoteProcessInstanceContentOperation,
                                                  completionOperation]
                              waitUntilFinished:NO];
        }
            break;
            
        case ASDKServiceDataAccessorCachingPolicyHybrid: {
            [remoteProcessInstanceContentOperation addDependency:cachedProcessInstanceContentOperation];
            [storeInCacheProcessInstanceContentOperation addDependency:remoteProcessInstanceContentOperation];
            [completionOperation addDependency:storeInCacheProcessInstanceContentOperation];
            [self.processingQueue addOperations:@[cachedProcessInstanceContentOperation,
                                                  remoteProcessInstanceContentOperation,
                                                  storeInCacheProcessInstanceContentOperation,
                                                  completionOperation]
                              waitUntilFinished:NO];
        }
            break;
            
        default: break;
    }
}

- (ASDKAsyncBlockOperation *)remoteProcessInstanceContentForProcessInstanceID:(NSString *)processInstanceID {
    if ([self.delegate respondsToSelector:@selector(dataAccessorDidStartFetchingRemoteData:)]) {
        [self.delegate dataAccessorDidStartFetchingRemoteData:self];
    }
    
    __weak typeof(self) weakSelf = self;
    ASDKAsyncBlockOperation *remoteProcessInstanceContentOperation = [ASDKAsyncBlockOperation blockOperationWithBlock:^(ASDKAsyncBlockOperation * operation) {
        __strong typeof(self) strongSelf = weakSelf;
        
        [strongSelf.processInstanceNetworkService
         fetchProcesInstanceContentForProcessInstanceID:processInstanceID
         completionBlock:^(NSArray *contentList, NSError *error) {
             if (operation.isCancelled) {
                 [operation complete];
                 return;
             }
             
             ASDKDataAccessorResponseCollection *responseCollection =
             [[ASDKDataAccessorResponseCollection alloc] initWithCollection:contentList
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
    
    return remoteProcessInstanceContentOperation;
}

- (ASDKAsyncBlockOperation *)cachedProcessInstanceContentForProcessInstanceID:(NSString *)processInstanceID {
    __weak typeof(self) weakSelf = self;
    ASDKAsyncBlockOperation *cachedProcessInstanceContentListOperation = [ASDKAsyncBlockOperation blockOperationWithBlock:^(ASDKAsyncBlockOperation *operation) {
        __strong typeof(self) strongSelf = weakSelf;
        
        [strongSelf.processInstanceCacheService
         fetchProcessInstanceContentForID:processInstanceID
         withCompletionBlock:^(NSArray *contentList, NSError *error) {
             if (operation.isCancelled) {
                 [operation complete];
                 return;
             }
             
             if (!error) {
                 ASDKLogVerbose(@"Process instance content list information successfully fetched from the cache for processInstanceID:%@", processInstanceID);
                 
                 ASDKDataAccessorResponseCollection *response =
                 [[ASDKDataAccessorResponseCollection alloc] initWithCollection:contentList
                                                                   isCachedData:YES
                                                                          error:error];
                 if (weakSelf.delegate) {
                     [weakSelf.delegate dataAccessor:weakSelf
                                 didLoadDataResponse:response];
                 }
             } else {
                 ASDKLogError(@"An error occured while fetching cache process instance content list information. Reason: %@", error.localizedDescription);
             }
             
             [operation complete];
         }];
    }];
    
    return cachedProcessInstanceContentListOperation;
}

- (ASDKAsyncBlockOperation *)processInstanceContentStoreInCacheOperationForProcessInstanceID:(NSString *)processInstanceID {
    __weak typeof(self) weakSelf = self;
    ASDKAsyncBlockOperation *storeInCacheOperation = [ASDKAsyncBlockOperation blockOperationWithBlock:^(ASDKAsyncBlockOperation *operation) {
        __strong typeof(self) strongSelf = weakSelf;
        
        ASDKAsyncBlockOperation *dependencyOperation = (ASDKAsyncBlockOperation *)operation.dependencies.firstObject;
        ASDKDataAccessorResponseCollection *remoteResponse = dependencyOperation.result;
        
        if (remoteResponse.collection) {
            [strongSelf.processInstanceCacheService cacheProcessInstanceContent:remoteResponse.collection
                                                           forProcessInstanceID:processInstanceID
                                                            withCompletionBlock:^(NSError *error) {
                                                                if (operation.isCancelled) {
                                                                    [operation complete];
                                                                    return;
                                                                }
                                                                
                                                                if (!error) {
                                                                    ASDKLogVerbose(@"Process intance content list was successfully cached for processInstanceID:%@", processInstanceID);
                                                                    
                                                                    [weakSelf.processInstanceCacheService saveChanges];
                                                                } else {
                                                                    ASDKLogError(@"Encountered an error while caching the process instance content list for processInstanceID:%@. Reason:%@", processInstanceID, error.localizedDescription);
                                                                }
                                                                
                                                                [operation complete];
                                                            }];
        }
    }];
    
    return storeInCacheOperation;
}


#pragma mark -
#pragma mark Service - Delete process instance

- (void)deleteProcessInstanceWithID:(NSString *)processInstanceID {
    NSParameterAssert(processInstanceID);
    
    if ([self.delegate respondsToSelector:@selector(dataAccessorDidStartFetchingRemoteData:)]) {
        [self.delegate dataAccessorDidStartFetchingRemoteData:self];
    }
    
    __weak typeof(self) weakSelf = self;
    [self.processInstanceNetworkService deleteProcessInstanceWithID:processInstanceID
                                                    completionBlock:^(BOOL isProcessInstanceDeleted, NSError *error) {
                                                        __strong typeof(self) strongSelf = weakSelf;
                                                        
                                                        ASDKDataAccessorResponseConfirmation *confirmationResponse = [[ASDKDataAccessorResponseConfirmation alloc] initWithConfirmation:isProcessInstanceDeleted
                                                                                                                                                                           isCachedData:NO
                                                                                                                                                                                  error:error];
                                                        if (strongSelf.delegate) {
                                                            [strongSelf.delegate dataAccessor:strongSelf
                                                                          didLoadDataResponse:confirmationResponse];
                                                            [strongSelf.delegate dataAccessorDidFinishedLoadingDataResponse:strongSelf];
                                                        }
                                                    }];
}


#pragma mark -
#pragma mark Service - Process instance comments

- (void)fetchProcessInstanceCommentsForProcessInstanceID:(NSString *)processInstanceID {
    NSParameterAssert(processInstanceID);
    
    // Define operations
    ASDKAsyncBlockOperation *remoteProcessInstanceCommentListOperation = [self remoteProcessInstanceCommentListOperationForProcessInstanceID:processInstanceID];
    ASDKAsyncBlockOperation *cachedProcessInstanceCommentListOperation = [self cachedProcessInstanceCommentListOperationForProcessInstanceID:processInstanceID];
    ASDKAsyncBlockOperation *storeInCacheProcessInstanceCommentListOperation = [self processInstanceCommentListStoreInCacheOperationWithFilter:processInstanceID];
    ASDKAsyncBlockOperation *completionOperation = [self defaultCompletionOperation];
    
    // Handle cache policies
    switch (self.cachePolicy) {
        case ASDKServiceDataAccessorCachingPolicyCacheOnly: {
            [completionOperation addDependency:cachedProcessInstanceCommentListOperation];
            [self.processingQueue addOperations:@[cachedProcessInstanceCommentListOperation,
                                                  completionOperation]
                              waitUntilFinished:NO];
        }
            break;
            
        case ASDKServiceDataAccessorCachingPolicyAPIOnly: {
            [completionOperation addDependency:remoteProcessInstanceCommentListOperation];
            [self.processingQueue addOperations:@[remoteProcessInstanceCommentListOperation,
                                                  completionOperation]
                              waitUntilFinished:NO];
        }
            break;
            
        case ASDKServiceDataAccessorCachingPolicyHybrid: {
            [remoteProcessInstanceCommentListOperation addDependency:cachedProcessInstanceCommentListOperation];
            [storeInCacheProcessInstanceCommentListOperation addDependency:remoteProcessInstanceCommentListOperation];
            [completionOperation addDependency:storeInCacheProcessInstanceCommentListOperation];
            [self.processingQueue addOperations:@[cachedProcessInstanceCommentListOperation,
                                                  remoteProcessInstanceCommentListOperation,
                                                  storeInCacheProcessInstanceCommentListOperation,
                                                  completionOperation]
                              waitUntilFinished:NO];
        }
            break;
            
        default: break;
    }
}

- (ASDKAsyncBlockOperation *)remoteProcessInstanceCommentListOperationForProcessInstanceID:(NSString *)processInstanceID {
    if ([self.delegate respondsToSelector:@selector(dataAccessorDidStartFetchingRemoteData:)]) {
        [self.delegate dataAccessorDidStartFetchingRemoteData:self];
    }
    
    __weak typeof(self) weakSelf = self;
    ASDKAsyncBlockOperation *remoteProcessInstanceCommentListOperation = [ASDKAsyncBlockOperation blockOperationWithBlock:^(ASDKAsyncBlockOperation * operation) {
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf.processInstanceNetworkService
         fetchProcessInstanceCommentsForProcessInstanceID:processInstanceID
         completionBlock:^(NSArray *commentList, NSError *error, ASDKModelPaging *paging) {
             if (operation.isCancelled) {
                 [operation complete];
                 return;
             }
             
             ASDKDataAccessorResponseCollection *responseCollection =
             [[ASDKDataAccessorResponseCollection alloc] initWithCollection:commentList
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
    
    return remoteProcessInstanceCommentListOperation;
}

- (ASDKAsyncBlockOperation *)cachedProcessInstanceCommentListOperationForProcessInstanceID:(NSString *)processInstanceID {
    __weak typeof(self) weakSelf = self;
    ASDKAsyncBlockOperation *cachedProcessInstanceCommentListOperation = [ASDKAsyncBlockOperation blockOperationWithBlock:^(ASDKAsyncBlockOperation *operation) {
        __strong typeof(self) strongSelf = weakSelf;
        
        [strongSelf.processInstanceCacheService
         fetchProcessInstanceCommentListForID:processInstanceID
         withCompletionBlock:^(NSArray *commentList, NSError *error, ASDKModelPaging *paging) {
             if (operation.isCancelled) {
                 [operation complete];
             }
             
             if (!error) {
                 ASDKLogVerbose(@"Process instance comment list information successfully fetched from cache for processInstanceID:%@", processInstanceID);
                 
                 ASDKDataAccessorResponseCollection *response = [[ASDKDataAccessorResponseCollection alloc] initWithCollection:commentList
                                                                                                                        paging:paging
                                                                                                                  isCachedData:YES
                                                                                                                         error:error];
                 if (weakSelf.delegate) {
                     [weakSelf.delegate dataAccessor:weakSelf
                                 didLoadDataResponse:response];
                 }
             } else {
                 ASDKLogError(@"An error occured while fetching cache process instance comment list information. Reason: %@", error.localizedDescription);
             }
             
             [operation complete];
         }];
    }];
    
    return cachedProcessInstanceCommentListOperation;
}

- (ASDKAsyncBlockOperation *)processInstanceCommentListStoreInCacheOperationWithFilter:(NSString *)processInstanceID {
    __weak typeof(self) weakSelf = self;
    ASDKAsyncBlockOperation *storeInCacheOperation = [ASDKAsyncBlockOperation blockOperationWithBlock:^(ASDKAsyncBlockOperation *operation) {
        __strong typeof(self) strongSelf = weakSelf;
        
        ASDKAsyncBlockOperation *dependencyOperation = (ASDKAsyncBlockOperation *)operation.dependencies.firstObject;
        ASDKDataAccessorResponseCollection *remoteResponse = dependencyOperation.result;
        
        if (remoteResponse.collection) {
            [strongSelf.processInstanceCacheService cacheProcessInstanceCommentList:remoteResponse.collection
                                                               forProcessInstanceID:processInstanceID
                                                                withCompletionBlock:^(NSError *error) {
                                                                    if (operation.isCancelled) {
                                                                        [operation complete];
                                                                    }
                                                                    
                                                                    if (!error) {
                                                                        ASDKLogVerbose(@"Process instance content list was successfully cached for processInstanceID: %@", processInstanceID);
                                                                    } else {
                                                                        ASDKLogError(@"Encountered an error while caching the process instance content list for processInstanceID: %@. Reason: %@", processInstanceID, error.localizedDescription);
                                                                    }
                                                                    
                                                                    [operation complete];
                                                                }];
        }
    }];
    
    return storeInCacheOperation;
}


#pragma mark -
#pragma mark Service - Create process instance comment

- (void)createComment:(NSString *)comment
 forProcessInstanceID:(NSString *)processInstanceID {
    NSParameterAssert(comment);
    NSParameterAssert(processInstanceID);
    
    if ([self.delegate respondsToSelector:@selector(dataAccessorDidStartFetchingRemoteData:)]) {
        [self.delegate dataAccessorDidStartFetchingRemoteData:self];
    }
    
    __weak typeof(self) weakSelf = self;
    [self.processInstanceNetworkService createComment:comment
                                forProcessInstanceID :processInstanceID
                                      completionBlock:^(ASDKModelComment *comment, NSError *error) {
                                          __strong typeof(self) strongSelf = weakSelf;
                                          
                                          ASDKDataAccessorResponseModel *response =
                                          [[ASDKDataAccessorResponseModel alloc] initWithModel:comment
                                                                                  isCachedData:NO
                                                                                         error:error];
                                          if (strongSelf.delegate) {
                                              [strongSelf.delegate dataAccessor:weakSelf
                                                          didLoadDataResponse:response];
                                              
                                              [strongSelf.delegate dataAccessorDidFinishedLoadingDataResponse:strongSelf];
                                          }
                                      }];
}


#pragma mark -
#pragma mark Service - Download process instance audit log

- (void)downloadAuditLogForProcessInstanceWithID:(NSString *)processInstanceID {
    NSParameterAssert(processInstanceID);
    
    if ([self.delegate respondsToSelector:@selector(dataAccessorDidStartFetchingRemoteData:)]) {
        [self.delegate dataAccessorDidStartFetchingRemoteData:self];
    }
    
    __weak typeof(self) weakSelf = self;
    [self.processInstanceNetworkService downloadAuditLogForProcessInstanceWithID:processInstanceID
                                                              allowCachedResults:(self.cachePolicy == ASDKServiceDataAccessorCachingPolicyAPIOnly) ? NO : YES
                                                                   progressBlock:^(NSString *formattedReceivedBytesString, NSError *error) {
                                                                       __strong typeof(self) strongSelf = weakSelf;
                                                                       
                                                                       ASDKDataAccessorResponseProgress *responseProgress =
                                                                       [[ASDKDataAccessorResponseProgress alloc] initWithFormattedProgressString:formattedReceivedBytesString
                                                                                                                                           error:error];
                                                                       if (strongSelf.delegate) {
                                                                           [strongSelf.delegate dataAccessor:strongSelf
                                                                                         didLoadDataResponse:responseProgress];
                                                                       }
                                                                   }
                                                                 completionBlock:^(NSURL *downloadedContentURL, BOOL isLocalContent, NSError *error) {
                                                                     __strong typeof(self) strongSelf = weakSelf;
                                                                     
                                                                     ASDKDataAccessorResponseModel *responseModel =
                                                                     [[ASDKDataAccessorResponseModel alloc] initWithModel:downloadedContentURL
                                                                                                             isCachedData:isLocalContent
                                                                                                                    error:error];
                                                                     if (strongSelf.delegate) {
                                                                         [strongSelf.delegate dataAccessor:strongSelf
                                                                                       didLoadDataResponse:responseModel];
                                                                         
                                                                         [strongSelf.delegate dataAccessorDidFinishedLoadingDataResponse:strongSelf];
                                                                     }
                                                                 }];
}


#pragma mark -
#pragma mark Service - Start a process instance

- (void)startProcessInstanceWithStartProcessRequestRepresentation:(ASDKStartProcessRequestRepresentation *)startProcessRequestRepresentation {
    NSParameterAssert(startProcessRequestRepresentation);
    
    if ([self.delegate respondsToSelector:@selector(dataAccessorDidStartFetchingRemoteData:)]) {
        [self.delegate dataAccessorDidStartFetchingRemoteData:self];
    }
    
    __weak typeof(self) weakSelf = self;
    [self.processInstanceNetworkService
     startProcessInstanceWithStartProcessRequestRepresentation:startProcessRequestRepresentation
     completionBlock:^(ASDKModelProcessInstance *processInstance, NSError *error) {
         __strong typeof(self) strongSelf = weakSelf;
         ASDKDataAccessorResponseModel *responseModel = [[ASDKDataAccessorResponseModel alloc] initWithModel:processInstance
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
}


#pragma mark -
#pragma mark Private interface

- (ASDKProcessInstanceNetworkServices *)processInstanceNetworkService {
    return (ASDKProcessInstanceNetworkServices *)self.networkService;
}

- (ASDKProcessInstanceCacheService *)processInstanceCacheService {
    return (ASDKProcessInstanceCacheService *)self.cacheService;
}

- (ASDKAsyncBlockOperation *)defaultCompletionOperation {
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

@end

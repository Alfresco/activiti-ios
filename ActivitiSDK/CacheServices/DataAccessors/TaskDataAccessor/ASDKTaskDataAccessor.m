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

#import "ASDKTaskDataAccessor.h"

// Constants
#import "ASDKLogConfiguration.h"

// Managers
#import "ASDKBootstrap.h"
#import "ASDKTaskNetworkServices.h"
#import "ASDKTaskCacheService.h"
#import "ASDKServiceLocator.h"

// Operations
#import "ASDKAsyncBlockOperation.h"

// Model
#import "ASDKFilterRequestRepresentation.h"
#import "ASDKDataAccessorResponseCollection.h"
#import "ASDKDataAccessorResponseProgress.h"
#import "ASDKDataAccessorResponseModel.h"
#import "ASDKDataAccessorResponseConfirmation.h"
#import "ASDKModelFileContent.h"
#import "ASDKModelContent.h"
#import "ASDKModelServerConfiguration.h"
#import "ASDKModelUser.h"
#import "ASDKModelComment.h"
#import "ASDKTaskCreationRequestRepresentation.h"


static const int activitiSDKLogLevel = ASDK_LOG_LEVEL_VERBOSE; // | ASDK_LOG_FLAG_TRACE;

@interface ASDKTaskDataAccessor ()

@property (strong, nonatomic) NSOperationQueue *processingQueue;

@end

@implementation ASDKTaskDataAccessor

- (instancetype)initWithDelegate:(id<ASDKDataAccessorDelegate>)delegate {
    self = [super initWithDelegate:delegate];
    
    if (self) {
        _processingQueue = [self serialOperationQueue];
        _cachePolicy = ASDKServiceDataAccessorCachingPolicyHybrid;
        dispatch_queue_t taskUpdatesProcessingQueue = dispatch_queue_create([[NSString stringWithFormat:@"%@.`%@ProcessingQueue",
                                                                              [NSBundle bundleForClass:[self class]].bundleIdentifier,
                                                                              NSStringFromClass([self class])] UTF8String],
                                                                            DISPATCH_QUEUE_SERIAL);
        
        // Acquire and set up the task network service
        ASDKBootstrap *sdkBootstrap = [ASDKBootstrap sharedInstance];
        _networkService = (ASDKTaskNetworkServices *)[sdkBootstrap.serviceLocator serviceConformingToProtocol:@protocol(ASDKTaskNetworkServiceProtocol)];
        _networkService.resultsQueue = taskUpdatesProcessingQueue;
        _cacheService = [ASDKTaskCacheService new];
    }
    
    return self;
}


#pragma mark -
#pragma mark Service - Task list

- (void)fetchTasksWithFilter:(ASDKFilterRequestRepresentation *)filter {
    NSParameterAssert(filter);
    
    // Define operations
    ASDKAsyncBlockOperation *remoteTaskListOperation = [self remoteTaskListOperationForFilter:filter];
    ASDKAsyncBlockOperation *cachedTaskListOperation = [self cachedTaskListOperationForFilter:filter];
    ASDKAsyncBlockOperation *storeInCacheTaskListOperation = [self taskListStoreInCacheOperationWithFilter:filter];
    ASDKAsyncBlockOperation *completionOperation = [self defaultCompletionOperation];
    
    // Handle cache policies
    switch (self.cachePolicy) {
        case ASDKServiceDataAccessorCachingPolicyCacheOnly: {
            [completionOperation addDependency:cachedTaskListOperation];
            [self.processingQueue addOperations:@[cachedTaskListOperation,
                                                  completionOperation]
                              waitUntilFinished:NO];
        }
            break;
            
        case ASDKServiceDataAccessorCachingPolicyAPIOnly: {
            [completionOperation addDependency:remoteTaskListOperation];
            [self.processingQueue addOperations:@[remoteTaskListOperation,
                                                  completionOperation]
                              waitUntilFinished:NO];
        }
            break;
            
        case ASDKServiceDataAccessorCachingPolicyHybrid: {
            [remoteTaskListOperation addDependency:cachedTaskListOperation];
            [storeInCacheTaskListOperation addDependency:remoteTaskListOperation];
            [completionOperation addDependency:storeInCacheTaskListOperation];
            [self.processingQueue addOperations:@[cachedTaskListOperation,
                                                  remoteTaskListOperation,
                                                  storeInCacheTaskListOperation,
                                                  completionOperation]
                              waitUntilFinished:NO];
        }
            break;
            
        default: break;
    }
}

- (ASDKAsyncBlockOperation *)remoteTaskListOperationForFilter:(ASDKFilterRequestRepresentation *)filter {
    if ([self.delegate respondsToSelector:@selector(dataAccessorDidStartFetchingRemoteData:)]) {
        [self.delegate dataAccessorDidStartFetchingRemoteData:self];
    }
    
    __weak typeof(self) weakSelf = self;
    ASDKAsyncBlockOperation *remoteTaskListOperation = [ASDKAsyncBlockOperation blockOperationWithBlock:^(ASDKAsyncBlockOperation *operation) {
        __strong typeof(self) strongSelf = weakSelf;
        
        [strongSelf.taskNetworkService fetchTaskListWithFilterRepresentation:filter
                                                             completionBlock:^(NSArray *taskList, NSError *error, ASDKModelPaging *paging) {
                                                                 if (operation.isCancelled) {
                                                                     [operation complete];
                                                                     return;
                                                                 }
                                                                 
                                                                 ASDKDataAccessorResponseCollection *responseCollection =
                                                                 [[ASDKDataAccessorResponseCollection alloc] initWithCollection:taskList
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
    
    return remoteTaskListOperation;
}

- (ASDKAsyncBlockOperation *)cachedTaskListOperationForFilter:(ASDKFilterRequestRepresentation *)filter {
    __weak typeof(self) weakSelf = self;
    ASDKAsyncBlockOperation *cachedTaskListOperation = [ASDKAsyncBlockOperation blockOperationWithBlock:^(ASDKAsyncBlockOperation *operation) {
        __strong typeof(self) strongSelf = weakSelf;
        
        [strongSelf.taskCacheService fetchTaskList:^(NSArray *taskList, NSError *error, ASDKModelPaging *paging) {
            if (operation.isCancelled) {
                [operation complete];
                return;
            }
            
            if (!error) {
                ASDKLogVerbose(@"Task list information successfully fetched from cache for filter.\nFilter:%@", filter);
                
                ASDKDataAccessorResponseCollection *response =
                [[ASDKDataAccessorResponseCollection alloc] initWithCollection:taskList
                                                                        paging:paging
                                                                  isCachedData:YES
                                                                         error:error];
                
                if (weakSelf.delegate) {
                    [weakSelf.delegate dataAccessor:weakSelf
                                didLoadDataResponse:response];
                }
            } else {
                ASDKLogError(@"An error occured while fetching cache task list information. Reason: %@", error.localizedDescription);
            }
            
            [operation complete];
        } usingFilter:filter];
    }];
    
    return cachedTaskListOperation;
}

- (ASDKAsyncBlockOperation *)taskListStoreInCacheOperationWithFilter:(ASDKFilterRequestRepresentation *)filter {
    __weak typeof(self) weakSelf = self;
    ASDKAsyncBlockOperation *storeInCacheOperation = [ASDKAsyncBlockOperation blockOperationWithBlock:^(ASDKAsyncBlockOperation *operation) {
        __strong typeof(self) strongSelf = weakSelf;
        ASDKAsyncBlockOperation *dependencyOperation = (ASDKAsyncBlockOperation *)operation.dependencies.firstObject;
        ASDKDataAccessorResponseCollection *remoteResponse = dependencyOperation.result;
        
        if (remoteResponse.collection) {
            [strongSelf.taskCacheService cacheTaskList:remoteResponse.collection
                                           usingFilter:filter
                                   withCompletionBlock:^(NSError *error) {
                                       if (operation.isCancelled) {
                                           [operation complete];
                                           return;
                                       }
                                       
                                       if (!error) {
                                           ASDKLogVerbose(@"Task list was successfully cached for filter.\nFilter: %@", filter);
                                           
                                           [weakSelf.taskCacheService saveChanges];
                                       } else {
                                           ASDKLogError(@"Encountered an error while caching the task list for filter: %@. Reason:%@", filter, error.localizedDescription);
                                       }
                                       
                                       [operation complete];
                                   }];
        }
    }];
    
    return storeInCacheOperation;
}


#pragma mark -
#pragma mark Service - Task details

- (void)fetchTaskDetailsForTaskID:(NSString *)taskID {
    NSParameterAssert(taskID);
    
    // Define operations
    ASDKAsyncBlockOperation *remoteTaskDetailsOperation = [self remoteTaskDetailsOperationForTaskID:taskID];
    ASDKAsyncBlockOperation *cachedTaskDetailsOperation = [self cachedTaskDetailsOperationForTaskID:taskID];
    ASDKAsyncBlockOperation *storeInCacheTaskDetailsOperation = [self taskDetailsStoreInCacheOperationForTaskID:taskID];
    ASDKAsyncBlockOperation *completionOperation = [self defaultCompletionOperation];
    
    // Handle cache policies
    switch (self.cachePolicy) {
        case ASDKServiceDataAccessorCachingPolicyCacheOnly: {
            [completionOperation addDependency:cachedTaskDetailsOperation];
            [self.processingQueue addOperations:@[cachedTaskDetailsOperation,
                                                  completionOperation]
                              waitUntilFinished:NO];
        }
            break;
            
        case ASDKServiceDataAccessorCachingPolicyAPIOnly: {
            [completionOperation addDependency:remoteTaskDetailsOperation];
            [self.processingQueue addOperations:@[remoteTaskDetailsOperation,
                                                  completionOperation]
                              waitUntilFinished:NO];
        }
            break;
            
        case ASDKServiceDataAccessorCachingPolicyHybrid: {
            [remoteTaskDetailsOperation addDependency:cachedTaskDetailsOperation];
            [storeInCacheTaskDetailsOperation addDependency:remoteTaskDetailsOperation];
            [completionOperation addDependency:storeInCacheTaskDetailsOperation];
            [self.processingQueue addOperations:@[cachedTaskDetailsOperation,
                                                  remoteTaskDetailsOperation,
                                                  storeInCacheTaskDetailsOperation,
                                                  completionOperation]
                              waitUntilFinished:NO];
        }
            break;
            
        default: break;
    }
}

- (ASDKAsyncBlockOperation *)remoteTaskDetailsOperationForTaskID:(NSString *)taskID {
    if ([self.delegate respondsToSelector:@selector(dataAccessorDidStartFetchingRemoteData:)]) {
        [self.delegate dataAccessorDidStartFetchingRemoteData:self];
    }
    
    __weak typeof(self) weakSelf = self;
    ASDKAsyncBlockOperation *remoteTaskDetailsOperation = [ASDKAsyncBlockOperation blockOperationWithBlock:^(ASDKAsyncBlockOperation *operation) {
        __strong typeof(self) strongSelf = weakSelf;
        
        [strongSelf.taskNetworkService fetchTaskDetailsForTaskID:taskID
                                                 completionBlock:^(ASDKModelTask *task, NSError *error) {
                                                     if (operation.isCancelled) {
                                                         [operation complete];
                                                         return;
                                                     }
                                                     
                                                     ASDKDataAccessorResponseModel *response =
                                                     [[ASDKDataAccessorResponseModel alloc] initWithModel:task
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
    
    return remoteTaskDetailsOperation;
}

- (ASDKAsyncBlockOperation *)cachedTaskDetailsOperationForTaskID:(NSString *)taskID {
    __weak typeof(self) weakSelf = self;
    ASDKAsyncBlockOperation *cachedTaskDetailsOperation = [ASDKAsyncBlockOperation blockOperationWithBlock:^(ASDKAsyncBlockOperation *operation) {
        __strong typeof(self) strongSelf = weakSelf;
        
        [strongSelf.taskCacheService fetchTaskDetailsForID:taskID
                                       withCompletionBlock:^(ASDKModelTask *task, NSError *error) {
                                           if (operation.isCancelled) {
                                               [operation complete];
                                               return;
                                           }
                                           
                                           if (!error) {
                                               if (task) {
                                                   ASDKLogVerbose(@"Task details information successfully fetched from cache for taskID:%@", taskID);
                                                   
                                                   ASDKDataAccessorResponseModel *response =
                                                   [[ASDKDataAccessorResponseModel alloc] initWithModel:task
                                                                                           isCachedData:YES
                                                                                                  error:error];
                                                   
                                                   if (weakSelf.delegate) {
                                                       [weakSelf.delegate dataAccessor:weakSelf
                                                                   didLoadDataResponse:response];
                                                   }
                                               }
                                           } else {
                                               ASDKLogError(@"An error occured while fetching cached task details for taskID:%@. Reason:%@", taskID, error.localizedDescription);
                                           }
                                           
                                           [operation complete];
                                       }];
    }];
    
    return cachedTaskDetailsOperation;
}

- (ASDKAsyncBlockOperation *)taskDetailsStoreInCacheOperationForTaskID:(NSString *)taskID {
    __weak typeof(self) weakSelf = self;
    ASDKAsyncBlockOperation *storeInCacheOperation = [ASDKAsyncBlockOperation blockOperationWithBlock:^(ASDKAsyncBlockOperation *operation) {
        __strong typeof(self) strongSelf = weakSelf;
        ASDKAsyncBlockOperation *dependencyOperation = (ASDKAsyncBlockOperation *)operation.dependencies.firstObject;
        ASDKDataAccessorResponseModel *remoteResponse = dependencyOperation.result;
        
        if (remoteResponse.model) {
            [strongSelf.taskCacheService cacheTaskDetails:remoteResponse.model
                                      withCompletionBlock:^(NSError *error) {
                                          if (operation.isCancelled) {
                                              [operation complete];
                                              return;
                                          }
                                          
                                          if (!error) {
                                              ASDKLogVerbose(@"Task details successfully cached for taskID: %@", taskID);
                                              [[weakSelf taskCacheService] saveChanges];
                                          } else {
                                              ASDKLogError(@"Encountered an error while caching the task details for taskID: %@. Reason: %@", taskID, error.localizedDescription);
                                          }
                                          
                                          [operation complete];
                                      }];
        }
    }];
    
    return storeInCacheOperation;
}


#pragma mark -
#pragma mark Service - Task content list

- (void)fetchTaskContentForTaskID:(NSString *)taskID {
    NSParameterAssert(taskID);
    
    // Define operations
    ASDKAsyncBlockOperation *remoteTaskContentOperation = [self remoteTaskContentOperationForTaskID:taskID];
    ASDKAsyncBlockOperation *cachedTaskContentOperation = [self cachedTaskContentOperationForTaskID:taskID];
    ASDKAsyncBlockOperation *storeInCacheOperation = [self taskContentStoreInCacheOperationForTaskID:taskID];
    ASDKAsyncBlockOperation *completionOperation = [self defaultCompletionOperation];
    
    // Handle cache policies
    switch (self.cachePolicy) {
        case ASDKServiceDataAccessorCachingPolicyCacheOnly: {
            [completionOperation addDependency:cachedTaskContentOperation];
            [self.processingQueue addOperations:@[cachedTaskContentOperation, completionOperation]
                              waitUntilFinished:NO];
        }
            break;
            
        case ASDKServiceDataAccessorCachingPolicyAPIOnly: {
            [completionOperation addDependency:remoteTaskContentOperation];
            [self.processingQueue addOperations:@[remoteTaskContentOperation, completionOperation]
                              waitUntilFinished:NO];
        }
            break;
            
        case ASDKServiceDataAccessorCachingPolicyHybrid: {
            [remoteTaskContentOperation addDependency:cachedTaskContentOperation];
            [storeInCacheOperation addDependency:remoteTaskContentOperation];
            [completionOperation addDependency:storeInCacheOperation];
            [self.processingQueue addOperations:@[cachedTaskContentOperation,
                                                  remoteTaskContentOperation,
                                                  storeInCacheOperation,
                                                  completionOperation]
                              waitUntilFinished:NO];
        }
            break;
            
        default:
            break;
    }
}

- (ASDKAsyncBlockOperation *)remoteTaskContentOperationForTaskID:(NSString *)taskID {
    if ([self.delegate respondsToSelector:@selector(dataAccessorDidStartFetchingRemoteData:)]) {
        [self.delegate dataAccessorDidStartFetchingRemoteData:self];
    }
    
    __weak typeof(self) weakSelf = self;
    ASDKAsyncBlockOperation *remoteTaskContentOperation = [ASDKAsyncBlockOperation blockOperationWithBlock:^(ASDKAsyncBlockOperation *operation) {
        __strong typeof(self) strongSelf = weakSelf;
        
        [strongSelf.taskNetworkService fetchTaskContentForTaskID:taskID
                                                 completionBlock:^(NSArray *contentList, NSError *error) {
                                                     if (operation.isCancelled) {
                                                         [operation complete];
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
    
    return remoteTaskContentOperation;
}

- (ASDKAsyncBlockOperation *)cachedTaskContentOperationForTaskID:(NSString *)taskID {
    __weak typeof(self) weakSelf = self;
    ASDKAsyncBlockOperation *cachedTaskContentListOperation = [ASDKAsyncBlockOperation blockOperationWithBlock:^(ASDKAsyncBlockOperation *operation) {
        __strong typeof(self) strongSelf = weakSelf;
        
        [strongSelf.taskCacheService fetchTaskContentListForTaskWithID:taskID
                                                   withCompletionBlock:^(NSArray *taskContentList, NSError *error) {
                                                       if (operation.isCancelled) {
                                                           [operation complete];
                                                           return;
                                                       }
                                                       
                                                       if (!error) {
                                                           ASDKLogVerbose(@"Task content list successfully fetched from cache for taskID:%@", taskID);
                                                           ASDKDataAccessorResponseCollection *response =
                                                           [[ASDKDataAccessorResponseCollection alloc] initWithCollection:taskContentList
                                                                                                             isCachedData:YES
                                                                                                                    error:error];
                                                           if (weakSelf.delegate) {
                                                               [weakSelf.delegate dataAccessor:weakSelf
                                                                           didLoadDataResponse:response];
                                                           }
                                                       } else {
                                                           ASDKLogError(@"An Error occured while fetching the cached task content list. Reason: %@", error.localizedDescription);
                                                       }
                                                       
                                                       [operation complete];
                                                   }];
    }];
    
    return cachedTaskContentListOperation;
}

- (ASDKAsyncBlockOperation *)taskContentStoreInCacheOperationForTaskID:(NSString *)taskID {
    __weak typeof(self) weakSelf = self;
    ASDKAsyncBlockOperation *storeInCacheOperation = [ASDKAsyncBlockOperation blockOperationWithBlock:^(ASDKAsyncBlockOperation *operation) {
        __strong typeof(self) strongSelf = weakSelf;
        ASDKAsyncBlockOperation *dependencyOperation = (ASDKAsyncBlockOperation *)operation.dependencies.firstObject;
        ASDKDataAccessorResponseCollection *remoteResponse = dependencyOperation.result;
        
        if (remoteResponse.collection) {
            [strongSelf.taskCacheService cacheTaskContentList:remoteResponse.collection
                                                forTaskWithID:taskID
                                          withCompletionBlock:^(NSError *error) {
                                              if (operation.isCancelled) {
                                                  [operation complete];
                                                  return;
                                              }
                                              
                                              if (!error) {
                                                  ASDKLogVerbose(@"Task content successfully cached for taskID:%@", taskID);
                                                  
                                                  [weakSelf.taskCacheService saveChanges];
                                              } else {
                                                  ASDKLogError(@"Encountered an error while caching the task content list for taskID: %@. Reason:%@", taskID, error.localizedDescription);
                                              }
                                              
                                              [operation complete];
                                          }];
        }
    }];
    
    return storeInCacheOperation;
}


#pragma mark -
#pragma mark Service - Task comment list

- (void)fetchTaskCommentsForTaskID:(NSString *)taskID {
    NSParameterAssert(taskID);
    
    // Define operations
    ASDKAsyncBlockOperation *remoteTaskCommentListOperation = [self remoteTaskCommentListOperationForTaskID:taskID];
    ASDKAsyncBlockOperation *cachedTaskCommentListOperation = [self cachedTaskCommentListOperationForTaskID:taskID];
    ASDKAsyncBlockOperation *storeInCacheOperation = [self taskCommentListStoreInCacheOperationForTaskID:taskID];
    ASDKAsyncBlockOperation *completionOperation = [self defaultCompletionOperation];
    
    // Handle cache policies
    switch (self.cachePolicy) {
        case ASDKServiceDataAccessorCachingPolicyCacheOnly: {
            [completionOperation addDependency:cachedTaskCommentListOperation];
            [self.processingQueue addOperations:@[cachedTaskCommentListOperation, completionOperation]
                              waitUntilFinished:NO];
        }
            break;
            
        case ASDKServiceDataAccessorCachingPolicyAPIOnly: {
            [completionOperation addDependency:remoteTaskCommentListOperation];
            [self.processingQueue addOperations:@[remoteTaskCommentListOperation, completionOperation]
                              waitUntilFinished:NO];
        }
            break;
            
        case ASDKServiceDataAccessorCachingPolicyHybrid: {
            [remoteTaskCommentListOperation addDependency:cachedTaskCommentListOperation];
            [storeInCacheOperation addDependency:remoteTaskCommentListOperation];
            [completionOperation addDependency:storeInCacheOperation];
            [self.processingQueue addOperations:@[cachedTaskCommentListOperation,
                                                  remoteTaskCommentListOperation,
                                                  storeInCacheOperation,
                                                  completionOperation]
                              waitUntilFinished:NO];
        }
            break;
            
        default: break;
    }
}

- (ASDKAsyncBlockOperation *)remoteTaskCommentListOperationForTaskID:(NSString *)taskID {
    if ([self.delegate respondsToSelector:@selector(dataAccessorDidStartFetchingRemoteData:)]) {
        [self.delegate dataAccessorDidStartFetchingRemoteData:self];
    }
    
    __weak typeof(self) weakSelf = self;
    ASDKAsyncBlockOperation *remoteTaskContentOperation = [ASDKAsyncBlockOperation blockOperationWithBlock:^(ASDKAsyncBlockOperation *operation) {
        __strong typeof(self) strongSelf = weakSelf;
        
        [strongSelf.taskNetworkService fetchTaskCommentsForTaskID:taskID
                                                  completionBlock:^(NSArray *commentList, NSError *error, ASDKModelPaging *paging) {
                                                      if (operation.isCancelled) {
                                                          [operation complete];
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
    
    return remoteTaskContentOperation;
}

- (ASDKAsyncBlockOperation *)cachedTaskCommentListOperationForTaskID:(NSString *)taskID {
    __weak typeof(self) weakSelf = self;
    ASDKAsyncBlockOperation *cachedTaskContentListOperation = [ASDKAsyncBlockOperation blockOperationWithBlock:^(ASDKAsyncBlockOperation *operation) {
        __strong typeof(self) strongSelf = weakSelf;
        
        [strongSelf.taskCacheService fetchTaskCommentListForTaskWithID:taskID
                                                   withCompletionBlock:^(NSArray *commentList, NSError *error, ASDKModelPaging *paging) {
                                                       if (operation.isCancelled) {
                                                           [operation complete];
                                                           return;
                                                       }
                                                       
                                                       if (!error) {
                                                           ASDKLogVerbose(@"Task comment list successfully fetched from cache for taskID: %@.", taskID);
                                                           
                                                           ASDKDataAccessorResponseCollection *response =
                                                           [[ASDKDataAccessorResponseCollection alloc] initWithCollection:commentList
                                                                                                                   paging:paging
                                                                                                             isCachedData:YES
                                                                                                                    error:error];
                                                           
                                                           if (weakSelf.delegate) {
                                                               [weakSelf.delegate dataAccessor:weakSelf
                                                                           didLoadDataResponse:response];
                                                           }
                                                       } else {
                                                           ASDKLogError(@"An error occured while fetching cached task comments. Reason: %@", error.localizedDescription);
                                                       }
                                                       
                                                       [operation complete];
                                                   }];
    }];
    
    return cachedTaskContentListOperation;
}

- (ASDKAsyncBlockOperation *)taskCommentListStoreInCacheOperationForTaskID:(NSString *)taskID {
    __weak typeof(self) weakSelf = self;
    ASDKAsyncBlockOperation *storeInCacheOperation = [ASDKAsyncBlockOperation blockOperationWithBlock:^(ASDKAsyncBlockOperation *operation) {
        __strong typeof(self) strongSelf = weakSelf;
        ASDKAsyncBlockOperation *dependencyOperation = (ASDKAsyncBlockOperation *)operation.dependencies.firstObject;
        ASDKDataAccessorResponseCollection *remoteResponse = dependencyOperation.result;
        
        if (remoteResponse.collection) {
            [strongSelf.taskCacheService cacheTaskCommentList:remoteResponse.collection
                                                forTaskWithID:taskID
                                          withCompletionBlock:^(NSError *error) {
                                              if (operation.isCancelled) {
                                                  [operation complete];
                                                  return;
                                              }
                                              
                                              if (!error) {
                                                  ASDKLogVerbose(@"Task comment list successfully cached for taskID: %@", taskID);
                                                  
                                                  [weakSelf.taskCacheService saveChanges];
                                              } else {
                                                  ASDKLogError(@"Encountered an error while caching the task comment list for taskID: %@. Reason:%@", taskID, error.localizedDescription);
                                              }
                                              
                                              [operation complete];
                                          }];
        }
    }];
    
    return storeInCacheOperation;
}


#pragma mark -
#pragma mark Service - Task checklist list

- (void)fetchTaskCheckListForTaskID:(NSString *)taskID {
    // Define operations
    ASDKAsyncBlockOperation *remoteTaskChecklistOperation = [self remoteTaskChecklistOperationForTaskID:taskID];
    ASDKAsyncBlockOperation *cachedTaskChecklistOperation = [self cachedTaskChecklistOperationForTaskID:taskID];
    ASDKAsyncBlockOperation *storeInCacheTaskChecklistOperation = [self taskChecklistStoreInCacheOperationForTaskID:taskID];
    ASDKAsyncBlockOperation *completionOperation = [self defaultCompletionOperation];
    
    // Handle cache policies
    switch (self.cachePolicy) {
        case ASDKServiceDataAccessorCachingPolicyCacheOnly: {
            [completionOperation addDependency:cachedTaskChecklistOperation];
            [self.processingQueue addOperations:@[cachedTaskChecklistOperation,
                                                  completionOperation]
                              waitUntilFinished:NO];
        }
            break;
            
        case ASDKServiceDataAccessorCachingPolicyAPIOnly: {
            [completionOperation addDependency:remoteTaskChecklistOperation];
            [self.processingQueue addOperations:@[remoteTaskChecklistOperation,
                                                  completionOperation]
                              waitUntilFinished:NO];
        }
            break;
            
        case ASDKServiceDataAccessorCachingPolicyHybrid: {
            [remoteTaskChecklistOperation addDependency:cachedTaskChecklistOperation];
            [storeInCacheTaskChecklistOperation addDependency:remoteTaskChecklistOperation];
            [completionOperation addDependency:storeInCacheTaskChecklistOperation];
            [self.processingQueue addOperations:@[cachedTaskChecklistOperation,
                                                  remoteTaskChecklistOperation,
                                                  storeInCacheTaskChecklistOperation,
                                                  completionOperation]
                              waitUntilFinished:NO];
        }
            break;
            
        default: break;
    }
    
}

- (ASDKAsyncBlockOperation *)remoteTaskChecklistOperationForTaskID:(NSString *)taskID {
    if ([self.delegate respondsToSelector:@selector(dataAccessorDidStartFetchingRemoteData:)]) {
        [self.delegate dataAccessorDidStartFetchingRemoteData:self];
    }
    
    __weak typeof(self) weakSelf = self;
    ASDKAsyncBlockOperation *remoteTaskListOperation = [ASDKAsyncBlockOperation blockOperationWithBlock:^(ASDKAsyncBlockOperation *operation) {
        __strong typeof(self) strongSelf = weakSelf;
        
        [strongSelf.taskNetworkService fetchChecklistForTaskWithID:taskID
                                                   completionBlock:^(NSArray *taskList, NSError *error, ASDKModelPaging *paging) {
                                                       if (operation.isCancelled) {
                                                           [operation complete];
                                                           return;
                                                       }
                                                       
                                                       ASDKDataAccessorResponseCollection *responseCollection =
                                                       [[ASDKDataAccessorResponseCollection alloc] initWithCollection:taskList
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
    
    return remoteTaskListOperation;
}

- (ASDKAsyncBlockOperation *)cachedTaskChecklistOperationForTaskID:(NSString *)taskID {
    __weak typeof(self) weakSelf = self;
    ASDKAsyncBlockOperation *cachedTaskChecklistOperation = [ASDKAsyncBlockOperation blockOperationWithBlock:^(ASDKAsyncBlockOperation *operation) {
        __strong typeof(self) strongSelf = weakSelf;
        
        [strongSelf.taskCacheService fetchTaskCheckListForTaskWithID:taskID
                                                 withCompletionBlock:^(NSArray *taskList, NSError *error, ASDKModelPaging *paging) {
                                                     if (operation.isCancelled) {
                                                         [operation complete];
                                                         return;
                                                     }
                                                     
                                                     if (!error) {
                                                         ASDKLogVerbose(@"Task checklist successfully fetched from cache for taskID:%@", taskID);
                                                         
                                                         ASDKDataAccessorResponseCollection *response =
                                                         [[ASDKDataAccessorResponseCollection alloc] initWithCollection:taskList
                                                                                                                 paging:paging
                                                                                                           isCachedData:YES
                                                                                                                  error:error];
                                                         
                                                         if (weakSelf.delegate) {
                                                             [weakSelf.delegate dataAccessor:weakSelf
                                                                         didLoadDataResponse:response];
                                                         }
                                                     } else {
                                                         ASDKLogError(@"An error occured while fetching the task checklist for taskID:%@. Reason: %@", taskID, error.localizedDescription);
                                                     }
                                                     
                                                     [operation complete];
                                                 }];
    }];
    
    return cachedTaskChecklistOperation;
}

- (ASDKAsyncBlockOperation *)taskChecklistStoreInCacheOperationForTaskID:(NSString *)taskID {
    __weak typeof(self) weakSelf = self;
    ASDKAsyncBlockOperation *storeInCacheOperation = [ASDKAsyncBlockOperation blockOperationWithBlock:^(ASDKAsyncBlockOperation *operation) {
        __strong typeof(self) strongSelf = weakSelf;
        ASDKAsyncBlockOperation *dependencyOperation = (ASDKAsyncBlockOperation *)operation.dependencies.firstObject;
        ASDKDataAccessorResponseCollection *remoteResponse = dependencyOperation.result;
        
        if (remoteResponse.collection) {
            [strongSelf.taskCacheService cacheTaskChecklist:remoteResponse.collection
                                              forTaskWithID:taskID
                                        withCompletionBlock:^(NSError *error) {
                                            if (operation.isCancelled) {
                                                [operation complete];
                                                return;
                                            }
                                            
                                            if (!error) {
                                                ASDKLogVerbose(@"Task checklist successfully cached for taskID: %@", taskID);
                                                
                                                [weakSelf.taskCacheService saveChanges];
                                            } else {
                                                ASDKLogError(@"Encountered an error while caching the task checklist for taskID: %@. Reason: %@", taskID, error.localizedDescription);
                                            }
                                            
                                            [operation complete];
                                        }];
        }
    }];
    
    return storeInCacheOperation;
}


#pragma mark -
#pragma mark Service - Update task details

- (void)updateTaskWithID:(NSString *)taskID
      withRepresentation:(ASDKTaskUpdateRequestRepresentation *)taskUpdateRepresentation {
    NSParameterAssert(taskID);
    
    if ([self.delegate respondsToSelector:@selector(dataAccessorDidStartFetchingRemoteData:)]) {
        [self.delegate dataAccessorDidStartFetchingRemoteData:self];
    }
    
    __weak typeof(self) weakSelf = self;
    [self.taskNetworkService updateTaskForTaskID:taskID
                          withTaskRepresentation:taskUpdateRepresentation
                                 completionBlock:^(BOOL isTaskUpdated, NSError *error) {
                                     __strong typeof(self) strongSelf = weakSelf;
                                     
                                     if (strongSelf.delegate) {
                                         ASDKDataAccessorResponseConfirmation *confirmation =
                                         [[ASDKDataAccessorResponseConfirmation alloc] initWithConfirmation:isTaskUpdated
                                                                                               isCachedData:NO
                                                                                                      error:error];
                                         
                                         [strongSelf.delegate dataAccessor:strongSelf
                                                       didLoadDataResponse:confirmation];
                                         [strongSelf.delegate dataAccessorDidFinishedLoadingDataResponse:strongSelf];
                                     }
                                 }];
}


#pragma mark -
#pragma mark Service - Complete task

- (void)completeTaskWithID:(NSString *)taskID {
    NSParameterAssert(taskID);
    
    if ([self.delegate respondsToSelector:@selector(dataAccessorDidStartFetchingRemoteData:)]) {
        [self.delegate dataAccessorDidStartFetchingRemoteData:self];
    }
    
    __weak typeof(self) weakSelf = self;
    [self.taskNetworkService completeTaskForTaskID:taskID
                                   completionBlock:^(BOOL isTaskCompleted, NSError *error) {
                                       __strong typeof(self) strongSelf = weakSelf;
                                       
                                       if (strongSelf.delegate) {
                                           ASDKDataAccessorResponseConfirmation *confirmation =
                                           [[ASDKDataAccessorResponseConfirmation alloc] initWithConfirmation:isTaskCompleted
                                                                                                 isCachedData:NO
                                                                                                        error:error];
                                           
                                           [strongSelf.delegate dataAccessor:strongSelf
                                                         didLoadDataResponse:confirmation];
                                           [strongSelf.delegate dataAccessorDidFinishedLoadingDataResponse:strongSelf];
                                       }
                                   }];
}


#pragma mark -
#pragma mark Service - Upload task content

- (void)uploadContentForTaskWithID:(NSString *)taskID
                       fromFileURL:(NSURL *)fileURL
                   withContentData:(NSData *)contentData {
    NSParameterAssert(taskID);
    NSParameterAssert(fileURL);
    NSParameterAssert(contentData);
    
    if ([self.delegate respondsToSelector:@selector(dataAccessorDidStartFetchingRemoteData:)]) {
        [self.delegate dataAccessorDidStartFetchingRemoteData:self];
    }
    
    ASDKModelFileContent *fileContentModel = [ASDKModelFileContent new];
    fileContentModel.modelFileURL = fileURL;
    
    __weak typeof(self) weakSelf = self;
    [self.taskNetworkService uploadContentWithModel:fileContentModel
                                        contentData:contentData
                                          forTaskID:taskID
                                      progressBlock:^(NSUInteger progress, NSError *error) {
                                          __strong typeof(self) strongSelf = weakSelf;
                                          
                                          ASDKDataAccessorResponseProgress *responseProgress =
                                          [[ASDKDataAccessorResponseProgress alloc] initWithProgress:progress
                                                                                               error:error];
                                          if (strongSelf.delegate) {
                                              [strongSelf.delegate dataAccessor:strongSelf
                                                            didLoadDataResponse:responseProgress];
                                          }
                                      } completionBlock:^(ASDKModelContent *uploadedContent, NSError *error) {
                                          __strong typeof(self) strongSelf = weakSelf;
                                          
                                          ASDKDataAccessorResponseModel *responseModel =
                                          [[ASDKDataAccessorResponseModel alloc] initWithModel:uploadedContent
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
#pragma mark Service - Download task content

- (void)downloadTaskContent:(ASDKModelContent *)content {
    NSParameterAssert(content);
    
    if ([self.delegate respondsToSelector:@selector(dataAccessorDidStartFetchingRemoteData:)]) {
        [self.delegate dataAccessorDidStartFetchingRemoteData:self];
    }
    
    __weak typeof(self) weakSelf = self;
    [self.taskNetworkService downloadContent:content
                          allowCachedResults:(self.cachePolicy == ASDKServiceDataAccessorCachingPolicyAPIOnly) ? NO : YES
                               progressBlock:^(NSString *formattedReceivedBytesString, NSError *error) {
                                   __strong typeof(self) strongSelf = weakSelf;
                                   
                                   [strongSelf handleDownloadProgressResponseWithFormattedBytesString:formattedReceivedBytesString
                                                                                                error:error];
                               } completionBlock:^(NSURL *downloadedContentURL, BOOL isLocalContent, NSError *error) {
                                   __strong typeof(self) strongSelf = weakSelf;
                                   
                                   [strongSelf handleDownloadCompletionAtPath:downloadedContentURL
                                                               isLocalContent:isLocalContent
                                                                        error:error];
                               }];
}


#pragma mark -
#pragma mark Service - Download task content thumbnail

- (void)downloadThumbnailForTaskContent:(ASDKModelContent *)content {
    NSParameterAssert(content);
    
    if ([self.delegate respondsToSelector:@selector(dataAccessorDidStartFetchingRemoteData:)]) {
        [self.delegate dataAccessorDidStartFetchingRemoteData:self];
    }
    
    __weak typeof(self) weakSelf = self;
    [self.taskNetworkService downloadThumbnailForContent:content
                                      allowCachedResults:(self.cachePolicy == ASDKServiceDataAccessorCachingPolicyAPIOnly) ? NO : YES
                                           progressBlock:^(NSString *formattedReceivedBytesString, NSError *error) {
                                               __strong typeof(self) strongSelf = weakSelf;
                                               
                                               [strongSelf handleDownloadProgressResponseWithFormattedBytesString:formattedReceivedBytesString
                                                                                                            error:error];
                                           } completionBlock:^(NSURL *downloadedContentURL, BOOL isLocalContent, NSError *error) {
                                               __strong typeof(self) strongSelf = weakSelf;
                                               
                                               [strongSelf handleDownloadCompletionAtPath:downloadedContentURL
                                                                           isLocalContent:isLocalContent
                                                                                    error:error];
                                           }];
}


#pragma mark -
#pragma mark Service - Delete task content

- (void)deleteContent:(ASDKModelContent *)content {
    NSParameterAssert(content);
    
    if ([self.delegate respondsToSelector:@selector(dataAccessorDidStartFetchingRemoteData:)]) {
        [self.delegate dataAccessorDidStartFetchingRemoteData:self];
    }
    
    __weak typeof(self) weakSelf = self;
    [self.taskNetworkService deleteContent:content
                           completionBlock:^(BOOL isContentDeleted, NSError *error) {
                               __strong typeof(self) strongSelf = weakSelf;
                               
                               ASDKDataAccessorResponseConfirmation *confirmationResponse =
                               [[ASDKDataAccessorResponseConfirmation alloc] initWithConfirmation:isContentDeleted
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
#pragma mark Service - Involve user with task

- (void)involveUser:(ASDKModelUser *)user
       inTaskWithID:(NSString *)taskID {
    NSParameterAssert(user);
    NSParameterAssert(taskID);
    
    if ([self.delegate respondsToSelector:@selector(dataAccessorDidStartFetchingRemoteData:)]) {
        [self.delegate dataAccessorDidStartFetchingRemoteData:self];
    }
    
    __weak typeof(self) weakSelf = self;
    if ([self isLoggedInOnCloud]) {
        [self.taskNetworkService involveUserWithEmailAddress:user.email
                                                   forTaskID:taskID
                                             completionBlock:^(BOOL isUserInvolved, NSError *error) {
                                                 __strong typeof(self) strongSelf = weakSelf;
                                                 
                                                 [strongSelf handleUserInvolvement:isUserInvolved
                                                                             error:error];
                                             }];
    } else {
        [self.taskNetworkService involveUserWithID:user.modelID
                                         forTaskID:taskID
                                   completionBlock:^(BOOL isUserInvolved, NSError *error) {
                                       __strong typeof(self) strongSelf = weakSelf;
                                       
                                       [strongSelf handleUserInvolvement:isUserInvolved
                                                                   error:error];
                                   }];
    }
}


#pragma mark -
#pragma mark Service - Remove involved user from task

- (void)removeInvolvedUser:(ASDKModelUser *)user
            fromTaskWithID:(NSString *)taskID {
    NSParameterAssert(user);
    NSParameterAssert(taskID);
    
    if ([self.delegate respondsToSelector:@selector(dataAccessorDidStartFetchingRemoteData:)]) {
        [self.delegate dataAccessorDidStartFetchingRemoteData:self];
    }
    
    __weak typeof(self) weakSelf = self;
    if ([self isLoggedInOnCloud]) {
        [self.taskNetworkService removeInvolvedUserWithEmailAddress:user.email
                                                          forTaskID:taskID
                                                    completionBlock:^(BOOL isUserInvolved, NSError *error) {
                                                        __strong typeof(self) strongSelf = weakSelf;
                                                        
                                                        [strongSelf handleUserInvolvement:isUserInvolved
                                                                                    error:error];
                                                    }];
    } else {
        [self.taskNetworkService removeInvolvedUserWithID:user.modelID
                                                forTaskID:taskID
                                          completionBlock:^(BOOL isUserInvolved, NSError *error) {
                                              __strong typeof(self) strongSelf = weakSelf;
                                              
                                              [strongSelf handleUserInvolvement:isUserInvolved
                                                                          error:error];
                                          }];
    }
}

#pragma mark -
#pragma mark Service - Create task comment

- (void)createComment:(NSString *)comment
        forTaskWithID:(NSString *)taskID {
    NSParameterAssert(comment);
    NSParameterAssert(taskID);
    
    if ([self.delegate respondsToSelector:@selector(dataAccessorDidStartFetchingRemoteData:)]) {
        [self.delegate dataAccessorDidStartFetchingRemoteData:self];
    }
    
    __weak typeof(self) weakSelf = self;
    [self.taskNetworkService createComment:comment
                                 forTaskID:taskID
                           completionBlock:^(ASDKModelComment *comment, NSError *error) {
                               __strong typeof(self) strongSelf = weakSelf;
                               
                               ASDKDataAccessorResponseModel *response =
                               [[ASDKDataAccessorResponseModel alloc] initWithModel:comment
                                                                       isCachedData:NO
                                                                              error:error];
                               if (weakSelf.delegate) {
                                   [weakSelf.delegate dataAccessor:weakSelf
                                               didLoadDataResponse:response];
                                   
                                   [strongSelf.delegate dataAccessorDidFinishedLoadingDataResponse:strongSelf];
                               }
                           }];
}


#pragma mark -
#pragma mark Service - Create task

- (void)createTaskWithRepresentation:(ASDKTaskCreationRequestRepresentation *)taskRepresentation {
    NSParameterAssert(taskRepresentation);
    
    if ([self.delegate respondsToSelector:@selector(dataAccessorDidStartFetchingRemoteData:)]) {
        [self.delegate dataAccessorDidStartFetchingRemoteData:self];
    }
    
    __weak typeof(self) weakSelf = self;
    [self.taskNetworkService createTaskWithRepresentation:taskRepresentation
                                          completionBlock:^(ASDKModelTask *task, NSError *error) {
                                              __strong typeof(self) strongSelf = weakSelf;
                                              
                                              ASDKDataAccessorResponseModel *response =
                                              [[ASDKDataAccessorResponseModel alloc] initWithModel:task
                                                                                      isCachedData:NO
                                                                                             error:error];
                                              if (weakSelf.delegate) {
                                                  [weakSelf.delegate dataAccessor:weakSelf
                                                              didLoadDataResponse:response];
                                                  
                                                  [strongSelf.delegate dataAccessorDidFinishedLoadingDataResponse:strongSelf];
                                              }
                                          }];
}


#pragma mark -
#pragma Service - Claim task

- (void)claimTaskWithID:(NSString *)taskID {
    NSParameterAssert(taskID);
    
    if ([self.delegate respondsToSelector:@selector(dataAccessorDidStartFetchingRemoteData:)]) {
        [self.delegate dataAccessorDidStartFetchingRemoteData:self];
    }
    
    __weak typeof(self) weakSelf = self;
    [self.taskNetworkService claimTaskWithID:taskID
                             completionBlock:^(BOOL isTaskClaimed, NSError *error) {
                                 __strong typeof(self) strongSelf = weakSelf;
                                 
                                 [strongSelf handleTaskClaiming:isTaskClaimed
                                                          error:error];
                             }];
}


#pragma mark -
#pragma mark Service - Unclaim task

- (void)unclaimTaskWithID:(NSString *)taskID {
    NSParameterAssert(taskID);
    NSParameterAssert(taskID);
    
    if ([self.delegate respondsToSelector:@selector(dataAccessorDidStartFetchingRemoteData:)]) {
        [self.delegate dataAccessorDidStartFetchingRemoteData:self];
    }
    
    __weak typeof(self) weakSelf = self;
    [self.taskNetworkService unclaimTaskWithID:taskID
                               completionBlock:^(BOOL isTaskClaimed, NSError *error) {
                                   __strong typeof(self) strongSelf = weakSelf;
                                   
                                   [strongSelf handleTaskClaiming:isTaskClaimed
                                                            error:error];
                               }];
}


#pragma mark -
#pragma mark Service - Assign task

- (void)assignTaskWithID:(NSString *)taskID
                  toUser:(ASDKModelUser *)user {
    NSParameterAssert(taskID);
    NSParameterAssert(user);
    
    if ([self.delegate respondsToSelector:@selector(dataAccessorDidStartFetchingRemoteData:)]) {
        [self.delegate dataAccessorDidStartFetchingRemoteData:self];
    }
    
    __weak typeof(self) weakSelf = self;
    [self.taskNetworkService assignTaskWithID:taskID
                                       toUser:user
                              completionBlock:^(ASDKModelTask *task, NSError *error) {
                                  __strong typeof(self) strongSelf = weakSelf;
                                  
                                  [strongSelf handleTaskDetails:task
                                                          error:error];
                              }];
}


#pragma mark -
#pragma mark Service - Download task audit log

- (void)downloadAuditLogForTaskWithID:(NSString *)taskID {
    NSParameterAssert(taskID);
    
    if ([self.delegate respondsToSelector:@selector(dataAccessorDidStartFetchingRemoteData:)]) {
        [self.delegate dataAccessorDidStartFetchingRemoteData:self];
    }
    
    __weak typeof(self) weakSelf = self;
    [self.taskNetworkService downloadAuditLogForTaskWithID:taskID
                                        allowCachedResults:(self.cachePolicy == ASDKServiceDataAccessorCachingPolicyAPIOnly) ? NO : YES
                                             progressBlock:^(NSString *formattedReceivedBytesString, NSError *error) {
                                                 __strong typeof(self) strongSelf = weakSelf;
                                                 
                                                 [strongSelf handleDownloadProgressResponseWithFormattedBytesString:formattedReceivedBytesString
                                                                                                              error:error];
                                             } completionBlock:^(NSURL *downloadedContentURL, BOOL isLocalContent, NSError *error) {
                                                 __strong typeof(self) strongSelf = weakSelf;
                                                 
                                                 [strongSelf handleDownloadCompletionAtPath:downloadedContentURL
                                                                             isLocalContent:isLocalContent
                                                                                      error:error];
                                             }];
}



#pragma mark -
#pragma mark Service - Create checklist entry

- (void)createChecklisEntryWithRepresentation:(ASDKTaskCreationRequestRepresentation *)taskRepresentation
                                forTaskWithID:(NSString *)taskID {
    NSParameterAssert(taskRepresentation);
    NSParameterAssert(taskID);
    
    if ([self.delegate respondsToSelector:@selector(dataAccessorDidStartFetchingRemoteData:)]) {
        [self.delegate dataAccessorDidStartFetchingRemoteData:self];
    }
    
    __weak typeof(self) weakSelf = self;
    [self.taskNetworkService createChecklistWithRepresentation:taskRepresentation
                                                        taskID:taskID
                                               completionBlock:^(ASDKModelTask *task, NSError *error) {
                                                   __strong typeof(self) strongSelf = weakSelf;
                                                   
                                                   [strongSelf handleTaskDetails:task
                                                                           error:error];
                                               }];
}


#pragma mark -
#pragma mark Service - Update checklist order

- (void)updateChecklistOrderWithRepresentation:(ASDKTaskChecklistOrderRequestRepresentation *)checklistOrderRepresentation
                                 forTaskWithID:(NSString *)taskID {
    NSParameterAssert(checklistOrderRepresentation);
    NSParameterAssert(taskID);
    
    if ([self.delegate respondsToSelector:@selector(dataAccessorDidStartFetchingRemoteData:)]) {
        [self.delegate dataAccessorDidStartFetchingRemoteData:self];
    }
    
    __weak typeof(self) weakSelf = self;
    [self.taskNetworkService updateChecklistOrderWithRepresentation:checklistOrderRepresentation
                                                             taskID:taskID
                                                    completionBlock:^(BOOL isTaskUpdated, NSError *error) {
                                                        __strong typeof(self) strongSelf = weakSelf;
                                                        
                                                        ASDKDataAccessorResponseConfirmation *confirmationResponse =
                                                        [[ASDKDataAccessorResponseConfirmation alloc] initWithConfirmation:isTaskUpdated
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
#pragma mark Cancel operations

- (void)cancelOperations {
    [super cancelOperations];
    [self.processingQueue cancelAllOperations];
    [self.taskNetworkService cancelAllNetworkOperations];
}


#pragma mark -
#pragma mark Handlers

- (void)handleUserInvolvement:(BOOL)isUserInvolved
                        error:(NSError *)error {
    ASDKDataAccessorResponseConfirmation *confirmationResponse =
    [[ASDKDataAccessorResponseConfirmation alloc] initWithConfirmation:isUserInvolved
                                                          isCachedData:NO
                                                                 error:error];
    if (self.delegate) {
        [self.delegate dataAccessor:self
                didLoadDataResponse:confirmationResponse];
        
        [self.delegate dataAccessorDidFinishedLoadingDataResponse:self];
    }
}

- (void)handleTaskClaiming:(BOOL)isTaskClaimed
                     error:(NSError *)error {
    ASDKDataAccessorResponseConfirmation *confirmationResponse =
    [[ASDKDataAccessorResponseConfirmation alloc] initWithConfirmation:isTaskClaimed
                                                          isCachedData:NO
                                                                 error:error];
    if (self.delegate) {
        [self.delegate dataAccessor:self
                didLoadDataResponse:confirmationResponse];
        
        [self.delegate dataAccessorDidFinishedLoadingDataResponse:self];
    }
}

- (void)handleDownloadProgressResponseWithFormattedBytesString:(NSString *)formattedReceivedBytesString
                                                         error:(NSError *)error {
    ASDKDataAccessorResponseProgress *responseProgress =
    [[ASDKDataAccessorResponseProgress alloc] initWithFormattedProgressString:formattedReceivedBytesString
                                                                        error:error];
    if (self.delegate) {
        [self.delegate dataAccessor:self
                didLoadDataResponse:responseProgress];
    }
}

- (void)handleDownloadCompletionAtPath:(NSURL *)downloadedContentURL
                        isLocalContent:(BOOL)isLocalContent
                                 error:(NSError *)error {
    ASDKDataAccessorResponseModel *responseModel =
    [[ASDKDataAccessorResponseModel alloc] initWithModel:downloadedContentURL
                                            isCachedData:isLocalContent
                                                   error:error];
    if (self.delegate) {
        [self.delegate dataAccessor:self
                didLoadDataResponse:responseModel];
        
        [self.delegate dataAccessorDidFinishedLoadingDataResponse:self];
    }
}

- (void)handleTaskDetails:(ASDKModelTask *)task
                    error:(NSError *)error {
    ASDKDataAccessorResponseModel *response =
    [[ASDKDataAccessorResponseModel alloc] initWithModel:task
                                            isCachedData:NO
                                                   error:error];
    if (self.delegate) {
        [self.delegate dataAccessor:self
                didLoadDataResponse:response];
    }
}


#pragma mark -
#pragma mark Private interface

- (ASDKTaskNetworkServices *)taskNetworkService {
    return (ASDKTaskNetworkServices *)self.networkService;
}

- (ASDKTaskCacheService *)taskCacheService {
    return (ASDKTaskCacheService *)self.cacheService;
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

- (BOOL)isLoggedInOnCloud {
    ASDKBootstrap *sdkBootstrap = [ASDKBootstrap sharedInstance];
    NSString *cloudHostname = [self.taskNetworkService.servicePathFactory cloudHostnamePath];
    return [sdkBootstrap.serverConfiguration.hostAddressString isEqualToString:cloudHostname];
}

@end

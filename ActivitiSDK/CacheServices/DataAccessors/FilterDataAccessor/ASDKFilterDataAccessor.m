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

#import "ASDKFilterDataAccessor.h"

// Constants
#import "ASDKLogConfiguration.h"
#import "ASDKLocalizationConstants.h"

// Managers
#import "ASDKBootstrap.h"
#import "ASDKFilterNetworkServices.h"
#import "ASDKFilterCacheService.h"
#import "ASDKServiceLocator.h"

// Operations
#import "ASDKAsyncBlockOperation.h"

// Models
#import "ASDKDataAccessorResponseCollection.h"
#import "ASDKFilterListRequestRepresentation.h"

static const int activitiSDKLogLevel = ASDK_LOG_LEVEL_VERBOSE; // | ASDK_LOG_FLAG_TRACE;

@interface ASDKFilterDataAccessor ()

@property (strong, nonatomic) NSOperationQueue *processingQueue;

@end

@implementation ASDKFilterDataAccessor

- (instancetype)initWithDelegate:(id<ASDKDataAccessorDelegate>)delegate {
    self = [super initWithDelegate:delegate];
    
    if (self) {
        _processingQueue = [self serialOperationQueue];
        _cachePolicy = ASDKServiceDataAccessorCachingPolicyHybrid;
        dispatch_queue_t profileUpdatesProcessingQueue = dispatch_queue_create([[NSString stringWithFormat:@"%@.`%@ProcessingQueue",
                                                                                 [NSBundle bundleForClass:[self class]].bundleIdentifier,
                                                                                 NSStringFromClass([self class])] UTF8String],
                                                                               DISPATCH_QUEUE_SERIAL);
        
        // Acquire and set up the app network service
        ASDKBootstrap *sdkBootstrap = [ASDKBootstrap sharedInstance];
        _networkService = (ASDKFilterNetworkServices *)[sdkBootstrap.serviceLocator serviceConformingToProtocol:@protocol(ASDKFilterNetworkServiceProtocol)];
        _networkService.resultsQueue = profileUpdatesProcessingQueue;
        _cacheService = [ASDKFilterCacheService new];
    }
    
    return self;
}


#pragma mark -
#pragma mark Service - Default task filter list

- (void)fetchDefaultTaskFilterList {
    // Define operations
    ASDKAsyncBlockOperation *remoteDefaultTaskFilterListOperation = [self remoteDefaultTaskFilterList];
    ASDKAsyncBlockOperation *cachedDefaultTaskFilterListOperation = [self cachedDefaultTaskFilterList];
    ASDKAsyncBlockOperation *storeInCacheDefaultTaskFilterListOperation = [self defaultTaskFilterListStoreInCacheOperation];
    ASDKAsyncBlockOperation *completionOperation = [self defaultCompletionOperation];
    
    // Handle cache policies
    switch (self.cachePolicy) {
        case ASDKServiceDataAccessorCachingPolicyCacheOnly: {
            [completionOperation addDependency:cachedDefaultTaskFilterListOperation];
            [self.processingQueue addOperations:@[cachedDefaultTaskFilterListOperation,
                                                  completionOperation]
                              waitUntilFinished:NO];
        }
            break;
            
        case ASDKServiceDataAccessorCachingPolicyAPIOnly: {
            [completionOperation addDependency:remoteDefaultTaskFilterListOperation];
            [self.processingQueue addOperations:@[remoteDefaultTaskFilterListOperation,
                                                  completionOperation]
                              waitUntilFinished:NO];
        }
            break;
            
        case ASDKServiceDataAccessorCachingPolicyHybrid: {
            [remoteDefaultTaskFilterListOperation addDependency:cachedDefaultTaskFilterListOperation];
            [storeInCacheDefaultTaskFilterListOperation addDependency:remoteDefaultTaskFilterListOperation];
            [completionOperation addDependency:storeInCacheDefaultTaskFilterListOperation];
            [self.processingQueue addOperations:@[cachedDefaultTaskFilterListOperation,
                                                  remoteDefaultTaskFilterListOperation,
                                                  storeInCacheDefaultTaskFilterListOperation,
                                                  completionOperation]
                              waitUntilFinished:NO];
        }
            break;
            
        default: break;
    }
}

- (ASDKAsyncBlockOperation *)remoteDefaultTaskFilterList {
    if ([self.delegate respondsToSelector:@selector(dataAccessorDidStartFetchingRemoteData:)]) {
        [self.delegate dataAccessorDidStartFetchingRemoteData:self];
    }
    
    __weak typeof(self) weakSelf = self;
    ASDKAsyncBlockOperation *remoteFilterListOperation = [ASDKAsyncBlockOperation blockOperationWithBlock:^(ASDKAsyncBlockOperation *operation) {
        __strong typeof(self) strongSelf = weakSelf;
        
        [strongSelf.filterNetworkService fetchTaskFilterListWithCompletionBlock:^(NSArray *filterList, NSError *error, ASDKModelPaging *paging) {
            if (operation.isCancelled) {
                [operation complete];
                return;
            }
            
            ASDKDataAccessorResponseCollection *responseCollection = [[ASDKDataAccessorResponseCollection alloc] initWithCollection:filterList
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
    
    return remoteFilterListOperation;
}

- (ASDKAsyncBlockOperation *)cachedDefaultTaskFilterList {
    __weak typeof(self) weakSelf = self;
    ASDKAsyncBlockOperation *cachedTaskFilterListOperation = [ASDKAsyncBlockOperation blockOperationWithBlock:^(ASDKAsyncBlockOperation * operation) {
        __strong typeof(self) strongSelf = weakSelf;
        
        [strongSelf.filterCacheService fetchDefaultTaskFilterList:^(NSArray *filterList, NSError *error, ASDKModelPaging *paging) {
            if (operation.isCancelled) {
                [operation complete];
                return;
            }
            
            if (!error) {
                ASDKLogVerbose(@"Default task filter list fetched successfully from cache.");
                
                ASDKDataAccessorResponseCollection *response = [[ASDKDataAccessorResponseCollection alloc] initWithCollection:filterList
                                                                                                                       paging:paging
                                                                                                                 isCachedData:YES
                                                                                                                        error:error];
                
                if (weakSelf.delegate) {
                    [weakSelf.delegate dataAccessor:weakSelf
                                didLoadDataResponse:response];
                }
            } else {
                ASDKLogError(@"An error occured while fetching cached default task filter list. Reason: %@", error.localizedDescription);
            }
            
            [operation complete];
        }];
    }];
    
    return cachedTaskFilterListOperation;
}

- (ASDKAsyncBlockOperation *)defaultTaskFilterListStoreInCacheOperation {
    __weak typeof(self) weakSelf = self;
    ASDKAsyncBlockOperation *storeInCacheOperation = [ASDKAsyncBlockOperation blockOperationWithBlock:^(ASDKAsyncBlockOperation *operation) {
        __strong typeof(self) strongSelf = weakSelf;
        
        ASDKAsyncBlockOperation *dependencyOperation = (ASDKAsyncBlockOperation *)operation.dependencies.firstObject;
        ASDKDataAccessorResponseCollection *remoteResponse = dependencyOperation.result;
        
        if (remoteResponse.collection) {
            [strongSelf.filterCacheService cacheDefaultTaskFilterList:remoteResponse.collection
                                                  withCompletionBlock:^(NSError *error) {
                                                      if (operation.isCancelled) {
                                                          [operation complete];
                                                          return;
                                                      }
                                                      
                                                      if (!error) {
                                                          [weakSelf.filterCacheService saveChanges];
                                                      } else {
                                                          ASDKLogError(@"Encountered an error while caching the default task filter list. Reason:%@", error.localizedDescription);
                                                      }
                                                      
                                                      [operation complete];
                                                  }];
        }
    }];
    
    return storeInCacheOperation;
}


#pragma mark -
#pragma mark Service - Application specific task filter list

- (void)fetchTaskFilterListForApplicationID:(NSString *)appID {
    ASDKFilterListRequestRepresentation *filterListRequestRepresentation = [ASDKFilterListRequestRepresentation new];
    filterListRequestRepresentation.jsonAdapterType = ASDKRequestRepresentationJSONAdapterTypeExcludeNilValues;
    filterListRequestRepresentation.appID = appID;
    
    // Define operations
    ASDKAsyncBlockOperation *remoteTaskFilterListOperation = [self remoteTaskFilterListForFilter:filterListRequestRepresentation];
    ASDKAsyncBlockOperation *cachedTaskFilterListOperation = [self cachedTaskFilterListForFilter:filterListRequestRepresentation];
    ASDKAsyncBlockOperation *storeInCacheTaskFilterListOperation = [self taskFilterListStoreInCacheOperationForFilter:filterListRequestRepresentation];
    ASDKAsyncBlockOperation *completionOperation = [self defaultCompletionOperation];
    
    // Handle cache policies
    switch (self.cachePolicy) {
        case ASDKServiceDataAccessorCachingPolicyCacheOnly: {
            [completionOperation addDependency:cachedTaskFilterListOperation];
            [self.processingQueue addOperations:@[cachedTaskFilterListOperation,
                                                  completionOperation]
                              waitUntilFinished:NO];
        }
            break;
            
        case ASDKServiceDataAccessorCachingPolicyAPIOnly: {
            [completionOperation addDependency:remoteTaskFilterListOperation];
            [self.processingQueue addOperations:@[remoteTaskFilterListOperation,
                                                  completionOperation]
                              waitUntilFinished:NO];
        }
            break;
            
        case ASDKServiceDataAccessorCachingPolicyHybrid: {
            [remoteTaskFilterListOperation addDependency:cachedTaskFilterListOperation];
            [storeInCacheTaskFilterListOperation addDependency:remoteTaskFilterListOperation];
            [completionOperation addDependency:storeInCacheTaskFilterListOperation];
            [self.processingQueue addOperations:@[cachedTaskFilterListOperation,
                                                  remoteTaskFilterListOperation,
                                                  storeInCacheTaskFilterListOperation,
                                                  completionOperation]
                              waitUntilFinished:NO];
        }
            break;
            
        default: break;
    }
}

- (void)createDefaultTaskFilterListForApplicationID:(NSString *)appID {
    // Define operations
    ASDKAsyncBlockOperation *createInvolvedTasksFilterOperation = [self createInvolvedTasksFilterForApplicationID:appID];
    ASDKAsyncBlockOperation *createMyTasksFilterOperation = [self createMyTasksFilterForApplicationID:appID];
    ASDKAsyncBlockOperation *createQueuedTasksFilterOperation = [self createQueuedTasksFilterForApplicationID:appID];
    ASDKAsyncBlockOperation *createCompletedTasksFilterOperation = [self createCompletedTasksFilterForApplicationID:appID];
    ASDKAsyncBlockOperation *refetchTaskFilterListOperation = [self refetchTaskFilterListForApplicationID:appID];
    
    [createMyTasksFilterOperation addDependency:createInvolvedTasksFilterOperation];
    [createQueuedTasksFilterOperation addDependency:createMyTasksFilterOperation];
    [createCompletedTasksFilterOperation addDependency:createQueuedTasksFilterOperation];
    [refetchTaskFilterListOperation addDependency:createCompletedTasksFilterOperation];
    [self.processingQueue addOperations:@[createInvolvedTasksFilterOperation,
                                          createMyTasksFilterOperation,
                                          createQueuedTasksFilterOperation,
                                          createCompletedTasksFilterOperation,
                                          refetchTaskFilterListOperation]
                      waitUntilFinished:NO];
    
}

- (ASDKAsyncBlockOperation *)remoteTaskFilterListForFilter:(ASDKFilterListRequestRepresentation *)filter {
    if ([self.delegate respondsToSelector:@selector(dataAccessorDidStartFetchingRemoteData:)]) {
        [self.delegate dataAccessorDidStartFetchingRemoteData:self];
    }
    
    __weak typeof(self) weakSelf = self;
    ASDKAsyncBlockOperation *remoteFilterListOperation = [ASDKAsyncBlockOperation blockOperationWithBlock:^(ASDKAsyncBlockOperation *operation) {
        __strong typeof(self) strongSelf = weakSelf;
        
        [strongSelf.filterNetworkService fetchTaskFilterListWithFilter:filter
                                                   withCompletionBlock:^(NSArray *filterList, NSError *error, ASDKModelPaging *paging) {
                                                       if (operation.isCancelled) {
                                                           [operation complete];
                                                           return;
                                                       }
                                                       
                                                       if (!error && !filterList.count) {
                                                           ASDKLogVerbose(@"There are no filters defined. Will populate with default ones...");
                                                           
                                                           // Generate default filter operations and define additional dependency rules
                                                           [weakSelf createDefaultTaskFilterListForApplicationID:filter.appID];
                                                       } else {
                                                           ASDKDataAccessorResponseCollection *responseCollection =
                                                           [[ASDKDataAccessorResponseCollection alloc] initWithCollection:filterList
                                                                                                                   paging:paging
                                                                                                             isCachedData:NO
                                                                                                                    error:error];
                                                           
                                                           if (weakSelf.delegate) {
                                                               [weakSelf.delegate dataAccessor:weakSelf
                                                                           didLoadDataResponse:responseCollection];
                                                           }
                                                           
                                                           operation.result = responseCollection;
                                                       }
                                                       
                                                       [operation complete];
                                                   }];
    }];
    
    return remoteFilterListOperation;
}

- (ASDKAsyncBlockOperation *)cachedTaskFilterListForFilter:(ASDKFilterListRequestRepresentation *)filter {
    __weak typeof(self) weakSelf = self;
    ASDKAsyncBlockOperation *cachedTaskFilterListOperation = [ASDKAsyncBlockOperation blockOperationWithBlock:^(ASDKAsyncBlockOperation * operation) {
        __strong typeof(self) strongSelf = weakSelf;
        
        [strongSelf.filterCacheService fetchTaskFilterList:^(NSArray *filterList, NSError *error, ASDKModelPaging *paging) {
            if (operation.isCancelled) {
                [operation complete];
                return;
            }
            
            if (!error) {
                ASDKLogVerbose(@"Task filter list information fetched successfully from cache for appID:%@.", filter.appID);
                
                ASDKDataAccessorResponseCollection *response = [[ASDKDataAccessorResponseCollection alloc] initWithCollection:filterList
                                                                                                                       paging:paging
                                                                                                                 isCachedData:YES
                                                                                                                        error:error];
                
                if (weakSelf.delegate) {
                    [weakSelf.delegate dataAccessor:weakSelf
                                didLoadDataResponse:response];
                }
            } else {
                ASDKLogError(@"An error occured while fetching cached task filter list information for appID:%@. Reason: %@", filter.appID, error.localizedDescription);
            }
            
            [operation complete];
        } usingFilter:filter];
    }];
    
    return cachedTaskFilterListOperation;
}

- (ASDKAsyncBlockOperation *)taskFilterListStoreInCacheOperationForFilter:(ASDKFilterListRequestRepresentation *)filter {
    __weak typeof(self) weakSelf = self;
    ASDKAsyncBlockOperation *storeInCacheOperation = [ASDKAsyncBlockOperation blockOperationWithBlock:^(ASDKAsyncBlockOperation *operation) {
        __strong typeof(self) strongSelf = weakSelf;
        
        ASDKAsyncBlockOperation *dependencyOperation = (ASDKAsyncBlockOperation *)operation.dependencies.firstObject;
        ASDKDataAccessorResponseCollection *remoteResponse = dependencyOperation.result;
        
        if (remoteResponse.collection) {
            [strongSelf.filterCacheService cacheTaskFilterList:remoteResponse.collection
                                                   usingFilter:filter
                                           withCompletionBlock:^(NSError *error) {
                                               if (operation.isCancelled) {
                                                   [operation complete];
                                                   return;
                                               }
                                               
                                               if (!error) {
                                                   [weakSelf.filterCacheService saveChanges];
                                               } else {
                                                   ASDKLogError(@"Encountered an error while caching the task filter list for appID:%@. Reason:%@",  filter.appID, error.localizedDescription);
                                               }
                                               
                                               [operation complete];
                                           }];
        }
    }];
    
    return storeInCacheOperation;
}

- (ASDKAsyncBlockOperation *)createInvolvedTasksFilterForApplicationID:(NSString *)appID {
    __weak typeof(self) weakSelf = self;
    ASDKAsyncBlockOperation *createFilterOperation = [ASDKAsyncBlockOperation blockOperationWithBlock:^(ASDKAsyncBlockOperation *operation) {
        __strong typeof(self) strongSelf = weakSelf;
        
        ASDKFilterCreationRequestRepresentation *involvedTasksFilter = [ASDKFilterCreationRequestRepresentation new];
        involvedTasksFilter.jsonAdapterType = ASDKRequestRepresentationJSONAdapterTypeExcludeNilValues;
        involvedTasksFilter.appID = appID;
        involvedTasksFilter.icon = kASDKAPIIconNameInvolved;
        involvedTasksFilter.index = 0;
        involvedTasksFilter.name = ASDKLocalizedStringFromTable(kLocalizationDefaultFilterInvolvedTasksText, ASDKLocalizationTable, @"Involved tasks text");
        
        ASDKModelFilter *involvedFilter = [ASDKModelFilter new];
        involvedFilter.jsonAdapterType = ASDKRequestRepresentationJSONAdapterTypeExcludeNilValues;
        involvedFilter.assignmentType = ASDKTaskAssignmentTypeInvolved;
        involvedFilter.sortType = ASDKModelFilterSortTypeCreatedDesc;
        involvedFilter.state = ASDKModelFilterStateTypeActive;
        
        involvedTasksFilter.filter = involvedFilter;
        
        [strongSelf.filterNetworkService createUserTaskFilterWithRepresentation:involvedTasksFilter
                                                            withCompletionBlock:^(ASDKModelFilter *filter, NSError *error) {
                                                                if (!error && filter) {
                                                                    ASDKLogVerbose(@"Created default filter:%@", filter.name);
                                                                } else {
                                                                    ASDKLogError(@"An error occured while trying to create the default filter:%@.\nReason:%@", involvedTasksFilter.name, error.localizedDescription);
                                                                }
                                                                
                                                                [operation complete];
                                                            }];
    }];
    
    return createFilterOperation;
}

- (ASDKAsyncBlockOperation *)createMyTasksFilterForApplicationID:(NSString *)appID {
    __weak typeof(self) weakSelf = self;
    ASDKAsyncBlockOperation *createFilterOperation = [ASDKAsyncBlockOperation blockOperationWithBlock:^(ASDKAsyncBlockOperation *operation) {
        __strong typeof(self) strongSelf = weakSelf;
        
        ASDKFilterCreationRequestRepresentation *myTasksFilter = [ASDKFilterCreationRequestRepresentation new];
        myTasksFilter.jsonAdapterType = ASDKRequestRepresentationJSONAdapterTypeExcludeNilValues;
        myTasksFilter.appID = appID;
        myTasksFilter.icon = kASDKAPIIconNameMy;
        myTasksFilter.index = 1;
        myTasksFilter.name = ASDKLocalizedStringFromTable(kLocalizationDefaultFilterInvolvedTasksText, ASDKLocalizationTable, "My tasks text");
        
        ASDKModelFilter *myFilter = [ASDKModelFilter new];
        myFilter.jsonAdapterType = ASDKRequestRepresentationJSONAdapterTypeExcludeNilValues;
        myFilter.assignmentType = ASDKTaskAssignmentTypeAssignee;
        myFilter.sortType = ASDKModelFilterSortTypeCreatedDesc;
        myFilter.state = ASDKModelFilterStateTypeActive;
        
        myTasksFilter.filter = myFilter;
        
        [strongSelf.filterNetworkService createUserTaskFilterWithRepresentation:myTasksFilter
                                                            withCompletionBlock:^(ASDKModelFilter *filter, NSError *error) {
                                                                if (!error && filter) {
                                                                    ASDKLogVerbose(@"Created default filter:%@", filter.name);
                                                                } else {
                                                                    ASDKLogError(@"An error occured while trying to create the default filter: %@.\nReason:%@", myTasksFilter.name, error.localizedDescription);
                                                                }
                                                                
                                                                [operation complete];
                                                            }];
    }];
    
    return createFilterOperation;
}

- (ASDKAsyncBlockOperation *)createQueuedTasksFilterForApplicationID:(NSString *)appID {
    __weak typeof(self) weakSelf = self;
    ASDKAsyncBlockOperation *createFilterOperation = [ASDKAsyncBlockOperation blockOperationWithBlock:^(ASDKAsyncBlockOperation *operation) {
        __strong typeof(self) strongSelf = weakSelf;
        
        ASDKFilterCreationRequestRepresentation *queuedTasksFilter = [ASDKFilterCreationRequestRepresentation new];
        queuedTasksFilter.jsonAdapterType = ASDKRequestRepresentationJSONAdapterTypeExcludeNilValues;
        queuedTasksFilter.appID = appID;
        queuedTasksFilter.icon = kASDKAPIIconNameQueued;
        queuedTasksFilter.index = 2;
        queuedTasksFilter.name = NSLocalizedString(kLocalizationDefaultFilterQueuedTasksText, @"Queued tasks text");
        
        ASDKModelFilter *queuedFilter = [ASDKModelFilter new];
        queuedFilter.jsonAdapterType = ASDKRequestRepresentationJSONAdapterTypeExcludeNilValues;
        queuedFilter.assignmentType = ASDKTaskAssignmentTypeCandidate;
        queuedFilter.sortType = ASDKModelFilterSortTypeCreatedDesc;
        queuedFilter.state = ASDKModelFilterStateTypeActive;
        
        queuedTasksFilter.filter = queuedFilter;
        
        [strongSelf.filterNetworkService createUserTaskFilterWithRepresentation:queuedTasksFilter
                                                            withCompletionBlock:^(ASDKModelFilter *filter, NSError *error) {
                                                                if (!error && filter) {
                                                                    ASDKLogVerbose(@"Created default filter:%@", filter.name);
                                                                } else {
                                                                    ASDKLogError(@"An error occured while trying to create the default filter: %@.\nReason:%@", queuedTasksFilter.name, error.localizedDescription);
                                                                }
                                                                
                                                                [operation complete];
                                                            }];
    }];
    
    return createFilterOperation;
}

- (ASDKAsyncBlockOperation *)createCompletedTasksFilterForApplicationID:(NSString *)appID {
    __weak typeof(self) weakSelf = self;
    ASDKAsyncBlockOperation *createFilterOperation = [ASDKAsyncBlockOperation blockOperationWithBlock:^(ASDKAsyncBlockOperation *operation) {
        __strong typeof(self) strongSelf = weakSelf;
        
        ASDKFilterCreationRequestRepresentation *completedTasksFilter = [ASDKFilterCreationRequestRepresentation new];
        completedTasksFilter.jsonAdapterType = ASDKRequestRepresentationJSONAdapterTypeExcludeNilValues;
        completedTasksFilter.appID = appID;
        completedTasksFilter.icon = kASDKAPIIconNameCompleted;
        completedTasksFilter.index = 3;
        completedTasksFilter.name = NSLocalizedString(kLocalizationDefaultFilterCompletedTasksText, @"Completed tasks text");
        
        ASDKModelFilter *completedFilter = [ASDKModelFilter new];
        completedFilter.jsonAdapterType = ASDKRequestRepresentationJSONAdapterTypeExcludeNilValues;
        completedFilter.assignmentType = ASDKTaskAssignmentTypeInvolved;
        completedFilter.sortType = ASDKModelFilterSortTypeCreatedDesc;
        completedFilter.state = ASDKModelFilterStateTypeCompleted;
        
        completedTasksFilter.filter = completedFilter;
        
        [strongSelf.filterNetworkService createUserTaskFilterWithRepresentation:completedTasksFilter
                                                            withCompletionBlock:^(ASDKModelFilter *filter, NSError *error) {
                                                                if (!error && filter) {
                                                                    ASDKLogVerbose(@"Created default filter:%@", filter.name);
                                                                } else {
                                                                    ASDKLogError(@"An error occured while trying to create the default filter: %@.\nReason:%@", completedTasksFilter.name, error.localizedDescription);
                                                                }
                                                                
                                                                [operation complete];
                                                            }];
    }];
    
    return createFilterOperation;
}

- (ASDKAsyncBlockOperation *)refetchTaskFilterListForApplicationID:(NSString *)appID {
    __weak typeof(self) weakSelf = self;
    ASDKAsyncBlockOperation *refetchTaskFilterListOperation = [ASDKAsyncBlockOperation blockOperationWithBlock:^(ASDKAsyncBlockOperation *operation) {
        __strong typeof(self) strongSelf = weakSelf;
        
        [strongSelf fetchTaskFilterListForApplicationID:appID];
        [operation complete];
    }];
    
    return refetchTaskFilterListOperation;
}


#pragma mark -
#pragma mark Cancel operations

- (void)cancelOperations {
    [super cancelOperations];
    [self.processingQueue cancelAllOperations];
    [self.filterNetworkService cancelAllNetworkOperations];
}


#pragma mark -
#pragma mark Private interface

- (ASDKFilterNetworkServices *)filterNetworkService {
    return (ASDKFilterNetworkServices *)self.networkService;
}

- (ASDKFilterCacheService *)filterCacheService {
    return (ASDKFilterCacheService *)self.cacheService;
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

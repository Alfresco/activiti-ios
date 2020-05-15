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

#import "ASDKQuerryDataAccessor.h"

// Constants
#import "ASDKLogConfiguration.h"

// Managers
#import "ASDKBootstrap.h"
#import "ASDKQuerryNetworkServices.h"
#import "ASDKTaskCacheService.h"

// Operations
#import "ASDKAsyncBlockOperation.h"

// Model
#import "ASDKTaskListQuerryRequestRepresentation.h"


static const int activitiSDKLogLevel = ASDK_LOG_LEVEL_VERBOSE; // | ASDK_LOG_FLAG_TRACE;

@interface ASDKQuerryDataAccessor ()

@property (strong, nonatomic) NSOperationQueue *processingQueue;

@end

@implementation ASDKQuerryDataAccessor

- (instancetype)initWithDelegate:(id<ASDKDataAccessorDelegate>)delegate {
    self = [super initWithDelegate:delegate];
    
    if (self) {
        _processingQueue = [self serialOperationQueue];
        _cachePolicy = ASDKServiceDataAccessorCachingPolicyHybrid;
        dispatch_queue_t taskUpdatesprocessingQueue = dispatch_queue_create([[NSString stringWithFormat:@"%@.`%@ProcessingQueue",
                                                                              [NSBundle bundleForClass:[self class]].bundleIdentifier,
                                                                              NSStringFromClass([self class])] UTF8String],
                                                                            DISPATCH_QUEUE_SERIAL);
        // Aquire and set up the task network service
        ASDKBootstrap *sdkBootstrap = [ASDKBootstrap sharedInstance];
        _networkService = (ASDKQuerryNetworkServices *)[sdkBootstrap.serviceLocator serviceConformingToProtocol:@protocol(ASDKQuerryNetworkServiceProtocol)];
        _networkService.resultsQueue = taskUpdatesprocessingQueue;
        _cacheService = [ASDKTaskCacheService new];
    }
    
    return self;
}


#pragma mark -
#pragma mark Service - Task list

- (void)fetchTasksWithFilter:(ASDKTaskListQuerryRequestRepresentation *)filter {
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
            [self.processingQueue addOperations:@[remoteTaskListOperation, completionOperation]
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

- (ASDKAsyncBlockOperation *)remoteTaskListOperationForFilter:(ASDKTaskListQuerryRequestRepresentation *)filter {
    if ([self.delegate respondsToSelector:@selector(dataAccessorDidStartFetchingRemoteData:)]) {
        [self.delegate dataAccessorDidStartFetchingRemoteData:self];
    }
    
    __weak typeof(self) weakSelf = self;
    ASDKAsyncBlockOperation *remoteTaskListOperaton = [ASDKAsyncBlockOperation blockOperationWithBlock:^(ASDKAsyncBlockOperation *operation) {
        __strong typeof(self) strongSelf = weakSelf;
        
        [strongSelf.querryNetworkService fetchTaskListWithFilterRepresentation:filter
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
    
    return remoteTaskListOperaton;
}

- (ASDKAsyncBlockOperation *)cachedTaskListOperationForFilter:(ASDKTaskListQuerryRequestRepresentation *)filter {
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
        } usingQuerryFilter:filter];
    }];
    
    return cachedTaskListOperation;
}

- (ASDKAsyncBlockOperation *)taskListStoreInCacheOperationWithFilter:(ASDKTaskListQuerryRequestRepresentation *)filter {
    __weak typeof(self) weakSelf = self;
    ASDKAsyncBlockOperation *storeInCacheOperation = [ASDKAsyncBlockOperation blockOperationWithBlock:^(ASDKAsyncBlockOperation *operation) {
        __strong typeof(self) strongSelf = weakSelf;
        ASDKAsyncBlockOperation *dependencyOperation = (ASDKAsyncBlockOperation *)operation.dependencies.firstObject;
        ASDKDataAccessorResponseCollection *remoteResponse = dependencyOperation.result;
        
        if (remoteResponse.collection) {
            [strongSelf.taskCacheService cacheTaskList:remoteResponse.collection
                                     usingQuerryFilter:filter
                                   withCompletionBlock:^(NSError *error) {
                                       if (operation.isCancelled) {
                                           [operation complete];
                                           return;
                                       }
                                       
                                       if (!error) {
                                           ASDKLogVerbose(@"Task list was successfully cached for filter.\nFilter: %@", filter);
                                           [weakSelf.taskCacheService saveChanges];
                                       } else {
                                           ASDKLogError(@"Encountered an error while caching the task list for filte: %@. Reason:%@", filter, error.localizedDescription);
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
    [self.querryNetworkService cancelAllNetworkOperations];
}


#pragma mark -
#pragma mark Private interface

- (ASDKQuerryNetworkServices *)querryNetworkService {
    return (ASDKQuerryNetworkServices *)self.networkService;
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

@end

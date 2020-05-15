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

#import "ASDKIntegrationDataAccessor.h"

// Constants
#import "ASDKLogConfiguration.h"

// Managers
#import "ASDKBootstrap.h"
#import "ASDKServiceLocator.h"
#import "ASDKIntegrationNetworkServices.h"
#import "ASDKIntegrationCacheService.h"

// Operations
#import "ASDKAsyncBlockOperation.h"

// Models
#import "ASDKDataAccessorResponseCollection.h"
#import "ASDKDataAccessorResponseModel.h"


static const int activitiSDKLogLevel = ASDK_LOG_LEVEL_VERBOSE; // | ASDK_LOG_FLAG_TRACE;

@interface ASDKIntegrationDataAccessor ()

@property (strong, nonatomic) NSOperationQueue *processingQueue;

@end

@implementation ASDKIntegrationDataAccessor

- (instancetype)initWithDelegate:(id<ASDKDataAccessorDelegate>)delegate {
    self = [super initWithDelegate:delegate];
    
    if (self) {
        _processingQueue = [self serialOperationQueue];
        _cachePolicy = ASDKServiceDataAccessorCachingPolicyHybrid;
        dispatch_queue_t integrationUpdatesProcessingQueue = dispatch_queue_create([[NSString stringWithFormat:@"%@.`%@ProcessingQueue",
                                                                                     [NSBundle bundleForClass:[self class]].bundleIdentifier,
                                                                                     NSStringFromClass([self class])] UTF8String], DISPATCH_QUEUE_SERIAL);
        
        // Acquire and set up the integration network service
        ASDKBootstrap *sdkBootstrap = [ASDKBootstrap sharedInstance];
        _networkService = (ASDKIntegrationNetworkServices *)[sdkBootstrap.serviceLocator serviceConformingToProtocol:@protocol(ASDKIntegrationNetworkServiceProtocol)];
        _networkService.resultsQueue = integrationUpdatesProcessingQueue;
        _cacheService = [ASDKIntegrationCacheService new];
    }
    
    return self;
}


#pragma mark -
#pragma mark Service - Integration accounts list

- (void)fetchIntegrationAccounts {
    // Define operations
    ASDKAsyncBlockOperation *remoteIntegrationListOperation = [self remoteIntegrationListOperation];
    ASDKAsyncBlockOperation *cachedIntegrationListOperation = [self cachedIntegrationListOperation];
    ASDKAsyncBlockOperation *storeInCacheIntegrationListOperation = [self integrationListStoreInCacheOperation];
    ASDKAsyncBlockOperation *completionOperation = [self defaultCompletionOperation];
    
    // Handle cache policies
    switch (self.cachePolicy) {
        case ASDKServiceDataAccessorCachingPolicyCacheOnly: {
            [completionOperation addDependency:cachedIntegrationListOperation];
            [self.processingQueue addOperations:@[cachedIntegrationListOperation,
                                                  completionOperation]
                              waitUntilFinished:NO];
        }
            break;
            
        case ASDKServiceDataAccessorCachingPolicyAPIOnly: {
            [completionOperation addDependency:remoteIntegrationListOperation];
            [self.processingQueue addOperations:@[remoteIntegrationListOperation,
                                                  completionOperation]
                              waitUntilFinished:NO];
        }
            break;
            
        case ASDKServiceDataAccessorCachingPolicyHybrid: {
            [remoteIntegrationListOperation addDependency:cachedIntegrationListOperation];
            [storeInCacheIntegrationListOperation addDependency:remoteIntegrationListOperation];
            [completionOperation addDependency:storeInCacheIntegrationListOperation];
            [self.processingQueue addOperations:@[cachedIntegrationListOperation,
                                                  remoteIntegrationListOperation,
                                                  storeInCacheIntegrationListOperation,
                                                  completionOperation]
                              waitUntilFinished:NO];
        }
            break;
            
        default: break;
    }
}

- (ASDKAsyncBlockOperation *)remoteIntegrationListOperation {
    if ([self.delegate respondsToSelector:@selector(dataAccessorDidStartFetchingRemoteData:)]) {
        [self.delegate dataAccessorDidStartFetchingRemoteData:self];
    }
    
    __weak typeof(self) weakSelf = self;
    ASDKAsyncBlockOperation *remoteIntegrationListOperation = [ASDKAsyncBlockOperation blockOperationWithBlock:^(ASDKAsyncBlockOperation *operation) {
        __strong typeof(self) strongSelf = weakSelf;
        
        [strongSelf.integrationNetworkService fetchIntegrationAccountsWithCompletionBlock:^(NSArray *accounts, NSError *error, ASDKModelPaging *paging) {
            if (operation.isCancelled) {
                [operation complete];
                return;
            }
            
            ASDKDataAccessorResponseCollection *responseCollection = [[ASDKDataAccessorResponseCollection alloc] initWithCollection:accounts
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
    
    return remoteIntegrationListOperation;
}

- (ASDKAsyncBlockOperation *)cachedIntegrationListOperation {
    __weak typeof(self) weakSelf = self;
    ASDKAsyncBlockOperation *cachedIntegrationListOperation = [ASDKAsyncBlockOperation blockOperationWithBlock:^(ASDKAsyncBlockOperation *operation) {
        __strong typeof(self) strongSelf = weakSelf;
        
        [strongSelf.integrationCacheService fetchIntegrationListWithCompletionBlock:^(NSArray *accounts, NSError *error, ASDKModelPaging *paging) {
            if (operation.isCancelled) {
                [operation complete];
                return;
            }
            
            if (!error) {
                ASDKLogVerbose(@"Integration account list information successfully fetched from the cache.");
                
                ASDKDataAccessorResponseCollection *response = [[ASDKDataAccessorResponseCollection alloc] initWithCollection:accounts
                                                                                                                       paging:paging
                                                                                                                 isCachedData:YES
                                                                                                                        error:error];
                if (weakSelf.delegate) {
                    [weakSelf.delegate dataAccessor:weakSelf
                                didLoadDataResponse:response];
                }
            } else {
                ASDKLogError(@"An error occured while fetching cache integration accounts information. Reason: %@", error.localizedDescription);
            }
            
            [operation complete];
        }];
    }];
    
    return  cachedIntegrationListOperation;
}

- (ASDKAsyncBlockOperation *)integrationListStoreInCacheOperation {
    __weak typeof(self) weakSelf = self;
    ASDKAsyncBlockOperation *storeInCacheOperation = [ASDKAsyncBlockOperation blockOperationWithBlock:^(ASDKAsyncBlockOperation *operation) {
        __strong typeof(self) strongSelf = weakSelf;
        
        ASDKAsyncBlockOperation *dependencyOperation = (ASDKAsyncBlockOperation *)operation.dependencies.firstObject;
        ASDKDataAccessorResponseCollection *remoteResponse = dependencyOperation.result;
        
        if (remoteResponse.collection) {
            [strongSelf.integrationCacheService cacheIntegrationList:remoteResponse.collection
                                                 withCompletionBlock:^(NSError *error) {
                                                     if (operation.isCancelled) {
                                                         [operation complete];
                                                         return;
                                                     }
                                                     
                                                     if (!error) {
                                                         ASDKLogVerbose(@"Integration account list was successfully cached.");
                                                         [weakSelf.integrationCacheService saveChanges];
                                                     } else {
                                                         ASDKLogError(@"Encountered an error while caching the integration account list. Reason: %@", error.localizedDescription);
                                                     }
                                                     
                                                     [operation complete];
                                                 }];
        }
    }];
    
    return storeInCacheOperation;
}


#pragma mark -
#pragma mark Service - Upload integration content for tasks

- (void)uploadIntegrationContentForTaskID:(NSString *)taskID
            withContentNodeRepresentation:(ASDKIntegrationNodeContentRequestRepresentation *)nodeContentRepresentation {
    NSParameterAssert(taskID);
    NSParameterAssert(nodeContentRepresentation);
    
    if ([self.delegate respondsToSelector:@selector(dataAccessorDidStartFetchingRemoteData:)]) {
        [self.delegate dataAccessorDidStartFetchingRemoteData:self];
    }
    
    __weak typeof(self) weakSelf = self;
    [self.integrationNetworkService uploadIntegrationContentForTaskID:taskID
                                                   withRepresentation:nodeContentRepresentation
                                                      completionBlock:^(ASDKModelContent *contentModel, NSError *error) {
                                                          __strong typeof(self) strongSelf = weakSelf;
                                                          
                                                          ASDKDataAccessorResponseModel *response =
                                                          [[ASDKDataAccessorResponseModel alloc] initWithModel:contentModel
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
#pragma mark Cancel operations

- (void)cancelOperations {
    [super cancelOperations];
    [self.processingQueue cancelAllOperations];
    [self.integrationNetworkService cancelAllNetworkOperations];
}


#pragma mark -
#pragma mark Private interface

- (ASDKIntegrationNetworkServices *)integrationNetworkService {
    return  (ASDKIntegrationNetworkServices *)self.networkService;
}

- (ASDKIntegrationCacheService *)integrationCacheService {
    return (ASDKIntegrationCacheService *)self.cacheService;
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

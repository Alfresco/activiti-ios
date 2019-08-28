/*******************************************************************************
 * Copyright (C) 2005-2018 Alfresco Software Limited.
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

#import "ASDKFormDataAccessor.h"

// Constants
#import "ASDKLogConfiguration.h"

// Managers
#import "ASDKBootstrap.h"
#import "ASDKServiceLocator.h"
#import "ASDKFormNetworkServices.h"
#import "ASDKFormCacheService.h"

// Operations
#import "ASDKAsyncBlockOperation.h"

// Models
#import "ASDKDataAccessorResponseModel.h"
#import "ASDKDataAccessorResponseConfirmation.h"
#import "ASDKDataAccessorResponseProgress.h"
#import "ASDKDataAccessorResponseFileContent.h"
#import "ASDKDataAccessorResponseCollection.h"
#import "ASDKDataAccessorResponseFormModel.h"
#import "ASDKDataAccessorResponseFormFieldValueRepresentations.h"


static const int activitiSDKLogLevel = ASDK_LOG_LEVEL_VERBOSE; // | ASDK_LOG_FLAG_TRACE;

@interface ASDKFormDataAccessor ()

@property (strong, nonatomic) NSOperationQueue *processingQueue;

@end

@implementation ASDKFormDataAccessor

- (instancetype)initWithDelegate:(id<ASDKDataAccessorDelegate>)delegate {
    self = [super initWithDelegate:delegate];
    
    if (self) {
        _processingQueue = [self serialOperationQueue];
        _cachePolicy = ASDKServiceDataAccessorCachingPolicyHybrid;
        dispatch_queue_t formUpdatesProcessingQueue = dispatch_queue_create([[NSString stringWithFormat:@"%@.`%@ProcessingQueue",
                                                                              [NSBundle bundleForClass:[self class]].bundleIdentifier,
                                                                              NSStringFromClass([self class])] UTF8String], DISPATCH_QUEUE_SERIAL);
        // Acquire and set up the form network service
        ASDKBootstrap *sdkBootstrap = [ASDKBootstrap sharedInstance];
        _networkService = (ASDKFormNetworkServices *)[sdkBootstrap.serviceLocator serviceConformingToProtocol:@protocol(ASDKFormNetworkServiceProtocol)];
        _networkService.resultsQueue = formUpdatesProcessingQueue;
        _cacheService = [ASDKFormCacheService new];
    }
    
    return self;
}


#pragma mark -
#pragma mark Service - Complete task form

- (void)completeFormForTaskID:(NSString *)taskID
withFormFieldValueRequestRepresentation:(ASDKFormFieldValueRequestRepresentation *)formFieldValuesRepresentation {
    NSParameterAssert(taskID);
    NSParameterAssert(formFieldValuesRepresentation);
    
    if ([self.delegate respondsToSelector:@selector(dataAccessorDidStartFetchingRemoteData:)]) {
        [self.delegate dataAccessorDidStartFetchingRemoteData:self];
    }
    
    __weak typeof(self) weakSelf = self;
    [self.formNetworkService completeFormForTaskID:taskID
           withFormFieldValueRequestRepresentation:formFieldValuesRepresentation
                                   completionBlock:^(BOOL isFormCompleted, NSError *error) {
                                       __strong typeof(self) strongSelf = weakSelf;
                                       
                                       ASDKDataAccessorResponseConfirmation *responseConfirmation =
                                       [[ASDKDataAccessorResponseConfirmation alloc] initWithConfirmation:isFormCompleted
                                                                                             isCachedData:NO
                                                                                                    error:error];
                                       
                                       if (strongSelf.delegate) {
                                           [strongSelf.delegate dataAccessor:strongSelf
                                                         didLoadDataResponse:responseConfirmation];
                                           
                                           [strongSelf.delegate dataAccessorDidFinishedLoadingDataResponse:strongSelf];
                                       }
                                   }];
    
}


#pragma mark -
#pragma mark Service - Complete process definition form

- (void)completeFormForProcessDefinition:(ASDKModelProcessDefinition *)processDefinition
withFormFieldValuesRequestRepresentation:(ASDKFormFieldValueRequestRepresentation *)formFieldValuesRepresentation {
    NSParameterAssert(processDefinition);
    NSParameterAssert(formFieldValuesRepresentation);
    
    if ([self.delegate respondsToSelector:@selector(dataAccessorDidStartFetchingRemoteData:)]) {
        [self.delegate dataAccessorDidStartFetchingRemoteData:self];
    }
    
    __weak typeof(self) weakSelf = self;
    [self.formNetworkService completeFormForProcessDefinition:processDefinition withFormFieldValuesRequestRepresentation:formFieldValuesRepresentation completionBlock:^(ASDKModelProcessInstance *processInstance, NSError *error) {
        __strong typeof(self) strongSelf = weakSelf;
        
        ASDKDataAccessorResponseModel *responseModel =
        [[ASDKDataAccessorResponseModel alloc] initWithModel:processInstance
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
#pragma mark Service - Save task form

- (void)saveFormForTaskID:(NSString *)taskID
withFormFieldValueRequestRepresentation:(ASDKFormFieldValueRequestRepresentation *)formFieldValuesRepresentation {
    NSParameterAssert(taskID);
    NSParameterAssert(formFieldValuesRepresentation);
    
    // Define operations
    ASDKAsyncBlockOperation *remoteSaveFormOperation = [self remoteSaveFormOperationForTaskID:taskID
                                                      withFormFieldValueRequestRepresentation:formFieldValuesRepresentation];
    ASDKAsyncBlockOperation *storeInCacheOperation = [self taskFormValuesStoreInCacheOperationForTaskID:taskID
                                                                withFormFieldValueRequestRepresentation:formFieldValuesRepresentation];
    ASDKAsyncBlockOperation *completionOperation = [self defaultCompletionOperation];
    
    // Handle cache policies
    switch (self.cachePolicy) {
        case ASDKServiceDataAccessorCachingPolicyCacheOnly: {
            [completionOperation addDependency:storeInCacheOperation];
            [self.processingQueue addOperations:@[storeInCacheOperation,
                                                  completionOperation]
                              waitUntilFinished:NO];
        }
            break;
            
        case ASDKServiceDataAccessorCachingPolicyAPIOnly: {
            [completionOperation addDependency:remoteSaveFormOperation];
            [self.processingQueue addOperations:@[remoteSaveFormOperation,
                                                  completionOperation]
                              waitUntilFinished:NO];
        }
            break;
            
        case ASDKServiceDataAccessorCachingPolicyHybrid: {
            [storeInCacheOperation addDependency:remoteSaveFormOperation];
            [completionOperation addDependency:storeInCacheOperation];
            [self.processingQueue addOperations:@[remoteSaveFormOperation,
                                                  storeInCacheOperation,
                                                  completionOperation]
                              waitUntilFinished:NO];
        }
            break;
            
        default: break;
    }
}

- (ASDKAsyncBlockOperation *)remoteSaveFormOperationForTaskID:(NSString *)taskID
                      withFormFieldValueRequestRepresentation:(ASDKFormFieldValueRequestRepresentation *)formFieldValueRepresentation {
    if ([self.delegate respondsToSelector:@selector(dataAccessorDidStartFetchingRemoteData:)]) {
        [self.delegate dataAccessorDidStartFetchingRemoteData:self];
    }
    
    __weak typeof(self) weakSelf = self;
    ASDKAsyncBlockOperation *remoteSaveFormOperation = [ASDKAsyncBlockOperation blockOperationWithBlock:^(ASDKAsyncBlockOperation *operation) {
        __strong typeof(self) strongSelf = weakSelf;
        
        [strongSelf.formNetworkService saveFormForTaskID:taskID
                withFormFieldValuesRequestRepresentation:formFieldValueRepresentation
                                         completionBlock:^(BOOL isFormSaved, NSError *error) {
                                             if (operation.isCancelled) {
                                                 [operation complete];
                                                 return;
                                             }
                                             
                                             ASDKDataAccessorResponseConfirmation *responseConfirmation =
                                             [[ASDKDataAccessorResponseConfirmation alloc] initWithConfirmation:isFormSaved
                                                                                                   isCachedData:NO
                                                                                                          error:error];
                                             
                                             if (weakSelf.delegate) {
                                                 [weakSelf.delegate dataAccessor:weakSelf
                                                             didLoadDataResponse:responseConfirmation];
                                             }
                                             
                                             operation.result = responseConfirmation;
                                             [operation complete];
                                         }];
    }];
    
    return remoteSaveFormOperation;
}

- (ASDKAsyncBlockOperation *)taskFormValuesStoreInCacheOperationForTaskID:(NSString *)taskID
                                  withFormFieldValueRequestRepresentation:(ASDKFormFieldValueRequestRepresentation *)formFieldValueRepresentation {
    __weak typeof(self) weakSelf = self;
    ASDKAsyncBlockOperation *storeInCacheOperation = [ASDKAsyncBlockOperation blockOperationWithBlock:^(ASDKAsyncBlockOperation *operation) {
        __strong typeof(self) strongSelf = weakSelf;
        
        ASDKAsyncBlockOperation *dependencyOperation = (ASDKAsyncBlockOperation *)operation.dependencies.firstObject;
        ASDKDataAccessorResponseConfirmation *remoteResponse = dependencyOperation.result;
        
        if (!remoteResponse || !remoteResponse.isConfirmation) {
            [strongSelf.formCacheService cacheTaskFormFieldValuesRepresentation:formFieldValueRepresentation
                                                                      forTaskID:taskID
                                                            withCompletionBlock:^(NSError *error) {
                                                                if (operation.isCancelled) {
                                                                    [operation complete];
                                                                    return;
                                                                }
                                                                
                                                                if (!error) {
                                                                    ASDKLogVerbose(@"Form field value representation cached successfully for task: %@", taskID);
                                                                    [weakSelf.formCacheService saveChanges];
                                                                } else {
                                                                    ASDKLogError(@"Encountered an error while caching form field value representation for task: %@", taskID);
                                                                }
                                                                
                                                                [operation complete];
                                                            }];
        } else {
            [operation complete];
        }
    }];
    
    return storeInCacheOperation;
}

- (void)fetchFormFieldValueRequestRepresentationForTaskID:(NSString *)taskID {
    NSParameterAssert(taskID);
    
    // Define operations
    ASDKAsyncBlockOperation *cachedFormFieldValueRepresentationOperation = [self cachedFormFieldValueRepresentationForTaskID:taskID];
    ASDKAsyncBlockOperation *completionOperation = [self defaultCompletionOperation];
    
    if (ASDKServiceDataAccessorCachingPolicyCacheOnly == self.cachePolicy ||
        ASDKServiceDataAccessorCachingPolicyHybrid == self.cachePolicy) {
        [completionOperation addDependency:cachedFormFieldValueRepresentationOperation];
        [self.processingQueue addOperations:@[cachedFormFieldValueRepresentationOperation,
                                              completionOperation]
                          waitUntilFinished:NO];
    }
}

- (ASDKAsyncBlockOperation *)cachedFormFieldValueRepresentationForTaskID:(NSString *)taskID {
    __weak typeof(self) weakSelf = self;
    ASDKAsyncBlockOperation *cachedFormFieldValueRepresentationOperation = [ASDKAsyncBlockOperation blockOperationWithBlock:^(ASDKAsyncBlockOperation *operation) {
        __strong typeof(self) strongSelf = weakSelf;
        
        [strongSelf.formCacheService
         fetchTaskFormFieldValuesRepresentationForTaskID:taskID
         withCompletionBlock:^(ASDKFormFieldValueRequestRepresentation *formFieldValueRequestRepresentation, NSError *error) {
             if (operation.isCancelled) {
                 [operation complete];
                 return;
             }
             
             if (!error) {
                 ASDKLogVerbose(@"Form field value representation successfully fetched from cache for task: %@", taskID);
                 
                 ASDKDataAccessorResponseModel *response =
                 [[ASDKDataAccessorResponseModel alloc] initWithModel:formFieldValueRequestRepresentation
                                                         isCachedData:YES
                                                                error:error];
                 if (weakSelf.delegate) {
                     [weakSelf.delegate dataAccessor:weakSelf
                                 didLoadDataResponse:response];
                 }
             } else {
                 ASDKLogError(@"An error occured while fetching cached form field value representation for task : %@. Reason:%@", taskID, error.localizedDescription);
             }
             
             [operation complete];
         }];
    }];
    
    return cachedFormFieldValueRepresentationOperation;
}

- (void)fetchAllFormFieldValueRequestRepresentations {
    // Define operations
    ASDKAsyncBlockOperation *cachedFormFieldValueRepresentationOperation = [self cachedFormFieldValueRepresentations];
    ASDKAsyncBlockOperation *completionOperation = [self defaultCompletionOperation];
    
    if (ASDKServiceDataAccessorCachingPolicyCacheOnly == self.cachePolicy ||
        ASDKServiceDataAccessorCachingPolicyHybrid == self.cachePolicy) {
        [completionOperation addDependency:cachedFormFieldValueRepresentationOperation];
        [self.processingQueue addOperations:@[cachedFormFieldValueRepresentationOperation,
                                              completionOperation]
                          waitUntilFinished:NO];
    }
}

- (ASDKAsyncBlockOperation *)cachedFormFieldValueRepresentations {
    __weak typeof(self) weakSelf = self;
    ASDKAsyncBlockOperation *cachedFormFieldValueRepresentationOperation = [ASDKAsyncBlockOperation blockOperationWithBlock:^(ASDKAsyncBlockOperation *operation) {
        __strong typeof(self) strongSelf = weakSelf;
        
        [strongSelf.formCacheService fetchAllTaskFormFieldValueRepresentationsWithCompletionBlock:^(NSArray *formFieldValueRepresentationList, NSArray *taskIDsList, NSError *error) {
            if (operation.isCancelled) {
                [operation complete];
                return;
            }
            
            if (!error) {
                ASDKLogVerbose(@"All form field value representations successfully fetched from cache.");
                
                ASDKDataAccessorResponseFormFieldValueRepresentations *response =
                [[ASDKDataAccessorResponseFormFieldValueRepresentations alloc]
                 initWithFormFieldValueRepresentations:formFieldValueRepresentationList
                 taskIDs:taskIDsList
                 isCachedData:YES
                 error:error];
                
                if (weakSelf.delegate) {
                    [weakSelf.delegate dataAccessor:weakSelf
                                didLoadDataResponse:response];
                }
            } else {
                ASDKLogError(@"An error occured while fetching all cached form field value representations. Reason:%@", error.localizedDescription);
            }
            
            [operation complete];
        }];
    }];
    
    return cachedFormFieldValueRepresentationOperation;
}

- (void)saveFormForTaskID:(NSString *)taskID
      withFormDescription:(ASDKModelFormDescription *)formDescription {
    NSParameterAssert(taskID);
    NSParameterAssert(formDescription);
    
    // Define operations
    ASDKAsyncBlockOperation *storeInCacheFormDescriptionOperation =
    [self taskFormIntermediateValuesStoreInCacheOperationForTaskID:taskID
                                               withFormDescription:formDescription];
    ASDKAsyncBlockOperation *completionOperation = [self defaultCompletionOperation];
    
    // Handle cache policies
    switch (self.cachePolicy) {
        case ASDKServiceDataAccessorCachingPolicyCacheOnly:
        case ASDKServiceDataAccessorCachingPolicyHybrid: {
            [completionOperation addDependency:storeInCacheFormDescriptionOperation];
            [self.processingQueue addOperations:@[storeInCacheFormDescriptionOperation,
                                                  completionOperation]
                              waitUntilFinished:NO];
        }
            break;
            
        default: break;
    }
}

- (ASDKAsyncBlockOperation *)taskFormIntermediateValuesStoreInCacheOperationForTaskID:(NSString *)taskID
                                                                  withFormDescription:(ASDKModelFormDescription *)formDescription {
    __weak typeof(self) weakSelf = self;
    ASDKAsyncBlockOperation *storeInCacheOperation = [ASDKAsyncBlockOperation blockOperationWithBlock:^(ASDKAsyncBlockOperation *operation) {
        __strong typeof(self) strongSelf = weakSelf;

        [strongSelf.formCacheService
         cacheTaskFormDescriptionWithIntermediateValues:formDescription
         forTaskID:taskID
         withCompletionBlock:^(NSError *error) {
             if (operation.isCancelled) {
                 [operation complete];
                 return;
             }
             
             if (!error) {
                 ASDKLogVerbose(@"Caching temporary form values for task: %@.", taskID);
                 [strongSelf.formCacheService saveChanges];
             } else {
                 ASDKLogError(@"Encountered an error while caching temporary form values for task: %@", taskID);
             }
             
             [operation complete];
         }];
    }];
    
    return storeInCacheOperation;
}

- (void)removeStalledFormFieldValueRepresentationsForTaskIDs:(NSArray *)taskIDs {
    NSParameterAssert(taskIDs);
    
    // Define operations
    ASDKAsyncBlockOperation *removeFormFieldValueRepresentationOperation = [self formFieldValueRepresentationRemoveFromCacheOperationForTaskIDs:taskIDs];
    ASDKAsyncBlockOperation *completionOperation = [self defaultCompletionOperation];
    
    // Handle cache policies
    switch (self.cachePolicy) {
        case ASDKServiceDataAccessorCachingPolicyCacheOnly:
        case ASDKServiceDataAccessorCachingPolicyHybrid: {
            [completionOperation addDependency:removeFormFieldValueRepresentationOperation];
            [self.processingQueue addOperations:@[removeFormFieldValueRepresentationOperation,
                                                  completionOperation]
                              waitUntilFinished:NO];
        }
            break;
            
        default: break;
    }
}

- (ASDKAsyncBlockOperation *)formFieldValueRepresentationRemoveFromCacheOperationForTaskIDs:(NSArray *)taskIDs {
    __weak typeof(self) weakSelf = self;
    ASDKAsyncBlockOperation *removeFromCacheOperation = [ASDKAsyncBlockOperation blockOperationWithBlock:^(ASDKAsyncBlockOperation *operation) {
        __strong typeof(self) strongSelf = weakSelf;
        
        [strongSelf.formCacheService
         removeStalledFormFieldValuesRepresentationsForTaskIDs:taskIDs
         withCompletionBlock:^(NSError *error) {
             if (operation.isCancelled) {
                 [operation complete];
                 return;
             }
             
             if (!error) {
                 ASDKLogVerbose(@"Successfully removed saved form field value representations from cache for tasks: %@", taskIDs);
             } else {
                 ASDKLogError(@"Encountered an error while removing from cache form field value representations for tasks :%@", taskIDs);
             }
             
             [operation complete];
         }];
    }];
    
    return removeFromCacheOperation;
}


#pragma mark -
#pragma mark Service - Upload form field content

- (void)uploadContentWithModel:(ASDKModelFileContent *)file
                   contentData:(NSData *)contentData {
    NSParameterAssert(file);
    NSParameterAssert(contentData);
    
    if ([self.delegate respondsToSelector:@selector(dataAccessorDidStartFetchingRemoteData:)]) {
        [self.delegate dataAccessorDidStartFetchingRemoteData:self];
    }
    
    __weak typeof(self) weakSelf = self;
    [self.formNetworkService uploadContentWithModel:file
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
                                      } completionBlock:^(ASDKModelContent *contentModel, NSError *error) {
                                          __strong typeof(self) strongSelf = weakSelf;
                                          
                                          ASDKDataAccessorResponseModel *responseModel =
                                          [[ASDKDataAccessorResponseModel alloc] initWithModel:contentModel
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
#pragma mark Service - Download form field content

- (void)downloadContentWithModel:(ASDKModelContent *)content {
    NSParameterAssert(content);
    
    if ([self.delegate respondsToSelector:@selector(dataAccessorDidStartFetchingRemoteData:)]) {
        [self.delegate dataAccessorDidStartFetchingRemoteData:self];
    }
    
    __weak typeof(self) weakSelf = self;
    
    BOOL areCachedResultsAllowed = (ASDKServiceDataAccessorCachingPolicyCacheOnly == self.cachePolicy) || (ASDKServiceDataAccessorCachingPolicyHybrid   == self.cachePolicy) ? YES : NO;
    [self.formNetworkService downloadContentWithModel:content
                                   allowCachedResults:areCachedResultsAllowed
                                        progressBlock:^(NSString *formattedReceivedBytesString, NSError *error) {
                                            __strong typeof(self) strongSelf = weakSelf;
                                            
                                            ASDKDataAccessorResponseProgress *responseProgress =
                                            [[ASDKDataAccessorResponseProgress alloc] initWithFormattedProgressString:formattedReceivedBytesString
                                                                                                                error:error];
                                            
                                            if (strongSelf.delegate) {
                                                [strongSelf.delegate dataAccessor:strongSelf
                                                              didLoadDataResponse:responseProgress];
                                            }
                                        } completionBlock:^(NSString *contentID, NSURL *downloadedContentURL, BOOL isLocalContent, NSError *error) {
                                            __strong typeof(self) strongSelf = weakSelf;
                                            
                                            ASDKDataAccessorResponseFileContent *responseFileContent =
                                            [[ASDKDataAccessorResponseFileContent alloc] initWithContent:content
                                                                                              contentURL:downloadedContentURL
                                                                                            isCachedData:isLocalContent
                                                                                                   error:error];
                                            
                                            if (strongSelf.delegate) {
                                                [strongSelf.delegate dataAccessor:strongSelf
                                                              didLoadDataResponse:responseFileContent];
                                                
                                                [strongSelf.delegate dataAccessorDidFinishedLoadingDataResponse:strongSelf];
                                            }
                                        }];
}


#pragma mark -
#pragma mark Service - Fetch REST values for task

- (void)fetchRestFieldValuesForTaskID:(NSString *)taskID
                      withFormFieldID:(NSString *)fieldID {
    // Define operations
    ASDKAsyncBlockOperation *remoteRestFieldValuesOperation = [self remoteRestFieldValuesOperationForTaskID:taskID
                                                                                            withFormFieldID:fieldID];
    ASDKAsyncBlockOperation *cachedRestFieldValuesOperation = [self cachedRestFieldValuesOperationForTaskID:taskID
                                                                                            withFormFieldID:fieldID];
    ASDKAsyncBlockOperation *storeInCacheRestFieldValuesOperation = [self restFieldValuesStoreInCacheOperationForTaskID:taskID
                                                                                                        withFormFieldID:fieldID];
    ASDKAsyncBlockOperation *completionOperation = [self defaultCompletionOperation];
    
    // Handle cache policies
    switch (self.cachePolicy) {
        case ASDKServiceDataAccessorCachingPolicyCacheOnly: {
            [completionOperation addDependency:cachedRestFieldValuesOperation];
            [self.processingQueue addOperations:@[cachedRestFieldValuesOperation,
                                                  completionOperation]
                              waitUntilFinished:NO];
        }
            break;
            
        case ASDKServiceDataAccessorCachingPolicyAPIOnly: {
            [completionOperation addDependency:remoteRestFieldValuesOperation];
            [self.processingQueue addOperations:@[remoteRestFieldValuesOperation,
                                                  completionOperation]
                              waitUntilFinished:NO];
        }
            break;
            
        case ASDKServiceDataAccessorCachingPolicyHybrid: {
            [remoteRestFieldValuesOperation addDependency:cachedRestFieldValuesOperation];
            [storeInCacheRestFieldValuesOperation addDependency:remoteRestFieldValuesOperation];
            [completionOperation addDependency:storeInCacheRestFieldValuesOperation];
            [self.processingQueue addOperations:@[cachedRestFieldValuesOperation,
                                                  remoteRestFieldValuesOperation,
                                                  storeInCacheRestFieldValuesOperation,
                                                  completionOperation]
                              waitUntilFinished:NO];
        }
            break;
            
        default:break;
    }
}

- (ASDKAsyncBlockOperation *)remoteRestFieldValuesOperationForTaskID:(NSString *)taskID
                                                     withFormFieldID:(NSString *)fieldID {
    if ([self.delegate respondsToSelector:@selector(dataAccessorDidStartFetchingRemoteData:)]) {
        [self.delegate dataAccessorDidStartFetchingRemoteData:self];
    }
    
    __weak typeof(self) weakSelf = self;
    ASDKAsyncBlockOperation *remoteRestFieldValuesOperation = [ASDKAsyncBlockOperation blockOperationWithBlock:^(ASDKAsyncBlockOperation *operation) {
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf.formNetworkService fetchRestFieldValuesForTaskWithID:taskID
                                                             withFieldID:fieldID
                                                         completionBlock:^(NSArray *restFieldValues, NSError *error) {
                                                             if (operation.isCancelled) {
                                                                 [operation complete];
                                                                 return;
                                                             }
                                                             
                                                             ASDKDataAccessorResponseCollection *responseCollection =
                                                             [[ASDKDataAccessorResponseCollection alloc] initWithCollection:restFieldValues
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
    
    return remoteRestFieldValuesOperation;
}

- (ASDKAsyncBlockOperation *)cachedRestFieldValuesOperationForTaskID:(NSString *)taskID
                                                     withFormFieldID:(NSString *)fieldID {
    __weak typeof(self) weakSelf = self;
    ASDKAsyncBlockOperation *cachedRestFieldValuesOperation = [ASDKAsyncBlockOperation blockOperationWithBlock:^(ASDKAsyncBlockOperation *operation) {
        __strong typeof(self) strongSelf = weakSelf;
        
        [strongSelf.formCacheService
         fetchRestFieldValuesForTaskID:taskID
         withFormFieldID:fieldID
         withCompletionBlock:^(NSArray *restFieldValues, NSError *error) {
             if (operation.isCancelled) {
                 [operation complete];
                 return;
             }
             
             if (!error) {
                 ASDKLogVerbose(@"Rest field values fetched succesfully from cache for taskID:%@ and formFieldID:%@", taskID, fieldID);
                 
                 ASDKDataAccessorResponseCollection *response = [[ASDKDataAccessorResponseCollection alloc] initWithCollection:restFieldValues
                                                                                                                  isCachedData:YES
                                                                                                                         error:error];
                 if (weakSelf.delegate) {
                     [weakSelf.delegate dataAccessor:weakSelf
                                 didLoadDataResponse:response];
                 }
             } else {
                 ASDKLogError(@"An error occured while fetching cached rest field values for taskID:%@ and formFieldID:%@. Reason: %@", taskID, fieldID, error.localizedDescription);
             }
             
             [operation complete];
         }];
    }];
    
    return cachedRestFieldValuesOperation;
}

- (ASDKAsyncBlockOperation *)restFieldValuesStoreInCacheOperationForTaskID:(NSString *)taskID
                                                           withFormFieldID:(NSString *)fieldID {
    __weak typeof(self) weakSelf = self;
    ASDKAsyncBlockOperation *storeInCacheOperation = [ASDKAsyncBlockOperation blockOperationWithBlock:^(ASDKAsyncBlockOperation *operation) {
        __strong typeof(self) strongSelf = weakSelf;
        
        ASDKAsyncBlockOperation *dependencyOperation = (ASDKAsyncBlockOperation *)operation.dependencies.firstObject;
        ASDKDataAccessorResponseCollection *remoteResponse = dependencyOperation.result;
        
        if (remoteResponse.collection) {
            [strongSelf.formCacheService cacheRestFieldValues:remoteResponse.collection
                                                    forTaskID:taskID
                                              withFormFieldID:fieldID
                                          withCompletionBlock:^(NSError *error) {
                                              if (operation.isCancelled) {
                                                  [operation complete];
                                                  return;
                                              }
                                              
                                              if (!error) {
                                                  ASDKLogVerbose(@"Rest field values cached successfully for taskID:%@ and formFieldID:%@.", taskID, fieldID);
                                                  [weakSelf.formCacheService saveChanges];
                                              } else {
                                                  ASDKLogError(@"Encountered an error while caching rest field values for taskID:%@ and formFieldID:%@", taskID, fieldID);
                                              }
                                              
                                              [operation complete];
                                          }];
        }
    }];
    
    return storeInCacheOperation;
}


#pragma mark -
#pragma mark Service - Fetch REST values in start form

- (void)fetchRestFieldValuesOfStartFormForProcessDefinitionID:(NSString *)processDefinitionID
                                              withFormFieldID:(NSString *)fieldID {
    // Define operations
    ASDKAsyncBlockOperation *remoteRestFieldValuesOperation = [self remoteRestFieldValuesOperationForProcessDefinitionID:processDefinitionID
                                                                                                         withFormFieldID:fieldID];
    ASDKAsyncBlockOperation *cachedRestFieldValuesOperation = [self cachedRestFieldValuesOperationForProcessDefinitionID:processDefinitionID
                                                                                                           withFormField:fieldID];
    ASDKAsyncBlockOperation *storeInCacheRestFieldValuesOperation =
    [self restFieldValuesStoreInCacheOperationForProcessDefinitionID:processDefinitionID
                                                     withFormFieldID:fieldID];
    ASDKAsyncBlockOperation *completionOperation = [self defaultCompletionOperation];
    
    // Handle cache policies
    switch (self.cachePolicy) {
        case ASDKServiceDataAccessorCachingPolicyCacheOnly: {
            [completionOperation addDependency:cachedRestFieldValuesOperation];
            [self.processingQueue addOperations:@[cachedRestFieldValuesOperation,
                                                  completionOperation]
                              waitUntilFinished:NO];
        }
            break;
            
        case ASDKServiceDataAccessorCachingPolicyAPIOnly: {
            [completionOperation addDependency:remoteRestFieldValuesOperation];
            [self.processingQueue addOperations:@[remoteRestFieldValuesOperation,
                                                  completionOperation]
                              waitUntilFinished:NO];
        }
            break;
            
        case ASDKServiceDataAccessorCachingPolicyHybrid: {
            [remoteRestFieldValuesOperation addDependency:cachedRestFieldValuesOperation];
            [storeInCacheRestFieldValuesOperation addDependency:remoteRestFieldValuesOperation];
            [completionOperation addDependency:storeInCacheRestFieldValuesOperation];
            [self.processingQueue addOperations:@[cachedRestFieldValuesOperation,
                                                  remoteRestFieldValuesOperation,
                                                  storeInCacheRestFieldValuesOperation,
                                                  completionOperation]
                              waitUntilFinished:NO];
        }
            break;
            
        default:break;
    }
}

- (ASDKAsyncBlockOperation *)remoteRestFieldValuesOperationForProcessDefinitionID:(NSString *)processDefinitionID
                                                                  withFormFieldID:(NSString *)fieldID {
    if ([self.delegate respondsToSelector:@selector(dataAccessorDidStartFetchingRemoteData:)]) {
        [self.delegate dataAccessorDidStartFetchingRemoteData:self];
    }
    
    __weak typeof(self) weakSelf = self;
    ASDKAsyncBlockOperation *remoteRestFieldValuesOperation = [ASDKAsyncBlockOperation blockOperationWithBlock:^(ASDKAsyncBlockOperation *operation) {
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf.formNetworkService
         fetchRestFieldValuesForStartFormWithProcessDefinitionID:processDefinitionID
         withFieldID:fieldID
         completionBlock:^(NSArray *restFieldValues, NSError *error) {
             if (operation.isCancelled) {
                 [operation complete];
                 return;
             }
             
             ASDKDataAccessorResponseCollection *responseCollection =
             [[ASDKDataAccessorResponseCollection alloc] initWithCollection:restFieldValues
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
    
    return remoteRestFieldValuesOperation;
}

- (ASDKAsyncBlockOperation *)cachedRestFieldValuesOperationForProcessDefinitionID:(NSString *)processDefinitionID
                                                                    withFormField:(NSString *)fieldID {
    __weak typeof(self) weakSelf = self;
    ASDKAsyncBlockOperation *cachedRestFieldValuesOperation = [ASDKAsyncBlockOperation blockOperationWithBlock:^(ASDKAsyncBlockOperation *operation) {
        __strong typeof(self) strongSelf = weakSelf;
        
        [strongSelf.formCacheService
         fetchRestFieldValuesForProcessDefinitionID:processDefinitionID
         withFormFieldID:fieldID
         withCompletionBlock:^(NSArray *restFieldValues, NSError *error) {
             if (operation.isCancelled) {
                 [operation complete];
                 return;
             }
             
             if (!error) {
                 ASDKLogVerbose(@"Rest field values fetched succesfully from cache for processDefinitionID:%@ and formFieldID:%@", processDefinitionID, fieldID);
                 
                 ASDKDataAccessorResponseCollection *response = [[ASDKDataAccessorResponseCollection alloc] initWithCollection:restFieldValues
                                                                                                                  isCachedData:YES
                                                                                                                         error:error];
                 if (weakSelf.delegate) {
                     [weakSelf.delegate dataAccessor:weakSelf
                                 didLoadDataResponse:response];
                 }
             } else {
                 ASDKLogError(@"An error occured while fetching cached rest field values for processDefinitionID:%@ and formFieldID:%@. Reason: %@", processDefinitionID, fieldID, error.localizedDescription);
             }
             
             [operation complete];
         }];
    }];
    
    return cachedRestFieldValuesOperation;
}

- (ASDKAsyncBlockOperation *)restFieldValuesStoreInCacheOperationForProcessDefinitionID:(NSString *)processDefinitionID
                                                                        withFormFieldID:(NSString *)fieldID {
    __weak typeof(self) weakSelf = self;
    ASDKAsyncBlockOperation *storeInCacheOperation = [ASDKAsyncBlockOperation blockOperationWithBlock:^(ASDKAsyncBlockOperation *operation) {
        __strong typeof(self) strongSelf = weakSelf;
        
        ASDKAsyncBlockOperation *dependencyOperation = (ASDKAsyncBlockOperation *)operation.dependencies.firstObject;
        ASDKDataAccessorResponseCollection *remoteResponse = dependencyOperation.result;
        
        if (remoteResponse.collection) {
            [strongSelf.formCacheService cacheRestFieldValues:remoteResponse.collection
                                       forProcessDefinitionID:processDefinitionID
                                              withFormFieldID:fieldID
                                          withCompletionBlock:^(NSError *error) {
                                              if (operation.isCancelled) {
                                                  [operation complete];
                                                  return;
                                              }
                                              
                                              if (!error) {
                                                  ASDKLogVerbose(@"Rest field values cached successfully for processDefinitionID:%@ and formFieldID:%@.", processDefinitionID, fieldID);
                                                  [weakSelf.formCacheService saveChanges];
                                              } else {
                                                  ASDKLogError(@"Encountered an error while caching rest field values for processDefinitionID:%@ and formFieldID:%@", processDefinitionID, fieldID);
                                              }
                                              
                                              [operation complete];
                                          }];
        }
    }];
    
    return storeInCacheOperation;
}


#pragma mark -
#pragma mark Service -  Fetch REST values for task in dynamic table

- (void)fetchRestFieldValuesForTaskID:(NSString *)taskID
                      withFormFieldID:(NSString *)fieldID
                         withColumnID:(NSString *)columnID {
    // Define operations
    ASDKAsyncBlockOperation *remoteRestFieldValuesOperation = [self remoteRestFieldValuesOperationForTaskID:taskID
                                                                                            withFormFieldID:fieldID
                                                                                               withColumnID:columnID];
    ASDKAsyncBlockOperation *cachedRestFieldValuesOperation = [self cachedRestFieldValuesOperationForTaskID:taskID
                                                                                            withFormFieldID:fieldID
                                                                                               withColumnID:columnID];
    ASDKAsyncBlockOperation *storeInCacheRestFieldValuesOperation =
    [self restFieldValuesStoreInCacheOperationForTaskID:taskID
                                        withFormFieldID:fieldID
                                           withColumnID:columnID];
    ASDKAsyncBlockOperation *completionOperation = [self defaultCompletionOperation];
    
    // Handle cache policies
    switch (self.cachePolicy) {
        case ASDKServiceDataAccessorCachingPolicyCacheOnly: {
            [completionOperation addDependency:cachedRestFieldValuesOperation];
            [self.processingQueue addOperations:@[cachedRestFieldValuesOperation,
                                                  completionOperation]
                              waitUntilFinished:NO];
        }
            break;
            
        case ASDKServiceDataAccessorCachingPolicyAPIOnly: {
            [completionOperation addDependency:remoteRestFieldValuesOperation];
            [self.processingQueue addOperations:@[remoteRestFieldValuesOperation,
                                                  completionOperation]
                              waitUntilFinished:NO];
        }
            break;
            
        case ASDKServiceDataAccessorCachingPolicyHybrid: {
            [remoteRestFieldValuesOperation addDependency:cachedRestFieldValuesOperation];
            [storeInCacheRestFieldValuesOperation addDependency:remoteRestFieldValuesOperation];
            [completionOperation addDependency:storeInCacheRestFieldValuesOperation];
            [self.processingQueue addOperations:@[cachedRestFieldValuesOperation,
                                                  remoteRestFieldValuesOperation,
                                                  storeInCacheRestFieldValuesOperation,
                                                  completionOperation]
                              waitUntilFinished:NO];
        }
            break;
            
        default:break;
    }
}

- (ASDKAsyncBlockOperation *)remoteRestFieldValuesOperationForTaskID:(NSString *)taskID
                                                     withFormFieldID:(NSString *)fieldID
                                                        withColumnID:(NSString *)columnID {
    if ([self.delegate respondsToSelector:@selector(dataAccessorDidStartFetchingRemoteData:)]) {
        [self.delegate dataAccessorDidStartFetchingRemoteData:self];
    }
    
    __weak typeof(self) weakSelf = self;
    ASDKAsyncBlockOperation *remoteRestFieldValuesOperation = [ASDKAsyncBlockOperation blockOperationWithBlock:^(ASDKAsyncBlockOperation *operation) {
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf.formNetworkService
         fetchRestFieldValuesForTaskWithID:taskID
         withFieldID:fieldID
         withColumnID:columnID
         completionBlock:^(NSArray *restFieldValues, NSError *error) {
             if (operation.isCancelled) {
                 [operation complete];
                 return;
             }
             
             ASDKDataAccessorResponseCollection *responseCollection =
             [[ASDKDataAccessorResponseCollection alloc] initWithCollection:restFieldValues
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
    
    return remoteRestFieldValuesOperation;
}

- (ASDKAsyncBlockOperation *)cachedRestFieldValuesOperationForTaskID:(NSString *)taskID
                                                     withFormFieldID:(NSString *)fieldID
                                                        withColumnID:(NSString *)columnID {
    __weak typeof(self) weakSelf = self;
    ASDKAsyncBlockOperation *cachedRestFieldValuesOperation = [ASDKAsyncBlockOperation blockOperationWithBlock:^(ASDKAsyncBlockOperation *operation) {
        __strong typeof(self) strongSelf = weakSelf;
        
        [strongSelf.formCacheService
         fetchRestFieldValuesForTaskID:taskID
         withFormFieldID:fieldID
         withColumnID:columnID
         withCompletionBlock:^(NSArray *restFieldValues, NSError *error) {
             if (operation.isCancelled) {
                 [operation complete];
                 return;
             }
             
             if (!error) {
                 ASDKLogVerbose(@"Rest field values fetched succesfully from cache for taskID:%@ , formFieldID:%@ and columnID:%@", taskID, fieldID, columnID);
                 
                 ASDKDataAccessorResponseCollection *response = [[ASDKDataAccessorResponseCollection alloc] initWithCollection:restFieldValues
                                                                                                                  isCachedData:YES
                                                                                                                         error:error];
                 if (weakSelf.delegate) {
                     [weakSelf.delegate dataAccessor:weakSelf
                                 didLoadDataResponse:response];
                 }
             } else {
                 ASDKLogError(@"An error occured while fetching cached rest field values for taskID:%@ , formFieldID:%@ and columnID:%@ . Reason: %@", taskID, fieldID, columnID, error.localizedDescription);
             }
             
             [operation complete];
         }];
    }];
    
    return cachedRestFieldValuesOperation;
}

- (ASDKAsyncBlockOperation *)restFieldValuesStoreInCacheOperationForTaskID:(NSString *)taskID
                                                           withFormFieldID:(NSString *)fieldID
                                                              withColumnID:(NSString *)columnID {
    __weak typeof(self) weakSelf = self;
    ASDKAsyncBlockOperation *storeInCacheOperation = [ASDKAsyncBlockOperation blockOperationWithBlock:^(ASDKAsyncBlockOperation *operation) {
        __strong typeof(self) strongSelf = weakSelf;
        
        ASDKAsyncBlockOperation *dependencyOperation = (ASDKAsyncBlockOperation *)operation.dependencies.firstObject;
        ASDKDataAccessorResponseCollection *remoteResponse = dependencyOperation.result;
        
        if (remoteResponse.collection) {
            [strongSelf.formCacheService cacheRestFieldValues:remoteResponse.collection
                                                    forTaskID:taskID
                                              withFormFieldID:fieldID
                                                 withColumnID:columnID
                                          withCompletionBlock:^(NSError *error) {
                                              if (operation.isCancelled) {
                                                  [operation complete];
                                                  return;
                                              }
                                              
                                              if (!error) {
                                                  ASDKLogVerbose(@"Rest field values cached successfully for taskID:%@ , formFieldID:%@ and columnID:%@.", taskID, fieldID, columnID);
                                                  [weakSelf.formCacheService saveChanges];
                                              } else {
                                                  ASDKLogError(@"Encountered an error while caching rest field values for taskID:%@ , formFieldID:%@ and columnID:%@", taskID, fieldID, columnID);
                                              }
                                              
                                              [operation complete];
                                          }];
        }
    }];
    
    return storeInCacheOperation;
}


#pragma mark -
#pragma mark Service - Fetch REST values for dynamic table in start form

- (void)fetchRestFieldValuesOfStartFormWithProcessDefinitionID:(NSString *)processDefinitionID
                                                 withFormField:(NSString *)fieldID
                                                  withColumnID:(NSString *)columnID {
    // Define operations
    ASDKAsyncBlockOperation *remoteRestFieldValuesOperation = [self remoteRestFieldValuesOperationForProcessDefinitionID:processDefinitionID
                                                                                                         withFormFieldID:fieldID
                                                                                                            withColumnID:columnID];
    ASDKAsyncBlockOperation *cachedRestFieldValuesOperation = [self cachedRestFieldValuesOperationForProcessDefinitionID:processDefinitionID
                                                                                                         withFormFieldID:fieldID
                                                                                                            withColumnID:columnID];
    ASDKAsyncBlockOperation *storeInCacheRestFieldValuesOperation =
    [self restFieldValuesStoreInCacheOperationForProcessDefinitionID:processDefinitionID
                                                     withFormFieldID:fieldID
                                                        withColumnID:columnID];
    ASDKAsyncBlockOperation *completionOperation = [self defaultCompletionOperation];
    
    // Handle cache policies
    switch (self.cachePolicy) {
        case ASDKServiceDataAccessorCachingPolicyCacheOnly: {
            [completionOperation addDependency:cachedRestFieldValuesOperation];
            [self.processingQueue addOperations:@[cachedRestFieldValuesOperation,
                                                  completionOperation]
                              waitUntilFinished:NO];
        }
            break;
            
        case ASDKServiceDataAccessorCachingPolicyAPIOnly: {
            [completionOperation addDependency:remoteRestFieldValuesOperation];
            [self.processingQueue addOperations:@[remoteRestFieldValuesOperation,
                                                  completionOperation]
                              waitUntilFinished:NO];
        }
            break;
            
        case ASDKServiceDataAccessorCachingPolicyHybrid: {
            [remoteRestFieldValuesOperation addDependency:cachedRestFieldValuesOperation];
            [storeInCacheRestFieldValuesOperation addDependency:remoteRestFieldValuesOperation];
            [completionOperation addDependency:storeInCacheRestFieldValuesOperation];
            [self.processingQueue addOperations:@[cachedRestFieldValuesOperation,
                                                  remoteRestFieldValuesOperation,
                                                  storeInCacheRestFieldValuesOperation,
                                                  completionOperation]
                              waitUntilFinished:NO];
        }
            break;
            
        default:break;
    }
}

- (ASDKAsyncBlockOperation *)remoteRestFieldValuesOperationForProcessDefinitionID:(NSString *)processDefinitionID
                                                                  withFormFieldID:(NSString *)fieldID
                                                                     withColumnID:(NSString *)columnID {
    if ([self.delegate respondsToSelector:@selector(dataAccessorDidStartFetchingRemoteData:)]) {
        [self.delegate dataAccessorDidStartFetchingRemoteData:self];
    }
    
    __weak typeof(self) weakSelf = self;
    ASDKAsyncBlockOperation *remoteRestFieldValuesOperation = [ASDKAsyncBlockOperation blockOperationWithBlock:^(ASDKAsyncBlockOperation *operation) {
        __strong typeof(self) strongSelf = weakSelf;
        
        [strongSelf.formNetworkService
         fetchRestFieldValuesForStartFormWithProcessDefinitionID:processDefinitionID
         withFieldID:fieldID
         withColumnID:columnID
         completionBlock:^(NSArray *restFieldValues, NSError *error) {
             if (operation.isCancelled) {
                 [operation complete];
                 return;
             }
             
             ASDKDataAccessorResponseCollection *responseCollection =
             [[ASDKDataAccessorResponseCollection alloc] initWithCollection:restFieldValues
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
    
    return remoteRestFieldValuesOperation;
}

- (ASDKAsyncBlockOperation *)cachedRestFieldValuesOperationForProcessDefinitionID:(NSString *)processDefinitionID
                                                                  withFormFieldID:(NSString *)fieldID
                                                                     withColumnID:(NSString *)columnID {
    __weak typeof(self) weakSelf = self;
    ASDKAsyncBlockOperation *cachedRestFieldValuesOperation = [ASDKAsyncBlockOperation blockOperationWithBlock:^(ASDKAsyncBlockOperation *operation) {
        __strong typeof(self) strongSelf = weakSelf;
        
        [strongSelf.formCacheService
         fetchRestFieldValuesForProcessDefinition:processDefinitionID
         withFormFieldID:fieldID
         withColumnID:columnID
         withCompletionBlock:^(NSArray *restFieldValues, NSError *error) {
             if (operation.isCancelled) {
                 [operation complete];
                 return;
             }
             
             if (!error) {
                 ASDKLogVerbose(@"Rest field values fetched succesfully from cache for processDefinitionID:%@ , formFieldID:%@ and columnID:%@", processDefinitionID, fieldID, columnID);
                 
                 ASDKDataAccessorResponseCollection *response = [[ASDKDataAccessorResponseCollection alloc] initWithCollection:restFieldValues
                                                                                                                  isCachedData:YES
                                                                                                                         error:error];
                 if (weakSelf.delegate) {
                     [weakSelf.delegate dataAccessor:weakSelf
                                 didLoadDataResponse:response];
                 }
             } else {
                 ASDKLogError(@"An error occured while fetching cached rest field values for processDefinitionID:%@ , formFieldID:%@ and columnID:%@ . Reason: %@", processDefinitionID, fieldID, columnID, error.localizedDescription);
             }
             
             [operation complete];
         }];
    }];
    
    return cachedRestFieldValuesOperation;
}

- (ASDKAsyncBlockOperation *)restFieldValuesStoreInCacheOperationForProcessDefinitionID:(NSString *)processDefinitionID
                                                                        withFormFieldID:(NSString *)fieldID
                                                                           withColumnID:(NSString *)columnID {
    __weak typeof(self) weakSelf = self;
    ASDKAsyncBlockOperation *storeInCacheOperation = [ASDKAsyncBlockOperation blockOperationWithBlock:^(ASDKAsyncBlockOperation *operation) {
        __strong typeof(self) strongSelf = weakSelf;
        
        ASDKAsyncBlockOperation *dependencyOperation = (ASDKAsyncBlockOperation *)operation.dependencies.firstObject;
        ASDKDataAccessorResponseCollection *remoteResponse = dependencyOperation.result;
        
        if (remoteResponse.collection) {
            [strongSelf.formCacheService
             cacheRestFieldValues:remoteResponse.collection
             forProcessDefinitionID:processDefinitionID
             withFormFieldID:fieldID
             withColumnID:columnID
             withCompletionBlock:^(NSError *error) {
                 if (operation.isCancelled) {
                     [operation complete];
                     return;
                 }
                 
                 if (!error) {
                     ASDKLogVerbose(@"Rest field values cached successfully for processDefinitionID:%@ , formFieldID:%@ and columnID:%@.", processDefinitionID, fieldID, columnID);
                     [weakSelf.formCacheService saveChanges];
                 } else {
                     ASDKLogError(@"Encountered an error while caching rest field values for processDefinitionID:%@ , formFieldID:%@ and columnID:%@", processDefinitionID, fieldID, columnID);
                 }
                 
                 [operation complete];
            }];
        }
    }];
    
    return storeInCacheOperation;
}


#pragma mark -
#pragma mark Service - Fetch task form

- (void)fetchFormDescriptionForTaskID:(NSString *)taskID {
    // Define operations
    ASDKAsyncBlockOperation *remoteFormDescriptionOperation = [self remoteFormDescriptionOperationForTaskID:taskID];
    ASDKAsyncBlockOperation *cachedFormDescriptionOperation = [self cachedFormDescriptionOperationForTaskID:taskID];
    ASDKAsyncBlockOperation *storeInCacheOperation = [self formDescriptionStoreInCacheOperationForTaskID:taskID];
    ASDKAsyncBlockOperation *completionOperation = [self defaultCompletionOperation];
    
    // Handle cache policies
    switch (self.cachePolicy) {
        case ASDKServiceDataAccessorCachingPolicyCacheOnly: {
            [completionOperation addDependency:cachedFormDescriptionOperation];
            [self.processingQueue addOperations:@[cachedFormDescriptionOperation,
                                                  completionOperation]
                              waitUntilFinished:NO];
        }
            break;
            
        case ASDKServiceDataAccessorCachingPolicyAPIOnly: {
            [completionOperation addDependency:remoteFormDescriptionOperation];
            [self.processingQueue addOperations:@[remoteFormDescriptionOperation,
                                                  completionOperation]
                              waitUntilFinished:NO];
        }
            break;
            
        case ASDKServiceDataAccessorCachingPolicyHybrid: {
            [remoteFormDescriptionOperation addDependency:cachedFormDescriptionOperation];
            [storeInCacheOperation addDependency:remoteFormDescriptionOperation];
            [completionOperation addDependency:storeInCacheOperation];
            [self.processingQueue addOperations:@[cachedFormDescriptionOperation,
                                                  remoteFormDescriptionOperation,
                                                  storeInCacheOperation,
                                                  completionOperation]
                              waitUntilFinished:NO];
        }
            break;
            
        default: break;
    }
}

- (ASDKAsyncBlockOperation *)remoteFormDescriptionOperationForTaskID:(NSString *)taskID {
    if ([self.delegate respondsToSelector:@selector(dataAccessorDidStartFetchingRemoteData:)]) {
        [self.delegate dataAccessorDidStartFetchingRemoteData:self];
    }
    
    __weak typeof(self) weakSelf = self;
    ASDKAsyncBlockOperation *remoteFormDescriptionOperation = [ASDKAsyncBlockOperation blockOperationWithBlock:^(ASDKAsyncBlockOperation *operation) {
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf.formNetworkService fetchFormForTaskWithID:taskID
                                              completionBlock:^(ASDKModelFormDescription *formDescription, NSError *error) {
                                                  if (operation.isCancelled) {
                                                      [operation complete];
                                                      return;
                                                  }
                                                  
                                                  ASDKDataAccessorResponseFormModel *responseModel =
                                                  [[ASDKDataAccessorResponseFormModel alloc] initWithModel:formDescription
                                                                                              isCachedData:NO
                                                                                               isSavedForm:NO
                                                                                                     error:error];
                                                  
                                                  if (weakSelf.delegate) {
                                                      [weakSelf.delegate dataAccessor:weakSelf
                                                                  didLoadDataResponse:responseModel];
                                                  }
                                                  
                                                  operation.result = responseModel;
                                                  [operation complete];
                                              }];
    }];
    
    return remoteFormDescriptionOperation;
}

- (ASDKAsyncBlockOperation *)cachedFormDescriptionOperationForTaskID:(NSString *)taskID {
    __weak typeof(self) weakSelf = self;
    ASDKAsyncBlockOperation *cachedFormDescriptionOperation = [ASDKAsyncBlockOperation blockOperationWithBlock:^(ASDKAsyncBlockOperation *operation) {
        __strong typeof(self) strongSelf = weakSelf;
        
        [strongSelf.formCacheService fetchTaskFormDescriptionForTaskID:taskID
                                                   withCompletionBlock:^(ASDKModelFormDescription *formDescription, NSError *error, BOOL isSavedForm) {
                                                       if (operation.isCancelled) {
                                                           [operation complete];
                                                           return;
                                                       }
                                                       
                                                       if (!error) {
                                                           ASDKLogVerbose(@"Form description fetched successfully from cache for taskID: %@", taskID);
                                                           
                                                           /* The additional parameter isSavedForm is also required along the isCacheData
                                                            * param to differentiate between the cases where a form description is provided with
                                                            * or without user info
                                                            */
                                                           ASDKDataAccessorResponseFormModel *response =
                                                           [[ASDKDataAccessorResponseFormModel alloc] initWithModel:formDescription
                                                                                                       isCachedData:YES
                                                                                                        isSavedForm:isSavedForm
                                                                                                              error:error];
                                                           if (weakSelf.delegate) {
                                                               [weakSelf.delegate dataAccessor:weakSelf
                                                                           didLoadDataResponse:response];
                                                           }
                                                       } else {
                                                           ASDKLogError(@"An error occured while fetching cached form description for taskID: %@. Reason: %@", taskID, error.localizedDescription);
                                                       }
                                                       
                                                       [operation complete];
        }];
    }];
    
    return cachedFormDescriptionOperation;
}

- (ASDKAsyncBlockOperation *)formDescriptionStoreInCacheOperationForTaskID:(NSString *)taskID {
    __weak typeof(self) weakSelf = self;
    ASDKAsyncBlockOperation *storeInCacheOperation = [ASDKAsyncBlockOperation blockOperationWithBlock:^(ASDKAsyncBlockOperation *operation) {
        __strong typeof(self) strongSelf = weakSelf;
        
        ASDKAsyncBlockOperation *dependencyOperation = (ASDKAsyncBlockOperation *)operation.dependencies.firstObject;
        ASDKDataAccessorResponseModel *remoteResponse = dependencyOperation.result;
        
        if (remoteResponse.model) {
            [strongSelf.formCacheService cacheTaskFormDescription:remoteResponse.model
                                                        forTaskID:taskID
                                              withCompletionBlock:^(NSError *error) {
                                                  if (operation.isCancelled) {
                                                      [operation complete];
                                                      return;
                                                  }
                                                  
                                                  if (!error) {
                                                      ASDKLogVerbose(@"Form description for task: %@ cached successfully", taskID);
                                                      [weakSelf.formCacheService saveChanges];
                                                  } else {
                                                      ASDKLogError(@"Encountered an error while caching form description for task: %@", taskID);
                                                  }
                                                  
                                                  [operation complete];
            }];
        } else {
            [operation complete];
        }
    }];
    
    return storeInCacheOperation;
}


#pragma mark -
#pragma mark Service - Fetch task form variables


- (void)fetchFormVariablesForTaskID:(NSString *)taskID {
    // Define operations
    ASDKAsyncBlockOperation *remoteFormVariablesOperation = [self remoteFormVariablesForTaskID:taskID];
    ASDKAsyncBlockOperation *cachedFormVariablesOperation = [self cachedFormVariablesOperationForTaskID:taskID];
    ASDKAsyncBlockOperation *storeInCacheOperation = [self formVariablesStoreInCacheOperationForTaskID:taskID];
    ASDKAsyncBlockOperation *completionOperation = [self defaultCompletionOperation];
    
    // Handle cache policies
    switch (self.cachePolicy) {
        case ASDKServiceDataAccessorCachingPolicyCacheOnly: {
            [completionOperation addDependency:cachedFormVariablesOperation];
            [self.processingQueue addOperations:@[cachedFormVariablesOperation,
                                                  completionOperation]
                              waitUntilFinished:NO];
        }
            break;
            
        case ASDKServiceDataAccessorCachingPolicyAPIOnly: {
            [completionOperation addDependency:remoteFormVariablesOperation];
            [self.processingQueue addOperations:@[remoteFormVariablesOperation,
                                                  completionOperation]
                              waitUntilFinished:NO];
        }
            break;
            
        case ASDKServiceDataAccessorCachingPolicyHybrid: {
            [remoteFormVariablesOperation addDependency:cachedFormVariablesOperation];
            [storeInCacheOperation addDependency:remoteFormVariablesOperation];
            [completionOperation addDependency:storeInCacheOperation];
            [self.processingQueue addOperations:@[cachedFormVariablesOperation,
                                                  remoteFormVariablesOperation,
                                                  storeInCacheOperation,
                                                  completionOperation]
                              waitUntilFinished:NO];
        }
            break;
            
        default: break;
    }
}

- (ASDKAsyncBlockOperation *)remoteFormVariablesForTaskID:(NSString *)taskID {
    if ([self.delegate respondsToSelector:@selector(dataAccessorDidStartFetchingRemoteData:)]) {
        [self.delegate dataAccessorDidStartFetchingRemoteData:self];
    }
    
    __weak typeof(self) weakSelf = self;
    ASDKAsyncBlockOperation *remoteFormDescriptionOperation = [ASDKAsyncBlockOperation blockOperationWithBlock:^(ASDKAsyncBlockOperation *operation) {
        __strong typeof(self) strongSelf = weakSelf;
        
        [strongSelf.formNetworkService fetchFormVariablesForTaskWithID:taskID
                                                       completionBlock:^(NSArray *formVariables, NSError *error) {
                                                           if (operation.isCancelled) {
                                                               [operation complete];
                                                               return;
                                                           }
                                                           
                                                           ASDKDataAccessorResponseCollection *responseCollection =
                                                           [[ASDKDataAccessorResponseCollection alloc] initWithCollection:formVariables
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
    
    return remoteFormDescriptionOperation;
}

- (ASDKAsyncBlockOperation *)cachedFormVariablesOperationForTaskID:(NSString *)taskID {
    __weak typeof(self) weakSelf = self;
    ASDKAsyncBlockOperation *cachedFormVariablesOperation = [ASDKAsyncBlockOperation blockOperationWithBlock:^(ASDKAsyncBlockOperation *operation) {
        __strong typeof(self) strongSelf = weakSelf;
        
        [strongSelf.formCacheService fetchTaskFormVariablesForTaskID:taskID
                                                 withCompletionBlock:^(NSArray *formVariables, NSError *error) {
                                                     if (operation.isCancelled) {
                                                         [operation complete];
                                                         return;
                                                     }
                                                     
                                                     if (!error) {
                                                         ASDKLogVerbose(@"Form variables fetches successfully for taskID: %@", taskID);
                                                         
                                                         ASDKDataAccessorResponseCollection *responseCollection =
                                                         [[ASDKDataAccessorResponseCollection alloc] initWithCollection:formVariables
                                                                                                           isCachedData:YES
                                                                                                                  error:error];
                                                         if (weakSelf.delegate) {
                                                             [weakSelf.delegate dataAccessor:weakSelf
                                                                         didLoadDataResponse:responseCollection];
                                                         }
                                                     } else {
                                                         ASDKLogError(@"An error occured while fetching cached form variables for taskID: %@. Reason: %@", taskID, error.localizedDescription);
                                                     }
                                                     
                                                     [operation complete];
        }];
    }];
    
    return cachedFormVariablesOperation;
}

- (ASDKAsyncBlockOperation *)formVariablesStoreInCacheOperationForTaskID:(NSString *)taskID {
    __weak typeof(self) weakSelf = self;
    ASDKAsyncBlockOperation *storeInCacheOperation = [ASDKAsyncBlockOperation blockOperationWithBlock:^(ASDKAsyncBlockOperation *operation) {
        __strong typeof(self) strongSelf = weakSelf;
        
        ASDKAsyncBlockOperation *dependencyOperation = (ASDKAsyncBlockOperation *)operation.dependencies.firstObject;
        ASDKDataAccessorResponseCollection *remoteResponse = dependencyOperation.result;
        
        if (remoteResponse.collection) {
            [strongSelf.formCacheService cacheTaskFormVariables:remoteResponse.collection
                                                      forTaskID:taskID
                                            withCompletionBlock:^(NSError *error) {
                                                if (operation.isCancelled) {
                                                    [operation complete];
                                                }
                                                
                                                if (!error) {
                                                    ASDKLogVerbose(@"Form variables for task: %@ cached successfully", taskID);
                                                    [weakSelf.formCacheService saveChanges];
                                                } else {
                                                    ASDKLogError(@"Encountered an error while caching form variables for task: %@", taskID);
                                                }
                                                
                                                [operation complete];
            }];
        }
    }];
    
    return storeInCacheOperation;
}


#pragma mark -
#pragma mark Service - Fetch process instance form

- (void)fetchFormDescriptionForProcessInstanceID:(NSString *)processInstanceID {
    // Define operations
    ASDKAsyncBlockOperation *remoteFormDescriptionOperation = [self remoteFormDescriptionOperationForProcessInstanceID:processInstanceID];
    ASDKAsyncBlockOperation *cachedFormDescriptionOperation = [self cachedFormDescriptionOperationForProcessInstanceID:processInstanceID];
    ASDKAsyncBlockOperation *storeInCacheOperation = [self formDescriptionStoreInCacheOperationForProcessInstanceID:processInstanceID];
    ASDKAsyncBlockOperation *completionOperation = [self defaultCompletionOperation];
    
    // Handle cache policies
    switch (self.cachePolicy) {
        case ASDKServiceDataAccessorCachingPolicyCacheOnly: {
            [completionOperation addDependency:cachedFormDescriptionOperation];
            [self.processingQueue addOperations:@[cachedFormDescriptionOperation,
                                                  completionOperation]
                              waitUntilFinished:NO];
        }
            break;
            
        case ASDKServiceDataAccessorCachingPolicyAPIOnly: {
            [completionOperation addDependency:remoteFormDescriptionOperation];
            [self.processingQueue addOperations:@[remoteFormDescriptionOperation,
                                                  completionOperation]
                              waitUntilFinished:NO];
        }
            break;
            
        case ASDKServiceDataAccessorCachingPolicyHybrid: {
            [remoteFormDescriptionOperation addDependency:cachedFormDescriptionOperation];
            [storeInCacheOperation addDependency:remoteFormDescriptionOperation];
            [completionOperation addDependency:storeInCacheOperation];
            [self.processingQueue addOperations:@[cachedFormDescriptionOperation,
                                                  remoteFormDescriptionOperation,
                                                  storeInCacheOperation,
                                                  completionOperation]
                              waitUntilFinished:NO];
        }
            break;
            
        default: break;
    }
}

- (ASDKAsyncBlockOperation *)remoteFormDescriptionOperationForProcessInstanceID:(NSString *)processInstanceID {
    if ([self.delegate respondsToSelector:@selector(dataAccessorDidStartFetchingRemoteData:)]) {
        [self.delegate dataAccessorDidStartFetchingRemoteData:self];
    }
    
    __weak typeof(self) weakSelf = self;
    ASDKAsyncBlockOperation *remoteFormDescriptionOperation = [ASDKAsyncBlockOperation blockOperationWithBlock:^(ASDKAsyncBlockOperation *operation) {
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf.formNetworkService startFormForProcessInstanceID:processInstanceID
                                                     completionBlock:^(ASDKModelFormDescription *formDescription, NSError *error) {
                                                         if (operation.isCancelled) {
                                                             [operation complete];
                                                             return;
                                                         }
                                                         
                                                         ASDKDataAccessorResponseModel *responseModel =
                                                         [[ASDKDataAccessorResponseModel alloc] initWithModel:formDescription
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
    
    return remoteFormDescriptionOperation;
}

- (ASDKAsyncBlockOperation *)cachedFormDescriptionOperationForProcessInstanceID:(NSString *)processInstanceID {
    __weak typeof(self) weakSelf = self;
    ASDKAsyncBlockOperation *cachedFormDescriptionOperation = [ASDKAsyncBlockOperation blockOperationWithBlock:^(ASDKAsyncBlockOperation *operation) {
        __strong typeof(self) strongSelf = weakSelf;
        
        [strongSelf.formCacheService
         fetchProcessInstanceFormDescriptionForProcessInstance:processInstanceID
         withCompletionBlock:^(ASDKModelFormDescription *formDescription, NSError *error) {
             if (operation.isCancelled) {
                 [operation complete];
                 return;
             }
             
             if (!error) {
                 ASDKLogVerbose(@"Form description fetched successfully from cache for processInstanceID: %@", processInstanceID);
                 
                 ASDKDataAccessorResponseModel *response =
                 [[ASDKDataAccessorResponseModel alloc] initWithModel:formDescription
                                                         isCachedData:YES
                                                                error:error];
                 if (weakSelf.delegate) {
                     [weakSelf.delegate dataAccessor:weakSelf
                                 didLoadDataResponse:response];
                 }
             } else {
                 ASDKLogError(@"An error occured while fetching cached form description for processInstanceID: %@. Reason: %@", processInstanceID, error.localizedDescription);
             }
             
             [operation complete];
         }];
    }];
    
    return cachedFormDescriptionOperation;
}

- (ASDKAsyncBlockOperation *)formDescriptionStoreInCacheOperationForProcessInstanceID:(NSString *)processInstanceID {
    __weak typeof(self) weakSelf = self;
    ASDKAsyncBlockOperation *storeInCacheOperation = [ASDKAsyncBlockOperation blockOperationWithBlock:^(ASDKAsyncBlockOperation *operation) {
        __strong typeof(self) strongSelf = weakSelf;
        
        ASDKAsyncBlockOperation *dependencyOperation = (ASDKAsyncBlockOperation *)operation.dependencies.firstObject;
        ASDKDataAccessorResponseModel *remoteResponse = dependencyOperation.result;
        
        if (remoteResponse.model) {
            [strongSelf.formCacheService cacheProcessInstanceFormDescription:remoteResponse.model
                                                        forProcessInstanceID:processInstanceID
                                                         withCompletionBlock:^(NSError *error) {
                                                             if (operation.isCancelled) {
                                                                 [operation complete];
                                                                 return;
                                                             }
                                                             
                                                             if (!error) {
                                                                 ASDKLogVerbose(@"Form description for process instance: %@ cached successfully", processInstanceID);
                                                                 [weakSelf.formCacheService saveChanges];
                                                             } else {
                                                                 ASDKLogError(@"Encountered an error while caching form description for process instance: %@", processInstanceID);
                                                             }
                                                             
                                                             [operation complete];
            }];
        }
    }];
    
    return storeInCacheOperation;
}


#pragma mark -
#pragma mark Service - Fetch process definition form

- (void)fetchFormDescriptionForProcessDefinitionID:(NSString *)processDefinitionID {
    // Define operations
    ASDKAsyncBlockOperation *remoteFormDescriptionOperation = [self remoteFormDescriptionOperationForProcessDefinitionID:processDefinitionID];
    ASDKAsyncBlockOperation *cachedFormDescriptionOperation = [self cachedFormDescriptionOperationforProcessDefinitionID:processDefinitionID];
    ASDKAsyncBlockOperation *storeInCacheOperation = [self formDescriptionStoreInCacheOperationForProcessDefinitionID:processDefinitionID];
    ASDKAsyncBlockOperation *completionOperation = [self defaultCompletionOperation];
    
    // Handle cache policies
    switch (self.cachePolicy) {
        case ASDKServiceDataAccessorCachingPolicyCacheOnly: {
            [completionOperation addDependency:cachedFormDescriptionOperation];
            [self.processingQueue addOperations:@[cachedFormDescriptionOperation,
                                                  completionOperation]
                              waitUntilFinished:NO];
        }
            break;
            
        case ASDKServiceDataAccessorCachingPolicyAPIOnly: {
            [completionOperation addDependency:remoteFormDescriptionOperation];
            [self.processingQueue addOperations:@[remoteFormDescriptionOperation,
                                                  completionOperation]
                              waitUntilFinished:NO];
        }
            break;
            
        case ASDKServiceDataAccessorCachingPolicyHybrid: {
            [remoteFormDescriptionOperation addDependency:cachedFormDescriptionOperation];
            [storeInCacheOperation addDependency:remoteFormDescriptionOperation];
            [completionOperation addDependency:storeInCacheOperation];
            [self.processingQueue addOperations:@[cachedFormDescriptionOperation,
                                                  remoteFormDescriptionOperation,
                                                  storeInCacheOperation,
                                                  completionOperation]
                              waitUntilFinished:NO];
        }
            break;
            
        default: break;
    }
}

- (ASDKAsyncBlockOperation *)remoteFormDescriptionOperationForProcessDefinitionID:(NSString *)processDefinitionID {
    if ([self.delegate respondsToSelector:@selector(dataAccessorDidStartFetchingRemoteData:)]) {
        [self.delegate dataAccessorDidStartFetchingRemoteData:self];
    }
    
    __weak typeof(self) weakSelf = self;
    ASDKAsyncBlockOperation *remoteFormDescriptionOperation = [ASDKAsyncBlockOperation blockOperationWithBlock:^(ASDKAsyncBlockOperation *operation) {
        __strong typeof(self) strongSelf = weakSelf;
        
        [strongSelf.formNetworkService startFormForProcessDefinitionID:processDefinitionID
                                                       completionBlock:^(ASDKModelFormDescription *formDescription, NSError *error) {
                                                           if (operation.isCancelled) {
                                                               [operation complete];
                                                               return;
                                                           }
                                                           
                                                           ASDKDataAccessorResponseModel *responseModel =
                                                           [[ASDKDataAccessorResponseModel alloc] initWithModel:formDescription
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
    
    return remoteFormDescriptionOperation;
}

- (ASDKAsyncBlockOperation *)cachedFormDescriptionOperationforProcessDefinitionID:(NSString *)processDefinitionID {
    __weak typeof(self) weakSelf = self;
    ASDKAsyncBlockOperation *cachedFormDescriptionOperation = [ASDKAsyncBlockOperation blockOperationWithBlock:^(ASDKAsyncBlockOperation *operation) {
        __strong typeof(self) strongSelf = weakSelf;
        
        [strongSelf.formCacheService
         fetchProcessDefinitionFormDescriptionForProcessDefinitionID:processDefinitionID
         withCompletionBlock:^(ASDKModelFormDescription *formDescription, NSError *error) {
             if (operation.isCancelled) {
                 [operation complete];
                 return;
             }
             
             if (!error) {
                 ASDKLogVerbose(@"Form description fetched successfully from cache for process definition: %@", processDefinitionID);
                 
                 ASDKDataAccessorResponseModel *response =
                 [[ASDKDataAccessorResponseModel alloc] initWithModel:formDescription
                                                         isCachedData:YES
                                                                error:error];
                 if (weakSelf.delegate) {
                     [weakSelf.delegate dataAccessor:weakSelf
                                 didLoadDataResponse:response];
                 }
             } else {
                 ASDKLogError(@"An error occured while fetching cached form description for process definition: %@. Reason: %@", processDefinitionID, error.localizedDescription);
             }
             
             [operation complete];
         }];
    }];
    
    return cachedFormDescriptionOperation;
}

- (ASDKAsyncBlockOperation *)formDescriptionStoreInCacheOperationForProcessDefinitionID:(NSString *)processDefinitionID {
    __weak typeof(self) weakSelf = self;
    ASDKAsyncBlockOperation *storeInCacheOperation = [ASDKAsyncBlockOperation blockOperationWithBlock:^(ASDKAsyncBlockOperation *operation) {
        __strong typeof(self) strongSelf = weakSelf;
        
        ASDKAsyncBlockOperation *dependencyOperation = (ASDKAsyncBlockOperation *)operation.dependencies.firstObject;
        ASDKDataAccessorResponseModel *remoteResponse = dependencyOperation.result;
        
        if (remoteResponse.model) {
            [strongSelf.formCacheService cacheProcessDefinitionFormDescription:remoteResponse.model
                                                        forProcessDefinitionID:processDefinitionID
                                                           withCompletionBlock:^(NSError *error) {
                                                               if (operation.isCancelled) {
                                                                   [operation complete];
                                                                   return;
                                                               }
                                                               
                                                               if (!error) {
                                                                   ASDKLogVerbose(@"Form description for process definition: %@ cached successfully", processDefinitionID);
                                                                   [weakSelf.formCacheService saveChanges];
                                                               } else {
                                                                   ASDKLogError(@"Encountered an error while caching form description for process definition: %@", processDefinitionID);
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
    [self.formNetworkService cancelAllNetworkOperations];
}


#pragma mark -
#pragma mark Private interface

- (ASDKFormNetworkServices *)formNetworkService {
    return (ASDKFormNetworkServices *)self.networkService;
}

- (ASDKFormCacheService *)formCacheService {
    return (ASDKFormCacheService *)self.cacheService;
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

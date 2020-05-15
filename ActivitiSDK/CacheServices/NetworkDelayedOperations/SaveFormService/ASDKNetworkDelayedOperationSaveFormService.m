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

#import "ASDKNetworkDelayedOperationSaveFormService.h"

// Constants
#import "ASDKLogConfiguration.h"

// Operations
#import "ASDKAsyncBlockOperation.h"

// Services
#import "ASDKFormDataAccessor.h"

// Managers
#import "ASDKReachabilityManager.h"
#import "ASDKKVOManager.h"
#import "ASDKDataAccessorOperation.h"

// Models
#import "ASDKDataAccessorResponseFormFieldValueRepresentations.h"
#import "ASDKDataAccessorResponseConfirmation.h"

typedef NS_ENUM(NSInteger, ASDKNetworkReachabilityOperationType) {
    ASDKNetworkReachabilityOperationTypeUndefined = -1,
    ASDKNetworkReachabilityOperationTypeSubmitSavedForms = 1
};

typedef NS_ENUM(NSInteger, ASDKNetworkReachabilityUserInfoParamType) {
    ASDKNetworkReachabilityUserInfoParamTypeUndefined = -1,
    ASDKNetworkReachabilityUserInfoParamTypeOperation,
    ASDKNetworkReachabilityUserInfoParamTypeID,
    ASDKNetworkReachabilityUserInfoParamTypeRetry,
    ASDKNetworkReachabilityUserInfoParamTypeFormFieldValueRequestRepresentation
};

@interface ASDKNetworkDelayedOperationSaveFormService () <ASDKDataAccessorDelegate,
                                                  ASDKDataAccessorOperationProtocol>

// Service aggregation
@property (strong, nonatomic) ASDKFormDataAccessor   *fetchFormFieldValueDataAccessor;
@property (strong, nonatomic) ASDKFormDataAccessor   *deleteFormFieldValueDataAccessor;

// Internal state
@property (strong, nonatomic) ASDKReachabilityManager *reachabilityManager;
@property (strong, nonatomic) ASDKKVOManager          *kvoManager;
@property (strong, nonatomic) NSOperationQueue        *processingQueue;
@property (strong, nonatomic) NSMutableArray          *taskIDs;
@property (strong, nonatomic) NSMutableArray          *operationsToRetry;

@end

@implementation ASDKNetworkDelayedOperationSaveFormService

- (instancetype)init {
    self = [super init];
    if (self) {
        _processingQueue = [NSOperationQueue new];
        _processingQueue.maxConcurrentOperationCount = 1;
        _taskIDs = [NSMutableArray array];
        _operationsToRetry = [NSMutableArray array];
        _reachabilityManager = [ASDKReachabilityManager new];
        _fetchFormFieldValueDataAccessor = [[ASDKFormDataAccessor alloc] initWithDelegate:self];
        _deleteFormFieldValueDataAccessor = [[ASDKFormDataAccessor alloc] initWithDelegate:self];
        
        [self handleBindingsForNetworkConnectivity];
    }
    return self;
}

- (void)dealloc {
    [self.kvoManager removeObserver:_reachabilityManager
                         forKeyPath:NSStringFromSelector(@selector(networkReachabilityStatus))];
    [self.kvoManager removeObserver:_processingQueue
                         forKeyPath:NSStringFromSelector(@selector(operationCount))];
}


#pragma mark -
#pragma mark Private interface

- (void)runNetworkConnectivityRestorationChecks {
    // Check for saved forms submitted for upload and try to reupload them
    [self.fetchFormFieldValueDataAccessor fetchAllFormFieldValueRequestRepresentations];
}

- (void)removeSaveFormFieldValues {
    [self.deleteFormFieldValueDataAccessor removeStalledFormFieldValueRepresentationsForTaskIDs:self.taskIDs];
}


#pragma mark -
#pragma mark ASDKDataAccessorDelegate

- (void)dataAccessor:(id<ASDKServiceDataAccessorProtocol>)dataAccessor
 didLoadDataResponse:(ASDKDataAccessorResponseBase *)response {
    if (self.fetchFormFieldValueDataAccessor == dataAccessor) {
        [self handleFetchFormFieldValueDataAccessorResponse:response];
    }
}

- (void)dataAccessorDidFinishedLoadingDataResponse:(id<ASDKServiceDataAccessorProtocol>)dataAccessor {
    if (self.deleteFormFieldValueDataAccessor == dataAccessor) {
        [self.taskIDs removeAllObjects];
        [self handleRetryForFailedOperations];
    }
}


#pragma mark -
#pragma mark ASDKDataAccessorOperationProtocol

- (void)dataAccessorOperation:(ASDKDataAccessorOperation *)operation
             withDataAccessor:(id<ASDKServiceDataAccessorProtocol>)dataAccessor
          didLoadDataResponse:(ASDKDataAccessorResponseBase *)response {
    if ([operation.userInfo[@(ASDKNetworkReachabilityUserInfoParamTypeOperation)] isEqual:@(ASDKNetworkReachabilityOperationTypeSubmitSavedForms)]) {
        [self handleSaveFormOperation:operation
                     withDataAccessor:dataAccessor
                         withResponse:response];
    }
}

- (void)dataAccessorOperation:(ASDKDataAccessorOperation *)operation
didFinishedLoadingDataResponse:(id<ASDKServiceDataAccessorProtocol>)dataAccessor {
}


#pragma mark -
#pragma mark Operation handlers

- (void)handleFetchFormFieldValueDataAccessorResponse:(ASDKDataAccessorResponseBase *)response {
    ASDKDataAccessorResponseFormFieldValueRepresentations *formFieldValueRepresentationsResponse = (ASDKDataAccessorResponseFormFieldValueRepresentations *)response;
    
    if (!formFieldValueRepresentationsResponse.error) {
        NSArray *formFieldValueRepresentationArr = formFieldValueRepresentationsResponse.formFieldValueRepresentations;
        NSArray *taskIDsArr = formFieldValueRepresentationsResponse.taskIDs;
        
        for (int idx = 0; idx < formFieldValueRepresentationArr.count; idx++) {
            ASDKFormFieldValueRequestRepresentation *formFieldValueRequestRepresentation = formFieldValueRepresentationArr[idx];
            NSString *taskID = taskIDsArr[idx];
            
            ASDKFormDataAccessor *saveFormDataAccessor = [[ASDKFormDataAccessor alloc] initWithDelegate:self];
            ASDKDataAccessorOperation *dataAccessorOperation = [[ASDKDataAccessorOperation alloc] initWithDataAccessor:saveFormDataAccessor
                                                                                                              delegate:self];
            saveFormDataAccessor.delegate = dataAccessorOperation;
            dataAccessorOperation.userInfo =
            @{@(ASDKNetworkReachabilityUserInfoParamTypeOperation) : @(ASDKNetworkReachabilityOperationTypeSubmitSavedForms),
              @(ASDKNetworkReachabilityUserInfoParamTypeID) : taskID,
              @(ASDKNetworkReachabilityUserInfoParamTypeFormFieldValueRequestRepresentation) : formFieldValueRequestRepresentation};

            [self.processingQueue addOperation:dataAccessorOperation];
            [saveFormDataAccessor saveFormForTaskID:taskID
            withFormFieldValueRequestRepresentation:formFieldValueRequestRepresentation];
        }
    }
}

- (void)handleSaveFormOperation:(ASDKDataAccessorOperation *)operation
               withDataAccessor:(id<ASDKServiceDataAccessorProtocol>)dataAccessor
                   withResponse:(ASDKDataAccessorResponseBase *)response {
    ASDKDataAccessorResponseConfirmation *confirmation = (ASDKDataAccessorResponseConfirmation *)response;
    if (confirmation.isConfirmation) {
        [self.taskIDs addObject:operation.userInfo[@(ASDKNetworkReachabilityUserInfoParamTypeID)]];
    } else {
        if ([operation.userInfo[@(ASDKNetworkReachabilityUserInfoParamTypeRetry)] boolValue]) {
            [self.taskIDs addObject:operation.userInfo[@(ASDKNetworkReachabilityUserInfoParamTypeID)]];
        } else {
            NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:operation.userInfo];
            [dictionary setObject:@(YES)
                           forKey:@(ASDKNetworkReachabilityUserInfoParamTypeRetry)];
            operation.userInfo = dictionary;
            [self.operationsToRetry addObject:operation];
        }
    }
}

- (void)handleRetryForFailedOperations {
    for (ASDKDataAccessorOperation *failedOperation in self.operationsToRetry) {
        NSString *taskID = failedOperation.userInfo[@(ASDKNetworkReachabilityUserInfoParamTypeID)];
        ASDKFormFieldValueRequestRepresentation *formFieldValueRequestRepresentation =
        failedOperation.userInfo[@(ASDKNetworkReachabilityUserInfoParamTypeFormFieldValueRequestRepresentation)];
        ASDKFormDataAccessor *dataAccessor = (ASDKFormDataAccessor *)failedOperation.dataAccessor;
        
        ASDKDataAccessorOperation *retryOperation = [[ASDKDataAccessorOperation alloc] initWithDataAccessor:dataAccessor
                                                                                                          delegate:self];
        dataAccessor.delegate = retryOperation;
        retryOperation.userInfo = failedOperation.userInfo;
        
        [self.processingQueue addOperation:retryOperation];
        [dataAccessor saveFormForTaskID:taskID
withFormFieldValueRequestRepresentation:formFieldValueRequestRepresentation];
    }
    
    [self.operationsToRetry removeAllObjects];
}


#pragma mark -
#pragma mark KVO Bindings

- (void)handleBindingsForNetworkConnectivity {
    self.kvoManager = [ASDKKVOManager managerWithObserver:self];
    
    __weak typeof(self) weakSelf = self;
    [self.kvoManager observeObject:self.reachabilityManager
                        forKeyPath:NSStringFromSelector(@selector(networkReachabilityStatus))
                           options:NSKeyValueObservingOptionNew
                             block:^(id observer, id object, NSDictionary *change) {
                                 __strong typeof(self) strongSelf = weakSelf;

                                 ASDKNetworkReachabilityStatus networkReachabilityStatus = [change[NSKeyValueChangeNewKey] boolValue];
                                 if (ASDKNetworkReachabilityStatusReachableViaWWANOrWifi == networkReachabilityStatus) {
                                     [strongSelf runNetworkConnectivityRestorationChecks];
                                 }
                             }];
    
    [self.kvoManager observeObject:self.processingQueue
                        forKeyPath:NSStringFromSelector(@selector(operationCount))
                           options:NSKeyValueObservingOptionNew
                             block:^(id observer, id object, NSDictionary *change) {
                                 __strong typeof(self) strongSelf = weakSelf;
                                 
                                 NSUInteger operationCount = [change[NSKeyValueChangeNewKey] unsignedIntegerValue];
                                 if (!operationCount) {
                                     [strongSelf removeSaveFormFieldValues];
                                 }
    }];
}

@end

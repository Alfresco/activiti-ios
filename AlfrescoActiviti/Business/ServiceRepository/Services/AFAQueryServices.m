/*******************************************************************************
 * Copyright (C) 2005-2020 Alfresco Software Limited.
 *
 * This file is part of the Alfresco Activiti Mobile iOS App.
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

#import "AFAQueryServices.h"
@import ActivitiSDK;

// Models
#import "AFAGenericFilterModel.h"

@interface AFAQueryServices () <ASDKDataAccessorDelegate>

// Active task list
@property (strong, nonatomic) ASDKQuerryDataAccessor            *fetchTaskListDataAccessor;
@property (copy, nonatomic) AFAQuerryTaskListCompletionBlock    taskListCompletionBlock;
@property (copy, nonatomic) AFAQuerryTaskListCompletionBlock    taskListCachedResultsBlock;

@end

@implementation AFAQueryServices


#pragma mark -
#pragma mark Public interface

- (void)requestTaskListWithFilter:(AFAGenericFilterModel *)taskFilter
                  completionBlock:(AFAQuerryTaskListCompletionBlock)completionBlock
                    cachedResults:(AFAQuerryTaskListCompletionBlock)cacheCompletionBlock {
    NSParameterAssert(completionBlock);
    
    self.taskListCompletionBlock = completionBlock;
    self.taskListCachedResultsBlock = cacheCompletionBlock;
    
    // Create request representation for the filter model
    ASDKTaskListQuerryRequestRepresentation *queryRequestRepresentation = [ASDKTaskListQuerryRequestRepresentation new];
    queryRequestRepresentation.jsonAdapterType = ASDKRequestRepresentationJSONAdapterTypeExcludeNilValues;
    queryRequestRepresentation.processInstanceID = taskFilter.processInstanceID;
    queryRequestRepresentation.requestTaskState = (ASDKTaskListQuerryStateType)taskFilter.state;
    
    self.fetchTaskListDataAccessor = [[ASDKQuerryDataAccessor alloc] initWithDelegate:self];
    [self.fetchTaskListDataAccessor fetchTasksWithFilter:queryRequestRepresentation];
}


#pragma mark -
#pragma mark ASDKDataAccessorDelegate

- (void)dataAccessor:(id<ASDKServiceDataAccessorProtocol>)dataAccessor
 didLoadDataResponse:(ASDKDataAccessorResponseBase *)response {
    if (self.fetchTaskListDataAccessor == dataAccessor) {
        [self handleFetchActiveTaskListDataAccessorResponse:response];
    }
}

- (void)dataAccessorDidFinishedLoadingDataResponse:(id<ASDKServiceDataAccessorProtocol>)dataAccessor {
}


#pragma mark -
#pragma mark Private interface

- (void)handleFetchActiveTaskListDataAccessorResponse:(ASDKDataAccessorResponseBase *)response {
    ASDKDataAccessorResponseCollection *taskListResponse = (ASDKDataAccessorResponseCollection *)response;
    NSArray *taskList = taskListResponse.collection;
    
    __weak typeof(self) weakSelf = self;
    if (!taskListResponse.error) {
        if (taskListResponse.isCachedData) {
            dispatch_async(dispatch_get_main_queue(), ^{
                __strong typeof(self) strongSelf = weakSelf;
                
                if (strongSelf.taskListCachedResultsBlock) {
                    strongSelf.taskListCachedResultsBlock(taskList, nil, taskListResponse.paging);
                    strongSelf.taskListCachedResultsBlock = nil;
                }
            });
            
            return;
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(self) strongSelf = weakSelf;
        
        if (strongSelf.taskListCompletionBlock) {
            strongSelf.taskListCompletionBlock(taskList, taskListResponse.error, taskListResponse.paging);
            strongSelf.taskListCompletionBlock = nil;
        }
    });
}

@end

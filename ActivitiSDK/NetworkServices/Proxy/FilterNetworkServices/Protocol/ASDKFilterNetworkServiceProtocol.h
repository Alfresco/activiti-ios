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

#import <Foundation/Foundation.h>

@class ASDKModelPaging,
ASDKModelFilter,
ASDKFilterListRequestRepresentation,
ASDKFilterCreationRequestRepresentation;

typedef void  (^ASDKFilterListCompletionBlock) (NSArray *filterList, NSError *error, ASDKModelPaging *paging);
typedef void  (^ASDKFilterModelCompletionBlock) (ASDKModelFilter *filter, NSError *error);

@protocol ASDKFilterNetworkServiceProtocol <NSObject>

/**
 *  Fetches and returns a list of task filters registered with the Activiti server for the
 *  authenticated user.
 *
 *  @param completionBlock Completion block providing the filter list, an optional error 
 *                         reason and pagination information
 */
- (void)fetchTaskFilterListWithCompletionBlock:(ASDKFilterListCompletionBlock)completionBlock;

/**
 *  Fetches and returns a list of task filters registered with the Activiti server for the 
 *  authenticated user and associated with an application.
 *
 *  @param filter          Filter object describing which subset of the filter list 
 *                         collection should be fetched
 *  @param completionBlock Completion block providing the filter list, an optional error
 *                         reason and pagination information
 */
- (void)fetchTaskFilterListWithFilter:(ASDKFilterListRequestRepresentation *)filter
                  withCompletionBlock:(ASDKFilterListCompletionBlock)completionBlock;

/**
 *  Fetches and returns a list of process instance filters registered with the Activiti server for 
 *  the authenticated user.
 *
 *  @param completionBlock Completion block providing the filter list, an optional error
 *                         reason and pagination information
 */
- (void)fetchProcessInstanceFilterListWithCompletionBlock:(ASDKFilterListCompletionBlock)completionBlock;

/**
 *  Fetches and returns via the completion block a list of process instance defined filters
 *  corresponding to the specified app.
 *
 *  @param filter          Filter object describing which subset of the filter list
 *                         collection should be fetched
 *  @param completionBlock Completion block providing the filter list, an optional error
 *                         reason and pagination information
 */
- (void)fetchProcessInstanceFilterListWithFilter:(ASDKFilterListRequestRepresentation *)filter
                             withCompletionBlock:(ASDKFilterListCompletionBlock)completionBlock;

/**
 *  Creates a task list filter given a filter request representation and returns via the completion
 *  block the filter description.
 *
 *  @param filter          Filter representation describing properties of the filter to be created
 *  @param completionBlock Completion block providing the filter description and an optional error
 *                         reason
 */
- (void)createUserTaskFilterWithRepresentation:(ASDKFilterCreationRequestRepresentation *)filter
                           withCompletionBlock:(ASDKFilterModelCompletionBlock)completionBlock;

/**
 *  Creates a process instance list filter given a filter request representation and returns via the
 *  completion block the filter description.
 *
 *  @param filter          Filter representation describing properties of the filter to be created
 *  @param completionBlock Completion block providing the filter description and an optional error
 *                         reason
 */
- (void)createProcessInstanceTaskFilterWithRepresentation:(ASDKFilterCreationRequestRepresentation *)filter
                                      withCompletionBlock:(ASDKFilterModelCompletionBlock)completionBlock;

/**
 *  Cancells all queued or running network operations
 */
- (void)cancelAllNetworkOperations;

@end

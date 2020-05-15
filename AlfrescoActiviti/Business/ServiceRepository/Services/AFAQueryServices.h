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

#import <Foundation/Foundation.h>

@class ASDKModelPaging,
AFAGenericFilterModel;

typedef void  (^AFAQuerryTaskListCompletionBlock) (NSArray *taskList, NSError *error, ASDKModelPaging *paging);

@interface AFAQueryServices : NSObject

/**
 * Performs a request for tasks with properties defined within the filter model.
 * The underlaying implementation is using a filter representation to call the
 * querry API.
 *
 * @param taskFilter            Filter object describing what properties should be considered
 * @param completionBlock       Completion block providing the task list, an optional error reason
 *                              and pagination information
 * @param cacheCompletionBlock  Completion block providing a cached reference to the task list,
 *                              an optional error and pagination information
 */
- (void)requestTaskListWithFilter:(AFAGenericFilterModel *)taskFilter
                  completionBlock:(AFAQuerryTaskListCompletionBlock)completionBlock
                    cachedResults:(AFAQuerryTaskListCompletionBlock)cacheCompletionBlock;

@end

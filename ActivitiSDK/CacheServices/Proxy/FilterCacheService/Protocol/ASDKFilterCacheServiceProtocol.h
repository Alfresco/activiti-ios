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
#import "ASDKCoreDataCacheService.h"

@class ASDKFilterListRequestRepresentation, ASDKModelPaging;

typedef void  (^ASDKCacheServiceFilterListCompletionBlock) (NSArray *filterList, NSError *error, ASDKModelPaging *paging);

@protocol ASDKFilterCacheServiceProtocol <NSObject>


/**
 * Caches provided task filter list and reports the operation succes over a completion
 * block.
 *
 * @param filterList      List of task filters to be cached
 * @param completionBlock Completion block indicating the succes of the operation
 */
- (void)cacheDefaultTaskFilterList:(NSArray *)filterList
               withCompletionBlock:(ASDKCacheServiceCompletionBlock)completionBlock;

/**
 * Caches provided task filter list by leveraging information from the filter that was
 * provided to the actual network request and reports the operation success over a 
 * completion block. The filter is provided to identify to which application the
 * task filter list is affiliated.
 *
 * @param filterList        List of task filters to be cached
 * @param filter            Filter object describing the membership of task filters in 
 *                          relation to an application
 * @param completionBlock   Completion block indicating the success of the operation
 */
- (void)cacheTaskFilterList:(NSArray *)filterList
                usingFilter:(ASDKFilterListRequestRepresentation *)filter
        withCompletionBlock:(ASDKCacheServiceCompletionBlock)completionBlock;

/**
 * Fetches the default task filter list and reports the results via a completion block.
 *
 * @param completionBlock   Completion block providing a list of model objects, paging
 *                          information and an optional error reason
 */
- (void)fetchDefaultTaskFilterList:(ASDKCacheServiceFilterListCompletionBlock)completionBlock;

/**
 * Fetches the task filter list associated with a specific application by leveraging the
 * application ID passed in the filter object. Results are reported back via a completion
 * block.
 *
 * @param completionBlock   Completion block providing a list of model objects, paging
 *                          information and an optional error reason
 * @param filter            Filter object containing the ID of the application the filter 
 *                          list is retrieved for
 */
- (void)fetchTaskFilterList:(ASDKCacheServiceFilterListCompletionBlock)completionBlock
                usingFilter:(ASDKFilterListRequestRepresentation *)filter;

/**
 * Caches provided process instance filter list by leveraging information from the filter
 * that was provided to the actual network request and reports the operation success over
 * a completion block. The filter is provided to identify to which application the task
 * filter list is affiliated.
 *
 * @param filterList      List of process instance filters to be cached
 * @param completionBlock Completion block indicating the success of the operation
 */
- (void)cacheDefaultProcessInstanceFilterList:(NSArray *)filterList
                          withCompletionBlock:(ASDKCacheServiceCompletionBlock)completionBlock;


/**
 * Caches provided process instance filter list by leveraging information from the filter
 * that was provided to the actual network request and reports the operation success over a
 * completion block. The filter is provided to identify to which application the
 * process instance filter list is affiliated.
 *
 * @param filterList        List of process instance filters to be cached
 * @param filter            Filter object describing the membership of proces instance filters
 *                          in relation to an application
 * @param completionBlock   Completion block indicating the success of the operation
 */
- (void)cacheProcessInstanceFilterList:(NSArray *)filterList
                           usingFilter:(ASDKFilterListRequestRepresentation *)filter
                   withCompletionBlock:(ASDKCacheServiceCompletionBlock)completionBlock;

/**
 * Fetches the default process instance filter list and reports the results via a completion
 * block.
 *
 * @param completionBlock   Completion block providing a list of model objects, paging
 *                          information and an optional error reason
 */
- (void)fetchDefaultProcessInstanceFilterList:(ASDKCacheServiceFilterListCompletionBlock)completionBlock;

/**
 * Fetches the process instance filter list associated with a specific application by leveraging
 * the application ID passed in the filter object. Results are reported back via a completion
 * block.
 *
 * @param completionBlock   Completion block providing a list of model objects, paging
 *                          information and an optional error reason
 * @param filter            Filter object containing the ID of the application the filter
 *                          list is retrieved for
 */
- (void)fetchProcessInstanceFilterList:(ASDKCacheServiceFilterListCompletionBlock)completionBlock
                           usingFilter:(ASDKFilterListRequestRepresentation *)filter;

@end

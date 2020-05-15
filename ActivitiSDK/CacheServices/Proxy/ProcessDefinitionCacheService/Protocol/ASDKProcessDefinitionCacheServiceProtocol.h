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

@class ASDKModelPaging;

typedef void (^ASDKCacheServiceProcessDefinitionListCompletionBlock) (NSArray *processDefinitions, NSError *error, ASDKModelPaging *paging);

@protocol ASDKProcessDefinitionCacheServiceProtocol <NSObject>

/**
 * Caches provided process definition list for the specified app ID and reports back
 * the operation success over a completion block.
 *
 * @param processDefinitionList List of process definitions to be cached
 * @param applicationID         Application ID describing the membership of process definition
 *                              items
 * @param completionBlock       Completion block indicating the success of the operation
 */
- (void)cacheProcessDefinitionList:(NSArray *)processDefinitionList
                          forAppID:(NSString *)applicationID
               withCompletionBlock:(ASDKCacheServiceCompletionBlock)completionBlock;

/**
 * Fetches and reports via a completion block the process definition IDs for the specified ID.
 *
 * @param applicationID     Application ID for which the process definition list is requested
 * @param completionBlock   Completion block providing a list of process definitions, an optional
 *                          error reason and paging information
 */
- (void)fetchProcessDefinitionListForAppID:(NSString *)applicationID
                       withCompletionBlock:(ASDKCacheServiceProcessDefinitionListCompletionBlock)completionBlock;

@end

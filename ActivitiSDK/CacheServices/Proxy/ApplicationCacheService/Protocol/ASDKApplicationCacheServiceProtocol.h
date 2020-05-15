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

typedef void (^ASDKCacheServiceAppCompletionBlock) (NSArray *appDefinitionList, NSError *error);

@protocol ASDKApplicationCacheServiceProtocol <NSObject>


/**
 * Caches provided runtime application definitions and reports the operation success
 * over a completion block.
 *
 * @param appDefinitionList   List of application definitions to be cached
 * @param completionBlock     Completion block indicating the success of the operation
 */
- (void)cacheRuntimeApplicationDefinitions:(NSArray *)appDefinitionList
                      withtCompletionBlock:(ASDKCacheServiceCompletionBlock)completionBlock;


/**
 * Fetches and reports via a completion block the runtime app definitions the current user
 * is allowed access to.
 *
 * @param completionBlock   Completion block providing a list of model objects and an optional
 *                          error reason
 */
- (void)fetchRuntimeApplicationDefinitions:(ASDKCacheServiceAppCompletionBlock)completionBlock;

@end

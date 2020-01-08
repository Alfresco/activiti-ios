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

#import <Foundation/Foundation.h>

@class ASDKModelPaging;

typedef void  (^ASDKCacheServiceIntegrationAccountListCompletionBlock)  (NSArray *accounts, NSError *error, ASDKModelPaging *paging);

@protocol ASDKIntegrationCacheServiceProtocol <NSObject>

/**
 * Caches provided integration service list and reports back the operation success
 * over a completion block.
 *
 * @param integrationList List of integration service list to be cached
 * @param completionBlock Completion block indicating the success of the operation
 */
- (void)cacheIntegrationList:(NSArray *)integrationList
         withCompletionBlock:(ASDKCacheServiceCompletionBlock)completionBlock;

/**
 * Fetches and reports via a completion block the integration service list.
 *
 * @param completionBlock   Completion block providing a list of integration services,
 *                          pagination information and an optional error reason
 */
- (void)fetchIntegrationListWithCompletionBlock:(ASDKCacheServiceIntegrationAccountListCompletionBlock)completionBlock;

@end

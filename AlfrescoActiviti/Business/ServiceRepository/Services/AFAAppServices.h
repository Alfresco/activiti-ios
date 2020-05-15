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

@class ASDKModelPaging;

typedef void  (^AFAAppServicesRuntimeAppDefinitionsCompletionBlock) (NSArray *appDefinitionsList, NSError *error, ASDKModelPaging *paging);

@interface AFAAppServices : NSObject

/**
 * Performs a request to fetch and return via the completion block a list of runtime app
 * definitions, the same list that you would see on the Activiti WEB landing page after login.
 *
 * @param completionBlock       Completion block providing the runtime app definition list an optional
 *                              error reason and pagination information
 * @param cacheCompletionBlock  Completion block providing a cached reference to the runtime app definition
 *                              list and an optional error reason
 */
- (void)requestRuntimeAppDefinitionsWithCompletionBlock:(AFAAppServicesRuntimeAppDefinitionsCompletionBlock)completionBlock
                                          cachedResults:(AFAAppServicesRuntimeAppDefinitionsCompletionBlock)cacheCompletionBlock;

/**
 * Cancels all requests related to app services activity
 */
- (void)cancellAppNetworkRequests;

@end

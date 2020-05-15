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
ASDKFilterRequestRepresentation;

typedef void  (^ASDKProcessDefinitionListCompletionBlock) (NSArray *processDefinitions, NSError *error, ASDKModelPaging *paging);

@protocol ASDKProcessDefinitionNetworkServiceProtocol <NSObject>

/**
 *  Fetches and returns via the completion block a list of process definitions.
 *
 *  @param completionBlock Completion block providing a process definition list, an optional
 *                         error reason and paging information
 */
- (void)fetchProcessDefinitionListWithCompletionBlock:(ASDKProcessDefinitionListCompletionBlock)completionBlock;

/**
 *  Fetches and returns via the completion block a list of process definitions 
 *  matching the provided app ID.
 *
 *  @param appID           When provided, only return process definitions belonging to a certain app
 *  @param completionBlock Completion block providing a process definition list, an optional
 *                         error reason and paging information
 */
- (void)fetchProcessDefinitionListForAppID:(NSString *)appID
                           completionBlock:(ASDKProcessDefinitionListCompletionBlock)completionBlock;

/**
 *  Cancells all queued or running network operations
 */
- (void)cancelAllTaskNetworkOperations;

@end

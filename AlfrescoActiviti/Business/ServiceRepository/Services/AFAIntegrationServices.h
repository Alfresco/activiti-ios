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
ASDKIntegrationNodeContentRequestRepresentation,
ASDKModelContent;

typedef void  (^AFAIntegrationAccountListCompletionBlock) (NSArray *accounts, NSError *error, ASDKModelPaging *paging);
typedef void  (^AFAIntegrationContentUploadCompletionBlock)(ASDKModelContent *contentModel, NSError *error);

@interface AFAIntegrationServices : NSObject

/**
 *  Performs a request for the list of external integration service accounts.
 *
 *  @param completionBlock Completion block providing an integration account list, an optional
 *                         error reason and paging information
 */
- (void)requestIntegrationAccountsWithCompletionBlock:(AFAIntegrationAccountListCompletionBlock)completionBlock
                                        cachedResults:(AFAIntegrationAccountListCompletionBlock)cacheCompletionBlock;

/**
 *  Performs a request to upload content for a specified task from an external integration service that is described inside the
 *  provided request representation and reports back via a completion block the status of the upload.
 *
 *  @param taskID                                     ID of the task for which the content is uploaded
 *  @param uploadIntegrationContentWithRepresentation Request representation object describing the content to be
 *                                                    uploaded like the source and the sourceID
 *  @param completionBlock                            Completion block providing a reference for the uploaded
 *                                                    model and an optional error reason.
 */
- (void)requestUploadIntegrationContentForTaskID:(NSString *)taskID
                              withRepresentation:(ASDKIntegrationNodeContentRequestRepresentation *)nodeContentRepresentation
                                  completionBloc:(AFAIntegrationContentUploadCompletionBlock)completionBlock;

@end

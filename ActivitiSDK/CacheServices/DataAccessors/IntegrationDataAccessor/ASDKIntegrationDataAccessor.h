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

#import "ASDKDataAccessor.h"

@class ASDKIntegrationNodeContentRequestRepresentation;

@interface ASDKIntegrationDataAccessor : ASDKDataAccessor

/**
 * Requests a list of integration accounts for the current logged in user
 * and reports network or cached data through the designated data accessor
 * delegate.
 */
- (void)fetchIntegrationAccounts;

/**
 * Uploads content for a specified task from an external integration service
 * and reports the created content model through the designated data accessor
 * delegate.
 *
 @param taskID ID of the task for which the content is uploaded
 @param nodeContentRepresentation Request representation object describing the content
 *                                to be uploaded
 */
- (void)uploadIntegrationContentForTaskID:(NSString *)taskID
            withContentNodeRepresentation:(ASDKIntegrationNodeContentRequestRepresentation *)nodeContentRepresentation;

@end

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

@interface ASDKFilterDataAccessor : ASDKDataAccessor

/**
 * Requests the default defined task filter list in the APS installation that are
 * not associated with any application and reports network or cached data through
 * the designated data accessor delegate.
 */
- (void)fetchDefaultTaskFilterList;

/**
 * Requests the task filter list that is associated with an application and reports
 * network or cached data through the desinated data accessor delegate.
 *
 * @param appID Application ID for which the filter list is requested.
 */
- (void)fetchTaskFilterListForApplicationID:(NSString *)appID;

/**
 * Requests the default defined process instance filter list in the APS installation
 * that are not associated with any application and reports network or cached data
 * through the designated data accessor delegate.
 */
- (void)fetchDefaultProcessInstanceFilterList;

/**
 * Requests the process instance filter list that is associated with an application and
 * reports network or cached data through the designated data accessor delegate.

 @param appID Application ID for which the filter list is requested.
 */
- (void)fetchProcessInstanceFilterListForApplicationID:(NSString *)appID;

/**
 * Cancels ongoing operations for the current data accessor.
 */
- (void)cancelOperations;

@end

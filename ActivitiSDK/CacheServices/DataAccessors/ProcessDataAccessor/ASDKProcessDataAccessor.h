/*******************************************************************************
 * Copyright (C) 2005-2017 Alfresco Software Limited.
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

@class ASDKFilterRequestRepresentation;

@interface ASDKProcessDataAccessor : ASDKDataAccessor

/**
 * Requests a list of process instances for the current logged in user conforming to
 * the properties of a provided filter and reports network or cached data through the
 * designated data accessor delegate.
 *
 * @param filter Filter object describing which subset of the task list should be fetched
 */
- (void)fetchProcessInstancesWithFilter:(ASDKFilterRequestRepresentation *)filter;

/**
 * Requests the details of a process instance and reports network or cached data through
 * the designated data accessor delegate.
 *
 * @param processInstanceID The ID of the process instance for which the details are requested
 */
- (void)fetchProcessInstanceDetailsForProcessInstanceID:(NSString *)processInstanceID;

/**
 * Cancels ongoing operations for the current data accessor.
 */
- (void)cancelOperations;

@end
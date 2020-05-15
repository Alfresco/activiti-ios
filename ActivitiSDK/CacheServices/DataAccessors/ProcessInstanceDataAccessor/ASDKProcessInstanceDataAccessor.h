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

@class ASDKFilterRequestRepresentation, ASDKStartProcessRequestRepresentation;

@interface ASDKProcessInstanceDataAccessor : ASDKDataAccessor

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
 * Requests the content associated with a process instance and reports network or cached data
 * through the designated data accessor delegate.
 *
 * @param processInstanceID The ID of the process instance for which the details are requested
 */
- (void)fetchProcessInstanceContentForProcessInstanceID:(NSString *)processInstanceID;

/**
 * Deletes a specific process instance and reports the result through the designated
 * data accessor delegate.
 *
 * @param processInstanceID The ID of the process instance which is to be deleted
 */
- (void)deleteProcessInstanceWithID:(NSString *)processInstanceID;

/**
 * Requests a list of process instance comments for a specific process instance and reports
 * the result through the designated data accessor delegate.
 *
 @param processInstanceID The ID of the process instance for which the comments are requested
 */
- (void)fetchProcessInstanceCommentsForProcessInstanceID:(NSString *)processInstanceID;

/**
* Creates a comment for the specified process instance and reports the result through the designated
* data accessor delegate.
*
* @param comment   Comment to be created
* @param taskID    The ID of the process instance for which the comment is to be created
*/
- (void)createComment:(NSString *)comment
 forProcessInstanceID:(NSString *)processInstanceID;

/**
 * Requests the audit log that is associated with a process instance an reports network or cached data
 * through the designated data accessor delegate.
 *
 * @param processInstanceID The ID of the process instance for which the download audit is requested
 */
- (void)downloadAuditLogForProcessInstanceWithID:(NSString *)processInstanceID;

/**
 * Starts a process instance given a request representation and reports the result through the designated
 * data accessor delegate.
 *
 * @param startProcessRequestRepresentation Request representation containing the process definition ID and
 *                                          the name of the instance.
 */
- (void)startProcessInstanceWithStartProcessRequestRepresentation:(ASDKStartProcessRequestRepresentation *)startProcessRequestRepresentation;

/**
 * Cancels ongoing operations for the current data accessor.
 */
- (void)cancelOperations;

@end

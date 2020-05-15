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

@class ASDKFormFieldValueRequestRepresentation,
ASDKModelProcessDefinition,
ASDKModelFileContent,
ASDKModelContent,
ASDKModelFormDescription;

@interface ASDKFormDataAccessor : ASDKDataAccessor

/**
 * Completes the form associated with a specified task given a form field value representation
 * and reports through the designated data accessor delegate.
 *
 * @param taskID                        Task ID for which the attached form should be completed
 * @param formFieldValuesRepresentation Request representation containing filled in form field values
 */
- (void)completeFormForTaskID:(NSString *)taskID
withFormFieldValueRequestRepresentation:(ASDKFormFieldValueRequestRepresentation *)formFieldValuesRepresentation;

/**
 * Completes the form associated with a specified process definition given a form field value
 * representation and reports through the designated data accessor delegate.
 *
 * @param processDefinition             Process definition for which the attached form should be completed
 * @param formFieldValuesRepresentation Request representation containing filled in form field values
 */
- (void)completeFormForProcessDefinition:(ASDKModelProcessDefinition *)processDefinition
withFormFieldValuesRequestRepresentation:(ASDKFormFieldValueRequestRepresentation *)formFieldValuesRepresentation;

/**
 * Save the state of the form associated with a specified task given a form field value
 * representation and reports through the designated data accessor delegate.
 *
 * @param taskID                        Task ID for which the attached form should be saved
 * @param formFieldValuesRepresentation Request representation containing filled in form field values
 */
- (void)saveFormForTaskID:(NSString *)taskID
withFormFieldValueRequestRepresentation:(ASDKFormFieldValueRequestRepresentation *)formFieldValuesRepresentation;

/**
 * Removes form field value representation that have been already persisted on the server
 *
 * @param taskIDs An array of task ID values to be removed
 */
- (void)removeStalledFormFieldValueRepresentationsForTaskIDs:(NSArray *)taskIDs;

/**
 * Requests the cached form field value request representation for a specified task and reports the result via the designated
 * data accessor delegate. This representation could then be used to complete or save a task form.
 *
 * @param taskID ID of the task for which the values are requested
 */
- (void)fetchFormFieldValueRequestRepresentationForTaskID:(NSString *)taskID;


/**
 * Requests all the existing cached form field value representations and reports the result via the designated
 * data accessor delegate. This is useful to get a reference to all saved forms that need to be submited to the server.
 */
- (void)fetchAllFormFieldValueRequestRepresentations;

/**
 * Save the state of the form associated with a specified task given the current form description
 * and reports through the designated data accessor delegate.
 *
 * @param taskID            Task ID for which the form description should be saved
 * @param formDescription   Form description model containing user data to be saved
 */
- (void)saveFormForTaskID:(NSString *)taskID
      withFormDescription:(ASDKModelFormDescription *)formDescription;

/**
 * Uploads content data given a content model and reports through the designated data accessor delegate.
 *
 * @param file          Content model encapsulating file information needed for the upload
 * @param contentData   NSData object of the content to be uploaded
 */
- (void)uploadContentWithModel:(ASDKModelFileContent *)file
                   contentData:(NSData *)contentData;

/**
 * Downloads content for a content form field and reports through the designated data accessor delegate.
 *
 * @param content Content model encapsulating file information needed for the download
 */
- (void)downloadContentWithModel:(ASDKModelContent *)content;

/**
 * Requests option values for REST based form fields and reports the result through the designated data
 * accessor delegate.
 *
 * @param taskID    Task ID for which the values are requested
 * @param fieldID   Form field ID from the task attached form for which the values are requested
 */
- (void)fetchRestFieldValuesForTaskID:(NSString *)taskID
                      withFormFieldID:(NSString *)fieldID;

/**
 * Requests option values for REST based form fields in a start form and reports the result via the
 * designated data accessor delegate.
 *
 * @param processDefinitionID   Process definition ID for which the values are requested
 * @param fieldID               Form field ID from the process definition attached form for which the values are requested
 */
- (void)fetchRestFieldValuesOfStartFormForProcessDefinitionID:(NSString *)processDefinitionID
                                              withFormFieldID:(NSString *)fieldID;

/**
 * Requests option values for REST based columns in dynamic table form fields and reports the result via
 * the designated data accessor delegate.
 *
 * @param taskID    Task ID for which the values are requested
 * @param fieldID   Form field ID from the task attached form for which the values are requested
 * @param columnID  Dynamic table column ID for which the values are requested
 */
- (void)fetchRestFieldValuesForTaskID:(NSString *)taskID
                      withFormFieldID:(NSString *)fieldID
                         withColumnID:(NSString *)columnID;

/**
 * Requests option values for REST based columns in dynamic table form fields that are part of a start form and reports
 * the result via the designated data accessor delegate.
 *
 * @param processDefinitionID   Process definition ID for which the values are requested
 * @param fieldID               Form field ID from the process definition attached form for which the values are requested
 * @param columnID              Dynamic table column ID for which the values are requested
 */
- (void)fetchRestFieldValuesOfStartFormWithProcessDefinitionID:(NSString *)processDefinitionID
                                                 withFormField:(NSString *)fieldID
                                                  withColumnID:(NSString *)columnID;

/**
 * Requests form description for specified task and reports the result via the designated data accessor delegate.
 *
 * @param taskID Task ID for which the description is requested
 */
- (void)fetchFormDescriptionForTaskID:(NSString *)taskID;


/**
 * Requests the form variables for a specified task and reports the result via the designated data accessor delegate.
 *
 * @param taskID Task ID for which the form variables are requested
 */
- (void)fetchFormVariablesForTaskID:(NSString *)taskID;

/**
 * Requests the start form for a specified process instance ID and reports the result via the designated data accessor delegate.
 *
 * @param processInstanceID Process instance ID for which the description is requested
 */
- (void)fetchFormDescriptionForProcessInstanceID:(NSString *)processInstanceID;

/**
 * Requests the start form for a specified process definition ID and reports the result via the designated data accessor delegate.
 *
 * @param processDefinitionID Process definition ID for which the description is requested
 */
- (void)fetchFormDescriptionForProcessDefinitionID:(NSString *)processDefinitionID;

@end

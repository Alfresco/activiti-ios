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

@class ASDKModelFormDescription,
ASDKFormFieldValueRequestRepresentation,
ASDKModelFileContent,
ASDKModelProcessInstance,
ASDKModelProcessDefinition;

typedef void  (^ASDKFormModelsCompletionBlock) (ASDKModelFormDescription *formDescription, NSError *error);
typedef void  (^ASDKFormVariablesCompletionBlock) (NSArray *formVariables, NSError *error);
typedef void  (^ASDKFormCompletionBlock) (BOOL isFormCompleted, NSError *error);
typedef void  (^ASDKFormSaveBlock) (BOOL isFormSaved, NSError *error);
typedef void  (^ASDKStarFormCompletionBlock) (ASDKModelProcessInstance *processInstance, NSError *error);
typedef void  (^ASDKFormContentUploadCompletionBlock) (ASDKModelContent *contentModel, NSError *error);
typedef void  (^ASDKFormContentProgressBlock) (NSUInteger progress, NSError *error);
typedef void  (^ASDKFormRestFieldValuesCompletionBlock) (NSArray *restFieldValues, NSError *error);
typedef void  (^ASDKStartFormRestFieldValuesCompletionBlock) (NSArray *restFieldValues, NSError *error);
typedef void  (^ASDKFormContentDownloadProgressBlock) (NSString *formattedReceivedBytesString, NSError *error);
typedef void  (^ASDKFormContentDownloadCompletionBlock) (NSString *contentID, NSURL *downloadedContentURL, BOOL isLocalContent, NSError *error);

@protocol ASDKFormNetworkServiceProtocol <NSObject>

/**
 *  When a process definition has the "hasStartForm" property set to true
 *  this call will retrieve the list of form models that are associated with the
 *  start form for that process definition and upon completion start the process.
 *
 *  @param processDefinitionID The process definition ID for which the form models are
 *                             retrieved
 *  @param completionBlock     Completion block providing the form model list and an 
 *                             optional error reason
 */
- (void)startFormForProcessDefinitionID:(NSString *)processDefinitionID
                        completionBlock:(ASDKFormModelsCompletionBlock)completionBlock;

/**
 *  When the process has been started by completeting a start form, this call will 
 *  retrieve the list of form models that are associated with the start form for that
 *  process instance.
 *
 *  @param processInstanceID The process instance ID for which the form models are 
 *                           retrieved
 *  @param completionBlock   Completion block providing the form model list and an
 *                             optional error reason
 */
- (void)startFormForProcessInstanceID:(NSString *)processInstanceID
                      completionBlock:(ASDKFormModelsCompletionBlock)completionBlock;

/**
 *  Completes a task form associated with a given task ID, with an attached form field values representation 
 *  containing input values from the user and the form outcome the user chosen.
 *
 *  @param taskID                           The task ID for which the attached form should be completed
 *  @param formFieldValuesRepresentation    Form field values encapsulated in this representation containing 
 *                                          user input for the current form
 *  @param completionBlock                  Completion block providing whether the form has been successfully
 *                                          completed and an optional error reason
 */
- (void)completeFormForTaskID:(NSString *)taskID
withFormFieldValueRequestRepresentation:(ASDKFormFieldValueRequestRepresentation *)formFieldValuesRepresentation
              completionBlock:(ASDKFormCompletionBlock)completionBlock;

/**
 *  Completes a task form associated with a given process definition ID, with an attached form field values
 *  representation containing input values from the user and the form outcome the user chosen.
 *
 *  @param processDefinition             The process definition for which the attached form should be completed
 *  @param formFieldValuesRepresentation Form field values encapsulated in this representation containing
 *                                       user input for the current form
 *  @param completionBlock               Completion block providing whether the form has been successfully
 *                                       completed and an optional error reason
 */
- (void)completeFormForProcessDefinition:(ASDKModelProcessDefinition *)processDefinition
withFormFieldValuesRequestRepresentation:(ASDKFormFieldValueRequestRepresentation *)formFieldValuesRepresentation
                         completionBlock:(ASDKStarFormCompletionBlock)completionBlock;

/**
 *  Saves a task form associated with a given task ID, with an attached form field values representation 
 *  containing input values from the user.
 *
 *  @param taskID                        The task ID for which the attached form should be saved
 *  @param formFieldValuesRepresentation Form field values encapsulated in this representation containing
 *                                       user input for the current form
 *  @param completionBlock               Completion block providing whether the form has been successfully 
 *                                       saved and an optional error reason
 */
- (void)saveFormForTaskID:(NSString *)taskID
withFormFieldValuesRequestRepresentation:(ASDKFormFieldValueRequestRepresentation *)formFieldValuesRepresentation
          completionBlock:(ASDKFormSaveBlock)completionBlock;

/**
 *  Fetches and returns via the completion block the associated form descriptiom given
 *  a task ID.
 *
 *  @param taskID          The task ID for which the attached form is requested
 *  @param completionBlock Completion block providing the form model list and an
 *                         optional error reason
 */
- (void)fetchFormForTaskWithID:(NSString *)taskID
               completionBlock:(ASDKFormModelsCompletionBlock)completionBlock;


/**
 * Fetches and returns via the completion block an array of form variables for the
 * given task ID.
 *
 * @param taskID            The task ID for which the array of form variables is returned
 * @param completionBlock   Completion block providing an array of form variables and an
 *                          optional error reason
 */
- (void)fetchFormVariablesForTaskWithID:(NSString *)taskID
                        completionBlock:(ASDKFormVariablesCompletionBlock)completionBlock;

/**
 *  Uploads provided content data for a content field (which has no process instance or task to relate to)
 *  and reports back via a completion and progress blocks the status of the upload, whether the operation 
 *  was successfull and optional errors that might occur.
 *
 *  @param file            Content model encapsulating file information needed for the upload
 *  @param contentData     NSData object of the content to be uploaded
 *  @param taskID          ID of the task for which the content is uploaded
 *  @param progressBlock   Block providing information on the upload progress and an optional error reason
 *  @param completionBlock Completion block providing information on whether the upload finished successfully
 *                         and an optional error reason.
 */
- (void)uploadContentWithModel:(ASDKModelFileContent *)file
                   contentData:(NSData *)contentData
                 progressBlock:(ASDKFormContentProgressBlock)progressBlock
               completionBlock:(ASDKFormContentUploadCompletionBlock)completionBlock;

/**
 *  Download provided content data for a content field
 *  and reports back via a completion and progress blocks the status of the upload, whether the operation
 *  was successfull and optional errors that might occur.
 *
 *  @param content              Content model encapsulating file information needed for the download
 *  @param allowCachedResults   Allow for cached results
 *  @param progressBlock        Block providing information on the upload progress and an optional error reason
 *  @param completionBlock      Completion block providing information on whether the upload finished successfully
 *                              and an optional error reason.
 */
- (void)downloadContentWithModel:(ASDKModelContent *)content
              allowCachedResults:(BOOL)allowCachedResults
                   progressBlock:(ASDKFormContentDownloadProgressBlock)progressBlock
                 completionBlock:(ASDKFormContentDownloadCompletionBlock)completionBlock;

/**
 *  Fetches option values for REST based columns in dynamic table form fields and returns them via the completion block.
 *
 *  @param taskID           The task ID
 *  @param fieldID          The form field ID
 *  @param columnID         The column ID
 *  @param completionBlock  Completion block providing a NSArray containing the REST field values
 *                          and an option error reason
 */
- (void)fetchRestFieldValuesForTaskWithID:(NSString *)taskID
                              withFieldID:(NSString *)fieldID
                             withColumnID:(NSString *)columnID
                          completionBlock:(ASDKFormRestFieldValuesCompletionBlock)completionBlock;

/**
 *  Fetches option values for REST based form fields and returns them via the completion block.
 *
 *  @param taskID           The task ID
 *  @param fieldID          The form field ID
 *  @param completionBlock  Completion block providing a NSArray containing the REST field values
 *                          and an option error reason
 */
- (void)fetchRestFieldValuesForTaskWithID:(NSString *)taskID
                              withFieldID:(NSString *)fieldID
                          completionBlock:(ASDKFormRestFieldValuesCompletionBlock)completionBlock;


/**
 *  Fetches option values for REST based form fields in start form and returns them via the completion block.
 *
 *  @param processDefinitionID            The process definition ID
 *  @param fieldID                        The form field ID
 *  @param completionBlock                Completion block providing a NSArray containing the REST field values
 *                                        and an option error reason
 */
- (void)fetchRestFieldValuesForStartFormWithProcessDefinitionID:(NSString *)processDefinitionID
                                                    withFieldID:(NSString *)fieldID
                                                completionBlock:(ASDKStartFormRestFieldValuesCompletionBlock)completionBlock;

/**
 *  Fetches option values for REST based columns in dynamic table form fields in start form and returns them via the completion block.
 *
 *  @param taskID           The task ID
 *  @param fieldID          The form field ID
 *  @param columnID         The column ID
 *  @param completionBlock  Completion block providing a NSArray containing the REST field values
 *                          and an option error reason
 */
- (void)fetchRestFieldValuesForStartFormWithProcessDefinitionID:(NSString *)processDefinitionID
                                                    withFieldID:(NSString *)fieldID
                                                   withColumnID:(NSString *)columnID
                                                completionBlock:(ASDKStartFormRestFieldValuesCompletionBlock)completionBlock;

/**
 *  Cancells all queued or running network operations
 */
- (void)cancelAllNetworkOperations;

@end

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
ASDKFormFieldValueRequestRepresentation;

typedef void (^ASDKCacheServiceTaskRestFieldValuesCompletionBlock) (NSArray *restFieldValues, NSError *error);
typedef void (^ASDKCacheServiceFormDescriptionCompletionBlock) (ASDKModelFormDescription *formDescription, NSError *error);
typedef void (^ASDKCacheServiceFormVariablesCompletionBlock) (NSArray *formVariables, NSError *error);
typedef void (^ASDKCacheServiceTaskSavedFormDescriptionCompletionBlock) (ASDKModelFormDescription *formDescription, NSError *error, BOOL isSavedForm);
typedef void (^ASDKCacheServiceTaskFormValueRepresentationCompletionBlock) (ASDKFormFieldValueRequestRepresentation *formFieldValueRequestRepresentation, NSError *error);
typedef void (^ASDKCacheServiceTaskFormValueRepresentationListCompletionBlock) (NSArray *formFieldValueRepresentationList, NSArray *taskIDs, NSError *error);

@protocol ASDKFormCacheServicesProtocol <NSObject>

/**
 * Caches provided rest field value list for the specified task and field ID and
 * reports the operation success over a completion block.
 *
 @param restFieldValues List of rest field values to be cached
 @param taskID          Task ID describing the membership of rest field value items
 @param fieldID         ID of the form field the rest values are assigned to
 @param completionBlock Completion block indicating the success of the operation
 */
- (void)cacheRestFieldValues:(NSArray *)restFieldValues
                   forTaskID:(NSString *)taskID
             withFormFieldID:(NSString *)fieldID
         withCompletionBlock:(ASDKCacheServiceCompletionBlock)completionBlock;

/**
 * Fetches and reports via a completion block the rest field values for the specified
 * task ID and form field ID.
 *
 @param taskID          Task ID describing the membership of rest field value items
 @param fieldID         ID of the form field the rest values are assigned to
 @param completionBlock Completion block returning the rest field values
 */
- (void)fetchRestFieldValuesForTaskID:(NSString *)taskID
                      withFormFieldID:(NSString *)fieldID
                  withCompletionBlock:(ASDKCacheServiceTaskRestFieldValuesCompletionBlock)completionBlock;

/**
 * Caches provided rest field value list for the specified process definition and
 * field ID and reports the operation success over a completion block.
 *
 * @param restFieldValues       List of rest field values to be cached
 * @param processDefinitionID   Process definition ID of the start form for which the rest
 *                              field values are cached
 * @param fieldID               ID of the form field the rest values are assigned to
 * @param completionBlock       Completion block indicating the success of the operation
 */
- (void)cacheRestFieldValues:(NSArray *)restFieldValues
      forProcessDefinitionID:(NSString *)processDefinitionID
             withFormFieldID:(NSString *)fieldID
         withCompletionBlock:(ASDKCacheServiceCompletionBlock)completionBlock;

/**
 * Fetches and reports via a completion block the rest field values of the start form
 * for the specified process definition ID and form field ID.
 *
 * @param processDefinitionID   Process definition ID of the start form for which the rest
 *                              field values are retrieved from cache
 * @param fieldID               ID of the form field the rest values are assigned to
 * @param completionBlock       Completion block returning the rest field values
 */
- (void)fetchRestFieldValuesForProcessDefinitionID:(NSString *)processDefinitionID
                                   withFormFieldID:(NSString *)fieldID
                               withCompletionBlock:(ASDKCacheServiceTaskRestFieldValuesCompletionBlock)completionBlock;

/**
 * Caches provided rest field value list for the specified dynamic table attached to
 * a task form and reports the operation success over a completion block.
 *
 * @param restFieldValues   List of rest field values to be cached
 * @param taskID            Task ID describing the membership of the dynamic table
 * @param fieldID           ID of the form field the rest values are assigned to
 * @param columnID          ID of the dynamic table column the rest values are assigned to
 * @param completionBlock   Completion block indicating the success of the operation
 */
- (void)cacheRestFieldValues:(NSArray *)restFieldValues
                   forTaskID:(NSString *)taskID
             withFormFieldID:(NSString *)fieldID
                withColumnID:(NSString *)columnID
         withCompletionBlock:(ASDKCacheServiceCompletionBlock)completionBlock;

/**
 * Fetches and reports via a completion block the rest field values assigned to
 * the specified dynamic table that is part of a task form.
 *
 * @param taskID            Task ID describing the membership of the dynamic table
 * @param fieldID           ID of the form field the rest values are assigned to
 * @param columnID          ID of the dynamic table column the rest values are assigned to
 * @param completionBlock   Completion block returning the rest field values
 */
- (void)fetchRestFieldValuesForTaskID:(NSString *)taskID
                      withFormFieldID:(NSString *)fieldID
                         withColumnID:(NSString *)columnID
                  withCompletionBlock:(ASDKCacheServiceTaskRestFieldValuesCompletionBlock)completionBlock;

/**
 * Caches provided rest field value list for the specified dynamic table attached to
 * a start form and reports the operation success over a completion block.
 *
 * @param restFieldValues       List of rest field values to be cached
 * @param processDefinitionID   Process definition ID of the start form for which the rest
 *                              field values are cached
 * @param fieldID               ID of the form field the rest values are assigned to
 * @param columnID              ID of the dynamic table column the rest values are assigned to
 * @param completionBlock       Completion block indicating the success of the operation
 */
- (void)cacheRestFieldValues:(NSArray *)restFieldValues
      forProcessDefinitionID:(NSString *)processDefinitionID
             withFormFieldID:(NSString *)fieldID
                withColumnID:(NSString *)columnID
         withCompletionBlock:(ASDKCacheServiceCompletionBlock)completionBlock;

/**
 * Fetches and reports via a completion block the rest field values assigned to the
 * specified dynamic table that is part of a start form.
 *
 * @param processDefinitionID   Process definition ID of the start form for which the rest
 *                              field values are retrieved from cache
 * @param fieldID               ID of the form field the rest values are assigned to
 * @param columnID              ID of the dynamic table column the rest values are assigned to
 * @param completionBlock       Completion block returning the rest field values
 */
- (void)fetchRestFieldValuesForProcessDefinition:(NSString *)processDefinitionID
                                 withFormFieldID:(NSString *)fieldID
                                    withColumnID:(NSString *)columnID
                             withCompletionBlock:(ASDKCacheServiceTaskRestFieldValuesCompletionBlock)completionBlock;

/**
 * Caches provided form description for the specified task and reports the operation success
 * over a completion block.
 *
 * @param formDescription   Top level container model encapsulating all the fields and
 *                          particularities of a form
 * @param taskID            ID of the task for which the form is cached
 * @param completionBlock   Completion block indicating the success of the operation
 */
- (void)cacheTaskFormDescription:(ASDKModelFormDescription *)formDescription
                       forTaskID:(NSString *)taskID
             withCompletionBlock:(ASDKCacheServiceCompletionBlock)completionBlock;

/**
 * Fetches and reports via a completion block the task form field that's corresponding to
 * the specified task.
 *
 * @param taskID            ID of the task for which form is retrieved
 * @param completionBlock   Completion block returning the task form and wheter this is a saved form or not
 */
- (void)fetchTaskFormDescriptionForTaskID:(NSString *)taskID
                      withCompletionBlock:(ASDKCacheServiceTaskSavedFormDescriptionCompletionBlock)completionBlock;

/**
 * Caches provided form variables associated with a specified task and reports the operation success
 * over a completion block.
 *
 * @param formVariables     List of form variables associated with a task form
 * @param taskID            ID of the task for which the form variables are cached
 * @param completionBlock   Completion block indicating the success of the operation
 */
- (void)cacheTaskFormVariables:(NSArray *)formVariables
                     forTaskID:(NSString *)taskID
           withCompletionBlock:(ASDKCacheServiceCompletionBlock)completionBlock;

/**
 * Fetches and reports via a completion block the form variables associated with the specified task.
 *
 * @param taskID            ID of the task for which the form variables are retrieved
 * @param completionBlock   Completion block returning the task form variables.
 */
- (void)fetchTaskFormVariablesForTaskID:(NSString *)taskID
                      withCompletionBlock:(ASDKCacheServiceFormVariablesCompletionBlock)completionBlock;

/**
 * Caches provided form description containing user values for the specified task and reports the operation
 * success over a completion block.
 *
 * @param formDescription   Top level model encapsulating all the fields and particularities
 *                          of a form
 * @param taskID            ID of the task for which the form is cached
 * @param completionBlock   Completion block indicating the success of the operation
 */
- (void)cacheTaskFormDescriptionWithIntermediateValues:(ASDKModelFormDescription *)formDescription
                                             forTaskID:(NSString *)taskID
                                   withCompletionBlock:(ASDKCacheServiceCompletionBlock)completionBlock;

/**
 * Caches provided form field values representation containing user filled data for the specified task and
 * reports the operation success over a completion block.
 *
 * @param formFieldValueRequestRepresentation   Form field values updated by the user
 * @param taskID                                ID of the task for which the values are cached
 * @param completionBlock                       Completion block indicating the success of the operation
 */
- (void)cacheTaskFormFieldValuesRepresentation:(ASDKFormFieldValueRequestRepresentation *)formFieldValueRequestRepresentation
                                     forTaskID:(NSString *)taskID
                           withCompletionBlock:(ASDKCacheServiceCompletionBlock)completionBlock;

/**
 * Fetches and reports via a completion block the form field value representation that's corresponding
 * to the specified task.
 *
 * @param taskID            ID of the task for which the form field values representation are fetched
 * @param completionBlock   Completion block returning the form field value representation
 */
- (void)fetchTaskFormFieldValuesRepresentationForTaskID:(NSString *)taskID
                                    withCompletionBlock:(ASDKCacheServiceTaskFormValueRepresentationCompletionBlock)completionBlock;

/**
 * Fetches and reports via a completion block all the form field value representations that correspond
 * to a specific task.
 *
 * @param completionBlock Completion block returning a list of all available form field value representations
 */
- (void)fetchAllTaskFormFieldValueRepresentationsWithCompletionBlock:(ASDKCacheServiceTaskFormValueRepresentationListCompletionBlock)completionBlock;

/**
 * Removes stalled form field value representations from cache given an array of task IDs and reports
 * the operation success over a completion block.
 *
 * @param taskIDs           An array of task IDs to be removed from cache
 * @param completionBlock   Completion block returning the success of the operation
 */
- (void)removeStalledFormFieldValuesRepresentationsForTaskIDs:(NSArray *)taskIDs
                                          withCompletionBlock:(ASDKCacheServiceCompletionBlock)completionBlock;

/**
 * Caches provided start form description for the specified process instance and reports the operation
 * success over a completion block.
 *
 * @param formDescription   Top level container model encapsulating all the fields and
 *                          particularities of a form
 * @param processInstanceID ID of the process instance for which the form description is cached
 * @param completionBlock   Completion block indicating the success of the operation
 */
- (void)cacheProcessInstanceFormDescription:(ASDKModelFormDescription *)formDescription
                       forProcessInstanceID:(NSString *)processInstanceID
                        withCompletionBlock:(ASDKCacheServiceCompletionBlock)completionBlock;

/**
 * Fetches and reports via a completion block the process instance start form that's corresponding
 * to the specified process instance.
 *
 * @param processInstanceID ID of the process instance for which the form description is retrieved
 * @param completionBlock   Completion block returning the process instance start form
 */
- (void)fetchProcessInstanceFormDescriptionForProcessInstance:(NSString *)processInstanceID
                                          withCompletionBlock:(ASDKCacheServiceFormDescriptionCompletionBlock)completionBlock;

/**
 * Caches provided start form description for the specified process definition and reports the operation
 * success over a completion block.
 *
 * @param formDescription       Top level container model encapsulating all the fields and particularities
 *                              of a form
 * @param processDefinitionID   ID of the process definition for which the form description is cached
 * @param completionBlock       Completion block indicating the success of the operation
 */
- (void)cacheProcessDefinitionFormDescription:(ASDKModelFormDescription *)formDescription
                       forProcessDefinitionID:(NSString *)processDefinitionID
                          withCompletionBlock:(ASDKCacheServiceCompletionBlock)completionBlock;

/**
 * Fetches and reports via a completion block the process definition start form that's corresponding
 * to the specified process definition.
 *
 * @param processDefinitionID   ID of the process definition for which the form is retrieved
 * @param completionBlock       Completion block returning the process definition start form
 */
- (void)fetchProcessDefinitionFormDescriptionForProcessDefinitionID:(NSString *)processDefinitionID
                                                withCompletionBlock:(ASDKCacheServiceFormDescriptionCompletionBlock)completionBlock;

@end

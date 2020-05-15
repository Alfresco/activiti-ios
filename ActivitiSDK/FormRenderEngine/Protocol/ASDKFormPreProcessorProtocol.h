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

#import <UIKit/UIKit.h>
#import "ASDKFormPreProcessorDelegate.h"

@class ASDKModelTask,
ASDKModelFormDescription,
ASDKFormNetworkServices;

@protocol ASDKFormPreProcessorProtocol <NSObject>

@property (weak, nonatomic) id<ASDKFormPreProcessorDelegate> delegate;

/**
 * Given a task ID, an optional dynamic table field id and a set of form
 * fields additional data fetching or processing over the form fields is 
 * addressed within this method such that the result is prepared for the 
 * form engine. These additional steps are needed in order to provide 
 * consistent relevant structures to the engine and avoid on-the-fly structure
 * mutations in the engine itself.
 *
 * @param taskID                    Task ID for which the processing is performed.
 * @param formFields                The list of form fields associated with the task form.
 * @param dynamicTableFieldID       Optional parameter indicating the identify of a dynamic table structure
 */
- (void)setupWithTaskID:(NSString *)taskID
         withFormFields:(NSArray *)formFields
withDynamicTableFieldID:(NSString *)dynamicTableFieldID;

/**
 * Given a process definition ID, an optional dynamic table field id and a set 
 * of form fields additional data fetching or processing over the form fields is
 * addressed within this methid such that the result is prepared for the form engine.
 * These additional steps are needed in order to provide
 * consistent relevant structures to the engine and avoid on-the-fly structure
 * mutations in the engine itself.
 *
 * @param processDefinitionID       Process definition ID for which the form field processing is performed
 * @param formFields                The list of form fields associated with the process definition start form
 * @param dynamicTableFieldID       Optional parameter indicating the identify of a dynamic table structure
 */
- (void)setupWithProcessDefinitionID:(NSString *)processDefinitionID
                      withFormFields:(NSArray *)formFields
             withDynamicTableFieldID:(NSString *)dynamicTableFieldID;

@end

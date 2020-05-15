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

/**
 *  The purpose of this interface is to provide the means of communication for actions
 *  triggered by the app which implements the ActivitiSDK and that have impact on the
 *  state of the rendered forms, or actions that signal a change of state inside the
 *  SDK and should be handled by the host application.
 */

@protocol ASDKFormEngineActionHandlerProtocol <NSObject>

@optional

// Save form actions

/**
 *  Saves the current state of the form and submits the form field values to the 
 *  REST endpoint.
 */
- (void)saveForm;

/**
 *  Check whether the save form action is available in the current context the form
 *  state is.
 *
 *  @return YES or NO boolean values
 */
- (BOOL)isSaveFormActionAvailable;

@end

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
#import "ASDKFormControllerNavigationProtocol.h"

@class UICollectionViewController,
ASDKModelProcessInstance,
ASDKModelFormDescription;

@protocol ASDKFormRenderEngineDelegate <NSObject>

/**
 * Signals that the form render engine finished rendering the form and returns
 * a controller ready to be displayed or a failure reason.
 *
 * @param formController Visual representation of the form, ready to be displayed
 * @param error          Optional error reason indicating a failure in the rendering process
 */
- (void)didRenderedFormController:(UICollectionViewController<ASDKFormControllerNavigationProtocol> *)formController
                            error:(NSError *)error;

@optional
/**
 * Signals that the user completed the form and returns an optional error reason
 * if the operation fails.
 *
 @param error            Optional error reason indicating a failure when completing the form
 */
- (void)didCompleteFormWithError:(NSError *)error;

/**
 * Signals that the user completed a start form and returns a reference to the
 * newly created process instance and an optional error reason if the operation
 * fails.
 *
 * @param processInstance Process instance created as a result of completing a start form
 * @param error           Optional error reason indicating a failure when completing a start form
 */
- (void)didCompleteStartForm:(ASDKModelProcessInstance *)processInstance
                       error:(NSError *)error;

/**
 * Signals that the user triggered a form save action and returns an optional error
 * reason if the operation fails
 *
 * @param error           Optional error reason indicating a failure when saving the form
 */
- (void)didSaveFormWithError:(NSError *)error;

/**
 * Signals that the user triggered a form save action whilst being offline.
 */
- (void)didSaveFormInOfflineMode;

/**
 * Signals that the form render engine is requesting more information to render the form description
 */
- (void)didRequestAdditionalInformationForFormDescription:(ASDKModelFormDescription *)formDescription;


/**
 * Signals that the form render engine has finished requesting information needed to render the form
 * description
 *
 * @param formDescription Form description for which the request was completed
 * @param error           Optional error reason indicating a failure when fetching the additional
 *                        information
 */
- (void)didCompleteRequestingAdditionalInformationForFormDescription:(ASDKModelFormDescription *)formDescription
                                                           withError:(NSError *)error;

@end

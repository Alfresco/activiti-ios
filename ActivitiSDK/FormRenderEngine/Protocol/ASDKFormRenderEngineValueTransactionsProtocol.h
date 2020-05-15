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

@import Foundation;
@import UIKit;

@class ASDKModelFormField,
ASDKModelFormOutcome;

@protocol ASDKFormRenderEngineValueTransactionsProtocol <NSObject>

@optional
/**
 *  This method informs it's delegate that the metadata value has changed for
 *  a particular form field model object whose visual representation is given
 *  by the cell parameter.
 *
 *  @param formFieldModel The form field model object which contains the updated
 *                        metadata information
 *  @param cell           The visual representation in the form of a collection
 *                        view cell for a form field model
 */
- (void)updatedMetadataValueForFormField:(ASDKModelFormField *)formFieldModel
                                 inCell:(UICollectionViewCell *)cell;

/**
 *  This method signals that the user has tapped on a form outcome and provides
 *  the associated model for that action so that the network call can occur.
 *
 *  @param formOutcomeModel Model object describing the outcome of a form
 */
- (void)completeFormWithOutcome:(ASDKModelFormOutcome *)formOutcomeModel;

@end

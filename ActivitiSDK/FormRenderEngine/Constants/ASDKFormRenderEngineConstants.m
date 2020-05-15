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

#import "ASDKFormRenderEngineConstants.h"


#pragma mark -
#pragma mark Storyboard

NSString *kASDKFormStoryboardBundleName                             = @"ASDKFormStoryboard";
NSString *kASDKStoryboardIDCollectionController                     = @"ASDKFormCollectionViewController";
NSString *kASDKStoryboardIDRadioFormFieldDetailController           = @"ASDKFormRadioFormFieldDetailController";
NSString *kASDKStoryboardIDDateFormFieldDetailController            = @"ASDKFormDateFormFieldDetailController";
NSString *kASDKStoryboardIDAttachFormFieldDetailController          = @"ASDKFormAttachFormFieldDetailController";
NSString *kASDKStoryboardIDMultilineFormFieldDetailController       = @"ASDKFormMultilineFormFieldDetailController";
NSString *kASDKStoryboardIDPeopleFormFieldDetailController          = @"ASDKFormPeopleFormFieldDetailController";
NSString *kASDKStoryboardIDDynamicTableFormFieldDetailController    = @"ASDKFormDynamicTableFormFieldDetailController";
NSString *kASDKStoryboardIDIntegrationLoginWebViewController        = @"ASDKIntegrationLoginWebViewController";
NSString *kASDKStoryboardIDIntegrationBrowsingViewController        = @"ASDKIntegrationBrowsingViewController";
NSString *kASDKStoryboardIDTypeaheadFormFieldDetailController       = @"ASDKFormFieldTypeaheadViewController";


#pragma mark -
#pragma mark Segue IDs

NSString *kASDKSegueIDFormContentPicker                         = @"FormContentPickerSegueID";
NSString *kSegueIDFormPeoplePicker                              = @"FormPeoplePickerSegueID";
NSString *kSegueIDFormFieldPeopleAddPeopleUnwind                = @"FormPeopleAddPeopleUnwindSegueID";

#pragma mark - 
#pragma mark Cell IDs

NSString *kASDKCellIDFormFieldTextRepresentation                    = @"FormFieldTextRepresentationCellID";
NSString *kASDKCellIDFormFieldBooleanRepresentation                 = @"FormFieldBooleanRepresentationCellID";
NSString *kASDKCellIDFormFieldOutcomeRepresentation                 = @"FormFieldOutcomeRepresentationCellID";
NSString *kASDKCellIDFormFieldDateRepresentation                    = @"FormFieldDateRepresentationCellID";
NSString *kASDKCellIDFormFieldRadioRepresentation                   = @"FormFieldRadioRepresentationCellID";
NSString *kASDKCellIDFormFieldRadioOptionRepresentation             = @"FormFieldRadioOptionRepresentationCellID";
NSString *kASDKCellIDFormFieldRadioOptionDisplayValueRepresentation = @"FormFieldRadioOptionDisplayValueRepresentationCellID";
NSString *kASDKCellIDFormFieldAmountRepresentation              	= @"FormFieldAmountRepresentationCellID";
NSString *kASDKCellIDFormFieldMultilineRepresentation               = @"FormFieldMultilineRepresentationCellID";
NSString *kASDKCellIDFormFieldAttachRepresentation                  = @"FormFieldAttachRepresentationCellID";
NSString *kASDKCellIDFormFieldAttachFileRepresentation              = @"FormFieldAttachFileRepresentationCellID";
NSString *kASDKCellIDFormFieldContentSourceRepresentation           = @"FormFieldContentSourceRepresentationCellID";
NSString *kASDKCellIDFormFieldHeaderRepresentation                  = @"FormFieldHeaderRepresentationCellID";
NSString *kASDKCellIDFormFieldFooterRepresentation                  = @"FormFieldFooterRepresentationCellID";
NSString *kASDKCellIDFormFieldHyperlinkRepresentation               = @"FormFieldHyperlinkRepresentationCellID";
NSString *kASDKCellIDFormFieldAttachAddContent                      = @"FormFieldAttachAddContentCellID";
NSString *kASDKCellIDFormFieldPeopleRepresentation                  = @"FormFieldPeopleRepresentationCellID";
NSString *kASDKCellIDFormFieldPeopleAddPeople                       = @"FormFieldPeopleAddPeopleCellID";
NSString *kASDKCellIDFormFieldDynamicTableRepresentation            = @"FormFieldDynamicTableRepresentationCellID";
NSString *kASDKCellIDFormFieldDynamicTableHeaderRepresentation      = @"FormFieldDynamicTableHeaderRepresentationCellID";
NSString *kASDKCellIDFormFieldDynamicTableRowRepresentation         = @"FormFieldDynamicTableRowRepresentationCellID";
NSString *kASDKCellIDFormFieldTabRepresentation                     = @"FormFieldTabRepresentationCellID";
NSString *kASDKCellIDFormFieldDisplayTextRepresentation             = @"FormFieldDisplayTextRepresentationCellID";
NSString *kASDKCellIDFormFieldTypeaheadRepresentation               = @"FormFieldTypeaheadValueRepresentationCellID";
NSString *kASDKCellIDFormFieldTypeaheadSuggestionRepresentation     = @"FormFieldTypeaheadSuggestionRepresentationCellID";
NSString *kASDKCellIDIntegrationBrowsing                            = @"IntegrationBrowsingCellID";


#pragma mark -
#pragma mark Form field key values

NSString *kASDKFormFieldTrueStringValue                         = @"true";
NSString *kASDKFormFieldFalseStringValue                        = @"false";
NSString *kASDKFormFieldIDParam                                 = @"formFieldID";
NSString *kASDKFormFieldLabelParameter                          = @"_LABEL";
NSString *kASDKFormFieldEmptyStringValue                        = @"empty";


#pragma mark -
#pragma mark Form errors

NSString *kASDKFormRenderEngineErrorDomain                      = @"kASDKFormRenderEngineErrorDomain";
NSInteger kASDKFormRenderEngineSetupErrorCode                   = 1;
NSInteger kASDKFormRenderEngineUnsupportedFormFieldsCode        = 2;
NSInteger kASDKFormVisibilityConditionProcessorErrorCode        = 3;


#pragma mark - 
#pragma mark Notifications

NSString *kASDKFormNotificationShowContentPicker                 = @"kASDKFormNotificationShowContentPicker";
NSString *kASDKFormNotificationFormFieldContentSuccessfullUpload = @"kASDKFormNotificationFormFieldContentSuccessfullUpload";
NSString *kASDKFormNotificationFormFieldContentSuccessfullDeleted= @"kASDKFormNotificationFormFieldContentSuccessfullDeleted";
NSString *kASDKAlfrescoCloudDecommissioningAlertShownKey         = @"kASDKCloudDecommissioningAlertShown";


#pragma mark -
#pragma mark Animations

NSTimeInterval kASDKDefaultAnimationTime                         = .45f;
NSTimeInterval kModalReplaceAnimationTime                        = .55f;
NSTimeInterval kOverlayAlphaChangeTime                           = .25f;
NSTimeInterval kASDKSetSelectedAnimationTime                     = .25f;


#pragma mark -
#pragma mark Integration parameters

NSString *kASDKIntegrationOauth2CodeParameter                    = @"code";

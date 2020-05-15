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

// Storyboard
extern NSString *kASDKFormStoryboardBundleName;
extern NSString *kASDKStoryboardIDCollectionController;
extern NSString *kASDKStoryboardIDRadioFormFieldDetailController;
extern NSString *kASDKStoryboardIDDateFormFieldDetailController;
extern NSString *kASDKStoryboardIDAttachFormFieldDetailController;
extern NSString *kASDKStoryboardIDMultilineFormFieldDetailController;
extern NSString *kASDKStoryboardIDPeopleFormFieldDetailController;
extern NSString *kASDKStoryboardIDDynamicTableFormFieldDetailController;
extern NSString *kASDKStoryboardIDIntegrationLoginWebViewController;
extern NSString *kASDKStoryboardIDTypeaheadFormFieldDetailController;

// Segue IDs
extern NSString *kASDKSegueIDFormContentPicker;
extern NSString *kSegueIDFormPeoplePicker;
extern NSString *kSegueIDFormFieldPeopleAddPeopleUnwind;

// Cell IDs
extern NSString *kASDKCellIDFormFieldTextRepresentation;
extern NSString *kASDKCellIDFormFieldBooleanRepresentation;
extern NSString *kASDKCellIDFormFieldOutcomeRepresentation;
extern NSString *kASDKCellIDFormFieldDateRepresentation;
extern NSString *kASDKCellIDFormFieldRadioRepresentation;
extern NSString *kASDKCellIDFormFieldRadioOptionRepresentation;
extern NSString *kASDKCellIDFormFieldRadioOptionDisplayValueRepresentation;
extern NSString *kASDKCellIDFormFieldAmountRepresentation;
extern NSString *kASDKCellIDFormFieldMultilineRepresentation;
extern NSString *kASDKCellIDFormFieldAttachRepresentation;
extern NSString *kASDKCellIDFormFieldAttachFileRepresentation;
extern NSString *kASDKCellIDFormFieldContentSourceRepresentation;
extern NSString *kASDKCellIDFormFieldHeaderRepresentation;
extern NSString *kASDKCellIDFormFieldFooterRepresentation;
extern NSString *kASDKCellIDFormFieldHyperlinkRepresentation;
extern NSString *kASDKCellIDFormFieldAttachAddContent;
extern NSString *kASDKCellIDFormFieldPeopleRepresentation;
extern NSString *kASDKCellIDFormFieldPeopleAddPeople;
extern NSString *kASDKCellIDFormFieldDynamicTableRepresentation;
extern NSString *kASDKCellIDFormFieldDynamicTableHeaderRepresentation;
extern NSString *kASDKCellIDFormFieldDynamicTableRowRepresentation;
extern NSString *kASDKCellIDFormFieldTabRepresentation;
extern NSString *kASDKCellIDFormFieldDisplayTextRepresentation;
extern NSString *kASDKCellIDFormFieldTypeaheadRepresentation;
extern NSString *kASDKCellIDFormFieldTypeaheadSuggestionRepresentation;
extern NSString *kASDKCellIDIntegrationBrowsing;

// Form field key values
extern NSString *kASDKFormFieldTrueStringValue;
extern NSString *kASDKFormFieldFalseStringValue;
extern NSString *kASDKFormFieldIDParam;
extern NSString *kASDKFormFieldLabelParameter;
extern NSString *kASDKFormFieldEmptyStringValue;

// Form errors
extern NSString *kASDKFormRenderEngineErrorDomain;
extern NSInteger kASDKFormRenderEngineSetupErrorCode;
extern NSInteger kASDKFormRenderEngineUnsupportedFormFieldsCode; 
extern NSInteger kASDKFormVisibilityConditionProcessorErrorCode;

// Notifications
extern NSString *kASDKFormNotificationShowContentPicker;
extern NSString *kASDKFormNotificationFormFieldContentSuccessfullUpload;
extern NSString *kASDKFormNotificationFormFieldContentSuccessfullDeleted;
extern NSString *kASDKAlfrescoCloudDecommissioningAlertShownKey;

// Animations
extern NSTimeInterval kASDKDefaultAnimationTime;
extern NSTimeInterval kModalReplaceAnimationTime;
extern NSTimeInterval kOverlayAlphaChangeTime;
extern NSTimeInterval kASDKSetSelectedAnimationTime;

// Segues
extern NSString *kSegueIDFormFieldPeopleAddPeopleUnwind;

// Integration parameters
extern NSString *kASDKIntegrationOauth2CodeParameter;
extern NSString *kASDKStoryboardIDIntegrationBrowsingViewController;

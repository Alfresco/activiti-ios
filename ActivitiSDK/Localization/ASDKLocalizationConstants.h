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

#define ASDKLocalizedStringFromTable(key, tbl, comment) \
[[NSBundle bundleForClass:[self class]] localizedStringForKey:(key) value:@"" table:(tbl)]

extern NSString *ASDKLocalizationTable;

// Form related
extern NSString *kLocalizationDefaultFormOutcome;
extern NSString *kLocalizationSaveFormOutcome;
extern NSString *kLocalizationStartProcessFormOutcome;
extern NSString *kLocalizationDeleteDynamicTableRowFormOutcome;
extern NSString *kLocalizationCancelButtonText;
extern NSString *kLocalizationFormDateComponentRemoveButtonText;
extern NSString *kLocalizationFormDateComponentPickDateLabelText;
extern NSString *kLocalizationFormDateComponentDoneButtonText;
extern NSString *kLocalizationFormDateComponentPickTodayText;
extern NSString *kLocalizationFormDropdownComponentPickOptionLabelText;
extern NSString *kLocalizationFormAttachFileComponentButtonText;
extern NSString *kLocalizationFormAttachFilesComponentButtonText;
extern NSString *kLocalizationFormAttachFileNoContentText;
extern NSString *kLocalizationFormAttachFileItemsAttachedText;
extern NSString *kLocalizationFormPeopleNoSelectedText;
extern NSString *kLocalizationFormDynamicTableRowsAvailableText;
extern NSString *kLocalizationFormDynamicTableRowAvailableText;
extern NSString *kLocalizationFormDynamicTableRowHeaderText;
extern NSString *kLocalizationFormDynamicTableDeleteRowConfirmationText;
extern NSString *kLocalizationFormValueEmpty;
extern NSString *kLocalizationFormOptionClearText;
extern NSString *kLocalizationFormFieldNoNetworkConnectionText;

// Content picker component
extern NSString *kLocalizationFormContentPickerComponentLocalContentText;
extern NSString *kLocalizationFormContentPickerComponentCameraContentText;
extern NSString *kLocalizationFormContentPickerComponentCameraNotAvailableErrorText;
extern NSString *kLocalizationFormContentPickerComponentProgressPercentageFormat;
extern NSString *kLocalizationFormContentPickerComponentUploadingText;
extern NSString *kLocalizationFormContentPickerComponentDownloadingText;
extern NSString *kLocalizationFormContentPickerComponentDownloadProgressFormat;
extern NSString *kLocalizationFormContentPickerComponentSuccessText;
extern NSString *kLocalizationFormContentPickerComponentFailedText;
extern NSString *kLocalizationFormContentPickerComponentLocalVersionAvailableText;
extern NSString *kLocalizationFormContentPickerComponentPreviewLocalVersionText;
extern NSString *kLocalizationFormContentPickerComponentGetLatestVersionText;
extern NSString *kLocalizationFormContentPickerComponentAlfrescoContentText;
extern NSString *kLocalizationFormContentPickerComponentBoxContentText;
extern NSString *kLocalizationFormContentPickerComponentDriveText;
extern NSString *kLocalizationContentPickerComponentNoContentText;
extern NSString *kLocalizationContentPickerComponentNoContentNotEditableText;
extern NSString *kLocalizationFormContentPickerComponentNotAuthorizedText;

// People picker component
extern NSString *kLocalizationPeoplePickerControllerTitleText;
extern NSString *kLocalizationPeoplePickerControllerInvolvingUserFormat;
extern NSString *kLocalizationPeoplePickerControllerRemovingUserFormat;
extern NSString *kLocalizationPeoplePickerControllerNoContributorsText;
extern NSString *kLocalizationPeoplePickerControllerNoContributorsNotEditableText;

// Alert dialog
extern NSString *kLocalizationFormAlertDialogOopsTitleText;
extern NSString *kLocalizationFormAlertDialogOkButtonText;
extern NSString *kLocalizationFormAlertDialogDeleteContentQuestionFormat;
extern NSString *kLocalizationFormAlertDialogYesButtonText;
extern NSString *kLocalizationFormAlertDialogNoButtonText;
extern NSString *kLocalizationFormAlertDialogGenericNetworkErrorText;

// Integration component
extern NSString *kLocalizationIntegrationLoginErrorText;
extern NSString *kLocalizationIntegrationLoginSuccessfullText;
extern NSString *kLocalizationIntegrationBrowsingChooseNetworkText;
extern NSString *kLocalizationIntegrationBrowsingChooseSiteText;
extern NSString *kLocalizationIntegrationBrowsingNoContentAvailableText;
extern NSString *kLocalizationIntegrationBrowsingNoIntegrationAccountText;

// Dynamic table component
extern NSString *kLocalizationDynamicTableNoRowsText;
extern NSString *kLocalizationDynamicTableNoRowsNotEditableText;
extern NSString *kLocalizationDynamicTableIncompleteRowDataText;

// Default filter names
extern NSString *kLocalizationDefaultFilterInvolvedTasksText;
extern NSString *kLocalizationDefaultFilterMyTasksText;
extern NSString *kLocalizationDefaultFilterQueuedTasksText;
extern NSString *kLocalizationDefaultFilterCompletedTasksText;
extern NSString *kLocalizationDefaultFilterRunningProcessText;
extern NSString *kLocalizationDefaultFilterCompletedProcessesText;
extern NSString *kLocalizationDefaultFilterAllProcessesText;

// Cloud decommissioning

extern NSString *kLocalizationAlfrescoCloudAddressText;
extern NSString *kLocalizationAlfrescoCloudDecommissionText;

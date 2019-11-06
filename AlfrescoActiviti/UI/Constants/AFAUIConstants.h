/*******************************************************************************
 * Copyright (C) 2005-2018 Alfresco Software Limited.
 *
 * This file is part of the Alfresco Activiti Mobile iOS App.
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


// Animation time intervals

extern NSTimeInterval kDefaultAnimationTime;
extern NSTimeInterval kLoginScreenBackgroundImageFadeInTime;
extern NSTimeInterval kLoginScreenServerButtonsFadeInTime;
extern NSTimeInterval kModalReplaceAnimationTime;
extern NSTimeInterval kPushPopAnimationTime;
extern NSTimeInterval kOverlayAlphaChangeTime;

// Storyboard components IDs

extern NSString *kStoryboardIDLoginCredentialsViewController;
extern NSString *kStoryboardIDEmbeddedCredentialsPageController;
extern NSString *kStoryboardIDContentPickerViewController;
extern NSString *kStoryboardIDModalTaskDetailsViewController;
extern NSString *kStoryboardIDModalPeoplePickerViewController;
extern NSString *kStoryboardIDListViewController;
extern NSString *kStoryboardIDApplicationListViewController;
extern NSString *kStoryboardIDProfileViewController;
extern NSString *kStoryboardIDSettingsViewController;

// Cell IDs

extern NSString *kCellIDCredentialTextField;
extern NSString *kCellIDSignInButton;
extern NSString *kCellIDSecurityLayer;
extern NSString *kCellIDRememberCredentials;
extern NSString *kCellIDApplicationListStyle;
extern NSString *kCellIDDrawerMenuAvatar;
extern NSString *kCellIDDrawerMenuButton;
extern NSString *kCellIDContentFile;
extern NSString *kCellIDTaskListStyle;
extern NSString *kCellIDTaskDetailsName;
extern NSString *kCellIDTaskDetailsComplete;
extern NSString *kCellIDTaskDetailsRequeue;
extern NSString *kCellIDTaskDetailsClaim;
extern NSString *kCellIDTaskDetailsAssignee;
extern NSString *kCellIDTaskDetailsCreated;
extern NSString *kCellIDTaskDetailsDue;
extern NSString *kCellIDTaskDetailsDescription;
extern NSString *kCellIDTaskDetailsContributor;
extern NSString *kCellIDTaskDetailsAttachedForm;
extern NSString *kCellIDComment;
extern NSString *kCellIDCommentHeader;
extern NSString *kCellIDTaskDetailsProcess;
extern NSString *kCellIDTaskDetailsTask;
extern NSString *kCellIDTaskDetailsDuration;
extern NSString *kCellIDTaskDetailsCompletedDate;
extern NSString *kCellIDAddContent;
extern NSString *kCellIDFilterOption;
extern NSString *kCellIDFilterHeader;
extern NSString *kCellIDProcessDefinitionListStyle;
extern NSString *kCellIDProcessInstanceDetailsName;
extern NSString *kCellIDProcessInstanceDetailsShowDiagram;
extern NSString *kCellIDProcessInstanceDetailsStarted;
extern NSString *kCellIDProcessInstanceDetailsStartedBy;
extern NSString *kCellIDProcessInstanceDetailsCompletedDate;
extern NSString *kCellIDProcessInstanceDetailsTask;
extern NSString *kCellIDProcessInstanceDetailsTaskHeader;
extern NSString *kCellIDProfileSectionTitle;
extern NSString *kCellIDProfileCategory;
extern NSString *kCellIDProfileOption;
extern NSString *kCellIDProfileAction;
extern NSString *kCellIDSettingsSwitch;
extern NSString *kCellIDAuditLog;
extern NSString *kCellIDStartForm;
extern NSString *kCellIDTaskChecklist;
extern NSString *kCellIDSettingsUsage;
extern NSString *kCellIDLoginSection;

// Segue IDs

extern NSString *kSegueIDLoginAuthorized;
extern NSString *kSegueIDLoginAuthorizedUnwind;
extern NSString *kSegueIDApplicationListEmbedding;
extern NSString *kSegueIDDrawerMenuEmbedding;
extern NSString *kSegueIDAdvancedSearchMenuEmbedding;
extern NSString *kSegueIDList;
extern NSString *kSegueIDListUnwind;
extern NSString *kSegueIDTaskDetails;
extern NSString *kSegueIDTaskDetailsUnwind;
extern NSString *kSegueIDTaskDetailsAddContributor;
extern NSString *kSegueIDTaskDetailsAddContributorUnwind;
extern NSString *kSegueIDTaskDetailsViewProcess;
extern NSString *kSegueIDTaskDetailsViewProcessUnwind;
extern NSString *kSegueIDTaskDetailsViewTask;
extern NSString *kSegueIDTaskDetailsViewTaskUnwind;
extern NSString *kSegueIDTaskDetailsAddComments;
extern NSString *kSegueIDTaskDetailsAddCommentsUnwind;
extern NSString *kSegueIDTaskDetailsChecklist;
extern NSString *kSegueIDTaskDetailsChecklistUnwind;
extern NSString *kSegueIDContentPickerComponentEmbedding;
extern NSString *kSegueIDFormComponent;
extern NSString *kSegueIDStartProcessInstance;
extern NSString *kSegueIDStartProcessInstanceUnwind;
extern NSString *kSegueIDProcessInstanceDetails;
extern NSString *kSegueIDProcessInstanceDetailsUnwind;
extern NSString *kSegueIDProcessInstanceTaskDetails;
extern NSString *kSegueIDProcessInstanceTaskDetailsUnwind;
extern NSString *kSegueIDProcessStartFormEmbedding;
extern NSString *kSegueIDProcessInstanceStartForm;
extern NSString *kSegueIDProcessInstanceStartFormUnwind;
extern NSString *kSegueIDProcessInstanceDetailsAddComments;
extern NSString *kSegueIDProcessInstanceDetailsAddCommentsUnwind;
extern NSString *kSegueIDProcessInstanceViewCompletedStartForm;
extern NSString *kSegueIDProcessInstanceViewCompletedStartFormUnwind;
extern NSString *kSegueIDProfileContentPickerComponentEmbedding;
extern NSString *kSegueIDLoginAIMSAdvancedSettings;

// Thumbnail manager
extern NSString *kProfileImageThumbnailIdentifier;

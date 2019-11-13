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

#import "AFAUIConstants.h"


#pragma mark -
#pragma mark Animations

NSTimeInterval kDefaultAnimationTime                            = .45f;
NSTimeInterval kLoginScreenServerButtonsFadeInTime              = .45f;
NSTimeInterval kLoginScreenBackgroundImageFadeInTime            = 1.2f;
NSTimeInterval kModalReplaceAnimationTime                       = .55f;
NSTimeInterval kPushPopAnimationTime                            = .40f;
NSTimeInterval kOverlayAlphaChangeTime                          = .25f;
NSTimeInterval kSplashScreenAnimationTime                       = 2.0;


#pragma mark -
#pragma mark Storyboard components IDs

NSString *kStoryboardIDLoginCredentialsViewController           = @"LoginCredentialsViewControllerID";
NSString *kStoryboardIDEmbeddedCredentialsPageController        = @"EmbeddedCredentialsPageControllerID";
NSString *kStoryboardIDContentPickerViewController              = @"ContentPickerViewControllerID";
NSString *kStoryboardIDModalTaskDetailsViewController           = @"ModalTaskDetailsViewControllerID";
NSString *kStoryboardIDModalPeoplePickerViewController          = @"ModalPeoplePickerViewControllerID";
NSString *kStoryboardIDListViewController                       = @"ListViewControllerID";
NSString *kStoryboardIDApplicationListViewController            = @"ApplicationListViewControllerID";
NSString *kStoryboardIDProfileViewController                    = @"ProfileViewControllerID";
NSString *kStoryboardIDSettingsViewController                   = @"SettingsViewControllerID";
NSString *kStoryboardIDAIMSSSOViewController                    = @"AIMSSSOViewControllerID";
NSString *kStoryboardIDBaseAuthLoginViewController              = @"BaseAuthViewControllerID";
NSString *kStoryboardIDAIMSHelpViewController                   = @"AIMSHelpViewControllerID";


#pragma mark -
#pragma mark Cell IDs

NSString *kCellIDCredentialTextField                            = @"LoginCredentialTextfieldCellID";
NSString *kCellIDSignInButton                                   = @"LoginSignInCellID";
NSString *kCellIDSecurityLayer                                  = @"LoginSecurityLayerCellID";
NSString *kCellIDRememberCredentials                            = @"LoginRememberCredentialsCellID";
NSString *kCellIDApplicationListStyle                           = @"ApplicationListStyleCellID";
NSString *kCellIDDrawerMenuAvatar                               = @"DrawerMenuAvatarCellID";
NSString *kCellIDDrawerMenuButton                               = @"DrawerMenuButtonCellID";
NSString *kCellIDContentFile                                    = @"ContentFileCellID";
NSString *kCellIDTaskListStyle                                  = @"TaskListStyleCellID";
NSString *kCellIDTaskDetailsName                                = @"TaskDetailsNameCellID";
NSString *kCellIDTaskDetailsComplete                            = @"TaskDetailsCompleteCellID";
NSString *kCellIDTaskDetailsRequeue                             = @"TaskDetailsRequeueCellID";
NSString *kCellIDTaskDetailsClaim                               = @"TaskDetailsClaimCellID";
NSString *kCellIDTaskDetailsAssignee                            = @"TaskDetailsAssigneeCellID";
NSString *kCellIDTaskDetailsCreated                             = @"TaskDetailsCreatedCellID";
NSString *kCellIDTaskDetailsDue                                 = @"TaskDetailsDueCellID";
NSString *kCellIDTaskDetailsDescription                         = @"TaskDetailsDescriptionCellID";
NSString *kCellIDTaskDetailsContributor                         = @"TaskDetailsContributorCellID";
NSString *kCellIDTaskDetailsAttachedForm                        = @"TaskDetailsAttachedFormCellID";
NSString *kCellIDComment                                        = @"CommenCellID";
NSString *kCellIDCommentHeader                                  = @"CommentHeaderCellID";
NSString *kCellIDTaskDetailsProcess                             = @"TaskDetailsProcessCellID";
NSString *kCellIDTaskDetailsTask                                = @"TaskDetailsTaskCellID";
NSString *kCellIDTaskDetailsDuration                            = @"TaskDetailsDurationCellID";
NSString *kCellIDTaskDetailsCompletedDate                       = @"TaskDetailsCompletedDateCellID";
NSString *kCellIDAddContent                                     = @"AddContentCellID";
NSString *kCellIDFilterOption                                   = @"FilterOptionCellID";
NSString *kCellIDFilterHeader                                   = @"FilterHeaderCellID";
NSString *kCellIDProcessDefinitionListStyle                     = @"ProcessDefinitionListStyleCellID";
NSString *kCellIDProcessInstanceDetailsName                     = @"ProcessInstanceDetailsNameCellID";
NSString *kCellIDProcessInstanceDetailsShowDiagram              = @"ProcessInstanceDetailsShowDiagramCellID";
NSString *kCellIDProcessInstanceDetailsStarted                  = @"ProcessInstanceDetailsStartedCellID";
NSString *kCellIDProcessInstanceDetailsStartedBy                = @"ProcessInstanceDetailsStartedByCellID";
NSString *kCellIDProcessInstanceDetailsCompletedDate            = @"ProcessInstanceDetailsCompletedDateCellID";
NSString *kCellIDProcessInstanceDetailsTask                     = @"ProcessInstanceTaskCellID";
NSString *kCellIDProcessInstanceDetailsTaskHeader               = @"ProcessInstanceTaskHeaderCellID";
NSString *kCellIDProfileSectionTitle                            = @"ProfileSectionTitleCellID";
NSString *kCellIDProfileCategory                                = @"ProfileCategoryCellID";
NSString *kCellIDProfileOption                                  = @"ProfileOptionCellID";
NSString *kCellIDProfileAction                                  = @"ProfileActionCellID";
NSString *kCellIDSettingsUsage                                  = @"SettingsUsageCellID";
NSString *kCellIDSettingsSwitch                                 = @"SettingsSwitchCellID";
NSString *kCellIDAuditLog                                       = @"AuditLogCellID";
NSString *kCellIDStartForm                                      = @"StartFormCellID";
NSString *kCellIDTaskChecklist                                  = @"TaskChecklistCellID";
NSString *kCellIDLoginSection                                   = @"LoginSectionCellID";
NSString *kCellIDAdvancedSettingsHttps                          = @"AdvancedSettingsHttpsCellID";
NSString *kCellIDAdvancedSettingsField                          = @"AdvancedSettingsTextfieldCellID";
NSString *kCellIDAdvancedSettingsButton                         = @"AdvancedSettingsButtonCellID";
NSString *kCellIDAdvancedSettingsCopyright                      = @"AdvancedSettingsCopyrightCellID";
NSString *kCellIDAdvancedSettingsSection                        = @"AdvancedSettingsSectionCellID";


#pragma mark -
#pragma mark Segue IDs

NSString *kSegueIDLoginAuthorized                               = @"LoginAuthorizedSegueID";
NSString *kSegueIDLoginAuthorizedUnwind                         = @"LoginAuthorizedUnwindSegueID";
NSString *kSegueIDApplicationListEmbedding                      = @"ApplicationListEmbeddingSegueID";
NSString *kSegueIDDrawerMenuEmbedding                           = @"DrawerMenuEmbeddingSegueID";
NSString *kSegueIDAdvancedSearchMenuEmbedding                   = @"AdvancedSearchMenuEmbeddingSegueID";
NSString *kSegueIDList                                          = @"ListSegueID";
NSString *kSegueIDListUnwind                                    = @"TaskListUnwindSegueID";
NSString *kSegueIDTaskDetails                                   = @"TaskDetailsSegueID";
NSString *kSegueIDTaskDetailsUnwind                             = @"TaskDetailsUnwindSegueID";
NSString *kSegueIDTaskDetailsAddContributor                     = @"TaskDetailsAddContributorSegueID";
NSString *kSegueIDTaskDetailsAddContributorUnwind               = @"TaskDetailsAddContributorUnwindSegueID";
NSString *kSegueIDTaskDetailsViewProcess                        = @"TaskDetailsViewProcessSegueID";
NSString *kSegueIDTaskDetailsViewProcessUnwind                  = @"TaskDetailsViewProcessUnwindSegueID";
NSString *kSegueIDTaskDetailsViewTask                           = @"TaskDetailsViewTaskSegueID";
NSString *kSegueIDTaskDetailsViewTaskUnwind                     = @"TaskDetailsViewTaskUnwindSegueID";
NSString *kSegueIDTaskDetailsAddComments                        = @"TaskDetailsAddCommentsSegueID";
NSString *kSegueIDTaskDetailsAddCommentsUnwind                  = @"TaskDetailsAddCommentsUnwindSegueID";
NSString *kSegueIDTaskDetailsChecklist                          = @"TaskDetailsChecklistSegueID";
NSString *kSegueIDTaskDetailsChecklistUnwind                    = @"TaskDetailsChecklistUnwindSegueID";
NSString *kSegueIDContentPickerComponentEmbedding               = @"ContentPickerComponentEmbeddingSegueID";
NSString *kSegueIDFormComponent                                 = @"FormComponentEmbeddingSegueID";
NSString *kSegueIDStartProcessInstance                          = @"StartProcessInstanceSegueID";
NSString *kSegueIDStartProcessInstanceUnwind                    = @"StartProcessInstanceUnwindSegueID";
NSString *kSegueIDProcessInstanceDetails                        = @"ProcessInstanceDetailsSegueID";
NSString *kSegueIDProcessInstanceDetailsUnwind                  = @"ProcessInstanceDetailsUnwindSegueID";
NSString *kSegueIDProcessInstanceTaskDetails                    = @"ProcessInstanceTaskDetailsSegueID";
NSString *kSegueIDProcessInstanceTaskDetailsUnwind              = @"ProcessInstanceTaskDetailsUnwindSegueID";
NSString *kSegueIDProcessStartFormEmbedding                     = @"ProcessStartFormEmbeddingSegueID";
NSString *kSegueIDProcessInstanceStartForm                      = @"ProcessInstanceStartFormSegueID";
NSString *kSegueIDProcessInstanceStartFormUnwind                = @"ProcessInstanceStartFormUnwindSegueID";
NSString *kSegueIDProcessInstanceDetailsAddComments             = @"ProcessInstanceDetailsAddCommentsSegueID";
NSString *kSegueIDProcessInstanceDetailsAddCommentsUnwind       = @"ProcessInstanceDetailsAddCommentsUnwindSegueID";
NSString *kSegueIDProcessInstanceViewCompletedStartForm         = @"ProcessInstanceViewCompletedStartFormSegueID";
NSString *kSegueIDProcessInstanceViewCompletedStartFormUnwind   = @"ProcessInstanceViewCompletedStartFormUnwindSegueID";
NSString *kSegueIDProfileContentPickerComponentEmbedding        = @"ProfileContentPickerComponentEmbeddingSegueID";
NSString *kSegueIDLoginAIMSAdvancedSettings                     = @"LoginAIMSAdvancedSettingsSegueID";
NSString *kSegueIDSplashScreen                                  = @"ShowAppFromSplashScreenSegueID";
NSString *kSegueIDBaseAuthLoginSegueID                          = @"BaseAuthLoginSegueID";


#pragma mark -
#pragma mark Thumbnail manager

NSString *kProfileImageThumbnailIdentifier                      = @"kProfileImageThumbnailIdentifier";


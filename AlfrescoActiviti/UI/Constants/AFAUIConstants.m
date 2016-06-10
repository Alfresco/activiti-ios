/*******************************************************************************
 * Copyright (C) 2005-2016 Alfresco Software Limited.
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
NSTimeInterval kOverlayAlphaChangeTime                          = .25f;


#pragma mark -
#pragma mark Storyboard components IDs

NSString *kStoryboardIDLoginCredentialsViewController           = @"LoginCredentialsViewControllerID";
NSString *kStoryboardIDEmbeddedCredentialsPageController        = @"EmbeddedCredentialsPageControllerID";
NSString *kStoryboardIDConnectivityViewController               = @"ConnectivityViewControllerID";
NSString *kStoryboardIDContentPickerViewController              = @"ContentPickerViewControllerID";
NSString *kStoryboardIDAddTaskViewController                    = @"AddTaskViewControllerID";
NSString *kStoryboardIDListViewController                       = @"ListViewControllerID";
NSString *kStoryboardIDApplicationListViewController            = @"ApplicationListViewControllerID";
NSString *kStoryboardIDProfileViewController                    = @"ProfileViewControllerID";


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
NSString *kCellIDTaskDetailsClaim                               = @"TaskDetailsClaimCellID";
NSString *kCellIDTaskDetailsAssignee                            = @"TaskDetailsAssigneeCellID";
NSString *kCellIDTaskDetailsCreated                             = @"TaskDetailsCreatedCellID";
NSString *kCellIDTaskDetailsDue                                 = @"TaskDetailsDueCellID";
NSString *kCellIDTaskDetailsDescription                         = @"TaskDetailsDescriptionCellID";
NSString *kCellIDTaskDetailsContributor                         = @"TaskDetailsContributorCellID";
NSString *kCellIDComment                                        = @"CommenCellID";
NSString *kCellIDCommentHeader                                  = @"CommentHeaderCellID";
NSString *kCellIDTaskDetailsProcess                             = @"TaskDetailsProcessCellID";
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
NSString *kCellIDProfileUsage                                   = @"ProfileUsageCellID";
NSString *kCellIDAuditLog                                       = @"AuditLogCellID";
NSString *kCellIDTaskChecklist                                  = @"TaskChecklistCellID";
NSString *kCellIDLoginSection                                   = @"LoginSectionCellID";


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
NSString *kSegueIDProfileContentPickerComponentEmbedding        = @"ProfileContentPickerComponentEmbeddingSegueID";


#pragma mark -
#pragma mark Thumbnail manager

NSString *kProfileImageThumbnailIdentifier                      = @"kProfileImageThumbnailIdentifier";


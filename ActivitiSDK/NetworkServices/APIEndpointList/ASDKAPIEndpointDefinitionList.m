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

#import "ASDKAPIEndpointDefinitionList.h"


#pragma mark -
#pragma mark Application path
NSString * const kASDKAPIApplicationPath            = @"activiti-app";
NSString * const kASDKAPIAppAuthentication          = @"authentication";

#pragma mark -
#pragma mark Enterprise component

NSString * const kASDKAPIEnterprisePath             = @"enterprise";


#pragma mark -
#pragma mark Cloud hostname

NSString * const kASDKAPICloudHostnamePath          = @"activiti.alfresco.com";


#pragma mark -
#pragma mark Server information

NSString * const kASDKAPIServerVersionPath          = @"app-version";


#pragma mark -
#pragma mark Generic paths

NSString * const kASDKAPIRestPath                    = @"rest";
NSString * const kASDKAPIActionPath                  = @"action";
NSString * const kASDKAPIPath                        = @"api";
NSString * const kASDKAPIAppPath                     = @"app";
NSString * const kASDKAPIQueryPath                   = @"query";


#pragma mark -
#pragma mark Apps

NSString * const kASDKAPIRuntimeAppDefinitionsPath  = @"runtime-app-definitions";


#pragma mark -
#pragma mark User profile related

NSString * const kASDKAPIProfilePath                 = @"profile";
NSString * const kASDKAPIProfilePicturePath          = @"profile-picture";
NSString * const kASDKAPIProfilePasswordPath         = @"profile-password";
NSString * const kASDKAPIProfileAdminPath            = @"admin";


#pragma mark -
#pragma mark Task related

NSString * const kASDKAPITasksPath                   = @"tasks";
NSString * const kASDKAPITaskActionCompletePath      = @"complete";
NSString * const kASDKAPITaskInvolvePath             = @"involve";
NSString * const kASDKAPITaskRemoveInvolvedPath      = @"remove-involved";
NSString * const kASDKAPITaskClaimPath               = @"claim";
NSString * const kASDKAPITaskUnclaimPath             = @"unclaim";
NSString * const kASDKAPITaskAssignPath              = @"assign";
NSString * const kASDKAPITaskChecklistPath           = @"checklist";

#pragma mark -
#pragma mark Filter related

NSString * const kASDKAPIFilterListPath              = @"filters";
NSString * const kASDKAPIFilterPath                  = @"filter";


#pragma mark -
#pragma mark Processes related

NSString * const kASDKAPIProcessInstancesPath        = @"process-instances";
NSString * const kASDKAPIProcessDefinitionPath       = @"process-definitions";
NSString * const kASDKAPIProcessesPath               = @"processes";

#pragma mark - 
#pragma mark Content related

NSString * const kASDKAPIContentPath                 = @"content";
NSString * const kASDKAPITaskContentUploadPath       = @"raw-content";
NSString * const kASDKAPIContentRawPath              = @"raw";
NSString * const kASDKAPIProcessContentPath          = @"field-content";
NSString * const kASDKAPIAuditPath                   = @"audit";
NSString * const kASDKAPIRenditionPath               = @"rendition";
NSString * const kASDKAPIThumbnailPath               = @"thumbnail";


#pragma mark -
#pragma mark Comment related

NSString * const kASDKAPICommentPath                = @"comments";

#pragma mark -
#pragma mark Form related

NSString * const kASDKAPIStartFormPath              = @"start-form";
NSString * const kASDKAPITaskFormsPath              = @"task-forms";
NSString * const kASDKAPIFormValuesPath             = @"form-values";
NSString * const kASDKAPIStartFormValuesPath        = @"start-form-values";
NSString * const kASDKAPISaveFormPath               = @"save-form";
NSString * const kASDKAPIVariablesFormPath          = @"variables";

#pragma mark -
#pragma mark Users related

NSString * const kASDKAPIUsersPath                  = @"users";
NSString * const kASDKAPIUsersPicturePath           = @"picture";


#pragma mark -
#pragma mark Integration related

NSString * const kASDKAPIIntegrationAccountPath         = @"account";
NSString * const kASDKAPIIntegrationPath                = @"integration";
NSString * const kASDKAPIIntegrationAlfrescoCloudPath   = @"alfresco-cloud";
NSString * const kASDKAPIIntegrationNetworksPath        = @"networks";
NSString * const kASDKAPIIntegrationSitesPath           = @"sites";
NSString * const kASDKAPIIntegrationFoldersPath         = @"folders";


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

/**
 *  Factory class that generates Alfresco Activiti specific API endpoints 
 */

@interface ASDKServicePathFactory : NSObject

@property (strong, nonatomic, readonly) NSURL *baseURL;

/**
 *  Designated initializer for this class. Upon completion it generates the baseURL 
 *  path that future requests will use.
 *
 *  @param hostAddress          The host adress in name.domain format (eg activiti.alfresco.com)
 *  @param serviceDocumentPath  Path to the activiti installation 
 *  @param port                 Port number on which the connection will be made
 *  @param isSecureLayer        Specifies whether the communication is made via a secured layer
 *
 *  @return Class intance of ASDKServicePathFactory
 */
- (instancetype)initWithHostAddress:(NSString *)hostAddress
                serviceDocumentPath:(NSString *)serviceDocumentPath
                               port:(NSString *)port
                    overSecureLayer:(BOOL)isSecureLayer;


// Service definitions

// Server information
- (NSString *)serverInformationServicePath;

// Cloud hostname
- (NSString *)cloudHostnamePath;

// Apps
- (NSString *)runtimeAppDefinitionsServicePath;

// Profile related
- (NSString *)profileServicePath;
- (NSString *)profilePicturePath;
- (NSString *)profilePasswordPath;
- (NSString *)profilePictureUploadPath;

// Task related
- (NSString *)taskListServicePath;
- (NSString *)taskListFromFilterServicePath;
- (NSString *)taskDetailsServicePathFormat;
- (NSString *)taskContentServicePathFormat;
- (NSString *)taskCommentServicePathFormat;
- (NSString *)taskActionCompleteServicePathFormat;
- (NSString *)taskContentUploadServicePathFormat;
- (NSString *)taskContentDownloadServicePathFormat;
- (NSString *)taskContentThumbnailServicePathFormat;
- (NSString *)taskUserInvolveServicePathFormat;
- (NSString *)taskUserRemoveInvolvedServicePathFormat;
- (NSString *)taskCreationServicePath;
- (NSString *)taskClaimServicePathFormat;
- (NSString *)taskUnclaimServicePathFormat;
- (NSString *)taskAssignServicePathFormat;
- (NSString *)taskAuditLogServicePathFormat;
- (NSString *)taskCheckListServicePathFormat;

// Filter related
- (NSString *)taskFilterListServicePath;

// Content related
- (NSString *)contentServicePathFormat;

// Form related
- (NSString *)processDefinitionStartFormServicePathFormat;
- (NSString *)processInstanceStartFormServicePathFormat;
- (NSString *)taskFormServicePathFormat;
- (NSString *)taskFormVariablesPathFormat;
- (NSString *)contentFieldUploadServicePath;
- (NSString *)restFieldValuesServicePathFormat;
- (NSString *)dynamicTableRestFieldValuesServicePathFormat;
- (NSString *)startFormCompletionPath;
- (NSString *)startFormRestFieldValuesServicePathFormat;
- (NSString *)startFormDynamicTableRestFieldValuesServicePathFormat;
- (NSString *)saveFormServicePathFormat;

// Process related
- (NSString *)processDefinitionListServicePathFormat;
- (NSString *)processInstanceFilterListServicePath;
- (NSString *)processInstancesListServicePath;
- (NSString *)startProcessInstanceServicePath;
- (NSString *)processInstanceDetailsServicePathFormat;
- (NSString *)processInstanceContentServicePathFormat;
- (NSString *)processInstanceCommentServicePathFormat;
- (NSString *)processInstanceAuditLogServicePathFormat;

// User related
- (NSString *)userListServicePath;
- (NSString *)userProfileImageServicePathFormat;
- (NSString *)authenticationServicePath;

// Query related
- (NSString *)taskQueryServicePath;

// Integration related
- (NSString *)integrationAccountsServicePath;
- (NSString *)integrationNetworksServicePathFormat;
- (NSString *)integrationSitesServicePathFormat;
- (NSString *)integrationSiteContentServicePathFormat;
- (NSString *)integrationFolderContentServicePathFormat;
- (NSString *)integrationContentUploadServicePath;
- (NSString *)integrationContentUploadForTaskServicePathFormat;

@end

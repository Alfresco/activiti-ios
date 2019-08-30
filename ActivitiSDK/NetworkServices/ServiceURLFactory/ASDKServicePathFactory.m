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

#import "ASDKServicePathFactory.h"
#import "ASDKAPIEndpointDefinitionList.h"
#import "ASDKNetworkServiceConstants.h"

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

// HTTP / HTTPS protocol definition
static NSString * const kASDKHTTP  = @"http";
static NSString * const kASDkHTTPS = @"https";

@implementation ASDKServicePathFactory

- (instancetype)initWithHostAddress:(NSString *)hostAddress
                serviceDocumentPath:(NSString *)serviceDocumentPath
                               port:(NSString *)port
                    overSecureLayer:(BOOL)isSecureLayer {
    self = [super init];
    
    if (self) {
        // Check parameter sanity
        NSParameterAssert(hostAddress.length);
        NSParameterAssert(serviceDocumentPath.length);
        
        // Attach the port component to the host address if defined
        if (port.length) {
            hostAddress = [hostAddress stringByAppendingFormat:@":%@", port];
        }
        
        // Check whether the protocol declaration must prefix the host address or not
        NSString *hostAddressFormat = @"%@://%@";
        if (isSecureLayer) {
            if (![hostAddress hasPrefix:kASDkHTTPS]) {
                hostAddress = [NSString stringWithFormat:hostAddressFormat, kASDkHTTPS, hostAddress];
            }
        } else {
            if (![hostAddress hasPrefix:kASDKHTTP]) {
                hostAddress = [NSString stringWithFormat:hostAddressFormat, kASDKHTTP, hostAddress];
            }
        }
        
        _baseURL = [NSURL URLWithString:serviceDocumentPath
                          relativeToURL:[NSURL URLWithString:[hostAddress stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]]];
    }
    
    return self;
}


#pragma mark -
#pragma mark Server information

- (NSString *)serverInformationServicePath {
    return [[kASDKAPIPath stringByAppendingPathComponent:kASDKAPIEnterprisePath] stringByAppendingPathComponent:kASDKAPIServerVersionPath];
}


#pragma mark -
#pragma mark Cloud hostname 

- (NSString *)cloudHostnamePath {
    return kASDKAPICloudHostnamePath;
}


#pragma mark -
#pragma mark Apps

- (NSString *)runtimeAppDefinitionsServicePath {
    return [[kASDKAPIPath stringByAppendingPathComponent:kASDKAPIEnterprisePath] stringByAppendingPathComponent:kASDKAPIRuntimeAppDefinitionsPath];
}


#pragma mark -
#pragma mark Profile

- (NSString *)profileServicePath {
    return [[kASDKAPIPath stringByAppendingPathComponent:kASDKAPIEnterprisePath] stringByAppendingPathComponent:kASDKAPIProfilePath];
}

- (NSString *)profilePicturePath {
    return [[kASDKAPIPath stringByAppendingPathComponent:kASDKAPIEnterprisePath] stringByAppendingPathComponent:kASDKAPIProfilePicturePath];
}

- (NSString *)profilePasswordPath {
    return [[kASDKAPIPath stringByAppendingPathComponent:kASDKAPIEnterprisePath] stringByAppendingPathComponent:kASDKAPIProfilePasswordPath];
}

- (NSString *)profilePictureUploadPath {
    return [[kASDKAPIPath stringByAppendingPathComponent:kASDKAPIEnterprisePath] stringByAppendingPathComponent:kASDKAPIProfilePicturePath];
}


#pragma mark -
#pragma mark Task related

- (NSString *)taskListServicePath {
    return [[[kASDKAPIPath stringByAppendingPathComponent:kASDKAPIEnterprisePath] stringByAppendingPathComponent:kASDKAPITasksPath] stringByAppendingPathComponent:kASDKAPIQueryPath];
}

- (NSString *)taskListFromFilterServicePath {
    return [[[kASDKAPIPath stringByAppendingPathComponent:kASDKAPIEnterprisePath] stringByAppendingPathComponent:kASDKAPITasksPath] stringByAppendingPathComponent:kASDKAPIFilterPath];
}

- (NSString *)taskDetailsServicePathFormat {
    return [[[kASDKAPIPath stringByAppendingPathComponent:kASDKAPIEnterprisePath] stringByAppendingPathComponent:kASDKAPITasksPath] stringByAppendingPathComponent:@"%@"];
}

- (NSString *)taskContentServicePathFormat {
    return [[self taskDetailsServicePathFormat] stringByAppendingPathComponent:kASDKAPIContentPath];
}

- (NSString *)taskCommentServicePathFormat {
    return [[self taskDetailsServicePathFormat] stringByAppendingPathComponent:kASDKAPICommentPath];
}

- (NSString *)taskActionCompleteServicePathFormat {
    return [[[self taskDetailsServicePathFormat] stringByAppendingPathComponent:kASDKAPIActionPath] stringByAppendingPathComponent:kASDKAPITaskActionCompletePath];
}

- (NSString *)taskContentUploadServicePathFormat {
    return [[[[kASDKAPIPath stringByAppendingPathComponent:kASDKAPIEnterprisePath] stringByAppendingPathComponent:kASDKAPITasksPath] stringByAppendingPathComponent:@"%@"] stringByAppendingPathComponent:kASDKAPITaskContentUploadPath];
}

- (NSString *)taskContentDownloadServicePathFormat {
    return [[[[kASDKAPIPath stringByAppendingPathComponent:kASDKAPIEnterprisePath] stringByAppendingPathComponent:kASDKAPIContentPath] stringByAppendingPathComponent:@"%@"] stringByAppendingPathComponent:kASDKAPIContentRawPath];
}

- (NSString *)taskContentThumbnailServicePathFormat {
    return [[[[[kASDKAPIPath stringByAppendingPathComponent:kASDKAPIEnterprisePath] stringByAppendingPathComponent:kASDKAPIContentPath] stringByAppendingPathComponent:@"%@"] stringByAppendingPathComponent:kASDKAPIRenditionPath] stringByAppendingPathComponent:kASDKAPIThumbnailPath];
}

- (NSString *)taskUserInvolveServicePathFormat {
    return [[[[[kASDKAPIPath stringByAppendingPathComponent:kASDKAPIEnterprisePath] stringByAppendingPathComponent:kASDKAPITasksPath] stringByAppendingPathComponent:@"%@"] stringByAppendingPathComponent:kASDKAPIActionPath] stringByAppendingPathComponent:kASDKAPITaskInvolvePath];
}

- (NSString *)taskUserRemoveInvolvedServicePathFormat {
    return [[[[[kASDKAPIPath stringByAppendingPathComponent:kASDKAPIEnterprisePath] stringByAppendingPathComponent:kASDKAPITasksPath] stringByAppendingPathComponent:@"%@"] stringByAppendingPathComponent:kASDKAPIActionPath] stringByAppendingPathComponent:kASDKAPITaskRemoveInvolvedPath];
}

- (NSString *)taskCreationServicePath {
    return [[kASDKAPIPath stringByAppendingPathComponent:kASDKAPIEnterprisePath] stringByAppendingPathComponent:kASDKAPITasksPath];
}

- (NSString *)taskClaimServicePathFormat {
    return [[[[[kASDKAPIPath stringByAppendingPathComponent:kASDKAPIEnterprisePath] stringByAppendingPathComponent:kASDKAPITasksPath] stringByAppendingPathComponent:@"%@"] stringByAppendingPathComponent:kASDKAPIActionPath] stringByAppendingPathComponent:kASDKAPITaskClaimPath];
}

- (NSString *)taskUnclaimServicePathFormat {
    return [[[[[kASDKAPIPath stringByAppendingPathComponent:kASDKAPIEnterprisePath] stringByAppendingPathComponent:kASDKAPITasksPath] stringByAppendingPathComponent:@"%@"] stringByAppendingPathComponent:kASDKAPIActionPath] stringByAppendingPathComponent:kASDKAPITaskUnclaimPath];
}

- (NSString *)taskAssignServicePathFormat {
    return [[[[[kASDKAPIPath stringByAppendingPathComponent:kASDKAPIEnterprisePath] stringByAppendingPathComponent:kASDKAPITasksPath] stringByAppendingPathComponent:@"%@"] stringByAppendingPathComponent:kASDKAPIActionPath] stringByAppendingPathComponent:kASDKAPITaskAssignPath];
}

- (NSString *)taskAuditLogServicePathFormat {
    return [[[[kASDKAPIAppPath stringByAppendingPathComponent:kASDKAPIRestPath] stringByAppendingPathComponent:kASDKAPITasksPath] stringByAppendingPathComponent:@"%@"] stringByAppendingPathComponent:kASDKAPIAuditPath];
}

- (NSString *)taskCheckListServicePathFormat {
    return [[[[kASDKAPIPath stringByAppendingPathComponent:kASDKAPIEnterprisePath] stringByAppendingPathComponent:kASDKAPITasksPath] stringByAppendingPathComponent:@"%@"] stringByAppendingPathComponent:kASDKAPITaskChecklistPath];
}


#pragma mark -
#pragma mark Filter related

- (NSString *)taskFilterListServicePath; {
    return [[[kASDKAPIPath stringByAppendingPathComponent:kASDKAPIEnterprisePath] stringByAppendingPathComponent:kASDKAPIFilterListPath] stringByAppendingPathComponent:kASDKAPITasksPath];
}

- (NSString *)processInstanceFilterListServicePath {
    return [[[kASDKAPIPath stringByAppendingPathComponent:kASDKAPIEnterprisePath] stringByAppendingPathComponent:kASDKAPIFilterListPath] stringByAppendingPathComponent:kASDKAPIProcessesPath];
}


#pragma mark -
#pragma mark Content related

- (NSString *)contentServicePathFormat {
    return [[[kASDKAPIPath stringByAppendingPathComponent:kASDKAPIEnterprisePath] stringByAppendingPathComponent:kASDKAPIContentPath] stringByAppendingPathComponent:@"%@"];
}


#pragma mark -
#pragma mark Form related

- (NSString *)processDefinitionStartFormServicePathFormat {
    return [[[[kASDKAPIPath stringByAppendingPathComponent:kASDKAPIEnterprisePath] stringByAppendingPathComponent:kASDKAPIProcessDefinitionPath] stringByAppendingPathComponent:@"%@"] stringByAppendingPathComponent:kASDKAPIStartFormPath];
}

- (NSString *)processInstanceStartFormServicePathFormat {
    return [[[[kASDKAPIPath stringByAppendingPathComponent:kASDKAPIEnterprisePath] stringByAppendingPathComponent:kASDKAPIProcessInstancesPath] stringByAppendingPathComponent:@"%@"] stringByAppendingPathComponent:kASDKAPIStartFormPath];
}

- (NSString *)taskFormServicePathFormat {
    return [[[kASDKAPIPath stringByAppendingPathComponent:kASDKAPIEnterprisePath] stringByAppendingPathComponent:kASDKAPITaskFormsPath] stringByAppendingPathComponent:@"%@"];
}

- (NSString *)taskFormVariablesPathFormat {
    return [[self taskFormServicePathFormat] stringByAppendingPathComponent:kASDKAPIVariablesFormPath];
}

- (NSString *)contentFieldUploadServicePath {
    return [[[kASDKAPIPath stringByAppendingPathComponent:kASDKAPIEnterprisePath] stringByAppendingPathComponent:kASDKAPIContentPath] stringByAppendingPathComponent:kASDKAPIContentRawPath];
}

- (NSString *)restFieldValuesServicePathFormat {
    return [[[[[kASDKAPIPath stringByAppendingPathComponent:kASDKAPIEnterprisePath] stringByAppendingPathComponent:kASDKAPITaskFormsPath] stringByAppendingPathComponent:@"%@"] stringByAppendingPathComponent:kASDKAPIFormValuesPath] stringByAppendingPathComponent:@"%@"];
}

- (NSString *)dynamicTableRestFieldValuesServicePathFormat {
    return [[[[[[kASDKAPIPath stringByAppendingPathComponent:kASDKAPIEnterprisePath] stringByAppendingPathComponent:kASDKAPITaskFormsPath] stringByAppendingPathComponent:@"%@"] stringByAppendingPathComponent:kASDKAPIFormValuesPath] stringByAppendingPathComponent:@"%@"] stringByAppendingPathComponent:@"%@"];
}

- (NSString *)startFormCompletionPath {
    return [[kASDKAPIPath stringByAppendingPathComponent:kASDKAPIEnterprisePath] stringByAppendingPathComponent:kASDKAPIProcessInstancesPath];
}

- (NSString *)startFormRestFieldValuesServicePathFormat {
    return [[[[[kASDKAPIPath stringByAppendingPathComponent:kASDKAPIEnterprisePath] stringByAppendingPathComponent:kASDKAPIProcessDefinitionPath] stringByAppendingPathComponent:@"%@"] stringByAppendingPathComponent:kASDKAPIStartFormValuesPath] stringByAppendingPathComponent:@"%@"];
}

- (NSString *)startFormDynamicTableRestFieldValuesServicePathFormat {
    return [[[[[[kASDKAPIPath stringByAppendingPathComponent:kASDKAPIEnterprisePath] stringByAppendingPathComponent:kASDKAPIProcessDefinitionPath] stringByAppendingPathComponent:@"%@"] stringByAppendingPathComponent:kASDKAPIStartFormValuesPath] stringByAppendingPathComponent:@"%@"] stringByAppendingPathComponent:@"%@"];
}

- (NSString *)saveFormServicePathFormat {
    return [[self taskFormServicePathFormat] stringByAppendingPathComponent:kASDKAPISaveFormPath];
}


#pragma mark -
#pragma mark Process related

- (NSString *)processDefinitionListServicePathFormat {
    return [[kASDKAPIPath stringByAppendingPathComponent:kASDKAPIEnterprisePath] stringByAppendingPathComponent:kASDKAPIProcessDefinitionPath];
}

- (NSString *)startProcessInstanceServicePath {
    return [[kASDKAPIPath stringByAppendingPathComponent:kASDKAPIEnterprisePath] stringByAppendingPathComponent:kASDKAPIProcessInstancesPath];
}

- (NSString *)processInstancesListServicePath {
    return [[[kASDKAPIPath stringByAppendingPathComponent:kASDKAPIEnterprisePath] stringByAppendingPathComponent:kASDKAPIProcessInstancesPath] stringByAppendingPathComponent:kASDKAPIFilterPath];
}

- (NSString *)processInstanceDetailsServicePathFormat {
    return [[[kASDKAPIPath stringByAppendingPathComponent:kASDKAPIEnterprisePath] stringByAppendingPathComponent:kASDKAPIProcessInstancesPath] stringByAppendingPathComponent:@"%@"];
}

- (NSString *)processInstanceContentServicePathFormat {
    return [[[[kASDKAPIPath stringByAppendingPathComponent:kASDKAPIEnterprisePath] stringByAppendingPathComponent:kASDKAPIProcessInstancesPath] stringByAppendingPathComponent:@"%@"] stringByAppendingPathComponent:kASDKAPIProcessContentPath];
}

- (NSString *)processInstanceCommentServicePathFormat {
    return [[self processInstanceDetailsServicePathFormat] stringByAppendingPathComponent:kASDKAPICommentPath];
}

- (NSString *)processInstanceAuditLogServicePathFormat {
    return [[[[kASDKAPIAppPath stringByAppendingPathComponent:kASDKAPIRestPath] stringByAppendingPathComponent:kASDKAPIProcessInstancesPath] stringByAppendingPathComponent:@"%@"] stringByAppendingPathComponent:kASDKAPIAuditPath];
}


#pragma mark -
#pragma mark User related

- (NSString *)userListServicePath {
    return [[kASDKAPIPath stringByAppendingPathComponent:kASDKAPIEnterprisePath] stringByAppendingPathComponent:kASDKAPIUsersPath];
}

- (NSString *)userProfileImageServicePathFormat {
    return [[[self userListServicePath] stringByAppendingPathComponent:@"%@"] stringByAppendingPathComponent:kASDKAPIUsersPicturePath];
}

- (NSString *)authenticationServicePath {
    return [kASDKAPIAppPath stringByAppendingPathComponent:kASDKAPIAppAuthentication];
}


#pragma mark -
#pragma mark Query related

- (NSString *)taskQueryServicePath {
    return [[[kASDKAPIPath stringByAppendingPathComponent:kASDKAPIEnterprisePath] stringByAppendingPathComponent:kASDKAPITasksPath] stringByAppendingPathComponent:kASDKAPIQueryPath];
}


#pragma mark -
#pragma mark Integration related

- (NSString *)integrationAccountsServicePath {
    return [[[kASDKAPIPath stringByAppendingPathComponent:kASDKAPIEnterprisePath] stringByAppendingPathComponent:kASDKAPIIntegrationAccountPath] stringByAppendingPathComponent:kASDKAPIIntegrationPath];
}

- (NSString *)integrationNetworksServicePathFormat {
    return [[[[kASDKAPIPath stringByAppendingPathComponent:kASDKAPIEnterprisePath] stringByAppendingPathComponent:kASDKAPIIntegrationPath] stringByAppendingPathComponent:@"%@"] stringByAppendingPathComponent:kASDKAPIIntegrationNetworksPath];
}

- (NSString *)integrationSitesServicePathFormat {
    return [[[self integrationNetworksServicePathFormat] stringByAppendingPathComponent:@"%@"] stringByAppendingPathComponent:kASDKAPIIntegrationSitesPath];
}

- (NSString *)integrationSiteContentServicePathFormat {
    return [[[self integrationSitesServicePathFormat] stringByAppendingPathComponent:@"%@"] stringByAppendingPathComponent:kASDKAPIContentPath];
}

- (NSString *)integrationFolderContentServicePathFormat {
    return [[[[[self integrationNetworksServicePathFormat] stringByAppendingPathComponent:@"%@"] stringByAppendingPathComponent:kASDKAPIIntegrationFoldersPath] stringByAppendingPathComponent:@"%@"] stringByAppendingPathComponent:kASDKAPIContentPath];
}

- (NSString *)integrationContentUploadServicePath {
    return [[kASDKAPIPath stringByAppendingPathComponent:kASDKAPIEnterprisePath] stringByAppendingPathComponent:kASDKAPIContentPath];
}

- (NSString *)integrationContentUploadForTaskServicePathFormat {
    return [[[[[kASDKAPIPath stringByAppendingPathComponent:kASDKAPIEnterprisePath] stringByAppendingPathComponent:kASDKAPITasksPath] stringByAppendingPathComponent:@"%@"] stringByAppendingPathComponent:kASDKAPIContentPath] stringByAppendingString:[NSString stringWithFormat:@"?%@=%@", kASDKAPIIsRelatedContentParameter, kASDKAPITrueParameter]];
}

@end

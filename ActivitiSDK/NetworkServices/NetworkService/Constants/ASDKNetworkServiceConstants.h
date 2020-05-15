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

// CSRF token
extern NSString *kASDKAPICSRFHeaderFieldParameter;
extern NSString *kASDKAPICSRFCookieName;

// Network API parameters
extern NSString *kASDKAPIIsRelatedContentParameter;
extern NSString *kASDKAPIContentUploadMultipartParameter;
extern NSString *kASDKAPIFormFieldParameter;
extern NSString *kASDKAPIGenericIDParameter;
extern NSString *kASDKAPIGenericNameParameter;
extern NSString *kASDKAPIAmountFormFieldCurrencyParameter;
extern NSString *kASDKAPIFileSourceFormFieldParameter;
extern NSString *kASDKAPIContentAvailableParameter;
extern NSString *kASDKAPIFormFieldTypeParameter;
extern NSString *kASDKAPILatestParameter;
extern NSString *kASDKAPIAppDefinitionIDParameter;
extern NSString *kASDKAPITrueParameter;
extern NSString *kASDKAPIUserIdParameter;
extern NSString *kASDKAPIProcessDefinitionIDParameter;
extern NSString *kASDKAPIMessageParameter;
extern NSString *kASDKAPIAssigneeParameter;
extern NSString *kASDKAPITableEditableParameter;
extern NSString *kASDKAPITypeParameter;
extern NSString *kASDKAPIParametersParameter;
extern NSString *kASDKAPIEmailParameter;

// Network API parameter values
extern NSString *kASDKAPIServiceIDAlfrescoCloud;
extern NSString *kASDKAPIServiceIDBox;
extern NSString *kASDKAPIServiceIDGoogleDrive;

// Network API response formats
extern NSString *kASDKAPISuccessfulResponseFormat;
extern NSString *kASDKAPIFailedResponseFormat;
extern NSString *kASDKAPIResponseFormat;

// Parser manager status formats
extern NSString *kASDKAPIParserManagerConversionErrorFormat;
extern NSString *kASDKAPIParserManagerConversionFormat;

// Reachability constants
extern NSString *kASDKAPINetworkServiceNoInternetConnection;
extern NSString *kASDKAPINetworkServiceInternetConnectionAvailable;

// Icon parameters
extern NSString *kASDKAPIIconNameInvolved;
extern NSString *kASDKAPIIconNameMy;
extern NSString *kASDKAPIIconNameQueued;
extern NSString *kASDKAPIIconNameCompleted;
extern NSString *kASDKAPIIconNameRunning;
extern NSString *kASDKAPIIconNameAll;

// Filter keys
extern NSString * const kASDKAPIJSONKeyData;
extern NSString * const kASDKAPIJSONKeyName;
extern NSString * const kASDKAPIJSONKeyFilter;
extern NSString * const kASDKAPIJSONKeyID;
extern NSString * const kASDKAPIJSONKeyContent;
extern NSString * const kASDKAPIJSONKeyApplicationID;

// Notification keys
extern NSString * const kADSKAPIUnauthorizedRequestNotification;

// Error doomain
extern NSString * const ASDKNetworkServiceErrorDomain;
extern NSInteger const  ASDKNetworkServiceErrorInvalidResponseFormat;

// AIMS session
extern NSTimeInterval kASDKSessionExpirationTimeIntervalCheck;
extern NSString * const kASDKAIMSJwtTokenPayload;

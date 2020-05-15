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

#import "ASDKNetworkServiceConstants.h"


#pragma mark -
#pragma mark CSRF token

NSString *kASDKAPICSRFHeaderFieldParameter                      = @"X-CSRF-TOKEN";
NSString *kASDKAPICSRFCookieName                                = @"CSRF-TOKEN";


#pragma mark -
#pragma mark Network API parameters

NSString *kASDKAPIIsRelatedContentParameter                     = @"isRelatedContent";
NSString *kASDKAPIContentUploadMultipartParameter               = @"file";
NSString *kASDKAPIFormFieldParameter                            = @"field";
NSString *kASDKAPIGenericIDParameter                            = @"id";
NSString *kASDKAPIGenericNameParameter                          = @"name";
NSString *kASDKAPIAmountFormFieldCurrencyParameter              = @"currency";
NSString *kASDKAPIFileSourceFormFieldParameter                  = @"fileSource";
NSString *kASDKAPIContentAvailableParameter                     = @"contentAvailable";
NSString *kASDKAPIFormFieldTypeParameter                        = @"fieldType";
NSString *kASDKAPILatestParameter                               = @"latest";
NSString *kASDKAPIAppDefinitionIDParameter                      = @"appDefinitionId";
NSString *kASDKAPITrueParameter                                 = @"true";
NSString *kASDKAPIUserIdParameter                               = @"userId";
NSString *kASDKAPIProcessDefinitionIDParameter                  = @"processDefinitionId";
NSString *kASDKAPIMessageParameter                              = @"message";
NSString *kASDKAPIAssigneeParameter                             = @"assignee";
NSString *kASDKAPITableEditableParameter                        = @"tableEditable";
NSString *kASDKAPITypeParameter                                 = @"type";
NSString *kASDKAPIParametersParameter                           = @"params";
NSString *kASDKAPIEmailParameter                                = @"email";


#pragma mark -
#pragma mark Network API parameter values

NSString *kASDKAPIServiceIDAlfrescoCloud                        = @"alfresco-cloud";
NSString *kASDKAPIServiceIDBox                                  = @"box";
NSString *kASDKAPIServiceIDGoogleDrive                          = @"google-drive";


#pragma mark -
#pragma mark Network API response formats

NSString *kASDKAPISuccessfulResponseFormat                      = @"Response: %@";
NSString *kASDKAPIFailedResponseFormat                          = @"Error: %@";
NSString *kASDKAPIResponseFormat                                = @"%@ - %@\nBody: %@\n";


#pragma mark -
#pragma mark Parser manager status formats
NSString *kASDKAPIParserManagerConversionErrorFormat            = @"Error parsing model object of type:%@. Reason:%@";
NSString *kASDKAPIParserManagerConversionFormat                 = @"Successfully parsed model object of type:%@. Content:%@";


#pragma mark -
#pragma mark Reachability constants

NSString *kASDKAPINetworkServiceNoInternetConnection            = @"NetworkServiceNoInternetConnection";
NSString *kASDKAPINetworkServiceInternetConnectionAvailable     = @"NetworkServiceInternetConnectionAvailable";


#pragma mark -
#pragma mark Icon parameters

NSString *kASDKAPIIconNameInvolved                              = @"glyphicon-align-left";
NSString *kASDKAPIIconNameMy                                    = @"glyphicon-inbox";
NSString *kASDKAPIIconNameQueued                                = @"glyphicon-record";
NSString *kASDKAPIIconNameCompleted                             = @"glyphicon-ok-sign";
NSString *kASDKAPIIconNameRunning                               = @"glyphicon-random";
NSString *kASDKAPIIconNameAll                                   = @"glyphicon-th";


#pragma mark -
#pragma mark Filter keys

NSString * const kASDKAPIJSONKeyData                            = @"data";
NSString * const kASDKAPIJSONKeyName                            = @"name";
NSString * const kASDKAPIJSONKeyFilter                          = @"filter";
NSString * const kASDKAPIJSONKeyID                              = @"id";
NSString * const kASDKAPIJSONKeyContent                         = @"content";
NSString * const kASDKAPIJSONKeyApplicationID                   = @"appId";


#pragma mark -
#pragma mark Notification keys

NSString * const kADSKAPIUnauthorizedRequestNotification        = @"com.alfresco.activiti.ActivitiSDK.networkService.responseSerializer";


#pragma mark -
#pragma mark Error domain

NSString * const ASDKNetworkServiceErrorDomain                  = @"ASDKNetworkServiceErrorDomain";
const NSInteger ASDKNetworkServiceErrorInvalidResponseFormat    = 1;

#pragma mark -
#pragma mark AIMS session

NSTimeInterval kASDKSessionExpirationTimeIntervalCheck          = 20;
NSString * const kASDKAIMSJwtTokenPayload                       = @"payload";

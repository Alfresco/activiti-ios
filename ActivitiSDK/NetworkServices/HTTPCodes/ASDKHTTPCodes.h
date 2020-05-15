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

#ifndef AlfrescoActiviti_ASDKHTTPCodes_h
#define AlfrescoActiviti_ASDKHTTPCodes_h

typedef NS_ENUM(NSUInteger, ASDKHTTPCode) {
    // Informational
    ASDKHTTPCode1XXInformationalUnknown = 1,
    ASDKHTTPCode100Continue = 100,
    ASDKHTTPCode101SwitchingProtocols = 101,
    ASDKHTTPCode102Processing = 102,
    
    // Success
    ASDKHTTPCode2XXSuccessUnknown = 2,
    ASDKHTTPCode200OK = 200,
    ASDKHTTPCode201Created = 201,
    ASDKHTTPCode202Accepted = 202,
    ASDKHTTPCode203NonAuthoritativeInformation = 203,
    ASDKHTTPCode204NoContent = 204,
    ASDKHTTPCode205ResetContent = 205,
    ASDKHTTPCode206PartialContent = 206,
    ASDKHTTPCode207MultiStatus = 207,
    ASDKHTTPCode208AlreadyReported = 208,
    ASDKHTTPCode209IMUsed = 209,
    
    // Redirection
    ASDKHTTPCode3XXSuccessUnknown = 3,
    ASDKHTTPCode300MultipleChoices = 300,
    ASDKHTTPCode301MovedPermanently = 301,
    ASDKHTTPCode302Found = 302,
    ASDKHTTPCode303SeeOther = 303,
    ASDKHTTPCode304NotModified = 304,
    ASDKHTTPCode305UseProxy = 305,
    ASDKHTTPCode306SwitchProxy = 306,
    ASDKHTTPCode307TemporaryRedirect = 307,
    ASDKHTTPCode308PermanentRedirect = 308,
    
    // Client error
    ASDKHTTPCode4XXSuccessUnknown = 4,
    ASDKHTTPCode400BadRequest = 400,
    ASDKHTTPCode401Unauthorised = 401,
    ASDKHTTPCode402PaymentRequired = 402,
    ASDKHTTPCode403Forbidden = 403,
    ASDKHTTPCode404NotFound = 404,
    ASDKHTTPCode405MethodNotAllowed = 405,
    ASDKHTTPCode406NotAcceptable = 406,
    ASDKHTTPCode407ProxyAuthenticationRequired = 407,
    ASDKHTTPCode408RequestTimeout = 408,
    ASDKHTTPCode409Conflict = 409,
    ASDKHTTPCode410Gone = 410,
    ASDKHTTPCode411LengthRequired = 411,
    ASDKHTTPCode412PreconditionFailed = 412,
    ASDKHTTPCode413RequestEntityTooLarge = 413,
    ASDKHTTPCode414RequestURITooLong = 414,
    ASDKHTTPCode415UnsupportedMediaType = 415,
    ASDKHTTPCode416RequestedRangeNotSatisfiable = 416,
    ASDKHTTPCode417ExpectationFailed = 417,
    ASDKHTTPCode418IamATeapot = 418,
    ASDKHTTPCode419AuthenticationTimeout = 419,
    ASDKHTTPCode420MethodFailureSpringFramework = 420,
    ASDKHTTPCode420EnhanceYourCalmTwitter = 4200,
    ASDKHTTPCode422UnprocessableEntity = 422,
    ASDKHTTPCode423Locked = 423,
    ASDKHTTPCode424FailedDependency = 424,
    ASDKHTTPCode424MethodFailureWebDaw = 4240,
    ASDKHTTPCode425UnorderedCollection = 425,
    ASDKHTTPCode426UpgradeRequired = 426,
    ASDKHTTPCode428PreconditionRequired = 428,
    ASDKHTTPCode429TooManyRequests = 429,
    ASDKHTTPCode431RequestHeaderFieldsTooLarge = 431,
    ASDKHTTPCode444NoResponseNginx = 444,
    ASDKHTTPCode449RetryWithMicrosoft = 449,
    ASDKHTTPCode450BlockedByWindowsParentalControls = 450,
    ASDKHTTPCode451RedirectMicrosoft = 451,
    ASDKHTTPCode451UnavailableForLegalReasons = 4510,
    ASDKHTTPCode494RequestHeaderTooLargeNginx = 494,
    ASDKHTTPCode495CertErrorNginx = 495,
    ASDKHTTPCode496NoCertNginx = 496,
    ASDKHTTPCode497HTTPToHTTPSNginx = 497,
    ASDKHTTPCode499ClientClosedRequestNginx = 499,
    
    
    // Server error
    ASDKHTTPCode5XXSuccessUnknown = 5,
    ASDKHTTPCode500InternalServerError = 500,
    ASDKHTTPCode501NotImplemented = 501,
    ASDKHTTPCode502BadGateway = 502,
    ASDKHTTPCode503ServiceUnavailable = 503,
    ASDKHTTPCode504GatewayTimeout = 504,
    ASDKHTTPCode505HTTPVersionNotSupported = 505,
    ASDKHTTPCode506VariantAlsoNegotiates = 506,
    ASDKHTTPCode507InsufficientStorage = 507,
    ASDKHTTPCode508LoopDetected = 508,
    ASDKHTTPCode509BandwidthLimitExceeded = 509,
    ASDKHTTPCode510NotExtended = 510,
    ASDKHTTPCode511NetworkAuthenticationRequired = 511,
    ASDKHTTPCode522ConnectionTimedOut = 522,
    ASDKHTTPCode598NetworkReadTimeoutErrorUnknown = 598,
    ASDKHTTPCode599NetworkConnectTimeoutErrorUnknown = 599
};


#endif

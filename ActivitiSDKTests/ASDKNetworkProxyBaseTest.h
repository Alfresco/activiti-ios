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

#import "ASDKBaseTest.h"

typedef void (^ASDKTestRequestSuccessBlock)(NSURLSessionDataTask *task, id responseObject);
typedef void (^ASDKTestRequestFailureBlock)(NSURLSessionDataTask *task, NSError *error);
typedef void (^ASDKTestRequestProgressBlock)(NSProgress *uploadProgress);

@interface ASDKNetworkProxyBaseTest : ASDKBaseTest

@property (strong, nonatomic) ASDKParserOperationManager *parserOperationManager;

- (NSURLSessionDataTask *)dataTaskWithStatusCode:(ASDKHTTPCode)statusCode
                                            error:(NSError *)error;
- (NSURLSessionDataTask *)dataTaskWithStatusCode:(ASDKHTTPCode)statusCode;

- (NSURLSessionDownloadTask *)downloadTaskWithStatusCode:(ASDKHTTPCode)statusCode;
- (NSURLSessionDownloadTask *)downloadTaskWithStatusCode:(ASDKHTTPCode)statusCode
                                                   error:(NSError *)error;

- (NSError *)requestGenericError;

@end

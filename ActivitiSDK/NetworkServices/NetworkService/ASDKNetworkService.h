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

@import AFNetworking;
#import <Foundation/Foundation.h>
#import "ASDKNetworkServiceProtocol.h"
#import "ASDKParserOperationManager.h"
#import "ASDKServicePathFactory.h"
#import "ASDKHTTPCodes.h"
#import "ASDKDiskServices.h"
#import "ASDKRequestOperationManager.h"
#import "ASDKCSRFTokenStorage.h"

typedef NS_ENUM(NSInteger, ASDKNetworkServiceRequestSerializerType) {
    ASDKNetworkServiceRequestSerializerTypeJSON,
    ASDKNetworkServiceRequestSerializerTypeHTTP,
    ASDKNetworkServiceRequestSerializerTypeHTTPWithCSRFToken
};

@interface ASDKNetworkService : NSObject <ASDKNetworkServiceProtocol>

@property (strong, nonatomic) ASDKRequestOperationManager   *requestOperationManager;
@property (strong, nonatomic) ASDKParserOperationManager    *parserOperationManager;
@property (strong, nonatomic) ASDKServicePathFactory        *servicePathFactory;
@property (strong, nonatomic) ASDKDiskServices              *diskServices;
@property (strong, nonatomic) ASDKCSRFTokenStorage          *tokenStorage;
@property (strong, nonatomic) dispatch_queue_t              resultsQueue;

- (instancetype)initWithRequestManager:(ASDKRequestOperationManager *)requestOperationManager
                         parserManager:(ASDKParserOperationManager *)parserManager
                    servicePathFactory:(ASDKServicePathFactory *)servicePathFactory
                          diskServices:(ASDKDiskServices *)diskServices
                          resultsQueue:(dispatch_queue_t)resultsQueue;

- (AFHTTPRequestSerializer *)requestSerializerOfType:(ASDKNetworkServiceRequestSerializerType)serializerType;
- (void)configureWithCSRFTokenStorage:(ASDKCSRFTokenStorage *)tokenStorage;

@end

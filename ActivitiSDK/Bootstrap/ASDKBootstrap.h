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
#import "ASDKModelCredentialBaseProtocol.h"

@class ASDKServiceLocator, ASDKModelServerConfiguration, AFHTTPRequestSerializer;

@interface ASDKBootstrap : NSObject

// Singleton interface
+ (instancetype)sharedInstance;
+ (instancetype)alloc __attribute__((unavailable("alloc not available with ASDKBootstrap, call sharedInstance instead")));
+ (instancetype)new __attribute__((unavailable("new not available with ASDKBootstrap, call sharedInstance instead")));
- (instancetype)init __attribute__((unavailable("init not available with ASDKBootstrap, call sharedInstance instead")));

// Services interface
- (void)setupServicesWithServerConfiguration:(ASDKModelServerConfiguration *)serverConfiguration;
- (void)updateServerConfigurationForCredential:(id<ASDKModelCredentialBaseProtocol>)credential;

// Read-only properties
@property (strong, nonatomic, readonly) ASDKServiceLocator              *serviceLocator;
@property (strong, nonatomic, readonly) ASDKModelServerConfiguration    *serverConfiguration;

@end

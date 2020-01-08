/*******************************************************************************
 * Copyright (C) 2005-2018 Alfresco Software Limited.
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

#import "AFACredentialModel.h"
@import ActivitiSDK;

@implementation AFACredentialModel

- (instancetype)init {
    self = [super init];
    if (self) {
        _serverConfiguration = [ASDKModelServerConfiguration new];
    }
    
    return self;
}


#pragma mark -
#pragma mark Getters

- (ASDKModelServerConfiguration *)serverConfiguration {
    _serverConfiguration.hostAddressString = _hostname;
    _serverConfiguration.port = _port;
    _serverConfiguration.serviceDocument = _serviceDocument;
    _serverConfiguration.isCommunicationOverSecureLayer = _isCommunicationOverSecureLayer;
    
    ASDKModelCredentialBaseAuth *baseAuthCredential = [[ASDKModelCredentialBaseAuth alloc] initWithUsername:_username password:_password];
    _serverConfiguration.credential = baseAuthCredential;
    
    return _serverConfiguration;
}

@end

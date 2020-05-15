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

#import "ASDKIntegrationCacheMapper.h"

// Models
#import "ASDKModelIntegrationAccount.h"
#import "ASDKMOIntegrationAccount.h"

@implementation ASDKIntegrationCacheMapper

+ (ASDKMOIntegrationAccount *)mapIntegrationAccount:(ASDKModelIntegrationAccount *)integrationAccount
                                          toCacheMO:(ASDKMOIntegrationAccount *)moIntegrationAccount {
    moIntegrationAccount.integrationServiceID = integrationAccount.integrationServiceID;
    moIntegrationAccount.isAccountAuthorized = integrationAccount.isAccountAuthorized;
    moIntegrationAccount.authorizationURLString = integrationAccount.authorizationURLString;
    moIntegrationAccount.isMetadataAllowed = integrationAccount.isMetadataAllowed;
    
    return moIntegrationAccount;
}

+ (ASDKModelIntegrationAccount *)mapCacheMOToIntegrationAccount:(ASDKMOIntegrationAccount *)moIntegrationAccount {
    ASDKModelIntegrationAccount *integrationAccount = [ASDKModelIntegrationAccount new];
    integrationAccount.integrationServiceID = moIntegrationAccount.integrationServiceID;
    integrationAccount.isAccountAuthorized = moIntegrationAccount.isAccountAuthorized;
    integrationAccount.authorizationURLString = moIntegrationAccount.authorizationURLString;
    integrationAccount.isMetadataAllowed = moIntegrationAccount.isMetadataAllowed;
    
    return integrationAccount;
}

@end

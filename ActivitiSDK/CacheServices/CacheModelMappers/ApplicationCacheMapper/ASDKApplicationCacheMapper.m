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

#import "ASDKApplicationCacheMapper.h"

// Models
#import "ASDKModelApp.h"
#import "ASDKMOApp.h"

@implementation ASDKApplicationCacheMapper

+ (ASDKMOApp *)mapApp:(ASDKModelApp *)app
            toCacheMO:(ASDKMOApp *)moApp {
    moApp.modelID = app.modelID;
    moApp.applicationDescription = app.applicationDescription;
    moApp.applicationModelID = app.applicationModelID;
    moApp.deploymentID = app.deploymentID;
    moApp.icon = app.icon;
    moApp.name = app.name;
    moApp.tenantID = app.tenantID;
    moApp.theme = app.theme;
    
    return moApp;
}

+ (ASDKModelApp *)mapCacheMOToApp:(ASDKMOApp *)moApp {
    ASDKModelApp *app = [ASDKModelApp new];
    app.modelID = moApp.modelID;
    app.applicationDescription = moApp.applicationDescription;
    app.applicationModelID = moApp.applicationModelID;
    app.deploymentID = moApp.deploymentID;
    app.icon = moApp.icon;
    app.name = moApp.name;
    app.tenantID = moApp.tenantID;
    app.theme = moApp.theme;
    
    return app;
}

@end

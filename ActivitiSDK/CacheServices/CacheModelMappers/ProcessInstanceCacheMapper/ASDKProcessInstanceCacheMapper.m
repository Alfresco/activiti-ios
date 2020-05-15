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

#import "ASDKProcessInstanceCacheMapper.h"

// Models
#import "ASDKMOProcessInstance.h"
#import "ASDKModelProcessInstance.h"
#import "ASDKModelProfile.h"

// Mappers
#import "ASDKProfileCacheMapper.h"

@implementation ASDKProcessInstanceCacheMapper

+ (ASDKMOProcessInstance *)mapProcessInstance:(ASDKModelProcessInstance *)processInstance
                                    toCacheMO:(ASDKMOProcessInstance *)moProcessInstance {
    moProcessInstance.modelID = processInstance.modelID;
    moProcessInstance.name = processInstance.name;
    moProcessInstance.endDate = processInstance.endDate;
    moProcessInstance.startDate = processInstance.startDate;
    moProcessInstance.tenantID = processInstance.tenantID;
    moProcessInstance.processDefinitionVersion = processInstance.processDefinitionVersion;
    moProcessInstance.processDefinitionCategory = processInstance.processDefinitionCategory;
    moProcessInstance.processDefinitionDeploymentID = processInstance.processDefinitionDeploymentID;
    moProcessInstance.processDefinitionDescription = processInstance.processDefinitionDescription;
    moProcessInstance.processDefinitionID = processInstance.processDefinitionID;
    moProcessInstance.processDefinitionKey = processInstance.processDefinitionKey;
    moProcessInstance.processDefinitionName = processInstance.processDefinitionName;
    
    /* Ignore start form flag set up if it has been previously set to true. The API provides this
     * value just when requesting the process instance details and if the cached data comes
     * from a process instance list REST API call it will have the flag set to false overriding
     * cached values. Technically if a process instance has been started with a form it will always
     * return true so the assumption to ignore the flag is valid in this case.
     */
    if (!moProcessInstance.isStartFormDefined) {
        moProcessInstance.isStartFormDefined = processInstance.isStartFormDefined;
    }
    
    return moProcessInstance;
}

+ (ASDKModelProcessInstance *)mapCacheMOToProcessInstance:(ASDKMOProcessInstance *)moProcessInstance {
    ASDKModelProcessInstance *processInstance = [ASDKModelProcessInstance new];
    processInstance.modelID = moProcessInstance.modelID;
    processInstance.name = moProcessInstance.name;
    processInstance.endDate = moProcessInstance.endDate;
    processInstance.startDate = moProcessInstance.startDate;
    processInstance.tenantID = moProcessInstance.tenantID;
    processInstance.processDefinitionVersion = moProcessInstance.processDefinitionVersion;
    processInstance.processDefinitionCategory = moProcessInstance.processDefinitionCategory;
    processInstance.processDefinitionDeploymentID = moProcessInstance.processDefinitionDeploymentID;
    processInstance.processDefinitionDescription = moProcessInstance.processDefinitionDescription;
    processInstance.processDefinitionID = moProcessInstance.processDefinitionID;
    processInstance.processDefinitionKey = moProcessInstance.processDefinitionKey;
    processInstance.processDefinitionName = moProcessInstance.processDefinitionName;
    processInstance.isStartFormDefined = moProcessInstance.isStartFormDefined;
    
    if (moProcessInstance.initiator) {
        ASDKModelProfile *profile = [ASDKProfileCacheMapper mapCacheMOToProfile:moProcessInstance.initiator];
        processInstance.initiatorModel = profile;
    }
    
    return processInstance;
}

@end

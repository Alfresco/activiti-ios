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

#import "ASDKProcessDefinitionCacheMapper.h"

// Models
#import "ASDKModelProcessDefinition.h"
#import "ASDKMOProcessDefinition.h"

@implementation ASDKProcessDefinitionCacheMapper

+ (ASDKMOProcessDefinition *)mapProcessDefinition:(ASDKModelProcessDefinition *)processDefinition
                                        toCacheMO:(ASDKMOProcessDefinition *)moProcessDefinition {
    moProcessDefinition.modelID = processDefinition.modelID;
    moProcessDefinition.name = processDefinition.name;
    moProcessDefinition.definitionDescription = processDefinition.definitionDescription;
    moProcessDefinition.key = processDefinition.key;
    moProcessDefinition.category = processDefinition.category;
    moProcessDefinition.version = processDefinition.version;
    moProcessDefinition.deploymentID = processDefinition.deploymentID;
    moProcessDefinition.tenantID = processDefinition.tenantID;
    moProcessDefinition.hasStartForm = processDefinition.hasStartForm;
    
    return moProcessDefinition;
}

+ (ASDKModelProcessDefinition *)mapCacheMOToProcessInstance:(ASDKMOProcessDefinition *)moProcessDefinition {
    ASDKModelProcessDefinition *processDefinition = [ASDKModelProcessDefinition new];
    processDefinition.modelID = moProcessDefinition.modelID;
    processDefinition.name = moProcessDefinition.name;
    processDefinition.definitionDescription = moProcessDefinition.definitionDescription;
    processDefinition.key = moProcessDefinition.key;
    processDefinition.category = moProcessDefinition.category;
    processDefinition.version = moProcessDefinition.version;
    processDefinition.deploymentID = moProcessDefinition.deploymentID;
    processDefinition.tenantID = moProcessDefinition.tenantID;
    processDefinition.hasStartForm = moProcessDefinition.hasStartForm;
    
    return processDefinition;
}

@end

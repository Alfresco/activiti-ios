/*******************************************************************************
 * Copyright (C) 2005-2017 Alfresco Software Limited.
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

#import "ASDKProcessInstanceContentFieldCacheMapper.h"

// Models
#import "ASDKMOProcessInstanceContentField.h"
#import "ASDKModelProcessInstanceContentField.h"

@implementation ASDKProcessInstanceContentFieldCacheMapper

+ (ASDKMOProcessInstanceContentField *)mapProcessInstanceContentField:(ASDKModelProcessInstanceContentField *)processInstanceContentField
                                                            toCacheMO:(ASDKMOProcessInstanceContentField *)moProcessInstanceContentField {
    moProcessInstanceContentField.modelID = processInstanceContentField.modelID;
    moProcessInstanceContentField.name = processInstanceContentField.name;
    
    return moProcessInstanceContentField;
}

+ (ASDKModelProcessInstanceContentField *)mapCacheMOToProcessInstanceContentField:(ASDKMOProcessInstanceContentField *)moProcessInstanceContentField {
    ASDKModelProcessInstanceContentField *processInstanceContentField = [ASDKModelProcessInstanceContentField new];
    processInstanceContentField.modelID = moProcessInstanceContentField.modelID;
    processInstanceContentField.name = moProcessInstanceContentField.name;
    
    return processInstanceContentField;
}

@end

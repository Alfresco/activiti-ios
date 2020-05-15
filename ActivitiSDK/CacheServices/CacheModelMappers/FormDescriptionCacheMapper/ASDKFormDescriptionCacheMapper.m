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

#import "ASDKFormDescriptionCacheMapper.h"

// Models
#import "ASDKMOFormDescription.h"
#import "ASDKModelFormDescription.h"

@implementation ASDKFormDescriptionCacheMapper

+ (ASDKMOFormDescription *)mapFormDescription:(ASDKModelFormDescription *)formDescription
                                forTaskWithID:(NSString *)taskID
                                    toCacheMO:(ASDKMOFormDescription *)moFormDescription {
    moFormDescription.taskID = taskID;
    moFormDescription.formDescription = formDescription;
    
    return moFormDescription;
}

+ (ASDKMOFormDescription *)mapFormDescription:(ASDKModelFormDescription *)formDescription
                         forProcessInstanceID:(NSString *)processInstanceID
                                    toCacheMO:(ASDKMOFormDescription *)moFormDescription {
    moFormDescription.processInstanceID = processInstanceID;
    moFormDescription.formDescription = formDescription;
    
    return moFormDescription;
}

+ (ASDKMOFormDescription *)mapFormDescription:(ASDKModelFormDescription *)formDescription
                       forProcessDefinitionID:(NSString *)processDefinitionID
                                    toCacheMO:(ASDKMOFormDescription *)moFormDescription {
    moFormDescription.processDefinitionID = processDefinitionID;
    moFormDescription.formDescription = formDescription;
    
    return moFormDescription;
}

+ (ASDKModelFormDescription *)mapCacheMOToFormDescription:(ASDKMOFormDescription *)moFormDescription {
    return (ASDKModelFormDescription *)moFormDescription.formDescription;
}

@end

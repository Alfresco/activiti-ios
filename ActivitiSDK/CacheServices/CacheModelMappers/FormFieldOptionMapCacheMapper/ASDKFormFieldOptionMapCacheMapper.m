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

#import "ASDKFormFieldOptionMapCacheMapper.h"

// Models
#import "ASDKMOFormFieldOptionMap.h"

@implementation ASDKFormFieldOptionMapCacheMapper

+ (ASDKMOFormFieldOptionMap *)mapRestFieldValueList:(NSArray *)restFieldValueList
                                          forTaskID:(NSString *)taskID
                                    withFormFieldID:(NSString *)fieldID
                                          toCacheMO:(ASDKMOFormFieldOptionMap *)moFormFieldOptionMap {
    moFormFieldOptionMap.taskID = taskID;
    moFormFieldOptionMap.formFieldID = fieldID;
    [moFormFieldOptionMap addRestFieldValueList:[NSSet setWithArray:restFieldValueList]];
    
    return moFormFieldOptionMap;
}

+ (ASDKMOFormFieldOptionMap *)mapRestFieldValueList:(NSArray *)restFieldValueList
                             forProcessDefinitionID:(NSString *)processDefinitionID
                                    withFormFieldID:(NSString *)fieldID
                                          toCacheMO:(ASDKMOFormFieldOptionMap *)moFormFieldOptionMap {
    moFormFieldOptionMap.processDefinitionID = processDefinitionID;
    moFormFieldOptionMap.formFieldID = fieldID;
    
    [moFormFieldOptionMap addRestFieldValueList:[NSSet setWithArray:restFieldValueList]];
    
    return moFormFieldOptionMap;
}

+ (ASDKMOFormFieldOptionMap *)mapRestFieldValueList:(NSArray *)restFieldValueList
                                          forTaskID:(NSString *)taskID
                                    withFormFieldID:(NSString *)fieldID
                                       withColumnID:(NSString *)columnID
                                          toCacheMO:(ASDKMOFormFieldOptionMap *)moFormFieldOptionMap {
    moFormFieldOptionMap.taskID = taskID;
    moFormFieldOptionMap.formFieldID = fieldID;
    moFormFieldOptionMap.columnID = columnID;
    
    [moFormFieldOptionMap addRestFieldValueList:[NSSet setWithArray:restFieldValueList]];
    return moFormFieldOptionMap;
}

+ (ASDKMOFormFieldOptionMap *)mapRestFieldValueList:(NSArray *)restFieldValueList
                             forProcessDefinitionID:(NSString *)processDefinitionID
                                    withFormFieldID:(NSString *)fieldID
                                       withColumnID:(NSString *)columnID
                                          toCacheMO:(ASDKMOFormFieldOptionMap *)moFormFieldOptionMap {
    moFormFieldOptionMap.processDefinitionID = processDefinitionID;
    moFormFieldOptionMap.formFieldID = fieldID;
    moFormFieldOptionMap.columnID = columnID;
    
    [moFormFieldOptionMap addRestFieldValueList:[NSSet setWithArray:restFieldValueList]];
    return moFormFieldOptionMap;
}

@end

/*******************************************************************************
 * Copyright (C) 2005-2016 Alfresco Software Limited.
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

#import "ASDKModelFormDescription.h"
#import "ASDKModelFormField.h"
#import "ASDKModelFormOutcome.h"
#import "ASDKModelFormVariable.h"

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

@implementation ASDKModelFormDescription


#pragma mark -
#pragma mark MTLJSONSerializing Delegate

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    NSMutableDictionary *inheretedPropertyKeys = [NSMutableDictionary dictionaryWithDictionary:[super JSONKeyPathsByPropertyKey]];
    
    if (inheretedPropertyKeys.allKeys.count) {
        [inheretedPropertyKeys addEntriesFromDictionary:@{//Objc property                 JSON property
                                                          @"processDefinitionID"        : @"processDefinitionId",
                                                          @"processDefinitionName"      : @"processDefinitionName",
                                                          @"processDefinitionKey"       : @"processDefinitionKey",
                                                          @"formFields"                 : @"fields",
                                                          @"formOutcomes"               : @"outcomes",
                                                          @"formVariables"              : @"variables"
                                                          }];
    }
    return inheretedPropertyKeys;
}


#pragma mark -
#pragma mark Value transformations

+ (NSValueTransformer *)formFieldsJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:ASDKModelFormField.class];
}

+ (NSValueTransformer *)formOutcomesJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:ASDKModelFormOutcome.class];
}

+ (NSValueTransformer *)formVariablesJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:ASDKModelFormVariable.class];
}

@end

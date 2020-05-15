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

#import "ASDKModelPeopleFormField.h"
#import "ASDKModelUser.h"

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

static const int activitiSDKLogLevel = ASDK_LOG_LEVEL_VERBOSE; // | ASDK_LOG_FLAG_TRACE;

@implementation ASDKModelPeopleFormField


#pragma mark -
#pragma mark MTLJSONSerializing Delegate

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    NSMutableDictionary *inheretedPropertyKeys = [NSMutableDictionary dictionaryWithDictionary:[super JSONKeyPathsByPropertyKey]];
    
    return inheretedPropertyKeys;
}


#pragma mark -
#pragma mark Value transformations

+ (NSValueTransformer *)valuesJSONTransformer {    
    return [MTLValueTransformer transformerUsingForwardBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
        if (value) {
            if ([value isKindOfClass:[NSArray class]]) {
                if (!((NSArray *)value).count) {
                    return nil;
                } else {
                    NSError *peopleValuesParseError = nil;
                    NSArray *peopleValues = [MTLJSONAdapter modelsOfClass:ASDKModelUser.class
                                                            fromJSONArray:value
                                                                    error:&peopleValuesParseError];
                    if (peopleValuesParseError) {
                        ASDKLogVerbose(@"Cannot parse people values to user model. Reason:%@", peopleValuesParseError.localizedDescription);
                    }
                    return peopleValues;
                }
            } else {
                NSError *peopleValueParseError = nil;
                ASDKModelUser *peopleValue = [MTLJSONAdapter modelOfClass:ASDKModelUser.class
                                                       fromJSONDictionary:value
                                                                    error:&peopleValueParseError];
                if (peopleValueParseError) {
                    ASDKLogVerbose(@"Cannot parse people value to user model. Reason:%@", peopleValueParseError.localizedDescription);
                }
                
                return @[peopleValue];
            }
        }
        
        return nil;
    }];
}

@end

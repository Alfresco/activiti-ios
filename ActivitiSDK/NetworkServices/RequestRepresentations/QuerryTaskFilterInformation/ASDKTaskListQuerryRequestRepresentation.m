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

#import "ASDKTaskListQuerryRequestRepresentation.h"

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

@implementation ASDKTaskListQuerryRequestRepresentation

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    NSMutableDictionary *inheretedPropertyKeys = [NSMutableDictionary dictionaryWithDictionary:[super JSONKeyPathsByPropertyKey]];
    [inheretedPropertyKeys addEntriesFromDictionary:@{//Objc property         JSON property
                                                      @"processInstanceID"  : @"processInstanceId",
                                                      @"requestTaskState"   : @"state"}];
    
    return inheretedPropertyKeys;
}


#pragma mark -
#pragma mark Value transformations

+ (NSValueTransformer *)appIDJSONTransformer {
    return self.valueTransformerForIDs;
}

+ (NSValueTransformer *)requestTaskStateJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSString *value, BOOL *success, NSError *__autoreleasing *error) {
        if ([@"active" isEqualToString:value]) {
            return @(ASDKTaskListQuerryStateTypeActive);
        } else if ([@"completed" isEqualToString:value]) {
            return @(ASDKTaskListQuerryStateTypeCompleted);
        }
        
        return @(ASDKTaskListQuerryStateTypeUndefined);
    } reverseBlock:^id(NSNumber *value, BOOL *success, NSError *__autoreleasing *error) {
        switch ([value integerValue]) {
            case ASDKTaskListQuerryStateTypeActive: {
                return @"active";
            }
                break;
                
            case ASDKTaskListQuerryStateTypeCompleted: {
                return @"completed";
            }
                break;
                
            default:
                break;
        }
        
        return [NSNull null];
    }];
}

@end

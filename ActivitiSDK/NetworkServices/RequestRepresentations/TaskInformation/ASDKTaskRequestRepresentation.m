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

#import "ASDKTaskRequestRepresentation.h"

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

@implementation ASDKTaskRequestRepresentation


#pragma mark -
#pragma mark Life cycle 

- (instancetype)init {
    self = [super init];
    
    if (self) {
        self.assignmentType = ASDKTaskAssignmentTypeUndefined;
    }
    
    return self;
}


#pragma mark -
#pragma mark MTLJSONSerializing Delegate

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    NSMutableDictionary *inheretedPropertyKeys = [NSMutableDictionary dictionaryWithDictionary:[super JSONKeyPathsByPropertyKey]];
    [inheretedPropertyKeys addEntriesFromDictionary:@{//Objc property         JSON property
                                                      @"taskName"           : @"text",
                                                      @"appDefinitionID"    : @"appDefinitionId",
                                                      @"processDefinitionID": @"processDefinitionId",
                                                      @"assigneeID"         : @"assignee",
                                                      @"candidateID"        : @"candidate",
                                                      @"assignmentType"     : @"assignment",
                                                      @"requestTaskState"   : @"state"}];
    
    return inheretedPropertyKeys;
}


#pragma mark -
#pragma mark Value transformations

+ (NSValueTransformer *)assignmentTypeJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSString *value, BOOL *success, NSError *__autoreleasing *error) {
        if (!value.length) {
            return @(ASDKTaskAssignmentTypeInvolved);
        } else if ([@"assignee" isEqualToString:value]) {
            return @(ASDKTaskAssignmentTypeAssignee);
        } else if ([@"candidate" isEqualToString:value]) {
            return @(ASDKTaskAssignmentTypeCandidate);
        }
        
        return !value.length ? @(ASDKTaskAssignmentTypeInvolved) : @(ASDKTaskAssignmentTypeUndefined);
    } reverseBlock:^id(NSNumber *value, BOOL *success, NSError *__autoreleasing *error) {
        switch ([value integerValue]) {
            case ASDKTaskAssignmentTypeInvolved: {
                return @"";
            }
                break;
                
            case ASDKTaskAssignmentTypeAssignee: {
                return @"assignee";
            }
                
            case ASDKTaskAssignmentTypeCandidate: {
                return @"candidate";
            }
                
            default:
                break;
        }
        
        return [NSNull null];
    }];
}

+ (NSValueTransformer *)taskStateJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSString *value, BOOL *success, NSError *__autoreleasing *error) {
        if ([@"active" isEqualToString:value]) {
            return @(ASDKTaskStateTypeActive);
        } else if ([@"completed" isEqualToString:value]) {
            return @(ASDKTaskStateTypeCompleted);
        }
        
        return @(ASDKTaskStateTypeUndefined);
    } reverseBlock:^id(NSNumber *value, BOOL *success, NSError *__autoreleasing *error) {
        switch ([value integerValue]) {
            case ASDKTaskStateTypeActive: {
                return @"active";
            }
                break;
                
            case ASDKTaskStateTypeCompleted: {
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

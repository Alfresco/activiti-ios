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

#import "ASDKModelFormVisibilityCondition.h"

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

@implementation ASDKModelFormVisibilityCondition


#pragma mark -
#pragma mark MTLJSONSerializing Delegate

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    NSMutableDictionary *inheretedPropertyKeys = [NSMutableDictionary dictionaryWithDictionary:[super JSONKeyPathsByPropertyKey]];
    [inheretedPropertyKeys addEntriesFromDictionary:@{//Objc property          JSON property
                                                      @"leftFormFieldID"       : @"leftFormFieldId",
                                                      @"leftRestResponseID"    : @"leftRestResponseId",
                                                      @"operationOperator"     : @"operator",
                                                      @"rightValue"            : @"rightValue",
                                                      @"rightFormFieldID"      : @"rightFormFieldId",
                                                      @"rightRestResponseID"   : @"rightRestResponseId",
                                                      @"nextConditionOperator" : @"nextConditionOperator",
                                                      @"nextCondition"         : @"nextCondition"}];
    
    return inheretedPropertyKeys;
}


#pragma mark -
#pragma mark Value transformations

+ (NSValueTransformer *)nextConditionJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:ASDKModelFormVisibilityCondition.class];
}

+ (NSValueTransformer *)rightValueJSONTransformer {
    return [self valueTransformerForIDs];
}

+ (NSValueTransformer *)operationOperatorJSONTransformer {
    return [NSValueTransformer mtl_valueMappingTransformerWithDictionary:
            @{@"=="         : @(ASDKModelFormVisibilityConditionOperatorTypeEqual),
              @"!="         : @(ASDKModelFormVisibilityConditionOperatorTypeNotEqual),
              @"<"          : @(ASDKModelFormVisibilityConditionOperatorTypeLessThan),
              @"<="         : @(ASDKModelFormVisibilityConditionOperatorTypeLessOrEqualThan),
              @">"          : @(ASDKModelFormVisibilityConditionOperatorTypeGreaterThan),
              @">="         : @(ASDKModelFormVisibilityConditionOperatorTypeGreatOrEqualThan),
              @"empty"      : @(ASDKModelFormVisibilityConditionOperatorTypeEmpty),
              @"!empty"     : @(ASDKModelFormVisibilityConditionOperatorTypeNotEmpty)}];
}

+ (NSValueTransformer *)nextConditionOperatorJSONTransformer {
    return [NSValueTransformer mtl_valueMappingTransformerWithDictionary:
            @{@""           : @(ASDKModelFormVisibilityConditionNextConditionOperatorTypeUndefined),
              @"and"        : @(ASDKModelFormVisibilityConditionNextConditionOperatorTypeAnd),
              @"and not"    : @(ASDKModelFormVisibilityConditionNextConditionOperatorTypeAndNot),
              @"or"         : @(ASDKModelFormVisibilityConditionNextConditionOperatorTypeOr),
              @"or not"     : @(ASDKModelFormVisibilityConditionNextConditionOperatorTypeOrNot)}];
}


#pragma mark -
#pragma mark KVC Override

/**
 *  If for some reason the API changes, or is unavailable in the API result,
 *  or it so happens that a mapped key is not found as described in this model
 *  (the base class construct might not accomodate every API endpoint), KVC will
 *  ask to replace nil when the field is of scalar type. In the current context
 *  this can happen when trying to set the enum properties defined in the model.
 *
 *  By convention we substitute scalar values with a sentinel value (undefined)
 *  when nil is being passed
 *
 *  @param key Name of the property KVC is trying to set
 */
- (void)setNilValueForKey:(NSString *)key {
    if ([NSStringFromSelector(@selector(operationOperator)) isEqualToString:key]) {
        _operationOperator = ASDKModelFormVisibilityConditionOperatorTypeUndefined;
    }
    if ([NSStringFromSelector(@selector(nextConditionOperator)) isEqualToString:key]) {
        _nextConditionOperator = ASDKModelFormVisibilityConditionNextConditionOperatorTypeUndefined;
    }
}

@end

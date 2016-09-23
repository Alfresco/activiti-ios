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

#import "ASDKModelFilter.h"

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

@implementation ASDKModelFilter


#pragma mark -
#pragma mark MTLJSONSerializing Delegate

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    NSMutableDictionary *inheretedPropertyKeys = [NSMutableDictionary dictionaryWithDictionary:[super JSONKeyPathsByPropertyKey]];
    [inheretedPropertyKeys addEntriesFromDictionary:@{//Objc property       JSON property
                                                      @"name"               : @"name",
                                                      @"sortType"           : @"sort",
                                                      @"state"              : @"state",
                                                      @"assignmentType"     : @"assignment",
                                                      @"appDefinitionID"    : @"appDefinitionId",
                                                      @"processInstanceID"  : @"processInstanceId"}];
    
    return inheretedPropertyKeys;
}


#pragma mark -
#pragma mark Value transformations

+ (NSValueTransformer *)sortTypeJSONTransformer {
    return [NSValueTransformer mtl_valueMappingTransformerWithDictionary:@{@"created-desc"   : @(ASDKModelFilterSortTypeCreatedDesc),
                                                                           @"created-asc"    : @(ASDKModelFilterSortTypeCreatedAsc),
                                                                           @"due-desc"       : @(ASDKModelFilterSortTypeDueDesc),
                                                                           @"due-asc"        : @(ASDKModelFilterSortTypeDueAsc)}];
}

+ (NSValueTransformer *)stateJSONTransformer {
    return [NSValueTransformer mtl_valueMappingTransformerWithDictionary:@{@"open"           : @(ASDKModelFilterStateTypeActive),
                                                                           @"completed"      : @(ASDKModelFilterStateTypeCompleted),
                                                                           @"running"        : @(ASDKModelFilterStateTypeRunning),
                                                                           @"all"            : @(ASDKModelFilterStateTypeAll)}];
}

+ (NSValueTransformer *)assignmentTypeJSONTransformer {
    return [NSValueTransformer mtl_valueMappingTransformerWithDictionary:@{@"involved"        : @(ASDKModelFilterAssignmentTypeInvolved),
                                                                           @"assignee"        : @(ASDKModelFilterAssignmentTypeAssignee),
                                                                           @"candidate"       : @(ASDKModelFilterAssignmentTypeCandidate)}];
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
    if ([NSStringFromSelector(@selector(sortType)) isEqualToString:key]) {
        _sortType = ASDKModelFilterSortTypeUndefined;
    }
    if ([NSStringFromSelector(@selector(state)) isEqualToString:key]) {
        _state = ASDKModelFilterStateTypeUndefined;
    }
    if ([NSStringFromSelector(@selector(assignmentType)) isEqualToString:key]) {
        _assignmentType = ASDKModelFilterAssignmentTypeUndefined;
    }
}

@end

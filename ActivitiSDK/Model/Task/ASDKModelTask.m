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

#import "ASDKModelTask.h"
#import "ASDKModelProfile.h"

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

@implementation ASDKModelTask

#pragma mark -
#pragma mark MTLJSONSerializing Delegate

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    NSMutableDictionary *inheretedPropertyKeys = [NSMutableDictionary dictionaryWithDictionary:[super JSONKeyPathsByPropertyKey]];
    [inheretedPropertyKeys addEntriesFromDictionary:@{//Objc property                   JSON property
                                                      @"name"                           : @"name",
                                                      @"taskDescription"                : @"description",
                                                      @"assigneeModel"                  : @"assignee",
                                                      @"dueDate"                        : @"dueDate",
                                                      @"endDate"                        : @"endDate",
                                                      @"duration"                       : @"duration",
                                                      @"priority"                       : @"priority",
                                                      @"processInstanceID"              : @"processInstanceId",
                                                      @"processDefinitionID"            : @"processDefinitionId",
                                                      @"processDefinitionName"          : @"processDefinitionName",
                                                      @"involvedPeople"                 : @"involvedPeople",
                                                      @"formKey"                        : @"formKey",
                                                      @"isMemberOfCandidateGroup"       : @"memberOfCandidateGroup",
                                                      @"isMemberOfCandidateUsers"       : @"memberOfCandidateUsers",
                                                      @"isManagerOfCandidateGroup"      : @"managerOfCandidateGroup",
                                                      @"parentTaskID"                   : @"parentTaskId",
                                                      @"creationDate"                   : @"created",
                                                      @"category"                       : @"category",
                                                      @"processDefinitionDeploymentID"  : @"processDefinitionDeploymentId"}];
    
    return inheretedPropertyKeys;
}


#pragma mark -
#pragma mark Value transformations

+ (NSValueTransformer *)assigneeModelJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:ASDKModelProfile.class];
}

+ (NSValueTransformer *)dueDateJSONTransformer {
    return self.valueTransformerForDate;
}

+ (NSValueTransformer *)endDateJSONTransformer {
    return self.valueTransformerForDate;
}

+ (NSValueTransformer *)involvedPeopleJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:ASDKModelProfile.class];
}

+ (NSValueTransformer *)processInstanceIDJSONTransformer {
    return self.valueTransformerForIDs;
}

+ (NSValueTransformer *)processDefinitionIDJSONTransformer {
    return self.valueTransformerForIDs;
}

+ (NSValueTransformer *)parentTaskIDJSONTransformer {
    return self.valueTransformerForIDs;
}

+ (NSValueTransformer *)creationDateJSONTransformer {
    return self.valueTransformerForDate;
}

+ (NSValueTransformer *)category {
    return self.valueTransformerForIDs;
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
    if ([NSStringFromSelector(@selector(duration)) isEqualToString:key]) {
        _duration = 0;
    }
    if ([NSStringFromSelector(@selector(priority)) isEqualToString:key]) {
        _priority = 0;
    }
    if ([NSStringFromSelector(@selector(isMemberOfCandidateGroup)) isEqualToString:key]) {
        _isMemberOfCandidateGroup = NO;
    }
    if ([NSStringFromSelector(@selector(isMemberOfCandidateUsers)) isEqualToString:key]) {
        _isMemberOfCandidateUsers = NO;
    }
    if ([NSStringFromSelector(@selector(isManagerOfCandidateGroup)) isEqualToString:key]) {
        _isManagerOfCandidateGroup = NO;
    }
}


@end

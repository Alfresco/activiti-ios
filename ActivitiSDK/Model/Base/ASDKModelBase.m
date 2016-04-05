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

#import "ASDKModelBase.h"
#import "ASDKModelConfiguration.h"
#import "ASDKLogConfiguration.h"
#import "ASDKMantleJSONAdapterExcludeZeroNil.h"

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

static const int activitiSDKLogLevel = ASDK_LOG_LEVEL_VERBOSE; // | ASDK_LOG_FLAG_TRACE;

@implementation ASDKModelBase


#pragma mark - 
#pragma mark Lifecycle

- (instancetype)initWithDictionary:(NSDictionary *)dictionaryValue
                             error:(NSError **)error {
    self = [super initWithDictionary:dictionaryValue
                               error:error];
    return self;
}


#pragma mark -
#pragma mark MTLJSONSerializing Delegate

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"instanceID"   : @"id",
             @"creationDate" : @"created",
             @"lastUpdate"   : @"lastUpdate",
             @"modelType"    : @"type"
            };
}


#pragma mark - 
#pragma mark Value transformations

+ (NSValueTransformer *)instanceIDJSONTransformer {
    return self.valueTransformerForIDs;
}

+ (NSValueTransformer *)modelTypeJSONTransformer {
    return [NSValueTransformer mtl_valueMappingTransformerWithDictionary:@{
                                                                           @"bpmSuite"   : @(ASDKModelBaseTypeBPMSuite),
                                                                           @"enterprise" : @(ASDKModelBaseTypeEnterprise)
                                                                           }];
}

+ (NSValueTransformer *)creationDateJSONTransformer {
    return self.valueTransformerForDate;
}

+ (NSValueTransformer *)lastUpdateJSONTransformer {
    return self.valueTransformerForDate;
}


#pragma mark -
#pragma mark JSON conversion

- (NSDictionary *)jsonDictionary {
    NSError *error = nil;
    NSDictionary *jsonDict = nil;
    
    switch (self.jsonAdapterType) {
        case ASDKModelJSONAdapterTypeDefault: {
            jsonDict = [MTLJSONAdapter JSONDictionaryFromModel:self
                                                         error:&error];
        }
            break;
            
        case ASDKModelJSONAdapterTypeExcludeNilValues: {
            jsonDict = [ASDKMantleJSONAdapterExcludeZeroNil JSONDictionaryFromModel:self
                                                                              error:&error];
        }
            break;
            
        default:
            break;
    }
    
    if (error) {
        ASDKLogError(@"Error converting model to dictionary. Reason:%@", error.localizedDescription);
    }
    
    return jsonDict;
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
    if ([NSStringFromSelector(@selector(modelType)) isEqualToString:key]) {
        self.modelType = ASDKModelBaseTypeUndefined;
    }
}


#pragma mark -
#pragma makr Merge policy

- (void)mergeValuesForKeysFromModel:(id<MTLModel>)model {
    if (self.mergePolicyBlock) {
        self.mergePolicyBlock(model);
    } else {
        [super mergeValuesForKeysFromModel:model];
    }
}


#pragma mark -
#pragma mark Utils

+ (NSDateFormatter *)standardDateFormatter {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    dateFormatter.dateFormat = kBaseModelDateFormat;
    
    return dateFormatter;
}

+ (MTLValueTransformer *)valueTransformerForDate {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSString *dateString, BOOL *success, NSError *__autoreleasing *error) {
        return [self.standardDateFormatter dateFromString:dateString];
    } reverseBlock:^id(NSDate *date, BOOL *success, NSError *__autoreleasing *error) {
        return [self.standardDateFormatter stringFromDate:date];
    }];
}

+ (MTLValueTransformer *)valueTransformerForIDs {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
        if ([value isKindOfClass:[NSNumber class]]) {
            return [(NSNumber *)value stringValue];
        }
        
        return value;
    } reverseBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
        NSNumberFormatter *numberFormatter = [NSNumberFormatter new];
        numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
        if ([value isKindOfClass:[NSString class]]) {
            return [numberFormatter numberFromString:(NSString *)value];
        }
        
        return value;
    }];
}

@end

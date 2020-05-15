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

#import "ASDKBaseRequestRepresentation.h"
#import "ASDKLogConfiguration.h"
#import "ASDKMantleJSONAdapterExcludeZeroNil.h"
#import "ASDKModelConfiguration.h"

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

static const int activitiSDKLogLevel = ASDK_LOG_LEVEL_VERBOSE; // | ASDK_LOG_FLAG_TRACE;

@implementation ASDKBaseRequestRepresentation

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
    return @{};
}


#pragma mark -
#pragma mark JSON conversion

- (NSDictionary *)jsonDictionary {
    NSError *error = nil;
    NSDictionary *jsonDict = nil;
    
    switch (self.jsonAdapterType) {
        case ASDKRequestRepresentationJSONAdapterTypeDefault: {
            jsonDict = [MTLJSONAdapter JSONDictionaryFromModel:self
                                                         error:&error];
        }
            break;
            
        case ASDKRequestRepresentationJSONAdapterTypeExcludeNilValues: {
            jsonDict = [ASDKMantleJSONAdapterExcludeZeroNil JSONDictionaryFromModel:self
                                                                          error:&error];
        }
            break;
            
        case ASDKRequestRepresentationJSONAdapterTypeCustomPolicy: {
            ASDKMantleJSONAdapterCustomPolicy *jsonAdapter = [[ASDKMantleJSONAdapterCustomPolicy alloc] initWithModelClass:self.class];
            jsonAdapter.policyBlock = self.policyBlock;
            jsonDict = [jsonAdapter JSONDictionaryFromModel:self
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
        NSString *dateString = [self.standardDateFormatter stringFromDate:date];
        return dateString ? dateString : @"";
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

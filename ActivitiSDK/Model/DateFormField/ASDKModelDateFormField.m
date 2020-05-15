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

#import "ASDKModelDateFormField.h"

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

@implementation ASDKModelDateFormField

#pragma mark -
#pragma mark MTLJSONSerializing Delegate


+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    NSMutableDictionary *inheretedPropertyKeys = [NSMutableDictionary dictionaryWithDictionary:[super JSONKeyPathsByPropertyKey]];
    [inheretedPropertyKeys addEntriesFromDictionary:@{//Objc property           JSON property
                                                      @"dateDisplayFormat"    : @"dateDisplayFormat",
                                                      @"minValue"             : @"minValue",
                                                      @"maxValue"             : @"maxValue"}];
    
    return inheretedPropertyKeys;
}

+ (NSValueTransformer *)dateDisplayFormatJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
        NSString *normalizedDateFormat = nil;
        
        if ([value isKindOfClass:[NSString class]]) {
            NSString *dateFormat = value;
            normalizedDateFormat = [self normalizedServerDateFormat:dateFormat];
        }
        
        return normalizedDateFormat;
    }];
}

+ (NSString *)normalizedServerDateFormat:(NSString *)serverDateFormat {
    NSMutableString *normalizedServerDateFormat = [NSMutableString string];
    
    NSUInteger len = [serverDateFormat length];
    unichar buffer[len+1];
    
    [serverDateFormat getCharacters:buffer
                              range:NSMakeRange(0, len)];
    
    for (int idx = 0; idx < len; idx++) {
        if (buffer[idx] == 'Y') {
            [normalizedServerDateFormat appendString:@"y"];
            continue;
        } else if (buffer[idx] == 'D') {
            [normalizedServerDateFormat appendString:@"d"];
            continue;
        } else if (buffer[idx] == 'A') {
            [normalizedServerDateFormat appendString:@"a"];
            continue;
        }
        
        NSString *characterString = [NSString stringWithFormat:@"%C",buffer[idx]];
        [normalizedServerDateFormat appendString:characterString];
    }
    
    return normalizedServerDateFormat;
}

@end

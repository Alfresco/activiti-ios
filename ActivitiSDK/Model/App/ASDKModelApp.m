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

#import "ASDKModelApp.h"

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

#pragma mark -
#pragma mark MTLJSONSerializing Delegate

@implementation ASDKModelApp

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    NSMutableDictionary *inheretedPropertyKeys = [NSMutableDictionary dictionaryWithDictionary:[super JSONKeyPathsByPropertyKey]];
    [inheretedPropertyKeys addEntriesFromDictionary:@{//Objc property             JSON property
                                                      @"deploymentID"           : @"deploymentId",
                                                      @"name"                   : @"name",
                                                      @"icon"                   : @"icon",
                                                      @"applicationDescription" : @"description",
                                                      @"theme"                  : @"theme",
                                                      @"applicationModelID"     : @"modelId"
                                                      }];
    
    return inheretedPropertyKeys;
}


#pragma mark -
#pragma mark Value transformations

+ (NSValueTransformer *)applicationModelIDJSONTransformer {
    return self.valueTransformerForIDs;
}

+ (NSValueTransformer *)themeJSONTransformer {
    return [NSValueTransformer mtl_valueMappingTransformerWithDictionary:@{
                                                                           @"theme-1"  : @(ASDKModelAppThemeTypeOne),
                                                                           @"theme-2"  : @(ASDKModelAppThemeTypeTwo),
                                                                           @"theme-3"  : @(ASDKModelAppThemeTypeThree),
                                                                           @"theme-4"  : @(ASDKModelAppThemeTypeFour),
                                                                           @"theme-5"  : @(ASDKModelAppThemeTypeFive),
                                                                           @"theme-6"  : @(ASDKModelAppThemeTypeSix),
                                                                           @"theme-7"  : @(ASDKModelAppThemeTypeSeven),
                                                                           @"theme-8"  : @(ASDKModelAppThemeTypeEight),
                                                                           @"theme-9"  : @(ASDKModelAppThemeTypeNine),
                                                                           @"theme-10" : @(ASDKModelAppThemeTypeTen)
                                                                          }];
}

@end

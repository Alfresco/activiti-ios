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

#import <Mantle/Mantle.h>
#import "ASDKMantleJSONAdapterCustomPolicy.h"

typedef NS_ENUM(NSInteger, ASDKRequestRepresentationJSONAdapterType) {
    ASDKRequestRepresentationJSONAdapterTypeDefault,
    ASDKRequestRepresentationJSONAdapterTypeExcludeNilValues,
    ASDKRequestRepresentationJSONAdapterTypeCustomPolicy
};

@interface ASDKBaseRequestRepresentation : MTLModel <MTLJSONSerializing>

/**
 *  You can specify what adapter will be making changes to your property keys here.
 *  If not specified the default behaviour (all properties returned by the 
 *  MTLJSONSerializing protocol will be used)
 */
@property (assign, nonatomic) ASDKRequestRepresentationJSONAdapterType jsonAdapterType;

/**
 *  You can specify using the below mentioned block to define which keys are to be
 *  excluded from the resulting JSON transformation based on the analysis of the 
 *  attached value. If defined you will need to return a boolean representing
 *  whether the value should be removed or not from the JSON representation.
 */
@property (strong, nonatomic) ASDKJSONAdapterPolicyBlock policyBlock;

/**
 *  Creates a JSON representation with all the keys that are processed by the jsonAdapter
 *
 *  @return Dictionary with JSON structure
 */
- (NSDictionary *)jsonDictionary;

// Utilities
+ (MTLValueTransformer *)valueTransformerForDate;
+ (MTLValueTransformer *)valueTransformerForIDs;

@end

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

typedef void (^ASDKModelMergePolicyBlock) (id<MTLModel>model);

typedef NS_ENUM(NSInteger, ASDKModelJSONAdapterType) {
    ASDKModelJSONAdapterTypeDefault,
    ASDKModelJSONAdapterTypeExcludeNilValues
};

@interface ASDKModelBase : MTLModel <MTLJSONSerializing>

/**
 *  When defined, the default implementation of the MTLModel changes and
 *  allows for a hook point to be defined in the process of aiding the 
 *  merging process. For example if you want to merge a subset of the
 *  properties returned you will be able to define an inline block that will
 *  accomodate your custom merge logic. 
 */
@property (strong, nonatomic) ASDKModelMergePolicyBlock mergePolicyBlock;

/**
 *  You can specify what adapter will be making changes to your property keys here.
 *  If not specified the default behaviour (all properties returned by the
 *  MTLJSONSerializing protocol will be used). This is useful when making conversions
 *  of models from native form to JSON dictionary. For example if you want to pass a
 *  model object to a filter request representation you might want to rule out nil
 *  or zero value entries from the model, thus apply a transformation adapter.
 */
@property (assign, nonatomic) ASDKModelJSONAdapterType jsonAdapterType;

- (NSDictionary *)jsonDictionary;

// Utilities
+ (NSDateFormatter *)standardDateFormatter;
+ (MTLValueTransformer *)valueTransformerForDate;
+ (MTLValueTransformer *)valueTransformerForIDs;

@end

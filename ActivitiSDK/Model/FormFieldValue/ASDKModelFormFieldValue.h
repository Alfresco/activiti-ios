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

#import <Foundation/Foundation.h>
#import <Mantle/Mantle.h>

@interface ASDKModelFormFieldValue : MTLModel

/**
 *  Property intended to hold a reference to the values of a form field
 */
@property (strong, nonatomic) NSString                  *attachedValue;

/**
 *  Property intended to hold a reference to nesting form field value object types
 */
@property (strong, nonatomic) ASDKModelFormFieldValue   *option;

/**
 *  Property intended to hold a reference to additional objects containing information
 *  relevant to metadata values of a form field.
 */
@property (strong, nonatomic) id                        userInfo;

@end

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

#import "ASDKFormRenderEngineDataSourceProtocol.h"

@class ASDKModelFormDescription,
ASDKModelFormTabDescription,
ASDKModelFormField;

@protocol ASDKFormRenderEngineFormDescriptionDataSourceProtocol <ASDKFormRenderEngineDataSourceProtocol>

/**
 *  Designated initializer method for a task based collection view controller datasource.
 *
 *  @param formDescription Description containing the form field objects to be displayed
 *
 *  @return                Instance of the data source object
 */
- (instancetype)initWithTaskFormDescription:(ASDKModelFormDescription *)formDescription;

/**
 *  Designated initializer method for a process definition based collection view controller datasource.
 *
 *  @param formDescription Description containing the form field objects to be displayed
 *
 *  @return                Instance of the data source object
 */
- (instancetype)initWithProcessDefinitionFormDescription:(ASDKModelFormDescription *)formDescription;

/**
 *  Designated initializer method for a tab based collection view controller datasource.
 *
 *  @param formDescription Description containing the form field objects to be displayed
 *
 *  @return                Instance of the data source object
 */
- (instancetype)initWithTabFormDescription:(ASDKModelFormTabDescription *)formDescription;

/**
 *  Property meant to hold a reference to the data source's delegate which will
 *  be notified about visibility changes in sections or items and other updates
 *  that need to trigger a visual response.
 */
@property (weak, nonatomic) id<ASDKFormRenderEngineDataSourceDelegate> delegate;

/**
 *  Property meant to hold a reference to the visibility condition processor.
 *  It's purpose is to determine based on form field visibility conditions which
 *  fields are to be displayed or hidden.
 */
@property (strong, nonatomic) ASDKFormVisibilityConditionsProcessor *visibilityConditionsProcessor;

@end

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

@class ASDKModelFormField;

typedef NS_ENUM(NSInteger, ASDKFormFieldSupportedType) {
    ASDKFormFieldSupportedTypeUndefined = -1,
    ASDKFormFieldSupportedTypeString    = 0,
    ASDKFormFieldSupportedTypeNumber,
    ASDKFormFieldSupportedTypeBoolean,
    ASDKFormFieldSupportedTypeDate,
};

typedef NS_ENUM(NSInteger, ASDKFormVisibilityConditionActionType) {
    ASDKFormVisibilityConditionActionTypeHideElement,
    ASDKFormVisibilityConditionActionTypeShowElement
};

@protocol ASDKFormVisibilityConditionsProcessorProtocol <NSObject>

/**
 *  Designated set up method for the visibility condition processor when it is used
 *  to determine which of the provided form fields are visible and which should 
 *  become or be hidden depending on the input of the user.
 *
 *  @param formFieldArr  Form fields to be parsed for visibility conditions
 *  @param formVariables Variables defined within the form description
 *
 *  @return Instance of the visibility conditions processor
 */
- (instancetype)initWithFormFields:(NSArray *)formFieldArr
                     formVariables:(NSArray *)formVariables;

/**
 *  Requests the form visibility conditions processor to return an array of form fields 
 *  elements that are visible at the moment of the call. Internally this method parses
 *  all the form fields that have visibility conditions attached and evaluates them
 *  to provide a list of those visible
 *
 *  @return Collection of visible form fields
 */
- (NSArray *)parseVisibleFormFields;

/**
 *  Requests a set of form fields that are a direct influence on the visibility of other 
 *  form fields.
 *
 *  @return Set of visibility influential form fields
 */
- (NSSet *)visibilityInfluentialFormFields;

/**
 *  Returns a collection of form fields used to check visibility conditions for the mentioned
 *  tab index.
 *
 *  @param tabIdx Tab index for which the form fields are requested
 *
 *  @return Array of form field objects
 */
- (NSArray *)formFieldsForTabID:(NSString *)tabID;

/**
 *  Requests a reevaluation of the visibility conditions that are affected by a form field's
 *  value change. The result will be delivered as a dictionary where the key is represented
 *  by one of the enumeration values of ASDKFormVisibilityConditionActionType and the value
 *  is an array of form fields.
 *  
 *  Discussion: For example if the key is of ASDKFormVisibilityConditionActionTypeHideElement
 *  value and it has attached an array of form field elements this will mean that those 
 *  attached elements should be hidden from the form because their visibilit conditions 
 *  suggest that action.
 *
 *  @param formField Form field for which reevaluations should be made
 *
 *  @return          Dictionary structure containing which fields should be made visible / hidden
 */
- (NSDictionary *)reevaluateVisibilityConditionsAffectedByFormField:(ASDKModelFormField *)formField;

@end

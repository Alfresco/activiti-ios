/*******************************************************************************
 * Copyright (C) 2005-2018 Alfresco Software Limited.
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

#import "ASDKModelAttributable.h"

typedef NS_ENUM(NSInteger, ASDKModelFormFieldType) {
    ASDKModelFormFieldTypeUndefined = -1,
    ASDKModelFormFieldTypeContainer= 1,
    ASDKModelFormFieldTypeFormField,
    ASDKModelFormFieldTypeRestField,
    ASDKModelFormFieldTypeAmountField,
    ASDKModelFormFieldTypeAttachField,
    ASDKModelFormFieldTypeHyperlinkField,
    ASDKModelFormFieldTypeDynamicTableField
};

typedef NS_ENUM(NSInteger, ASDKModelFormFieldRepresentationType) {
    ASDKModelFormFieldRepresentationTypeUndefined = -1,
    ASDKModelFormFieldRepresentationTypeReadOnly  = 1,
    ASDKModelFormFieldRepresentationTypeContainer,
    ASDKModelFormFieldRepresentationTypeHeader,
    ASDKModelFormFieldRepresentationTypeText,
    ASDKModelFormFieldRepresentationTypeBoolean,
    ASDKModelFormFieldRepresentationTypeNumerical,
    ASDKModelFormFieldRepresentationTypeDate,
    ASDKModelFormFieldRepresentationTypeDropdown,
    ASDKModelFormFieldRepresentationTypeRadio,
    ASDKModelFormFieldRepresentationTypeAmount,
    ASDKModelFormFieldRepresentationTypeMultiline,
    ASDKModelFormFieldRepresentationTypeReadonlyText,
    ASDKModelFormFieldRepresentationTypeAttach,
    ASDKModelFormFieldRepresentationTypeHyperlink,
    ASDKModelFormFieldRepresentationTypePeople,
    ASDKModelFormFieldRepresentationTypeDynamicTable,
    ASDKModelFormFieldRepresentationTypeDateTime,
    ASDKModelFormFieldRepresentationTypeTypeahead
};

@class ASDKModelFormFieldValue, ASDKModelFormVisibilityCondition;

@interface ASDKModelFormField : ASDKModelAttributable

@property (assign, nonatomic) ASDKModelFormFieldType                fieldType;
@property (assign, nonatomic) ASDKModelFormFieldRepresentationType  representationType;
@property (strong, nonatomic) NSString                              *fieldName;
@property (strong, nonatomic) NSString                              *placeholder;
@property (strong, nonatomic) NSArray                               *values;
@property (assign, nonatomic) BOOL                                  isReadOnly;
@property (assign, nonatomic) BOOL                                  isRequired;
@property (assign, nonatomic) NSInteger                             sizeX;
@property (assign, nonatomic) NSInteger                             sizeY;
@property (strong, nonatomic) NSArray                               *formFields;
@property (strong, nonatomic) NSArray                               *formFieldOptions;
@property (strong, nonatomic) ASDKModelFormField                    *formFieldParams;
@property (strong, nonatomic) ASDKModelFormFieldValue               *metadataValue;
@property (strong, nonatomic) ASDKModelFormVisibilityCondition      *visibilityCondition;
@property (strong, nonatomic) NSString                              *tabID;

@end

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

#import "ASDKModelFormField.h"
#import "ASDKLogConfiguration.h"
#import "ASDKNetworkServiceConstants.h"
#import "ASDKModelFormFieldOption.h"
#import "ASDKModelAmountFormField.h"
#import "ASDKModelFormFieldAttachParameter.h"
#import "ASDKModelContent.h"
#import "ASDKModelFormFieldValue.h"
#import "ASDKModelHyperlinkFormField.h"
#import "ASDKModelRestFormField.h"
#import "ASDKModelPeopleFormField.h"
#import "ASDKModelDynamicTableFormField.h"
#import "ASDKModelFormVisibilityCondition.h"
#import "ASDKModelDateFormField.h"

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

static const int activitiSDKLogLevel = ASDK_LOG_LEVEL_VERBOSE; // | ASDK_LOG_FLAG_TRACE;

@implementation ASDKModelFormField


#pragma mark -
#pragma mark Class cluster handling

+ (Class)classForParsingJSONDictionary:(NSDictionary *)JSONDictionary {
    NSString *formFieldTypeString = JSONDictionary[kASDKAPIFormFieldTypeParameter];
    
    // Input forms
    if ([formFieldTypeString isEqualToString:@"AmountFieldRepresentation"]) {
        return ASDKModelAmountFormField.class;
    } else if ([formFieldTypeString isEqualToString:@"HyperlinkRepresentation"]) {
        return ASDKModelHyperlinkFormField.class;
    } else if ([formFieldTypeString isEqualToString:@"RestFieldRepresentation"]) {
        return ASDKModelRestFormField.class;
    } else if ([formFieldTypeString isEqualToString:@"FormFieldRepresentation"]) {
        if ([JSONDictionary[@"type"] isEqualToString:@"people"]) {
            return ASDKModelPeopleFormField.class;
        } else if ([JSONDictionary[@"type"] isEqualToString:@"datetime"] ||
                   [JSONDictionary[@"type"] isEqualToString:@"date"]) {
            return ASDKModelDateFormField.class;
        }
    } else if ([formFieldTypeString isEqualToString:@"DynamicTableRepresentation"]) {
        return ASDKModelDynamicTableFormField.class;
    }
    
    NSString *fieldTypeParameterString = JSONDictionary[kASDKAPIParametersParameter][kASDKAPIFormFieldParameter][kASDKAPITypeParameter];
    BOOL isReadOnlyType = [JSONDictionary[kASDKAPITypeParameter] isEqualToString:@"readonly"];
    
    // Completed forms
    if (isReadOnlyType) {
        if ([fieldTypeParameterString isEqualToString:@"people"]) {
            return ASDKModelPeopleFormField.class;
        } else if ([fieldTypeParameterString isEqualToString:@"date"] ||
                   [fieldTypeParameterString isEqualToString:@"datetime"]) {
            return ASDKModelDateFormField.class;
        }
    }
    
    // Display value
    if ([JSONDictionary[kASDKAPIFormFieldTypeParameter] isEqualToString:@"FormFieldRepresentation"] &&
        isReadOnlyType) {
        
        if ([fieldTypeParameterString isEqualToString:@"amount"]) {
            return ASDKModelAmountFormField.class;
        }
        if ([fieldTypeParameterString isEqualToString:@"hyperlink"]) {
            return ASDKModelHyperlinkFormField.class;
        }
        if ([fieldTypeParameterString isEqualToString:@"dynamic-table"]) {
            return ASDKModelDynamicTableFormField.class;
        }
    }
    
    return self;
}


#pragma mark -
#pragma mark MTLJSONSerializing Delegate

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    NSMutableDictionary *inheretedPropertyKeys = [NSMutableDictionary dictionaryWithDictionary:[super JSONKeyPathsByPropertyKey]];
    [inheretedPropertyKeys addEntriesFromDictionary:@{//Objc property           JSON property
                                                      @"fieldType"            : @"fieldType",
                                                      @"fieldName"            : @"name",
                                                      @"representationType"   : @"type",
                                                      @"placeholder"          : @"placeholder",
                                                      @"values"               : @"value",
                                                      @"isReadOnly"           : @"readOnly",
                                                      @"isRequired"           : @"required",
                                                      @"sizeX"                : @"sizeX",
                                                      @"sizeY"                : @"sizeY",
                                                      @"formFields"           : @"fields",
                                                      @"formFieldParams"      : @"params",
                                                      @"formFieldOptions"     : @"options",
                                                      @"visibilityCondition"  : @"visibilityCondition",
                                                      @"tabID"                : @"tab"}];
    
    return inheretedPropertyKeys;
}


#pragma mark -
#pragma mark Value transformations

+ (NSValueTransformer *)fieldTypeJSONTransformer {
    return [NSValueTransformer mtl_valueMappingTransformerWithDictionary:
            @{@"ContainerRepresentation"       : @(ASDKModelFormFieldTypeContainer),
              @"FormFieldRepresentation"       : @(ASDKModelFormFieldTypeFormField),
              @"RestFieldRepresentation"       : @(ASDKModelFormFieldTypeRestField),
              @"AmountFieldRepresentation"     : @(ASDKModelFormFieldTypeAmountField),
              @"AttachFileFieldRepresentation" : @(ASDKModelFormFieldTypeAttachField),
              @"HyperlinkRepresentation"       : @(ASDKModelFormFieldTypeHyperlinkField),
              @"DynamicTableRepresentation"    : @(ASDKModelFormFieldTypeDynamicTableField)}];
}

+ (NSValueTransformer *)representationTypeJSONTransformer {
    return [NSValueTransformer mtl_valueMappingTransformerWithDictionary:
            @{@"readonly"       : @(ASDKModelFormFieldRepresentationTypeReadOnly),
              @"container"      : @(ASDKModelFormFieldRepresentationTypeContainer),
              @"group"          : @(ASDKModelFormFieldRepresentationTypeHeader),
              @"text"           : @(ASDKModelFormFieldRepresentationTypeText),
              @"boolean"        : @(ASDKModelFormFieldRepresentationTypeBoolean),
              @"date"           : @(ASDKModelFormFieldRepresentationTypeDate),
              @"integer"        : @(ASDKModelFormFieldRepresentationTypeNumerical),
              @"dropdown"       : @(ASDKModelFormFieldRepresentationTypeDropdown),
              @"radio-buttons"  : @(ASDKModelFormFieldRepresentationTypeRadio),
              @"amount"         : @(ASDKModelFormFieldRepresentationTypeAmount),
              @"multi-line-text": @(ASDKModelFormFieldRepresentationTypeMultiline),
              @"readonly-text"  : @(ASDKModelFormFieldRepresentationTypeReadonlyText),
              @"upload"         : @(ASDKModelFormFieldRepresentationTypeAttach),
              @"hyperlink"      : @(ASDKModelFormFieldRepresentationTypeHyperlink),
              @"people"         : @(ASDKModelFormFieldRepresentationTypePeople),
              @"dynamic-table"  : @(ASDKModelFormFieldRepresentationTypeDynamicTable),
              @"datetime"       : @(ASDKModelFormFieldRepresentationTypeDateTime),
              @"typeahead"      : @(ASDKModelFormFieldRepresentationTypeTypeahead)}];
}

+ (NSValueTransformer *)formFieldsJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSDictionary *value, BOOL *success, NSError *__autoreleasing *error) {
        NSMutableArray * childrenFormFieldsJSONArr = [NSMutableArray array];
        for (NSString *key in value.allKeys) {
            // We know that we're receiving an array of dictionaries
            NSArray *formFieldsForKey = value[key];
            [childrenFormFieldsJSONArr addObjectsFromArray:formFieldsForKey];
        }
        
        NSError *childrenFormFieldsParseError = nil;
        NSArray *childrenFormModels = [MTLJSONAdapter modelsOfClass:ASDKModelFormField.class
                                                      fromJSONArray:childrenFormFieldsJSONArr
                                                              error:&childrenFormFieldsParseError];
        if (childrenFormFieldsParseError) {
            ASDKLogVerbose(@"Cannot parse children form models. Reason:%@", childrenFormFieldsParseError.localizedDescription);
        }
        
        return childrenFormModels;
    } reverseBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
        // Not applicable for the time being to provide back a JSON representation
        return nil;
    }];
}

+ (NSValueTransformer *)formFieldParamsJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSDictionary *value, BOOL *success, NSError *__autoreleasing *error) {
        NSError *formFieldsParseError = nil;
        id parsedFormFieldParams = nil;
        
        if (value[kASDKAPIFormFieldParameter]) {
            NSString *formFieldTypeString = value[kASDKAPIFormFieldParameter][kASDKAPITypeParameter];
            
            if ([formFieldTypeString isEqualToString:@"amount"]) {
                parsedFormFieldParams = [MTLJSONAdapter modelOfClass:ASDKModelAmountFormField.class
                                                  fromJSONDictionary:value[kASDKAPIFormFieldParameter]
                                                               error:&formFieldsParseError];
            } else if([formFieldTypeString isEqualToString:@"hyperlink"]) {
                parsedFormFieldParams = [MTLJSONAdapter modelOfClass:ASDKModelHyperlinkFormField.class
                                                  fromJSONDictionary:value[kASDKAPIFormFieldParameter]
                                                               error:&formFieldsParseError];
            } else if([formFieldTypeString isEqualToString:@"dynamic-table"]) {
                parsedFormFieldParams = [MTLJSONAdapter modelOfClass:ASDKModelDynamicTableFormField.class
                                                  fromJSONDictionary:value[kASDKAPIFormFieldParameter]
                                                               error:&formFieldsParseError];
                ASDKModelDynamicTableFormField *parsedDynamicTableFormFieldParams = (ASDKModelDynamicTableFormField *) parsedFormFieldParams;
                parsedDynamicTableFormFieldParams.isTableEditable = [value[kASDKAPITableEditableParameter] boolValue];
            } else {
                parsedFormFieldParams = [MTLJSONAdapter modelOfClass:ASDKModelFormField.class
                                                  fromJSONDictionary:value[kASDKAPIFormFieldParameter]
                                                               error:&formFieldsParseError];
            }
        } else if (value[kASDKAPIFileSourceFormFieldParameter]) {
            parsedFormFieldParams = [MTLJSONAdapter modelOfClass:ASDKModelFormFieldAttachParameter.class
                                              fromJSONDictionary:value
                                                           error:&formFieldsParseError];
        }
        
        if (formFieldsParseError) {
            ASDKLogVerbose(@"Cannot parse form field parameters model. Reason:%@", formFieldsParseError.localizedDescription);
        }
        
        return parsedFormFieldParams;
    }];
}

+ (NSValueTransformer *)formFieldOptionsJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:ASDKModelFormFieldOption.class];
}

+ (NSValueTransformer *)valuesJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
        if (!value) {
            return nil;
        }
        
        if ([value isKindOfClass:[NSString class]]) {
            return @[value];
        } else if ([value isKindOfClass:[NSArray class]]) {
            NSArray *valuesArr = (NSArray *)value;
            
            if (!valuesArr.count) {
                return nil;
            } else {
                NSError *formFieldsParseError = nil;
                NSArray *formFields = nil;
                
                // Examine one of the collection's element to check for their type
                // and then try to parse it to a model if possible
                if ([valuesArr.firstObject isKindOfClass:[NSDictionary class]]) {
                    NSDictionary *firstElement = valuesArr.firstObject;
                    
                    // Check for form fields attached content
                    if (firstElement[kASDKAPIContentAvailableParameter]) {
                        formFields = [MTLJSONAdapter modelsOfClass:ASDKModelContent.class
                                                     fromJSONArray:value
                                                             error:&formFieldsParseError];
                        if (formFieldsParseError) {
                            ASDKLogVerbose(@"Cannot parse form field parameters model. Reason:%@", formFieldsParseError.localizedDescription);
                        }
                    }
                }
                
                return formFields;
            }
        } else {
            return @[[NSString stringWithFormat:@"%@", value]];
        }
    }];
}

+ (NSValueTransformer *)visibilityConditionJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:ASDKModelFormVisibilityCondition.class];
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
    if ([NSStringFromSelector(@selector(representationType)) isEqualToString:key]) {
        _representationType = ASDKModelFormFieldRepresentationTypeUndefined;
    }
    if ([NSStringFromSelector(@selector(fieldType)) isEqualToString:key]) {
        _fieldType = ASDKModelFormFieldTypeUndefined;
    }
    if ([NSStringFromSelector(@selector(isReadOnly)) isEqualToString:key]) {
        _fieldType = NO;
    }
    if ([NSStringFromSelector(@selector(isRequired)) isEqualToString:key]) {
        _isRequired = NO;
    }
    if ([NSStringFromSelector(@selector(sizeX)) isEqualToString:key]) {
        _sizeX = NO;
    }
    if ([NSStringFromSelector(@selector(sizeY)) isEqualToString:key]) {
        _sizeY = NO;
    }
}


@end

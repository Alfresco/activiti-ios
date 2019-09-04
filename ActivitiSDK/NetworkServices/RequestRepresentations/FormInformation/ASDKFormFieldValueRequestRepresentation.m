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

#import "ASDKFormFieldValueRequestRepresentation.h"
#import "ASDKModelFormFieldValue.h"
#import "ASDKModelFormField.h"
#import "ASDKNetworkServiceConstants.h"
#import "ASDKModelFormFieldOption.h"
#import "ASDKModelUser.h"
#import "ASDKModelDynamicTableFormField.h"
#import "ASDKModelFormTab.h"
#import "ASDKModelConfiguration.h"
#import "ASDKModelDateFormField.h"

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

@implementation ASDKFormFieldValueRequestRepresentation

#pragma mark -
#pragma mark MTLJSONSerializing Delegate

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{//Objc property          JSON property
             @"formFields"          : @"values",
             @"outcome"             : @"outcome"};
}


#pragma mark -
#pragma mark Value transformations

+ (NSValueTransformer *)formFieldsJSONTransformer {
    return [MTLValueTransformer transformerUsingReversibleBlock:^id(NSArray *formFields, BOOL *success, NSError *__autoreleasing *error) {
        NSMutableDictionary *formFieldMetadataValuesDict = [NSMutableDictionary dictionary];
        
        // If form tabs are present extract the form field sections from them
        NSMutableArray *sectionFormFields = [NSMutableArray array];
        for (id model in formFields) {
            if ([model isKindOfClass:ASDKModelFormTab.class]) {
                [sectionFormFields addObjectsFromArray:((ASDKModelFormTab *)model).formFields];
            } else {
                [sectionFormFields addObject:model];
            }
        }
        
        for (ASDKModelFormField *sectionFormField in sectionFormFields) {
            // Extract the form fields for the correspondent container
            if ([sectionFormField isKindOfClass:ASDKModelDynamicTableFormField.class]) {
                NSMutableArray *rowValues = [NSMutableArray new];
                
                for (NSArray *row in sectionFormField.values) {
                    NSMutableDictionary *columnValues = [NSMutableDictionary new];
                    
                    for (ASDKModelFormField *columnFormField in row) {
                        id formFieldValue = [self determineValueForFormField:columnFormField];
                        if (formFieldValue) {
                            [columnValues setObject:formFieldValue
                                             forKey:columnFormField.modelID];
                        }
                    }
                    [rowValues addObject:columnValues];
                }
                [formFieldMetadataValuesDict setObject:rowValues
                                                forKey:sectionFormField.modelID];
                
            } else {
                for (ASDKModelFormField *formField in sectionFormField.formFields) {
                    id formFieldValue = [self determineValueForFormField:formField];
                    if (formFieldValue) {
                        [formFieldMetadataValuesDict setObject:formFieldValue
                                                        forKey:formField.modelID];
                    }
                }
            }
        }
        
        return formFieldMetadataValuesDict;
    }];
}

+ (id)determineValueForFormField:(ASDKModelFormField *)formField {
    id formFieldValue = nil;
    
    if (ASDKModelFormFieldRepresentationTypeReadOnly != formField.representationType &&
        ASDKModelFormFieldRepresentationTypeContainer != formField.representationType) {
        
        // If there's an option field available change the nesting structure
        if (formField.metadataValue.option) {
            if (ASDKModelFormFieldTypeRestField == formField.fieldType) {
                NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:@"name == %@", formField.metadataValue.option.attachedValue];
                ASDKModelFormFieldOption *chosenOption = [formField.formFieldOptions filteredArrayUsingPredicate:searchPredicate].firstObject;
                formFieldValue = @{kASDKAPIGenericIDParameter  : chosenOption.modelID,
                                   kASDKAPIGenericNameParameter: formField.metadataValue.option.attachedValue};
            } else {
                formFieldValue = @{kASDKAPIGenericIDParameter  : formField.modelID,
                                   kASDKAPIGenericNameParameter: formField.metadataValue.option.attachedValue};
            }
        } else if (formField.metadataValue.attachedValue) { // if there's a attached value
            // special date field handling
            if (formField.representationType == ASDKModelFormFieldRepresentationTypeDate ||
                formField.representationType == ASDKModelFormFieldRepresentationTypeDateTime) {
                formFieldValue = [self handleDateAndDateTimeFormFieldValueRepresentationForFormField:formField];
            } else {
                formFieldValue = formField.metadataValue.attachedValue;
            }
        } else if (formField.values) { // otherwise use the original value
            // special attach field handling
            if (formField.representationType == ASDKModelFormFieldRepresentationTypeAttach) {
                formFieldValue = [self handleAttachFormFieldValueRepresentationForFormField:formField];
            }
            // special radio / dropdown field handling
            else if (formField.representationType == ASDKModelFormFieldRepresentationTypeDropdown ||
                     formField.representationType == ASDKModelFormFieldRepresentationTypeRadio ||
                     formField.representationType == ASDKModelFormFieldRepresentationTypeTypeahead) {
                formFieldValue = [self handleDropdownAndRadioFormFieldValueRepresentationForFormField:formField];
            }
            // special people field handling
            else if (formField.representationType == ASDKModelFormFieldRepresentationTypePeople) {
                formFieldValue = [self handlePeopleFormFieldValueRepresentationForFormField:formField];
            }
            // special people field handling
            else if (formField.representationType == ASDKModelFormFieldRepresentationTypeBoolean) {
                formFieldValue = [self handleBooleanFormFieldValueRepresentationForFormField:formField];
            } else {
                formFieldValue = formField.values.firstObject;
            }
            
        }
    }
    
    return formFieldValue;
}

+ (id)handleDateAndDateTimeFormFieldValueRepresentationForFormField:(ASDKModelFormField *)formField {
    id formFieldValue = nil;
    NSString *dateFormat = nil;
    ASDKModelDateFormField *dateFormField = (ASDKModelDateFormField *)formField;
    
    // create date object from saved string
    NSDateFormatter *displayDateFormatter = [[NSDateFormatter alloc] init];
    displayDateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    displayDateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    
    if (dateFormField.dateDisplayFormat.length) {
        dateFormat = dateFormField.dateDisplayFormat;
    } else {
        if (formField.representationType == ASDKModelFormFieldRepresentationTypeDate) {
            dateFormat = kASDKServerShortDateFormat;
        } else {
            dateFormat = kASDKServerMediumDateFormat;
        }
    }
    
    displayDateFormatter.dateFormat = dateFormat;
    NSDate *storedDate = [displayDateFormatter dateFromString:formField.metadataValue.attachedValue];
    
    //format submit date (2016-02-23T23:00:000Z)
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    dateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    dateFormatter.dateFormat = kASDKServerFullDateFormat;
    
    formFieldValue = [dateFormatter stringFromDate:storedDate];
    return formFieldValue;
}

+ (id)handleAttachFormFieldValueRepresentationForFormField:(ASDKModelFormField *)formField {
    id formFieldValue = nil;
    
    NSMutableArray *modelContentArray = [NSMutableArray new];
    for (ASDKModelContent *modelContent in formField.values) {
        [modelContentArray addObject:modelContent.modelID];
    }
    formFieldValue = [modelContentArray componentsJoinedByString:@","];
    return formFieldValue;
}

+ (id)handleDropdownAndRadioFormFieldValueRepresentationForFormField:(ASDKModelFormField *)formField {
    id formFieldValue = nil;
    
    if ([formField.values.firstObject isKindOfClass:NSDictionary.class]) {
        formFieldValue = formField.values.firstObject;
    } else {
        for (ASDKModelFormFieldOption *formFieldOption in formField.formFieldOptions) {
            // First try to identify the option through the name parameter
            if ([formFieldOption.name isEqualToString:formField.values.firstObject]) {
                // check if option has id (dynamic table dropdown column types don't have any)
                NSString *optionID = @"";
                if (formFieldOption.modelID) {
                    optionID = formFieldOption.modelID;
                }
                formFieldValue = @{kASDKAPIGenericIDParameter  : optionID,
                                   kASDKAPIGenericNameParameter: formField.values.firstObject};
                break;
            }
            
            // If no names are matching try to match by ID
            if ([formFieldOption.modelID isEqualToString:formField.values.firstObject]) {
                formFieldValue = @{kASDKAPIGenericIDParameter   : formFieldOption.modelID,
                                   kASDKAPIGenericNameParameter : formFieldOption.name};
                break;
            }
        }
    }
    
    return formFieldValue;
}

+ (id)handlePeopleFormFieldValueRepresentationForFormField:(ASDKModelFormField *)formField {
    id formFieldValue = nil;
    
    NSError *error = nil;
    if (formField.values.count > 1) {
        NSArray *JSONDictionaryArr = [MTLJSONAdapter JSONArrayFromModels:formField.values
                                                                   error:&error];
        formFieldValue = JSONDictionaryArr;
    } else if (formField.values.count == 1) {
        
        NSDictionary *JSONDictionary = [MTLJSONAdapter JSONDictionaryFromModel:formField.values.firstObject
                                                                         error:&error];
        formFieldValue = JSONDictionary;
    }
    
    return formFieldValue;
}

+ (id)handleBooleanFormFieldValueRepresentationForFormField:(ASDKModelFormField *)formField {
    id formFieldValue = nil;
    
    if (!formField.values.firstObject) {
        formFieldValue = @NO;
    } else {
        formFieldValue = [NSNumber numberWithBool:((NSString *)formField.values.firstObject).boolValue];
    }
    
    return formFieldValue;
}

@end

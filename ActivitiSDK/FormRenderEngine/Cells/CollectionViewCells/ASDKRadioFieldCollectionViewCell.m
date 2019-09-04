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

#import "ASDKRadioFieldCollectionViewCell.h"

// Models
#import "ASDKModelFormField.h"
#import "ASDKModelFormFieldValue.h"
#import "ASDKModelRestFormField.h"
#import "ASDKModelFormFieldOption.h"
#import "ASDKModelFormVariable.h"

// Constants
#import "ASDKFormRenderEngineConstants.h"

@interface ASDKRadioFieldCollectionViewCell ()

@property (strong, nonatomic) ASDKModelFormField         *formField;
@property (assign, nonatomic) BOOL                       isRequired;

- (NSString *)formatSelectedOptionLabelTextWithRestFormField:(ASDKModelRestFormField *)restFormField;

@end

@implementation ASDKRadioFieldCollectionViewCell

- (void)setSelected:(BOOL)selected {
    if (ASDKModelFormFieldRepresentationTypeReadOnly != self.formField.representationType) {
        [UIView animateWithDuration:kASDKSetSelectedAnimationTime animations:^{
            self.backgroundColor = selected ? self.colorSchemeManager.formViewHighlightedCellBackgroundColor : [UIColor whiteColor];
        }];
    }
}


#pragma mark -
#pragma mark ASDKFormCellProtocol

- (void)setupCellWithFormField:(ASDKModelFormField *)formField {
    self.formField = formField;
    
    ASDKModelRestFormField *restFormField = (ASDKModelRestFormField *)formField;
    self.descriptionLabel.text = formField.fieldName;
    
    if (ASDKModelFormFieldRepresentationTypeReadOnly == restFormField.representationType) {
        self.selectedOptionLabel.text = [self formatSelectedOptionLabelTextWithRestFormField:restFormField];
        self.selectedOptionLabel.textColor = self.colorSchemeManager.formViewFilledInValueColor;
        self.disclosureIndicatorLabel.hidden = YES;
        self.trailingToDisclosureConstraint.priority = UILayoutPriorityFittingSizeLevel;
    } else {
        self.isRequired = formField.isRequired;
        
        self.selectedOptionLabel.text = [self formatSelectedOptionLabelTextWithRestFormField:restFormField];
        self.disclosureIndicatorLabel.hidden = NO;
        
        [self validateCellStateForText:self.selectedOptionLabel.text];
    }
}

- (NSString *)formatSelectedOptionLabelTextWithRestFormField:(ASDKModelRestFormField *)restFormField {
    NSString *descriptionLabelText = nil;
    
    // If a previously selected option is available display it
    if (restFormField.metadataValue) {
        descriptionLabelText = restFormField.metadataValue.option.attachedValue;
    } else if (restFormField.representationType == ASDKModelFormFieldRepresentationTypeRadio &&
               restFormField.restURL) {
        descriptionLabelText = [self optionNameForRestFormField:restFormField];
    } else if (restFormField.values) {
        // TODO: Should dynamic table fields be formatted conform regular drop down fields??
        if ([restFormField.values.firstObject isKindOfClass:NSDictionary.class]) {
            descriptionLabelText = restFormField.values.firstObject[@"name"];
        } else {
            NSString *optionNameForRestFormField = [self optionNameForRestFormField:restFormField];
            if (!optionNameForRestFormField) {
                ASDKModelFormVariable *formVariable = restFormField.formFieldParams.values.firstObject;
                optionNameForRestFormField = formVariable.value;
            }
            
            if (ASDKModelFormFieldRepresentationTypeReadOnly == restFormField.representationType) {
                NSString *stringValue = restFormField.values.firstObject;
                
                if (stringValue.length) {
                    descriptionLabelText = stringValue;
                }
                
                if (optionNameForRestFormField.length) {
                    if (descriptionLabelText.length) {
                        descriptionLabelText = [NSString stringWithFormat:@"%@ (%@)", descriptionLabelText, optionNameForRestFormField];
                    }
                }
                
                if (!descriptionLabelText.length) {
                    descriptionLabelText = kASDKFormFieldEmptyStringValue;
                }
            } else {
                descriptionLabelText = optionNameForRestFormField;
            }
        }
    } else if (restFormField.representationType == ASDKModelFormFieldRepresentationTypeDropdown &&
               restFormField.restURL) {
        // temporary handling initial value dislay for REST populated radio form fields
        // the JSON model contains an initial value which isn't correct and shouldn't be displayed
        
        descriptionLabelText = @"";
    } else {
        descriptionLabelText = @"";
    }
    
    return descriptionLabelText;
}


#pragma mark -
#pragma mark Cell states & validation

- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.descriptionLabel.text = nil;
    self.descriptionLabel.textColor = self.colorSchemeManager.formViewValidValueColor;
    self.selectedOptionLabel.text = nil;
}

- (void)markCellValueAsInvalid {
    self.descriptionLabel.textColor = self.colorSchemeManager.formViewInvalidValueColor;
}

- (void)markCellValueAsValid {
    self.descriptionLabel.textColor = self.colorSchemeManager.formViewValidValueColor;
}

- (void)cleanInvalidCellValue {
    self.selectedOptionLabel.text = nil;
}

- (void)validateCellStateForText:(NSString *)text {
    // Check input in relation to the requirement of the field
    if (self.isRequired) {
        if (!text.length) {
            [self markCellValueAsInvalid];
        } else {
            [self markCellValueAsValid];
        }
    }
}


#pragma mark -
#pragma mark Covenience methods

- (NSString *)optionNameForRestFormField:(ASDKModelRestFormField *)restFormField {
    NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:@"modelID == %@", (NSString *)restFormField.values.firstObject];
    ASDKModelFormFieldOption *correspondingOption = [restFormField.formFieldOptions filteredArrayUsingPredicate:searchPredicate].firstObject;
    return correspondingOption.name;
}

@end

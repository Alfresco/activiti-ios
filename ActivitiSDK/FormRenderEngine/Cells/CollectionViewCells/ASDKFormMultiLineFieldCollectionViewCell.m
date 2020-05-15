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

#import "ASDKFormMultiLineFieldCollectionViewCell.h"

// Models
#import "ASDKModelFormField.h"
#import "ASDKModelFormFieldValue.h"

// Constants
#import "ASDKFormRenderEngineConstants.h"
#import "ASDKLocalizationConstants.h"

@interface ASDKFormMultiLineFieldCollectionViewCell ()

@property (strong, nonatomic) ASDKModelFormField            *formField;
@property (assign, nonatomic) BOOL                          isRequired;

@end

@implementation ASDKFormMultiLineFieldCollectionViewCell

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
    self.descriptionLabel.text = formField.fieldName;
    
    // If dealing with a read-only representation then disable the text field and copy the
    // user-filled value
    if (ASDKModelFormFieldRepresentationTypeReadOnly == formField.representationType) {
        NSString *formFieldValue = formField.values.firstObject;
        
        self.multiLineTextLabel.text = formFieldValue ? formFieldValue : ASDKLocalizedStringFromTable(kLocalizationFormValueEmpty, ASDKLocalizationTable, @"Empty value text");
        self.disclosureIndicatorLabel.hidden = formFieldValue.length ? NO : YES;
        self.multiLineTextLabel.textColor = self.colorSchemeManager.formViewFilledInValueColor;
        if (!formFieldValue.length) {
            self.labelTrailingToDisclosureIndicatorConstraint.priority = UILayoutPriorityFittingSizeLevel;
        }
    } else {
        self.isRequired = formField.isRequired;
        // If a previously selected option is available display it
        if (formField.metadataValue) {
            self.multiLineTextLabel.text = formField.metadataValue.attachedValue;
        } else if (formField.values) {
            self.multiLineTextLabel.text = formField.values.firstObject;
        } else {
            self.multiLineTextLabel.text = @"";
        }
        self.disclosureIndicatorLabel.hidden = NO;
        
        [self validateCellStateForText:self.multiLineTextLabel.text];
    }
}


#pragma mark -
#pragma mark Cell states & validation

- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.descriptionLabel.text = nil;
    self.descriptionLabel.textColor = self.colorSchemeManager.formViewValidValueColor;
    self.multiLineTextLabel.text = nil;
}

- (void)markCellValueAsInvalid {
    self.descriptionLabel.textColor = self.colorSchemeManager.formViewInvalidValueColor;
}

- (void)markCellValueAsValid {
    self.descriptionLabel.textColor = self.colorSchemeManager.formViewValidValueColor;
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

@end

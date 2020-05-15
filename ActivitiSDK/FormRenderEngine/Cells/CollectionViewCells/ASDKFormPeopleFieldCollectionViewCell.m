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

#import "ASDKFormPeopleFieldCollectionViewCell.h"

// Models
#import "ASDKModelFormField.h"
#import "ASDKModelFormFieldValue.h"
#import "ASDKModelPeopleFormField.h"

// Constants
#import "ASDKFormRenderEngineConstants.h"
#import "ASDKLocalizationConstants.h"

@interface ASDKFormPeopleFieldCollectionViewCell ()

@property (strong, nonatomic) ASDKModelFormField            *formField;
@property (assign, nonatomic) BOOL                          isRequired;

@end

@implementation ASDKFormPeopleFieldCollectionViewCell

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
    
    if (ASDKModelFormFieldRepresentationTypeReadOnly == formField.representationType) {
        self.selectedPeopleLabel.text = [self formatDescriptionLabelTextWithFormFieldValues:formField.values];
        self.selectedPeopleLabel.textColor = self.colorSchemeManager.formViewFilledInValueColor;
        self.selectedPeopleLabel.enabled = NO;
        self.disclosureIndicatorLabel.hidden = YES;
        self.labelTrailingToDisclosureIndicatorConstraint.priority = UILayoutPriorityFittingSizeLevel;
    } else {
        self.isRequired = formField.isRequired;
    
        // If a previously selected option is available display it
        if (formField.metadataValue) {
            self.selectedPeopleLabel.text = formField.metadataValue.attachedValue;
        } else if (formField.values) {
            self.selectedPeopleLabel.text = [self formatDescriptionLabelTextWithFormFieldValues:formField.values];

        } else {
            self.selectedPeopleLabel.text = ASDKLocalizedStringFromTable(kLocalizationFormPeopleNoSelectedText, ASDKLocalizationTable, @"No people selected");
        }
        self.disclosureIndicatorLabel.hidden = NO;

        [self validateCellStateForFormFieldValues:formField.values];
    }
}

- (NSString *)formatDescriptionLabelTextWithFormFieldValues:(NSArray *)formFieldValues {
    NSString *descriptionLabelText = nil;
    
    if ([formFieldValues count] > 0) {
        // If passed values cannot be casted to concrete user models
        // fallback to string representation
        id formFieldValue = formFieldValues.firstObject;
        if ([formFieldValue isKindOfClass:[ASDKModelUser class]]) {
            ASDKModelUser *selectedPeople = (ASDKModelUser *) formFieldValues.firstObject;
            descriptionLabelText = selectedPeople.normalisedName;
        } else {
            descriptionLabelText = formFieldValue;
        }
    } else {
        descriptionLabelText = ASDKLocalizedStringFromTable(kLocalizationFormPeopleNoSelectedText, ASDKLocalizationTable, @"No people selected");
    }
    
    return descriptionLabelText;
}


#pragma mark -
#pragma mark Cell states & validation

- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.descriptionLabel.text = nil;
    self.descriptionLabel.textColor = self.colorSchemeManager.formViewValidValueColor;
    self.selectedPeopleLabel.text = nil;
}

- (void)markCellValueAsInvalid {
    self.descriptionLabel.textColor = self.colorSchemeManager.formViewInvalidValueColor;
}

- (void)markCellValueAsValid {
    self.descriptionLabel.textColor = self.colorSchemeManager.formViewValidValueColor;
}

- (void)cleanInvalidCellValue {
    self.selectedPeopleLabel.text = nil;
}

- (void)validateCellStateForFormFieldValues:(NSArray *)formFieldValues {
    // Check input in relation to the requirement of the field
    if (self.isRequired) {
        if (!formFieldValues.count) {
            [self markCellValueAsInvalid];
        } else {
            [self markCellValueAsValid];
        }
    }
}

@end

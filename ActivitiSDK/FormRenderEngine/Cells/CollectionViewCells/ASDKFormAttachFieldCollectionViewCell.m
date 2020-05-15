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

#import "ASDKFormAttachFieldCollectionViewCell.h"

// Models
#import "ASDKModelFormField.h"
#import "ASDKModelFormFieldValue.h"
#import "ASDKModelContent.h"

// Managers
#import "ASDKBootstrap.h"
#import "ASDKServiceLocator.h"

// Constants
#import "ASDKFormRenderEngineConstants.h"
#import "ASDKLocalizationConstants.h"

@interface ASDKFormAttachFieldCollectionViewCell ()

@property (strong, nonatomic) ASDKModelFormField         *formField;
@property (assign, nonatomic) BOOL                       isRequired;

- (NSString *)formatDescriptionLabelTextWithFormFieldValues:(NSArray *)formfieldValues;
    
@end

@implementation ASDKFormAttachFieldCollectionViewCell

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
        self.selectedContentLabel.text = [self formatDescriptionLabelTextWithFormFieldValues:formField.values];
        self.selectedContentLabel.textColor = self.colorSchemeManager.formViewFilledInValueColor;
    } else {
        self.isRequired = formField.isRequired;

        // If a previously selected option is available display it
        if (formField.metadataValue) {
            self.selectedContentLabel.text = formField.metadataValue.attachedValue;
        } else if (formField.values) {
            self.selectedContentLabel.text = [self formatDescriptionLabelTextWithFormFieldValues:formField.values];
        } else {
            self.selectedContentLabel.text = ASDKLocalizedStringFromTable(kLocalizationFormAttachFileNoContentText, ASDKLocalizationTable, @"No content attached");
        }
        
        [self validateCellStateForFormFieldValues:formField.values];
    }
    
    self.disclosureIndicatorLabel.hidden = NO;
}

- (NSString *)formatDescriptionLabelTextWithFormFieldValues:(NSArray *)formfieldValues {
    NSString *descriptionLabelText = nil;
    
    if (!formfieldValues.count) {
        descriptionLabelText= ASDKLocalizedStringFromTable(kLocalizationFormAttachFileNoContentText, ASDKLocalizationTable, @"No content attached");
    } else if (formfieldValues.count == 1) {
        ASDKModelContent *firstAttachedContent = (ASDKModelContent *) formfieldValues.firstObject;
        
        descriptionLabelText = firstAttachedContent.contentName;
    } else {
        descriptionLabelText = [NSString stringWithFormat:ASDKLocalizedStringFromTable(kLocalizationFormAttachFileItemsAttachedText, ASDKLocalizationTable, @"Percent format"), formfieldValues.count];
    }
    
    return descriptionLabelText;
}

#pragma mark -
#pragma mark Cell states & validation

- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.descriptionLabel.text = nil;
    self.descriptionLabel.textColor = self.colorSchemeManager.formViewValidValueColor;
    self.selectedContentLabel.text = nil;
}

- (void)markCellValueAsInvalid {
    self.descriptionLabel.textColor = self.colorSchemeManager.formViewInvalidValueColor;
}

- (void)markCellValueAsValid {
    self.descriptionLabel.textColor = self.colorSchemeManager.formViewValidValueColor;
}

- (void)cleanInvalidCellValue {
    self.selectedContentLabel.text = nil;
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

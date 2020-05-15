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

#import "ASDKFormDynamicTableFieldCollectionViewCell.h"

// Models
#import "ASDKModelFormField.h"
#import "ASDKModelFormFieldValue.h"
#import "ASDKModelDynamicTableFormField.h"

// Constants
#import "ASDKFormRenderEngineConstants.h"
#import "ASDKLocalizationConstants.h"

@interface ASDKFormDynamicTableFieldCollectionViewCell ()

@property (strong, nonatomic) ASDKModelFormField            *formField;
@property (assign, nonatomic) BOOL                          isRequired;

@end

@implementation ASDKFormDynamicTableFieldCollectionViewCell

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
    
    ASDKModelDynamicTableFormField *dynamicTableFormField = (ASDKModelDynamicTableFormField *) formField;
    
    // If dealing with a read-only representation then disable the text field and copy the
    // user-filled value
    if (ASDKModelFormFieldRepresentationTypeReadOnly == formField.representationType &&
        !dynamicTableFormField.isTableEditable) {
        self.dynamicTableLabel.text = [self formatLabelTextWithFormFieldValues:formField.values];
        self.dynamicTableLabel.textColor = self.colorSchemeManager.formViewFilledInValueColor;
    } else {
        self.isRequired = formField.isRequired;
        // If a previously selected option is available display it
        self.dynamicTableLabel.text = [self formatLabelTextWithFormFieldValues:formField.values];

        [self validateCellStateForFormfieldValues:formField.values];
    }
    
    self.disclosureIndicatorLabel.hidden = NO;
}

- (NSString *)formatLabelTextWithFormFieldValues:(NSArray *)formfieldValues {
    NSString *labelText = nil;
    NSUInteger valuesCount = formfieldValues.count;
    
    if (valuesCount) {
        if (valuesCount == 1) {
            labelText = ASDKLocalizedStringFromTable(kLocalizationFormDynamicTableRowAvailableText, ASDKLocalizationTable, @"One field available text");
        } else {
            labelText = [NSString stringWithFormat:ASDKLocalizedStringFromTable(kLocalizationFormDynamicTableRowsAvailableText, ASDKLocalizationTable, @"Number of rows"), valuesCount];
        }
    } else {
        labelText = @"";
    }
    
    return labelText;
}


#pragma mark -
#pragma mark Cell states & validation

- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.descriptionLabel.text = nil;
    self.descriptionLabel.textColor = self.colorSchemeManager.formViewValidValueColor;
    self.dynamicTableLabel.text = nil;
}

- (void)markCellValueAsInvalid {
    self.descriptionLabel.textColor = self.colorSchemeManager.formViewInvalidValueColor;
}

- (void)markCellValueAsValid {
    self.descriptionLabel.textColor = self.colorSchemeManager.formViewValidValueColor;
}

- (void)validateCellStateForFormfieldValues:(NSArray *)formfieldValues {
    // Check input in relation to the requirement of the field
    if (self.isRequired) {
        if (!formfieldValues.count) {
            [self markCellValueAsInvalid];
        } else {
            [self markCellValueAsValid];
        }
    }
}

@end

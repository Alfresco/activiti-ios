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

#import "ASDKFormTextFieldCollectionViewCell.h"

// Constants
#import "ASDKLocalizationConstants.h"

// Models
#import "ASDKModelFormField.h"
#import "ASDKModelFormFieldValue.h"
#import "ASDKModelDynamicTableColumnDefinitionFormField.h"

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

@interface ASDKFormTextFieldCollectionViewCell () <UITextFieldDelegate>

@property (strong, nonatomic) ASDKModelFormField         *formField;
@property (assign, nonatomic) BOOL                       isRequired;

@end

@implementation ASDKFormTextFieldCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.textfield.delegate = self;
}


#pragma mark -
#pragma mark ASDKFormCellProtocol

- (void)setupCellWithFormField:(ASDKModelFormField *)formField {
    self.formField = formField;
    self.descriptionLabel.text = formField.fieldName;
    
    // We reuse the text field cell so check the input type mode based on the passed
    // form field
    self.keyBoardType = [self keyBoardTypeForFormField:formField];
    
    // If dealing with a read-only representation then disable the text field and copy the
    // user-filled value
    if (ASDKModelFormFieldRepresentationTypeReadOnly == formField.representationType) {
        NSString *formFieldValue = formField.values.firstObject;
        self.textfield.text = formFieldValue ? formFieldValue : ASDKLocalizedStringFromTable(kLocalizationFormValueEmpty, ASDKLocalizationTable, @"Empty value text");
        self.textfield.enabled = NO;
        self.textfield.textColor = self.colorSchemeManager.formViewFilledInValueColor;
    } else {
        BOOL isEditable = YES;
        self.isRequired = formField.isRequired;
        
        if ([formField isKindOfClass:[ASDKModelDynamicTableColumnDefinitionFormField class]]) {
            isEditable = ((ASDKModelDynamicTableColumnDefinitionFormField *)formField).editable;
        }
        isEditable = isEditable && !formField.isReadOnly;
        self.textfield.enabled = isEditable;
        self.textfield.placeholder = formField.placeholder;
        self.textfield.keyboardType = [self keyBoardTypeForValue:self.keyBoardType];
        
        // Check for any existing metadata value that might have been attached to the form
        // field object. If present, populate the text field with it
        if (self.formField.metadataValue) {
            self.textfield.text = self.formField.metadataValue.attachedValue;
        } else if (formField.values) {
            self.textfield.text = formField.values.firstObject;
        }
        
        [self validateCellStateForText:self.textfield.text];
    }
}

- (void)toggleFocusedState {
    if ([self.textfield isEditing]) {
        [self.textfield resignFirstResponder];
    } else {
        [self.textfield becomeFirstResponder];
    }
}


#pragma mark -
#pragma mark TextField Delegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    ASDKModelFormFieldValue *metadataValue = [ASDKModelFormFieldValue new];
    metadataValue.attachedValue = textField.text;
    self.formField.metadataValue = metadataValue;
    
    if ([self.delegate respondsToSelector:@selector(updatedMetadataValueForFormField:inCell:)]) {
        [self.delegate updatedMetadataValueForFormField:self.formField
                                                 inCell:self];
    }
}

- (IBAction)onTextFieldValueChange:(UITextField *)sender {
    // If the value of this cell is required check it's state every time
    // the value of the text field changes
    [self validateCellStateForText:sender.text];
}


#pragma mark -
#pragma mark Cell states & validation

- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.descriptionLabel.text = nil;
    self.descriptionLabel.textColor = self.colorSchemeManager.formViewValidValueColor;
    self.textfield.text = nil;
}

- (void)markCellValueAsInvalid {
    self.descriptionLabel.textColor = self.colorSchemeManager.formViewInvalidValueColor;
}

- (void)markCellValueAsValid {
    self.descriptionLabel.textColor = self.colorSchemeManager.formViewValidValueColor;
}

- (void)cleanInvalidCellValue {
    self.textfield.text = nil;
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
    
    // Check input in relation to the type of input
    if (ASDKFormTextFieldKeyboardTypeNumerical == self.keyBoardType) {
        NSCharacterSet *alphaNums = [NSCharacterSet decimalDigitCharacterSet];
        NSCharacterSet *inStringSet = [NSCharacterSet characterSetWithCharactersInString:text];
        BOOL isStringSetAlphaNumeric = [alphaNums isSupersetOfSet:inStringSet];
        if (!isStringSetAlphaNumeric) {
            [self cleanInvalidCellValue];
        }
    }
}

- (UIKeyboardType)keyBoardTypeForValue:(ASDKFormTextFieldKeyboardType)enumValue {
    switch (enumValue) {
        case ASDKFormTextFieldKeyboardTypeASCII: {
            return UIKeyboardTypeASCIICapable;
        }
            break;
            
        case ASDKFormTextFieldKeyboardTypeNumerical: {
            return UIKeyboardTypeNumberPad;
        }
            break;
            
        default:
            break;
    }
    
    return UIKeyboardTypeDefault;
}

- (ASDKFormTextFieldKeyboardType)keyBoardTypeForFormField:(ASDKModelFormField *)formField {
    ASDKModelFormFieldRepresentationType fieldRepresentationType = ASDKModelFormFieldRepresentationTypeUndefined;
    
    if (ASDKModelFormFieldRepresentationTypeReadOnly == formField.representationType) {
        fieldRepresentationType = formField.formFieldParams.representationType;
    } else {
        fieldRepresentationType = formField.representationType;
    }
    
    switch (fieldRepresentationType) {
        case ASDKModelFormFieldRepresentationTypeText: {
            return ASDKFormTextFieldKeyboardTypeASCII;
        }
            break;
        
        case ASDKModelFormFieldRepresentationTypeNumerical: {
            return ASDKFormTextFieldKeyboardTypeNumerical;
        }
            break;
            
        default:
            break;
    }
    
    // If a match can't be found use the ASCII keyboard;
    return ASDKFormTextFieldKeyboardTypeASCII;
}

@end

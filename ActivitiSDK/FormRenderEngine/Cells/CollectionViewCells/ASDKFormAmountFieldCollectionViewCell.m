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

#import "ASDKFormAmountFieldCollectionViewCell.h"

// Constants
#import "ASDKLocalizationConstants.h"

// Models
#import "ASDKModelAmountFormField.h"
#import "ASDKModelFormField.h"
#import "ASDKModelFormFieldValue.h"

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

@interface ASDKFormAmountFieldCollectionViewCell () <UITextFieldDelegate>

@property (strong, nonatomic) ASDKModelAmountFormField      *currentFormField;
@property (assign, nonatomic) BOOL                          isRequired;
@property (assign, nonatomic) BOOL                          isFractionsEnabled;

@end

@implementation ASDKFormAmountFieldCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.amountTextfield.delegate = self;
}


#pragma mark -
#pragma mark ASDKFormCellProtocol

- (void)setupCellWithFormField:(ASDKModelFormField *)formField {
    self.currentFormField = (ASDKModelAmountFormField *) formField;
    self.isFractionsEnabled = self.currentFormField.enableFractions;
    
    // adding currency label to field label
    NSString *currencySymbol = (self.currentFormField.currency.length != 0) ? self.currentFormField.currency : @"$";
    NSMutableAttributedString *labelText = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ (%@)", formField.fieldName, currencySymbol]];
    [labelText addAttribute:NSForegroundColorAttributeName
                      value:self.colorSchemeManager.formViewAmountFieldSymbolColor
                      range:NSMakeRange((labelText.length) - 3,3)];

    self.descriptionLabel.attributedText = labelText;

    // Check if form field is a display value form field
    // In this case the structure received from the server is a bit different
    // then regular or completed form fields and we should handle it accordingly
    if (ASDKModelFormFieldRepresentationTypeReadOnly == formField.representationType) {
        NSString *formFieldValue = formField.values.firstObject;
        self.amountTextfield.text = formFieldValue ? [NSString stringWithFormat:@"%@", formFieldValue] : ASDKLocalizedStringFromTable(kLocalizationFormValueEmpty, ASDKLocalizationTable, @"Empty value text");
        self.amountTextfield.enabled = NO;
        self.amountTextfield.textColor = self.colorSchemeManager.formViewFilledInValueColor;
    } else {
        self.isRequired = formField.isRequired;
        self.amountTextfield.placeholder = formField.placeholder;
        self.amountTextfield.enabled = !formField.isReadOnly;
        
        // Check for any existing metadata value that might have been attached to the form
        // field object. If present, populate the text field with it

        if (self.currentFormField.enableFractions) {
            self.amountTextfield.keyboardType = UIKeyboardTypeDecimalPad;
        } else {
            self.amountTextfield.keyboardType = UIKeyboardTypeNumberPad;
        }
    
        if (self.currentFormField.metadataValue) {
            self.amountTextfield.text = formField.metadataValue.attachedValue;
        } else if (formField.values) {
            self.amountTextfield.text = [NSString stringWithFormat:@"%@", formField.values.firstObject];
        }

        [self validateCellStateForText:self.amountTextfield.text];
    }
}

- (void)toggleFocusedState {
    if ([self.amountTextfield isEditing]) {
        [self.amountTextfield resignFirstResponder];
    } else {
        [self.amountTextfield becomeFirstResponder];
    }
}


#pragma mark -
#pragma mark TextField Delegate methods

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    __weak typeof(self) weakSelf = self;
    
    // Dispatch the metadata update in the next processing cycle
    // to give room for all UITextfield delegate methods to get
    // executed - the metadata update method triggers a collection
    // view reload which causes certain delegate methods calls to
    // be intrerupted
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(self) strongSelf = weakSelf;
        
        if (self.amountTextfield == textField) {
            if (self.isFractionsEnabled) {
                if (textField.text.length > 0) {
                    NSRange rangeAfterSeperator = [textField.text rangeOfString:@"."];
                
                    if (rangeAfterSeperator.length != 0) {
                        NSUInteger lengthAfterDotPosition = [textField.text substringFromIndex:rangeAfterSeperator.location].length;
                        
                        if (lengthAfterDotPosition == 1) {
                            textField.text = [textField.text stringByAppendingString:@"00"];
                        } else if (lengthAfterDotPosition == 2) {
                            textField.text = [textField.text stringByAppendingString:@"0"];
                        }
                    } else if (rangeAfterSeperator.location == NSNotFound) {
                       textField.text = [textField.text stringByAppendingString:@".00"];
                    }
                }
            }
        }
        
        ASDKModelFormFieldValue *formFieldValue = [ASDKModelFormFieldValue new];
        formFieldValue.attachedValue = textField.text;
        strongSelf.currentFormField.metadataValue = formFieldValue;
        
        if ([strongSelf.delegate respondsToSelector:@selector(updatedMetadataValueForFormField:inCell:)]) {
            [strongSelf.delegate updatedMetadataValueForFormField:strongSelf.currentFormField
                                                           inCell:strongSelf];
        }
    });
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField
shouldChangeCharactersInRange:(NSRange)range
replacementString:(NSString *)string {
    if (self.amountTextfield == textField) {
        if (self.isFractionsEnabled) {
            if ([textField.text containsString:@"."]) {
                // if . is present no other . allowed
                if ([string isEqualToString:@"."]) {
                    return NO;
                }
                
                // check there can be only 2 decimal digits
                NSRange range = [textField.text rangeOfString:@"."];
                NSUInteger lengthAfterDotPosition = [textField.text substringFromIndex:range.location].length + string.length;
                
                if (lengthAfterDotPosition > 3) {
                    return NO;
                }
            }
        }
    }
    
    return YES;
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
    self.amountTextfield.text = nil;
}

- (void)markCellValueAsInvalid {
    self.descriptionLabel.textColor = self.colorSchemeManager.formViewInvalidValueColor;
}

- (void)markCellValueAsValid {
    self.descriptionLabel.textColor = self.colorSchemeManager.formViewValidValueColor;
}

- (void)cleanInvalidCellValue {
    self.amountTextfield.text = nil;
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

/*******************************************************************************
 * Copyright (C) 2005-2020 Alfresco Software Limited.
 *
 * This file is part of the Alfresco Activiti Mobile iOS App.
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

#import "AFACredentialTextFieldTableViewCell.h"
#import "AFAUIConstants.h"
#import "UIView+AFAViewAnimations.h"

// Internal scope constants
CGFloat kHairlineViewAlphaFull      = 1.0f;
CGFloat kHairlineViewAlphaDimmed    = 0.5f;

@implementation AFACredentialTextFieldTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.hairlineView.alpha = kHairlineViewAlphaDimmed;
    self.inputTextField.delegate = self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected
              animated:animated];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.inputTextField.text = nil;
    self.inputTextField.keyboardType = UIKeyboardTypeDefault;
    self.inputTextField.secureTextEntry = NO;
    self.inputTextField.returnKeyType = UIReturnKeyNext;
    self.cellType = AFACredentialTextFieldCellTypeUnsecured;
    self.delegate = nil;
    _inputText = nil;
}


#pragma mark -
#pragma mark UITextField Delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    self.passwordButton.hidden = (AFACredentialTextFieldCellTypeUnsecured == self.cellType) ? YES : NO;
    
    if (AFACredentialTextFieldCellTypeUnsecured == self.cellType) {
        self.clearButton.hidden = textField.text.length ? NO : YES;
    }
    
    if ([self.delegate respondsToSelector:@selector(inputTextFieldWillBeginEditting:inCell:)]) {
        [self.delegate inputTextFieldWillBeginEditting:textField
                                                inCell:self];
    }

    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    if ([self.delegate respondsToSelector:@selector(inputTextFieldWillEndEditting:inCell:)]) {
        [self.delegate inputTextFieldWillEndEditting:textField
                                              inCell:self];
    }

    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([self.delegate respondsToSelector:@selector(inputTextFieldShouldReturn:inCell:)]) {
        [self.delegate inputTextFieldShouldReturn:textField
                                           inCell:self];
    }
    
    return NO;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self.hairlineView animateAlpha:kHairlineViewAlphaFull
                       withDuration:kDefaultAnimationTime
                withCompletionBlock:nil];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self.hairlineView animateAlpha:kHairlineViewAlphaDimmed
                       withDuration:kDefaultAnimationTime
                withCompletionBlock:nil];
    
    self.clearButton.hidden = YES;
    self.passwordButton.hidden = YES;
    
    self.inputText = textField.text;
}


#pragma mark -
#pragma mark Actions

- (IBAction)onClear:(id)sender {
    self.inputTextField.text = @"";
    self.clearButton.hidden = YES;
}

- (IBAction)onPasswordShow:(id)sender {
    [self.inputTextField resignFirstResponder];
    self.inputTextField.secureTextEntry = !self.inputTextField.secureTextEntry;
    [self.inputTextField becomeFirstResponder];
    
    [self.passwordButton setImage:self.inputTextField.secureTextEntry ? [UIImage imageNamed:@"show-password-icon"] : [UIImage imageNamed:@"hide-password-icon"]
                         forState:UIControlStateNormal];
}

- (IBAction)onTextChangeEvent:(UITextField *)sender {
    self.clearButton.hidden = (AFACredentialTextFieldCellTypeUnsecured == self.cellType) ? ((sender.text.length) ? NO : YES) : YES;
}

@end

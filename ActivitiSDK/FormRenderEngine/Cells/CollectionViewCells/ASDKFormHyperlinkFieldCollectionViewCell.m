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

#import "ASDKFormHyperlinkFieldCollectionViewCell.h"

// Models
#import "ASDKModelFormField.h"
#import "ASDKModelFormFieldValue.h"
#import "ASDKModelHyperlinkFormField.h"

// Constants
#import "ASDKFormRenderEngineConstants.h"

@interface ASDKFormHyperlinkFieldCollectionViewCell ()

@property (strong, nonatomic) ASDKModelHyperlinkFormField   *formField;

@end

@implementation ASDKFormHyperlinkFieldCollectionViewCell

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
    ASDKModelHyperlinkFormField *hyperlinkFormField = (ASDKModelHyperlinkFormField *) formField;
    self.formField = hyperlinkFormField;

    self.descriptionLabel.text = formField.fieldName;

    if (self.formField.displayText != nil) {
        [self.hyperlinkButton setTitle:self.formField.displayText forState:UIControlStateNormal];
    } else if (self.formField.hyperlinkURL != nil) {
        [self.hyperlinkButton setTitle:self.formField.hyperlinkURL forState:UIControlStateNormal];
    } else {
        [self.hyperlinkButton setTitle:@"" forState:UIControlStateNormal];
    }
}

- (IBAction)hyperlinkTapped:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.formField.hyperlinkURL]
                                       options:@{}
                             completionHandler:nil];
}

@end

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

#import "ASDKFormDisplayTextFieldCollectionViewCell.h"

// Models
#import "ASDKModelFormField.h"
#import "ASDKModelFormFieldValue.h"

// Constants
#import "ASDKFormRenderEngineConstants.h"
#import "ASDKLocalizationConstants.h"

@interface ASDKFormDisplayTextFieldCollectionViewCell ()

@property (strong, nonatomic) ASDKModelFormField         *formField;

@end

@implementation ASDKFormDisplayTextFieldCollectionViewCell

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
    
    NSString *formFieldDisplayText = formField.values.firstObject;
    
    self.displayTextLabel.text = formFieldDisplayText ? formFieldDisplayText : ASDKLocalizedStringFromTable(kLocalizationFormValueEmpty, ASDKLocalizationTable, @"Empty value text");
    self.disclosureIndicatorLabel.hidden = formFieldDisplayText.length ? NO : YES;
}

#pragma mark -
#pragma mark Cell states & validation

- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.displayTextLabel.text = nil;
    self.disclosureIndicatorLabel.hidden = NO;
}

@end

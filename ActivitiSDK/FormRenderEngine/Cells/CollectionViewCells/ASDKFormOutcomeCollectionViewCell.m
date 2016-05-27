/*******************************************************************************
 * Copyright (C) 2005-2016 Alfresco Software Limited.
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

#import "ASDKFormOutcomeCollectionViewCell.h"
#import "ASDKModelFormOutcome.h"
#import "UIColor+ASDKFormViewColors.h"

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

@interface ASDKFormOutcomeCollectionViewCell ()

@property (strong, nonatomic) ASDKModelFormOutcome *formOutcome;

@end

@implementation ASDKFormOutcomeCollectionViewCell

- (UICollectionViewLayoutAttributes *)preferredLayoutAttributesFittingAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes {
    // Adjust the cell sizing parameters by constraining with a high priority on the horizontal axis
    // and a lower priority on the vertical axis
    UICollectionViewLayoutAttributes *attributes = [super preferredLayoutAttributesFittingAttributes:layoutAttributes];
    attributes.size = CGSizeMake(layoutAttributes.size.width, attributes.size.height);
    return attributes;
}


#pragma mark -
#pragma mark ASDKFormCellProtocol

- (void)setupCellWithFormOutcome:(ASDKModelFormOutcome *)formOutcome
               enableFormOutcome:(BOOL)enableFormOutcome {
    self.formOutcome = formOutcome;
    
    [UIView performWithoutAnimation:^{
        [self.outcomeButton setTitle:formOutcome.name
                            forState:UIControlStateNormal];
        [self.outcomeButton layoutIfNeeded];
    }];
    
    [self enableOutcomeButton:enableFormOutcome];
}


#pragma mark -
#pragma mark Button actions

- (IBAction)onFormOutcome:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(completeFormWithOutcome:)]) {
        [self.delegate completeFormWithOutcome:self.formOutcome];
    }
}


#pragma mark -
#pragma mark Cell states & validation

- (void)prepareForReuse {
    [UIView performWithoutAnimation:^{
        [self.outcomeButton setTitle:nil
                            forState:UIControlStateNormal];
        [self.outcomeButton layoutIfNeeded];
    }];
    self.outcomeButton.backgroundColor = [UIColor formViewOutcomeEnabledColor];
}

- (void)enableOutcomeButton:(BOOL)enabled {
    self.outcomeButton.enabled = enabled;
    self.outcomeButton.backgroundColor = enabled ? [UIColor formViewOutcomeEnabledColor] : [UIColor formViewOutcomeDisabledColor];
}

@end
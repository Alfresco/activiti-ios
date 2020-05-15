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

#import "AFAProcessDefinitionListStyleTableViewCell.h"
@import ActivitiSDK;

@interface AFAProcessDefinitionListStyleTableViewCell ()

@end

@implementation AFAProcessDefinitionListStyleTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}


#pragma mark -
#pragma mark Setters

- (void)setApplicationThemeColor:(UIColor *)applicationThemeColor {
    if (_applicationThemeColor != applicationThemeColor) {
        _applicationThemeColor = applicationThemeColor;
        
        UIView *backgroundColorView = [UIView new];
        backgroundColorView.backgroundColor = [_applicationThemeColor colorWithAlphaComponent:.2f];
        [self setSelectedBackgroundView:backgroundColorView];
        self.hairlineLeadingView.backgroundColor = _applicationThemeColor ? _applicationThemeColor : [UIColor clearColor];
    }
}


#pragma mark -
#pragma mark Public interface

- (void)setupWithProcessDefinition:(ASDKModelProcessDefinition *)processDefinition {
    self.processDefinitionTitleLabel.text = processDefinition.name;
}

@end

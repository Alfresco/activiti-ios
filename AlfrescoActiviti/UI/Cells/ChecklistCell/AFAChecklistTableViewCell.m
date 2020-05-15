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

#import "AFAChecklistTableViewCell.h"
#import "AFALocalizationConstants.h"
#import "UIColor+AFATheme.h"
@import ActivitiSDK;

@implementation AFAChecklistTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.descriptionLabel.text = NSLocalizedString(kLocalizationTaskDetailsScreenChecklistNameText, @"Checklist name text");
}


#pragma mark -
#pragma mark Setters

- (void)setApplicationThemeColor:(UIColor *)applicationThemeColor {
    if (_applicationThemeColor != applicationThemeColor) {
        _applicationThemeColor = applicationThemeColor;
        
        UIView *backgroundColorView = [UIView new];
        backgroundColorView.backgroundColor = [_applicationThemeColor colorWithAlphaComponent:.2f];
        [self setSelectedBackgroundView:backgroundColorView];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setEditing:(BOOL)editing
          animated:(BOOL)animated{
    [super setEditing:editing
             animated:animated];
    
    self.disclosureIndicatorLabel.hidden = editing;
}


#pragma mark -
#pragma mark Public interface

- (void)setUpCellWithTask:(ASDKModelTask *)task {
    self.checklistNameLabel.text = task.name;
    self.iconImageView.tintColor = (task.endDate && task.duration) ? [UIColor checkmarkedActionColor] : [UIColor disabledControlColor];
}

@end

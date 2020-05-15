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

#import "AFAAttachFormTableViewCell.h"
#import "UIColor+AFATheme.h"
#import "AFALocalizationConstants.h"

@implementation AFAAttachFormTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self.attachedFormButton setTitle:NSLocalizedString(kLocalizationTaskDetailsScreenShowFormText, @"Show form text")
                             forState:UIControlStateNormal];
    self.iconImageView.tintColor = [UIColor disabledControlColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


#pragma mark -
#pragma mark Actions

- (IBAction)onAttachedForm:(id)sender {
    if ([self.delegate respondsToSelector:@selector(onViewAttachedFormTap)]) {
        [self.delegate onViewAttachedFormTap];
    }
}


@end

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

#import "AFADueTableViewCell.h"
#import "AFALocalizationConstants.h"
#import "NSDate+AFAStringTransformation.h"
#import "UIColor+AFATheme.h"
@import ActivitiSDK;

@implementation AFADueTableViewCell


#pragma mark -
#pragma mark Life cycle

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.dueLabel.text = NSLocalizedString(kLocalizationTaskDetailsScreenDueText, @"Due text");
    self.iconImageView.tintColor = [UIColor disabledControlColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - 
#pragma mark Actions

- (IBAction)onAddDueDate:(id)sender {
    if ([self.delegate respondsToSelector:@selector(onAddDueDateTap)]) {
        [self.delegate onAddDueDateTap];
    }
}

#pragma mark -
#pragma mark Public interface

- (void)setUpCellWithTask:(ASDKModelTask *)task {
    BOOL taskHasDueDate = task.dueDate ? YES : NO;
    
    // If we're dealing with a completed task just display the value
    // or that there's no value - don't show the add button
    if (task.endDate) {
        self.dueDateLabel.hidden = NO;
        self.addDueDateButton.hidden = YES;
        
        self.dueDateLabel.text = taskHasDueDate ? [task.dueDate dueDateFormattedString] : NSLocalizedString(kLocalizationTaskDetailsScreenNoDueDateText, @"No due date text");
    } else {
        // If there is no due date set
        if (!taskHasDueDate) {
            [self.addDueDateButton setTitle:NSLocalizedString(kLocalizationTaskDetailsScreenAddDueDateText, @"Add due label text")
                                   forState:UIControlStateNormal];
            self.addDueDateButton.hidden = NO;
            self.dueDateLabel.hidden = YES;
            self.editButtonImageView.hidden = YES;
        } else { // Alow the user to change it
            [self.addDueDateButton setTitle:@""
                                   forState:UIControlStateNormal];
            self.addDueDateButton.hidden = NO;
            self.editButtonImageView.hidden = NO;
            self.dueDateLabel.hidden = NO;
            self.dueDateLabel.text = [task.dueDate dueDateFormattedString];
        }
    }
}

- (void)updateStateForConnectivity:(BOOL)isConnectivityAvailable {
    self.addDueDateButton.enabled = isConnectivityAvailable;
}

@end

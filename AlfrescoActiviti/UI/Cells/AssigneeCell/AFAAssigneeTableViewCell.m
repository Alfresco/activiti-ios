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

#import "AFAAssigneeTableViewCell.h"
#import "AFALocalizationConstants.h"
#import "UIColor+AFATheme.h"
@import ActivitiSDK;

@implementation AFAAssigneeTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.iconImageView.tintColor = [UIColor disabledControlColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setUpCellWithTask:(ASDKModelTask *)task
  isConnectivityAvailable:(BOOL)isConnectivityAvailable {
    self.assigneeLabel.text = NSLocalizedString(kLocalizationTaskDetailsScreenAssignedToText, @"Assignee text");
    
    BOOL isAssigneeButtonEnabled = YES;
    NSString *assigneeName = nil;
    if (task.assigneeModel.userFirstName || task.assigneeModel.userLastName) {
        assigneeName = [task.assigneeModel normalisedName];
    } else {
        assigneeName = NSLocalizedString(kLocalizationTaskDetailsScreenNoInvolvedPeopleText, @"No people involved text");
        isAssigneeButtonEnabled = NO;
    }
    
    // Assignee button can be triggered only when there is an assignee
    // available, the task is not completed and there is connectivity available
    isAssigneeButtonEnabled = isAssigneeButtonEnabled && !task.endDate;
    isAssigneeButtonEnabled = isAssigneeButtonEnabled && isConnectivityAvailable;
    
    self.assigneeNameButton.enabled = isAssigneeButtonEnabled;
    [self.assigneeNameButton setTitle:assigneeName
                             forState:UIControlStateNormal];
}

- (void)setupCellWithProcessInstance:(ASDKModelProcessInstance *)processInstance {
    // Assignee button cannot trigger any action when configured with a process instance
    // so disable it in this case
    self.assigneeNameButton.enabled = NO;
    self.assigneeLabel.text = NSLocalizedString(kLocalizationProcessInstanceDetailsScreenStartedByText, @"Started by text");

    NSString *assigneeName = nil;
    if (processInstance.initiatorModel.userFirstName || processInstance.initiatorModel.userLastName) {
        assigneeName = [processInstance.initiatorModel normalisedName];
    } else {
        assigneeName = NSLocalizedString(kLocalizationTaskDetailsScreenNoInvolvedPeopleText, @"No people involved text");
    }
    
    [self.assigneeNameButton setTitle:assigneeName
                             forState:UIControlStateNormal];
}


#pragma mark -
#pragma mark Actions

- (IBAction)onAssigneeName:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(onChangeAssignee)]) {
        [self.delegate onChangeAssignee];
    }
}


@end

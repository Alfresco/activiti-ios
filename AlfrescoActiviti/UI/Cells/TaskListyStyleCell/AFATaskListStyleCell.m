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

#import "AFATaskListStyleCell.h"
#import "UIColor+AFATheme.h"
#import "NSDate+AFAStringTransformation.h"
#import "AFALocalizationConstants.h"
@import ActivitiSDK;

@implementation AFATaskListStyleCell


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

- (void)setupWithTask:(ASDKModelTask *)task {
    self.taskNameLabel.text = task.name ? task.name : NSLocalizedString(kLocalizationListScreenNoTaskNameText, @"No task name available");
    self.taskDescriptionLabel.text = task.taskDescription;
    self.creationDateLabel.text = [task.creationDate listCreationDate];

    BOOL taskHasDueDate = task.dueDate ? YES : NO;
    self.dueDateIconImageView.hidden = !taskHasDueDate;
    self.dueDateLabel.hidden = !taskHasDueDate;
    if (taskHasDueDate) {
        self.dueDateLabel.text = [task.dueDate dueDateFormattedString];
    }
}

- (void)setupWithProcessInstance:(ASDKModelProcessInstance *)processInstance {
    self.taskNameLabel.text = processInstance.name ? processInstance.name : NSLocalizedString(kLocalizationProcessInstanceDetailsScreenNoTitleNameText, @"No process instance name available");
    self.taskDescriptionLabel.text = processInstance.processDefinitionDescription;
    self.creationDateLabel.text = [processInstance.startDate listCreationDate];
    BOOL processInstanceHasEndDate = processInstance.endDate ? YES : NO;
    self.dueDateIconImageView.hidden = !processInstanceHasEndDate;
    self.dueDateLabel.hidden = !processInstanceHasEndDate;
    if (processInstanceHasEndDate) {
        self.dueDateLabel.text = [processInstance.endDate listEndedDate];
    }
}

@end

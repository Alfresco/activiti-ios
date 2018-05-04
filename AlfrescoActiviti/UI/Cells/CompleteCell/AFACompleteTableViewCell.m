/*******************************************************************************
 * Copyright (C) 2005-2018 Alfresco Software Limited.
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

#import "AFACompleteTableViewCell.h"
#import "AFALocalizationConstants.h"

@implementation AFACompleteTableViewCell


#pragma mark
#pragma mark - Life cycle

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self.completeTaskButton setTitle:NSLocalizedString(kLocalizationTaskDetailsScreenCompleteTaskButtonText, @"Complete task text")
                             forState:UIControlStateNormal];
    [self.requeueTaskButton setTitle:NSLocalizedString(kLocalizationTaskDetailsScreenRequeueTaskButtonText, @"Requeue task text")
                            forState:UIControlStateNormal];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}


#pragma mark -
#pragma mark Public interface

- (void)setUpWithThemeColor:(UIColor *)themeColor {
    self.completeTaskRoundedBorderView.fillColor = themeColor;
    self.requeueRoundedBorderView.fillColor = themeColor;
    self.backgroundColor = [themeColor colorWithAlphaComponent:.4f];
}

- (void)updateStateForConnectivity:(BOOL)isConnectivityAvailable {
    self.completeTaskButton.enabled = isConnectivityAvailable;
    self.requeueTaskButton.enabled = isConnectivityAvailable;
}


#pragma mark -
#pragma mark Actions

- (IBAction)onCompleteTask:(id)sender {
    if ([self.delegate respondsToSelector:@selector(onCompleteTask)]) {
        [self.delegate onCompleteTask];
    }
}

- (IBAction)onRequeue:(id)sender {
    if ([self.delegate respondsToSelector:@selector(onRequeueTask)]) {
        [self.delegate onRequeueTask];
    }
}

@end

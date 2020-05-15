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

#import "AFAShowDiagramTableViewCell.h"
#import "AFALocalizationConstants.h"

@implementation AFAShowDiagramTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self.showDiagramButton setTitle:NSLocalizedString(kLocalizationProcessInstanceDetailsScreenShowDiagramText, @"Show diagram text")
                            forState:UIControlStateNormal];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark -
#pragma mark Public interface

- (void)setUpWithThemeColor:(UIColor *)themeColor {
    self.showDiagramRoundedBorderView.fillColor = themeColor;
    self.backgroundColor = [themeColor colorWithAlphaComponent:.4f];
}

- (void)setupWithProcessInstance:(ASDKModelProcessInstance *)processInstance {
    // If the process is currently running then display the cancel option,
    // otherwise display the delete option
    self.processControlButton.hidden = NO;
    self.processControlRoundedBorderView.hidden = NO;
    
    if (!processInstance.endDate) {
        [self.processControlButton setTitle:NSLocalizedString(kLocalizationProcessInstanceDetailsScreenCancelProcessButtonText, @"Cancel process text")
                                   forState:UIControlStateNormal];
    } else {
        [self.processControlButton setTitle:NSLocalizedString(kLocalizationProcessInstanceDetailsScreenDeleteProcessButtonText, @"Delete process text")
                                   forState:UIControlStateNormal];
    }
}

- (void)updateStateForConnectivity:(BOOL)isConnectivityAvailable {
    self.processControlButton.enabled = isConnectivityAvailable;
}


#pragma mark -
#pragma mark Actions

- (IBAction)onShowDiagram:(id)sender {
    if ([self.delegate respondsToSelector:@selector(onShowDiagram)]) {
        [self.delegate onShowDiagram];
    }
}

- (IBAction)onProcessCotrol:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(onProcessControl)]) {
        [self.delegate onProcessControl];
    }
}


@end

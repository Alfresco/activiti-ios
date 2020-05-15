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

#import "AFAContributorTableViewCell.h"
@import ActivitiSDK;

@implementation AFAContributorTableViewCell

#pragma mark -
#pragma makr Life cycle

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark -
#pragma mark Public interface

- (void)setUpCellWithProfile:(ASDKModelProfile *)profile {
    NSString *contributorName = nil;
    if (profile.userFirstName.length) {
        contributorName = profile.userFirstName;
    }
    
    if (profile.userLastName.length) {
        if (contributorName.length) {
            contributorName = [contributorName stringByAppendingFormat:@" %@", profile.userLastName];
        } else {
            contributorName = profile.userLastName;
        }
    }
    
    self.contributorNameLabel.text = contributorName;
    [self.avararInitialsView updateInitialsForName:contributorName];
}

- (void)setUpCellWithUser:(ASDKModelUser *)user {
    NSString *contributorName = nil;
    if (user.userFirstName.length) {
        contributorName = user.userFirstName;
    }
    
    if (user.userLastName.length) {
        if (contributorName.length) {
            contributorName = [contributorName stringByAppendingFormat:@" %@", user.userLastName];
        } else {
            contributorName = user.userLastName;
        }
    }
    
    self.contributorNameLabel.text = contributorName;
    [self.avararInitialsView updateInitialsForName:contributorName];
}

@end

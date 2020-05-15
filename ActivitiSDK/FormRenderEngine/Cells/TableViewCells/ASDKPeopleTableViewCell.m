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

#import "ASDKPeopleTableViewCell.h"
#import "ASDKModelProfile.h"
#import "ASDKModelUser.h"

@implementation ASDKPeopleTableViewCell

#pragma mark -
#pragma mark Life cycle

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
    self.contributorNameLabel.text = profile.normalisedName;
    [self.avararInitialsView updateInitialsForName:profile.normalisedName];
}

- (void)setUpCellWithUser:(ASDKModelUser *)user {
    self.contributorNameLabel.text = user.normalisedName;
    [self.avararInitialsView updateInitialsForName:user.normalisedName];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setupCellWithUserNameString:(NSString *)userNameString {
    self.contributorNameLabel.text = userNameString;
    [self.avararInitialsView updateInitialsForName:userNameString];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

@end

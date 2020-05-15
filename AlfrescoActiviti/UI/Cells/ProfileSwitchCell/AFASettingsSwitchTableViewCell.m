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

#import "AFASettingsSwitchTableViewCell.h"
#import "AFALocalizationConstants.h"
@import ActivitiSDK;

@interface AFASettingsSwitchTableViewCell ()

@property (strong, nonatomic) ASDKKVOManager *kvoManager;

@end

@implementation AFASettingsSwitchTableViewCell

- (void)dealloc {
    [self.kvoManager removeObserver:self.switchControl
                         forKeyPath:NSStringFromSelector(@selector(isOn))];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        self.kvoManager = [ASDKKVOManager managerWithObserver:self];
    }
    
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.switchControl.onLabelText = NSLocalizedString(kLocalizationLoginHostnameSwitchONText, @"ON label");
    self.switchControl.offLabelText = NSLocalizedString(kLocalizationLoginHostnameSwitchOFFText, @"OFF label");
    
    __weak typeof(self) weakSelf = self;
    [self.kvoManager observeObject:self.switchControl
                        forKeyPath:NSStringFromSelector(@selector(isOn))
                           options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                             block:^(id observer, id object, NSDictionary *change) {
                                 __strong typeof(self) strongSelf = weakSelf;
                                 
                                 if ([change[NSKeyValueChangeNewKey] boolValue] != [change[NSKeyValueChangeOldKey] boolValue]) {
                                     if ([strongSelf.delegate respondsToSelector:@selector(didUpdateSwitchStateTo:)]) {
                                         [strongSelf.delegate didUpdateSwitchStateTo: [change[NSKeyValueChangeNewKey] boolValue]];
                                     }
                                 }
                             }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end

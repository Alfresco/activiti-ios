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

#import "AFASettingsViewController.h"

// Constants
#import "AFALocalizationConstants.h"
#import "AFAUIConstants.h"

// Categories
#import "UIColor+AFATheme.h"

// Cells
#import "AFAProfileSectionTableViewCell.h"
#import "AFAProfileActionTableViewCell.h"
#import "AFASettingsUsageTableViewCell.h"
#import "AFASettingsSwitchTableViewCell.h"

// Frameworks
#import <Buglife/Buglife.h>

typedef NS_ENUM(NSInteger, AFASettingsControllerSectionType) {
    AAFASettingsControllerSectionTypeStorage = 0,
    AFASettingsControllerSectionTypeCleanCache,
    AFASettingsControllerSectionTypeReportTool,
    AFASettingsControllerSectionTypeEnumCount
};

typedef NS_ENUM(NSInteger, AFASettingsControllerStorageType) {
    AFASettingsControllerStorageTypeAvailable = 0,
    AFASettingsControllerStorageTypeActivitiData,
    AFASettingsControllerStorageTypeEnumCount
};

static const CGFloat kSettingsControllerSectionHeight = 40.0f;

@interface AFASettingsViewController () <AFAProfileActionTableViewCellDelegate, AFASettingsSwitchTableViewCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *settingsTableView;

@end

@implementation AFASettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Update navigation bar title
    self.navigationBarTitle = NSLocalizedString(kLocalizationSettingsText, @"Settings title");
    
    // Set up the task list table view to adjust it's size automatically
    self.settingsTableView.estimatedRowHeight = 40.0f;
    self.settingsTableView.rowHeight = UITableViewAutomaticDimension;
    //    self.settingsTableView.contentInset = UIEdgeInsetsMake(.0f, .0f, 20.0f, .0f);
}


#pragma mark -
#pragma mark AFAProfileActionTableViewCellDelegate

- (void)profileActionChosenForCell:(UITableViewCell *)cell {
    NSIndexPath *indexPath = [self.settingsTableView indexPathForCell:cell];
    
    if (AFASettingsControllerSectionTypeCleanCache == indexPath.section) {
        UIAlertController *cleanCacheAlertController = [UIAlertController alertControllerWithTitle:nil
                                                                                           message:NSLocalizedString(kLocalizationProfileScreenCleanCacheAlertText, @"Clean cache alert text")
                                                                                    preferredStyle:UIAlertControllerStyleAlert];
        
        __weak typeof(self) weakSelf = self;
        UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:NSLocalizedString(kLocalizationAlertDialogConfirmText, @"Confirm")
                                                                style:UIAlertActionStyleDestructive
                                                              handler:^(UIAlertAction * _Nonnull action) {
                                                                  __strong typeof(self) strongSelf = weakSelf;
                                                                  
                                                                  [strongSelf.settingsTableView reloadData];
                                                                  [ASDKDiskServices deleteLocalData];
                                                              }];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(kLocalizationAlertDialogCancelButtonText, @"Cancel")
                                                               style:UIAlertActionStyleCancel
                                                             handler:nil];
        [cleanCacheAlertController addAction:confirmAction];
        [cleanCacheAlertController addAction:cancelAction];
        
        [self presentViewController:cleanCacheAlertController
                           animated:YES
                         completion:nil];
    }
}


#pragma mark-
#pragma mark AFASettingsSwitchTableViewCellDelegate

- (void)didUpdateSwitchStateTo:(BOOL)isOn {
    [Buglife sharedBuglife].invocationOptions = isOn ? LIFEInvocationOptionsFloatingButton : LIFEInvocationOptionsShake;
}


#pragma mark -
#pragma mark Tableview Delegate & Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSUInteger sectionCount = 0;
    if (REPORT_TOOL) {
        sectionCount = AFASettingsControllerSectionTypeEnumCount;
    } else {
        sectionCount = AFASettingsControllerSectionTypeEnumCount-1;
    }
    
    return sectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    NSInteger rowCount = 0;
    
    switch (section) {
        case AAFASettingsControllerSectionTypeStorage: {
            rowCount = AFASettingsControllerStorageTypeEnumCount;
        }
            break;
            
        case AFASettingsControllerSectionTypeCleanCache:{
            rowCount = 1;
        }
            break;
            
        case AFASettingsControllerSectionTypeReportTool: {
            rowCount = 1;
        }
            break;
            
        default: break;
    }
    
    return rowCount;
}

- (UIView *)tableView:(UITableView *)tableView
viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = nil;
    
    if (AAFASettingsControllerSectionTypeStorage == section ||
        AFASettingsControllerSectionTypeReportTool == section) {
        AFAProfileSectionTableViewCell *sectionHeaderCell = [tableView dequeueReusableCellWithIdentifier:kCellIDProfileSectionTitle];
        if (AAFASettingsControllerSectionTypeStorage == section) {
            sectionHeaderCell.sectionIconImageView.image = [UIImage imageNamed:@"storage-icon"];
            sectionHeaderCell.sectionTitleLabel.text = NSLocalizedString(kLocalizationProfileScreenDiskUsageText, @"Disk usage text");
        } else if (AFASettingsControllerSectionTypeReportTool == section) {
            sectionHeaderCell.sectionIconImageView.image = [UIImage imageNamed:@"bug-icon"];
            sectionHeaderCell.sectionTitleLabel.text = NSLocalizedString(kLocalizationSettingsScreenBugReportingText, @"Bug reporting text");
        }
        
        sectionHeaderCell.sectionIconImageView.tintColor = [UIColor darkGreyTextColor];
        headerView = sectionHeaderCell;
    }
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView
heightForHeaderInSection:(NSInteger)section {
    CGFloat headerHeight = .0f;
    if (AAFASettingsControllerSectionTypeStorage  == section ||
        AFASettingsControllerSectionTypeReportTool == section) {
        headerHeight = kSettingsControllerSectionHeight;
    }
    
    return headerHeight;
}

- (CGFloat)tableView:(UITableView *)tableView
heightForFooterInSection:(NSInteger)section {
    return 1.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    
    switch (indexPath.section) {
        case AFASettingsControllerSectionTypeCleanCache: {
            AFAProfileActionTableViewCell *cleanCacheCell = [tableView dequeueReusableCellWithIdentifier:kCellIDProfileAction
                                                                                            forIndexPath:indexPath];
            cleanCacheCell.delegate = self;
            [cleanCacheCell.actionButton setTitle:NSLocalizedString(kLocalizationProfileScreenCleanCacheButtonText, @"Clean cache button")
                                         forState:UIControlStateNormal];
            
            cell = cleanCacheCell;
        }
            break;
            
        case AAFASettingsControllerSectionTypeStorage: {
            AFASettingsUsageTableViewCell *settingsUsageCell = [tableView dequeueReusableCellWithIdentifier:kCellIDSettingsUsage
                                                                                               forIndexPath:indexPath];
            if (AFASettingsControllerStorageTypeActivitiData == indexPath.row) {
                settingsUsageCell.descriptionLabel.text = NSLocalizedString(kLocalizationProfileScreenDiskUsageAvailableText, @"Disk usage text");
                settingsUsageCell.usageLabel.text = [ASDKDiskServices remainingDiskSpaceOnThisDevice];
            } else {
                settingsUsageCell.descriptionLabel.text = NSLocalizedString(kLocalizationProfileScreenActivitiDataText, @"Activiti data text");
                settingsUsageCell.usageLabel.text = [ASDKDiskServices usedDiskSpaceForDownloads];
            }
            
            cell = settingsUsageCell;
        }
            break;
            
        case AFASettingsControllerSectionTypeReportTool: {
            AFASettingsSwitchTableViewCell *settingsSwitchCell = [tableView dequeueReusableCellWithIdentifier:kCellIDSettingsSwitch
                                                                                                 forIndexPath:indexPath];
            settingsSwitchCell.descriptionLabel.text = NSLocalizedString(kLocalizationProfileScreenReportToolText, @"Report tool text");
            settingsSwitchCell.switchControl.isOn = ([Buglife sharedBuglife].invocationOptions == LIFEInvocationOptionsFloatingButton) ? YES : NO;
            settingsSwitchCell.delegate = self;
            
            cell = settingsSwitchCell;
        }
            break;
            
        default:
            break;
    }
    
    return cell;
}

@end

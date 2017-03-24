/*******************************************************************************
 * Copyright (C) 2005-2017 Alfresco Software Limited.
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

#import "AFAProfileViewControllerDataSource.h"

// Constants
#import "AFALocalizationConstants.h"
#import "AFAUIConstants.h"

// Categories
#import "UIColor+AFATheme.h"

// Cells
#import "AFAProfileDetailTableViewCell.h"
#import "AFAProfileSimpleTableViewCell.h"
#import "AFAProfileActionTableViewCell.h"

@interface AFAProfileViewControllerDataSource () <AFAProfileDetailTableViewCellDelegate,
AFAProfileActionTableViewCellDelegate>

@property (weak, nonatomic) UITableView *profileTableView;

@end

@implementation AFAProfileViewControllerDataSource

- (instancetype)initWithProfile:(ASDKModelProfile *)profile {
    self = [super init];
    
    if (self) {
        _currentProfile = profile;
    }
    
    return self;
}


#pragma mark -
#pragma mark AFAProfileDetailTableViewCellDelegate

- (void)updatedModelPropertyWithValue:(NSString *)value
                              forCell:(UITableViewCell *)cell {
    // Check which property of the profile is affected by this cell
    NSIndexPath *indexPath = [self.profileTableView indexPathForCell:cell];
    BOOL isProfileUpdated = NO;
    
    // Deep copy the profile object so that it remains untouched by future mutations
    NSData *buffer = [NSKeyedArchiver archivedDataWithRootObject: self.currentProfile];
    ASDKModelProfile *profileCopy = [NSKeyedUnarchiver unarchiveObjectWithData: buffer];
    
    if (AFAProfileControllerSectionTypeContactInformation == indexPath.section) {
        switch (indexPath.row) {
            case AFAProfileControllerContactInformationTypeEmail: {
                if (![profileCopy.email isEqualToString:value]) {
                    isProfileUpdated = YES;
                    profileCopy.email = value;
                }
            }
                break;
                
            case AFAProfileControllerContactInformationTypeCompany: {
                if (![profileCopy.companyName isEqualToString:value]) {
                    isProfileUpdated = YES;
                    profileCopy.companyName = value;
                }
            }
                break;
                
            default:
                break;
        }
    }
    
    if (isProfileUpdated) {
        if ([self.delegate respondsToSelector:@selector(updateInformationForProfile:)]) {
            [self.delegate updateInformationForProfile:profileCopy];
        }
    }
}


#pragma mark -
#pragma mark AFAProfileActionTableViewCellDelegate

- (void)profileActionChosenForCell:(UITableViewCell *)cell {
    NSIndexPath *indexPath = [self.profileTableView indexPathForCell:cell];
    
    if (AFAProfileControllerSectionTypeChangePassord == indexPath.section) {
        UIAlertController *changePasswordAlertController = [UIAlertController
                                                            alertControllerWithTitle:NSLocalizedString(kLocalizationProfileScreenPasswordButtonText, @"Change password")
                                                            message:nil
                                                            preferredStyle:UIAlertControllerStyleAlert];
        [changePasswordAlertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.placeholder = NSLocalizedString(kLocalizationProfileScreenOriginalPasswordText, @"Original password");
            textField.secureTextEntry = YES;
        }];
        [changePasswordAlertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.placeholder = NSLocalizedString(kLocalizationProfileScreenNewPasswordText, @"New password");
            textField.secureTextEntry = YES;
        }];
        [changePasswordAlertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.placeholder = NSLocalizedString(kLocalizationProfileScreenRepeatPasswordText, @"Repeat password");
            textField.secureTextEntry = YES;
        }];
        
        __weak typeof(self) weakSelf = self;
        UIAlertAction *confirmAction =
        [UIAlertAction actionWithTitle:NSLocalizedString(kLocalizationAlertDialogConfirmText, @"Confirm")
                                 style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * _Nonnull action) {
                                   __strong typeof(self) strongSelf = weakSelf;
                                   
                                   UITextField *oldPasswordField = changePasswordAlertController.textFields.firstObject;
                                   UITextField *newPasswordField = changePasswordAlertController.textFields[1];
                                   UITextField *confirmPasswordField = changePasswordAlertController.textFields.lastObject;
                                   
                                   if (oldPasswordField.text.length &&
                                       newPasswordField.text.length &&
                                       [newPasswordField.text isEqualToString:confirmPasswordField.text]) {
                                       if ([strongSelf.delegate respondsToSelector:@selector(updateProfilePasswordWithNewPassword:oldPassword:)]) {
                                           [strongSelf.delegate updateProfilePasswordWithNewPassword:newPasswordField.text
                                                                                         oldPassword:oldPasswordField.text];
                                       }
                                   } else {
                                       if ([strongSelf.delegate respondsToSelector:@selector(handleNetworkErrorWithMessage:)]) {
                                           [strongSelf.delegate handleNetworkErrorWithMessage:NSLocalizedString(kLocalizationProfileScreenPasswordMismatchText, @"Password missmatch")];
                                       }
                                   }
                               }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(kLocalizationAlertDialogCancelButtonText, @"Cancel")
                                                               style:UIAlertActionStyleCancel
                                                             handler:nil];
        
        [changePasswordAlertController addAction:cancelAction];
        [changePasswordAlertController addAction:confirmAction];
        
        if ([self.delegate respondsToSelector:@selector(presentAlertController:)]) {
            [self.delegate presentAlertController:changePasswordAlertController];
        }
    }
}


#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return REPORT_TOOL ? AFAProfileControllerSectionTypeEnumCount : AFAProfileControllerSectionTypeEnumCount-1 ;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    NSInteger rowCount = 0;
    
    switch (section) {
        case AFAProfileControllerSectionTypeContactInformation: {
            rowCount = AFAProfileControllerContactInformationTypeEnumCount;
        }
            break;
            
        case AFAProfileControllerSectionTypeGroups: {
            rowCount = self.currentProfile.groups.count;
        }
            break;
            
        case AFAProfileControllerSectionTypeChangePassord: {
            rowCount = 1;
        }
            break;
            
        default: break;
    }
    
    return rowCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!self.profileTableView) {
        self.profileTableView = tableView;
    }
    
    UITableViewCell *cell = nil;
    
    switch (indexPath.section) {
        case AFAProfileControllerSectionTypeContactInformation: {
            AFAProfileDetailTableViewCell *contactInformationCell = [tableView dequeueReusableCellWithIdentifier:kCellIDProfileCategory
                                                                                                    forIndexPath:indexPath];
            contactInformationCell.delegate = self;
            if (AFAProfileControllerContactInformationTypeEmail == indexPath.row) {
                contactInformationCell.categoryTitleLabel.text =  NSLocalizedString(kLocalizationProfileScreenEmailText, @"Email text");
                contactInformationCell.categoryDescriptionTextField.text = self.currentProfile.email;
            } else {
                contactInformationCell.categoryTitleLabel.text = NSLocalizedString(kLocalizationProfileScreenCompanyText, @"Company text");
                contactInformationCell.categoryDescriptionTextField.text = self.currentProfile.companyName;
            }
            
            cell = contactInformationCell;
        }
            break;
            
        case AFAProfileControllerSectionTypeGroups: {
            AFAProfileSimpleTableViewCell *groupCell = [tableView dequeueReusableCellWithIdentifier:kCellIDProfileOption
                                                                                       forIndexPath:indexPath];
            groupCell.titleLabel.text = ((ASDKModelGroup *)self.currentProfile.groups[indexPath.row]).name;
            cell = groupCell;
        }
            break;
            
        case AFAProfileControllerSectionTypeChangePassord: {
            AFAProfileActionTableViewCell *changePasswordCell = [tableView dequeueReusableCellWithIdentifier:kCellIDProfileAction
                                                                                                forIndexPath:indexPath];
            changePasswordCell.delegate = self;
            [changePasswordCell.actionButton setTitle:NSLocalizedString(kLocalizationProfileScreenPasswordButtonText, @"Change password button")
                                             forState:UIControlStateNormal];
            
            cell = changePasswordCell;
        }
            break;
            
        default:
            break;
    }
    
    return cell;
}


@end

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

#import "AFALoginCredentialsViewController.h"

// Constants
#import "AFAUIConstants.h"
#import "AFABusinessConstants.h"
#import "AFALocalizationConstants.h"

// Categories
#import "UIViewController+AFAAlertAddition.h"

// Components
#import "AFAFadingTableView.h"

// Cells
#import "AFACredentialSectionTableViewCell.h"

@interface AFALoginCredentialsViewController () <AFALoginCredentialsViewControllerDataSourceDelegate,
UITableViewDelegate>

@property (weak, nonatomic)   IBOutlet AFAFadingTableView   *credentialsTableView;
@property (assign, nonatomic) NSUInteger                    fieldTagIdx;

@end

@implementation AFALoginCredentialsViewController


#pragma mark -
#pragma mark View lifecycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.credentialsTableView setContentOffset:CGPointZero
                                       animated:NO];
    [self.credentialsTableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    _dataSource.delegate = self;
    self.credentialsTableView.dataSource = self.dataSource;
    self.credentialsTableView.delegate = self;
    
    // Adjust the table content inset to avoid a positioning inconsistency
    // when presenting the controller in a page controller with an animation
    CGFloat edgeInset = self.credentialsTableView.frame.origin.y;
    if (edgeInset) {
        self.credentialsTableView.contentInset = UIEdgeInsetsMake(edgeInset, 0, 0, 0);
    }
    
    // Unlock if previously unlocked as a result from poping the controller
    [self lockInterface:NO];
}


#pragma mark -
#pragma mark Actions

- (IBAction)onDismissTap:(UITapGestureRecognizer *)sender {
    [self.view endEditing:YES];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
       shouldReceiveTouch:(UITouch *)touch {
    return ![touch.view isKindOfClass:[UIButton class]];
}


#pragma mark -
#pragma mark AFALoginCredentialsViewControllerDataSourceDelegate

- (void)lockInterface:(BOOL)lockInterface {
    if (lockInterface) {
        [self.view endEditing:YES];
    }
    self.view.userInteractionEnabled = !lockInterface;
}

- (void)jumpFromTextField:(UITextField *)fromTextField
   toNextTextFieldWithTag:(NSUInteger)tag {
    UIResponder *nextResponder = [self.view viewWithTag:tag];
    
    if ([nextResponder isKindOfClass:[UITextField class]]) {
        [nextResponder becomeFirstResponder];
    } else {
        [fromTextField resignFirstResponder];
    }
}

- (void)handleNetworkErrorWithMessage:(NSString *)errorMessage {
    [self showGenericNetworkErrorAlertControllerWithMessage:errorMessage];
}

- (BOOL)isNetworkReachable {
    return (self.networkReachabilityStatus == ASDKNetworkReachabilityStatusReachableViaWWANOrWifi) ? YES : NO;
}


#pragma mark -
#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView
heightForHeaderInSection:(NSInteger)section {
    CGFloat sectionHeight = 0;
    if (AFALoginAuthenticationTypePremise == self.dataSource.loginModel.authentificationType) {
        if (AFAPremiseLoginSectionTypeAdvanced == section) {
            sectionHeight = 60.0f;
        }
    }
    
    return sectionHeight;
}

- (UIView *)tableView:(UITableView *)tableView
viewForHeaderInSection:(NSInteger)section {
    AFACredentialSectionTableViewCell *sectionHeaderViewCell = [tableView dequeueReusableCellWithIdentifier:kCellIDLoginSection];
    sectionHeaderViewCell.sectionTitleLabel.text = [NSLocalizedString(kLocalizationLoginAdvancedSectionHeaderText, @"Advanced section text") uppercaseString];
    return sectionHeaderViewCell;
}

@end

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

#import "ASDKPeopleFormFieldPeoplePickerViewController.h"

// Categories
#import "UIFont+ASDKGlyphicons.h"
#import "NSString+ASDKFontGlyphicons.h"
#import "NSString+ASDKEmailValidation.h"
#import "UIView+ASDKViewAnimations.h"
#import "UIViewController+ASDKAlertAddition.h"

// Views
#import "ASDKActivityView.h"
#import <JGProgressHUD/JGProgressHUD.h>

// Constants
#import "ASDKFormRenderEngineConstants.h"
#import "ASDKLocalizationConstants.h"

// Services
#import "ASDKUserDataAccessor.h"

// Models
#import "ASDKUserFilterModel.h"
#import "ASDKUserRequestRepresentation.h"
#import "ASDKModelUser.h"
#import "ASDKModelFormField.h"
#import "ASDKDataAccessorResponseCollection.h"

// Cells
#import "ASDKPeopleTableViewCell.h"


#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

typedef NS_ENUM(NSInteger, ASDKPeoplePickerControllerState) {
    AFAPeoplePickerControllerStateIdle,
    AFAPeoplePickerControllerStateInProgress,
};


@interface ASDKPeopleFormFieldPeoplePickerViewController () <ASDKDataAccessorDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem            *backBarButtonItem;
@property (weak, nonatomic) IBOutlet UIView                     *searchOverlayView;
@property (weak, nonatomic) IBOutlet UITableView                *contributorsTableView;
@property (weak, nonatomic) IBOutlet UILabel                    *noRecordsLabel;
@property (weak, nonatomic) IBOutlet ASDKActivityView           *loadingActivityView;
@property (weak, nonatomic) IBOutlet UITextField                *peopleSearchField;
@property (strong, nonatomic) JGProgressHUD                     *progressHUD;

// Internal state
@property (assign, nonatomic) BOOL                              isSearchInProgress;
@property (strong, nonatomic) NSArray                           *usersArr;
@property (strong, nonatomic) ASDKModelUser                     *selectedUser;
@property (assign, nonatomic) ASDKPeoplePickerControllerState   controllerState;

// Services
@property (strong, nonatomic) ASDKUserDataAccessor              *fetchUsersDataAccessor;

@end


@implementation ASDKPeopleFormFieldPeoplePickerViewController

#pragma mark -
#pragma mark Life cycle

-(instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        self.controllerState = AFAPeoplePickerControllerStateIdle;
        self.progressHUD = [self configureProgressHUD];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.backBarButtonItem setTitleTextAttributes:@{NSFontAttributeName           : [UIFont glyphiconFontWithSize:15],
                                                     NSForegroundColorAttributeName: [UIColor whiteColor]}
                                          forState:UIControlStateNormal];
    self.backBarButtonItem.title = [NSString iconStringForIconType:ASDKGlyphIconTypeChevronLeft];
    
    // pre select user
    self.selectedUser = self.currentFormField.values.firstObject;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.peopleSearchField becomeFirstResponder];
}


#pragma mark -
#pragma mark ASDKFormFieldDetailsControllerProtocol

- (void)setupWithFormFieldModel:(ASDKModelFormField *)formFieldModel {
    self.currentFormField = formFieldModel;
}

#pragma mark -
#pragma mark Actions

- (IBAction)onBack:(id)sender {
    [self performSegueWithIdentifier:kSegueIDFormFieldPeopleAddPeopleUnwind
                              sender:sender];
}

- (IBAction)onSearchOverlay:(id)sender {
    [self toggleContentTransparentOverlay];
}

#pragma mark -
#pragma mark UITextField Delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [self toggleContentTransparentOverlay];
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField.text.length) {
        [self fetchUserListForSearchText:textField.text];
    }
    [self toggleContentTransparentOverlay];
    
    return YES;
}


#pragma mark -
#pragma mark Animations

- (void)toggleContentTransparentOverlay {
    self.isSearchInProgress = !self.isSearchInProgress;
    
    CGFloat overlayAlphaValue = self.isSearchInProgress ? .5f : self.searchOverlayView.alpha ? .0f : .5f;
    
    [self.searchOverlayView animateAlpha:overlayAlphaValue
                            withDuration:kOverlayAlphaChangeTime
                     withCompletionBlock:^(BOOL didFinished) {
                         if (!self.isSearchInProgress) {
                             [self.view endEditing:YES];
                         }
                     }];
}

#pragma mark -
#pragma mark Service integration

- (void)fetchUserListForSearchText:(NSString *)searchText {
    self.controllerState = AFAPeoplePickerControllerStateInProgress;
    
    ASDKUserFilterModel *userFilterModel = [ASDKUserFilterModel new];
    searchText = [searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([searchText isValidEmailAddress]) {
        userFilterModel.email = searchText;
    } else {
        userFilterModel.name = searchText;
    }
    
    ASDKUserRequestRepresentation *userRequestRepresentation = [ASDKUserRequestRepresentation new];
    userRequestRepresentation.filter = userFilterModel.name;
    userRequestRepresentation.email = userFilterModel.email;
    userRequestRepresentation.jsonAdapterType = ASDKModelJSONAdapterTypeExcludeNilValues;
    
    self.fetchUsersDataAccessor = [[ASDKUserDataAccessor alloc] initWithDelegate:self];
    [self.fetchUsersDataAccessor fetchUsersWithUserFilter:userRequestRepresentation];
}

- (void)addUserToCurrentFormField:(ASDKModelUser *)user {
    NSMutableArray *currentUser = [NSMutableArray arrayWithObject:user];
    self.currentFormField.values = [NSArray arrayWithArray:currentUser];
}

- (void)removeUserFromCurrentFormField {
    self.currentFormField.values = [[NSArray alloc] init];
}

#pragma mark -
#pragma mark Progress hud setup

- (JGProgressHUD *)configureProgressHUD {
    JGProgressHUD *hud = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
    hud.interactionType = JGProgressHUDInteractionTypeBlockAllTouches;
    JGProgressHUDFadeZoomAnimation *zoomAnimation = [JGProgressHUDFadeZoomAnimation animation];
    hud.animation = zoomAnimation;
    hud.indicatorView = [[JGProgressHUDIndeterminateIndicatorView alloc] init];
    
    return hud;
}

- (void)showUserInvolvementIndicatorView {
    self.progressHUD.textLabel.text = nil;
    JGProgressHUDIndeterminateIndicatorView *indicatorView = [[JGProgressHUDIndeterminateIndicatorView alloc] init];
    [indicatorView setColor:[UIColor whiteColor]];
    self.progressHUD.indicatorView = indicatorView;
    [self.progressHUD showInView:self.navigationController.view];
}


#pragma mark -
#pragma mark ASDKDataAccessorDelegate

- (void)dataAccessor:(id<ASDKServiceDataAccessorProtocol>)dataAccessor
 didLoadDataResponse:(ASDKDataAccessorResponseBase *)response {
    if (self.fetchUsersDataAccessor == dataAccessor) {
        [self handleUserDataAccessorResponse:response];
    }
}


#pragma mark -
#pragma mark Content handlers

- (void)handleUserDataAccessorResponse:(ASDKDataAccessorResponseBase *)response {
    ASDKDataAccessorResponseCollection *userListResponse = (ASDKDataAccessorResponseCollection *)response;
    NSArray *userList = userListResponse.collection;
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(self) strongSelf = weakSelf;
        
        if (userListResponse.error) {
            strongSelf.noRecordsLabel.hidden = NO;
            strongSelf.contributorsTableView.hidden = YES;
            
            [strongSelf showGenericNetworkErrorAlertControllerWithMessage:ASDKLocalizedStringFromTable(kLocalizationFormAlertDialogGenericNetworkErrorText, ASDKLocalizationTable, @"Generic network error")];
        } else {
            strongSelf.usersArr = userList;
            
            // Check if we got an empty list
            strongSelf.noRecordsLabel.hidden = userList.count ? YES : NO;
            strongSelf.contributorsTableView.hidden = userList.count ? NO : YES;
            
            // Reload table data
            [strongSelf.contributorsTableView reloadData];
        }
    });
}

- (void)dataAccessorDidFinishedLoadingDataResponse:(id<ASDKServiceDataAccessorProtocol>)dataAccessor {
}


#pragma mark -
#pragma mark Tableview Delegate & Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    return self.usersArr.count;
}

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ASDKPeopleTableViewCell *peopleCell = [tableView dequeueReusableCellWithIdentifier:kASDKCellIDFormFieldPeopleAddPeople];
    ASDKModelUser *selectedUser = self.usersArr[indexPath.row];
    [peopleCell setUpCellWithUser:selectedUser];
    
    if (self.selectedUser.modelID == selectedUser.modelID) {
        peopleCell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        peopleCell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return peopleCell;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ASDKModelUser *selectedUser = self.usersArr[indexPath.row];
    
    if (self.selectedUser.modelID == selectedUser.modelID) {
        self.selectedUser = nil;
        [self removeUserFromCurrentFormField];
    } else {
        self.selectedUser = selectedUser;
        [self addUserToCurrentFormField:selectedUser];
    }
    
    // Notify the value transaction delegate there has been a change with the provided form field model
    if ([self.valueTransactionDelegate respondsToSelector:@selector(updatedMetadataValueForFormField:inCell:)]) {
        [self.valueTransactionDelegate updatedMetadataValueForFormField:self.currentFormField
                                                                 inCell:nil];
    }
    
    [self performSegueWithIdentifier:kSegueIDFormFieldPeopleAddPeopleUnwind sender:self];

}

@end

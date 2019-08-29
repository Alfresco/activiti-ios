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

#import "AFAPeoplePickerViewController.h"
@import ActivitiSDK;

// Categories
#import "UIFont+ASDKGlyphicons.h"
#import "NSString+ASDKFontGlyphicons.h"
#import "UIView+AFAViewAnimations.h"
#import "UIViewController+AFAAlertAddition.h"

// Constants
#import "AFAUIConstants.h"
#import "AFALocalizationConstants.h"

// Models
#import "AFAUserFilterModel.h"

// Managers
#import "AFAServiceRepository.h"
#import "AFAUserServices.h"
#import "AFATaskServices.h"

// Views
#import "AFAActivityView.h"
#import <JGProgressHUD/JGProgressHUD.h>

// Cells
#import "AFAContributorTableViewCell.h"

typedef NS_ENUM(NSInteger, AFAPeoplePickerControllerState) {
    AFAPeoplePickerControllerStateIdle,
    AFAPeoplePickerControllerStateInProgress,
    AFAPeoplePickerControllerStateEmptyList
};


@interface AFAPeoplePickerViewController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem            *backBarButtonItem;
@property (weak, nonatomic) IBOutlet UIView                     *searchOverlayView;
@property (weak, nonatomic) IBOutlet UITableView                *contributorsTableView;
@property (weak, nonatomic) IBOutlet UILabel                    *noRecordsLabel;
@property (weak, nonatomic) IBOutlet AFAActivityView            *loadingActivityView;
@property (weak, nonatomic) IBOutlet UITextField                *peopleSearchField;
@property (strong, nonatomic) JGProgressHUD                     *progressHUD;

// Internal state properties
@property (assign, nonatomic) BOOL                              isSearchInProgress;
@property (strong, nonatomic) NSArray                           *contributorsArr;
@property (strong, nonatomic) NSMutableDictionary               *selectedContributors;
@property (assign, nonatomic) AFAPeoplePickerControllerState    controllerState;

// Task services
@property (strong, nonatomic) AFATaskServices                   *involveUserService;
@property (strong, nonatomic) AFATaskServices                   *removeUserService;
@property (strong, nonatomic) AFATaskServices                   *assignTaskService;

// User services
@property (strong, nonatomic) AFAUserServices                   *fetchUsersService;


// KVO
@property (strong, nonatomic) ASDKKVOManager                     *kvoManager;

@end

@implementation AFAPeoplePickerViewController

#pragma mark -
#pragma mark Life cycle

-(instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        _controllerState = AFAPeoplePickerControllerStateIdle;
        _selectedContributors = [NSMutableDictionary dictionary];
        _progressHUD = [self configureProgressHUD];
        
        _involveUserService = [AFATaskServices new];
        _assignTaskService = [AFATaskServices new];
        _removeUserService = [AFATaskServices new];
        
        _fetchUsersService = [AFAUserServices new];
        
        // Set up state bindings
        [self handleBindingsForPeoplePickerViewController];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.backBarButtonItem setTitleTextAttributes:@{NSFontAttributeName           : [UIFont glyphiconFontWithSize:15],
                                                     NSForegroundColorAttributeName: [UIColor whiteColor]}
                                          forState:UIControlStateNormal];
    self.backBarButtonItem.title = [NSString iconStringForIconType:ASDKGlyphIconTypeChevronLeft];
    self.navigationBarTitle = NSLocalizedString(kLocalizationPeoplePickerControllerTitleText, @"People picker screen title");
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.peopleSearchField becomeFirstResponder];
}


#pragma mark -
#pragma mark Actions

- (IBAction)onBack:(id)sender {
    [self performSegueWithIdentifier:kSegueIDTaskDetailsAddContributorUnwind
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
    
    AFAUserFilterModel *userFilterModel = [AFAUserFilterModel new];
    searchText = [searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    // First check if we're dealing with a search by email
    if ([searchText isValidEmailAddress]) {
        userFilterModel.email = searchText;
    } else {
        userFilterModel.name = searchText;
    }
    
    // If the controller is a people involve type controller include the
    // parameter to exclude already involved users, otherwise list all options
    if (AFAPeoplePickerControllerTypeInvolve == self.peoplePickerType) {
        userFilterModel.excludeTaskID = self.taskID;
    }
    
    __weak typeof(self) weakSelf = self;
    [self.fetchUsersService requestUsersWithUserFilter:userFilterModel
                                       completionBlock:^(NSArray *users, NSError *error, ASDKModelPaging *paging) {
                                           __strong typeof(self) strongSelf = weakSelf;
                                           
                                           BOOL isContentAvailable = users.count ? YES : NO;
                                           strongSelf.controllerState = isContentAvailable ? AFAPeoplePickerControllerStateIdle : AFAPeoplePickerControllerStateEmptyList;
                                           
                                           if (!error) {
                                               strongSelf.contributorsArr = users;
                                               
                                               // Reload table data
                                               [strongSelf.contributorsTableView reloadData];
                                           } else {
                                               [strongSelf showGenericNetworkErrorAlertControllerWithMessage:NSLocalizedString(kLocalizationAlertDialogGenericNetworkErrorText, @"Generic network error")];
                                           }
                                       }];
}

- (void)involveUserForCurrentTask:(ASDKModelUser *)user {
    
    NSString *userFullName = [user normalisedName];
    
    [self showUserInvolvementIndicatorView];
    
    __weak typeof(self) weakSelf = self;
    [self.involveUserService requestTaskUserInvolvement:user
                                              forTaskID:self.taskID
                                        completionBlock:^(BOOL isUserInvolved, NSError *error) {
                                            __strong typeof(self) strongSelf = weakSelf;
                                            if (!error && isUserInvolved) {
                                                strongSelf.progressHUD.textLabel.text = [NSString stringWithFormat:NSLocalizedString(kLocalizationPeoplePickerControllerInvolvingUserFormat, "User X is now involved text"), userFullName];
                                                strongSelf.progressHUD.detailTextLabel.text = nil;
                                                strongSelf.progressHUD.indicatorView = [[JGProgressHUDSuccessIndicatorView alloc] init];
                                                
                                                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                                    [weakSelf.progressHUD dismiss];
                                                });
                                            } else {
                                                [strongSelf.progressHUD dismiss];
                                                [strongSelf showGenericNetworkErrorAlertControllerWithMessage:NSLocalizedString(kLocalizationAlertDialogGenericNetworkErrorText, @"Generic network error")];
                                            }
                                        }];
}

- (void)assignUserForCurrentTask:(ASDKModelUser *)user {
    NSString *userFullName = [user normalisedName];
    
    [self showUserInvolvementIndicatorView];
    __weak typeof(self) weakSelf = self;
    [self.assignTaskService requestTaskAssignForTaskWithID:self.taskID
                                                    toUser:user
                                           completionBlock:^(ASDKModelTask *task, NSError *error) {
                                               __strong typeof(self) strongSelf = weakSelf;
                                               if (!error && task) {
                                                   strongSelf.progressHUD.textLabel.text = [NSString stringWithFormat:NSLocalizedString(kLocalizationPeoplePickerControllerAssigningUserFormat, "User X is now assigned text"), userFullName];
                                                   strongSelf.progressHUD.detailTextLabel.text = nil;
                                                   strongSelf.progressHUD.indicatorView = [[JGProgressHUDSuccessIndicatorView alloc] init];
                                                   
                                                   dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                                       [weakSelf.progressHUD dismiss];
                                                   });
                                               } else {
                                                   [strongSelf.progressHUD dismiss];
                                                   [strongSelf showGenericNetworkErrorAlertControllerWithMessage:NSLocalizedString(kLocalizationAlertDialogGenericNetworkErrorText, @"Generic network error")];
                                               }
                                           }];
}

- (void)removeInvolvedUserForCurrentTask:(ASDKModelUser *)user {
    NSString *userFullName = [user normalisedName];
    
    [self showUserInvolvementIndicatorView];
    
    __weak typeof(self) weakSelf = self;
    [self.removeUserService requestToRemoveTaskUserInvolvement:user
                                                     forTaskID:self.taskID
                                               completionBlock:^(BOOL isUserInvolved, NSError *error) {
                                                   __strong typeof(self) strongSelf = weakSelf;
                                                   if (!error && !isUserInvolved) {
                                                       strongSelf.progressHUD.textLabel.text = [NSString stringWithFormat:NSLocalizedString(kLocalizationPeoplePickerControllerRemovingUserFormat, "User X is no longer involved text"), userFullName];
                                                       strongSelf.progressHUD.detailTextLabel.text = nil;
                                                       strongSelf.progressHUD.indicatorView = [[JGProgressHUDSuccessIndicatorView alloc] init];
                                                       
                                                       dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                                           [weakSelf.progressHUD dismiss];
                                                       });
                                                   } else {
                                                       [strongSelf.progressHUD dismiss];
                                                       [strongSelf showGenericNetworkErrorAlertControllerWithMessage:NSLocalizedString(kLocalizationAlertDialogGenericNetworkErrorText, @"Generic network error")];
                                                   }
                                               }];
}


#pragma mark -
#pragma mark - Progress hud setup

- (JGProgressHUD *)configureProgressHUD {
    JGProgressHUD *hud = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
    hud.interactionType = JGProgressHUDInteractionTypeBlockAllTouches;
    JGProgressHUDFadeZoomAnimation *zoomAnimation = [JGProgressHUDFadeZoomAnimation animation];
    hud.animation = zoomAnimation;
    
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
#pragma mark Tableview Delegate & Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    return self.contributorsArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AFAContributorTableViewCell *contributorCell = [tableView dequeueReusableCellWithIdentifier:kCellIDTaskDetailsContributor];
    ASDKModelUser *selectedUser = self.contributorsArr[indexPath.row];
    [contributorCell setUpCellWithUser:selectedUser];
    
    if (self.selectedContributors[selectedUser.modelID]) {
        contributorCell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        contributorCell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return contributorCell;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ASDKModelUser *selectedUser = self.contributorsArr[indexPath.row];
    if (!self.selectedContributors[selectedUser.modelID]) {
        if (AFAPeoplePickerControllerTypeInvolve == self.peoplePickerType) {
            self.selectedContributors[selectedUser.modelID] = @(YES);
            [self involveUserForCurrentTask:selectedUser];
        } else {
            [self.selectedContributors removeAllObjects];
            self.selectedContributors[selectedUser.modelID] = @(YES);
            
            [self assignUserForCurrentTask:selectedUser];
        }
    } else {
        if (AFAPeoplePickerControllerTypeInvolve == self.peoplePickerType) {
            [self.selectedContributors removeObjectForKey:selectedUser.modelID];
            [self removeInvolvedUserForCurrentTask:selectedUser];
        }
    }
    
    [tableView reloadData];
}


#pragma mark -
#pragma mark KVO bindings

- (void)handleBindingsForPeoplePickerViewController {
    self.kvoManager = [ASDKKVOManager managerWithObserver:self];
    
    __weak typeof(self) weakSelf = self;
    [self.kvoManager observeObject:self
                        forKeyPath:NSStringFromSelector(@selector(controllerState))
                           options:NSKeyValueObservingOptionNew
                             block:^(id observer, id object, NSDictionary *change) {
                                 AFAPeoplePickerControllerState controllerState = [change[NSKeyValueChangeNewKey] integerValue];
                                 
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     if (AFAPeoplePickerControllerStateIdle == controllerState) {
                                         weakSelf.loadingActivityView.hidden = YES;
                                         weakSelf.loadingActivityView.animating = NO;
                                         weakSelf.contributorsTableView.hidden = NO;
                                         weakSelf.noRecordsLabel.hidden = YES;
                                     } else if (AFAPeoplePickerControllerStateInProgress == controllerState) {
                                         weakSelf.loadingActivityView.hidden = NO;
                                         weakSelf.loadingActivityView.animating = YES;
                                         weakSelf.contributorsTableView.hidden = YES;
                                         weakSelf.noRecordsLabel.hidden = YES;
                                     } else  if (AFAPeoplePickerControllerStateEmptyList == controllerState) {
                                         weakSelf.loadingActivityView.hidden = YES;
                                         weakSelf.loadingActivityView.animating = NO;
                                         weakSelf.contributorsTableView.hidden = YES;
                                         weakSelf.noRecordsLabel.hidden = NO;
                                     }
                                 });
                             }];
}

@end

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

// Constants
#import "AFAUIConstants.h"
#import "AFALocalizationConstants.h"

// Categories
#import "UIViewController+AFAAlertAddition.h"

// Models
#import "AFALoginViewModel.h"

// View models
#import "AFATaskListViewModel.h"
#import "AFAProcessListViewModel.h"

// Managers
#import "AFAServiceRepository.h"
#import "AFAThumbnailManager.h"
#import "AFAAppServices.h"
#import "AFAProcessServices.h"
#import "AFAFilterServices.h"
#import "AFAFormServices.h"
#import "AFAUserServices.h"
#import "AFAQueryServices.h"
#import "AFAIntegrationServices.h"
#import "AFAReachabilityStore.h"
@import ActivitiSDK;

// Controllers
#import "AFAContainerViewController.h"
#import "AFAApplicationListViewController.h"
#import "AFADrawerMenuViewController.h"
#import "AFAListViewController.h"
#import "AFAProfileViewController.h"
#import "AFASettingsViewController.h"


@interface AFAContainerViewController () <AFAContainerViewControllerDelegate>

// Constraints
@property (weak, nonatomic) IBOutlet NSLayoutConstraint     *detailsContainerViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint     *detailsContainerViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint     *detailsContainerViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint     *detailsContainerViewTopPaddedConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint     *detailsContainerViewHeightPaddedConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint     *detailsContainerViewPaddedLeadingConstraint;

// Views
@property (weak, nonatomic) IBOutlet UIView                 *detailsContainerView;
@property (weak, nonatomic) IBOutlet UIView                 *menuContainerView;

// State
@property (assign, nonatomic) BOOL                          isDrawerMenuOpen;

// Controllers
@property (strong, nonatomic) AFADrawerMenuViewController   *drawerMenuViewController;
@property (strong, nonatomic) UINavigationController        *detailsNavigationController;

@end

@implementation AFAContainerViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        AFAServiceRepository *serviceRepository = [AFAServiceRepository sharedRepository];
        
        // Register SDK integration services
        AFAFormServices *formService = [AFAFormServices new];
        [serviceRepository registerServiceObject:formService
                                      forPurpose:AFAServiceObjectTypeFormServices];
        
        AFAUserServices *userService = [AFAUserServices new];
        [serviceRepository registerServiceObject:userService
                                      forPurpose:AFAServiceObjectTypeUserServices];
        
        // Register the thumbnail manager with the service repository
        AFAThumbnailManager *thumbnailManager = [AFAThumbnailManager new];
        [serviceRepository registerServiceObject:thumbnailManager
                                      forPurpose:AFAServiceObjectTypeThumbnailManager];
        
        // Register the reachability store to get notified or querry for network outages
        AFAReachabilityStore *reachabilityStore = [AFAReachabilityStore new];
        [reachabilityStore requestInitialReachabilityStatus];
        [serviceRepository registerServiceObject:reachabilityStore
                                      forPurpose:AFAServiceObjectTypeReachabilityStore];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleUnAuthorizedRequestNotification)
                                                     name:kADSKAPIUnauthorizedRequestNotification
                                                   object:nil];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNeedsStatusBarAppearanceUpdate];
    
    // Only draw the menu view when the menu is toggled
    self.menuContainerView.hidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}


#pragma mark -
#pragma mark Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue
                 sender:(id)sender {
    if ([kSegueIDApplicationListEmbedding isEqualToString:segue.identifier]) {
        // Check if the application list is the root controller of a navigation controller
        if ([segue.destinationViewController isKindOfClass:[UINavigationController class]]) {
            self.detailsNavigationController = (UINavigationController *)segue.destinationViewController;
            
            AFAApplicationListViewController *applicationListViewController = ((UINavigationController *)segue.destinationViewController).viewControllers.firstObject;
            applicationListViewController.delegate = self;
        }
    }
    
    if ([kSegueIDDrawerMenuEmbedding isEqualToString:segue.identifier]) {
        self.drawerMenuViewController = (AFADrawerMenuViewController *)segue.destinationViewController;
        self.drawerMenuViewController.delegate = self;
    }
}


#pragma mark -
#pragma mark AFAContainerViewController Delegate

- (BOOL)isDrawerMenuOpen {
    return _isDrawerMenuOpen;
}

- (void)toggleDrawerMenu {
    [self.drawerMenuViewController refreshDrawerMenu];
    self.isDrawerMenuOpen = !self.isDrawerMenuOpen;
    self.isDrawerMenuOpen ? [self openQuickAccessDrawerMenu] : [self closeQuickAccessDrawerMenu];
}

- (void)showApplications {
    [self toggleDrawerMenu];
    
    AFAApplicationListViewController *applicationListViewController = [self.storyboard instantiateViewControllerWithIdentifier:kStoryboardIDApplicationListViewController];
    applicationListViewController.delegate = self;  
    
    [self.detailsNavigationController setViewControllers:@[applicationListViewController]
                                                animated:NO];
}

- (void)showAdhocTasks {
    [self toggleDrawerMenu];
    
    AFAListViewController *listViewController = [self.storyboard instantiateViewControllerWithIdentifier:kStoryboardIDListViewController];
    AFATaskListViewModel *taskListViewModel = [AFATaskListViewModel new];
    AFAProcessListViewModel *processListViewModel = [AFAProcessListViewModel new];
    listViewController.taskListViewModel = taskListViewModel;
    listViewController.processListViewModel = processListViewModel;
    listViewController.delegate = self;
    
    UIBarButtonItem *menuItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu-dots-icon"]
                                                                 style:UIBarButtonItemStylePlain
                                                                target:listViewController
                                                                action:@selector(toggleMenu:)];
    menuItem.tintColor = [UIColor whiteColor];
    listViewController.navigationItem.leftBarButtonItem = menuItem;
    
    [self.detailsNavigationController setViewControllers:@[listViewController]
                                                animated:NO];
}

- (void)logoutUser {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil
                                                                             message:NSLocalizedString(kLocalizationAlertDialogSignOutDescriptionText, @"Sign out title text")
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    __weak typeof(self) weakSelf = self;
    UIAlertAction *yesButtonAction = [UIAlertAction actionWithTitle:NSLocalizedString(kLocalizationAlertDialogYesButtonText, @"YES button title")
                                                              style:UIAlertActionStyleDefault
                                                            handler:^(UIAlertAction *action) {
                                                                __strong typeof(self) strongSelf = weakSelf;

                                                                [strongSelf requestUserLogout];
                                                            }];
    UIAlertAction *cancelButtonAction = [UIAlertAction actionWithTitle:NSLocalizedString(kLocalizationAlertDialogCancelButtonText, @"Cancel button title")
                                                                 style:UIAlertActionStyleDefault
                                                               handler:^(UIAlertAction *action) {
                                                                   [alertController dismissViewControllerAnimated:YES
                                                                                                       completion:nil];
                                                               }];
    [alertController addAction:yesButtonAction];
    [alertController addAction:cancelButtonAction];
    
    [self presentViewController:alertController
                       animated:YES
                     completion:nil];
}

- (void)showUserProfile {
    [self toggleDrawerMenu];
    
    AFAProfileViewController *profileViewController = [self.storyboard instantiateViewControllerWithIdentifier:kStoryboardIDProfileViewController];
    profileViewController.delegate = self;
    
    UIBarButtonItem *menuItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu-dots-icon"]
                                                                 style:UIBarButtonItemStylePlain
                                                                target:profileViewController
                                                                action:@selector(toggleMenu:)];
    menuItem.tintColor = [UIColor whiteColor];
    profileViewController.navigationItem.leftBarButtonItem = menuItem;
    
    [self.detailsNavigationController setViewControllers:@[profileViewController]
                                                animated:NO];
}

- (void)showSettings {
    [self toggleDrawerMenu];
    
    AFASettingsViewController *settingsViewController = [self.storyboard instantiateViewControllerWithIdentifier:kStoryboardIDSettingsViewController];
    settingsViewController.delegate = self;
    
    UIBarButtonItem *menuItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu-dots-icon"]
                                                                 style:UIBarButtonItemStylePlain
                                                                target:settingsViewController
                                                                action:@selector(toggleMenu:)];
    menuItem.tintColor = [UIColor whiteColor];
    settingsViewController.navigationItem.leftBarButtonItem = menuItem;
    
    [self.detailsNavigationController setViewControllers:@[settingsViewController]
                                                animated:NO];
}


#pragma mark -
#pragma mark Animations

- (void)openQuickAccessDrawerMenu {
    [self performDrawerAnimationInReverse:NO];
}

- (void)closeQuickAccessDrawerMenu {
    [self performDrawerAnimationInReverse:YES];
}

- (void)performDrawerAnimationInReverse:(BOOL)isReverseAnimation {
    // Before starting the animation make sure the menu is visible
    if (!isReverseAnimation) {
        self.menuContainerView.hidden = NO;
    }
    
    // Apply padding to the details container view
    if (isReverseAnimation) {
        self.detailsContainerViewTopPaddedConstraint.active = NO;
        self.detailsContainerViewPaddedLeadingConstraint.constant = .0f;
        self.detailsContainerViewTopConstraint.active = YES;
    } else {
        self.detailsContainerViewTopConstraint.active = NO;
        self.detailsContainerViewTopPaddedConstraint.active = YES;
        self.detailsContainerViewPaddedLeadingConstraint.constant = 200.0f;
    }
    
    self.detailsContainerViewLeadingConstraint.constant = isReverseAnimation ? 0 : CGRectGetWidth(self.menuContainerView.frame);
    
    self.detailsContainerView.layer.shadowColor = isReverseAnimation ? [UIColor clearColor].CGColor : [UIColor colorWithRed:.0f
                                                                                                                      green:.0f
                                                                                                                       blue:.0f
                                                                                                                      alpha:34].CGColor;
    self.detailsContainerView.layer.shadowOffset = isReverseAnimation ? CGSizeZero : CGSizeMake(-3,3);
    self.detailsContainerView.layer.shadowOpacity = isReverseAnimation ? .0f : .5f;
    self.detailsContainerView.layer.shadowRadius = isReverseAnimation ? .0f : 3.0f;
    
    [UIView animateWithDuration:kDefaultAnimationTime
                          delay:.0f
         usingSpringWithDamping:isReverseAnimation ? 1.0f : .7f
          initialSpringVelocity:10.0f
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         [self.view layoutIfNeeded];
                     }
                     completion:^(BOOL finished) {
                         // After the reverse animation finished there is no need to keep the menu container
                         // visible, hide it till the next toggle
                         if (isReverseAnimation) {
                             self.menuContainerView.hidden = YES;
                         }
                     }];
}


#pragma mark -
#pragma mark Private interface

- (void)handleUnAuthorizedRequestNotification {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil
                                                                             message:NSLocalizedString(kLocalizationLoginUnauthorizedRequestErrorText, @"Unauthorized request text")
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    __weak typeof(self) weakSelf = self;
    UIAlertAction *okButtonAction = [UIAlertAction actionWithTitle:NSLocalizedString(kLocalizationAlertDialogOkButtonText, @"OK button title")
                                                             style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction *action) {
                                                               __strong typeof(self) strongSelf = weakSelf;
                                                               [strongSelf requestUserUnauthorizedLogout];
                                                           }];
    [alertController addAction:okButtonAction];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:alertController
                           animated:YES
                         completion:nil];
    });
}

- (void)requestUserLogout {
    [self.loginViewModel requestLogout];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self performSegueWithIdentifier:kSegueIDLoginAuthorizedUnwind
                                  sender:nil];
    });
}

- (void)requestUserUnauthorizedLogout {
    [self.loginViewModel requestLogoutForUnauthorizedAccess];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self performSegueWithIdentifier:kSegueIDLoginAuthorizedUnwind
                                  sender:nil];
    });
}

@end

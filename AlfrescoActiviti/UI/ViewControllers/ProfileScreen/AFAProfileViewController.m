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

#import "AFAProfileViewController.h"

// Constants
#import "AFALocalizationConstants.h"
#import "AFAUIConstants.h"

// Categories
#import "NSDate+AFAStringTransformation.h"
#import "UIViewController+AFAAlertAddition.h"
#import "UIColor+AFATheme.h"

// Data source
#import "AFAContentPickerDataSource.h"
#import "AFAContentPickerProfileUploadBehavior.h"

// Views
#import "AFAAvatarView.h"
#import "AFAActivityView.h"
#import <JGProgressHUD/JGProgressHUD.h>

// Cells
#import "AFAProfileSectionTableViewCell.h"

// View controllers
#import "AFAContentPickerViewController.h"

// Managers
#import "AFAServiceRepository.h"
#import "AFAProfileServices.h"
#import "AFAThumbnailManager.h"
@import ActivitiSDK;

typedef NS_ENUM(NSInteger, AFAProfileControllerState) {
    AFAProfileControllerStateIdle,
    AFAProfileControllerStateRefreshInProgress,
    AFAProfileControllerStateCachedResults
};

static const CGFloat kProfileControllerSectionHeight = 40.0f;

@interface AFAProfileViewController () <AFAProfileViewControllerDataSourceDelegate,
AFAContentPickerViewControllerDelegate,
UITextFieldDelegate,
UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView                *profileTableView;
@property (weak, nonatomic) IBOutlet AFAAvatarView              *avatarView;
@property (weak, nonatomic) IBOutlet UILabel                    *registeredDateLabel;
@property (weak, nonatomic) IBOutlet AFAActivityView            *activityView;
@property (strong, nonatomic) UIRefreshControl                  *refreshControl;
@property (weak, nonatomic) IBOutlet UITextField                *firstNameTextField;
@property (weak, nonatomic) IBOutlet UITextField                *lastNameTextField;
@property (strong, nonatomic) JGProgressHUD                     *progressHUD;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint         *contentPickerContainerBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint         *contentPickerContainerHeightConstraint;
@property (strong, nonatomic) AFAContentPickerViewController    *contentPickerViewController;
@property (weak, nonatomic) IBOutlet UIView                     *contentPickerContainer;
@property (weak, nonatomic) IBOutlet UIView                     *fullScreenOverlayView;
@property (weak, nonatomic) IBOutlet UILabel                    *noInformationAvailableLabel;
@property (weak, nonatomic) IBOutlet UIView                     *refreshView;
@property (weak, nonatomic) IBOutlet UIButton                   *refreshButton;
@property (weak, nonatomic) IBOutlet ASDKRoundedBorderView      *profilePictureAddButtonView;

// Internal state properties
@property (assign, nonatomic) AFAProfileControllerState         controllerState;
@property (strong, nonatomic) UIImage                           *profileImage;
@property (assign, nonatomic) CGFloat                           initialContentPickerContainerHeight;

// Services
@property (strong, nonatomic) AFAProfileServices                *requestProfileService;
@property (strong, nonatomic) AFAProfileServices                *profileImageService;
@property (strong, nonatomic) AFAProfileServices                *profileUpdateService;
@property (strong, nonatomic) AFAProfileServices                *profilePasswordUpdateService;
@property (strong, nonatomic) ASDKKVOManager                    *kvoManager;

@end

@implementation AFAProfileViewController


#pragma mark -
#pragma mark Life cycle

-(instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        _controllerState = AFAProfileControllerStateIdle;
        _progressHUD = [self configureProgressHUD];
        _requestProfileService = [AFAProfileServices new];
        _profileImageService = [AFAProfileServices new];
        _profileUpdateService = [AFAProfileServices new];
        _profilePasswordUpdateService = [AFAProfileServices new];
        
        // Set up state bindings
        [self handleBindingsForAppListViewController];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Update navigation bar title
    self.navigationBarTitle = NSLocalizedString(kLocalizationProfileScreenTitleText, @"Application title");
    
    // Set up the refresh control
    UITableViewController *tableViewController = [[UITableViewController alloc] init];
    [self addChildViewController:tableViewController];
    tableViewController.tableView = self.profileTableView;
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self
                            action:@selector(onRefresh:)
                  forControlEvents:UIControlEventValueChanged];
    tableViewController.refreshControl = self.refreshControl;
    
    self.refreshButton.titleLabel.font = [UIFont glyphiconFontWithSize:15];
    [self.refreshButton setTitle:[NSString iconStringForIconType:ASDKGlyphIconTypeRefresh]
                        forState:UIControlStateNormal];
    self.noInformationAvailableLabel.text = NSLocalizedString(kLocalizationProfileScreenNoInformationAvailableText, @"No information available");
    
    // Set up the task list table view to adjust it's size automatically
    self.profileTableView.estimatedRowHeight = 40.0f;
    self.profileTableView.rowHeight = UITableViewAutomaticDimension;
    self.profileTableView.contentInset = UIEdgeInsetsMake(.0f, .0f, 20.0f, .0f);
    self.profileTableView.delegate = self;
    
    // Set name fields delegate
    self.firstNameTextField.delegate = self;
    self.lastNameTextField.delegate = self;
    
    // Set a provisory profile image placeholder
    AFAThumbnailManager *thumbnailManager = [[AFAServiceRepository sharedRepository] serviceObjectForPurpose:AFAServiceObjectTypeThumbnailManager];
    self.avatarView.profileImage = [thumbnailManager placeholderThumbnailImage];
    
    self.initialContentPickerContainerHeight = self.contentPickerContainerHeightConstraint.constant;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Request the user profile
    self.controllerState = AFAProfileControllerStateRefreshInProgress;
    [self onRefresh:nil];
}


#pragma mark -
#pragma mark Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([kSegueIDProfileContentPickerComponentEmbedding isEqualToString:segue.identifier]) {
        self.contentPickerViewController = (AFAContentPickerViewController *)segue.destinationViewController;
        self.contentPickerViewController.delegate = self;
        
        AFAContentPickerProfileUploadBehavior *profileUploadBehavior = [AFAContentPickerProfileUploadBehavior new];
        AFAContentPickerDataSource *contentPickerDataSource = [AFAContentPickerDataSource new];
        contentPickerDataSource.uploadBehavior = profileUploadBehavior;
        self.contentPickerViewController.dataSource = contentPickerDataSource;
    }
}


#pragma mark -
#pragma mark Connectivity notifications

- (void)didRestoredNetworkConnectivity {
    [super didRestoredNetworkConnectivity];
    
    self.controllerState = AFAProfileControllerStateRefreshInProgress;
    [self onRefresh:nil];
}

- (void)didLoseNetworkConnectivity {
    [super didLoseNetworkConnectivity];
    
    [self onRefresh:nil];
}


#pragma mark -
#pragma mark Actions

- (IBAction)onRefresh:(id)sender {
    self.refreshView.hidden = YES;
    self.noInformationAvailableLabel.hidden = YES;
    [self showProfileSaveButton:NO];
    
    [self fetchProfileInformation];
    [self fetchProfileImage];
}

- (IBAction)onDismissTap:(UITapGestureRecognizer *)sender {
    [self.view endEditing:YES];
}

- (IBAction)onProfilePictureAdd:(id)sender {
    [self toggleFullscreenOverlayView];
    [self toggleContentPickerComponent];
}

- (void)toggleContentPickerComponent {
    NSInteger contentPickerConstant = 0;
    if (!self.contentPickerContainerBottomConstraint.constant) {
        if (@available(iOS 11.0, *)) {
            self.contentPickerContainerHeightConstraint.constant = self.initialContentPickerContainerHeight + self.view.safeAreaInsets.bottom;
            contentPickerConstant = self.contentPickerContainerHeightConstraint.constant;;
        } else {
            contentPickerConstant = self.contentPickerContainerHeightConstraint.constant;
        }
    }
    
    // Show the content picker container
    if (contentPickerConstant) {
        self.contentPickerContainer.hidden = NO;
    }
    
    [self.view layoutIfNeeded];
    [UIView animateWithDuration:kDefaultAnimationTime
                          delay:0
         usingSpringWithDamping:.95f
          initialSpringVelocity:20.0f
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.contentPickerContainerBottomConstraint.constant = contentPickerConstant;
                         [self.view layoutIfNeeded];
                     } completion:^(BOOL finished) {
                         if (!contentPickerConstant) {
                             self.contentPickerContainer.hidden = YES;
                         }
                     }];
}

- (void)toggleFullscreenOverlayView {
    CGFloat alphaValue = !self.fullScreenOverlayView.alpha ? .4f : .0f;
    if (alphaValue) {
        self.fullScreenOverlayView.hidden = NO;
    }
    
    [UIView animateWithDuration:kDefaultAnimationTime animations:^{
        self.fullScreenOverlayView.alpha = alphaValue;
    } completion:^(BOOL finished) {
        if (!alphaValue) {
            self.fullScreenOverlayView.hidden = YES;
        }
    }];
}

- (IBAction)onFullscreenOverlayTap:(id)sender {
    [self toggleFullscreenOverlayView];
    [self toggleContentPickerComponent];
}


#pragma mark -
#pragma mark Service integration

- (void)fetchProfileInformation {
    __weak typeof(self) weakSelf = self;
    
    void (^updateProfileDataSourceBlock)(ASDKModelProfile *) = ^(ASDKModelProfile *profile) {
        __strong typeof(self) strongSelf = weakSelf;
        
        // Display the last update date
        if (strongSelf.refreshControl) {
            strongSelf.refreshControl.attributedTitle = [[NSDate date] lastUpdatedFormattedString];
        }
        
        // Store the fetched profile
        AFAProfileViewControllerDataSource *profileDataSource = [[AFAProfileViewControllerDataSource alloc] initWithProfile:profile];
        profileDataSource.delegate = self;
        BOOL showingCachedOrRefreshingData = (AFAProfileControllerStateRefreshInProgress == strongSelf.controllerState ||
                                              AFAProfileControllerStateCachedResults == strongSelf.controllerState);
        profileDataSource.isInputEnabled = showingCachedOrRefreshingData ? NO : YES;
        strongSelf.profileTableView.dataSource = profileDataSource;
        strongSelf.dataSource = profileDataSource;
        
        [strongSelf updateUIForProfileContent:profile];
    };
    
    [self.requestProfileService requestProfileWithCompletionBlock:^(ASDKModelProfile *profile, NSError *error) {
        __strong typeof(self) strongSelf = weakSelf;
        
        if (!error) {
            strongSelf.controllerState = AFAProfileControllerStateIdle;
            updateProfileDataSourceBlock(profile);
        } else {
            if (error.code == NSURLErrorNotConnectedToInternet) {
                [self showWarningMessage:NSLocalizedString(kLocalizationOfflineProvidingCachedResultsText, @"Cached results text")];
            } else {
                [self showErrorMessage:NSLocalizedString(kLocalizationAlertDialogGenericNetworkErrorText, @"Generic network error")];
            }
        }
    } cachedResults:^(ASDKModelProfile *profile, NSError *error) {
        __strong typeof(self) strongSelf = weakSelf;
        
        if (!error) {
            strongSelf.controllerState = AFAProfileControllerStateCachedResults;
            updateProfileDataSourceBlock(profile);
        }
        
        BOOL isInformationAvailable = error ? NO : YES;
        strongSelf.noInformationAvailableLabel.hidden = isInformationAvailable;
        strongSelf.profileTableView.hidden = !isInformationAvailable;
        strongSelf.refreshView.hidden = isInformationAvailable;
        
        [[NSOperationQueue currentQueue] addOperationWithBlock:^{
            [weakSelf.refreshControl endRefreshing];
        }];
    }];
}

- (void)fetchProfileImage {
    __weak typeof(self) weakSelf = self;
    [self.profileImageService requestProfileImageWithCompletionBlock:^(UIImage *profileImage, NSError *error) {
        __strong typeof(self) strongSelf = weakSelf;
        
        AFAThumbnailManager *thumbnailManager = [[AFAServiceRepository sharedRepository] serviceObjectForPurpose:AFAServiceObjectTypeThumbnailManager];
        
        if (!error) {
            strongSelf.profileImage = profileImage;
            
            // If we don't have loaded a thumbnail image use a placeholder instead
            // otherwise look in the cache or compute the image and set it once
            // available
            strongSelf.profileImage = [thumbnailManager thumbnailForImage:self.profileImage
                                                           withIdentifier:kProfileImageThumbnailIdentifier
                                                                 withSize:CGRectGetHeight(strongSelf.avatarView.frame) * [UIScreen mainScreen].scale
                                                processingCompletionBlock:^(UIImage *processedThumbnailImage) {
                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                        weakSelf.avatarView.profileImage = processedThumbnailImage;
                                                    });
                                                }];
        } else {
            strongSelf.profileImage = [thumbnailManager thumbnailImageForIdentifier:kProfileImageThumbnailIdentifier];
        }
        
        strongSelf.avatarView.profileImage = self.profileImage;
    }];
}


#pragma mark -
#pragma mark UITextField Delegate

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (self.isSlided) {
        // If the user chose to slide the drawer menu rollback changes he made to the fields
        [self.dataSource rollbackProfileChanges];
        [self showProfileSaveButton:NO];
        [self updateUIForProfileContent:self.dataSource.currentProfile];
    } else {
        // Check for changes made to the profile
        if (self.firstNameTextField == textField) {
            if (![self.dataSource.currentProfile.userFirstName isEqualToString:textField.text]) {
                self.dataSource.currentProfile.userFirstName = textField.text;
            }
        }
        
        if (self.lastNameTextField == textField) {
            if (![self.dataSource.currentProfile.userLastName isEqualToString:textField.text]) {
                self.dataSource.currentProfile.userLastName = textField.text;
            }
        }
        
        [self showProfileSaveButton:[self.dataSource isProfileUpdated]];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    return YES;
}


#pragma mark -
#pragma mark AFAContentPickerViewController Delegate

- (void)userPickedImageAtURL:(NSURL *)imageURL {
    [self onFullscreenOverlayTap:nil];
}

- (void)userDidCancelImagePick {
    [self onFullscreenOverlayTap:nil];
}

- (void)pickedContentHasFinishedUploading {
    [self fetchProfileImage];
}

- (void)userPickedImageFromCamera {
    [self onFullscreenOverlayTap:nil];
}

- (void)pickedContentHasFinishedDownloadingAtURL:(NSURL *)downloadedFileURL {
}


#pragma mark -
#pragma mark Progress hud setup

- (JGProgressHUD *)configureProgressHUD {
    JGProgressHUD *hud = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
    hud.interactionType = JGProgressHUDInteractionTypeBlockAllTouches;
    JGProgressHUDFadeZoomAnimation *zoomAnimation = [JGProgressHUDFadeZoomAnimation animation];
    hud.animation = zoomAnimation;
    
    return hud;
}

- (void)showFormSaveIndicatorView {
    self.progressHUD.textLabel.text = nil;
    JGProgressHUDIndeterminateIndicatorView *indicatorView = [[JGProgressHUDIndeterminateIndicatorView alloc] init];
    [indicatorView setColor:[UIColor whiteColor]];
    self.progressHUD.indicatorView = indicatorView;
    [self.progressHUD showInView:self.navigationController.view];
}


#pragma mark -
#pragma mark AFAProfileViewControllerDataSourceDelegate

- (void)handleNetworkErrorWithMessage:(NSString *)errorMessage {
    [self showGenericNetworkErrorAlertControllerWithMessage:errorMessage];
}

- (void)presentAlertController:(UIAlertController *)alertController {
    [self presentViewController:alertController
                       animated:YES
                     completion:nil];
}

- (void)showProfileSaveButton:(BOOL)isSaveButtonEnabled {    
    // Set up the profile information save button
    UIBarButtonItem *saveBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"save-icon"]
                                                                          style:UIBarButtonItemStylePlain
                                                                         target:self.dataSource
                                                                         action:@selector(challengeUserCredentialsForProfileUpdate)];
    saveBarButtonItem.tintColor = [UIColor whiteColor];
    
    if (isSaveButtonEnabled) {
        self.navigationItem.rightBarButtonItem = saveBarButtonItem;
    } else {
        self.navigationItem.rightBarButtonItem = nil;
    }
}

- (void)updateProfileInformation {
    // Ignore profile information updates when the screen is slided
    if (self.isSlided) {
        // If the user chose to slide the drawer menu rollback changes he made to the fields
        [self.dataSource rollbackProfileChanges];
        [self showProfileSaveButton:NO];
        [self updateUIForProfileContent:self.dataSource.currentProfile];
        return;
    }
    
    [self showFormSaveIndicatorView];
    
    __weak typeof(self) weakSelf = self;
    [self.profileUpdateService
     requestProfileUpdateWithModel:self.dataSource.currentProfile
     completionBlock:^(ASDKModelProfile *profile, NSError *error) {
         __strong typeof(self) strongSelf = weakSelf;
         
         if (!error) {
             // Display the last update date
             if (strongSelf.refreshControl) {
                 strongSelf.refreshControl.attributedTitle = [[NSDate date] lastUpdatedFormattedString];
             }
             
             strongSelf.progressHUD.textLabel.text = NSLocalizedString(kLocalizationProfileScreenProfileInformationUpdatedText, "Profile updated text");
             strongSelf.progressHUD.detailTextLabel.text = nil;
             strongSelf.progressHUD.indicatorView = [[JGProgressHUDSuccessIndicatorView alloc] init];
             
             dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                 [weakSelf.progressHUD dismiss];
             });
             
             // Store the fetched profile
             profile.groups = strongSelf.dataSource.currentProfile.groups;
             strongSelf.dataSource = [[AFAProfileViewControllerDataSource alloc] initWithProfile:profile];
             strongSelf.dataSource.delegate = strongSelf;
             strongSelf.profileTableView.dataSource = strongSelf.dataSource;
             
             [strongSelf updateUIForProfileContent:profile];
         } else {
             [strongSelf.progressHUD dismiss];
             [strongSelf handleNetworkErrorWithMessage:NSLocalizedString(kLocalizationAlertDialogGenericNetworkErrorText, @"Generic network error")];
             
             // If an error occured, roll back to the previous valid state of the user profile
             [strongSelf.dataSource rollbackProfileChanges];
             [self showProfileSaveButton:NO];
             [strongSelf updateUIForProfileContent:strongSelf.dataSource.currentProfile];
         }
         
         [strongSelf showProfileSaveButton:NO];
     }];
}

- (void)updateProfilePasswordWithNewPassword:(NSString *)updatedPassword
                                 oldPassword:(NSString *)oldPassword {
    [self showFormSaveIndicatorView];
    
    __weak typeof(self) weakSelf = self;
    [self.profilePasswordUpdateService
     requestProfilePasswordUpdatedWithNewPassword:updatedPassword
     oldPassword:oldPassword
     completionBlock:^(BOOL isPasswordUpdated, NSError *error) {
         __strong typeof(self) strongSelf = weakSelf;
         
         if (!error) {
             // Display the last update date
             if (strongSelf.refreshControl) {
                 strongSelf.refreshControl.attributedTitle = [[NSDate date] lastUpdatedFormattedString];
             }
             
             strongSelf.progressHUD.textLabel.text = NSLocalizedString(kLocalizationProfileScreenPasswordUpdatedText, "Password updated text");
             strongSelf.progressHUD.detailTextLabel.text = nil;
             strongSelf.progressHUD.indicatorView = [[JGProgressHUDSuccessIndicatorView alloc] init];
             
             dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                 [weakSelf.progressHUD dismiss];
             });
         } else {
             [strongSelf.progressHUD dismiss];
             [strongSelf handleNetworkErrorWithMessage:NSLocalizedString(kLocalizationProfileScreenInvalidPasswordResponseText, @"Invalid password response text")];
         }
     }];
}


#pragma mark -
#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView
heightForHeaderInSection:(NSInteger)section {
    CGFloat headerHeight = .0f;
    
    switch (section) {
        case AFAProfileControllerSectionTypeContactInformation:
        case AFAProfileControllerSectionTypeGroups: {
            headerHeight = kProfileControllerSectionHeight;
        }
            break;
            
        default:
            break;
    }
    
    return headerHeight;
}

- (UIView *)tableView:(UITableView *)tableView
viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = nil;
    
    if (AFAProfileControllerSectionTypeContactInformation == section ||
        AFAProfileControllerSectionTypeGroups == section) {
        AFAProfileSectionTableViewCell *sectionHeaderCell = [tableView dequeueReusableCellWithIdentifier:kCellIDProfileSectionTitle];
        
        if (AFAProfileControllerSectionTypeContactInformation == section) {
            sectionHeaderCell.sectionIconImageView.image = [UIImage imageNamed:@"contact-icon"];
            sectionHeaderCell.sectionTitleLabel.text = NSLocalizedString(kLocalizationProfileScreenContactInformationText, @"Contact information text");
        } else if (AFAProfileControllerSectionTypeGroups == section) {
            sectionHeaderCell.sectionIconImageView.image = [UIImage imageNamed:@"group-icon"];
            sectionHeaderCell.sectionTitleLabel.text = NSLocalizedString(kLocalizationProfileScreenGroupsText, @"Groups text");
        }
        
        sectionHeaderCell.sectionIconImageView.tintColor = [UIColor darkGreyTextColor];
        
        headerView = sectionHeaderCell;
    }
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView
heightForFooterInSection:(NSInteger)section {
    return 1.0f;
}


#pragma mark -
#pragma mark Utils

- (void)updateUIForProfileContent:(ASDKModelProfile *)profile {
    // Update the table header with the name and registration date
    self.firstNameTextField.text = profile.userFirstName;
    self.lastNameTextField.text = profile.userLastName;
    self.registeredDateLabel.text = [NSString stringWithFormat:NSLocalizedString(kLocalizationProfileScreenRegisteredFormat, @"Registered since date"), [profile.creationDate listCreationDate]];
    
    [self.profileTableView reloadData];
}


#pragma mark -
#pragma mark KVO bindings

- (void)handleBindingsForAppListViewController {
    self.kvoManager = [ASDKKVOManager managerWithObserver:self];
    
    __weak typeof(self) weakSelf = self;
    [self.kvoManager observeObject:self
                        forKeyPath:NSStringFromSelector(@selector(controllerState))
                           options:NSKeyValueObservingOptionNew
                             block:^(id observer, id object, NSDictionary *change) {
                                 AFAProfileControllerState controllerState = [change[NSKeyValueChangeNewKey] integerValue];
                                 
                                 BOOL showingCachedOrRefreshingData = (AFAProfileControllerStateRefreshInProgress == controllerState ||
                                                                       AFAProfileControllerStateCachedResults == controllerState);
                                 
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     weakSelf.activityView.hidden = (AFAProfileControllerStateRefreshInProgress == controllerState) ? NO : YES;
                                     weakSelf.activityView.animating = (AFAProfileControllerStateRefreshInProgress == controllerState) ? YES : NO;
                                     weakSelf.profileTableView.hidden = (AFAProfileControllerStateRefreshInProgress == controllerState) ? YES : NO;

                                     weakSelf.firstNameTextField.enabled = showingCachedOrRefreshingData ? NO : YES;
                                     weakSelf.lastNameTextField.enabled = showingCachedOrRefreshingData ? NO : YES;
                                     weakSelf.profilePictureAddButtonView.hidden = showingCachedOrRefreshingData;
                                 });
                             }];
    
    [self.kvoManager observeObject:self
                        forKeyPath:NSStringFromSelector(@selector(isSlided))
                           options:NSKeyValueObservingOptionNew
                             block:^(id observer, id object, NSDictionary *change) {
                                 [self.view endEditing:YES];
                             }];
}

@end

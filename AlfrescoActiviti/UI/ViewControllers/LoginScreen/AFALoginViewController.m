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

#import "AFALoginViewController.h"

// Constants
#import "AFAUIConstants.h"
#import "AFABusinessConstants.h"
#import "AFALocalizationConstants.h"

// Categories
#import "UIView+AFAViewAnimations.h"

// Models
#import "AFALoginViewModel.h"

// View controllers
#import "AFACredentialsPageViewController.h"
#import "AFAContainerViewController.h"

// Managers
#import "AFALogConfiguration.h"
@import ActivitiSDK;

// Views
#import "AFAActivityView.h"

// Animators
#import "AFAModalReplaceAnimator.h"
#import "AFAModalDismissAnimator.h"


static const int activitiLogLevel = AFA_LOG_LEVEL_VERBOSE; // | AFA_LOG_FLAG_TRACE;

@interface AFALoginViewController () <UIViewControllerTransitioningDelegate>

// Views
@property (weak, nonatomic) IBOutlet UIView                     *effectViewContainer;
@property (weak, nonatomic) IBOutlet UIImageView                *activitiLogoImageView;
@property (weak, nonatomic) IBOutlet UIView                     *serverButtonsContainerView;
@property (weak, nonatomic) IBOutlet UIView                     *roundedViewsContainer;
@property (weak, nonatomic) IBOutlet UIView                     *embeddedViewContainer;
@property (weak, nonatomic) IBOutlet UIToolbar                  *buttonToolbar;
@property (weak, nonatomic) IBOutlet AFAActivityView            *activityView;
@property (weak, nonatomic) IBOutlet UIButton                   *cloudLoginButton;
@property (weak, nonatomic) IBOutlet UIButton                   *premiseLoginButton;

// Constraints
@property (weak, nonatomic) IBOutlet NSLayoutConstraint         *activitiLogoCenterConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint         *activitiLogoCenterPaddedConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint         *activitiLogoTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint         *activitiLogoPaddedTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint         *roundedViewsCenterConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint         *serverButtonsCenterConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint         *roundedViewsPaddedConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint         *serverButtonsPaddedConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint         *containerViewTopAlignment;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint         *containerViewCenterConstraint;

// Controllers
@property (strong, nonatomic) AFACredentialsPageViewController  *credentialsPageViewController;

// Models
@property (strong, nonatomic) AFALoginViewModel                 *loginViewModel;

// KVO
@property (strong, nonatomic) ASDKKVOManager                    *kvoManager;

@end

@implementation AFALoginViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        _loginViewModel = [AFALoginViewModel new];
        _kvoManager = [ASDKKVOManager managerWithObserver:self];
    }
    
    return self;
}

- (void)dealloc {
    [self.kvoManager removeObserver:self
                         forKeyPath:NSStringFromSelector(@selector(isCredentialInputInProgress))];
    [self.kvoManager removeObserver:self
                         forKeyPath:NSStringFromSelector(@selector(authState))];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNeedsStatusBarAppearanceUpdate];
    
    // Set up localization
    [self.cloudLoginButton setTitle:NSLocalizedString(kLocalizationLoginCloudLoginButtonText, @"Cloud login text")
                           forState:UIControlStateNormal];
    [self.premiseLoginButton setTitle:NSLocalizedString(kLocalizationLoginPremiseLoginButtonText, @"Premise login text")
                             forState:UIControlStateNormal];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.activitiLogoCenterConstraint.active = NO;
    self.activitiLogoCenterPaddedConstraint.active = YES;
    
    [self.loginViewModel restoreLastSuccessfullSessionLoginCredentialsForType:[AFALoginViewModel lastAuthenticationType]];
    
    if ([self.loginViewModel canUserSignIn]) {
        [self handleBindingsForLoginViewModel:self.loginViewModel];
        [self.loginViewModel requestLoginWithCompletionBlock:^(BOOL isLoggedIn, NSError *error) {
            BOOL displayEnvironmentMenu = NO;
            if (!error) {
                if (!isLoggedIn) {
                    // Credentials might have expired or have been changed
                    // Display the environment menu options
                    displayEnvironmentMenu = YES;
                }
            } else {
                displayEnvironmentMenu = YES;
                AFALogVerbose(@"Failed to auto login with Keychain credentials. Reason:%@", error.localizedDescription);
            }
            
            if (displayEnvironmentMenu) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [UIView animateViewsFromArray:@[self.roundedViewsContainer, self.serverButtonsContainerView]
                                        withAlpha:1.0f
                                     withDuration:kLoginScreenServerButtonsFadeInTime
                              withCompletionBlock:nil];
                });
            }
        }];
    } else { // Show the enviroment menu options
        [UIView animateViewsFromArray:@[self.roundedViewsContainer, self.serverButtonsContainerView]
                            withAlpha:1.0f
                         withDuration:kLoginScreenServerButtonsFadeInTime
                  withCompletionBlock:nil];
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}


#pragma mark -
#pragma mark Navigation

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                  presentingController:(UIViewController *)presenting
                                                                      sourceController:(UIViewController *)source {
    return [AFAModalReplaceAnimator new];
}

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return [AFAModalDismissAnimator new];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue
                 sender:(id)sender {
    // Get a hold of the reference for the embedded page view controller
    if ([kStoryboardIDEmbeddedCredentialsPageController isEqualToString:segue.identifier]) {
        self.credentialsPageViewController = segue.destinationViewController;
        [self handleBindingsForLoginViewModel:self.credentialsPageViewController.cloudLoginViewModel];
        [self handleBindingsForLoginViewModel:self.credentialsPageViewController.premiseLoginViewModel];
    }
    
    if ([kSegueIDLoginAuthorized isEqualToString:segue.identifier]) {
        AFAContainerViewController *containerViewController = segue.destinationViewController;
        containerViewController.transitioningDelegate = self;
//        containerViewController.loginViewModel = self.loginViewModel;
    }
}

- (IBAction)unwindToLoginController:(UIStoryboardSegue *)segue {
    [self onEnvironment:nil];
}


#pragma mark -
#pragma mark Actions

- (IBAction)onActivitiCloud:(id)sender {
    [self.credentialsPageViewController.cloudLoginViewModel restoreLastSuccessfullSessionLoginCredentialsForType:AFALoginAuthenticationTypeCloud];
    
    [self performCredentialPageAnimationInReverse:NO
                                  completionBlock:^(BOOL finished) {
        [self.credentialsPageViewController showCloudLoginCredentials];
    }];
}

- (IBAction)onActivitiPremise:(id)sender {
    [self.credentialsPageViewController.premiseLoginViewModel restoreLastSuccessfullSessionLoginCredentialsForType:AFALoginAuthenticationTypePremise];
    
    [self performCredentialPageAnimationInReverse:NO
                                  completionBlock:^(BOOL finished) {
        [self.credentialsPageViewController showPremiseLoginCredentials];
    }];
}

- (IBAction)onEnvironment:(id)sender {
    NSMutableArray *loginViewModels = [NSMutableArray new];
    
    if (self.loginViewModel) {
        [loginViewModels addObject:self.loginViewModel];
    }
    if (self.credentialsPageViewController.cloudLoginViewModel) {
        [loginViewModels addObject:self.credentialsPageViewController.cloudLoginViewModel];
    }
    if (self.credentialsPageViewController.premiseLoginViewModel) {
        [loginViewModels addObject:self.credentialsPageViewController.premiseLoginViewModel];
    }
    
    // Cancel possible ongoing login request
    [loginViewModels makeObjectsPerformSelector:@selector(cancelLoginRequest)];
    
    [self showEnvironmentPageAnimation];
}


#pragma mark -
#pragma mark Animations

- (void)performLogoShrinkAndCredentialsPaddingAnimationInReverse:(BOOL)isReverseAnimation {
    // Animate activiti logo from center position to the first quarter
    // of the upper part adjusting also it's size
    if (!isReverseAnimation) {
        self.activitiLogoCenterPaddedConstraint.active = NO;
        self.activitiLogoPaddedTopConstraint.active = YES;
        self.activitiLogoTopConstraint.active = YES;
        
        // Animate the embedded container view center Y position and lift it
        self.containerViewTopAlignment.active = NO;
        self.containerViewCenterConstraint.active = YES;
    } else {
        self.activitiLogoTopConstraint.active = NO;
        self.activitiLogoPaddedTopConstraint.active = NO;
        self.activitiLogoCenterPaddedConstraint.active = YES;
        
        self.containerViewCenterConstraint.active = NO;
        self.containerViewTopAlignment.active = YES;
    }
    
    [UIView animateWithDuration:kDefaultAnimationTime
                          delay:.0f
         usingSpringWithDamping:1.0f
          initialSpringVelocity:5.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         [self.view layoutIfNeeded];
                     } completion:nil];
}

- (void)performCredentialPageAnimationInReverse:(BOOL)isReverseAnimation
                                completionBlock:(void (^)(BOOL finished))completionBlock {
    if (!isReverseAnimation) {
        // Make visible the environment toolbar
        [self.buttonToolbar animateAlpha:1.0f
                            withDuration:kDefaultAnimationTime
                     withCompletionBlock:nil];
        
        // Animate moving rounded views and server buttons to the left side
        self.roundedViewsCenterConstraint.active = NO;
        self.serverButtonsCenterConstraint.active = NO;
        self.roundedViewsPaddedConstraint.active = YES;
        self.serverButtonsPaddedConstraint.active = YES;
    } else {
        // Animate moving rounded views and server buttons to the right side
        
        self.roundedViewsPaddedConstraint.active = NO;
        self.serverButtonsPaddedConstraint.active = NO;
        
        self.roundedViewsCenterConstraint.active = YES;
        self.serverButtonsCenterConstraint.active = YES;
    }
    
    [UIView animateWithDuration:kDefaultAnimationTime
                          delay:.0f
         usingSpringWithDamping:1.0f
          initialSpringVelocity:5.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         [self.roundedViewsContainer layoutIfNeeded];
                         [self.serverButtonsContainerView layoutIfNeeded];
                     } completion:completionBlock];
}

- (void)performActivityAnimationInReverse:(BOOL)isReverseAnimation {
    self.activityView.animating = !self.activityView.animating;
    
    NSTimeInterval activityViewDelay = isReverseAnimation ? 0 : kDefaultAnimationTime / 3.0f;
    NSTimeInterval activitiLogoDelay = isReverseAnimation ? kDefaultAnimationTime / 3.0f : 0;
    
    [UIView animateWithDuration:kDefaultAnimationTime
                          delay:activitiLogoDelay
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.activitiLogoImageView.alpha = isReverseAnimation ? 1.0f : .0f;
                     } completion:nil];
    
    [UIView animateWithDuration:kDefaultAnimationTime
                          delay:activityViewDelay
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.activityView.alpha = isReverseAnimation ? .0f : 1.0f;
                     } completion:nil];
}

- (void)showEnvironmentPageAnimation {
    [self.credentialsPageViewController hideCurrentPageWithCompletionBlock:^(BOOL finished) {
        // Hide the environment toolbar
        [self.buttonToolbar animateAlpha:.0f
                            withDuration:kDefaultAnimationTime
                     withCompletionBlock:nil];
        
        [self performCredentialPageAnimationInReverse:YES
                                      completionBlock:nil];
    }];
}

#pragma mark -
#pragma mark KVO bindings

- (void)handleBindingsForLoginViewModel:(AFALoginViewModel *)loginViewModel {
    __weak typeof(self) weakSelf = self;
    [self.kvoManager observeObject:loginViewModel
                        forKeyPath:NSStringFromSelector(@selector(isCredentialInputInProgress))
                           options:NSKeyValueObservingOptionNew
                             block:^(id observer, id object, NSDictionary *change) {
                                 BOOL isEditingInProgress = [change[NSKeyValueChangeNewKey] boolValue];
                                 
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     [weakSelf performLogoShrinkAndCredentialsPaddingAnimationInReverse:!isEditingInProgress];
                                 });
                             }];
    
    [self.kvoManager observeObject:loginViewModel
                        forKeyPath:NSStringFromSelector(@selector(authState))
                           options:NSKeyValueObservingOptionNew
                             block:^(id observer, id object, NSDictionary *change) {
                                 AFALoginAuthenticationState authState = [change[NSKeyValueChangeNewKey] unsignedIntegerValue];
                                 
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     if (AFALoginAuthenticationStateLoggedOut == authState) {
                                         [weakSelf showEnvironmentPageAnimation];
                                         return ;
                                     }
                                     
                                     // If the user performed an action asses whether an animation is needed
                                     if (AFALoginAuthenticationStatePreparing != authState) {
                                         [weakSelf performActivityAnimationInReverse:(AFALoginAuthenticationStateInProgress == authState) ? NO : YES];
                                     }
                                     
                                     if (AFALoginAuthenticationStateAuthorized == authState) {
                                         AFALoginViewModel *authorizedLoginModel = (AFALoginViewModel *)object;
                                         [weakSelf.loginViewModel updateUserNameEntry:authorizedLoginModel.username];
                                         [weakSelf.loginViewModel updatePasswordEntry:authorizedLoginModel.password];
                                         [weakSelf.loginViewModel updateHostNameEntry:authorizedLoginModel.hostName];
                                         [weakSelf.loginViewModel updatePortEntry:authorizedLoginModel.port];
                                         [weakSelf.loginViewModel updateCommunicationOverSecureLayer:authorizedLoginModel.isSecureLayer];
                                         [weakSelf.loginViewModel updateServiceDocument:authorizedLoginModel.serviceDocument];
                                         [weakSelf.loginViewModel updateRememberCredentials:authorizedLoginModel.rememberCredentials];
                                         
                                         [weakSelf performSegueWithIdentifier:kSegueIDLoginAuthorized
                                                                   sender:nil];
                                     }
                                 });
                             }];
}


@end

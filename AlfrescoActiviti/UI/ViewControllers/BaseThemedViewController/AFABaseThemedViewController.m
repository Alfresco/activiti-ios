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

#import "AFABaseThemedViewController.h"

// Constants
#import "AFAUIConstants.h"
#import "AFALocalizationConstants.h"

// Managers
@import ActivitiSDK;

@interface AFABaseThemedViewController ()

@property (strong, nonatomic) AFANavigationBarBannerAlertView   *bannerAlertView;
@property (assign, nonatomic) BOOL                              isControllerViewVisible;
@property (strong, nonatomic) ASDKKVOManager                    *kvoManager;

@end

@implementation AFABaseThemedViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _kvoManager = [ASDKKVOManager managerWithObserver:self];
        
        __weak typeof(self) weakSelf = self;
        [_kvoManager observeObject:self
                        forKeyPath:NSStringFromSelector(@selector(networkReachabilityStatus))
                           options:NSKeyValueObservingOptionNew
                             block:^(id observer, id object, NSDictionary *change) {
                                 __strong typeof(self) strongSelf = weakSelf;
                                 
                                 ASDKNetworkReachabilityStatus reachability = [change[NSKeyValueChangeNewKey] integerValue];
                                 
                                 switch (reachability) {
                                     case ASDKNetworkReachabilityStatusNotReachable: {
                                         if (strongSelf.isControllerViewVisible) {
                                             [strongSelf didLoseNetworkConnectivity];
                                         }
                                     }
                                         break;
                                         
                                     case ASDKNetworkReachabilityStatusReachableViaWWANOrWifi: {
                                         if (strongSelf.isControllerViewVisible) {
                                             [strongSelf didRestoredNetworkConnectivity];
                                         }
                                     }
                                         break;
                                         
                                     default: break;
                                 }
                             }];
    }
    
    return self;
}

- (void)dealloc {
    [self.kvoManager removeObserver:self
                         forKeyPath:NSStringFromSelector(@selector(networkReachabilityStatus))];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _bannerAlertView = [[AFANavigationBarBannerAlertView alloc] initWithParentViewController:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.isControllerViewVisible = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.isControllerViewVisible = NO;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.bannerAlertView hide];
}


#pragma mark -
#pragma mark Setters

- (void)setNavigationBarTitle:(NSString *)navigationBarTitle {
    if (![_navigationBarTitle isEqualToString:navigationBarTitle]) {
        _navigationBarTitle = navigationBarTitle;
        
        // Update navigation bar title
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.text = _navigationBarTitle;
        titleLabel.font = [UIFont fontWithName:@"Avenir-Book"
                                          size:17];
        titleLabel.textColor = [UIColor whiteColor];
        [titleLabel sizeToFit];
        self.navigationItem.titleView = titleLabel;
    }
}

- (void)setNavigationBarThemeColor:(UIColor *)navigationBarThemeColor {
    if (_navigationBarThemeColor != navigationBarThemeColor) {
        _navigationBarThemeColor = navigationBarThemeColor;
        
        // Make the color change an animated transition
        [self.navigationController.navigationBar.layer addAnimation:[self fadeTransitionWithDuration:kOverlayAlphaChangeTime]
                                                             forKey:nil];
        [self.navigationController.navigationBar setBarTintColor:_navigationBarThemeColor];
        [self.navigationController.navigationBar setTranslucent:NO];
    }
}

- (CATransition *)fadeTransitionWithDuration:(CGFloat)duration {
    CATransition *transition = [CATransition animation];
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionFade;
    transition.duration = duration;
    return transition;
}


#pragma mark -
#pragma mark Public interface

- (void)showWarningMessage:(NSString *)warningMessage {
    [self.bannerAlertView showAndHideWithText:warningMessage
                                        title:NSLocalizedString(kLocalizationBannerViewWarningText, @"Warning title")
                                        style:AFABannerAlertStyleWarning];
}

- (void)showErrorMessage:(NSString *)errorMessage {
    [self.bannerAlertView showAndHideWithText:errorMessage
                                        title:NSLocalizedString(kLocalizationBannerViewErrorText, @"Error title")
                                        style:AFABannerAlertStyleError];
}

- (void)showConfirmationMessage:(NSString *)confirmationMessage {
    [self.bannerAlertView showAndHideWithText:confirmationMessage
                                        title:NSLocalizedString(kLocalizationBannerViewConfirmationText, @"Confirmation title")
                                        style:AFABannerAlertStyleSuccess];
}

- (void)didRestoredNetworkConnectivity {
    [self showConfirmationMessage:NSLocalizedString(kLocalizationOfflineConnectivityConnectedRefreshingText, @"Reconect text")];
}

- (void)didLoseNetworkConnectivity {
    // Override in child classes
}

- (BOOL)isNetworkReachable {
    return (self.networkReachabilityStatus == ASDKNetworkReachabilityStatusReachableViaWWANOrWifi) ? YES : NO;
}

@end

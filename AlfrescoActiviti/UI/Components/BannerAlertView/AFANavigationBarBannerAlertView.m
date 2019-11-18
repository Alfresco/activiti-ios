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

#import "AFANavigationBarBannerAlertView.h"
#import "UIColor+AFATheme.h"
#import "AFAUIConstants.h"

static const CGFloat kVerticalMargin = 16.0f;
static const CGFloat kTopMarginWithoutNavigationBar = 44.0f;
static const NSTimeInterval kHideTimeout = 2.f;

typedef void  (^AFANavigationBarBannerAlertHideCompletionBlock) (void);

@interface AFANavigationBarBannerAlertView()

@property (strong, nonatomic) UILabel               *alertTextLabel;
@property (strong, nonatomic) NSLayoutConstraint    *topSpacingConstraint;
@property (weak, nonatomic) UIViewController        *parentViewController;
@property (strong, nonatomic) NSTimer               *hideTimer;

@end

@implementation AFANavigationBarBannerAlertView

- (instancetype)initWithAlertText:(NSString *)alertText
                       alertStyle:(AFABannerAlertStyle)alertStyle
             parentViewController:(UIViewController *)parentViewController {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        _alertText = alertText;
        _alertStyle = alertStyle;
        _parentViewController = parentViewController;
        
        [self setUpBannerComponents];
    }
    return self;
}

+ (instancetype)showAlertWithText:(NSString *)alertText
                            style:(AFABannerAlertStyle)alertStyle
                 inViewController:(UIViewController *)viewController {
    AFANavigationBarBannerAlertView *bannerAlert = [[AFANavigationBarBannerAlertView alloc] initWithAlertText:alertText
                                                                                                   alertStyle:alertStyle
                                                                                         parentViewController:viewController];
    [bannerAlert showAndHideWithTimeout:kHideTimeout];
    
    return bannerAlert;
}

- (instancetype)initWithParentViewController:(UIViewController *)parentViewController {
    return [self initWithAlertText:nil
                        alertStyle:AFABannerAlertStyleUndefined
              parentViewController:parentViewController];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.alertTextLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.alertTextLabel.frame);
}

- (void)updateConstraints {
    [super updateConstraints];
    
    UINavigationBar *navigationBar = self.parentViewController.navigationController.navigationBar;
    self.topSpacingConstraint.constant = navigationBar.isHidden ? 0 : CGRectGetMaxY(navigationBar.frame);;
    
    if (!self.isBannerVisible) {
        self.topSpacingConstraint.constant += -self.frame.size.height;
    }
}

- (void)setUpBannerComponents {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    
    // Set up alert label
    self.alertTextLabel = [[UILabel alloc] init];
    self.alertTextLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.alertTextLabel.numberOfLines = 0;
    self.alertTextLabel.textAlignment = NSTextAlignmentCenter;
    self.alertTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.alertTextLabel.backgroundColor = [UIColor clearColor];
    self.alertTextLabel.font = [UIFont fontWithName:@"Avenir-Book"
                                               size:14.0f];
    [self addSubview:self.alertTextLabel];
    
    // Configure alert label constraints
    NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[alertLabel]-|"
                                                                             options:kNilOptions
                                                                             metrics:nil
                                                                               views:@{@"alertLabel" : self.alertTextLabel}];
    
    NSArray *verticalConstraints =
    [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(top)-[alertLabel]-(bottom)-|"
                                            options:kNilOptions
                                            metrics:@{@"top"         : self.parentViewController.navigationController.navigationBar.isHidden ? @(kVerticalMargin) : @(kTopMarginWithoutNavigationBar),
                                                      @"bottom"      : @(kVerticalMargin),}
                                              views:@{@"alertLabel"  : self.alertTextLabel}];
    [self addConstraints:horizontalConstraints];
    [self addConstraints:verticalConstraints];
}

- (void)updateUI {
    [self updateConstraintsIfNeeded];
    [self layoutIfNeeded];
    
    [self setNeedsUpdateConstraints];
}

- (void)updateAlertStyleAndText {
    // Set up background and text color based on the style of the alert
    UIColor *backgroundColor = nil;
    UIColor *alertTextColor = nil;
    
    if (AFABannerAlertStyleWarning == self.alertStyle) {
        backgroundColor = [UIColor connectivityWarningColor];
        alertTextColor = [UIColor darkGreyTextColor];
    } else if (AFABannerAlertStyleError == self.alertStyle) {
        backgroundColor = [UIColor alertWithErrorColor];
        alertTextColor = [UIColor whiteColor];
    } else if (AFABannerAlertStyleSuccess == self.alertStyle) {
        backgroundColor = [UIColor connectivityRestoredColor];
        alertTextColor = [UIColor whiteColor];
    }
    
    self.backgroundColor = backgroundColor;
    self.alertTextLabel.textColor = alertTextColor;
    self.alertTextLabel.text = self.alertText;
}

- (void)show {
    _isBannerVisible = YES;
    
    UINavigationBar *navigationBar = self.parentViewController.navigationController.navigationBar;
    CGFloat topOffset;
    
    if (!navigationBar.isHidden) {
        [navigationBar.superview insertSubview:self
        belowSubview:navigationBar];
        topOffset = CGRectGetMaxY(navigationBar.frame);
    } else {
        [self.parentViewController.view addSubview:self];
        topOffset = 0;
    }

    NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[banner]|"
                                                                             options:kNilOptions
                                                                             metrics:nil
                                                                               views:@{@"banner": self}];
    NSArray *topConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(offset)-[banner]"
                                                                      options:kNilOptions
                                                                      metrics:@{@"offset": @(topOffset)}
                                                                        views:@{@"banner": self}];
    self.topSpacingConstraint = topConstraints.firstObject;
    
    [self.superview addConstraints:horizontalConstraints];
    [self.superview addConstraints:topConstraints];
    
    [self updateAlertStyleAndText];
    [self updateUI];
    
    self.transform = CGAffineTransformMakeTranslation(0, -self.frame.size.height);
    [UIView animateWithDuration:kDefaultAnimationTime
                     animations:^{
                         self.transform = CGAffineTransformIdentity;
                     }];
}

- (void)hide:(AFANavigationBarBannerAlertHideCompletionBlock)hideCompletionBlock {
    if (self.hideTimer) {
        [self.hideTimer invalidate];
        self.hideTimer = nil;
    }
    
    _isBannerVisible = NO;
    
    [self updateUI];
    
    self.transform = CGAffineTransformMakeTranslation(0, self.frame.size.height);
    [UIView animateWithDuration:kDefaultAnimationTime animations:^{
        self.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        if (hideCompletionBlock) {
            hideCompletionBlock();
        }
    }];
}

- (void)hide {
    [self hide:nil];
}

- (void)showAndHideWithTimeout:(NSTimeInterval)timeout {
    [self show];
    
    self.hideTimer = [NSTimer scheduledTimerWithTimeInterval:timeout
                                                      target:self
                                                    selector:@selector(hide)
                                                    userInfo:nil
                                                     repeats:NO];
}

- (void)showAndHideWithText:(NSString *)alertText
                      style:(AFABannerAlertStyle)alertStyle {
    _alertText = alertText;
    _alertStyle = alertStyle;
    
    if (self.isBannerVisible) {
        __weak typeof(self) weakSelf = self;
        [self hide:^{
            __strong typeof(self) strongSelf = weakSelf;
            [strongSelf showAndHideWithTimeout:kHideTimeout];
        }];
    } else {
        [self showAndHideWithTimeout:kHideTimeout];
    }
}

@end

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

static const CGFloat kNotchVerticalPadding          = 10.0f;
static const CGFloat kVerticalPadding               = 20.0f;
static const CGFloat kHorizontalPadding             = 8.0f;
static const CGFloat kHorizontalImageViewPadding    = 12.0f;
static const CGFloat kAlertImageViewRectangleSize   = 25.0f;
static const CGFloat kCloseButtonRectangleSize      = 20.0f;
static const NSTimeInterval kHideTimeout            = 2.f;

typedef void  (^AFANavigationBarBannerAlertHideCompletionBlock) (void);

@interface AFANavigationBarBannerAlertView()

@property (strong, nonatomic) UIView                *containerView;
@property (strong, nonatomic) UILabel               *alertTitleLabel;
@property (strong, nonatomic) UILabel               *alertTextLabel;
@property (strong, nonatomic) UIButton              *closeButton;
@property (strong, nonatomic) UIImageView           *alertImageView;
@property (strong, nonatomic) UIView                *separator;
@property (strong, nonatomic) NSLayoutConstraint    *topSpacingConstraint;
@property (weak, nonatomic) UIViewController        *parentViewController;
@property (strong, nonatomic) NSTimer               *hideTimer;
@property (assign, nonatomic) BOOL                  hasSetConstraints;

@end

@implementation AFANavigationBarBannerAlertView

- (instancetype)initWithAlertText:(NSString *)alertText
                            title:(NSString *)alertTitle
                       alertStyle:(AFABannerAlertStyle)alertStyle
             parentViewController:(UIViewController *)parentViewController {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        _alertText = alertText;
        _alertTitle = alertTitle;
        _alertStyle = alertStyle;
        _parentViewController = parentViewController;
        
        [self setUpBannerComponents];
    }
    return self;
}

+ (instancetype)showAlertWithText:(NSString *)alertText
                            title:(NSString *)alertTitle
                            style:(AFABannerAlertStyle)alertStyle
                 inViewController:(UIViewController *)viewController {
    AFANavigationBarBannerAlertView *bannerAlert = [[AFANavigationBarBannerAlertView alloc] initWithAlertText:alertText
                                                                                                        title:alertTitle
                                                                                                   alertStyle:alertStyle
                                                                                         parentViewController:viewController];
    [bannerAlert showAndHideWithTimeout:kHideTimeout];
    
    return bannerAlert;
}

- (instancetype)initWithParentViewController:(UIViewController *)parentViewController {
    return [self initWithAlertText:nil
                             title:nil
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

- (BOOL)navigationHidden {
    return self.parentViewController.navigationController.navigationBar.isHidden;
}

- (void)setUpBannerComponents {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.containerView = [UIView new];
    self.containerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.containerView];
    
    // Set up alert image view
    self.alertImageView = [UIImageView new];
    self.alertImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.alertImageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.alertImageView.tintColor = UIColor.whiteColor;
    
    [self.containerView addSubview:self.alertImageView];
    
    // Set up alert title
    self.alertTitleLabel = [UILabel new];
    self.alertTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.alertTitleLabel.contentMode = UIViewContentModeTopLeft;
    self.alertTitleLabel.numberOfLines = 1;
    self.alertTitleLabel.textAlignment = NSTextAlignmentLeft;
    self.alertTitleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    self.alertTitleLabel.backgroundColor = UIColor.clearColor;
    self.alertTitleLabel.font = [UIFont fontWithName:@"Muli-Bold"
                                                size:14.0f];
    self.alertTitleLabel.textColor = UIColor.whiteColor;
    [self.containerView addSubview:self.alertTitleLabel];
    
    // Set up alert label
    self.alertTextLabel = [UILabel new];
    self.alertTextLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.alertTextLabel.numberOfLines = 2;
    self.alertTextLabel.textAlignment = NSTextAlignmentLeft;
    self.alertTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.alertTextLabel.backgroundColor = UIColor.clearColor;
    self.alertTextLabel.font = [UIFont fontWithName:@"Muli-Light"
                                               size:14.0f];
    [self.containerView addSubview:self.alertTextLabel];
    
    // Set up view separator
    self.separator = [UIView new];
    self.separator.backgroundColor = UIColor.darkGreyTextColor;
    self.separator.translatesAutoresizingMaskIntoConstraints = NO;
    [self.containerView addSubview:self.separator];
    
    self.closeButton = [UIButton new];
    [self.closeButton setTitle:@"✕"
                      forState:UIControlStateNormal];
    self.closeButton.translatesAutoresizingMaskIntoConstraints = false;
    [self.closeButton addTarget:self
                         action:@selector(hide)
               forControlEvents:UIControlEventTouchUpInside];
    [self.containerView addSubview:self.closeButton];
}

- (void)setBannerComponentConstraints {
    // Compute top offset
    CGFloat topOffset = 0;
    UINavigationBar *navigationBar = self.parentViewController.navigationController.navigationBar;

    BOOL assessForNavigationBar = NO;
    
    if (!navigationBar) {
        assessForNavigationBar = YES;
    } else {
        assessForNavigationBar = navigationBar.isHidden;
    }
    
    if (assessForNavigationBar) {
        topOffset += kVerticalPadding;
        
        if ([self isNotchPresent]) {
            topOffset += kNotchVerticalPadding;
        }
    }
    
    // Container view constraints
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[containerView]|"
                                                                 options:kNilOptions
                                                                 metrics:nil
                                                                   views:@{@"containerView" : self.containerView}]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(topOffset)-[containerView]|"
                                                                 options:kNilOptions
                                                                 metrics:@{@"topOffset" : @(topOffset)}
                                                                   views:@{@"containerView" : self.containerView}]];
    
    // Alert image view size constraints
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat: @"V:[alertImageView(rectangleSize)]"
                                                                 options: kNilOptions
                                                                 metrics: @{@"rectangleSize"  : @(kAlertImageViewRectangleSize)}
                                                                   views: @{@"alertImageView" : self.alertImageView}]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat: @"H:[alertImageView(rectangleSize)]"
                                                                 options: kNilOptions
                                                                 metrics: @{@"rectangleSize"  : @(kAlertImageViewRectangleSize)}
                                                                   views: @{@"alertImageView" : self.alertImageView}]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat: @"H:[superview]-(<=1)-[alertImageView]"
                                                                 options: NSLayoutFormatAlignAllCenterY
                                                                 metrics: nil
                                                                   views: @{@"superview"      : self.containerView,
                                                                            @"alertImageView" : self.alertImageView}]];
    
    // Separator constraints
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat: @"H:[separator(1)]"
                                                                 options: kNilOptions
                                                                 metrics: nil
                                                                   views: @{@"separator" : self.separator}]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat: @"V:|-(8)-[separator]-(8)-|"
                                                                 options: kNilOptions
                                                                 metrics: nil
                                                                   views: @{@"separator" : self.separator}]];
    
    // Close button constraints
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat: @"V:[closeButton(rectangleSize)]"
                                                                 options: kNilOptions
                                                                 metrics: @{@"rectangleSize": @(kCloseButtonRectangleSize)}
                                                                   views: @{@"closeButton"  : self.closeButton}]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat: @"H:[closeButton(rectangleSize)]"
                                                                 options: kNilOptions
                                                                 metrics: @{@"rectangleSize" : @(kCloseButtonRectangleSize)}
                                                                   views: @{@"closeButton"   : self.closeButton}]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat: @"H:[superview]-(<=1)-[closeButton]"
                                                                 options: NSLayoutFormatAlignAllCenterY
                                                                 metrics: nil
                                                                   views: @{@"superview"    : self.containerView,
                                                                            @"closeButton"  : self.closeButton}]];
    
    // Layout constraints
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat: @"H:|-(imageViewPadding)-[alertImageView]-(imageViewPadding)-[separator]-(horizontalPadding)-[alertTitle]-[closeButton]-|"
                                                                 options: kNilOptions
                                                                 metrics: @{@"horizontalPadding" : @(kHorizontalPadding),
                                                                            @"imageViewPadding"  : @(kHorizontalImageViewPadding)}
                                                                   views: @{@"alertImageView"    : self.alertImageView,
                                                                            @"separator"         : self.separator,
                                                                            @"alertTitle"        : self.alertTitleLabel,
                                                                            @"closeButton"       : self.closeButton}]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat: @"H:[separator]-(horizontalPadding)-[alertText]-[closeButton]-|"
                                                                 options: kNilOptions
                                                                 metrics: @{@"horizontalPadding" : @(kHorizontalPadding)}
                                                                   views: @{@"separator"         : self.separator,
                                                                            @"alertText"         : self.alertTextLabel,
                                                                            @"closeButton"       : self.closeButton}]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat: @"V:|-(2)-[alertTitle]-(4)-[alertText]-|"
                                                                 options: kNilOptions
                                                                 metrics: nil
                                                                   views: @{@"alertTitle"  : self.alertTitleLabel,
                                                                            @"alertText"   : self.alertTextLabel}]];
}

- (void)updateUI {
    [self updateConstraintsIfNeeded];
    [self layoutIfNeeded];
    
    [self setNeedsUpdateConstraints];
}

- (void)updateAlertStyleAndText {
    // Set up background and text color based on the style of the alert
    UIColor *backgroundColor = nil;
    UIImage *alertImage = nil;
    
    if (AFABannerAlertStyleWarning == self.alertStyle) {
        backgroundColor = [UIColor connectivityWarningColor];
        alertImage = [UIImage imageNamed:@"warning-icon"];
    } else if (AFABannerAlertStyleError == self.alertStyle) {
        backgroundColor = [UIColor alertWithErrorColor];
        alertImage = [UIImage imageNamed:@"error-icon"];
    } else if (AFABannerAlertStyleSuccess == self.alertStyle) {
        backgroundColor = [UIColor connectivityRestoredColor];
        alertImage = [UIImage imageNamed:@"notice-icon"];
    }
    
    self.backgroundColor = backgroundColor;
    self.alertImageView.image = alertImage;
    self.alertTextLabel.textColor = [UIColor whiteColor];
    self.alertTextLabel.text = self.alertText;
    self.alertTitleLabel.text = self.alertTitle;
}

- (void)show {
    if (!self.hasSetConstraints) {
        [self setBannerComponentConstraints];
        self.hasSetConstraints = YES;
    }
    
    _isBannerVisible = YES;
    
    UINavigationBar *navigationBar = self.parentViewController.navigationController.navigationBar;
    if (navigationBar && !navigationBar.isHidden) {
        [navigationBar.superview insertSubview:self
                                  belowSubview:navigationBar];
    } else {
        [self.parentViewController.view addSubview:self];
    }
    
    if (!self.superview) {
        return;
    }
    
    NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[banner]|"
                                                                             options:kNilOptions
                                                                             metrics:nil
                                                                               views:@{@"banner": self}];
    NSArray *topConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[banner]"
                                                                      options:kNilOptions
                                                                      metrics:nil
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

- (void)hide:(BOOL)animated {
    [self hideWithCompletionBlock:nil
                         animated:NO];
}

- (void)hideWithCompletionBlock:(AFANavigationBarBannerAlertHideCompletionBlock)hideCompletionBlock
                       animated:(BOOL)animated {
    if (self.hideTimer) {
        [self.hideTimer invalidate];
        self.hideTimer = nil;
    }
    
    _isBannerVisible = NO;
    
    [self updateUI];
    
    self.transform = CGAffineTransformMakeTranslation(0, self.frame.size.height);
    
    if (animated) {
        [UIView animateWithDuration:kDefaultAnimationTime animations:^{
            self.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
            if (hideCompletionBlock) {
                hideCompletionBlock();
            }
        }];
    } else {
        [self removeFromSuperview];
        if (hideCompletionBlock) {
            hideCompletionBlock();
        }
    }
}

- (void)hide {
    [self hideWithCompletionBlock:nil
                         animated:YES];
}

- (void)showAndHideWithTimeout:(NSTimeInterval)timeout {
    [self show];
    
    self.hideTimer = [NSTimer scheduledTimerWithTimeInterval:timeout
                                                      target:self
                                                    selector:@selector(hide)
                                                    userInfo:nil
                                                     repeats:NO];
}

- (void)showWithText:(NSString *)alertText
               title:(NSString *)alertTitle
               style:(AFABannerAlertStyle)alertStyle {
    _alertText = alertText;
    _alertTitle = alertTitle;
    _alertStyle = alertStyle;
    
    if (self.isBannerVisible) {
        __weak typeof(self) weakSelf = self;
        [self hideWithCompletionBlock:^{
            __strong typeof(self) strongSelf = weakSelf;
            [strongSelf show];
        } animated:YES];
    } else {
        [self show];
    }
}

- (BOOL)isNotchPresent {
    return UIApplication.sharedApplication.keyWindow.safeAreaInsets.bottom > 0 && UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone;
}

@end

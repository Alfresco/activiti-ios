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

#import "AFABaseSliderViewController.h"
#import "UIView+AFAImageEffects.h"
#import "AFAUIConstants.h"

@interface AFABaseSliderViewController ()

@property (strong, nonatomic) UIImageView   *menuBlurImageView;

@end

@implementation AFABaseSliderViewController

- (void)viewDidLoad {
    UISwipeGestureRecognizer *slideOpenGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                                     action:@selector(handleSwipeAction:)];
    UISwipeGestureRecognizer *slideCloseGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                                      action:@selector(handleSwipeAction:)];
    slideOpenGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    slideCloseGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:slideOpenGestureRecognizer];
    [self.view addGestureRecognizer:slideCloseGestureRecognizer];
    
    [super viewDidLoad];
}


#pragma mark -
#pragma mark Actions

- (void)toggleMenu:(id)sender {
    [self toggleMenuBlur];
    
    if ([self.delegate respondsToSelector:@selector(toggleDrawerMenuWithThemeColor:)]) {
        [self.delegate toggleDrawerMenuWithThemeColor:self.navigationBarThemeColor];
    }
}

- (void)handleSwipeAction:(UISwipeGestureRecognizer *)gestureRecognizer {
    // Only handle swipe actions for root controllers
    if (self == self.navigationController.viewControllers.firstObject) {
        BOOL performToggle = NO;
        switch (gestureRecognizer.direction) {
            case UISwipeGestureRecognizerDirectionRight: {
                if ([self.delegate respondsToSelector:@selector(isDrawerMenuOpen)]) {
                    if (![self.delegate isDrawerMenuOpen]) {
                        performToggle = YES;
                    }
                }
            }
                break;
                
            case UISwipeGestureRecognizerDirectionLeft: {
                if ([self.delegate respondsToSelector:@selector(isDrawerMenuOpen)]) {
                    if ([self.delegate isDrawerMenuOpen]) {
                        performToggle = YES;
                    }
                }
            }
                break;
                
            default:
                break;
        }
        
        if (performToggle) {
            [self toggleMenu:nil];
        }
    }
}


#pragma mark -
#pragma mark Content blur

- (void)toggleMenuBlur {
    if (!self.menuBlurImageView) {
        self.menuBlurImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        self.menuBlurImageView.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                               action:@selector(toggleMenu:)];
        [self.menuBlurImageView addGestureRecognizer:tapGestureRecognizer];
    }
    
    if (!self.menuBlurImageView.image) {
        self.menuBlurImageView.image = [self.view blurredSnapshot];
    }
    self.isSlided = self.menuBlurImageView.superview ? NO : YES;
    
    if (!self.menuBlurImageView.superview) {
        [self.view addSubview:self.menuBlurImageView];
        self.menuBlurImageView.alpha = .0f;
        [UIView animateWithDuration:kDefaultAnimationTime
                         animations:^{
                             self.menuBlurImageView.alpha = 1.0f;
                         }];
    } else {
        [UIView animateWithDuration:kOverlayAlphaChangeTime
                         animations:^{
                             self.menuBlurImageView.alpha = .0f;
                         } completion:^(BOOL finished) {
                             [self.menuBlurImageView removeFromSuperview];
                             self.menuBlurImageView.image = nil;
                         }];
    }
}

@end

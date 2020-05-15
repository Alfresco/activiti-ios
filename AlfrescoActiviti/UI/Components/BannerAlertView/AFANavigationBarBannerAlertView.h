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

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, AFABannerAlertStyle) {
    AFABannerAlertStyleUndefined = -1,
    AFABannerAlertStyleError     = 0,
    AFABannerAlertStyleWarning   = 1,
    AFABannerAlertStyleSuccess   = 2
};

@interface AFANavigationBarBannerAlertView : UIView

@property (strong, nonatomic, readonly) NSString            *alertText;
@property (strong, nonatomic, readonly) NSString            *alertTitle;
@property (assign, nonatomic, readonly) AFABannerAlertStyle alertStyle;
@property (assign, nonatomic, readonly) BOOL                isBannerVisible;

+ (instancetype)showAlertWithText:(NSString *)alertText
                            title:(NSString *)alertTitle
                            style:(AFABannerAlertStyle)alertStyle
                 inViewController:(UIViewController *)viewController;

- (instancetype)initWithAlertText:(NSString *)alertText
                            title:(NSString *)alertTitle
                       alertStyle:(AFABannerAlertStyle)alertStyle
             parentViewController:(UIViewController *)parentViewController;

- (instancetype)initWithParentViewController:(UIViewController *)parentViewController;

- (void)show;
- (void)hide;
- (void)hide:(BOOL)animated;
- (void)showAndHideWithTimeout:(NSTimeInterval)timeout;
- (void)showWithText:(NSString *)alertText
               title:(NSString *)alertTitle
               style:(AFABannerAlertStyle)alertStyle;

@end

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

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, AFABannerAlertStyle) {
    AFABannerAlertStyleUndefined = -1,
    AFABannerAlertStyleError     = 0,
    AFABannerAlertStyleWarning   = 1
};

@interface AFANavigationBarBannerAlertView : UIView

@property (strong, nonatomic, readonly) NSString            *alertText;
@property (assign, nonatomic, readonly) AFABannerAlertStyle alertStyle;
@property (assign, nonatomic, readonly) BOOL                isBannerVisible;

- (instancetype)initWithFrame:(CGRect)frame
                    alertText:(NSString *)alertText
                   alertStyle:(AFABannerAlertStyle)alertStyle
         parentViewController:(UIViewController *)parentViewController;

+ (instancetype)showAlertWithText:(NSString *)alertText
                            style:(AFABannerAlertStyle)alertStyle
                 inViewController:(UIViewController *)viewController;

- (void)show;
- (void)hide;
- (void)showAndHideWithTimeout:(NSTimeInterval)timeout;

@end

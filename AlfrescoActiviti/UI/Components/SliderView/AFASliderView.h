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

@class AFASliderView;
@protocol AFASliderViewDelegate <NSObject>

- (void)slider:(AFASliderView *)slider didSelectOptionAtIndex:(NSInteger)index;

@end

@interface AFASliderView : UIView

@property (weak, nonatomic)   id<AFASliderViewDelegate>     delegate;
@property (strong, nonatomic) NSArray                       *bulletStringTitles;
@property (strong, nonatomic) NSString                      *sliderButtonTitle;
@property (strong, nonatomic) UIColor                       *generalTintColor;
@property (strong, nonatomic) UIColor                       *sliderButtonFillColor;

- (void)setupAndLayout;

@end

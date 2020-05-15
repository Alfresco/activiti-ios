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

typedef NS_ENUM(NSInteger, AFASwitchViewOnOffLabelPosition) {
    AFASwitchViewOnOffLabelPositionCenter = 0,
    AFASwitchViewOnOffLabelPositionMargin
};

IB_DESIGNABLE
@interface AFASwitchView : UIView

@property (assign, nonatomic) BOOL isOn;
@property (assign, nonatomic) AFASwitchViewOnOffLabelPosition onOffLabelPosition;

@property (strong, nonatomic) IBInspectable UIColor *backgroundViewColor;
@property (assign, nonatomic) IBInspectable CGFloat backgroundViewCornerRadius;
@property (strong, nonatomic) IBInspectable UIColor *buttonViewColor;
@property (assign, nonatomic) IBInspectable CGFloat buttonViewCornerRadius;
@property (strong, nonatomic) IBInspectable UIColor *onLabelTextColor;
@property (strong, nonatomic) IBInspectable UIColor *offLabelTextColor;
@property (strong, nonatomic) IBInspectable UIColor *descriptionTextColor;
@property (strong, nonatomic) IBInspectable UIColor *descriptionBackgroundColor;

@property (strong, nonatomic) NSString *onLabelText;
@property (strong, nonatomic) NSString *offLabelText;
@property (strong, nonatomic) NSString *switchDescriptionText;


@end

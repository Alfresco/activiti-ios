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
@import ActivitiSDK;

@protocol AFACompleteTableViewCellDelegate <NSObject>

- (void)onCompleteTask;
- (void)onRequeueTask;

@end

@interface AFACompleteTableViewCell : UITableViewCell

@property (weak, nonatomic) id<AFACompleteTableViewCellDelegate> delegate;

@property (weak, nonatomic) IBOutlet ASDKRoundedBorderView  *completeTaskRoundedBorderView;
@property (weak, nonatomic) IBOutlet UIButton               *completeTaskButton;
@property (weak, nonatomic) IBOutlet ASDKRoundedBorderView  *requeueRoundedBorderView;
@property (weak, nonatomic) IBOutlet UIButton               *requeueTaskButton;

- (void)setUpWithThemeColor:(UIColor *)themeColor;
- (void)updateStateForConnectivity:(BOOL)isConnectivityAvailable;

@end

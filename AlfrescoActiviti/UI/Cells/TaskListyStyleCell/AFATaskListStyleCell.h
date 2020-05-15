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

@class ASDKModelTask, ASDKModelProcessInstance;

@interface AFATaskListStyleCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView      *hairlineLeadingView;
@property (weak, nonatomic) IBOutlet UILabel     *taskNameLabel;
@property (weak, nonatomic) IBOutlet UILabel     *taskDescriptionLabel;
@property (weak, nonatomic) IBOutlet UIImageView *creationDateIconImageView;
@property (weak, nonatomic) IBOutlet UIImageView *dueDateIconImageView;
@property (weak, nonatomic) IBOutlet UILabel     *creationDateLabel;
@property (weak, nonatomic) IBOutlet UILabel     *dueDateLabel;
@property (strong, nonatomic) UIColor            *applicationThemeColor;

- (void)setupWithTask:(ASDKModelTask *)task;
- (void)setupWithProcessInstance:(ASDKModelProcessInstance *)processInstance;

@end

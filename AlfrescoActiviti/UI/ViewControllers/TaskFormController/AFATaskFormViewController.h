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

@class ASDKModelTask, ASDKFormRenderEngine;

@protocol AFATaskFormViewControllerDelegate <NSObject>

- (void)formDidLoadWithError:(NSError *)error;
- (void)formDidLoadPrerequisitesWithError:(NSError *)error;
- (void)userDidCompleteForm;
- (void)presentFormDetailController:(UIViewController *)controller;
- (UINavigationController *)formNavigationController;

@optional
- (void)formDidStartedLoadingPrerequisites;

@end

@interface AFATaskFormViewController : ASDKReachabilityViewController

@property (weak, nonatomic) id<AFATaskFormViewControllerDelegate>   delegate;
@property (strong, nonatomic) ASDKFormRenderEngine                  *taskFormRenderEngine;

- (void)formForTask:(ASDKModelTask *)task;
- (void)saveForm;

@end

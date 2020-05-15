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

#import "AFANavigationControllerDelegate.h"

// Animators
#import "AFAPushFadeAnimator.h"
#import "AFAPopFadeAnimator.h"

@interface AFANavigationControllerDelegate ()

@property (strong, nonatomic) AFAPushFadeAnimator *pushAnimator;
@property (strong, nonatomic) AFAPopFadeAnimator *popAnimator;

@end

@implementation AFANavigationControllerDelegate

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.pushAnimator = [AFAPushFadeAnimator new];
    self.popAnimator = [AFAPopFadeAnimator new];
}

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                  animationControllerForOperation:(UINavigationControllerOperation)operation
                                               fromViewController:(UIViewController *)fromVC
                                                 toViewController:(UIViewController *)toVC {
    if (UINavigationControllerOperationPush == operation) {
        return self.pushAnimator;
    } else if (UINavigationControllerOperationPop) {
        return self.popAnimator;
    }

    return nil;
}

@end

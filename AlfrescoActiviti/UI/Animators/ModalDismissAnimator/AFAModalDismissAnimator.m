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

#import "AFAModalDismissAnimator.h"
#import "AFAUIConstants.h"
#import "UIView+AFAViewAnimations.h"

@implementation AFAModalDismissAnimator

- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext {
    return kModalReplaceAnimationTime;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *containerView = transitionContext.containerView;
    
    CGRect initialFrame = [transitionContext initialFrameForViewController:fromVC];
    CGRect finalFrame = [transitionContext finalFrameForViewController:toVC];
    finalFrame.origin.y = CGRectGetHeight(initialFrame);
    
    // Origin view controller snapshot
    UIView *fromVCSnapshotView = [fromVC.view snapshotViewFromCurrentView];
    fromVCSnapshotView.frame = initialFrame;
    
    // Destination view controller snapshot
    UIView *toVCSnapshotView = [toVC.view snapshotViewFromCurrentView];
    toVCSnapshotView.frame = initialFrame;
    
    // Populate the container view with snapshots and the actual destination view
    [containerView addSubview:toVC.view];
    [containerView addSubview:toVCSnapshotView];
    [containerView addSubview:fromVCSnapshotView];
    fromVC.view.hidden = YES;
    toVC.view.hidden = YES;
    
    CFTimeInterval duration = [self transitionDuration:transitionContext];
    
    CATransform3D scale = CATransform3DIdentity;
    toVCSnapshotView.layer.transform = CATransform3DScale(scale, .6f, .6f, 1.0f);
    toVCSnapshotView.alpha = .0f;
    
    CATransform3D t1 = [self scaleRotateTransform];
    
    [UIView animateKeyframesWithDuration:duration
                                   delay:.0f
                                 options:UIViewKeyframeAnimationOptionCalculationModeLinear
                              animations:^{
                                  [UIView addKeyframeWithRelativeStartTime:.0f
                                                          relativeDuration:1/3.0f
                                                                animations:^{
                                                                    fromVCSnapshotView.frame = finalFrame;
                                                                }];
                                  [UIView addKeyframeWithRelativeStartTime:1/3.0f
                                                          relativeDuration:1/3.0f
                                                                animations:^{
                                                                    toVCSnapshotView.layer.transform = t1;
                                                                    toVCSnapshotView.alpha = 1.0f;
                                                                }];
                                  [UIView addKeyframeWithRelativeStartTime:2/3.0f
                                                          relativeDuration:1/3.0f
                                                                animations:^{
                                                                    toVCSnapshotView.layer.transform = CATransform3DIdentity;
                                                                }];
                              } completion:^(BOOL finished) {
                                  fromVC.view.hidden = NO;
                                  toVC.view.hidden = NO;
                                  [toVCSnapshotView removeFromSuperview];
                                  [fromVCSnapshotView removeFromSuperview];
                                  [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
                              }];
}

- (CATransform3D)scaleRotateTransform {
    CATransform3D t1 = CATransform3DIdentity;
    t1.m34 = 1.0 / -900;
    t1 = CATransform3DScale(t1, .95, .95, 1);
    t1 = CATransform3DRotate(t1, 15.0f * M_PI / 180.0f, 1, 0, 0);
    
    return t1;
}

@end

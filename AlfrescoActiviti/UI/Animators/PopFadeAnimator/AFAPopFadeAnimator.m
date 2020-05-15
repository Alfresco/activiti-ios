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

#import "AFAPopFadeAnimator.h"
#import "AFAUIConstants.h"
#import "UIView+AFAViewAnimations.h"

@implementation AFAPopFadeAnimator

- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext {
    return kPushPopAnimationTime;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *containerView = transitionContext.containerView;
    
    CGRect initialFrame = [transitionContext initialFrameForViewController:fromVC];
    CGRect finalFrame = [transitionContext finalFrameForViewController:toVC];
    
    // Destination view controller snapshot
    UIView *toVCSnapshotView = [toVC.view snapshotViewFromCurrentViewsLayer];
    CGRect toOffScreenFrame = finalFrame;
    toOffScreenFrame.origin.x = - CGRectGetWidth(finalFrame) / 4;
    toVCSnapshotView.frame = toOffScreenFrame;
    
    toVCSnapshotView.layer.shadowColor = [UIColor blackColor].CGColor;
    toVCSnapshotView.layer.shadowOffset = CGSizeMake(5.0f,5.0f);
    toVCSnapshotView.layer.shadowOpacity = .5f;
    toVCSnapshotView.layer.shadowRadius = 5.0f;
    
    // Origin view controller snapshot
    UIView *fromVCSnapshotView = [fromVC.view snapshotViewFromCurrentViewsLayer];
    fromVCSnapshotView.frame = initialFrame;
    
    CGRect offScreenFrame = initialFrame;
    offScreenFrame.origin.x = CGRectGetWidth(initialFrame);
    
    // Populate the container view with snapshots and the actual destination view
    [containerView addSubview:toVC.view];
    [containerView addSubview:toVCSnapshotView];
    [containerView addSubview:fromVCSnapshotView];
    fromVC.view.hidden = YES;
    toVC.view.hidden = YES;
    
    CFTimeInterval duration = [self transitionDuration:transitionContext];
    
    CATransform3D t1 = [self scaleAndPushTransform];
    CATransform3D t2 = [self scaleAndPullTransform];
    
    toVCSnapshotView.layer.transform = t1;
    
    [UIView animateKeyframesWithDuration:duration
                                   delay:0.0
                                 options:UIViewKeyframeAnimationOptionCalculationModeLinear
                              animations:^{
                                  [UIView addKeyframeWithRelativeStartTime:.0f
                                                          relativeDuration:1/3.0f
                                                                animations:^{
                                                                    toVCSnapshotView.layer.transform = t2;
                                                                }];
                                  [UIView addKeyframeWithRelativeStartTime:.0f
                                                          relativeDuration:1.0f
                                                                animations:^{
                                                                    fromVCSnapshotView.frame = offScreenFrame;
                                                                }];
                                  [UIView addKeyframeWithRelativeStartTime:.0f
                                                          relativeDuration:1.0f
                                                                animations:^{
                                                                    toVCSnapshotView.frame = finalFrame;
                                                                }];
                              } completion:^(BOOL finished) {
                                  toVC.view.hidden = NO;
                                  fromVC.view.hidden = NO;
                                  [fromVCSnapshotView removeFromSuperview];
                                  [toVCSnapshotView removeFromSuperview];
                                  [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
                              }];
}

- (CATransform3D)scaleAndPushTransform {
    CATransform3D t1 = CATransform3DIdentity;
    t1 = CATransform3DScale(t1, 0.95f, 0.95f, 1);
    t1 = CATransform3DTranslate(t1, 0, -0.1, 0);
    
    return t1;
}

- (CATransform3D)scaleAndPullTransform {
    CATransform3D t1 = CATransform3DIdentity;
    t1 = CATransform3DScale(t1, 1.0f, 1.0f, 1);
    t1 = CATransform3DTranslate(t1, 0, -0.05, 0);
    
    return t1;
}

@end

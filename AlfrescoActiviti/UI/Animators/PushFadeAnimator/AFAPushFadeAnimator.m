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

#import "AFAPushFadeAnimator.h"
#import "AFAUIConstants.h"
#import "UIView+AFAViewAnimations.h"

@implementation AFAPushFadeAnimator

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
    CGRect offScreenFrame = finalFrame;
    offScreenFrame.origin.x = CGRectGetWidth(finalFrame);
    toVCSnapshotView.frame = offScreenFrame;
    
    // Origin view controller snapshot
    UIView *fromVCSnapshotView = [fromVC.view snapshotViewFromCurrentViewsLayer];
    fromVCSnapshotView.frame = initialFrame;
    fromVCSnapshotView.layer.shadowColor = [UIColor blackColor].CGColor;
    fromVCSnapshotView.layer.shadowOffset = CGSizeMake(5.0f,5.0f);
    fromVCSnapshotView.layer.shadowOpacity = .5f;
    fromVCSnapshotView.layer.shadowRadius = 5.0f;
    
    // Populate the container view with snapshots and the actual destination view
    [containerView addSubview:fromVCSnapshotView];
    [containerView addSubview:toVC.view];
    [containerView addSubview:toVCSnapshotView];
    fromVC.view.hidden = YES;
    toVC.view.hidden = YES;
    
    CFTimeInterval duration = [self transitionDuration:transitionContext];
    
    CATransform3D t1 = [self scaleTranslateTransform];
    
    [UIView animateKeyframesWithDuration:duration
                                   delay:.0f
                                 options:UIViewKeyframeAnimationOptionCalculationModeLinear
                              animations:^{
                                  [UIView addKeyframeWithRelativeStartTime:.0f
                                                          relativeDuration:1/3.0f
                                                                animations:^{
                                                                    fromVCSnapshotView.layer.transform = t1;
                                                                }];
                                  [UIView addKeyframeWithRelativeStartTime:.0f
                                                          relativeDuration:1.0f
                                                                animations:^{
                                                                    toVCSnapshotView.frame = finalFrame;
                                                                }];
                                  [UIView addKeyframeWithRelativeStartTime:.0f
                                                          relativeDuration:1.0f
                                                                animations:^{
                                                                    CGRect fromOffScreenFrame = fromVCSnapshotView.frame;
                                                                    fromOffScreenFrame.origin.x = - CGRectGetWidth(fromVCSnapshotView.frame) / 4;
                                                                    fromVCSnapshotView.frame = fromOffScreenFrame;
                                                                }];
                              } completion:^(BOOL finished) {
                                  toVC.view.frame = finalFrame;
                                  fromVC.view.hidden = NO;
                                  toVC.view.hidden = NO;
                                  [fromVCSnapshotView removeFromSuperview];
                                  [toVCSnapshotView removeFromSuperview];
                                  [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
                              }];
}

- (CATransform3D)scaleTranslateTransform {
    CATransform3D t1 = CATransform3DIdentity;
    t1 = CATransform3DScale(t1, 0.95f, 0.95f, 1);
    t1 = CATransform3DTranslate(t1, 0, -0.1, 0);
    
    return t1;
}

@end

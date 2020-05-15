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
 ******************************************************************************///

#import "AFAModalReplaceAnimator.h"
#import "AFAUIConstants.h"
#import "UIView+AFAViewAnimations.h"

@implementation AFAModalReplaceAnimator

- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext {
    return kModalReplaceAnimationTime;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *containerView = transitionContext.containerView;
    
    CGRect initialFrame = [transitionContext initialFrameForViewController:fromVC];
    CGRect finalFrame = [transitionContext finalFrameForViewController:toVC];

    // Destination view controller snapshot
    UIView *toVCSnapshotView = [toVC.view snapshotViewFromCurrentView];
    CGRect offScreenFrame = initialFrame;
    offScreenFrame.origin.y = CGRectGetHeight(initialFrame);
    toVCSnapshotView.frame = offScreenFrame;
    
    // Origin view controller snapshot
    UIView *fromVCSnapshotView = [fromVC.view snapshotViewFromCurrentView];
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
    
    // Animate the transforms on the snapshots
    CATransform3D t1 = [self scaleRotateTransform];
    CATransform3D t2 = [self translateScaleTransformWithView:fromVCSnapshotView];
    
    [UIView animateKeyframesWithDuration:duration
                                   delay:.0f
                                 options:UIViewKeyframeAnimationOptionCalculationModeLinear
                              animations:^{
                                  [UIView addKeyframeWithRelativeStartTime:0.0f
                                                          relativeDuration:1/3.0f
                                                                animations:^{
                                                                    fromVCSnapshotView.layer.transform = t1;
                                                                    fromVCSnapshotView.alpha = 0.6;
                                                                }];
                                  
                                  [UIView addKeyframeWithRelativeStartTime:1/3.0f
                                                          relativeDuration:1/3.0f
                                                                animations:^{
                                                                    fromVCSnapshotView.layer.transform = t2;
                                                                }];
                                  
                                  [UIView addKeyframeWithRelativeStartTime:2/3.0f
                                                          relativeDuration:1/3.0f
                                                                animations:^{
                                                                    toVCSnapshotView.frame = finalFrame;
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
    t1 = CATransform3DScale(t1, 0.95, 0.95, 1);
    t1 = CATransform3DRotate(t1, 15.0f * M_PI / 180.0f, 1, 0, 0);
    
    return t1;
}

- (CATransform3D)translateScaleTransformWithView:(UIView*)view {
    CATransform3D t2 = CATransform3DIdentity;
    t2.m34 = [self scaleRotateTransform].m34;
    t2 = CATransform3DTranslate(t2, 0, view.frame.size.height * -0.08, 0);
    t2 = CATransform3DScale(t2, 0.8, 0.8, 1);
    
    return t2;
}

@end

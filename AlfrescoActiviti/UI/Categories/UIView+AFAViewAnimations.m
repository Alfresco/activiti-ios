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

#import "UIView+AFAViewAnimations.h"

@implementation UIView (AFAViewAnimations)

- (void)animateAlpha:(CGFloat)alpha
        withDuration:(NSTimeInterval)duration
 withCompletionBlock:(AFAAnimationCompletionBlock)completionBlock {
    [UIView animateViewsFromArray:@[self]
                        withAlpha:alpha
                     withDuration:duration
              withCompletionBlock:completionBlock];
}

+ (void)animateViewsFromArray:(NSArray *)viewsArray
                    withAlpha:(CGFloat)alpha
                 withDuration:(NSTimeInterval)duration
          withCompletionBlock:(AFAAnimationCompletionBlock)completionBlock {
    NSParameterAssert(duration > .0f);
    NSParameterAssert(alpha >= .0f && alpha <= 1.0f);
    
    [UIView animateWithDuration:duration
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         for (UIView *view in viewsArray) {
                             view.alpha = alpha;
                         }
                     } completion:^(BOOL finished) {
                         if (completionBlock) {
                             completionBlock(YES);
                         }
                     }];
}

- (UIView *)snapshotViewFromCurrentView {
    CGRect bounds = self.bounds;
    
    UIGraphicsBeginImageContextWithOptions(bounds.size, NO, [UIScreen mainScreen].scale);
    [self drawViewHierarchyInRect:bounds
               afterScreenUpdates:YES];
    UIImage *snapshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImageView *snapshotImageView = [[UIImageView alloc] initWithImage:snapshot];
    UIView *snapshotView = [[UIView alloc] init];
    [snapshotView addSubview:snapshotImageView];
    
    return snapshotView;
}

- (UIView *)snapshotViewFromCurrentViewsLayer {
    CGRect bounds = self.layer.bounds;
    
    UIGraphicsBeginImageContextWithOptions(bounds.size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSaveGState(context);
    [self.layer renderInContext:context];
    CGContextRestoreGState(context);
    
    UIImage *snapshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImageView *snapshotImageView = [[UIImageView alloc] initWithImage:snapshot];
    UIView *snapshotView = [[UIView alloc] init];
    snapshotView.backgroundColor = [UIColor whiteColor];
    [snapshotView addSubview:snapshotImageView];
    
    return snapshotView;
}

@end

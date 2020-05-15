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

#import "AFAFadingTableView.h"

@implementation AFAFadingTableView


#pragma mark -
#pragma mark UI customizations

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (!self.layer.mask) {
        CAGradientLayer *maskLayer = [CAGradientLayer layer];
        
        maskLayer.locations = @[@(0.0),
                                @(0.2),
                                @(0.8),
                                @(1.0)];
        maskLayer.bounds = CGRectMake(0, 0,
                                      self.frame.size.width,
                                      self.frame.size.height);
        maskLayer.anchorPoint = CGPointZero;
        
        self.layer.mask = maskLayer;
    }
    
    [self scrollViewDidScroll:self];
}


#pragma mark -
#pragma mark UIScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGColorRef outerColor = [UIColor colorWithWhite:1.0
                                              alpha:0.0].CGColor;
    CGColorRef innerColor = [UIColor colorWithWhite:1.0
                                              alpha:1.0].CGColor;
    NSArray *colors = nil;
    
    if (scrollView.contentOffset.y + scrollView.contentInset.top <= 0) {
        //Top of scrollView
        colors = @[(__bridge id)innerColor, (__bridge id)innerColor,
                   (__bridge id)innerColor, (__bridge id)outerColor];
    } else if (scrollView.contentOffset.y + scrollView.frame.size.height >=
               scrollView.contentSize.height) {
        //Bottom of tableView
        colors = @[(__bridge id)outerColor, (__bridge id)innerColor,
                   (__bridge id)innerColor, (__bridge id)innerColor];
    } else {
        //Middle
        colors = @[(__bridge id)outerColor, (__bridge id)innerColor,
                   (__bridge id)innerColor, (__bridge id)outerColor];
    }
    ((CAGradientLayer *)scrollView.layer.mask).colors = colors;
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    scrollView.layer.mask.position = CGPointMake(0, scrollView.contentOffset.y);
    [CATransaction commit];
}

@end

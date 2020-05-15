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

#import "ASDKActivityView.h"

CGFloat const titleScale           = .85f;

@interface ASDKActivityView ()

@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UIView *outerCircleView;
@property (strong, nonatomic) UIView *innerCircleView;
@property (strong, nonatomic) CAShapeLayer *outerCircle;
@property (strong, nonatomic) CAShapeLayer *innerCircle;
@property (assign, nonatomic) CGFloat currentOuterRotation;
@property (assign, nonatomic) CGFloat currentInnerRotation;
@end

@implementation ASDKActivityView


#pragma mark -
#pragma mark Life cycle

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        self.outerCircle = [CAShapeLayer layer];
        self.innerCircle = [CAShapeLayer layer];
        self.currentInnerRotation = .1f;
    }
    
    return self;
}


- (void)drawRect:(CGRect)rect {
    
    // Configure outer circle
    self.outerCircleView = [[UIView alloc] initWithFrame:self.bounds];
    self.outerCircle.path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(.0f, .0f, self.bounds.size.width, self.bounds.size.height)].CGPath;
    self.outerCircle.lineWidth = self.outerCircleLineWidth;
    self.outerCircle.lineCap = kCALineCapRound;
    self.outerCircle.fillColor = UIColor.clearColor.CGColor;
    self.outerCircle.strokeColor = self.outerCircleColor.CGColor;
    [self.outerCircleView.layer addSublayer:self.outerCircle];
    
    [self addSubview:self.outerCircleView];
    
    // Configure inner circle
    self.innerCircleView = [[UIView alloc] initWithFrame:self.bounds];
    self.innerCircle.path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(self.innerCirclePadding, self.innerCirclePadding, self.bounds.size.width - 2 * self.innerCirclePadding, self.bounds.size.height - 2 * self.innerCirclePadding)].CGPath;
    self.innerCircle.lineWidth = self.innerCircleLineWidht;
    self.innerCircle.lineCap = kCALineCapRound;
    self.innerCircle.fillColor = UIColor.clearColor.CGColor;
    self.innerCircle.strokeColor = self.innerCircleColor.CGColor;
    [self.innerCircleView.layer addSublayer:self.innerCircle];
    
    [self addSubview:self.innerCircleView];
    
    // Configure description label
    CGFloat contentWidth = self.innerCirclePadding + self.outerCircleLineWidth + self.innerCircleLineWidht;
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(contentWidth, self.bounds.origin.y / 2.0f + 10 , self.bounds.size.width * titleScale - contentWidth, self.bounds.size.height * titleScale)];
    self.titleLabel.font = [UIFont systemFontOfSize:15];
    self.titleLabel.text = self.descriptionText;
    self.titleLabel.textColor = self.descriptionTextColor;
    self.titleLabel.numberOfLines = 0;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.titleLabel.adjustsFontSizeToFitWidth = YES;
    
    [self addSubview:self.titleLabel];
}


#pragma mark -
#pragma mark Setters & Getters

- (void)setAnimating:(BOOL)animating {
    if (animating != _animating) {
        _animating = animating;
        
        if (_animating) {
            self.outerCircle.strokeStart = .0f;
            self.outerCircle.strokeEnd = .45f;
            self.innerCircle.strokeStart = .5f;
            self.innerCircle.strokeEnd = .9f;
            
            [self spinOuterCircle];
            [self spinInnerCircle];
        } else {
            self.outerCircle.strokeStart = .0;
            self.outerCircle.strokeEnd = 1.0f;
            self.innerCircle.strokeStart = .0f;
            self.innerCircle.strokeEnd = 1.0f;
        }
    }
}


#pragma mark -
#pragma mark Animations

- (void)spinOuterCircle {
    NSTimeInterval duration = 1.0f;
    double randomRotation = (arc4random() / UINT32_MAX) * M_PI_4 + M_PI_4;
    
    [UIView animateWithDuration:duration
                          delay:.0f
         usingSpringWithDamping:.4f
          initialSpringVelocity:.0f
                        options:0
                     animations:^{
                         self.currentOuterRotation -= randomRotation;
                         self.outerCircleView.transform = CGAffineTransformMakeRotation(self.currentOuterRotation);
                     } completion:^(BOOL finished) {
                         CGFloat waitDuration = .4f;
                         
                         __weak typeof(self) weakSelf = self;
                         dispatch_after(dispatch_time(DISPATCH_TIME_NOW, waitDuration * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                             __strong typeof(self) strongSelf = weakSelf;
                             if (strongSelf.animating) {
                                 [strongSelf spinOuterCircle];
                             }
                         });
                     }];
}

- (void)spinInnerCircle {
    [UIView animateWithDuration:.5f
                          delay:.0f
         usingSpringWithDamping:.5f
          initialSpringVelocity:.0f
                        options:0
                     animations:^{
                         self.currentInnerRotation += M_PI_4;
                         self.innerCircleView.transform = CGAffineTransformMakeRotation(self.currentInnerRotation);
                     } completion:^(BOOL finished) {
                         __weak typeof(self) weakSelf = self;
                         dispatch_after(dispatch_time(DISPATCH_TIME_NOW, .2f * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                             __strong typeof(self) strongSelf = weakSelf;
                             
                             if (strongSelf.animating) {
                                 [strongSelf spinInnerCircle];
                             }
                         });
                     }];
}

@end

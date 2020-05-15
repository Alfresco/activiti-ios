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

#import "ASDKFormCheckbox.h"

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

CGFloat const finalStrokeEndForCheckmark = .85f;
CGFloat const finalStrokeStartForCheckmark = .3f;
CGFloat const checkmarkBounceAmount = .1f;
NSTimeInterval const animationDuration = .3f;

@interface ASDKFormCheckbox ()

@property (strong, nonatomic) CAShapeLayer *trailCircle;
@property (strong, nonatomic) CAShapeLayer *circle;
@property (strong, nonatomic) CAShapeLayer *checkmark;
@property (assign, nonatomic) CGPoint checkmarkMidPoint;
@property (assign, nonatomic) BOOL selectedInternal;

@end

@implementation ASDKFormCheckbox


#pragma mark -
#pragma mark Life cycle

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        self.trailCircle = [CAShapeLayer layer];
        self.circle = [CAShapeLayer layer];
        self.checkmark = [CAShapeLayer layer];
        
        self.selected = NO;
        self.selectedInternal = NO;
        
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
        
        [self addTarget:self
                 action:@selector(onTouchUpInside:)
       forControlEvents:UIControlEventTouchUpInside];
    }
    
    return self;
}

- (void)setSelected:(BOOL)selected
           animated:(BOOL)animated {
    [super setSelected:selected];
    
    self.selectedInternal = selected;
    
    [self.checkmark removeAllAnimations];
    [self.circle removeAllAnimations];
    [self.trailCircle removeAllAnimations];
    
    [self resetValuesAnimated:animated];
    
    if (animated) {
        [self addAnimationForSelected:self.selectedInternal];
    }
}

- (void)setSelected:(BOOL)selected {
    [self setSelected:selected
             animated:NO];
}

- (BOOL)isSelected {
    return _selectedInternal;
}


- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self configureShapeLayer:self.trailCircle];
    [self configureShapeLayer:self.circle];
    [self configureShapeLayer:self.checkmark];
}

- (void)drawRect:(CGRect)rect {
    [self.backgroundColor setFill];
    UIRectFill([self bounds]);
}


#pragma mark - 
#pragma mark Setters

- (void)setTrailStrokeColor:(UIColor *)trailStrokeColor {
    self.trailCircle.strokeColor = trailStrokeColor.CGColor;
}

- (void)setStrokeColor:(UIColor *)strokeColor {
    self.circle.strokeColor = strokeColor.CGColor;
    self.checkmark.strokeColor = strokeColor.CGColor;
}


#pragma mark -
#pragma mark Actions

- (void)onTouchUpInside:(id)sender {
    [self willChangeValueForKey:@"selected"];
    [self setSelected:!self.selected
             animated:YES];
    [self didChangeValueForKey:@"selected"];
    
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}


#pragma mark -
#pragma mark Private interface

- (void)resetValuesAnimated:(BOOL)animated {
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    
    if ((self.selectedInternal && animated) ||
        (!self.selectedInternal && !animated)) {
        self.checkmark.strokeEnd = 0.0;
        self.checkmark.strokeStart = 0.0;
        self.trailCircle.opacity = 0.0;
        self.circle.strokeStart = 0.0;
        self.circle.strokeEnd = 1.0;
    } else {
        self.checkmark.strokeEnd = finalStrokeEndForCheckmark;
        self.checkmark.strokeStart = finalStrokeStartForCheckmark;
        self.trailCircle.opacity = 1.0;
        self.circle.strokeStart = 0.0;
        self.circle.strokeEnd = 0.0;
    }
    
    [CATransaction commit];
}


#pragma mark -
#pragma mark Drawing

- (void)configureShapeLayer:(CAShapeLayer *)shapeLayer {
    shapeLayer.lineJoin = kCALineJoinRound;
    shapeLayer.lineCap = kCALineCapRound;
    shapeLayer.lineWidth = self.lineWidth;
    shapeLayer.fillColor = UIColor.clearColor.CGColor;
    [self.layer addSublayer:shapeLayer];
}

- (void)layoutSublayersOfLayer:(CALayer *)layer {
    [super layoutSublayersOfLayer:layer];
    
    if (layer == self.layer) {
        CGPoint offset = CGPointZero;
        CGFloat radius = fminf(self.bounds.size.width, self.bounds.size.height) / 2.0f;
        offset.x = (self.bounds.size.width - radius * 2) / 2.0;
        offset.y = (self.bounds.size.height - radius * 2) / 2.0;
        
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        
        CGRect ovalRect = CGRectMake(offset.x, offset.y, radius * 2.0f, radius * 2.0f);
        self.trailCircle.path = [UIBezierPath bezierPathWithOvalInRect:ovalRect].CGPath;
        
        self.circle.transform = CATransform3DIdentity;
        self.circle.frame = self.bounds;
        self.circle.path = [UIBezierPath bezierPathWithOvalInRect:ovalRect].CGPath;
        self.circle.transform = CATransform3DMakeRotation(212.0f * M_PI / 180.0f, 0, 0, 1);
        
        CGPoint origin = CGPointMake(offset.x + radius, offset.y + radius);
        CGPoint checkStartPoint = CGPointZero;
        checkStartPoint.x = origin.x + radius * cos(212.0f * M_PI / 180.0f);
        checkStartPoint.y = origin.y + radius * sin(212.0f * M_PI / 180.0f);
        
        UIBezierPath *checkmarkPath = [UIBezierPath bezierPath];
        [checkmarkPath moveToPoint:checkStartPoint];
        
        self.checkmarkMidPoint = CGPointMake(offset.x + radius * .9f, offset.y + radius * 1.4f);
        [checkmarkPath addLineToPoint:self.checkmarkMidPoint];
        
        CGPoint checkEndPoint = CGPointZero;
        checkEndPoint.x = origin.x + radius * cos(320.0f * M_PI / 180.0f);
        checkEndPoint.y = origin.y + radius * sin(320.0f * M_PI / 180.0f);
        
        [checkmarkPath addLineToPoint:checkEndPoint];
        
        self.checkmark.frame = self.bounds;
        self.checkmark.path = checkmarkPath.CGPath;
        
        [CATransaction commit];
    }
}

- (void)addAnimationForSelected:(BOOL)selected {
    NSTimeInterval circleAnimationDuration = animationDuration * .5f;
    NSTimeInterval checkMarkEndDuration = animationDuration * .8f;
    
    NSTimeInterval checkMarkStartDuration = checkMarkEndDuration - circleAnimationDuration;
    NSTimeInterval checkMarkBounceDuration = animationDuration - checkMarkEndDuration;
    
    CAAnimationGroup *checkMarkAnimationGroup = [CAAnimationGroup animation];
    checkMarkAnimationGroup.removedOnCompletion = NO;
    checkMarkAnimationGroup.fillMode = kCAFillModeForwards;
    checkMarkAnimationGroup.duration = animationDuration;
    checkMarkAnimationGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    
    CAKeyframeAnimation *checkMarkStrokeEnd = [CAKeyframeAnimation animationWithKeyPath:@"strokeEnd"];
    checkMarkStrokeEnd.duration = checkMarkEndDuration + checkMarkBounceDuration;
    checkMarkStrokeEnd.removedOnCompletion = NO;
    checkMarkStrokeEnd.fillMode = kCAFillModeForwards;
    checkMarkStrokeEnd.calculationMode = kCAAnimationPaced;
    
    if (self.selected) {
        checkMarkStrokeEnd.values = @[@(.0f), @(finalStrokeEndForCheckmark + checkmarkBounceAmount), @(finalStrokeEndForCheckmark)];
        checkMarkStrokeEnd.keyTimes = @[@(.0f), @(checkMarkEndDuration), @(checkMarkEndDuration + checkMarkBounceDuration)];
    } else {
        checkMarkStrokeEnd.values = @[@(finalStrokeEndForCheckmark), @(finalStrokeEndForCheckmark + checkmarkBounceAmount), @(-.1f)];
        checkMarkStrokeEnd.keyTimes = @[@(.0f), @(checkMarkBounceDuration), @(checkMarkEndDuration + checkMarkBounceDuration)];
    }
    
    CAKeyframeAnimation *checkMarkStrokeStart = [CAKeyframeAnimation animationWithKeyPath:@"strokeStart"];
    checkMarkStrokeStart.duration = checkMarkStartDuration + checkMarkBounceDuration;
    checkMarkStrokeStart.removedOnCompletion = NO;
    checkMarkStrokeStart.fillMode = kCAFillModeForwards;
    checkMarkStrokeStart.calculationMode = kCAAnimationPaced;
    
    if (self.selected) {
        checkMarkStrokeStart.values = @[@(.0f), @(finalStrokeStartForCheckmark + checkmarkBounceAmount), @(finalStrokeStartForCheckmark)];
        checkMarkStrokeStart.keyTimes = @[@(.0f), @(checkMarkStartDuration), @(checkMarkStartDuration + checkMarkBounceDuration)];
        checkMarkStrokeStart.beginTime = circleAnimationDuration;
    } else {
        checkMarkStrokeStart.values = @[@(finalStrokeStartForCheckmark), @(finalStrokeStartForCheckmark + checkmarkBounceAmount), @(.0f)];
        checkMarkStrokeStart.keyTimes = @[@(.0f), @(checkMarkBounceDuration), @(checkMarkStartDuration + checkMarkBounceDuration)];
    }
    
    checkMarkAnimationGroup.animations = @[checkMarkStrokeEnd, checkMarkStrokeStart];
    [self.checkmark addAnimation:checkMarkAnimationGroup
                          forKey:@"checkMarkAnimation"];
    
    
    CAAnimationGroup *circleAnimationGroup = [CAAnimationGroup animation];
    circleAnimationGroup.duration = animationDuration;
    circleAnimationGroup.removedOnCompletion = NO;
    circleAnimationGroup.fillMode = kCAFillModeForwards;
    circleAnimationGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    
    CABasicAnimation *circleStrokeEnd = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    circleStrokeEnd.duration = circleAnimationDuration;
    
    if (self.selected) {
        circleStrokeEnd.beginTime = .0f;
        circleStrokeEnd.fromValue = @(1.0f);
        circleStrokeEnd.toValue = @(-.1f);
    } else {
        circleStrokeEnd.beginTime = animationDuration - circleAnimationDuration;
        
        circleStrokeEnd.fromValue = @(.0f);
        circleStrokeEnd.toValue = @(1.0f);
    }
    circleStrokeEnd.removedOnCompletion = NO;
    circleStrokeEnd.fillMode = kCAFillModeForwards;
    
    circleAnimationGroup.animations = @[circleStrokeEnd];
    [self.circle addAnimation:circleAnimationGroup
                       forKey:@"circleStrokeEnd"];
    
    
    CABasicAnimation *trailCircleColor = [CABasicAnimation animationWithKeyPath:@"opacity"];
    trailCircleColor.duration = animationDuration;
    
    if (self.selected) {
        trailCircleColor.fromValue = @(.0f);
        trailCircleColor.toValue = @(1.0f);
    } else {
        trailCircleColor.fromValue = @(1.0f);
        trailCircleColor.toValue = @(.0f);
    }
    trailCircleColor.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    trailCircleColor.fillMode = kCAFillModeForwards;
    trailCircleColor.removedOnCompletion = NO;
    
    [self.trailCircle addAnimation:trailCircleColor
                            forKey:@"trailCircleColor"];
}

@end

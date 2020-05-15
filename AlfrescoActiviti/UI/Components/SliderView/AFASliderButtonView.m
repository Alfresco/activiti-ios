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

#import "AFASliderButtonView.h"

static const CGFloat kAFASliderButtonPadding = 4.0f;

@interface AFASliderButtonView ()

@property (assign, nonatomic) CGPoint touchStartPoint;

@end

@implementation AFASliderButtonView


#pragma mark -
#pragma mark Drawing

- (void)drawRect:(CGRect)rect {
    [self.buttonFillColor set];
    UIBezierPath *background = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(rect, 3.0f, 3.0f)
                                                          cornerRadius:20];
    [background fill];
    
    if (self.buttonTitleString) {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSTextAlignmentCenter;
        [self.buttonTitleString drawInRect:CGRectOffset(rect, 0, kAFASliderButtonPadding)
                            withAttributes:@{NSParagraphStyleAttributeName : paragraphStyle,
                                             NSFontAttributeName           : [UIFont fontWithName:@"Avenir-Book"
                                                                                             size:10.0f],
                                             NSForegroundColorAttributeName: [UIColor whiteColor]}];
    }
    
    if (self.isHighlighted) {
        [[UIColor colorWithWhite:.0f
                           alpha:.1f] set];
        UIBezierPath * outline = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(rect, 1.0f, 1.0f)
                                                            cornerRadius:20];
        [outline stroke];
    }
}


#pragma Mark -
#pragma Mark - Touch Response

- (void)touchesBegan:(NSSet *)touches
           withEvent:(UIEvent *)event {
    [super touchesBegan:touches
              withEvent:event];
    
    if ([self.delegate respondsToSelector:@selector(buttonIsHighlighted:)]) {
        [self.delegate buttonIsHighlighted:YES];
    }
    
    self.isHighlighted = YES;
    [self setNeedsDisplay];
}

- (void)touchesMoved:(NSSet *)touches
           withEvent:(UIEvent *)event {
    [super touchesMoved:touches
              withEvent:event];
    CGPoint touchPoint = [self touchPoint:touches];
    CGPoint centerPoint = CGPointMake(touchPoint.x - self.touchStartPoint.x, self.center.y);
    
    if ([self.delegate respondsToSelector:@selector(updateButtonCenterPosition:)]) {
        [self.delegate updateButtonCenterPosition:centerPoint];
    }
}

- (void)touchesCancelled:(NSSet *)touches
               withEvent:(UIEvent *)event {
    [super touchesCancelled:touches
                  withEvent:event];
    
    if ([self.delegate respondsToSelector:@selector(buttonIsHighlighted:)]) {
        [self.delegate buttonIsHighlighted:NO];
    }
    
    self.isHighlighted = NO;
    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches
           withEvent:(UIEvent *)event {
    [super touchesEnded:touches
              withEvent:event];
    
    if ([self.delegate respondsToSelector:@selector(buttonIsHighlighted:)]) {
        [self.delegate buttonIsHighlighted:NO];
    }
    
    if ([self.delegate respondsToSelector:@selector(buttonDragHasEnded:)]) {
        CGPoint touchPoint = [self touchPoint:touches];
        CGPoint centerPoint = CGPointMake(touchPoint.x - self.touchStartPoint.x, self.center.y);
        
        [self.delegate buttonDragHasEnded:centerPoint];
    }
    
    self.isHighlighted = NO;
    [self setNeedsDisplay];
}


#pragma Mark -
#pragma Mark - Convenience Methods

- (CGPoint)touchPoint:(NSSet *)touches; {
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self.superview];
    return touchPoint;
}

@end

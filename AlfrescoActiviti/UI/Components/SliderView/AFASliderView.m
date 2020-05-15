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

#import "AFASliderView.h"
#import "AFASliderTrackView.h"
#import "AFASliderButtonView.h"
#import "AFASliderTitleView.h"
#import "AFAUIConstants.h"
#import "AFALogConfiguration.h"

static const int activitiLogLevel = AFA_LOG_LEVEL_VERBOSE; // | AFA_LOG_FLAG_TRACE;

@interface AFASliderView () <AFASliderButtonViewDelegate, AFASliderTrackViewDelegate>

@property (strong, nonatomic) AFASliderTrackView *trackView;
@property (strong, nonatomic) AFASliderButtonView *buttonView;
@end

@implementation AFASliderView


#pragma mark - 
#pragma mark Life cycle

- (void)setupAndLayout {
    if (!self.bulletStringTitles.count) {
        AFALogError(@"Cannot initialize the slider view (%@) without any defined title options.", self.sliderButtonTitle);
        return;
    }
    
    [self layoutIfNeeded];
    
    // Set up and add the track view
    if (self.trackView.superview) {
        [self.trackView removeFromSuperview];
    }
    
    self.trackView = [[AFASliderTrackView alloc] initWithFrame:self.bounds];
    self.trackView.backgroundColor = [UIColor clearColor];
    self.trackView.trackItemsCount = self.bulletStringTitles.count;
    self.trackView.bulletTitles = self.bulletStringTitles;
    self.trackView.titleColor = self.generalTintColor;
    self.trackView.delegate = self;
    [self addSubview:self.trackView];
    
    // Set up and add the button view
    if (self.buttonView.superview) {
        [self.buttonView removeFromSuperview];
    }
    
    self.buttonView = [[AFASliderButtonView alloc] initWithFrame:CGRectInset(self.bounds, 100, CGRectGetHeight(self.bounds) / 2.9)];
    self.buttonView.backgroundColor = [UIColor clearColor];
    self.buttonView.buttonFillColor = self.sliderButtonFillColor;
    self.buttonView.buttonTitleString = self.sliderButtonTitle;
    self.buttonView.delegate = self;
    [self addSubview:self.buttonView];
}


#pragma mark -
#pragma mark AFASliderTrackView Delegate

- (void)handleNeutralPositionAfterFirstDrawingForPoint:(CGPoint)neutralPoint {
    self.buttonView.center = neutralPoint;
}

#pragma mark -
#pragma mark AFASliderButtonView Delegate

- (void)updateButtonCenterPosition:(CGPoint)point {
    CGFloat trackHighCenter = [self trackHighCenter];
    CGFloat trackLowCenter = [self trackLowCenter];
    
    if (point.x > trackHighCenter) {
        self.buttonView.center = CGPointMake(trackHighCenter, point.y);
        return;
    }
    
    if (point.x < trackLowCenter) {
        self.buttonView.center = CGPointMake(trackLowCenter, point.y);
        return;
    }
    
    self.buttonView.center = point;
}

- (void)buttonIsHighlighted:(BOOL)isHighlighted {
    self.trackView.isHighlighted = isHighlighted;
    [self.trackView setNeedsDisplay];
}

- (void)buttonDragHasEnded:(CGPoint)point {
    CGFloat smallestDistance = [self distanceFromPoint:[self.trackView.trackBulletsCoordinates.firstObject CGPointValue]
                                               toPoint:point];
    NSInteger smallestDistanceIdx = 0;
    for (NSInteger trackBulletIdx = 1; trackBulletIdx < self.trackView.trackBulletsCoordinates.count; trackBulletIdx++) {
        CGFloat pointDistance = [self distanceFromPoint:[self.trackView.trackBulletsCoordinates[trackBulletIdx] CGPointValue]
                                                toPoint:point];
        
        if (pointDistance < smallestDistance) {
            smallestDistance = pointDistance;
            smallestDistanceIdx = trackBulletIdx;
        }
    }
    
    [UIView animateWithDuration:kDefaultAnimationTime
                          delay:.0f
         usingSpringWithDamping:.9f
          initialSpringVelocity:3.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.buttonView.center = [self.trackView.trackBulletsCoordinates[smallestDistanceIdx] CGPointValue];
    } completion:^(BOOL finished) {
        if ([self.delegate respondsToSelector:@selector(slider:didSelectOptionAtIndex:)]) {
            [self.delegate slider:self didSelectOptionAtIndex:smallestDistanceIdx];
        }
    }];
}


#pragma mark -
#pragma mark Convenience methods

- (CGFloat)trackLowCenter {
    return (CGRectGetWidth(self.buttonView.frame) / 2.0f - 5.0f);
}

- (CGFloat)trackHighCenter {
    return self.bounds.size.width - (CGRectGetWidth(self.buttonView.frame) / 2.0f - 5.0f);
}

- (CGFloat) distanceFromPoint:(CGPoint)p1 toPoint:(CGPoint)p2 {
    return sqrt(pow(p2.x-p1.x,2)+pow(p2.y-p1.y,2));
}

@end

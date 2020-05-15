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

#import "AFASliderTrackView.h"
#import "AFASliderTitleView.h"

static const CGFloat kAFASliderTrackBulletRadius = 5.0f;
static const CGFloat kAFASliderBulletTitleOffsetY = 20.0f;

@interface AFASliderTrackView ()

@property (assign, nonatomic) BOOL reportNeutralPointAfterDrawing;

@end

@implementation AFASliderTrackView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.trackBulletsCoordinates = [NSMutableArray array];
        self.bulletTitleView = [[AFASliderTitleView alloc] initWithFrame:self.bounds];
        self.bulletTitleView.opaque = NO;
        self.bulletTitleView.backgroundColor = [UIColor clearColor];
        self.reportNeutralPointAfterDrawing = YES;
        [self addSubview:self.bulletTitleView];
    }
    
    return self;
}

- (void)drawRect:(CGRect)rect {
    [[UIColor colorWithWhite:0.
                       alpha:0.1] set];
    
    
    if (!self.isHighlighted) {
        // Draw track path
        CGRect trackRect = CGRectMake(0, self.center.y, self.bounds.size.width, 1.0f);
        UIBezierPath *trachPath = [UIBezierPath bezierPathWithRoundedRect:trackRect
                                                             cornerRadius:2.0f];
        [trachPath fill];
    }
    
    // Compute bullet spacing
    CGFloat trackItemBulletCoordY = 0;
    
    if (self.trackItemsCount - 1 <= 0) {
        trackItemBulletCoordY = CGRectGetWidth(self.bounds);
    } else {
        trackItemBulletCoordY = CGRectGetWidth(self.bounds) / (self.trackItemsCount - 1) - (kAFASliderTrackBulletRadius / (self.trackItemsCount - 1));
    }
    
    [self.trackBulletsCoordinates removeAllObjects];
    
    if (self.isHighlighted ||
        self.reportNeutralPointAfterDrawing) {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSTextAlignmentCenter;
        NSDictionary *titleAttributes = @{NSParagraphStyleAttributeName : paragraphStyle,
                                          NSFontAttributeName           : [UIFont fontWithName:@"Avenir-Book"
                                                                                          size:12.0f],
                                          NSForegroundColorAttributeName: self.titleColor};
        NSMutableArray *titlesCenterRectValues = [NSMutableArray array];
        NSMutableArray *attributedStringTitles = [NSMutableArray array];
        
        for (int trackIdx = 0; trackIdx < self.trackItemsCount; trackIdx++) {
            // Draw bullet points
            CGFloat trackItemCoordX = trackIdx * trackItemBulletCoordY;
            
            [self.trackBulletsCoordinates addObject:[NSValue valueWithCGPoint:CGPointMake(trackItemCoordX, self.center.y)]];
            
            CGRect bulletRect = CGRectMake(trackItemCoordX,
                                           self.center.y - kAFASliderTrackBulletRadius / 2 + .5f,
                                           kAFASliderTrackBulletRadius,
                                           kAFASliderTrackBulletRadius);
            UIBezierPath *trackItemBulletPath = [UIBezierPath bezierPathWithOvalInRect:bulletRect];
            [trackItemBulletPath fill];
            
            // Draw in-between lines
            UIBezierPath *linePath = [UIBezierPath bezierPath];
            [linePath moveToPoint:CGPointMake(trackItemCoordX + kAFASliderTrackBulletRadius, self.center.y + .5f)];
            [linePath addLineToPoint:CGPointMake(trackItemCoordX + trackItemBulletCoordY, self.center.y + .5f)];
            [linePath stroke];
            
            // Draw string titles
            NSAttributedString *titleAttributedString = [[NSAttributedString alloc] initWithString:self.bulletTitles[trackIdx]
                                                                                        attributes:titleAttributes];
            [attributedStringTitles addObject:titleAttributedString];
            
            CGRect titleRect = CGRectMake(CGRectGetMidX(trackItemBulletPath.bounds) - titleAttributedString.size.width / 2.0f, bulletRect.origin.y - titleAttributedString.size.height - kAFASliderBulletTitleOffsetY, titleAttributedString.size.width, titleAttributedString.size.height);
            
            [titlesCenterRectValues addObject:[NSValue valueWithCGRect:titleRect]];
        }
        
        [self.bulletTitleView displayTitles:attributedStringTitles
                             forCoordinates:titlesCenterRectValues
                             withAttributes:titleAttributes];
        
        if (self.reportNeutralPointAfterDrawing) {
            if ([self.delegate respondsToSelector:@selector(handleNeutralPositionAfterFirstDrawingForPoint:)]) {
                [self.delegate handleNeutralPositionAfterFirstDrawingForPoint:[self.trackBulletsCoordinates.firstObject CGPointValue]];
            }
            
            self.reportNeutralPointAfterDrawing = NO;
        }
    }
}

@end

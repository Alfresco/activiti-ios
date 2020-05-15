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

#import <UIKit/UIKit.h>

@class AFASliderTitleView;

@protocol AFASliderTrackViewDelegate <NSObject>

- (void)handleNeutralPositionAfterFirstDrawingForPoint:(CGPoint)neutralPoint;

@end

@interface AFASliderTrackView : UIView

@property (weak, nonatomic)   id<AFASliderTrackViewDelegate> delegate;
@property (assign, nonatomic) NSInteger                      trackItemsCount;
@property (assign, nonatomic) BOOL                           isHighlighted;
@property (strong, nonatomic) NSMutableArray                 *trackBulletsCoordinates;
@property (strong, nonatomic) NSArray                        *bulletTitles;
@property (strong, nonatomic) AFASliderTitleView             *bulletTitleView;
@property (strong, nonatomic) UIColor                        *titleColor;

@end

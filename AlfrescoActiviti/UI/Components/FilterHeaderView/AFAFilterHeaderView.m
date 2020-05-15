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

#import "AFAFilterHeaderView.h"

// Constants
#import "AFALocalizationConstants.h"

// Categories
@import ActivitiSDK;
#import "UIColor+AFATheme.h"

@interface AFAFilterHeaderView ()

@property (strong, nonatomic) UILabel   *headerIconLabel;
@property (strong, nonatomic) UILabel   *headerTitleLabel;
@property (strong, nonatomic) UIButton  *clearAllButton;

@end

@implementation AFAFilterHeaderView

- (instancetype)initWithReuseIdentifier:(nullable NSString *)reuseIdentifier {
    self = [super initWithReuseIdentifier:reuseIdentifier];
    
    if (self) {
        CGFloat headerViewColor = 234 / 255.0f;
        self.backgroundColor = [UIColor colorWithRed:headerViewColor
                                               green:headerViewColor
                                                blue:headerViewColor
                                               alpha:1.0f];
        
        // Set header icon label
        _headerIconLabel = [UILabel new];
        _headerIconLabel.font = [UIFont glyphiconFontWithSize:17];
        _headerIconLabel.text = [NSString iconStringForIconType:ASDKGlyphIconTypeFilter];
        _headerIconLabel.textColor = [UIColor darkGreyTextColor];
        _headerIconLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_headerIconLabel];
        
        // Set header title label
        _headerTitleLabel = [UILabel new];
        _headerTitleLabel.font = [UIFont fontWithName:@"Avenir-Book"
                                                 size:12.0f];
        _headerTitleLabel.textAlignment = NSTextAlignmentLeft;
        _headerTitleLabel.textColor = [UIColor darkGreyTextColor];
        _headerTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_headerTitleLabel];
        
        // Set up clear all button
        _clearAllButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _clearAllButton.titleLabel.font = [UIFont fontWithName:@"Avenir-Heavy"
                                                          size:12];
        _clearAllButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [_clearAllButton setTitle:NSLocalizedString(kLocalizationListScreenClearAllButtonTitleText, @"Clear all")
                         forState:UIControlStateNormal];
        [_clearAllButton setTitleColor:[UIColor darkGreyTextColor]
                              forState:UIControlStateNormal];
        [_clearAllButton addTarget:self
                            action:@selector(onClear:)
                  forControlEvents:UIControlEventTouchUpInside];
        _clearAllButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_clearAllButton];
        
        // Set up header icon constraints
        [_headerIconLabel setContentHuggingPriority:UILayoutPriorityDefaultHigh
                                            forAxis:UILayoutConstraintAxisHorizontal];
        NSLayoutConstraint *headerIconLabelCenterYConstraint =
        [NSLayoutConstraint constraintWithItem:_headerIconLabel
                                     attribute:NSLayoutAttributeCenterY
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self
                                     attribute:NSLayoutAttributeCenterY
                                    multiplier:1.0
                                      constant:0];
        
        NSLayoutConstraint *headerIcontLabelLeadingConstraint =
        [NSLayoutConstraint constraintWithItem:_headerIconLabel
                                     attribute:NSLayoutAttributeLeading
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self
                                     attribute:NSLayoutAttributeLeading
                                    multiplier:1.0
                                      constant:10];
        headerIconLabelCenterYConstraint.active = YES;
        headerIcontLabelLeadingConstraint.active = YES;
        
        // Set up header title constraints
        NSLayoutConstraint *headerTitleLabelLeadingConstraint =
        [NSLayoutConstraint constraintWithItem:_headerTitleLabel
                                     attribute:NSLayoutAttributeLeading
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:_headerIconLabel
                                     attribute:NSLayoutAttributeTrailing
                                    multiplier:1.0
                                      constant:8];
        
        NSLayoutConstraint *headerTitleLabelCenterYConstraint =
        [NSLayoutConstraint constraintWithItem:_headerTitleLabel
                                     attribute:NSLayoutAttributeCenterY
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self
                                     attribute:NSLayoutAttributeCenterY
                                    multiplier:1.0
                                      constant:0];
        headerTitleLabelLeadingConstraint.active = YES;
        headerTitleLabelCenterYConstraint.active = YES;
        
        // Set up header clear button constraints
        NSLayoutConstraint *clearAllButtonLeadingConstraint =
        [NSLayoutConstraint constraintWithItem:_clearAllButton
                                     attribute:NSLayoutAttributeLeading
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:_headerTitleLabel
                                     attribute:NSLayoutAttributeTrailing
                                    multiplier:1.0
                                      constant:8];
        NSLayoutConstraint *clearAllButtonTrailingConstraint =
        [NSLayoutConstraint constraintWithItem:_clearAllButton
                                     attribute:NSLayoutAttributeTrailing
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self
                                     attribute:NSLayoutAttributeTrailing
                                    multiplier:1.0
                                      constant:-8];
        NSLayoutConstraint *clearAllButtonCenterYConstraint =
        [NSLayoutConstraint constraintWithItem:_clearAllButton
                                     attribute:NSLayoutAttributeCenterY
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self
                                     attribute:NSLayoutAttributeCenterY
                                    multiplier:1.0
                                      constant:0];
        NSLayoutConstraint *clearAllButtonWidthConstraint =
        [NSLayoutConstraint constraintWithItem:_clearAllButton
                                     attribute:NSLayoutAttributeWidth
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:nil
                                     attribute:NSLayoutAttributeWidth
                                    multiplier:1.0
                                      constant:100];
        
        clearAllButtonLeadingConstraint.active = YES;
        clearAllButtonTrailingConstraint.active = YES;
        clearAllButtonCenterYConstraint.active = YES;
        clearAllButtonWidthConstraint.active = YES;
    }
    
    return self;
}


#pragma mark -
#pragma mark Public interface

- (void)setUpForFilterList {
    _headerTitleLabel.text = NSLocalizedString(kLocalizationListScreenFilterByText, @"Filter by");
    _clearAllButton.hidden = NO;
}

- (void)setUpForSortList {
    _headerTitleLabel.text = NSLocalizedString(kLocalizationListScreenSortByText, @"Sort by");
    _clearAllButton.hidden = YES;
}


#pragma mark -
#pragma mark Actions

- (IBAction)onClear:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(didClearAll:)]) {
        [self.delegate didClearAll:self];
    }
}


@end

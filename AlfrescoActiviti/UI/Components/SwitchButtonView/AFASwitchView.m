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

#import "AFASwitchView.h"

@interface AFASwitchView ()

@property (strong, nonatomic) UIView    *buttonView;
@property (strong, nonatomic) UIButton  *onButton;
@property (strong, nonatomic) UIButton  *offButton;
@property (strong, nonatomic) UILabel   *onLabel;
@property (strong, nonatomic) UILabel   *offLabel;
@property (strong, nonatomic) UIView    *backgroundView;
@property (strong, nonatomic) UILabel   *descriptionLabel;

@end

@implementation AFASwitchView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        // Setup background view
        _backgroundView = [[UIView alloc] init];
        _backgroundView.layer.cornerRadius = 4.0;
        [self addSubview:_backgroundView];
        
        // Setup button view
        _buttonView = [[UIView alloc] init];
        [self addSubview:_buttonView];
        
        // Setup toggle buttons
        _onButton = [[UIButton alloc] init];
        _onButton.backgroundColor = [UIColor clearColor];
        _onButton.enabled = YES;
        [_onButton addTarget:self
                      action:@selector(onToggle:)
            forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_onButton];
        
        _offButton = [[UIButton alloc] init];
        _offButton.backgroundColor = [UIColor clearColor];
        _offButton.enabled = NO;
        [_offButton addTarget:self
                       action:@selector(onToggle:)
             forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_offButton];
        
        // Setup ON / OFF labels
        NSTextAlignment onTextAlignment = (AFASwitchViewOnOffLabelPositionMargin == _onOffLabelPosition) ? NSTextAlignmentLeft : NSTextAlignmentCenter;
        NSTextAlignment offTextAlignment = (AFASwitchViewOnOffLabelPositionMargin == _onOffLabelPosition) ? NSTextAlignmentRight : NSTextAlignmentCenter;
        
        _onLabel = [[UILabel alloc] init];
        _onLabel.textAlignment = onTextAlignment;
        _onLabel.font = [UIFont boldSystemFontOfSize:15];
        [_onButton addSubview:_onLabel];
        
        _offLabel = [[UILabel alloc] init];
        _offLabel.textAlignment = offTextAlignment;
        _offLabel.font = [UIFont boldSystemFontOfSize:15];
        [_offButton addSubview:_offLabel];
        
        // Setup description label
        UIFont *descriptionTextFont = [UIFont systemFontOfSize:10];
        
        _descriptionLabel = [[UILabel alloc] init];
        _descriptionLabel.textAlignment = NSTextAlignmentCenter;
        _descriptionLabel.font = descriptionTextFont;
        _descriptionLabel.layer.cornerRadius = 5.0f;
        _descriptionLabel.clipsToBounds = YES;
        [self addSubview:_descriptionLabel];
    }
    
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _backgroundView.backgroundColor = _backgroundViewColor;
    _buttonView.backgroundColor = _buttonViewColor;
    _onLabel.textColor = _onLabelTextColor;
    _offLabel.textColor = _offLabelTextColor;
    _descriptionLabel.textColor = _descriptionTextColor;
    _descriptionLabel.backgroundColor = _descriptionBackgroundColor;
    _buttonView.layer.cornerRadius = _buttonViewCornerRadius;
    
#if TARGET_INTERFACE_BUILDER
    _onLabel.text = @"ON";
    _offLabel.text = @"OFF";
#else
    _onLabel.text = _onLabelText;
    _offLabel.text = _offLabelText;
    _descriptionLabel.text = _switchDescriptionText;
#endif
}

- (void)layoutSubviews {
    if (CGRectIsEmpty(_backgroundView.frame)) {
        _backgroundView.frame = self.bounds;
    }
    
    if (CGRectIsEmpty(_buttonView.frame)) {
        _buttonView.frame = CGRectMake(.0f, .0f, self.bounds.size.width / 2.0f, self.bounds.size.height);
    }
    
    if (CGRectIsEmpty(_onButton.frame)) {
        _onButton.frame = CGRectMake(self.bounds.size.width / 2.0f, .0f, self.bounds.size.width / 2.0f, self.bounds.size.height);
    }
    
    if (CGRectIsEmpty(_offButton.frame)) {
        _offButton.frame = CGRectMake(.0f, .0f, self.bounds.size.width / 2.0f, self.bounds.size.height);
    }
    
    CGFloat marginPadding = (AFASwitchViewOnOffLabelPositionMargin == self.onOffLabelPosition) ? 10.0f : .0f;
    if (CGRectIsEmpty(_onLabel.frame)) {
        _onLabel.frame = CGRectMake(marginPadding, (self.bounds.size.height / 2.0f) - 25, self.bounds.size.width / 2.0f, 50);
    }
    
    if (CGRectIsEmpty(_offLabel.frame)) {
        _offLabel.frame = CGRectMake(-marginPadding / 2.0f, (self.bounds.size.height / 2.0f) - 25, self.bounds.size.width / 2.0f, 50);
    }
    
    if (self.switchDescriptionText) {
        if (CGRectIsEmpty(_descriptionLabel.frame)) {
            CGFloat widthOfDescriptionText = [self widthOfString:_switchDescriptionText
                                                        withFont:_descriptionLabel.font];
            // Add extra padding
            widthOfDescriptionText += 10;
            _descriptionLabel.frame = CGRectMake((self.bounds.size.width / 2.0f) - (widthOfDescriptionText / 2.0f), (self.bounds.size.height / 2.0) - 10, widthOfDescriptionText, 20);
        }
    }
    
    if (_isOn) {
        // Perform a refresh for the initial state of the switch
        [self switchFromCurrentState:_isOn];
    }
}


#pragma mark -
#pragma mark Setters

- (void)setIsOn:(BOOL)isOn {
    if (isOn != _isOn) {
        _isOn = isOn;
        [self switchFromCurrentState:_isOn];
    }
}


#pragma mark -
#pragma mark Actions

- (void)onToggle:(UIButton *)sender {
    self.isOn = !self.isOn;
}


#pragma mark -
#pragma mark Animations

- (void)switchFromCurrentState:(BOOL)on {
    [UIView animateWithDuration:.4f
                          delay:.0f
         usingSpringWithDamping:.8f
          initialSpringVelocity:14.0f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         CGRect adjustedButtonViewFrame = self.buttonView.frame;
                         adjustedButtonViewFrame.origin.x += self.frame.size.width / 2.0f * (on ? 1 : -1);
                         
                         if (on) {
                             adjustedButtonViewFrame.origin.x += 1;
                             
                         }else {
                             adjustedButtonViewFrame.origin.x -= 1;
                         }
                         
                         self.buttonView.frame = adjustedButtonViewFrame;
                     } completion:nil];
    
    [self animateLabelText:self.offLabel
                   toColor:(on ? self.onLabelTextColor : self.offLabelTextColor)];
    [self animateLabelText:self.onLabel
                   toColor:(on ? self.offLabelTextColor : self.onLabelTextColor)];
    
    self.onButton.enabled = !on;
    self.offButton.enabled = on;
}

- (void)animateLabelText:(UILabel *)label
                 toColor:(UIColor *)color {
    [UIView transitionWithView:label
                      duration:.4f
                       options:UIViewAnimationOptionCurveEaseOut |
     UIViewAnimationOptionTransitionCrossDissolve |
     UIViewAnimationOptionBeginFromCurrentState
                    animations:^{
                        label.textColor = color;
                    } completion:nil];
    
}


#pragma mark -
#pragma mark Utilities

- (CGFloat)widthOfString:(NSString *)string
                withFont:(UIFont *)font {
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil];
    return [[[NSAttributedString alloc] initWithString:string
                                            attributes:attributes] size].width;
}

@end

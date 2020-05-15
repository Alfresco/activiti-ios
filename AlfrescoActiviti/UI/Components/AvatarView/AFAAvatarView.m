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

#import "AFAAvatarView.h"

@interface AFAAvatarView ()

@property (strong, nonatomic) UIImageView   *avatarImageView;
@property (strong, nonatomic) CAShapeLayer  *borderLayer;
@property (strong, nonatomic) CAShapeLayer  *imageMaskLayer;

@end

@implementation AFAAvatarView


#pragma mark -
#pragma mark Life cycle

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        self.borderLayer = [CAShapeLayer layer];
        self.borderLayer.contentsScale = 2.0f * [UIScreen mainScreen].scale;
        self.imageMaskLayer = [CAShapeLayer layer];
        
        self.avatarImageView = [UIImageView new];
        self.avatarImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.avatarImageView.layer.mask = self.imageMaskLayer;
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.borderLayer.strokeColor = self.borderColor.CGColor;
    
    if (![self.borderLayer superlayer]) {
        [self.layer addSublayer:self.borderLayer];
    }
    
    self.avatarImageView.frame = self.bounds;
    self.avatarImageView.image = self.profileImage;
    if (![self.avatarImageView superview]) {
        [self addSubview:self.avatarImageView];
    }
}

- (void)layoutSublayersOfLayer:(CALayer *)layer {
    [super layoutSublayersOfLayer:layer];
    
    CGFloat insetSize = self.borderWidth;
    CGRect rectInsets = CGRectInset(self.bounds, insetSize, insetSize);
    
    self.imageMaskLayer.path = [UIBezierPath bezierPathWithOvalInRect:rectInsets].CGPath;
    self.borderLayer.path = self.imageMaskLayer.path;
    self.borderLayer.frame = self.bounds;
}


#pragma mark -
#pragma mark Setters

- (void)setProfileImage:(UIImage *)profileImage {
    if (_profileImage != profileImage) {
        _profileImage = profileImage;
        
        [self setNeedsLayout];
    }
}

@end

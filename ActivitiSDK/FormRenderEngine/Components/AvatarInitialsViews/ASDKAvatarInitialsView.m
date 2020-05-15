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

#import "ASDKAvatarInitialsView.h"

static const NSInteger kAvatarInitialsComponentCount = 2;

@interface ASDKAvatarInitialsView ()

@property (strong, nonatomic) CAShapeLayer  *fillLayer;
@property (strong, nonatomic) UILabel       *initialsLabel;
@property (strong, nonatomic) NSString      *initialsString;

@end

@implementation ASDKAvatarInitialsView

#pragma mark -
#pragma mark Life cycle

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        self.fillLayer = [CAShapeLayer layer];
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (![self.fillLayer superlayer]) {
        self.fillLayer.path = [UIBezierPath bezierPathWithOvalInRect:self.bounds].CGPath;
        [self.layer addSublayer:self.fillLayer];
    }
    
    if (!self.initialsLabel.superview) {
        self.initialsLabel = [[UILabel alloc] initWithFrame:CGRectInset(self.bounds, 3, 3)];
        self.initialsLabel.font = [UIFont fontWithName:@"Avenir-Book "
                                                  size:10];
        self.initialsLabel.textAlignment = NSTextAlignmentCenter;
        self.initialsLabel.textColor = self.initialsColor;
        self.initialsLabel.text = self.initialsString;
        
        [self addSubview:self.initialsLabel];
    }
    
    self.fillLayer.fillColor = self.fillColor.CGColor;
}

#pragma mark -
#pragma mark Public interface

- (void)updateInitialsForName:(NSString *)fullNameString {
    NSArray *nameComponents = [fullNameString componentsSeparatedByString:@" "];
    NSMutableString *initialsString = [NSMutableString string];
    
    NSInteger initialsComponentCount =  (kAvatarInitialsComponentCount > nameComponents.count) ? nameComponents.count : kAvatarInitialsComponentCount;
    
    for (NSInteger componentIdx = 0; componentIdx < initialsComponentCount; componentIdx++) {
        [initialsString appendString:[[nameComponents[componentIdx] substringToIndex:1] uppercaseString]];
    }
    
    self.initialsString = initialsString;
    self.initialsLabel.text = self.initialsString;
}

@end

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

#import "AFASignInTableViewCell.h"
#import "AFAUIConstants.h"

@implementation AFASignInTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}


#pragma mark -
#pragma mark Public interface

- (void)shakeSignInButton {
    CABasicAnimation *shake = [CABasicAnimation animationWithKeyPath:@"position"];
    [shake setDuration:0.1];
    [shake setRepeatCount:2];
    [shake setAutoreverses:YES];
    [shake setFromValue:[NSValue valueWithCGPoint:
                         CGPointMake(self.signInButton.center.x - 10,self.signInButton.center.y)]];
    [shake setToValue:[NSValue valueWithCGPoint:
                       CGPointMake(self.signInButton.center.x + 10, self.signInButton.center.y)]];
    [self.signInButton.layer addAnimation:shake forKey:@"position"];
}

- (IBAction)onSignIn:(id)sender {
    if ([self.delegate respondsToSelector:@selector(onSignIn:fromCell:)]) {
        [self.delegate onSignIn:self
                       fromCell:self];
    }
}


@end

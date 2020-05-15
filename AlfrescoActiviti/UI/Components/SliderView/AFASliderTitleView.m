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

#import "AFASliderTitleView.h"

@interface AFASliderTitleView ()

@end

@implementation AFASliderTitleView

- (void)displayTitles:(NSArray *)bulletTitles
       forCoordinates:(NSArray *)coordinatesArr
       withAttributes:(NSDictionary *)attributes {
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    for (NSInteger bulletTitleIdx = 0; bulletTitleIdx < bulletTitles.count; bulletTitleIdx++) {
        CGRect titleRectValue = [coordinatesArr[bulletTitleIdx] CGRectValue];
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:titleRectValue];
        titleLabel.attributedText = bulletTitles[bulletTitleIdx];
        
        [self addSubview:titleLabel];
    }
}

@end

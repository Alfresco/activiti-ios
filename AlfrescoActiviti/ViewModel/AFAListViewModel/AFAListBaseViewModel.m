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

#import "AFAListBaseViewModel.h"

// Constants
#import "AFALocalizationConstants.h"

// Categories
#import "UIColor+AFATheme.h"

@implementation AFAListBaseViewModel


#pragma mark -
#pragma mark Public interface 

- (instancetype)initWithApplication:(ASDKModelApp *)application {
    self = [super init];
    if (self) {
        _application = application;
    }
    
    return self;
}

- (NSString *)navigationBarTitle {
    // Update navigation bar title according to the description of the app if there's
    // a defined one, otherwise this means we're displaying adhoc tasks
    NSString *barTitle = nil;
    if (!self.application) {
        barTitle = NSLocalizedString(kLocalizationListScreenTaskAppText, @"Adhoc tasks title");
    } else {
        barTitle = self.application.name;
    }
    
    return barTitle;
}

- (UIColor *)navigationBarThemeColor {
    // Update navigation bar theme color according to the description of the app
    // if there's a defined one, otherwise this means we're displaying adhoc tasks
    UIColor *barColor = nil;
    if (!self.application) {
        barColor = [UIColor applicationThemeDefaultColor];
    } else {
        barColor = [UIColor applicationColorForTheme:self.application.theme];
    }
    
    return barColor;
}

@end

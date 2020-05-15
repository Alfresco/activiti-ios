/*******************************************************************************
 * Copyright (C) 2005-2020 Alfresco Software Limited.
 *
 * This file is part of the Alfresco Activiti Mobile SDK.
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

#import "ASDKFormColorSchemeManager.h"

@implementation ASDKFormColorSchemeManager

- (instancetype)init {
    self = [super init];
    if (self) {
        // Initialize with default values
        UIColor *uiControlLightBlueColor = [UIColor colorWithRed:40 / 255.0f green:150 / 255.0f blue:185 / 255.0f alpha:1.0f];
        UIColor *uiControlLightGrayColor = [UIColor colorWithRed:198 / 255.0f green:200 / 255.0f blue:200 / 255.0f alpha:1.0f];
        
        _formViewInvalidValueColor = [UIColor colorWithRed:255 / 255.0f green:102 / 255.0f blue:102 / 255.0f alpha:1.0f];
        _formViewValidValueColor = [UIColor blackColor];
        _formViewOutcomeEnabledColor = uiControlLightBlueColor;
        _formViewOutcomeDisabledColor = uiControlLightGrayColor;
        _formViewRadioOptionCheckmarkColor = uiControlLightBlueColor;
        _formViewHighlightedCellBackgroundColor = uiControlLightGrayColor;
        _formViewAmountFieldSymbolColor = [UIColor lightGrayColor];
        _formViewBackgroundColorForDistructiveOperation = [UIColor colorWithRed:250 / 255.0f green:128 / 255.0f blue:114 / 255.0f alpha:1.0f];
        _formViewFilledInValueColor = [UIColor grayColor];
    }
    
    return self;
}

@end

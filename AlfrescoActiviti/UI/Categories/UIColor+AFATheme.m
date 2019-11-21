/*******************************************************************************
 * Copyright (C) 2005-2018 Alfresco Software Limited.
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

#import "UIColor+AFATheme.h"

@implementation UIColor (AFATheme)

+ (UIColor *)placeholderColorForCredentialTextField {
    return [UIColor colorWithRed:178 / 255.0f green:177 / 255.0f blue:179 / 255.0f alpha:.9f];
}

+ (UIColor *)windowBackgroundColor {
    return [UIColor colorWithRed:42 / 255.0f green:41 / 255.0f blue:41 / 255.0f alpha:1.0f];
}

+ (UIColor *)drawerMenuButtonBackgroundColor {
    return [UIColor colorWithRed:119 / 255.0f green:119 / 255.0f blue:119 / 255.0f alpha:1.0f];
}

+ (UIColor *)applicationThemeDefaultColor {
    return [UIColor colorWithRed:49 / 255.0f green:68 / 255.0f blue:75 / 255.0f alpha:1.0f];
}

+ (UIColor *)applicationThemeOneColor {
    return [UIColor colorWithRed:27 / 255.0f green:136 / 255.0f blue:176 / 255.0f alpha:1.0f];
}

+ (UIColor *)applicationThemeTwoColor {
    return [UIColor colorWithRed:106 / 255.0f green:153 / 255.0f blue:161 / 255.0f alpha:1.0f];
}

+ (UIColor *)applicationThemeThreeColor {
    return [UIColor colorWithRed:118 / 255.0f green:137 / 255.0f blue:171 / 255.0f alpha:1.0f];
}

+ (UIColor *)applicationThemeFourColor {
    return [UIColor colorWithRed:187 / 255.0f green:56 / 255.0f blue:44 / 255.0f alpha:1.0f];
}

+ (UIColor *)applicationThemeFiveColor {
    return [UIColor colorWithRed:249 / 255.0f green:172 / 255.0f blue:83 / 255.0f alpha:1.0f];
}

+ (UIColor *)applicationThemeSixColor {
    return [UIColor colorWithRed:98 / 255.0f green:144 / 255.0f blue:55 / 255.0f alpha:1.0f];
}

+ (UIColor *)applicationThemeSevenColor {
    return [UIColor colorWithRed:162 / 255.0f green:167 / 255.0f blue:116 / 255.0f alpha:1.0f];
}

+ (UIColor *)applicationThemeEightColor {
    return [UIColor colorWithRed:144 / 255.0f green:91 / 255.0f blue:136 / 255.0f alpha:1.0f];
}

+ (UIColor *)applicationThemeNineColor {
    return [UIColor colorWithRed:86 / 255.0f green:89 / 255.0f blue:84 / 255.0f alpha:1.0f];
}

+ (UIColor *)applicationThemeTenColor {
    return [UIColor colorWithRed:191 / 255.0f green:177 / 255.0f blue:24 / 255.0f alpha:1.0f];
}

+ (UIColor *)applicationColorForTheme:(ASDKModelAppThemeType)theme {
    switch (theme) {
        case ASDKModelAppThemeTypeOne: {
            return [UIColor applicationThemeOneColor];
        }
            break;
            
        case ASDKModelAppThemeTypeTwo: {
            return [UIColor applicationThemeTwoColor];
        }
            break;
            
        case ASDKModelAppThemeTypeThree: {
            return [UIColor applicationThemeThreeColor];
        }
            break;
            
        case ASDKModelAppThemeTypeFour: {
            return [UIColor applicationThemeFourColor];
        }
            break;
            
        case ASDKModelAppThemeTypeFive: {
            return [UIColor applicationThemeFiveColor];
        }
            break;
            
        case ASDKModelAppThemeTypeSix: {
            return [UIColor applicationThemeSixColor];
        }
            break;
            
        case ASDKModelAppThemeTypeSeven: {
            return [UIColor applicationThemeSevenColor];
        }
            break;
            
        case ASDKModelAppThemeTypeEight: {
            return [UIColor applicationThemeEightColor];
        }
            break;
            
        case ASDKModelAppThemeTypeNine: {
            return [UIColor applicationThemeNineColor];
        }
            break;
        
        case ASDKModelAppThemeTypeTen: {
            return [UIColor applicationThemeTenColor];
        }
            break;
            
        default:
            break;
    }
    
    return nil;
}

+ (UIColor *)taskFilteringButtonBackgroundColor {
    return [UIColor colorWithRed:60 / 255.0f green:150 / 255.0f blue:202 / 255.0f alpha:1.0f];
}

+ (UIColor *)applicationCellSelectedBackgroundColor {
    return [UIColor colorWithRed:75 / 255.0f green:71 / 255.0f blue:73 / 255.0f alpha:1.0f];
}

+ (UIColor *)disabledControlColor {
    return [UIColor colorWithRed:198 / 255.0f green:200 / 255.0f blue:200 / 255.0f alpha:1.0f];
}

+ (UIColor *)enabledControlColor {
    return [UIColor colorWithRed:45 / 255.0f green:47 / 255.0f blue:51 / 255.0f alpha:1.0f];
}

+ (UIColor *)darkGreyTextColor {
    return [UIColor colorWithRed:69 / 255.0f green:69 / 255.0f blue:69 / 255.0f alpha:1.0f];
}

+ (UIColor *)distructiveOperationBackgroundColor {
    return [UIColor colorWithRed:250 / 255.0f green:128 / 255.0f blue:114 / 255.0f alpha:1.0f];
}

+ (UIColor *)checkmarkedActionColor {
    return [UIColor colorWithRed:92 / 255.0f green:184 / 255.0f blue:92 / 255.0f alpha:1.0f];
}

+ (UIColor *)connectivityWarningColor {
    return [UIColor colorWithRed:254 / 255.0f green:167 / 255.0f blue:77 / 255.0f alpha:1.0f];
}

+ (UIColor *)connectivityRestoredColor {
    return [UIColor colorWithRed:112 / 255.0f green:156 / 255.0f blue:70 / 255.0f alpha:1.0f];
}

+ (UIColor *)alertWithErrorColor {
    return [UIColor colorWithRed:201 / 255.0f green:47 / 255.0f blue:60 / 255.0f alpha:1.0f];
}

@end

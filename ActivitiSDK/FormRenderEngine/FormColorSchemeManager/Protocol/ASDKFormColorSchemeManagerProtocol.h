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

@import UIKit;

/**
 *  The purpose of classes implementing this protocol is to serve as color picker
 *  containers providing the means of customizing form related colors from outside
 *  the ActivitiSDK.
 */

@protocol ASDKFormColorSchemeManagerProtocol <NSObject>

/**
 *  Color reference for navigation bar tint color of form child controllers.
 */
@property (strong, nonatomic) UIColor *navigationBarThemeColor;

/**
 *  Color reference for the navigation bar title and other
 *  bar buttons that might exist on the navigation bar.
 */
@property (strong, nonatomic) UIColor *navigationBarTitleAndControlsColor;


/**
 *  Color reference for general form input invalid data.
 */
@property (strong, nonatomic) UIColor *formViewInvalidValueColor;


/**
 *  Color reference for general form input valid data.
 */
@property (strong, nonatomic) UIColor *formViewValidValueColor;


/**
 *  Color reference for the enabled outcome button of a form.
 */
@property (strong, nonatomic) UIColor *formViewOutcomeEnabledColor;


/**
 *  Color reference for the disabled outcome button of a form.
 */
@property (strong, nonatomic) UIColor *formViewOutcomeDisabledColor;


/**
 *  Color reference for the radio option check mark indicator within a 
 *  radio form field.
 */
@property (strong, nonatomic) UIColor *formViewRadioOptionCheckmarkColor;


/**
 *  Color reference for the highlighted state of a form field background.
 */
@property (strong, nonatomic) UIColor *formViewHighlightedCellBackgroundColor;


/**
 *  Color reference for the amount symbol inside the amount form field.
 */
@property (strong, nonatomic) UIColor *formViewAmountFieldSymbolColor;


/**
 *  Color reference for background views that signal a distructive operation i.e. deleting
 */
@property (strong, nonatomic) UIColor *formViewBackgroundColorForDistructiveOperation;


/**
 * Color reference for user filled in values in form views
 */
@property (strong, nonatomic) UIColor *formViewFilledInValueColor;

@end

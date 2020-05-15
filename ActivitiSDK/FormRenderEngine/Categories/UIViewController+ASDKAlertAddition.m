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

#import "UIViewController+ASDKAlertAddition.h"
#import "ASDKLocalizationConstants.h"

@implementation UIViewController (ASDKAlertAddition)

- (void)showGenericNetworkErrorAlertControllerWithMessage:(NSString *)networkErrorMessage {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(kLocalizationFormAlertDialogOopsTitleText, @"Oops title")
                                                                             message:networkErrorMessage
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okButtonAction = [UIAlertAction actionWithTitle:NSLocalizedString(kLocalizationFormAlertDialogOkButtonText, @"Ok button title")
                                                             style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction *action) {
                                                               [alertController dismissViewControllerAnimated:YES
                                                                                                   completion:nil];
                                                           }];
    [alertController addAction:okButtonAction];
    
    [self presentViewController:alertController
                       animated:YES
                     completion:nil];
}

- (void)showGenericErrorAlertControllerWithMessage:(NSString *)errorMessage {
    [self showGenericNetworkErrorAlertControllerWithMessage:errorMessage];
}

- (void)showConfirmationAlertControllerWithMessage:(NSString *)confirmationMessage
                           confirmationBlockAction:(ASDKAlertAdditionConfirmationBlock)confirmationBlock {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil
                                                                             message:confirmationMessage
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *yesButtonAction = [UIAlertAction actionWithTitle:NSLocalizedString(kLocalizationFormAlertDialogYesButtonText, @"YES text")
                                                              style:UIAlertActionStyleDestructive
                                                            handler:^(UIAlertAction * _Nonnull action) {
                                                                if (confirmationBlock) {
                                                                    confirmationBlock();
                                                                }
                                                            }];
    
    UIAlertAction *cancelButtonAction = [UIAlertAction actionWithTitle:NSLocalizedString(kLocalizationFormAlertDialogNoButtonText, @"Cancel text")
                                                                 style:UIAlertActionStyleCancel
                                                               handler:nil];
    
    [alertController addAction:yesButtonAction];
    [alertController addAction:cancelButtonAction];
    
    [self presentViewController:alertController
                       animated:YES
                     completion:nil];
}

- (void)showMultipleChoiceAlertControllerWithTitle:(NSString *)title
                                           message:(NSString *)message
                       choiceButtonTitlesAndBlocks:(NSString *)firstButtonTitle, ...; {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    va_list arguments;
    va_start(arguments, firstButtonTitle);
    NSString *buttonTitleString = firstButtonTitle;
    dispatch_block_t block;
    
    while(buttonTitleString) {
        block = va_arg(arguments, dispatch_block_t);
        
        UIAlertAction *action = [UIAlertAction actionWithTitle:buttonTitleString
                                                         style:UIAlertActionStyleDefault
                                                       handler:block ? ^(UIAlertAction *action) {
                                                           block();
                                                       } : nil];
        
        
        [alertController addAction:action];
        
        buttonTitleString = va_arg(arguments, id);
    }
    va_end(arguments);
    
    [self presentViewController:alertController
                       animated:YES
                     completion:nil];
}

@end

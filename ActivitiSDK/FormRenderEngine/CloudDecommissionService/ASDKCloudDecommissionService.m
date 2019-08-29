/*******************************************************************************
 * Copyright (C) 2005-2018 Alfresco Software Limited.
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

#import "ASDKCloudDecommissionService.h"
#import "ASDKFormRenderEngineConstants.h"
#import "ASDKNetworkServiceConstants.h"
#import "ASDKLocalizationConstants.h"
#import "ASDKModelIntegrationAccount.h"

@implementation ASDKCloudDecommissionService

+ (void)presentAlfrescoCloudDecommissioningAlertForAccount:(ASDKModelIntegrationAccount *)account
                                          inViewController:(UIViewController *)viewController
                                           completionBlock:(void (^)(void))completionBlock {
    if (![kASDKAPIServiceIDAlfrescoCloud isEqualToString:account.integrationServiceID]) {
        if (completionBlock) {
            completionBlock();
        }
    }
    
    BOOL wasCloudDecommissioningAlertShown = [[NSUserDefaults standardUserDefaults] boolForKey:kASDKAlfrescoCloudDecommissioningAlertShownKey];
    if (wasCloudDecommissioningAlertShown) {
        if (completionBlock) {
            completionBlock();
        }
    } else {
        NSString *alertTitle = kLocalizationAlfrescoCloudAddressText;
        NSString *alertText = ASDKLocalizedStringFromTable(kLocalizationAlfrescoCloudDecommissionText, ASDKLocalizationTable, @"Alfresco Cloud decommission message");
        NSString *okButtonText = ASDKLocalizedStringFromTable(kLocalizationFormAlertDialogOkButtonText, ASDKLocalizationTable, @"OK button title");
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:alertTitle
                                                                                 message:alertText
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *dismissAction = [UIAlertAction actionWithTitle:okButtonText
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * _Nonnull action) {
                                                                  [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kASDKAlfrescoCloudDecommissioningAlertShownKey];
                                                                  if(completionBlock) {
                                                                      completionBlock();
                                                                  }
                                                              }];
        [alertController addAction:dismissAction];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [viewController presentViewController:alertController
                                         animated:YES
                                       completion:nil];
        });
    }
}

@end

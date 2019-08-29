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

#import "ASDKPhotosLibraryService.h"
@import Photos;

@implementation ASDKPhotosLibraryService

+ (void)requestPhotosAuthorizationWithCompletionBlock:(ASDKPhotoLibraryAuthorizationStatus)completionBlock {
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    
    if (PHAuthorizationStatusDenied == status ||
        PHAuthorizationStatusRestricted == status) {
        if (completionBlock) {
            completionBlock(NO);
        }
    } else if (status == PHAuthorizationStatusNotDetermined) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            BOOL isAuthorized = (status != PHAuthorizationStatusAuthorized) ? NO : YES;
            
            if (completionBlock) {
                completionBlock(isAuthorized);
            }
        }];
    } else {
        if (completionBlock) {
            completionBlock(YES);
        }
    }
}

@end

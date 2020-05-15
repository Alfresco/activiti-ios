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

#import <Foundation/Foundation.h>
#import "ASDKDataAccessor.h"

@class ASDKModelProfile, ASDKModelFileContent;

@interface ASDKProfileDataAccessor : ASDKDataAccessor

/**
 * Requests the current user profile and reports network or cached data through the
 * designated data accessor delegate.
 */
- (void)fetchCurrentUserProfile;

/**
 * Requests the current user profile image and reports network or cached data through the
 * designated data accessor delegate.
 */
- (void)fetchCurrentUserProfileImage;

/**
 *
 * Updates the current profile data with changes encapsulated in a model object and reports
 * through the desginated data accessor delegate.
 *
 * @param profileModel Model object describing a profile.
 */
- (void)updateCurrentProfileWithModel:(ASDKModelProfile *)profileModel;

/**
 * Updates the current user's password and reports through the desginated data accessor delegate.
 *
 @param newPassword New password string.
 @param oldPassword Old password string.
 */
- (void)updateCurrentProfileWithNewPassword:(NSString *)newPassword
                                oldPassword:(NSString *)oldPassword;

/**
 * Updates the current profile image and reports through the desginated data accessor delegate.
 *
 @param fileContentModel    Description information for the image to be uploaded.
 @param contentData         Image data.
 */
- (void)uploadCurrentProfileImageForContentModel:(ASDKModelFileContent *)fileContentModel
                                     contentData:(NSData *)contentData;

/**
 * Cancels ongoing operations for the current data accessor.
 */
- (void)cancelOperations;

@end

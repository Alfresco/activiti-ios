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

@import Foundation;
@import UIKit;

@class ASDKModelServerConfiguration,
ASDKModelProfile;

typedef void  (^AFAProfileServicesProfileImageCompletionBlock)  (UIImage *profileImage, NSError *error);
typedef void  (^AFAProfileCompletionBlock)                      (ASDKModelProfile *profile, NSError *error);
typedef void  (^AFAProfilePasswordCompletionBlock)              (BOOL isPasswordUpdated, NSError *error);
typedef void  (^AFAProfileContentProgressBlock)                 (NSUInteger progress, NSError *error);
typedef void  (^AFAProfileContentUploadCompletionBlock)         (BOOL isContentUploaded, NSError *error);

@interface AFAProfileServices : NSObject

/**
 *  Performs a request for the profile image
 *
 *  @param completionBlock Completion block providing an UIImage instance and an optional error reason
 */
- (void)requestProfileImageWithCompletionBlock:(AFAProfileServicesProfileImageCompletionBlock)completionBlock;

/**
 *  Performs a request for the detailed profile information
 *
 *  @param completionBlock Completion block providing a reference to the profile model object and an
 *                         optional error reason.
 */
- (void)requestProfileWithCompletionBlock:(AFAProfileCompletionBlock)completionBlock;

/**
 *  Performs a request for the detailed profile but first it tries to return cached data
 *
 *  @param completionBlock      Completion block providing a reference to the profile model object and an
 *                              optional error reason.
 *  @param cacheCompletionBlock Completion block providing a cached reference to the profile model object and
 *                              an optional error reason.
 */
- (void)requestProfileWithCompletionBlock:(AFAProfileCompletionBlock)completionBlock
                            cachedResults:(AFAProfileCompletionBlock)cacheCompletionBlock;



/**
 *  Given a ASDKModelProfile model object it will update all of the provided fields and return via the
 *  completion block an updated profile model object and an optional error reason.
 *
 *  @param profileModel    Model object containing updated values
 *  @param completionBlock Completion block called upon successful or failed attempt
 */
- (void)requestProfileUpdateWithModel:(ASDKModelProfile *)profileModel
                      completionBlock:(AFAProfileCompletionBlock)completionBlock;

/**
 *  Requests a profile update given the old an new value and returns via a completion block whether
 *  the password was changed and an optional error reason.
 *
 *  @param updatedPassword New password value
 *  @param oldPassword     Old password value
 *  @param completionBlock Completion block called upon successful or failed attempt
 */
- (void)requestProfilePasswordUpdatedWithNewPassword:(NSString *)updatedPassword
                                         oldPassword:(NSString *)oldPassword
                                     completionBlock:(AFAProfilePasswordCompletionBlock)completionBlock;

/**
 *  Performs a request to upload a profile picture from the specified URL
 *
 *  @param fileURL         URL from where data content will be uploaded
 *  @param progressBlock   Block used to report progress updates for the upload operation and an optional error
 *                         reason
 *  @param completionBlock Completion block providing whether the content was successfully uploaded or not and
 *                         an optional error reason
 */

- (void)requestUploadProfileImageAtFileURL:(NSURL *)fileURL
                               contentData:(NSData *)contentData
                             progressBlock:(AFAProfileContentProgressBlock)progressBlock
                           completionBlock:(AFAProfileContentUploadCompletionBlock)completionBlock;

/**
 *  Cancels all requests related to profile activity
 */
- (void)cancellProfileNetworkRequests;

@end

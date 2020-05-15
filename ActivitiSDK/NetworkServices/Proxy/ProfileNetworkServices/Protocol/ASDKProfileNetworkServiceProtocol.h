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
#import "ASDKModelProfile.h"

@class ASDKModelFileContent,
ASDKModelContent;

typedef void  (^ASDKProfileCompletionBlock)             (ASDKModelProfile *profile, NSError *error);
typedef void  (^ASDKProfileImageCompletionBlock)        (UIImage *profileImage, NSError *error);
typedef void  (^ASDKProfilePasswordCompletionBlock)     (BOOL isPasswordUpdated, NSError *error);
typedef void  (^ASDKProfileAutheticationCompletionBlock)(BOOL didAuthenticate, NSError *error);
typedef void  (^ASDKProfileContentProgressBlock)        (NSUInteger progress, NSError *error);
typedef void  (^ASDKProfileImageContentUploadCompletionBlock)(ASDKModelContent *profilePictureContent, NSError *error);


@protocol ASDKProfileNetworkServiceProtocol <NSObject>

@required

/**
 *  Tries to autheticate the user with the provided password and returns the result
 *  via a completion block.
 *
 *  @param username         Username to be authenticated
 *  @param password         Password corresponding to the provided user account
 *  @param completionBlock  Completion block providing whether the autheticated has
 *                          succeeded or not and an additional error reason.
 */
- (void)authenticateUser:(NSString *)username
            withPassword:(NSString *)password
     withCompletionBlock:(ASDKProfileAutheticationCompletionBlock)completionBlock __deprecated;


/**
 *  Fetches from REST API and returns via a completion block a profile model object accompanied by
 *  an optional error reason.
 *
 *  @param completionBlock Completion block called upon successful or failed attempt
 */
- (void)fetchProfileWithCompletionBlock:(ASDKProfileCompletionBlock)completionBlock;

/**
 *  Given a ASDKModelProfile model object it will update all of the provided fields and return via the
 *  completion block an updated profile model object and an optional error reason.
 *
 *  @param profileModel    Model object containing updated values
 *  @param completionBlock Completion block called upon successful or failed attempt
 */
- (void)updateProfileWithModel:(ASDKModelProfile *)profileModel
               completionBlock:(ASDKProfileCompletionBlock)completionBlock;

/**
 *  Fetches from REST API and returns via the provided completion block an UIImage containing the
 *  user's profile picture or an optional error reason.
 *
 *  @param completionBlock Completion block called upon successful or failed attempt
 */
- (void)fetchProfileImageWithCompletionBlock:(ASDKProfileImageCompletionBlock)completionBlock;

/**
 *  Requests a profile update given the old an new value and returns via a completion block whether
 *  the password was changed or an optional error reason.
 *
 *  @param updatedPassword New password value
 *  @param oldPassword     Old password value
 *  @param completionBlock Completion block called upon successful or failed attempt
 */
- (void)updateProfileWithNewPassword:(NSString *)updatedPassword
                         oldPassword:(NSString *)oldPassword
                     completionBlock:(ASDKProfilePasswordCompletionBlock)completionBlock;

/**
 *  Uploads provided profile image content and reports back via a completion and progress blocks
 *  the status of the upload, whether the operation was successfull and optional errors that might occur.
 *
 *  @param file            Content model encapsulating file information needed for the upload
 *  @param contentData     NSData object of the content to be uploaded
 *  @param progressBlock   Block providing information on the upload progress and an optional error reason
 *  @param completionBlock Completion block providing information on whether the upload finished successfully
 *                         and an optional error reason.
 */
- (void)uploadProfileImageWithModel:(ASDKModelFileContent *)file
                        contentData:(NSData *)contentData
                      progressBlock:(ASDKProfileContentProgressBlock)progressBlock
                    completionBlock:(ASDKProfileImageContentUploadCompletionBlock)completionBlock;

/**
 *  Cancells all queued or running network operations
 */
- (void)cancelAllNetworkOperations;

@end

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

@class ASDKUserRequestRepresentation,
ASDKModelPaging;

typedef void  (^ASDKUsersCompletionBlock) (NSArray *users, NSError *error, ASDKModelPaging *paging);
typedef void  (^ASDKUsersPictureCompletionBlock) (UIImage *profileImage, NSError *error);

@protocol ASDKUserNetworkServiceProtocol <NSObject>

/**
 *  Fetches and returns via the completion block a list of users. 
 *  
 *  Note: This would be useful used when a user wants to involve 
 *        or assign another user to a task.
 *
 *  @param userRequest              Request object describing which subset of the user list
 *                                  collection should be fetched
 *  @param completionBlock          Completion block providing a user list, an optional
 *                                  error reason and paging information
 */
- (void)fetchUsersWithUserRequestRepresentation:(ASDKUserRequestRepresentation *)userRequest
                               completionBlock:(ASDKUsersCompletionBlock)completionBlock;

/**
 *  Fetches and returns via the completion block the profile picture of a user.
 *
 *  @param userID                   ID of the user for which the picture is fetched
 *  @param completionBlock          Completion block providing the picture image and an optional
 *                                  error reason
 */
- (void)fetchPictureForUserID:(NSString *)userID
              completionBlock:(ASDKUsersPictureCompletionBlock)completionBlock;

/**
 *  Cancells all queued or running network operations
 */
- (void)cancelAllNetworkOperations;

@end

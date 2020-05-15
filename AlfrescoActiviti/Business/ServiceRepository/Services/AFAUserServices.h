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

#import <Foundation/Foundation.h>
@class UIImage;

@class AFAUserFilterModel, ASDKModelPaging;

typedef void  (^AFAUserServicesFetchCompletionBlock) (NSArray *users, NSError *error, ASDKModelPaging *paging);
typedef void  (^AFAUserPictureCompletionBlock) (UIImage *profileImage, NSError *error);

@interface AFAUserServices : NSObject

/**
 *  Performs a request given a filter object and returns via the completion block a list of users
 *  matching the filter criteria.
 *
 *  @param filter                   Filter object describing which subset of the user list
 *                                  collection should be fetched
 *  @param completionBlock          Completion block providing a user list, an optional
 *                                  error reason and paging information
 */
- (void)requestUsersWithUserFilter:(AFAUserFilterModel *)filter
                   completionBlock:(AFAUserServicesFetchCompletionBlock)completionBlock;

/**
 *  Performs a request and returns via the completion block the profile picture of a user given it's
 *  user ID.
 *
 *  @param userID          ID of the user for which the picture is requested
 *  @param completionBlock Completion block providing the picture image and an optional
 *                         error reason
 */
- (void)requestPictureForUserID:(NSString *)userID
                completionBlock:(AFAUserPictureCompletionBlock)completionBlock;


/**
 *  Performs a check on whether the user is logged in on cloud or premise.
 *
 *  @return Boolean value indicating whether the user is logged in on cloud or premise
 */
+ (BOOL)isLoggedInOnCloud;

@end

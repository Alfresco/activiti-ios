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

@class ASDKModelProfile;

typedef void (^ASDKCacheServiceProfileCompletionBlock) (ASDKModelProfile *profile, NSError *error);

@protocol ASDKProfileCacheServiceProtocol <NSObject>


/**
 * Caches provided user profile and reports the operation success over a completion block.
 *
 * @param profile           Profile model to be cached
 * @param completionBlock   Completion block indicating the succes of the operation
 */
- (void)cacheCurrentUserProfile:(ASDKModelProfile *)profile
            withCompletionBlock:(ASDKCacheServiceCompletionBlock)completionBlock;


/**
 * Fetches and reports via a completion block the current user profile.
 *
 * @param profileCompletionBlock Completion block providing a profile model and an optional
 *                               error reason
 */
- (void)fetchCurrentUserProfile:(ASDKCacheServiceProfileCompletionBlock)profileCompletionBlock;

@end

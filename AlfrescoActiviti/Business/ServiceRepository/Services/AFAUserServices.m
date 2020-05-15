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

#import "AFAUserServices.h"
@import ActivitiSDK;

// Constants
#import "AFABusinessConstants.h"

// Models
#import "AFAUserFilterModel.h"

@interface AFAUserServices () <ASDKDataAccessorDelegate>

// Fetch user list
@property (strong, nonatomic) ASDKUserDataAccessor              *fetchUserListDataAccessor;
@property (copy, nonatomic) AFAUserServicesFetchCompletionBlock userListCompletionBlock;

// Fetch profile image
@property (strong, nonatomic) ASDKUserDataAccessor              *fetchProfileImageDataAccessor;
@property (copy, nonatomic) AFAUserPictureCompletionBlock        profileImageCompletionBlock;

@end

@implementation AFAUserServices


#pragma mark -
#pragma mark Public interface

- (void)requestUsersWithUserFilter:(AFAUserFilterModel *)filter
                   completionBlock:(AFAUserServicesFetchCompletionBlock)completionBlock {
    NSParameterAssert(filter);
    NSParameterAssert(completionBlock);
    
    ASDKUserRequestRepresentation *userRequestRepresentation = [ASDKUserRequestRepresentation new];
    userRequestRepresentation.filter = filter.name;
    userRequestRepresentation.email = filter.email;
    userRequestRepresentation.excludeTaskID = filter.excludeTaskID;
    userRequestRepresentation.excludeProcessID = filter.excludeProcessID;
    userRequestRepresentation.jsonAdapterType = ASDKModelJSONAdapterTypeExcludeNilValues;
    
    self.userListCompletionBlock = completionBlock;
    
    self.fetchUserListDataAccessor = [[ASDKUserDataAccessor alloc] initWithDelegate:self];
    [self.fetchUserListDataAccessor fetchUsersWithUserFilter:userRequestRepresentation];
}

- (void)requestPictureForUserID:(NSString *)userID
                completionBlock:(AFAUserPictureCompletionBlock)completionBlock {
    NSParameterAssert(completionBlock);
    
    self.profileImageCompletionBlock = completionBlock;
    
    self.fetchProfileImageDataAccessor = [[ASDKUserDataAccessor alloc] initWithDelegate:self];
    [self.fetchProfileImageDataAccessor fetchProfilePictureForUserWithID:userID];
}

+ (BOOL)isLoggedInOnCloud {
    ASDKBootstrap *sdkBootstrap = [ASDKBootstrap sharedInstance];
    ASDKUserNetworkServices *userNetworkService = [sdkBootstrap.serviceLocator serviceConformingToProtocol:@protocol(ASDKUserNetworkServiceProtocol)];
    return [sdkBootstrap.serverConfiguration.hostAddressString isEqualToString:[userNetworkService.servicePathFactory cloudHostnamePath]];
}


#pragma mark -
#pragma mark ASDKDataAccessorDelegate

- (void)dataAccessor:(id<ASDKServiceDataAccessorProtocol>)dataAccessor
 didLoadDataResponse:(ASDKDataAccessorResponseBase *)response {
    if (self.fetchUserListDataAccessor == dataAccessor) {
        [self handleUserDataAccessorResponse:response];
    } else if (self.fetchProfileImageDataAccessor == dataAccessor) {
        [self handleProfileImageDataAccessorResponse:response];
    }
}

- (void)dataAccessorDidFinishedLoadingDataResponse:(id<ASDKServiceDataAccessorProtocol>)dataAccessor {
}


#pragma mark -
#pragma mark Private interface

- (void)handleUserDataAccessorResponse:(ASDKDataAccessorResponseBase *)response {
    ASDKDataAccessorResponseCollection *userListResponse = (ASDKDataAccessorResponseCollection *)response;
    NSArray *userList = userListResponse.collection;
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(self) strongSelf = weakSelf;
        
        if (strongSelf.userListCompletionBlock) {
            strongSelf.userListCompletionBlock(userList, userListResponse.error, userListResponse.paging);
            strongSelf.userListCompletionBlock = nil;
        }
    });
}

- (void)handleProfileImageDataAccessorResponse:(ASDKDataAccessorResponseBase *)response {
    ASDKDataAccessorResponseModel *profileImageResponse = (ASDKDataAccessorResponseModel *)response;
    UIImage *profileImage = profileImageResponse.model;
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(self) strongSelf = weakSelf;
        if (strongSelf.profileImageCompletionBlock) {
            strongSelf.profileImageCompletionBlock(profileImage, profileImageResponse.error);
            strongSelf.profileImageCompletionBlock = nil;
        }
    });
}

@end

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

#import "ASDKUserDataAccessor.h"

// Managers
#import "ASDKBootstrap.h"
#import "ASDKUserNetworkServices.h"
#import "ASDKServiceLocator.h"

// Model
#import "ASDKDataAccessorResponseCollection.h"
#import "ASDKDataAccessorResponseModel.h"

@interface ASDKUserDataAccessor ()

@property (strong, nonatomic) NSOperationQueue *processingQueue;

@end

@implementation ASDKUserDataAccessor

- (instancetype)initWithDelegate:(id<ASDKDataAccessorDelegate>)delegate {
    self = [super initWithDelegate:delegate];
    
    if (self) {
        _processingQueue = [self serialOperationQueue];
        _cachePolicy = ASDKServiceDataAccessorCachingPolicyHybrid;
        dispatch_queue_t taskUpdatesprocessingQueue = dispatch_queue_create([[NSString stringWithFormat:@"%@.`%@ProcessingQueue",
                                                                              [NSBundle bundleForClass:[self class]].bundleIdentifier,
                                                                              NSStringFromClass([self class])] UTF8String],
                                                                            DISPATCH_QUEUE_SERIAL);
        // Aquire and set up the task network service
        ASDKBootstrap *sdkBootstrap = [ASDKBootstrap sharedInstance];
        _networkService = (ASDKUserNetworkServices *)[sdkBootstrap.serviceLocator serviceConformingToProtocol:@protocol(ASDKUserNetworkServiceProtocol)];
        _networkService.resultsQueue = taskUpdatesprocessingQueue;
    }
    
    return self;
}

#pragma mark -
#pragma mark Service User list

- (void)fetchUsersWithUserFilter:(ASDKUserRequestRepresentation *)filter {
    NSParameterAssert(filter);
    
    if ([self.delegate respondsToSelector:@selector(dataAccessorDidStartFetchingRemoteData:)]) {
        [self.delegate dataAccessorDidStartFetchingRemoteData:self];
    }
    
    __weak typeof(self) weakSelf = self;
    [self.userNetworkService fetchUsersWithUserRequestRepresentation:filter
                                                     completionBlock:^(NSArray *users, NSError *error, ASDKModelPaging *paging) {
                                                         __strong typeof(self) strongSelf = weakSelf;
                                                         
                                                         ASDKDataAccessorResponseCollection *response =
                                                         [[ASDKDataAccessorResponseCollection alloc] initWithCollection:users
                                                                                                                 paging:paging
                                                                                                           isCachedData:NO
                                                                                                                  error:error];
                                                         if (strongSelf.delegate) {
                                                             [strongSelf.delegate dataAccessor:weakSelf
                                                                           didLoadDataResponse:response];
                                                             
                                                             [strongSelf.delegate dataAccessorDidFinishedLoadingDataResponse:strongSelf];
                                                         }
    }];
}

- (void)fetchProfilePictureForUserWithID:(NSString *)userID {
    NSParameterAssert(userID);
    
    if ([self.delegate respondsToSelector:@selector(dataAccessorDidStartFetchingRemoteData:)]) {
        [self.delegate dataAccessorDidStartFetchingRemoteData:self];
    }
    
    __weak typeof(self) weakSelf = self;
    [self.userNetworkService fetchPictureForUserID:userID
                                   completionBlock:^(UIImage *profileImage, NSError *error) {
                                       __strong typeof(self) strongSelf = weakSelf;
                                       
                                       ASDKDataAccessorResponseModel *response =
                                       [[ASDKDataAccessorResponseModel alloc] initWithModel:profileImage
                                                                               isCachedData:NO
                                                                                      error:error];
                                       
                                       if (strongSelf.delegate) {
                                           [strongSelf.delegate dataAccessor:weakSelf
                                                         didLoadDataResponse:response];
                                           
                                           [strongSelf.delegate dataAccessorDidFinishedLoadingDataResponse:strongSelf];
                                       }
    }];
}


#pragma mark -
#pragma mark Cancel operations

- (void)cancelOperations {
    [super cancelOperations];
    [self.processingQueue cancelAllOperations];
    [self.userNetworkService cancelAllNetworkOperations];
}


#pragma mark -
#pragma mark Private interface

- (ASDKUserNetworkServices *)userNetworkService {
    return (ASDKUserNetworkServices *)self.networkService;
}

@end

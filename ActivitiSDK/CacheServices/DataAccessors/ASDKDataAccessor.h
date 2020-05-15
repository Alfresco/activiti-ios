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
#import "ASDKServiceDataAccessorProtocol.h"

typedef NS_ENUM(NSInteger, ASDKNetworkReachabilityStatus) {
    ASDKNetworkReachabilityStatusUnknown          = -1,
    ASDKNetworkReachabilityStatusNotReachable     = 0,
    ASDKNetworkReachabilityStatusReachableViaWWANOrWifi = 1
};

@interface ASDKDataAccessor : NSObject <ASDKServiceDataAccessorProtocol, NSCopying> {
    @protected
    ASDKServiceDataAccessorCachingPolicy  _cachePolicy;
    ASDKNetworkService                    *_networkService;
    ASDKCacheService                      *_cacheService;
}

@property (assign, nonatomic)           ASDKServiceDataAccessorCachingPolicy  cachePolicy;
@property (strong, nonatomic)           ASDKCacheService                      *cacheService;
@property (strong, nonatomic, readonly) ASDKNetworkService                    *networkService;
@property (weak, nonatomic)             id<ASDKDataAccessorDelegate>          delegate;

- (instancetype)initWithDelegate:(id<ASDKDataAccessorDelegate>)delegate;

/**
 * Creates and returns a serial operation queue.
 */
- (NSOperationQueue *)serialOperationQueue;

/**
 * Returns the network reachability status at a given moment.
 @return Enum integer corresponding to a reachability status.
 */
- (ASDKNetworkReachabilityStatus)networkReachabilityStatus;

/**
 * Requests cancelation for all domain specific operations.
 */
- (void)cancelOperations;

@end

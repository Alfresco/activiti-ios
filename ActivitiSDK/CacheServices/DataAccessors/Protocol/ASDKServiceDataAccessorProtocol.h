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
#import "ASDKDataAccessorResponseBase.h"

@class ASDKNetworkService, ASDKCacheService;
@protocol ASDKServiceDataAccessorProtocol;

typedef NS_ENUM(NSInteger, ASDKServiceDataAccessorCachingPolicy) {
    ASDKServiceDataAccessorCachingPolicyUndefined = -1,
    ASDKServiceDataAccessorCachingPolicyCacheOnly,
    ASDKServiceDataAccessorCachingPolicyAPIOnly,
    ASDKServiceDataAccessorCachingPolicyHybrid                  // Default behavior unless specified otherwise
};

@protocol ASDKDataAccessorDelegate <NSObject>

/**
 * Signals that a data response from the cache or remote has been received and delivers
 * an encapsulated response.
 *
 * @param dataAccessor  Reference to the data accessor that is delivering the response
 * @param response      Response object that's encapsulating the actual data, whether the response
 *                      is being delivered from the cache or remote
 */
- (void)dataAccessor:(id<ASDKServiceDataAccessorProtocol>)dataAccessor
 didLoadDataResponse:(ASDKDataAccessorResponseBase *)response;

/**
 * Signals that all data fetching operations from the cache or remote have finished
 *
 * @param dataAccessor Reference to the data accessor that is delivering the response
 */
- (void)dataAccessorDidFinishedLoadingDataResponse:(id<ASDKServiceDataAccessorProtocol>)dataAccessor;

@optional
/**
 * Signals that the data accessor will begin to fetch remote data
 *
 * @param dataAccessor Reference to the data accessor that is delivering the response
 */
- (void)dataAccessorDidStartFetchingRemoteData:(id<ASDKServiceDataAccessorProtocol>)dataAccessor;

@end

@protocol ASDKServiceDataAccessorProtocol <NSObject>

/**
 * Cache policy defining the order of operations inside a data accessor.
 */
@property (assign, nonatomic)           ASDKServiceDataAccessorCachingPolicy  cachePolicy;


/**
 * This property is intentionally defined of a base class type to allow custom derived subclasses
 * with different implementations of persistence mediums other than the default Core Data one to be used.
 */
@property (strong, nonatomic)           ASDKCacheService                      *cacheService;


/**
 * This property holds a reference to the domain specific network service subclass used to fetch
 * remote data.
 */
@property (strong, nonatomic, readonly) ASDKNetworkService                    *networkService;


/**
 * Delegate object that is notified about operations performed by the data accessor.
 */
@property (weak, nonatomic)             id<ASDKDataAccessorDelegate>          delegate;

@end

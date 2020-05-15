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

#import "ASDKDataAccessor.h"

// Managers
#import "ASDKCacheService.h"
#import "ASDKNetworkService.h"

@implementation ASDKDataAccessor


#pragma mark -
#pragma mark Life cycle

- (instancetype)initWithDelegate:(id<ASDKDataAccessorDelegate>)delegate {
    self = [super init];
    if (self) {
        _delegate = delegate;
    }
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}


#pragma mark - 
#pragma mark Public interface

- (NSOperationQueue *)serialOperationQueue {
    NSOperationQueue *operationQueue = [NSOperationQueue new];
    operationQueue.maxConcurrentOperationCount = 1;
    
    return operationQueue;
}

- (ASDKNetworkReachabilityStatus)networkReachabilityStatus {
    switch ([self.networkService.requestOperationManager.reachabilityManager networkReachabilityStatus]) {
        case AFNetworkReachabilityStatusReachableViaWWAN:
        case AFNetworkReachabilityStatusReachableViaWiFi: {
            return ASDKNetworkReachabilityStatusReachableViaWWANOrWifi;
        }
            break;
            
        case AFNetworkReachabilityStatusNotReachable: {
            return ASDKNetworkReachabilityStatusNotReachable;
        }
            
        default:break;
    }
    
    return ASDKNetworkReachabilityStatusUnknown;
}

- (void)cancelOperations {
    // Implement in sublcasses.
}

@end

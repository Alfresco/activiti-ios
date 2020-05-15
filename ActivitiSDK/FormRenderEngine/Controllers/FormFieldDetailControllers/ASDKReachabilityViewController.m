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

#import "ASDKReachabilityViewController.h"
#import "ASDKReachabilityManager.h"

@interface ASDKReachabilityViewController ()

@property (strong, nonatomic) ASDKReachabilityManager *reachabilityManager;

@end

@implementation ASDKReachabilityViewController


#pragma mark -
#pragma mark View lifecycle

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _reachabilityManager = [ASDKReachabilityManager new];
    }
    
    return self;
}

+ (NSSet *)keyPathsForValuesAffectingNetworkReachabilityStatus {
    return [NSSet setWithObject:@"reachabilityManager.networkReachabilityStatus"];
}


#pragma mark -
#pragma mark Public interface

- (ASDKNetworkReachabilityStatus)networkReachabilityStatus {
    return self.reachabilityManager.networkReachabilityStatus;
}

- (void)setNetworkReachabilityStatus:(ASDKNetworkReachabilityStatus)networkReachabilityStatus {
    if (self.reachabilityManager.networkReachabilityStatus != networkReachabilityStatus) {
        self.reachabilityManager.networkReachabilityStatus = networkReachabilityStatus;
    }
}

- (ASDKNetworkReachabilityStatus)requestInitialReachabilityStatus {
   return [self.reachabilityManager requestInitialReachabilityStatus];
}

@end

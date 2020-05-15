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

#import "ASDKKVOManagerSharedProxy.h"
#import "ASDKKVOManagerInfo.h"
#import <libkern/OSAtomic.h>

@interface ASDKKVOManagerSharedProxy () {
    NSHashTable *_kvoManagerInfos;
    NSLock *_lock;
}

@end

@implementation ASDKKVOManagerSharedProxy


#pragma mark -
#pragma mark Life cycle

+ (instancetype)sharedInstance {
    static ASDKKVOManagerSharedProxy *kvoManagerSharedProxy = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        kvoManagerSharedProxy = [ASDKKVOManagerSharedProxy new];
    });
    
    return kvoManagerSharedProxy;
}

- (instancetype)init {
    self = [super init];
    
    if (self) {
        _kvoManagerInfos = [[NSHashTable alloc] initWithOptions:NSPointerFunctionsWeakMemory | NSPointerFunctionsObjectPointerPersonality
                                                       capacity:0];
        _lock = [NSLock new];
    }
    
    return self;
}


#pragma mark -
#pragma mark Public interface

- (void)observe:(id)object
withManagerInfo:(ASDKKVOManagerInfo *)managerInfo {
    [_lock lock];
    [_kvoManagerInfos addObject:managerInfo];
    [_lock unlock];
    
    [object addObserver:self
             forKeyPath:managerInfo.keyPath
                options:managerInfo.options
                context:(void *)managerInfo];
}

- (void)removeObserver:(id)object
       withManagerInfo:(ASDKKVOManagerInfo *)managerInfo {
    [_lock lock];
    [_kvoManagerInfos removeObject:managerInfo];
    [_lock unlock];
    
    [object removeObserver:self
                forKeyPath:managerInfo.keyPath
                   context:(void *)managerInfo];
}


#pragma mark -
#pragma mark KVO delegates

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    ASDKKVOManagerInfo *managerInfo = nil;
    
    [_lock lock];
    managerInfo = [_kvoManagerInfos member:(__bridge id)context];
    [_lock unlock];
    
    if (managerInfo) {
        ASDKKVOManager *kvoManager = managerInfo.kvoManager;
        if (kvoManager) {
            id observer = kvoManager.observer;
            if (observer &&
                managerInfo.notificationBlock) {
                managerInfo.notificationBlock(observer, object, change);
            }
        }
    }
}

@end

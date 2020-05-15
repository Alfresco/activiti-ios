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

#import "ASDKKVOManager.h"
#import <libkern/OSAtomic.h>
#import "ASDKKVOManagerInfo.h"
#import "ASDKKVOManagerSharedProxy.h"

@implementation ASDKKVOManager {
    NSMapTable *_objInfoMap;
    NSLock *_lock;
}


#pragma mark -
#pragma mark Life cycle

+ (instancetype)managerWithObserver:(id)observer {
    return [[self alloc] initWithObserver:observer
                      withStrongReference:YES];
}

- (instancetype)initWithObserver:(id)observer
             withStrongReference:(BOOL)isStrongReference {
    self = [super init];
    
    if (self) {
        _observer = observer;
        NSPointerFunctionsOptions keyOptions = isStrongReference ? NSPointerFunctionsStrongMemory | NSPointerFunctionsObjectPointerPersonality : NSPointerFunctionsWeakMemory | NSPointerFunctionsObjectPointerPersonality;
        NSPointerFunctionsOptions valueOptions = NSPointerFunctionsStrongMemory | NSPointerFunctionsObjectPersonality;
        _objInfoMap = [[NSMapTable alloc] initWithKeyOptions:keyOptions
                                                valueOptions:valueOptions
                                                    capacity:0];
        _lock = [NSLock new];
    }
    
    return self;
}


#pragma mark -
#pragma mark Public interface

- (void)observeObject:(id)object
           forKeyPath:(NSString *)keyPath
              options:(NSKeyValueObservingOptions)options
                block:(ASDKKVOManagerNotificationBlock)notificationBlock {
    NSParameterAssert(object &&
                      keyPath &&
                      notificationBlock);
    
    // Create observation container
    ASDKKVOManagerInfo *managerInfo = [[ASDKKVOManagerInfo alloc] initWithManager:self
                                                                          keyPath:keyPath
                                                                          options:options
                                                                            block:notificationBlock];
    [self observe:object
  withManagerInfo:managerInfo];
}

- (void)removeObserver:(id)object
            forKeyPath:(NSString *)keyPath {
    NSParameterAssert(object &&
                      keyPath);
    
    // Create observation container
    ASDKKVOManagerInfo *managerInfo= [[ASDKKVOManagerInfo alloc] initWithManager:self
                                                                         keyPath:keyPath];
    
    [self removeObserver:object
         withManagerInfo:managerInfo];
}


#pragma mark -
#pragma mark Private interface

- (void)observe:(id)object
withManagerInfo:(ASDKKVOManagerInfo *)managerInfo {
    [_lock lock];

    NSMutableSet *managerInfos = [_objInfoMap objectForKey:object];
    if (!managerInfos) {
        managerInfos = [NSMutableSet set];
        [_objInfoMap setObject:managerInfos
                        forKey:object];
    }
    
    // Register passed manager info with set in the info map table
    [managerInfos addObject:managerInfo];
    
    [_lock unlock];
    
    [[ASDKKVOManagerSharedProxy sharedInstance] observe:object
                                        withManagerInfo:managerInfo];
}

- (void)removeObserver:(id)object
       withManagerInfo:(ASDKKVOManagerInfo *)managerInfo {
    [_lock lock];
    
    NSMutableSet *managerInfos = [_objInfoMap objectForKey:object];
    
    ASDKKVOManagerInfo *existingInfo = [managerInfos member:managerInfo];
    if (existingInfo) {
        [managerInfos removeObject:existingInfo];
        
        if (managerInfos.count) {
            [_objInfoMap removeObjectForKey:object];
        }
    }
    
    [_lock unlock];
    
    [[ASDKKVOManagerSharedProxy sharedInstance] removeObserver:object
                                               withManagerInfo:existingInfo];
}

@end

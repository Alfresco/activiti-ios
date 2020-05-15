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

#import "ASDKServiceLocator.h"
#import "ASDKLogConfiguration.h"
#import <objc/runtime.h>
#import <libkern/OSAtomic.h>

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

static const int activitiSDKLogLevel = ASDK_LOG_LEVEL_WARN; // | ASDK_LOG_FLAG_TRACE;

@interface ASDKServiceLocator () {
    NSLock *_lock;
}

@property (strong, nonatomic) NSMutableDictionary *serviceDictionary;

@end

@implementation ASDKServiceLocator

- (instancetype)init {
    self = [super init];
    
    if (self) {
        self.serviceDictionary = [NSMutableDictionary dictionary];
        _lock = [NSLock new];
    }
    
    return self;
}

#pragma mark - 
#pragma mark Public interface

- (NSArray *)registeredServices {
    return [self.serviceDictionary allValues];
}

#pragma mark -
#pragma mark Service Locator contract

- (void)addService:(id)service {
    NSParameterAssert([service class]);
    
    Class serviceClass = [service class];
    NSArray *protocolListName = [self protocolNameListForClass:serviceClass];
    
    // Warn if multiple protocols contracts are found
    if (!protocolListName.count) {
        ASDKLogError(@"Service class:%@ does not comply to any service protocol. Cannot register as a service", NSStringFromClass(serviceClass));
        return;
    }
    
    if (protocolListName.count > 1) {
        ASDKLogError(@"Service class:%@ breaking single protocol conformity rule. Make sure sure service class only conform to one service protocol.", NSStringFromClass(serviceClass));
        return;
    } else {
        [_lock lock];
        [self.serviceDictionary setObject:service
                                   forKey:protocolListName.firstObject];
        [_lock unlock];
    }
}

- (BOOL)isServiceRegistered:(id)service {
    NSParameterAssert([service class]);
    BOOL isServiceRegistered = YES;
        
    Class serviceClass = [service class];
    NSArray *protocolListName = [self protocolNameListForClass:serviceClass];
    
    [_lock lock];
    if (!protocolListName ||
        !self.serviceDictionary[protocolListName.firstObject]) {
        isServiceRegistered = NO;
    }
    [_lock unlock];
    
    return isServiceRegistered;
}


- (BOOL)isServiceRegisteredForProtocol:(Protocol *)protocol {
    NSParameterAssert(protocol);
    
    [_lock lock];
    BOOL isServiceRegistered = self.serviceDictionary[NSStringFromProtocol(protocol)] ? YES : NO;
    [_lock unlock];
    
    return isServiceRegistered;
}

- (id)serviceConformingToProtocol:(Protocol *)protocol {
    NSParameterAssert(protocol);

    [_lock lock];
    id service = self.serviceDictionary[NSStringFromProtocol(protocol)];
    [_lock unlock];
    
    return service;
}

- (void)removeServiceConformingToProtocol:(Protocol *)protocol {
    NSParameterAssert(protocol);
    
    [_lock lock];
    if (self.serviceDictionary.allKeys.count) {
        [self.serviceDictionary removeObjectForKey:NSStringFromProtocol(protocol)];
    }
    [_lock unlock];
}

- (void)removeService:(id)service {
    NSParameterAssert(service);
    
    Class serviceClass = [service class];
    NSArray *protocolListName = [self protocolNameListForClass:serviceClass];
    
    [_lock lock];
    if (self.serviceDictionary.allKeys.count) {
        [self.serviceDictionary removeObjectForKey:protocolListName.firstObject];
    }
    [_lock unlock];
}

#pragma mark -
#pragma mark Private interface

- (NSArray *)protocolNameListForClass:(Class)serviceClass {
    NSMutableArray *protocolListArr = [NSMutableArray array];
    
    unsigned int protocolCount = 0;
    Protocol * __unsafe_unretained *protocols = class_copyProtocolList(serviceClass, &protocolCount);
    if (!protocolCount) {
        return nil;
    } else {
        for (NSInteger protocolIdx = 0; protocolIdx < protocolCount; protocolIdx++) {
            [protocolListArr addObject:NSStringFromProtocol(protocols[protocolIdx])];
        }
    }
    
    free(protocols);
    return protocolListArr;
}

@end

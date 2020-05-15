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

#import "ASDKKVOManagerInfo.h"

@implementation ASDKKVOManagerInfo


#pragma mark -
#pragma mark Life cycle

- (instancetype)initWithManager:(ASDKKVOManager *)kvoManager
                        keyPath:(NSString *)keyPath
                        options:(NSKeyValueObservingOptions)options
                          block:(ASDKKVOManagerNotificationBlock)notificationBlock {
    self = [super init];
    
    if (self) {
        self.kvoManager = kvoManager;
        self.notificationBlock = notificationBlock;
        self.keyPath = keyPath;
        self.options = options;
    }
    
    return self;
}

- (instancetype)initWithManager:(ASDKKVOManager *)kvoManager
                        keyPath:(NSString *)keyPath {
    return [self initWithManager:kvoManager
                         keyPath:keyPath
                         options:0
                           block:nil];
}


#pragma mark -
#pragma mark Equality overrides

- (NSUInteger)hash {
    return [self.keyPath hash];
}

- (BOOL)isEqual:(id)object {
    if (object == self) {
        return YES;
    }
    if (!object) {
        return NO;
    }
    
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    
    return [((ASDKKVOManagerInfo *)object).keyPath isEqualToString:self.keyPath];
}

@end

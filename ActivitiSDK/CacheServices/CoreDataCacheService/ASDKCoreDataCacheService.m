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

#import "ASDKCoreDataCacheService.h"

// Protocols
#import "ASDKPersistenceStackProtocol.h"

// Managers
#import "ASDKBootstrap.h"
#import "ASDKServiceLocator.h"

@implementation ASDKCoreDataCacheService

- (instancetype)init {
    self = [super init];
    if (self) {
        ASDKBootstrap *bootStrap = [ASDKBootstrap sharedInstance];
        _persistenceStack = [bootStrap.serviceLocator serviceConformingToProtocol:@protocol(ASDKPersistenceStackProtocol)];
    }
    
    return self;
}

- (void)saveChanges {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf.persistenceStack saveContext];
    });
}

@end

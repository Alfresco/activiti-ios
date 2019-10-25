/*******************************************************************************
 * Copyright (C) 2005-2018 Alfresco Software Limited.
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

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, AFAServiceObjectType) {
    AFAServiceObjectTypeThumbnailManager,
    AFAServiceObjectTypeNetworkDelayedSaveFormService,
    AFAServiceObjectTypeAIMSLogin
};

/**
 *  The purpose of this class is to offer a centralized way of requesting for manager
 *  objects instead of spawning singeton instanced directly inside the implementation.
 *  Object access is thread safe for both getters and setter methods
 */

@interface AFAServiceRepository : NSObject

// Singleton interface
+ (instancetype)sharedRepository;
+ (instancetype)alloc __attribute__((unavailable("alloc not available with AFAServiceRepository, call sharedInstance instead")));
+ (instancetype)new __attribute__((unavailable("new not available with AFAServiceRepository, call sharedInstance instead")));
- (instancetype)init __attribute__((unavailable("init not available with AFAServiceRepository, call sharedInstance instead")));

/**
 *  Registers  service object that can be later referenced via it's service object type
 *
 *  @param serviceObject     Object to be registered
 *  @param serviceObjectType Enum type describing the object purpose
 */
- (void)registerServiceObject:(id)serviceObject
                   forPurpose:(AFAServiceObjectType)serviceObjectType;


/**
 *  Returns a service object for the specified purpose
 *
 *  @param serviceObjectType Enum type describing the expected object's purpose
 *
 *  @return Object registered for the specified enum type
 */
- (id)serviceObjectForPurpose:(AFAServiceObjectType)serviceObjectType;


/**
 *  Removes the specified registered service object
 *
 *  @param serviceObjectType Enum type describing the expected object to be removed
 */
- (void)removeServiceForPurpose:(AFAServiceObjectType)serviceObjectType;

@end

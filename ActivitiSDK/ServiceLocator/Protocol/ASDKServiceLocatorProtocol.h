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

 /** 
  * The ServiceLocator protocol is intended to describe an object repository interface
  * and convenience methods to work with that object repository. It's purpose is to
  * avoid Singleton abuse and offer an alternative way through which 'managers' are
  * requested from the repository and injected where needed
  */

@protocol ASDKServiceLocatorProtocol <NSObject>

@required

/**
 *  Adds a service to the internal object pool the underlaying class need to implement.
 *
 *  IMPORTANT NOTE:
 *  The service's class first protocol will be used for later references so this rule
 *  enforces single protocol usage for service classes to keep low coupling between classes
 *
 *  @param service The service needed to be later referenced
 */
- (void)addService:(id)service;

/**
 *  Returns a boolean value specifying whether the mentioned service is registered with
 *  the internal object pool or not.
 *
 *  @param service Service instance reference to be checked
 *
 *  @return State of the registration
 */
- (BOOL)isServiceRegistered:(id)service;

/**
 *  Returns a boolean value specifying whether an instance is registered or not with the 
 *  mentioned protocol
 *
 *  @param protocol Protocol definition to be checked for
 *
 *  @return State of the registration
 */
- (BOOL)isServiceRegisteredForProtocol:(Protocol *)protocol;

/**
 *  Returns back a service conforming to a specified protocol. Because the underlaying
 *  implementation of service classes can change or needs to be decoupled, services added
 *  to the internal object pool need to conform to a protocol and we use that protocol to 
 *  get back a reference to that service.
 *
 *  @param protocol Protocol for which we want to get back a service instance
 *
 *  @return Single service instance for which conforming to @param protocol
 */
- (id)serviceConformingToProtocol:(Protocol *)protocol;

/**
 *  Removes a service instance from the internal object pool that conforms to the specified
 *  protocol
 *
 *  @param protocol Protocol implemented by the object to be removed
 */
- (void)removeServiceConformingToProtocol:(Protocol *)protocol;

/**
 *  Removes the specified service instance from the internal object pool
 *
 *  @param service Service instance to be removed
 */
- (void)removeService:(id)service;

@end

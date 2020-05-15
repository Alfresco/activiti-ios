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

#import <Foundation/Foundation.h>

/**
 *  Notification block called on key-value change event
 *
 *  @param observer Object observing changes
 *  @param object   Object that changed
 *  @param change   Change dictionary
 */
typedef void (^ASDKKVOManagerNotificationBlock)(id observer, id object, NSDictionary *change);

@interface ASDKKVOManager : NSObject

/**
 *  The object observer registered to listen to key-value changes.
 */
@property (weak, atomic, readonly) id observer;

/**
 *  Convenience method to get a hold of a initialized KVO manager instance.
 *
 *  @param observer The object being notified with the key-value changes.
 *
 *  @return KVO manager instance
 */
+ (instancetype)managerWithObserver:(id)observer;


/**
 *  Observers key-value changes on passed object for the specified key path 
 *  and returns captured changes via a notification block.
 *  If observing an already observed key path nothing will happen.
 *  If invalid parameters (see implementation) are provided this will cause an
 *  assertion.
 *
 *  @param object            Object to be observed
 *  @param keyPath           Key path for the observed object
 *  @param options           NSKeyValueObservingOptions being fed to the KVO
 *  @param notificationBlock Block executed upon notification
 */
- (void)observeObject:(id)object
           forKeyPath:(NSString *)keyPath
              options:(NSKeyValueObservingOptions)options
                block:(ASDKKVOManagerNotificationBlock)notificationBlock;

/**
 *  Removes observer for key path
 *
 *  @param object  The object to remove the observer for
 *  @param keyPath The key path being observed
 */
- (void)removeObserver:(id)object
            forKeyPath:(NSString *)keyPath;

@end

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

@class ASDKKVOManagerInfo;

/**
 *  The purpose of this class is to act as a single and centralized proxy to requests
 *  coming from the KVOManager class extract data encapsulated inside
 *  ASDKKVOManagerInfo instances and notify changes back through provided notification
 *  blocks.
 */

@interface ASDKKVOManagerSharedProxy : NSObject

+ (instancetype)sharedInstance;

/**
 *  Registers passed object to KVO and passes on ASDKKVOManagerInfo instances as context
 *  for later internal handling inside the delegate KVO methods
 *
 *  @param object      Object to be observed
 *  @param managerInfo ASDKKVOManagerInfo instance passed by ASDKKVOManager
 */
- (void)observe:(id)object
withManagerInfo:(ASDKKVOManagerInfo *)managerInfo;

- (void)removeObserver:(id)object
       withManagerInfo:(ASDKKVOManagerInfo *)managerInfo;

@end

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
#import "AFATaskDetailsDataSourceProtocol.h"

@interface AFATaskDetailsDataSource : NSObject <AFATaskDetailsDataSourceProtocol>

@property (strong, nonatomic, readonly) UIColor     *themeColor;
@property (strong, nonatomic, readonly) NSString    *taskID;
@property (strong, nonatomic, readonly) NSString    *parentTaskID;
@property (strong, nonatomic) NSMutableDictionary   *sectionModels;
@property (strong, nonatomic) NSMutableDictionary   *cellFactories;
@property (strong, nonatomic) AFATableController    *tableController;
@property (assign, nonatomic) BOOL                  isConnectivityAvailable;

@end

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

#import "ASDKFilterCacheMapper.h"

// Model
#import "ASDKModelFilter.h"
#import "ASDKMOFilter.h"

@implementation ASDKFilterCacheMapper

+ (ASDKMOFilter *)mapFilter:(ASDKModelFilter *)filter
                  toCacheMO:(ASDKMOFilter *)moFilter {
    moFilter.modelID = filter.modelID;
    moFilter.name = filter.name;
    moFilter.sortType = filter.sortType;
    moFilter.state = filter.state;
    moFilter.assignmentType = filter.assignmentType;
    moFilter.applicationID = filter.applicationID;
    
    return moFilter;
}

+ (ASDKModelFilter *)mapCacheMOToFilter:(ASDKMOFilter *)moFilter {
    ASDKModelFilter *filter = [ASDKModelFilter new];
    filter.modelID = moFilter.modelID;
    filter.name = moFilter.name;
    filter.sortType = moFilter.sortType;
    filter.state = moFilter.state;
    filter.assignmentType = moFilter.assignmentType;
    filter.applicationID = moFilter.applicationID;
    
    return filter;
}

@end

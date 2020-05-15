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

#import "ASDKGroupCacheMapper.h"

// Models
#import "ASDKMOGroup.h"
#import "ASDKModelGroup.h"
#import "ASDKModelProfile.h"

// Mappers
#import "ASDKProfileCacheMapper.h"

@implementation ASDKGroupCacheMapper

- (ASDKMOGroup *)mapGroup:(ASDKModelGroup *)group
                toCacheMO:(ASDKMOGroup *)moGroup {
    moGroup.modelID = group.modelID;
    moGroup.tenantID = group.tenantID;
    moGroup.name = group.name;
    moGroup.externalID = group.externalID;
    moGroup.parentGroupID = group.parentGroupID;
    moGroup.groupState = group.groupState;
    moGroup.type = group.type;
    
    return moGroup;
}

- (ASDKModelGroup *)mapCacheMOToGroup:(ASDKMOGroup *)moGroup {
    ASDKModelGroup *group = [ASDKModelGroup new];
    group.modelID = moGroup.modelID;
    group.tenantID = moGroup.tenantID;
    group.name = moGroup.name;
    group.externalID = moGroup.externalID;
    group.parentGroupID = moGroup.parentGroupID;
    group.groupState = moGroup.groupState;
    group.type = moGroup.type;
    
    if (moGroup.subGroups.count) {
        ASDKGroupCacheMapper *groupMapper = [ASDKGroupCacheMapper new];
        NSMutableArray *subGroups = [NSMutableArray array];
        for (ASDKMOGroup *moSubGroup in moGroup.subGroups) {
            ASDKModelGroup *subGroup = [groupMapper mapCacheMOToGroup:moSubGroup];
            [subGroups addObject:subGroup];
        }
        group.subGroups = subGroups;
    }
    
    if (moGroup.userProfiles.count) {
        NSMutableArray *profiles = [NSMutableArray array];
        for (ASDKMOProfile *moProfile in moGroup.userProfiles) {
            ASDKModelProfile *profile = [ASDKProfileCacheMapper mapCacheMOToProfileProxy:moProfile];
            [profiles addObject:profile];
        }
        group.userProfiles = profiles;
    }
    
    return group;
}

@end

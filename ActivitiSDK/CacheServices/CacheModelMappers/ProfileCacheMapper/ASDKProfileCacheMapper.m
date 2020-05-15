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

#import "ASDKProfileCacheMapper.h"

// Models
#import "ASDKModelProfile.h"
#import "ASDKMOProfile.h"
#import "ASDKModelGroup.h"
#import "ASDKMOCurrentProfile.h"

// Mappers
#import "ASDKGroupCacheMapper.h"

@implementation ASDKProfileCacheMapper


#pragma mark -
#pragma mark Public interface

+ (ASDKMOProfile *)mapProfile:(ASDKModelProfile *)profile
                    toCacheMO:(ASDKMOProfile *)moProfile {
    moProfile.modelID = profile.modelID;
    moProfile.tenantID = profile.tenantID;
    moProfile.tenantName = profile.tenantName;
    moProfile.tenantPictureID = profile.tenantPictureID;
    moProfile.userFirstName = profile.userFirstName;
    moProfile.userLastName = profile.userLastName;
    moProfile.email = profile.email;
    moProfile.companyName = profile.email;
    moProfile.companyName = profile.companyName;
    moProfile.externalID = profile.externalID;
    moProfile.pictureID = profile.pictureID;
    moProfile.profileState = profile.profileState;
    moProfile.creationDate = profile.creationDate;
    moProfile.lastUpdate = profile.lastUpdate;
    
    return moProfile;
}

+ (ASDKMOCurrentProfile *)mapCacheMOProfile:(ASDKMOProfile *)moProfile
                    toCurrentProfileCacheMO:(ASDKMOCurrentProfile *)moCurrentProfile {
    moCurrentProfile.profile = moProfile;
    return moCurrentProfile;
}


+ (ASDKModelProfile *)mapCacheMOToProfile:(ASDKMOProfile *)moProfile {
    ASDKModelProfile *profile = [ASDKModelProfile new];
    profile.modelID = moProfile.modelID;
    profile.tenantID = moProfile.tenantID;
    profile.tenantName = moProfile.tenantName;
    profile.tenantPictureID = moProfile.tenantPictureID;
    profile.userFirstName = moProfile.userFirstName;
    profile.userLastName = moProfile.userLastName;
    profile.email = moProfile.email;
    profile.companyName = moProfile.companyName;
    profile.externalID = moProfile.externalID;
    profile.pictureID = moProfile.pictureID;
    profile.profileState = moProfile.profileState;
    profile.creationDate = moProfile.creationDate;
    profile.lastUpdate = moProfile.lastUpdate;
    
    if (moProfile.groups.count) {
        ASDKGroupCacheMapper *groupMapper = [ASDKGroupCacheMapper new];
        NSMutableArray *groups = [NSMutableArray array];
        for (ASDKMOGroup *moGroup in moProfile.groups) {
            ASDKModelGroup *group = [groupMapper mapCacheMOToGroup:moGroup];
            [groups addObject:group];
        }
        profile.groups = groups;
    }
    
    return profile;
}

+ (ASDKModelProfile *)mapCacheMOToProfileProxy:(ASDKMOProfile *)moProfile {
    ASDKModelProfile *profile = [ASDKModelProfile new];
    profile.modelID = moProfile.modelID;
    
    return profile;
}

@end

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

#import "ASDKGroupCacheModelUpsert.h"

// Models
#import "ASDKModelGroup.h"
#import "ASDKModelProfile.h"
#import "ASDKMOGroup.h"
#import "ASDKMOProfile.h"

// Model mappers
#import "ASDKGroupCacheMapper.h"
#import "ASDKProfileCacheMapper.h"

// Model upsert
#import "ASDKProfileCacheModelUpsert.h"

@implementation ASDKGroupCacheModelUpsert

+ (ASDKMOGroup *)upsertGroupToCache:(ASDKModelGroup *)group
                              error:(NSError **)error
                        inMOContext:(NSManagedObjectContext *)moContext {
    NSError *internalError = nil;
    ASDKMOGroup *moGroup = nil;
    ASDKGroupCacheMapper *groupCacheMapper = [ASDKGroupCacheMapper new];
    
    NSFetchRequest *fetchGroupRequest = [ASDKMOGroup fetchRequest];
    fetchGroupRequest.predicate = [NSPredicate predicateWithFormat:@"modelID == %@", group.modelID];
    NSArray *groupResults = [moContext executeFetchRequest:fetchGroupRequest
                                                     error:&internalError];
    if (!internalError) {
        moGroup = groupResults.firstObject;
        if (!moGroup) {
            moGroup = [NSEntityDescription insertNewObjectForEntityForName:[ASDKMOGroup entityName]
                                                    inManagedObjectContext:moContext];
        }
        
        // Map group properties to managed object
        [groupCacheMapper mapGroup:group
                         toCacheMO:moGroup];
        
        // Map subgroup to group managed object
        if (group.subGroups.count) {
            for (ASDKModelGroup *subGroup in group.subGroups) {
                ASDKMOGroup *moSubGroup = [self upsertGroupToCache:subGroup
                                                             error:&internalError
                                                       inMOContext:moContext];
                if (internalError) {
                    [moGroup addSubGroupsObject:moSubGroup];
                }
            }
        }
        
        // Map user profiles to group mananged object
        if (group.userProfiles.count) {
            for (ASDKModelProfile *profile in group.userProfiles) {
                ASDKMOProfile *moProfile = [ASDKProfileCacheModelUpsert upsertProfileToCache:profile
                                                                                       error:&internalError
                                                                                 inMOContext:moContext];
                
                if (!internalError) {
                    [moGroup addUserProfilesObject:moProfile];
                }
            }
        }
    }
    
    *error = internalError;
    return moGroup;
}

@end

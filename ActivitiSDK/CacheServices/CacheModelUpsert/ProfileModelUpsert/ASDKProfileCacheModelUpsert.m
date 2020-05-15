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

#import "ASDKProfileCacheModelUpsert.h"

// Models
#import "ASDKModelProfile.h"
#import "ASDKModelGroup.h"
#import "ASDKMOProfile.h"
#import "ASDKMOGroup.h"

// Model mappers
#import "ASDKProfileCacheMapper.h"

// Model upsert
#import "ASDKGroupCacheModelUpsert.h"

@implementation ASDKProfileCacheModelUpsert

+ (ASDKMOProfile *)upsertProfileToCache:(ASDKModelProfile *)profile
                                  error:(NSError **)error
                            inMOContext:(NSManagedObjectContext *)moContext {
    NSError *internalError = nil;
    ASDKMOProfile *moProfile = nil;
    
    NSFetchRequest *fetchProfileRequest = [ASDKMOProfile fetchRequest];
    fetchProfileRequest.predicate = [NSPredicate predicateWithFormat:@"modelID == %@", profile.modelID];
    NSArray *profileResults = [moContext executeFetchRequest:fetchProfileRequest
                                                       error:&internalError];
    if (!internalError) {
        moProfile = profileResults.firstObject;
        if (!moProfile) {
            moProfile = [NSEntityDescription insertNewObjectForEntityForName:[ASDKMOProfile entityName]
                                                      inManagedObjectContext:moContext];
        }
        
        // Map profile properties to managed object
        [ASDKProfileCacheMapper mapProfile:profile
                                 toCacheMO:moProfile];
        
        // Map group to managed object
        if (profile.groups.count) {
            for (ASDKModelGroup *group in profile.groups) {
                ASDKMOGroup *moGroup = [ASDKGroupCacheModelUpsert upsertGroupToCache:group
                                                                               error:&internalError
                                                                         inMOContext:moContext];
                [moProfile addGroupsObject:moGroup];
            }
        }
    }
    
    *error = internalError;
    return moProfile;
}

@end

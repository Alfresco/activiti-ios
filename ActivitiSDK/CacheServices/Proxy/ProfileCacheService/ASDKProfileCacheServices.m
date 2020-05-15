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

#import "ASDKProfileCacheServices.h"

// Models
#import "ASDKModelProfile.h"
#import "ASDKMOProfile.h"
#import "ASDKMOCurrentProfile.h"

// Model upsert
#import "ASDKProfileCacheModelUpsert.h"
#import "ASDKGroupCacheModelUpsert.h"

// Persistence
#import "ASDKProfileCacheMapper.h"

@implementation ASDKProfileCacheServices


#pragma mark -
#pragma mark Public interface

- (void)cacheCurrentUserProfile:(ASDKModelProfile *)profile
            withCompletionBlock:(ASDKCacheServiceCompletionBlock)completionBlock {
    [self.persistenceStack performBackgroundTask:^(NSManagedObjectContext *managedObjectContext) {
        managedObjectContext.automaticallyMergesChangesFromParent = YES;
        managedObjectContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;
        
        NSError *error = nil;
        
        NSFetchRequest *fetchCurrentProfileRequest = [ASDKMOCurrentProfile fetchRequest];
        NSArray *currentProfileResults = [managedObjectContext executeFetchRequest:fetchCurrentProfileRequest
                                                                             error:&error];
        
        if (!error) {
            ASDKMOCurrentProfile *moCurrentProfile = currentProfileResults.firstObject;
            if (!moCurrentProfile) {
                moCurrentProfile = [NSEntityDescription insertNewObjectForEntityForName:[ASDKMOCurrentProfile entityName]
                                                                 inManagedObjectContext:managedObjectContext];
            }
            ASDKMOProfile *moProfile = [ASDKProfileCacheModelUpsert upsertProfileToCache:profile
                                                                                   error:&error
                                                                             inMOContext:managedObjectContext];
            if (!error) {
                [ASDKProfileCacheMapper mapCacheMOProfile:moProfile
                                  toCurrentProfileCacheMO:moCurrentProfile];
            }
            
        }
        
        [managedObjectContext save:&error];
        
        if (completionBlock) {
            completionBlock(error);
        }
    }];
}

- (void)fetchCurrentUserProfile:(ASDKCacheServiceProfileCompletionBlock)profileCompletionBlock {
    [self.persistenceStack  performBackgroundTask:^(NSManagedObjectContext *managedObjectContext) {
        managedObjectContext.automaticallyMergesChangesFromParent = YES;
        managedObjectContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;
        
        NSError *error = nil;
        
        NSFetchRequest *fetchRequest = [ASDKMOCurrentProfile fetchRequest];
        NSArray *fetchResults = [managedObjectContext executeFetchRequest:fetchRequest
                                                                    error:&error];
        
        if (profileCompletionBlock) {
            ASDKMOCurrentProfile *moCurrentProfile = fetchResults.firstObject;
            ASDKMOProfile *moProfile = moCurrentProfile.profile;
            
            if (error || !moProfile) {
                profileCompletionBlock(nil, error);
            } else {
                ASDKModelProfile *profile = [ASDKProfileCacheMapper mapCacheMOToProfile:moProfile];
                profileCompletionBlock(profile, nil);
            }
        }
    }];
}

@end

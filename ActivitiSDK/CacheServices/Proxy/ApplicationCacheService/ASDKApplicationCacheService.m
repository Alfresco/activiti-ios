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

#import "ASDKApplicationCacheService.h"

// Models
#import "ASDKModelApp.h"
#import "ASDKMOApp.h"

// Persistence
#import "ASDKApplicationCacheMapper.h"


@implementation ASDKApplicationCacheService


#pragma mark -
#pragma mark Public interface

- (void)cacheRuntimeApplicationDefinitions:(NSArray *)appDefinitionList
                      withtCompletionBlock:(ASDKCacheServiceCompletionBlock)completionBlock {
    [self.persistenceStack performBackgroundTask:^(NSManagedObjectContext *managedObjectContext) {
        managedObjectContext.automaticallyMergesChangesFromParent = YES;
        managedObjectContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;
        
        NSError *error = nil;
        NSFetchRequest *oldAppsFetchRequest = [ASDKMOApp fetchRequest];
        NSBatchDeleteRequest *removeOldAppsRequest = [[NSBatchDeleteRequest alloc] initWithFetchRequest:oldAppsFetchRequest];
        removeOldAppsRequest.resultType = NSBatchDeleteResultTypeObjectIDs;
        
        NSBatchDeleteResult *deletionResult = [managedObjectContext executeRequest:removeOldAppsRequest
                                                                             error:&error];
        NSArray *moIDArr = deletionResult.result;
        [NSManagedObjectContext mergeChangesFromRemoteContextSave:@{NSDeletedObjectsKey : moIDArr}
                                                     intoContexts:@[managedObjectContext]];
        
        if (!error) {
            for (ASDKModelApp *app in appDefinitionList) {
                ASDKMOApp *moApp = [NSEntityDescription insertNewObjectForEntityForName:[ASDKMOApp entityName]
                                                                 inManagedObjectContext:managedObjectContext];
                [ASDKApplicationCacheMapper mapApp:app
                                         toCacheMO:moApp];
            }
            
            [managedObjectContext save:&error];
        }
        
        if (completionBlock) {
            completionBlock(error);
        }
    }];
}

- (void)fetchRuntimeApplicationDefinitions:(ASDKCacheServiceAppCompletionBlock)completionBlock {
    [self.persistenceStack  performBackgroundTask:^(NSManagedObjectContext *managedObjectContext) {
        NSFetchRequest *fetchRequest = [ASDKMOApp fetchRequest];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"deploymentID != nil"];
        
        NSError *error = nil;
        NSArray *fetchResults = [managedObjectContext executeFetchRequest:fetchRequest
                                                                    error:&error];
        
        fetchResults = [fetchResults sortedArrayUsingDescriptors:
                        @[[NSSortDescriptor sortDescriptorWithKey:@"modelID"
                                                        ascending:YES
                                                       comparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
                                                           return [obj1 compare:obj2
                                                                        options:NSNumericSearch];
                                                       }]]];
        
        NSMutableArray *applications = [NSMutableArray array];
        for (ASDKMOApp *moApp in fetchResults) {
            ASDKModelApp *app = [ASDKApplicationCacheMapper mapCacheMOToApp:moApp];
            [applications addObject:app];
        }
        
        if (completionBlock) {
            if (error || !applications.count) {
                completionBlock(nil, error);
            } else {
                completionBlock(applications, nil);
            }
        }
    }];
}

@end

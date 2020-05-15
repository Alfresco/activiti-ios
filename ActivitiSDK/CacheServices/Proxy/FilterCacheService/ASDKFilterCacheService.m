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

#import "ASDKFilterCacheService.h"

// Model
#import "ASDKModelFilter.h"
#import "ASDKMOFilter.h"
#import "ASDKFilterListRequestRepresentation.h"

// Persistence
#import "ASDKFilterCacheMapper.h"


@implementation ASDKFilterCacheService


#pragma mark -
#pragma mark Public interface

- (void)cacheDefaultTaskFilterList:(NSArray *)filterList
               withCompletionBlock:(ASDKCacheServiceCompletionBlock)completionBlock {
    __weak typeof(self) weakSelf = self;
    
    [self.persistenceStack performBackgroundTask:^(NSManagedObjectContext *managedObjectContext) {
        __strong typeof(self) strongSelf = weakSelf;
        
        [strongSelf cacheTaskFilterList:filterList
                         usingPredicate:[strongSelf adhocTaskFilterPredicate]
                 inManagedObjectContext:managedObjectContext
                    withCompletionBlock:completionBlock];
    }];
}

- (void)cacheTaskFilterList:(NSArray *)filterList
                usingFilter:(ASDKFilterListRequestRepresentation *)filter
        withCompletionBlock:(ASDKCacheServiceCompletionBlock)completionBlock {
    __weak typeof(self) weakSelf = self;
    
    [self.persistenceStack performBackgroundTask:^(NSManagedObjectContext *managedObjectContext) {
        __strong typeof(self) strongSelf = weakSelf;
        
        [strongSelf cacheTaskFilterList:filterList
                         usingPredicate:[strongSelf appTaskFilterPredicateForAppID:filter.appID]
                 inManagedObjectContext:managedObjectContext
                    withCompletionBlock:completionBlock];
    }];
}

- (void)fetchDefaultTaskFilterList:(ASDKCacheServiceFilterListCompletionBlock)completionBlock {
    __weak typeof(self) weakSelf = self;
    
    [self.persistenceStack performBackgroundTask:^(NSManagedObjectContext *managedObjectContext) {
        __strong typeof(self) strongSelf = weakSelf;
        
        [strongSelf fetchFilterListUsingPredicate:[strongSelf adhocTaskFilterPredicate]
                               inManagedObjectContext:managedObjectContext
                                  withCompletionBlock:completionBlock];
    }];
}

- (void)fetchTaskFilterList:(ASDKCacheServiceFilterListCompletionBlock)completionBlock
                usingFilter:(ASDKFilterListRequestRepresentation *)filter {
    __weak typeof(self) weakSelf = self;
    
    [self.persistenceStack performBackgroundTask:^(NSManagedObjectContext *managedObjectContext) {
        __strong typeof(self) strongSelf = weakSelf;
        
        [strongSelf fetchFilterListUsingPredicate:[strongSelf appTaskFilterPredicateForAppID:filter.appID]
                               inManagedObjectContext:managedObjectContext
                                  withCompletionBlock:completionBlock];
    }];
}

- (void)cacheDefaultProcessInstanceFilterList:(NSArray *)filterList
                          withCompletionBlock:(ASDKCacheServiceCompletionBlock)completionBlock {
    __weak typeof(self) weakSelf = self;
    [self.persistenceStack performBackgroundTask:^(NSManagedObjectContext *managedObjectContext) {
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf cacheProcessInstanceFilterList:filterList
                                    usingPredicate:[strongSelf adhocProcessInstanceFilterPredicate]
                            inManagedObjectContext:managedObjectContext
                               withCompletionBlock:completionBlock];
    }];
}

- (void)cacheProcessInstanceFilterList:(NSArray *)filterList
                           usingFilter:(ASDKFilterListRequestRepresentation *)filter
                   withCompletionBlock:(ASDKCacheServiceCompletionBlock)completionBlock {
    __weak typeof(self) weakSelf = self;
    
    [self.persistenceStack performBackgroundTask:^(NSManagedObjectContext *managedObjectContext) {
        __strong typeof(self) strongSelf = weakSelf;
        
        [strongSelf cacheProcessInstanceFilterList:filterList
                                    usingPredicate:[strongSelf appProcessInstanceFilterPredicateForAppID:filter.appID] inManagedObjectContext:managedObjectContext
                               withCompletionBlock:completionBlock];
    }];
}

- (void)fetchDefaultProcessInstanceFilterList:(ASDKCacheServiceFilterListCompletionBlock)completionBlock {
    __weak typeof(self) weakSelf = self;
    
    [self.persistenceStack performBackgroundTask:^(NSManagedObjectContext *managedObjectContext) {
        __strong typeof(self) strongSelf = weakSelf;
        
        [strongSelf fetchFilterListUsingPredicate:[strongSelf adhocProcessInstanceFilterPredicate]
                           inManagedObjectContext:managedObjectContext
                              withCompletionBlock:completionBlock];
    }];
}

- (void)fetchProcessInstanceFilterList:(ASDKCacheServiceFilterListCompletionBlock)completionBlock
                           usingFilter:(ASDKFilterListRequestRepresentation *)filter {
    __weak typeof(self) weakSelf = self;
    
    [self.persistenceStack performBackgroundTask:^(NSManagedObjectContext *managedObjectContext) {
        __strong typeof(self) strongSelf = weakSelf;
        
        [strongSelf fetchFilterListUsingPredicate:[strongSelf appProcessInstanceFilterPredicateForAppID:filter.appID]
                           inManagedObjectContext:managedObjectContext
                              withCompletionBlock:completionBlock];
    }];
}


#pragma mark -
#pragma mark Private interface

- (void)cacheTaskFilterList:(NSArray *)filterList
             usingPredicate:(NSPredicate *)predicate
     inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
        withCompletionBlock:(ASDKCacheServiceCompletionBlock)completionBlock {
    [self cacheFilterList:filterList
           usingPredicate:predicate
   inManagedObjectContext:managedObjectContext
      withCompletionBlock:completionBlock
             isTaskFilter:YES];
}

- (void)cacheProcessInstanceFilterList:(NSArray *)filterList
                        usingPredicate:(NSPredicate *)predicate
                inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
                   withCompletionBlock:(ASDKCacheServiceCompletionBlock)completionBlock {
    [self cacheFilterList:filterList
           usingPredicate:predicate
   inManagedObjectContext:managedObjectContext
      withCompletionBlock:completionBlock
             isTaskFilter:NO];
}

- (void)cacheFilterList:(NSArray *)filterList
         usingPredicate:(NSPredicate *)predicate
 inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
    withCompletionBlock:(ASDKCacheServiceCompletionBlock)completionBlock
           isTaskFilter:(BOOL)isTaskFilter {
    managedObjectContext.automaticallyMergesChangesFromParent = YES;
    managedObjectContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;
    
    NSError *error = nil;
    NSFetchRequest *oldFiltersFetchRequest = [ASDKMOFilter fetchRequest];
    oldFiltersFetchRequest.predicate = predicate;
    
    NSBatchDeleteRequest *removeOldDefaultTaskFiltersRequest = [[NSBatchDeleteRequest alloc] initWithFetchRequest:oldFiltersFetchRequest];
    removeOldDefaultTaskFiltersRequest.resultType = NSBatchDeleteResultTypeObjectIDs;
    
    NSBatchDeleteResult *deletionResult = [managedObjectContext executeRequest:removeOldDefaultTaskFiltersRequest
                                                                         error:&error];
    NSArray *moIDArr = deletionResult.result;
    [NSManagedObjectContext mergeChangesFromRemoteContextSave:@{NSDeletedObjectsKey : moIDArr}
                                                 intoContexts:@[managedObjectContext]];
    
    if (!error) {
        for (ASDKModelFilter *filter in filterList) {
            ASDKMOFilter *moFilter = [NSEntityDescription insertNewObjectForEntityForName:[ASDKMOFilter entityName]
                                                                   inManagedObjectContext:managedObjectContext];
            moFilter = [ASDKFilterCacheMapper mapFilter:filter
                                              toCacheMO:moFilter];
            moFilter.isTaskFilter = isTaskFilter;
        }
        
        [managedObjectContext save:&error];
    }
    
    if (completionBlock) {
        completionBlock(error);
    }
}

- (void)fetchFilterListUsingPredicate:(NSPredicate *)predicate
               inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
                  withCompletionBlock:(ASDKCacheServiceFilterListCompletionBlock)completionBlock {
    NSFetchRequest *fetchRequest = [ASDKMOFilter fetchRequest];
    fetchRequest.predicate = predicate;
    
    NSError *error = nil;
    NSArray *fetchResults = [managedObjectContext executeFetchRequest:fetchRequest
                                                                error:&error];
    fetchResults = [fetchResults sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"modelID"
                                                                                             ascending:YES
                                                                                            comparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
                                                                                                return [obj1 compare:obj2
                                                                                                             options:NSNumericSearch];
                                                                                            }]]];
    
    NSMutableArray *taskFilters = [NSMutableArray array];
    for (ASDKMOFilter *moFilter in fetchResults) {
        ASDKModelFilter *filter = [ASDKFilterCacheMapper mapCacheMOToFilter:moFilter];
        [taskFilters addObject:filter];
    }
    
    if (completionBlock) {
        if (error || !taskFilters.count) {
            completionBlock(nil, error, nil);
        } else {
            ASDKModelPaging *paging = [ASDKModelPaging new];
            paging.size = taskFilters.count;
            paging.total = taskFilters.count;
            
            completionBlock(taskFilters, nil, paging);
        }
    }
}


#pragma mark -
#pragma mark Predicate construction

- (NSPredicate *)adhocTaskFilterPredicate {
    return [NSPredicate predicateWithFormat:@"isTaskFilter == YES AND applicationID == nil"];
}

- (NSPredicate *)appTaskFilterPredicateForAppID:(NSString *)appID {
    return [NSPredicate predicateWithFormat:@"isTaskFilter == YES && applicationID == %@", appID];
}

- (NSPredicate *)adhocProcessInstanceFilterPredicate {
    return [NSPredicate predicateWithFormat:@"isTaskFilter == NO AND applicationID == nil"];
}

- (NSPredicate *)appProcessInstanceFilterPredicateForAppID:(NSString *)appID {
    return [NSPredicate predicateWithFormat:@"isTaskFilter == NO && applicationID == %@", appID];
}

@end

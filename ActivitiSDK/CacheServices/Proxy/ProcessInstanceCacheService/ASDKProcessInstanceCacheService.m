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

#import "ASDKProcessInstanceCacheService.h"

// Constants
#import "ASDKPersistenceStackConstants.h"

// Model upsert
#import "ASDKProcessInstanceCacheModelUpsert.h"
#import "ASDKProcessInstanceContentCacheModelUpsert.h"
#import "ASDKCommentCacheModelUpsert.h"

// Models
#import "ASDKFilterRequestRepresentation.h"
#import "ASDKMOProcessInstance.h"
#import "ASDKMOProcessInstanceFilterMap.h"
#import "ASDKModelPaging.h"
#import "ASDKModelFilter.h"
#import "ASDKModelProcessInstance.h"
#import "ASDKMOProcessInstanceFilterMapPlaceholder.h"
#import "ASDKMOProcessInstanceContent.h"
#import "ASDKMOProcessInstanceCommentMap.h"

// Persistence
#import "ASDKProcessInstanceCacheMapper.h"
#import "ASDKProcessInstanceFilterMapCacheMapper.h"
#import "ASDKProcessInstanceContentCacheMapper.h"
#import "ASDKProcessInstanceCommentMapCacheMapper.h"
#import "ASDKCommentCacheMapper.h"

@implementation ASDKProcessInstanceCacheService


#pragma mark -
#pragma mark Public interface

- (void)cacheProcessInstanceList:(NSArray *)processInstanceList
                     usingFilter:(ASDKFilterRequestRepresentation *)filter
             withCompletionBlock:(ASDKCacheServiceCompletionBlock)completionBlock {
    __weak typeof(self) weakSelf = self;
    [self.persistenceStack performBackgroundTask:^(NSManagedObjectContext *managedObjectContext) {
        __strong typeof(self) strongSelf = weakSelf;
        managedObjectContext.automaticallyMergesChangesFromParent = YES;
        managedObjectContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;
        
        /* When fetching the first page of process instances for a specific application
         remove all references to existing process instances and clear the process instance filter map
         
         Note: The process instance filter map exists to provide membership information for
         process instances in relation to a specific filter and application.
         */
        NSError *error = nil;
        if (!filter.page &&
            ASDKModelFilterStateTypeAll != filter.filterModel.state) {
            error = [strongSelf cleanStalledProcessInstancesInContext:managedObjectContext
                                                            forFilter:filter];
        }
        
        if (!error) {
            error = [strongSelf saveProcessInstanceListAndGenerateFilterMap:processInstanceList
                                                                  forFilter:filter
                                                                  inContext:managedObjectContext];
        }
        
        if (!error) {
            [managedObjectContext save:&error];
        }
        
        if (completionBlock) {
            completionBlock(error);
        }
    }];
}

- (void)fetchProcessInstanceList:(ASDKCacheServiceProcessInstanceListCompletionBlock)completionBlock
                     usingFilter:(ASDKFilterRequestRepresentation *)filter {
    __weak typeof(self) weakSelf = self;
    [self.persistenceStack performBackgroundTask:^(NSManagedObjectContext *managedObjectContext) {
        __strong typeof(self) strongSelf = weakSelf;
        
        ASDKModelPaging *paging = nil;
        NSError *error = nil;
        NSArray *pagedProcessInstanceArr = nil;
        
        NSFetchRequest *processInstanceFilterMapRequest = [ASDKMOProcessInstanceFilterMap fetchRequest];
        if (ASDKModelFilterStateTypeAll == filter.filterModel.state) {
            processInstanceFilterMapRequest.predicate = [self allFilterMapsOnCurrentApplicationForFilter:filter];
        } else {
            processInstanceFilterMapRequest.predicate = [self filterMapMembershipPredicateForFilter:filter];
        }
        
        NSArray *processInstanceFilterMapArr = [managedObjectContext executeFetchRequest:processInstanceFilterMapRequest
                                                                                   error:&error];
        
        if (!error) {
            NSMutableArray *allProcessInstanceFilterMapPlaceholdersOfCurrentApp = [NSMutableArray array];
            NSArray *processInstances = nil;
            
            for (ASDKMOProcessInstanceFilterMap *processInstanceFilterMap in processInstanceFilterMapArr) {
                [allProcessInstanceFilterMapPlaceholdersOfCurrentApp addObjectsFromArray:processInstanceFilterMap.processInstancePlaceholders.allObjects];
            }
            
            NSArray *processInstancesIDs = [allProcessInstanceFilterMapPlaceholdersOfCurrentApp valueForKey:@"modelID"];
            
            if (processInstancesIDs.count) {
                NSFetchRequest *processInstanceFetchRequest = [ASDKMOProcessInstance fetchRequest];
                processInstanceFetchRequest.predicate = [NSPredicate predicateWithFormat:@"modelID IN %@", processInstancesIDs];
                processInstances = [managedObjectContext executeFetchRequest:processInstanceFetchRequest
                                                                       error:&error];
            }
            
            if (!error) {
                NSArray *sortedProcessInstances = nil;
                NSSortDescriptor *sortDescriptorForFilter = [strongSelf sortDescriptorForFilter:filter];
                
                if (sortDescriptorForFilter) {
                    sortedProcessInstances = [processInstances sortedArrayUsingDescriptors:@[[strongSelf sortDescriptorForFilter:filter]]];
                } else {
                    sortedProcessInstances = processInstances;
                }
                
                NSPredicate *namePredicate = [strongSelf namePredicateForFilter:filter];
                
                NSArray *matchingProcessInstanceArr = nil;
                if (namePredicate) {
                    matchingProcessInstanceArr = [sortedProcessInstances filteredArrayUsingPredicate:namePredicate];
                } else {
                    matchingProcessInstanceArr = sortedProcessInstances;
                }
                
                NSUInteger fetchOffset = filter.size * filter.page;
                NSInteger location = matchingProcessInstanceArr.count - fetchOffset;
                NSInteger length = MIN(location, filter.size);
                if (length >= 0) {
                    pagedProcessInstanceArr = [matchingProcessInstanceArr subarrayWithRange:NSMakeRange(fetchOffset, length)];
                }
                
                paging = [strongSelf paginationWithStartIndex:filter.size * filter.page
                                            forTotalTaskCount:sortedProcessInstances.count
                                           remainingTaskCount:length];
            }
        }
        
        if (completionBlock) {
            if (error || !pagedProcessInstanceArr.count) {
                completionBlock(nil, error, paging);
            } else {
                NSMutableArray *processInstances = [NSMutableArray array];
                for (ASDKMOProcessInstance *moProcessInstance in pagedProcessInstanceArr) {
                    ASDKModelProcessInstance *processInstance = [ASDKProcessInstanceCacheMapper mapCacheMOToProcessInstance:moProcessInstance];
                    [processInstances addObject:processInstance];
                }
                
                completionBlock(processInstances, nil, paging);
            }
        }
    }];
}

- (void)cacheProcessInstanceDetails:(ASDKModelProcessInstance *)processInstance
                withCompletionBlock:(ASDKCacheServiceCompletionBlock)completionBlock {
    [self.persistenceStack performBackgroundTask:^(NSManagedObjectContext *managedObjectContext) {
        managedObjectContext.automaticallyMergesChangesFromParent = YES;
        managedObjectContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;
        
        NSError *error = nil;
        [ASDKProcessInstanceCacheModelUpsert upsertProcessInstanceToCache:processInstance
                                                                    error:&error
                                                              inMOContext:managedObjectContext];
        
        if (!error) {
            [managedObjectContext save:&error];
        }
        
        if (completionBlock) {
            completionBlock(error);
        }
    }];
}

- (void)fetchProcesInstanceDetailsForID:(NSString *)processInstanceID
                    withCompletionBlock:(ASDKCacheServiceProcessInstanceDetailsCompletionBlock)completionBlock {
    [self.persistenceStack performBackgroundTask:^(NSManagedObjectContext *managedObjectContext) {
        NSFetchRequest *fetchRequest = [ASDKMOProcessInstance fetchRequest];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"modelID == %@", processInstanceID];
        
        NSError *error = nil;
        NSArray *fetchResults = [managedObjectContext executeFetchRequest:fetchRequest
                                                                    error:&error];
        
        if (completionBlock) {
            ASDKMOProcessInstance *moProcessInstance = fetchResults.firstObject;
            
            if (error || !moProcessInstance) {
                completionBlock(nil, error);
            } else {
                ASDKModelProcessInstance *processInstance = [ASDKProcessInstanceCacheMapper mapCacheMOToProcessInstance:moProcessInstance];
                completionBlock(processInstance, nil);
            }
        }
    }];
}

- (void)cacheProcessInstanceContent:(NSArray *)contentList
               forProcessInstanceID:(NSString *)processInstanceID
                withCompletionBlock:(ASDKCacheServiceCompletionBlock)completionBlock {
    __weak typeof(self) weakSelf = self;
    [self.persistenceStack performBackgroundTask:^(NSManagedObjectContext *managedObjectContext) {
        __strong typeof(self) strongSelf = weakSelf;
        managedObjectContext.automaticallyMergesChangesFromParent = YES;
        managedObjectContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;
        
        NSError *error = [strongSelf cleanStalledProcessInstanceContentInContext:managedObjectContext
                                                            forProcessInstanceID:processInstanceID];
        
        if (!error) {
            [ASDKProcessInstanceContentCacheModelUpsert upsertProcessInstanceContentListToCache:contentList
                                                                           forProcessInstanceID:processInstanceID
                                                                                          error:&error
                                                                                    inMOContext:managedObjectContext];
        }
        
        if (!error) {
            [managedObjectContext save:&error];
        }
        
        if (completionBlock) {
            completionBlock(error);
        }
    }];
}

- (void)fetchProcessInstanceContentForID:(NSString *)processInstanceID
                     withCompletionBlock:(ASDKCacheServiceProcessInstanceContentListCompletionBlock)completionBlock {
    [self.persistenceStack performBackgroundTask:^(NSManagedObjectContext *managedObjectContext) {
        NSFetchRequest *fetchRequest = [ASDKMOProcessInstanceContent fetchRequest];
        fetchRequest.predicate = [self processInstancePredicateForProcessInstanceID:processInstanceID];
        
        NSError *error = nil;
        NSArray *moProcessInstanceContentArr = [managedObjectContext executeFetchRequest:fetchRequest
                                                                                   error:&error];
        if (completionBlock) {
            if (error || !moProcessInstanceContentArr.count) {
                completionBlock(nil, error);
            } else {
                NSMutableArray *processInstanceContentArr = [NSMutableArray array];
                for (ASDKMOProcessInstanceContent *moContent in moProcessInstanceContentArr) {
                    ASDKModelProcessInstanceContent *content = [ASDKProcessInstanceContentCacheMapper mapCacheMOToProcessInstanceContent:moContent];
                    [processInstanceContentArr addObject:content];
                }
                
                completionBlock(processInstanceContentArr, nil);
            }
        }
    }];
}

- (void)cacheProcessInstanceCommentList:(NSArray *)commentList
                   forProcessInstanceID:(NSString *)processInstanceID
                    withCompletionBlock:(ASDKCacheServiceCompletionBlock)completionBlock {
    __weak typeof(self) weakSelf = self;
    [self.persistenceStack performBackgroundTask:^(NSManagedObjectContext *managedObjectContext) {
        __strong typeof(self) strongSelf = weakSelf;
        managedObjectContext.automaticallyMergesChangesFromParent = YES;
        managedObjectContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;
        
        NSError *error = [strongSelf cleanStalledCommentsAndProcessInstanceCommentMapForProcessInstanceID:processInstanceID
                                                                                                inContext:managedObjectContext];
        
        if (!error) {
            /* The comment map exists to provide membership information for comments
             * in relation to a specific process instance. Just the state of the comment
             * objects do not provide sufficient information to assign them to a task.
             */
            error = [strongSelf saveProcessInstanceCommentsAndGenerateCommentMap:commentList
                                                            forProcessInstanceID:processInstanceID
                                                                       inContext:managedObjectContext];
        }
        
        if (!error) {
            [managedObjectContext save:&error];
        }
        
        if (completionBlock) {
            completionBlock(error);
        }
    }];
}

- (void)fetchProcessInstanceCommentListForID:(NSString *)processInstanceID
                         withCompletionBlock:(ASDKCacheServiceProcessInstanceCommentListCompletionBlock)completionBlock {
    __weak typeof(self) weakSelf = self;
    [self.persistenceStack performBackgroundTask:^(NSManagedObjectContext *managedObjectContext) {
        __strong typeof(self) strongSelf = weakSelf;
        
        ASDKModelPaging *paging = nil;
        NSError *error = nil;
        NSArray *matchingCommentsArr = nil;
        
        NSFetchRequest *processInstanceCommentMapRequest = [ASDKMOProcessInstanceCommentMap fetchRequest];
        processInstanceCommentMapRequest.predicate = [self processInstancePredicateForProcessInstanceID:processInstanceID];
        NSArray *processInstanceCommentMapArr = [managedObjectContext executeFetchRequest:processInstanceCommentMapRequest
                                                                                    error:&error];
        
        if (!error) {
            ASDKMOProcessInstanceCommentMap *processInstanceCommentMap = processInstanceCommentMapArr.firstObject;
            matchingCommentsArr = [processInstanceCommentMap.processInstanceCommentList allObjects];
            paging = [strongSelf paginationWithStartIndex:0
                                        forTotalTaskCount:matchingCommentsArr.count
                                       remainingTaskCount:matchingCommentsArr.count];
        }
        
        if (completionBlock) {
            if (error || !matchingCommentsArr.count) {
                completionBlock(nil, error, nil);
            } else {
                NSMutableArray *comments = [NSMutableArray array];
                for (ASDKMOComment *moComment in matchingCommentsArr) {
                    ASDKModelComment *comment = [ASDKCommentCacheMapper mapCacheMOToComment:moComment];
                    [comments addObject:comment];
                }
                
                completionBlock(comments, nil, paging);
            }
        }
    }];
}


#pragma mark -
#pragma mark Operations

- (NSError *)cleanStalledProcessInstancesInContext:(NSManagedObjectContext *)managedObjectContext
                                         forFilter:(ASDKFilterRequestRepresentation *)filter {
    NSError *internalError = nil;
    
    NSFetchRequest *oldProcessInstanceFilterMapRequest = [ASDKMOProcessInstanceFilterMap fetchRequest];
    oldProcessInstanceFilterMapRequest.predicate = [self filterMapMembershipPredicateForFilter:filter];
    oldProcessInstanceFilterMapRequest.resultType = NSManagedObjectIDResultType;
    
    NSBatchDeleteRequest *removeOldProcessInstanceFilterMapRequest = [[NSBatchDeleteRequest alloc] initWithFetchRequest:oldProcessInstanceFilterMapRequest];
    removeOldProcessInstanceFilterMapRequest.resultType = NSBatchDeleteResultTypeObjectIDs;
    NSBatchDeleteResult *removeOldProcessInstanceFilterMapResult = [managedObjectContext executeRequest:removeOldProcessInstanceFilterMapRequest
                                                                                                  error:&internalError];
    NSArray *moIDArr = removeOldProcessInstanceFilterMapResult.result;
    [NSManagedObjectContext mergeChangesFromRemoteContextSave:@{NSDeletedObjectsKey : moIDArr}
                                                 intoContexts:@[managedObjectContext]];
    if (internalError) {
        return [self clearCacheStalledDataError];
    }
    
    return nil;
}

- (NSError *)saveProcessInstanceListAndGenerateFilterMap:(NSArray *)processInstanceList
                                               forFilter:(ASDKFilterRequestRepresentation *)filter
                                               inContext:(NSManagedObjectContext *)managedObjectContext {
    // Upsert process instances
    NSError *error = nil;
    NSArray *moProcessInstanceList = [ASDKProcessInstanceCacheModelUpsert upsertProcessInstanceListToCache:processInstanceList
                                                                                                     error:&error
                                                                                               inMOContext:managedObjectContext];
    if (error) {
        return error;
    }
    
    // Fetch existing or create a process instance filter map
    NSFetchRequest *processInstanceFilterMapFetchRequest = [ASDKMOProcessInstanceFilterMap fetchRequest];
    processInstanceFilterMapFetchRequest.predicate = [self filterMapMembershipPredicateForFilter:filter];
    NSArray *fetchResults = [managedObjectContext executeFetchRequest:processInstanceFilterMapFetchRequest
                                                                error:&error];
    if (error) {
        return error;
    }
    
    ASDKMOProcessInstanceFilterMap *processInstanceFilterMap = fetchResults.firstObject;
    if (!processInstanceFilterMap) {
        processInstanceFilterMap = [NSEntityDescription insertNewObjectForEntityForName:[ASDKMOProcessInstanceFilterMap entityName]
                                                                 inManagedObjectContext:managedObjectContext];
    }
    
    // Populate the process instance filter map with placeholders pointing to the actual entities
    NSMutableArray *processInstanceFilterMapPlaceholders = [NSMutableArray array];
    for (ASDKMOProcessInstance *moProcessInstance in moProcessInstanceList) {
        ASDKMOProcessInstanceFilterMapPlaceholder *processInstanceFilterMapPlaceholder =
        [NSEntityDescription insertNewObjectForEntityForName:[ASDKMOProcessInstanceFilterMapPlaceholder entityName]
                                      inManagedObjectContext:managedObjectContext];
        processInstanceFilterMapPlaceholder.modelID = moProcessInstance.modelID;
        [processInstanceFilterMapPlaceholders addObject:processInstanceFilterMapPlaceholder];
    }
    
    [ASDKProcessInstanceFilterMapCacheMapper mapProcessInstancePlaceholderList:processInstanceFilterMapPlaceholders
                                                                    withFilter:filter
                                                                     toCacheMO:processInstanceFilterMap];
    
    return nil;
}

- (NSError *)cleanStalledProcessInstanceContentInContext:(NSManagedObjectContext *)managedObjectContext
                                    forProcessInstanceID:(NSString *)processInstanceID {
    NSError *internalError = nil;
    
    NSFetchRequest *oldProcessInstanceContentRequest = [ASDKMOProcessInstanceContent fetchRequest];
    oldProcessInstanceContentRequest.predicate = [self processInstancePredicateForProcessInstanceID:processInstanceID];
    oldProcessInstanceContentRequest.resultType = NSManagedObjectIDResultType;
    
    NSBatchDeleteRequest *removeOldProcessInstanceContentRequest = [[NSBatchDeleteRequest alloc] initWithFetchRequest:oldProcessInstanceContentRequest];
    removeOldProcessInstanceContentRequest.resultType = NSBatchDeleteResultTypeObjectIDs;
    NSBatchDeleteResult *removeOldProcessInstanceContentResult =
    [managedObjectContext executeRequest:removeOldProcessInstanceContentRequest
                                   error:&internalError];
    NSArray *moIDArr = removeOldProcessInstanceContentResult.result;
    [NSManagedObjectContext mergeChangesFromRemoteContextSave:@{NSDeletedObjectsKey : moIDArr}
                                                 intoContexts:@[managedObjectContext]];
    if (internalError) {
        return [self clearCacheStalledDataError];
    }
    
    return nil;
}

- (NSError *)cleanStalledCommentsAndProcessInstanceCommentMapForProcessInstanceID:(NSString *)processInstanceID
                                                                        inContext:(NSManagedObjectContext *)managedObjectContext {
    NSError *internalError = nil;
    NSFetchRequest *oldProcessInstanceCommentMapRequest = [ASDKMOProcessInstanceCommentMap fetchRequest];
    oldProcessInstanceCommentMapRequest.predicate = [self processInstancePredicateForProcessInstanceID:processInstanceID];
    oldProcessInstanceCommentMapRequest.resultType = NSManagedObjectIDResultType;
    
    NSBatchDeleteRequest *removeOldProcessInstanceCommentMapRequest = [[NSBatchDeleteRequest alloc] initWithFetchRequest:oldProcessInstanceCommentMapRequest];
    removeOldProcessInstanceCommentMapRequest.resultType = NSBatchDeleteResultTypeObjectIDs;
    NSBatchDeleteResult *processInstanceCommentMapDeletionResult = [managedObjectContext executeRequest:removeOldProcessInstanceCommentMapRequest
                                                                                                  error:&internalError];
    NSArray *moIDArr = processInstanceCommentMapDeletionResult.result;
    [NSManagedObjectContext mergeChangesFromRemoteContextSave:@{NSDeletedObjectsKey : moIDArr}
                                                 intoContexts:@[managedObjectContext]];
    
    if (internalError) {
        return [self clearCacheStalledDataError];
    }
    
    return nil;
}

- (NSError *)saveProcessInstanceCommentsAndGenerateCommentMap:(NSArray *)processInstanceCommentList
                                         forProcessInstanceID:(NSString *)processInstanceID
                                                    inContext:(NSManagedObjectContext *)managedObjectContext {
    NSError *internalError = nil;
    NSArray *moCommentList = [ASDKCommentCacheModelUpsert upsertCommentListToCache:processInstanceCommentList
                                                                             error:&internalError
                                                                       inMOContext:managedObjectContext];
    if (internalError) {
        return internalError;
    }
    
    NSFetchRequest *commentMapFetchRequest = [ASDKMOProcessInstanceCommentMap fetchRequest];
    commentMapFetchRequest.predicate = [self processInstancePredicateForProcessInstanceID:processInstanceID];
    NSArray *fetchResult = [managedObjectContext executeFetchRequest:commentMapFetchRequest
                                                               error:&internalError];
    if (internalError) {
        return internalError;
    }
    
    ASDKMOProcessInstanceCommentMap *processInstanceCommentMap = fetchResult.firstObject;
    if (!processInstanceCommentMap) {
        processInstanceCommentMap = [NSEntityDescription insertNewObjectForEntityForName:[ASDKMOProcessInstanceCommentMap entityName]
                                                                  inManagedObjectContext:managedObjectContext];
    }
    
    [ASDKProcessInstanceCommentMapCacheMapper mapProcessInstanceCommentList:moCommentList
                                                       forProcessInstanceID:processInstanceID
                                                                  toCacheMO:processInstanceCommentMap];
    
    return nil;
}

- (ASDKModelPaging *)paginationWithStartIndex:(NSUInteger)startIndex
                            forTotalTaskCount:(NSUInteger)taskTotalCount
                           remainingTaskCount:(NSUInteger)remainingTaskCount {
    ASDKModelPaging * paging = [ASDKModelPaging new];
    paging.size = remainingTaskCount;
    paging.start = startIndex;
    paging.total = taskTotalCount;
    
    return paging;
}


#pragma mark -
#pragma mark Predicate construction

- (NSPredicate *)filterMapMembershipPredicateForFilter:(ASDKFilterRequestRepresentation *)filter {
    return [NSPredicate predicateWithFormat:@"applicationID == %@ && state == %ld", filter.appDefinitionID, filter.filterModel.state];
}

- (NSPredicate *)allFilterMapsOnCurrentApplicationForFilter:(ASDKFilterRequestRepresentation *)filter {
    return [NSPredicate predicateWithFormat:@"applicationID == %@", filter.appDefinitionID];
}

- (NSPredicate *)namePredicateForFilter:(ASDKFilterRequestRepresentation *)filter {
    if (filter.filterModel.name.length) {
        return [NSPredicate predicateWithFormat:@"name CONTAINS[cd] %@", filter.filterModel.name];
    }
    
    return nil;
}

- (NSPredicate *)processInstancePredicateForProcessInstanceID:(NSString *)processInstanceID {
    return [NSPredicate predicateWithFormat:@"processInstanceID == %@", processInstanceID];
}


#pragma mark -
#pragma mark Sort descriptor construction

- (NSSortDescriptor *)sortDescriptorForFilter:(ASDKFilterRequestRepresentation *)filter {
    NSSortDescriptor *sortDescriptor = nil;
    
    switch (filter.filterModel.sortType) {
        case ASDKModelFilterSortTypeCreatedDesc: {
            sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"startDate"
                                                         ascending:NO];
        }
            break;
        case ASDKModelFilterSortTypeCreatedAsc: {
            sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"startDate"
                                                         ascending:YES];
        }
            break;
            
        default: break;
    }
    
    return sortDescriptor;
}


#pragma mark -
#pragma mark Errors

- (NSError *)clearCacheStalledDataError {
    NSDictionary *userInfo = @{NSLocalizedDescriptionKey            : @"Cannot clean cache stalled data.",
                               NSLocalizedFailureReasonErrorKey     : @"One of the cache clean operations failed.",
                               NSLocalizedRecoverySuggestionErrorKey: @"Investigate which of the clean requests failed."};
    return [NSError errorWithDomain:ASDKPersistenceStackErrorDomain
                               code:kASDKPersistenceStackCleanCacheStalledDataErrorCode
                           userInfo:userInfo];
}

@end

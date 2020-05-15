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

#import "ASDKTaskCacheService.h"

// Constants
#import "ASDKPersistenceStackConstants.h"

// Models
#import "ASDKFilterRequestRepresentation.h"
#import "ASDKModelTask.h"
#import "ASDKMOTask.h"
#import "ASDKModelFilter.h"
#import "ASDKMOTaskFilterMap.h"
#import "ASDKModelPaging.h"
#import "ASDKModelContent.h"
#import "ASDKMOContent.h"
#import "ASDKMOTaskContentMap.h"
#import "ASDKMOTaskCommentMap.h"
#import "ASDKMOComment.h"
#import "ASDKMOTaskFilterMapPlaceholder.h"
#import "ASDKMOProcessTaskFilterMap.h"
#import "ASDKTaskListQuerryRequestRepresentation.h"

// Model upsert
#import "ASDKTaskCacheModelUpsert.h"
#import "ASDKContentCacheModelUpsert.h"
#import "ASDKCommentCacheModelUpsert.h"
#import "ASDKCommentCacheMapper.h"

// Persistence
#import "ASDKTaskCacheMapper.h"
#import "ASDKTaskFilterMapCacheMapper.h"
#import "ASDKTaskContentMapCacheMapper.h"
#import "ASDKContentCacheMapper.h"
#import "ASDKTaskCommentMapCacheMapper.h"
#import "ASDKProcessTaskFilterMapCacheMapper.h"

@implementation ASDKTaskCacheService


#pragma mark -
#pragma mark Public interface

- (void)cacheTaskList:(NSArray *)taskList
          usingFilter:(ASDKFilterRequestRepresentation *)filter
  withCompletionBlock:(ASDKCacheServiceCompletionBlock)completionBlock {
    __weak typeof(self) weakSelf = self;
    [self.persistenceStack performBackgroundTask:^(NSManagedObjectContext *managedObjectContext) {
        __strong typeof(self) strongSelf = weakSelf;
        managedObjectContext.automaticallyMergesChangesFromParent = YES;
        managedObjectContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;
        
        /* When fetching the first page of tasks for a specific application
         remove all references to existing tasks and clear the filter task map
         
         Note: The filter task map exists to provide membership information for
         tasks in relation to a specific filter. Information like whether
         the current task is being made available to the user because he's
         a candidate and not a direct assignee is not retrieved by using the
         tasks/filter API but by employing the details of a task hence the need
         to locally store these kind of relations.
         */
        NSError *error = nil;
        if (!filter.page) {
            error = [strongSelf cleanStalledTasksAndFilterMapInContext:managedObjectContext
                                                             forFilter:filter];
        }
        
        if (!error) {
            error = [strongSelf saveTasksAndGenerateFilterMap:taskList
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

- (void)fetchTaskList:(ASDKCacheServiceTaskListCompletionBlock)completionBlock
          usingFilter:(ASDKFilterRequestRepresentation *)filter {
    __weak typeof(self) weakSelf = self;
    [self.persistenceStack performBackgroundTask:^(NSManagedObjectContext *managedObjectContext) {
        __strong typeof(self) strongSelf = weakSelf;
        
        ASDKModelPaging *paging = nil;
        NSError *error = nil;
        NSArray *pagedTaskArr = nil;
        
        NSFetchRequest *taskFilterMapRequest = [ASDKMOTaskFilterMap fetchRequest];
        taskFilterMapRequest.predicate = [self taskFilterMapMembershipPredicateForFilter:filter];
        NSArray *taskFilterMapArr = [managedObjectContext executeFetchRequest:taskFilterMapRequest
                                                                        error:&error];
        if (!error) {
            NSArray *matchingTaskArr = nil;
            NSArray *tasks = nil;
            
            ASDKMOTaskFilterMap *taskFilterMap = taskFilterMapArr.firstObject;
            NSArray *taskIDs = [taskFilterMap.taskPlaceholders valueForKey:@"modelID"];
            
            if (taskIDs.count) {
                NSFetchRequest *taskFetchRequest = [ASDKMOTask fetchRequest];
                taskFetchRequest.predicate = [self predicateMatchingModelIDList:taskIDs];
                tasks = [managedObjectContext executeFetchRequest:taskFetchRequest
                                                            error:&error];
            }
            
            if (!error) {
                NSArray *sortedTasks = nil;
                NSSortDescriptor *sortDescriptorForFilter = [strongSelf sortDescriptorForFilter:filter];
                
                if (sortDescriptorForFilter) {
                    sortedTasks = [tasks sortedArrayUsingDescriptors:@[sortDescriptorForFilter]];
                } else {
                    sortedTasks = tasks;
                }
                
                NSPredicate *namePredicate = [strongSelf namePredicateForFilter:filter];
                if (namePredicate) {
                    matchingTaskArr = [sortedTasks filteredArrayUsingPredicate:namePredicate];
                } else {
                    matchingTaskArr = sortedTasks;
                }
                
                NSInteger fetchOffset = filter.size * filter.page;
                NSInteger location = matchingTaskArr.count - fetchOffset;
                NSInteger length = MIN(location, filter.size);
                if (length >= 0) {
                    pagedTaskArr = [matchingTaskArr subarrayWithRange:NSMakeRange(fetchOffset, length)];
                }
                
                paging = [strongSelf paginationWithStartIndex:filter.size * filter.page
                                            forTotalTaskCount:sortedTasks.count
                                           remainingTaskCount:length];
            }
        }
        
        if (completionBlock) {
            if (error || !pagedTaskArr.count) {
                completionBlock(nil, error, paging);
            } else {
                NSMutableArray *tasks = [NSMutableArray array];
                for (ASDKMOTask *moTask in pagedTaskArr) {
                    ASDKModelTask *task = [ASDKTaskCacheMapper mapCacheMOToTask:moTask];
                    [tasks addObject:task];
                }
                
                completionBlock(tasks, nil, paging);
            }
        }
    }];
}

- (void)cacheTaskList:(NSArray *)taskList
    usingQuerryFilter:(ASDKTaskListQuerryRequestRepresentation *)filter
  withCompletionBlock:(ASDKCacheServiceCompletionBlock)completionBlock {
    __weak typeof(self) weakSelf = self;
    [self.persistenceStack performBackgroundTask:^(NSManagedObjectContext *managedObjectContext) {
        __strong typeof(self) strongSelf = weakSelf;
        managedObjectContext.automaticallyMergesChangesFromParent = YES;
        managedObjectContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;
        
        NSError *error = [strongSelf cleanStalledTasksAndProcessTaskFilterMapInContext:managedObjectContext
                                                                             forFilter:filter];
        
        if (!error) {
            error = [strongSelf saveTasksAndGenerateProcessTaskFilterMap:taskList
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

- (void)fetchTaskList:(ASDKCacheServiceTaskListCompletionBlock)completionBlock
    usingQuerryFilter:(ASDKTaskListQuerryRequestRepresentation *)filter {
    __weak typeof(self) weakSelf = self;
    [self.persistenceStack performBackgroundTask:^(NSManagedObjectContext *managedObjectContext) {
        __strong typeof(self) strongSelf = weakSelf;
        
        ASDKModelPaging *paging = nil;
        NSError *error = nil;
        NSArray *moTaskArr = nil;
        
        NSFetchRequest *processTaskFilterMapRequest = [ASDKMOProcessTaskFilterMap fetchRequest];
        processTaskFilterMapRequest.predicate = [self processTaskFilterMapMembershipPredicateForFilter:filter];
        NSArray *processTaskFilterMapArr = [managedObjectContext executeFetchRequest:processTaskFilterMapRequest
                                                                               error:&error];
        if (!error) {
            ASDKMOProcessTaskFilterMap *processTaskFilterMap = processTaskFilterMapArr.firstObject;
            NSArray *taskIDs = [processTaskFilterMap.taskPlaceholders valueForKey:@"modelID"];
            
            if (taskIDs.count) {
                NSFetchRequest *taskFetchRequest = [ASDKMOTask fetchRequest];
                taskFetchRequest.predicate = [self predicateMatchingModelIDList:taskIDs];
                moTaskArr = [managedObjectContext executeFetchRequest:taskFetchRequest
                                                            error:&error];
            }
            
            if (!error) {
                paging = [strongSelf paginationWithStartIndex:0
                                            forTotalTaskCount:moTaskArr.count
                                           remainingTaskCount:moTaskArr.count];
            }
        }
        
        if (completionBlock) {
            if (error || !moTaskArr.count) {
                completionBlock(nil, error, paging);
            } else {
                NSMutableArray *tasks = [NSMutableArray array];
                for (ASDKMOTask *moTask in moTaskArr) {
                    ASDKModelTask *task = [ASDKTaskCacheMapper mapCacheMOToTask:moTask];
                    [tasks addObject:task];
                }
                
                completionBlock(tasks, nil, paging);
            }
        }
    }];
}

- (void)cacheTaskDetails:(ASDKModelTask *)task
     withCompletionBlock:(ASDKCacheServiceCompletionBlock)completionBlock {
    [self.persistenceStack performBackgroundTask:^(NSManagedObjectContext *managedObjectContext) {
        managedObjectContext.automaticallyMergesChangesFromParent = YES;
        managedObjectContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;
        
        NSError *error = nil;
        [ASDKTaskCacheModelUpsert upsertTaskToCache:task
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

- (void)fetchTaskDetailsForID:(NSString *)taskID
          withCompletionBlock:(ASDKCacheServiceTaskDetailsCompletionBlock)completionBlock {
    [self.persistenceStack performBackgroundTask:^(NSManagedObjectContext *managedObjectContext) {
        NSFetchRequest *fetchRequest = [ASDKMOTask fetchRequest];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"modelID == %@", taskID];
        
        NSError *error = nil;
        NSArray *fetchResults = [managedObjectContext executeFetchRequest:fetchRequest
                                                                    error:&error];
        
        if (completionBlock) {
            ASDKMOTask *moTask = fetchResults.firstObject;
            
            if (error || !moTask) {
                completionBlock(nil, error);
            } else {
                ASDKModelTask *task = [ASDKTaskCacheMapper mapCacheMOToTask:moTask];
                completionBlock(task, nil);
            }
        }
    }];
}

- (void)cacheTaskContentList:(NSArray *)taskContentList
               forTaskWithID:(NSString *)taskID
         withCompletionBlock:(ASDKCacheServiceCompletionBlock)completionBlock {
    __weak typeof(self) weakSelf = self;
    [self.persistenceStack performBackgroundTask:^(NSManagedObjectContext *managedObjectContext) {
        __strong typeof(self) strongSelf = weakSelf;
        
        managedObjectContext.automaticallyMergesChangesFromParent = YES;
        managedObjectContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;
        
        NSError *error = [strongSelf cleanStalledTaskContentAndContentMapForTaskID:taskID
                                                                         inContext:managedObjectContext];
        if (!error) {
            /* The content map exists to provide membership information for
             * content in relation to a specific task. Just the state of the
             * content objects do not provide sufficient information to assign
             * them to a task.
             */
            error = [strongSelf saveTaskContentAndGenerateContentMap:taskContentList
                                                           forTaskID:taskID
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

- (void)fetchTaskContentListForTaskWithID:(NSString *)taskID
                      withCompletionBlock:(ASDKCacheServiceTaskContentListCompletionBlock)completionBlock {
    [self.persistenceStack performBackgroundTask:^(NSManagedObjectContext *managedObjectContext) {
        NSError *error = nil;
        NSArray *matchingContentArr = nil;
        
        NSFetchRequest *taskContentMapRequest = [ASDKMOTaskContentMap fetchRequest];
        taskContentMapRequest.predicate = [NSPredicate predicateWithFormat:@"taskID == %@", taskID];
        NSArray *taskContentMapArr = [managedObjectContext executeFetchRequest:taskContentMapRequest
                                                                         error:&error];
        
        if (!error) {
            ASDKMOTaskContentMap *taskContentMap = taskContentMapArr.firstObject;
            NSSortDescriptor *contentSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"creationDate"
                                                                                    ascending:YES];
            matchingContentArr = [[taskContentMap.taskContentList allObjects] sortedArrayUsingDescriptors:@[contentSortDescriptor]];
        }
        
        if (completionBlock) {
            if (error || !matchingContentArr.count) {
                completionBlock(nil, error);
            } else {
                NSMutableArray *contentList = [NSMutableArray array];
                for (ASDKMOContent *moContent in matchingContentArr) {
                    ASDKModelContent *content = [ASDKContentCacheMapper mapCacheMOToContent:moContent];
                    [contentList addObject:content];
                }
                
                completionBlock(contentList, nil);
            }
        }
    }];
}

- (void)cacheTaskCommentList:(NSArray *)taskCommentList
               forTaskWithID:(NSString *)taskID
         withCompletionBlock:(ASDKCacheServiceCompletionBlock)completionBlock {
    __weak typeof(self) weakSelf = self;
    [self.persistenceStack performBackgroundTask:^(NSManagedObjectContext *managedObjectContext) {
        __strong typeof(self) strongSelf = weakSelf;
        
        managedObjectContext.automaticallyMergesChangesFromParent = YES;
        managedObjectContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;
        
        NSError *error = [strongSelf cleanStalledTaskCommentAndCommentMapForTaskID:taskID
                                                                         inContext:managedObjectContext];
        if (!error) {
            /* The comment map exists to provide membership information for
             * comment in relation to a specific task. Just the state of the
             * comment objects do not provide sufficient information to assign
             * them to a task.
             */
            error = [strongSelf saveTaskCommentAndGenerateCommentMap:taskCommentList
                                                           forTaskID:taskID
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

- (void)fetchTaskCommentListForTaskWithID:(NSString *)taskID
                      withCompletionBlock:(ASDKCacheServiceTaskCommentListCompletionBlock)completionBlock {
    __weak typeof(self) weakSelf = self;
    [self.persistenceStack performBackgroundTask:^(NSManagedObjectContext *managedObjectContext) {
        __strong typeof(self) strongSelf = weakSelf;
        
        ASDKModelPaging *paging = nil;
        NSError *error = nil;
        NSArray *matchingCommentsArr = nil;
        
        NSFetchRequest *taskCommentMapRequest = [ASDKMOTaskCommentMap fetchRequest];
        taskCommentMapRequest.predicate = [NSPredicate predicateWithFormat:@"taskID == %@", taskID];
        NSArray *taskCommentMapArr = [managedObjectContext executeFetchRequest:taskCommentMapRequest
                                                                         error:&error];
        if (!error) {
            ASDKMOTaskCommentMap *taskCommentMap = taskCommentMapArr.firstObject;
            matchingCommentsArr = [taskCommentMap.taskCommentList allObjects];
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

- (void)cacheTaskChecklist:(NSArray *)taskChecklist
             forTaskWithID:(NSString *)taskID
       withCompletionBlock:(ASDKCacheServiceCompletionBlock)completionBlock {
    __weak typeof(self) weakSelf = self;
    [self.persistenceStack performBackgroundTask:^(NSManagedObjectContext *managedObjectContext) {
        __strong typeof(self) strongSelf = weakSelf;
        
        managedObjectContext.automaticallyMergesChangesFromParent = YES;
        managedObjectContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;
        
        
        NSError *error = [strongSelf cleanStalledTasksChecklistForTaskID:taskID
                                                               inContext:managedObjectContext];
        
        if (!error) {
            [ASDKTaskCacheModelUpsert upsertTaskListToCache:taskChecklist
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

- (void)fetchTaskCheckListForTaskWithID:(NSString *)taskID
                    withCompletionBlock:(ASDKCacheServiceTaskListCompletionBlock)completionBlock {
    __weak typeof(self) weakSelf = self;
    [self.persistenceStack performBackgroundTask:^(NSManagedObjectContext *managedObjectContext) {
        __strong typeof(self) strongSelf = weakSelf;
        
        NSError *error = nil;
        ASDKModelPaging *paging = nil;
        
        NSFetchRequest *taskChecklistRequest = [ASDKMOTask fetchRequest];
        taskChecklistRequest.predicate = [NSPredicate predicateWithFormat:@"parentTaskID == %@", taskID];
        NSArray *moTaskChecklistArr = [managedObjectContext executeFetchRequest:taskChecklistRequest
                                                                          error:&error];
        
        if (!error) {
            paging = [strongSelf paginationWithStartIndex:0
                                        forTotalTaskCount:moTaskChecklistArr.count
                                       remainingTaskCount:moTaskChecklistArr.count];
        }
        
        if (completionBlock) {
            if (error || !moTaskChecklistArr.count) {
                completionBlock(nil, error, nil);
            } else {
                NSMutableArray *taskChecklistArr = [NSMutableArray array];
                for (ASDKMOTask *moTask in moTaskChecklistArr) {
                    ASDKModelTask *task = [ASDKTaskCacheMapper mapCacheMOToTask:moTask];
                    [taskChecklistArr addObject:task];
                }
                
                completionBlock(taskChecklistArr, nil, paging);
            }
        }
    }];
}


#pragma mark -
#pragma mark Operations

- (NSError *)cleanStalledTasksAndFilterMapInContext:(NSManagedObjectContext *)managedObjectContext
                                          forFilter:(ASDKFilterRequestRepresentation *)filter {
    NSError *internalError = nil;
    NSFetchRequest *oldTaskFilterMapRequest = [ASDKMOTaskFilterMap fetchRequest];
    oldTaskFilterMapRequest.predicate = [self taskFilterMapMembershipPredicateForFilter:filter];
    oldTaskFilterMapRequest.resultType = NSManagedObjectIDResultType;
    
    NSBatchDeleteRequest *removeOldTaskFilterMapRequest = [[NSBatchDeleteRequest alloc] initWithFetchRequest:oldTaskFilterMapRequest];
    removeOldTaskFilterMapRequest.resultType = NSBatchDeleteResultTypeObjectIDs;
    NSBatchDeleteResult *taskFilterMapDeletionResult = [managedObjectContext executeRequest:removeOldTaskFilterMapRequest
                                                                                      error:&internalError];
    
    NSArray *moIDArr = taskFilterMapDeletionResult.result;
    [NSManagedObjectContext mergeChangesFromRemoteContextSave:@{NSDeletedObjectsKey : moIDArr}
                                                 intoContexts:@[managedObjectContext]];
    
    if (internalError) {
        return [self clearCacheStalledDataError];
    }
    
    return nil;
}

- (NSError *)cleanStalledTasksChecklistForTaskID:(NSString *)taskID
                                       inContext:(NSManagedObjectContext *)managedObjectContext {
    NSError *internalError = nil;
    NSFetchRequest *oldTaskChecklistRequest = [ASDKMOTask fetchRequest];
    oldTaskChecklistRequest.predicate = [NSPredicate predicateWithFormat:@"parentTaskID == %@", taskID];
    oldTaskChecklistRequest.resultType = NSManagedObjectIDResultType;
    
    NSBatchDeleteRequest *removeOldTaskChecklistRequest = [[NSBatchDeleteRequest alloc] initWithFetchRequest:oldTaskChecklistRequest];
    removeOldTaskChecklistRequest.resultType = NSBatchDeleteResultTypeObjectIDs;
    NSBatchDeleteResult *taskChecklistDeletionResult = [managedObjectContext executeRequest:removeOldTaskChecklistRequest
                                                                                      error:&internalError];
    
    NSArray *moIDArr = taskChecklistDeletionResult.result;
    [NSManagedObjectContext mergeChangesFromRemoteContextSave:@{NSDeletedObjectsKey : moIDArr}
                                                 intoContexts:@[managedObjectContext]];
    
    if (internalError) {
        return [self clearCacheStalledDataError];
    }
    
    return nil;
}

- (NSError *)saveTasksAndGenerateFilterMap:(NSArray *)taskList
                                 forFilter:(ASDKFilterRequestRepresentation *)filter
                                 inContext:(NSManagedObjectContext *)managedObjectContext {
    // Upsert tasks
    NSError *error = nil;
    NSArray *moTasks = [ASDKTaskCacheModelUpsert upsertTaskListToCache:taskList
                                                                 error:&error
                                                           inMOContext:managedObjectContext];
    if (error) {
        return error;
    }
    
    // Fetch existing or create a task filter map
    NSFetchRequest *taskFilterMapFetchRequest = [ASDKMOTaskFilterMap fetchRequest];
    taskFilterMapFetchRequest.predicate = [self taskFilterMapMembershipPredicateForFilter:filter];
    NSArray *fetchResults = [managedObjectContext executeFetchRequest:taskFilterMapFetchRequest
                                                                error:&error];
    if (error) {
        return error;
    }
    
    ASDKMOTaskFilterMap *taskFilterMap = fetchResults.firstObject;
    if (!taskFilterMap) {
        taskFilterMap = [NSEntityDescription insertNewObjectForEntityForName:[ASDKMOTaskFilterMap entityName]
                                                      inManagedObjectContext:managedObjectContext];
    }
    
    // Populate the task filter map with placeholders pointing to the actual entities
    NSMutableArray *taskFilterMapPlaceholders = [NSMutableArray array];
    for (ASDKMOTask *moTask in moTasks) {
        ASDKMOTaskFilterMapPlaceholder *taskFilterMapPlaceholder = [NSEntityDescription insertNewObjectForEntityForName:[ASDKMOTaskFilterMapPlaceholder entityName]
                                                                                                 inManagedObjectContext:managedObjectContext];
        taskFilterMapPlaceholder.modelID = moTask.modelID;
        [taskFilterMapPlaceholders addObject:taskFilterMapPlaceholder];
    }
    
    [ASDKTaskFilterMapCacheMapper mapTaskPlaceholderList:taskFilterMapPlaceholders
                                              withFilter:filter
                                               toCacheMO:taskFilterMap];
    
    return nil;
}

- (NSError *)cleanStalledTasksAndProcessTaskFilterMapInContext:(NSManagedObjectContext *)managedObjectContext
                                                     forFilter:(ASDKTaskListQuerryRequestRepresentation *)filter {
    NSError *internalError = nil;
    NSFetchRequest *oldTaskFilterMapRequest = [ASDKMOProcessTaskFilterMap fetchRequest];
    oldTaskFilterMapRequest.predicate = [self processTaskFilterMapMembershipPredicateForFilter:filter];
    oldTaskFilterMapRequest.resultType = NSManagedObjectIDResultType;
    
    NSBatchDeleteRequest *removeOldTaskFilterMapRequest = [[NSBatchDeleteRequest alloc] initWithFetchRequest:oldTaskFilterMapRequest];
    removeOldTaskFilterMapRequest.resultType = NSBatchDeleteResultTypeObjectIDs;
    NSBatchDeleteResult *taskFilterMapDeletionResult = [managedObjectContext executeRequest:removeOldTaskFilterMapRequest
                                                                                      error:&internalError];
    NSArray *moIDArr = taskFilterMapDeletionResult.result;
    [NSManagedObjectContext mergeChangesFromRemoteContextSave:@{NSDeletedObjectsKey : moIDArr}
                                                 intoContexts:@[managedObjectContext]];
    
    if (internalError) {
        return [self clearCacheStalledDataError];
    }
    
    return nil;
}

- (NSError *)saveTasksAndGenerateProcessTaskFilterMap:(NSArray *)taskList
                                            forFilter:(ASDKTaskListQuerryRequestRepresentation *)filter
                                            inContext:(NSManagedObjectContext *)managedObjectContext {
    // Upsert tasks
    NSError *error = nil;
    NSArray *moTasks = [ASDKTaskCacheModelUpsert upsertTaskListToCache:taskList
                                                                 error:&error
                                                           inMOContext:managedObjectContext];
    if (error) {
        return error;
    }
    
    // Fetch existing or create process task filter map
    NSFetchRequest *processTaskFilterMapFetchRequest = [ASDKMOProcessTaskFilterMap fetchRequest];
    processTaskFilterMapFetchRequest.predicate = [self processTaskFilterMapMembershipPredicateForFilter:filter];
    NSArray *fetchResults = [managedObjectContext executeFetchRequest:processTaskFilterMapFetchRequest
                                                                error:&error];
    if (error) {
        return error;
    }
    
    ASDKMOProcessTaskFilterMap *processInstanceFilterMap = fetchResults.firstObject;
    if (!processInstanceFilterMap) {
        processInstanceFilterMap = [NSEntityDescription insertNewObjectForEntityForName:[ASDKMOProcessTaskFilterMap entityName]
                                                                 inManagedObjectContext:managedObjectContext];
    }
    
    // Populate the process task filter map with placeholders pointing to the actual entities
    NSMutableArray *processTaskFilterMapPlaceholders = [NSMutableArray array];
    for (ASDKMOTask *moTask in moTasks) {
        ASDKMOTaskFilterMapPlaceholder *taskFilterMapPlaceholder = [NSEntityDescription insertNewObjectForEntityForName:[ASDKMOTaskFilterMapPlaceholder entityName]
                                                                                                 inManagedObjectContext:managedObjectContext];
        taskFilterMapPlaceholder.modelID = moTask.modelID;
        [processTaskFilterMapPlaceholders addObject:taskFilterMapPlaceholder];
    }
    
    [ASDKProcessTaskFilterMapCacheMapper mapTaskPlaceholderList:processTaskFilterMapPlaceholders
                                                     withFilter:filter
                                                      toCacheMO:processInstanceFilterMap];
    
    return nil;
}


- (NSError *)cleanStalledTaskContentAndContentMapForTaskID:(NSString *)taskID
                                                 inContext:(NSManagedObjectContext *)managedObjectContext {
    NSError *internalError = nil;
    NSFetchRequest *oldTaskContentMapRequest = [ASDKMOTaskContentMap fetchRequest];
    oldTaskContentMapRequest.predicate = [NSPredicate predicateWithFormat:@"taskID == %@", taskID];
    oldTaskContentMapRequest.resultType = NSManagedObjectIDResultType;
    
    NSBatchDeleteRequest *removeOldTaskContentMapRequest = [[NSBatchDeleteRequest alloc] initWithFetchRequest:oldTaskContentMapRequest];
    removeOldTaskContentMapRequest.resultType = NSBatchDeleteResultTypeObjectIDs;
    NSBatchDeleteResult *taskContentMapDeletionResult = [managedObjectContext executeRequest:removeOldTaskContentMapRequest
                                                                                       error:&internalError];
    NSArray *moIDArr = taskContentMapDeletionResult.result;
    [NSManagedObjectContext mergeChangesFromRemoteContextSave:@{NSDeletedObjectsKey : moIDArr}
                                                 intoContexts:@[managedObjectContext]];
    
    if (internalError) {
        return [self clearCacheStalledDataError];
    }
    
    return nil;
}

- (NSError *)saveTaskContentAndGenerateContentMap:(NSArray *)taskContentList
                                        forTaskID:(NSString *)taskID
                                        inContext:(NSManagedObjectContext *)managedObjectContext {
    NSError *internalError = nil;
    NSArray *moContentList = [ASDKContentCacheModelUpsert upsertContentListToCache:taskContentList
                                                                             error:&internalError
                                                                       inMOContext:managedObjectContext];
    if (internalError) {
        return internalError;
    }
    
    NSFetchRequest *contentMapFetchRequest = [ASDKMOTaskContentMap fetchRequest];
    contentMapFetchRequest.predicate = [NSPredicate predicateWithFormat:@"taskID == %@", taskID];
    NSArray *fetchResults = [managedObjectContext executeFetchRequest:contentMapFetchRequest
                                                                error:&internalError];
    
    if (internalError) {
        return internalError;
    }
    
    ASDKMOTaskContentMap *taskContentMap = fetchResults.firstObject;
    if (!taskContentMap) {
        taskContentMap = [NSEntityDescription insertNewObjectForEntityForName:[ASDKMOTaskContentMap entityName]
                                                       inManagedObjectContext:managedObjectContext];
    }
    [ASDKTaskContentMapCacheMapper mapTaskContentList:moContentList
                                            forTaskID:taskID
                                            toCacheMO:taskContentMap];
    
    return nil;
}

- (NSError *)cleanStalledTaskCommentAndCommentMapForTaskID:(NSString *)taskID
                                                 inContext:(NSManagedObjectContext *)managedObjectContext {
    NSError *internalError = nil;
    NSFetchRequest *oldTaskCommentMapRequest = [ASDKMOTaskCommentMap fetchRequest];
    oldTaskCommentMapRequest.predicate = [NSPredicate predicateWithFormat:@"taskID == %@", taskID];
    oldTaskCommentMapRequest.resultType = NSManagedObjectIDResultType;
    
    NSBatchDeleteRequest *removeOldTaskCommentMapRequest = [[NSBatchDeleteRequest alloc] initWithFetchRequest:oldTaskCommentMapRequest];
    removeOldTaskCommentMapRequest.resultType = NSBatchDeleteResultTypeObjectIDs;
    NSBatchDeleteResult *taskCommentMapDeletionResult = [managedObjectContext executeRequest:removeOldTaskCommentMapRequest
                                                                                       error:&internalError];
    NSArray *moIDArr = taskCommentMapDeletionResult.result;
    [NSManagedObjectContext mergeChangesFromRemoteContextSave:@{NSDeletedObjectsKey : moIDArr}
                                                 intoContexts:@[managedObjectContext]];
    
    if (internalError) {
        return [self clearCacheStalledDataError];
    }
    
    return nil;
}

- (NSError *)saveTaskCommentAndGenerateCommentMap:(NSArray *)taskCommentList
                                        forTaskID:(NSString *)taskID
                                        inContext:(NSManagedObjectContext *)managedObjectContext {
    NSError *internalError = nil;
    NSArray *moCommentList = [ASDKCommentCacheModelUpsert upsertCommentListToCache:taskCommentList
                                                                             error:&internalError
                                                                       inMOContext:managedObjectContext];
    if (internalError) {
        return internalError;
    }
    
    NSFetchRequest *commentMapFetchRequest = [ASDKMOTaskCommentMap fetchRequest];
    commentMapFetchRequest.predicate = [NSPredicate predicateWithFormat:@"taskID == %@", taskID];
    NSArray *fetchResults = [managedObjectContext executeFetchRequest:commentMapFetchRequest
                                                                error:&internalError];
    if (internalError) {
        return internalError;
    }
    
    ASDKMOTaskCommentMap *taskCommentMap = fetchResults.firstObject;
    if (!taskCommentMap) {
        taskCommentMap = [NSEntityDescription insertNewObjectForEntityForName:[ASDKMOTaskCommentMap entityName]
                                                       inManagedObjectContext:managedObjectContext];
    }
    
    [ASDKTaskCommentMapCacheMapper mapTaskCommentList:moCommentList
                                            forTaskID:taskID
                                            toCacheMO:taskCommentMap];
    
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


- (ASDKModelPaging *)emptyPagination {
    return [self paginationWithStartIndex:0
                        forTotalTaskCount:0
                       remainingTaskCount:0];
}


#pragma mark -
#pragma mark Predicate construction

- (NSPredicate *)taskFilterMapMembershipPredicateForFilter:(ASDKFilterRequestRepresentation *)filter {
    NSPredicate *appIDPredicate = [NSPredicate predicateWithFormat:@"applicationID == %@", filter.appDefinitionID];
    NSPredicate *assignmentTypePredicate = [NSPredicate predicateWithFormat:@"assignmentType == %ld", filter.filterModel.assignmentType];
    NSPredicate *statePredicate = [NSPredicate predicateWithFormat:@"state == %ld", filter.filterModel.state];
    
    return [[NSCompoundPredicate alloc] initWithType:NSAndPredicateType
                                       subpredicates:@[appIDPredicate, assignmentTypePredicate, statePredicate]];
}

- (NSPredicate *)processTaskFilterMapMembershipPredicateForFilter:(ASDKTaskListQuerryRequestRepresentation *)filter {
    return [NSPredicate predicateWithFormat:@"processInstanceID == %@ && taskState == %ld", filter.processInstanceID, filter.requestTaskState];
}

- (NSPredicate *)namePredicateForFilter:(ASDKFilterRequestRepresentation *)filter {
    if (filter.filterModel.name.length) {
        return [NSPredicate predicateWithFormat:@"name CONTAINS[cd] %@", filter.filterModel.name];
    }
    
    return nil;
}

- (NSPredicate *)predicateMatchingModelID:(NSString *)modelID {
    return [NSPredicate predicateWithFormat:@"modelID == %@", modelID];
}

- (NSPredicate *)predicateMatchingModelIDList:(NSArray *)modelIDList {
    return [NSPredicate predicateWithFormat:@"modelID IN %@", modelIDList];
}


#pragma mark -
#pragma mark Sort descriptor construction

- (NSSortDescriptor *)sortDescriptorForFilter:(ASDKFilterRequestRepresentation *)filter {
    NSSortDescriptor *sortDescriptor = nil;
    
    switch (filter.filterModel.sortType) {
        case ASDKModelFilterSortTypeCreatedDesc: {
            sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"creationDate"
                                                         ascending:NO];
        }
            break;
        case ASDKModelFilterSortTypeCreatedAsc: {
            sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"creationDate"
                                                         ascending:YES];
        }
            break;
            
        case ASDKModelFilterSortTypeDueDesc: {
            sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"dueDate"
                                                         ascending:NO];
        }
            break;
            
        case ASDKModelFilterSortTypeDueAsc: {
            sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"dueDate"
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

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

#import "ASDKProcessDefinitionCacheService.h"

// Constants
#import "ASDKPersistenceStackConstants.h"

// Model upsert
#import "ASDKProcessDefinitionCacheModelUpsert.h"

// Models
#import "ASDKModelPaging.h"
#import "ASDKModelProcessDefinition.h"
#import "ASDKMOProcessDefinition.h"
#import "ASDKMOProcessDefinitionMap.h"

// Persistence
#import "ASDKProcessDefinitionMapCacheMapper.h"
#import "ASDKProcessDefinitionCacheMapper.h"

@implementation ASDKProcessDefinitionCacheService


#pragma mark -
#pragma mark Public interface

- (void)cacheProcessDefinitionList:(NSArray *)processDefinitionList
                          forAppID:(NSString *)applicationID
               withCompletionBlock:(ASDKCacheServiceCompletionBlock)completionBlock {
    __weak typeof(self) weakSelf = self;
    [self.persistenceStack performBackgroundTask:^(NSManagedObjectContext *managedObjectContext) {
        __strong typeof(self) strongSelf = weakSelf;
        managedObjectContext.automaticallyMergesChangesFromParent = YES;
        managedObjectContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;
        
        NSError *error = [strongSelf cleanStalledProcessDefinitionsInContext:managedObjectContext
                                                                    forAppID:applicationID];
        
        if (!error) {
            error = [strongSelf saveProcessDefinitionListAndGenerateProcessDefinitionMap:processDefinitionList
                                                                                forAppID:applicationID
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

- (void)fetchProcessDefinitionListForAppID:(NSString *)applicationID
                       withCompletionBlock:(ASDKCacheServiceProcessDefinitionListCompletionBlock)completionBlock {
    __weak typeof(self) weakSelf = self;
    [self.persistenceStack performBackgroundTask:^(NSManagedObjectContext *managedObjectContext) {
        __strong typeof(self) strongSelf = weakSelf;
        
        ASDKModelPaging *paging = nil;
        NSError *error = nil;
        NSArray *matchingProcessDefinitionArr = nil;
        
        NSFetchRequest *processDefinitionMapRequest = [ASDKMOProcessDefinitionMap fetchRequest];
        processDefinitionMapRequest.predicate = [self processDefinitionPredicateForAppID:applicationID];
        NSArray *processDefinitionMapArr = [managedObjectContext executeFetchRequest:processDefinitionMapRequest
                                                                               error:&error];
        if (!error) {
            ASDKMOProcessDefinitionMap *processDefinitionMap = processDefinitionMapArr.firstObject;
            matchingProcessDefinitionArr = [processDefinitionMap.processDefinitionList allObjects];
            paging = [strongSelf paginationWithStartIndex:0
                                        forTotalTaskCount:matchingProcessDefinitionArr.count
                                       remainingTaskCount:matchingProcessDefinitionArr.count];
        }
        
        if (completionBlock) {
            if (error || !matchingProcessDefinitionArr.count) {
                completionBlock(nil, error, nil);
            } else {
                NSMutableArray *processDefinitions = [NSMutableArray array];
                for (ASDKMOProcessDefinition *moProcessDefinition in matchingProcessDefinitionArr) {
                    ASDKModelProcessDefinition *processDefinition = [ASDKProcessDefinitionCacheMapper mapCacheMOToProcessInstance:moProcessDefinition];
                    [processDefinitions addObject:processDefinition];
                }
                
                completionBlock(processDefinitions, nil, paging);
            }
        }
    }];
}


#pragma mark -
#pragma mark Operations

- (NSError *)cleanStalledProcessDefinitionsInContext:(NSManagedObjectContext *)managedObjectContext
                                            forAppID:(NSString *)applicationID {
    NSError *internalError = nil;
    
    NSFetchRequest *oldProcessDefinitionRequest = [ASDKMOProcessDefinitionMap fetchRequest];
    oldProcessDefinitionRequest.predicate = [self processDefinitionPredicateForAppID:applicationID];
    oldProcessDefinitionRequest.resultType = NSManagedObjectIDResultType;
    
    NSBatchDeleteRequest *removeOldProcessDefinitionsRequest = [[NSBatchDeleteRequest alloc] initWithFetchRequest:oldProcessDefinitionRequest];
    removeOldProcessDefinitionsRequest.resultType = NSBatchDeleteResultTypeObjectIDs;
    NSBatchDeleteResult *removeOldProcessDefinitionResult = [managedObjectContext executeRequest:removeOldProcessDefinitionsRequest
                                                                                           error:&internalError];
    NSArray *moIDArr = removeOldProcessDefinitionResult.result;
    [NSManagedObjectContext mergeChangesFromRemoteContextSave:@{NSDeletedObjectsKey : moIDArr}
                                                 intoContexts:@[managedObjectContext]];
    if (internalError) {
        return [self clearCacheStalledDataError];
    }
    
    return nil;
}

- (NSError *)saveProcessDefinitionListAndGenerateProcessDefinitionMap:(NSArray *)processDefinitionList
                                                             forAppID:(NSString *)applicationID
                                                            inContext:(NSManagedObjectContext *)managedObjectContext {
    // Upsert process definitions
    NSError *error = nil;
    NSArray *moProcessDefinitionList = [ASDKProcessDefinitionCacheModelUpsert upsertProcessDefinitionListToCache:processDefinitionList
                                                                                                           error:&error
                                                                                                     inMOContext:managedObjectContext];
    
    if (error) {
        return error;
    }
    
    // Fetch existing or create a process definition map
    NSFetchRequest *processDefinitionMapFetchRequest = [ASDKMOProcessDefinitionMap fetchRequest];
    processDefinitionMapFetchRequest.predicate = [self processDefinitionPredicateForAppID:applicationID];
    NSArray *fetchResults = [managedObjectContext executeFetchRequest:processDefinitionMapFetchRequest
                                                                error:&error];
    if (error) {
        return error;
    }
    
    ASDKMOProcessDefinitionMap *processDefinitionMap = fetchResults.firstObject;
    if (!processDefinitionMap) {
        processDefinitionMap = [NSEntityDescription insertNewObjectForEntityForName:[ASDKMOProcessDefinitionMap entityName]
                                                             inManagedObjectContext:managedObjectContext];
    }
    
    [ASDKProcessDefinitionMapCacheMapper mapProcessDefinitionList:moProcessDefinitionList
                                                         forAppID:applicationID
                                                        toCacheMO:processDefinitionMap];
    
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

- (NSPredicate *)processDefinitionPredicateForAppID:(NSString *)applicationID {
    if (!applicationID.length) {
        return nil;
    } else {
        return [NSPredicate predicateWithFormat:@"appID == %@", applicationID];
    }
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

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

#import "ASDKIntegrationCacheService.h"

// Constants
#import "ASDKPersistenceStackConstants.h"

// Models
#import "ASDKModelPaging.h"
#import "ASDKModelIntegrationAccount.h"
#import "ASDKMOIntegrationAccount.h"

// Model upsert
#import "ASDKIntegrationCacheModelUpsert.h"

// Mappers
#import "ASDKIntegrationCacheMapper.h"

@implementation ASDKIntegrationCacheService


#pragma mark -
#pragma mark Public interface

- (void)cacheIntegrationList:(NSArray *)integrationList
         withCompletionBlock:(ASDKCacheServiceCompletionBlock)completionBlock {
    __weak typeof(self) weakSelf = self;
    [self.persistenceStack performBackgroundTask:^(NSManagedObjectContext *managedObjectContext) {
        __strong typeof(self) strongSelf = weakSelf;
        managedObjectContext.automaticallyMergesChangesFromParent = YES;
        managedObjectContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;
        
        NSError *error = [strongSelf cleanStalledIntegrationListInContext:managedObjectContext];
        
        if (!error) {
            error = [strongSelf saveIntegrationAccountList:integrationList
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

- (void)fetchIntegrationListWithCompletionBlock:(ASDKCacheServiceIntegrationAccountListCompletionBlock)completionBlock {
    __weak typeof(self) weakSelf = self;
    [self.persistenceStack performBackgroundTask:^(NSManagedObjectContext *managedObjectContext) {
        __strong typeof(self) strongSelf = weakSelf;
        
        ASDKModelPaging *paging = nil;
        NSError *error = nil;
        
        NSFetchRequest *integrationAccountRequest = [ASDKMOIntegrationAccount fetchRequest];
        NSArray *matchingIntegrationAccountArr = [managedObjectContext executeFetchRequest:integrationAccountRequest
                                                                                     error:&error];
        
        if (!error) {
            paging = [strongSelf paginationWithStartIndex:0
                                        forTotalTaskCount:matchingIntegrationAccountArr.count
                                       remainingTaskCount:matchingIntegrationAccountArr.count];
        }
        
        if (completionBlock) {
            if(error || !matchingIntegrationAccountArr.count) {
                completionBlock(nil, error, nil);
            } else {
                NSMutableArray *integrationAccounts = [NSMutableArray array];
                for (ASDKMOIntegrationAccount *moIntegrationAccount in matchingIntegrationAccountArr) {
                    ASDKModelIntegrationAccount *integrationAccount = [ASDKIntegrationCacheMapper mapCacheMOToIntegrationAccount:moIntegrationAccount];
                    [integrationAccounts addObject:integrationAccount];
                }
                
                completionBlock(integrationAccounts, nil, paging);
            }
        }
    }];
}


#pragma mark -
#pragma mark Operations

- (NSError *)cleanStalledIntegrationListInContext:(NSManagedObjectContext *)manangedObjectContext {
    NSError *internalError = nil;
    
    NSFetchRequest *oldIntegrationListRequest = [ASDKMOIntegrationAccount fetchRequest];
    oldIntegrationListRequest.resultType = NSManagedObjectIDResultType;
    
    NSBatchDeleteRequest *removeOldIntegrationListRequest = [[NSBatchDeleteRequest alloc] initWithFetchRequest:oldIntegrationListRequest];
    removeOldIntegrationListRequest.resultType = NSBatchDeleteResultTypeObjectIDs;
    NSBatchDeleteResult *removeOldIntegrationListResult = [manangedObjectContext executeRequest:removeOldIntegrationListRequest
                                                                                          error:&internalError];
    NSArray *moIDArr = removeOldIntegrationListResult.result;
    [NSManagedObjectContext mergeChangesFromRemoteContextSave:@{NSDeletedObjectsKey : moIDArr}
                                                 intoContexts:@[manangedObjectContext]];
    if (internalError) {
        return [self clearCacheStalledDataError];
    }
    
    return nil;
}

- (NSError *)saveIntegrationAccountList:(NSArray *)integrationAccountList
                              inContext:(NSManagedObjectContext *)managedObjectContext {
    // Upsert integration list
    NSError *error = nil;
    [ASDKIntegrationCacheModelUpsert upsertIntegrationListToCache:integrationAccountList
                                                            error:&error
                                                      inMOContext:managedObjectContext];
    if (error) {
        return error;
    }
    
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

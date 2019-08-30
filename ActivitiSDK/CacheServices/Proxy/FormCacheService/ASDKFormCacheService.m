/*******************************************************************************
 * Copyright (C) 2005-2018 Alfresco Software Limited.
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

#import "ASDKFormCacheService.h"

// Constants
#import "ASDKPersistenceStackConstants.h"

// Models
#import "ASDKMOFormFieldOptionMap.h"
#import "ASDKMOFormFieldOption.h"
#import "ASDKMOFormDescription.h"
#import "ASDKMOFormFieldValueRepresentation.h"
#import "ASDKMOFormVariable.h"

// Model upsert
#import "ASDKFormFieldOptionCacheModelUpsert.h"
#import "ASDKFormDescriptionCacheModelUpsert.h"
#import "ASDKFormFieldValueRepresentationCacheModelUpsert.h"
#import "ASDKFormVariablesCacheModelUpsert.h"

// Mappers
#import "ASDKFormFieldOptionMapCacheMapper.h"
#import "ASDKFormFieldOptionCacheMapper.h"
#import "ASDKFormDescriptionCacheMapper.h"
#import "ASDKFormFieldValueRepresentationCacheMapper.h"
#import "ASDKFormVariableCacheMapper.h"


@implementation ASDKFormCacheService


#pragma mark -
#pragma mark Public interface

- (void)cacheRestFieldValues:(NSArray *)restFieldValues
                   forTaskID:(NSString *)taskID
             withFormFieldID:(NSString *)fieldID
         withCompletionBlock:(ASDKCacheServiceCompletionBlock)completionBlock {
    __weak typeof(self) weakSelf = self;
    [self.persistenceStack performBackgroundTask:^(NSManagedObjectContext *managedObjectContext) {
        __strong typeof(self) strongSelf = weakSelf;
        managedObjectContext.automaticallyMergesChangesFromParent = YES;
        managedObjectContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;
        
        NSError *error = [strongSelf cleanStalledRestFieldValuesInContext:managedObjectContext
                                                             forPredicate:[strongSelf restFieldValuesPredicateForTaskID:taskID
                                                                                                            formFieldID:fieldID]];
        if (!error) {
            error = [strongSelf saveRestFieldValuesAndGenerateFormFieldOptionMap:restFieldValues
                                                                       forTaskID:taskID
                                                                 withFormFieldID:fieldID
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

- (void)fetchRestFieldValuesForTaskID:(NSString *)taskID
                      withFormFieldID:(NSString *)fieldID
                  withCompletionBlock:(ASDKCacheServiceTaskRestFieldValuesCompletionBlock)completionBlock {
    [self fetchRestFieldValuesWithPredicate:[self restFieldValuesPredicateForTaskID:taskID
                                                                        formFieldID:fieldID]
                        withCompletionBlock:completionBlock];
}

- (void)cacheRestFieldValues:(NSArray *)restFieldValues
      forProcessDefinitionID:(NSString *)processDefinitionID
             withFormFieldID:(NSString *)fieldID
         withCompletionBlock:(ASDKCacheServiceCompletionBlock)completionBlock {
    __weak typeof(self) weakSelf = self;
    [self.persistenceStack performBackgroundTask:^(NSManagedObjectContext *managedObjectContext) {
        __strong typeof(self) strongSelf = weakSelf;
        managedObjectContext.automaticallyMergesChangesFromParent = YES;
        managedObjectContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;
        
        NSError *error = [strongSelf cleanStalledRestFieldValuesInContext:managedObjectContext
                                                             forPredicate:[self restFieldValuesPredicateForProcessDefinitionID:processDefinitionID
                                                                                                                   formFieldID:fieldID]];
        if (!error) {
            error = [strongSelf saveRestFieldValuesAndGenerateFormFieldOptionMap:restFieldValues
                                                          forProcessDefinitionID:processDefinitionID
                                                                 withFormFieldID:fieldID
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

- (void)fetchRestFieldValuesForProcessDefinitionID:(NSString *)processDefinitionID
                                   withFormFieldID:(NSString *)fieldID
                               withCompletionBlock:(ASDKCacheServiceTaskRestFieldValuesCompletionBlock)completionBlock {
    [self fetchRestFieldValuesWithPredicate:[self restFieldValuesPredicateForProcessDefinitionID:processDefinitionID
                                                                                     formFieldID:fieldID]
                        withCompletionBlock:completionBlock];
}

- (void)cacheRestFieldValues:(NSArray *)restFieldValues
                   forTaskID:(NSString *)taskID
             withFormFieldID:(NSString *)fieldID
                withColumnID:(NSString *)columnID
         withCompletionBlock:(ASDKCacheServiceCompletionBlock)completionBlock {
    __weak typeof(self) weakSelf = self;
    [self.persistenceStack performBackgroundTask:^(NSManagedObjectContext *managedObjectContext) {
        __strong typeof(self) strongSelf = weakSelf;
        managedObjectContext.automaticallyMergesChangesFromParent = YES;
        managedObjectContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;
        
        NSError *error = [strongSelf cleanStalledRestFieldValuesInContext:managedObjectContext
                                                             forPredicate:[self restFieldValuesPredicateForTaskID:taskID
                                                                                                      formFieldID:fieldID
                                                                                                         columnID:columnID]];
        if (!error) {
            error = [strongSelf saveRestFieldValuesAndGenerateFormFieldOptionMap:restFieldValues
                                                                       forTaskID:taskID
                                                                 withFormFieldID:fieldID
                                                                    withColumnID:columnID
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

- (void)fetchRestFieldValuesForTaskID:(NSString *)taskID
                      withFormFieldID:(NSString *)fieldID
                         withColumnID:(NSString *)columnID
                  withCompletionBlock:(ASDKCacheServiceTaskRestFieldValuesCompletionBlock)completionBlock {
    [self fetchRestFieldValuesWithPredicate:[self restFieldValuesPredicateForTaskID:taskID
                                                                        formFieldID:fieldID
                                                                           columnID:columnID]
                        withCompletionBlock:completionBlock];
}

- (void)cacheRestFieldValues:(NSArray *)restFieldValues
      forProcessDefinitionID:(NSString *)processDefinitionID
             withFormFieldID:(NSString *)fieldID
                withColumnID:(NSString *)columnID
         withCompletionBlock:(ASDKCacheServiceCompletionBlock)completionBlock {
    __weak typeof(self) weakSelf = self;
    [self.persistenceStack performBackgroundTask:^(NSManagedObjectContext *managedObjectContext) {
        __strong typeof(self) strongSelf = weakSelf;
        managedObjectContext.automaticallyMergesChangesFromParent = YES;
        managedObjectContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;
        
        NSError *error = [strongSelf cleanStalledRestFieldValuesInContext:managedObjectContext
                                                             forPredicate:[self restFieldValuesPredicateForProcessDefinitionID:processDefinitionID
                                                                                                                   formFieldID:fieldID
                                                                                                                      columnID:columnID]];
        if (!error) {
            error = [strongSelf saveRestFieldValuesAndGenerateFormFieldOptionMap:restFieldValues
                                                          forProcessDefinitionID:processDefinitionID
                                                                 withFormFieldID:fieldID
                                                                    withColumnID:columnID
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

- (void)fetchRestFieldValuesForProcessDefinition:(NSString *)processDefinitionID
                                 withFormFieldID:(NSString *)fieldID
                                    withColumnID:(NSString *)columnID
                             withCompletionBlock:(ASDKCacheServiceTaskRestFieldValuesCompletionBlock)completionBlock {
    [self fetchRestFieldValuesWithPredicate:[self restFieldValuesPredicateForProcessDefinitionID:processDefinitionID
                                                                                     formFieldID:fieldID
                                                                                        columnID:columnID]
                        withCompletionBlock:completionBlock];
}

- (void)cacheTaskFormDescription:(ASDKModelFormDescription *)formDescription
                       forTaskID:(NSString *)taskID
             withCompletionBlock:(ASDKCacheServiceCompletionBlock)completionBlock {
    [self cacheTaskFormDescription:formDescription
                         forTaskID:taskID
             isSaveFormDescription:NO
               withCompletionBlock:completionBlock];
}

- (void)cacheTaskFormDescriptionWithIntermediateValues:(ASDKModelFormDescription *)formDescription
                                             forTaskID:(NSString *)taskID
                                   withCompletionBlock:(ASDKCacheServiceCompletionBlock)completionBlock {
    [self cacheTaskFormDescription:formDescription
                         forTaskID:taskID
             isSaveFormDescription:YES
               withCompletionBlock:completionBlock];
}

- (void)cacheTaskFormDescription:(ASDKModelFormDescription *)formDescription
                       forTaskID:(NSString *)taskID
           isSaveFormDescription:(BOOL)isSaveFormDescription
             withCompletionBlock:(ASDKCacheServiceCompletionBlock)completionBlock {
    [self.persistenceStack performBackgroundTask:^(NSManagedObjectContext *managedObjectContext) {
        managedObjectContext.automaticallyMergesChangesFromParent = YES;
        managedObjectContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;
        
        NSError *error = nil;
        
        ASDKMOFormDescription *moFormDescription =
        [ASDKFormDescriptionCacheModelUpsert upsertTaskFormDescriptionToCache:formDescription
                                                                    forTaskID:taskID
                                                                        error:&error
                                                                  inMOContext:managedObjectContext];
        moFormDescription.isSavedFormDescription = isSaveFormDescription;
        
        if (!error) {
            [managedObjectContext save:&error];
        }
        
        if (completionBlock) {
            completionBlock(error);
        }
    }];

}

- (void)fetchTaskFormDescriptionForTaskID:(NSString *)taskID
                      withCompletionBlock:(ASDKCacheServiceTaskSavedFormDescriptionCompletionBlock)completionBlock {
    [self.persistenceStack performBackgroundTask:^(NSManagedObjectContext *managedObjectContext) {
        managedObjectContext.automaticallyMergesChangesFromParent = YES;
        managedObjectContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;
        
        NSError *error = nil;
        
        NSFetchRequest *fetchRequest = [ASDKMOFormDescription fetchRequest];
        fetchRequest.predicate = [ASDKFormDescriptionCacheModelUpsert formDescriptionPredicateForTaskID:taskID];
        NSArray *fetchResults = [managedObjectContext executeFetchRequest:fetchRequest
                                                                    error:&error];
        
        if (completionBlock) {
            ASDKMOFormDescription *moFormDescription = fetchResults.firstObject;
            
            if (error || !moFormDescription) {
                completionBlock(nil, error, NO);
            } else {
                ASDKModelFormDescription *formDescription = [ASDKFormDescriptionCacheMapper mapCacheMOToFormDescription:moFormDescription];
                completionBlock(formDescription, nil, moFormDescription.isSavedFormDescription);
            }
        }
    }];
}

- (void)cacheTaskFormVariables:(NSArray *)formVariables
                     forTaskID:(NSString *)taskID
           withCompletionBlock:(ASDKCacheServiceCompletionBlock)completionBlock {
    __weak typeof(self) weakSelf = self;
    [self.persistenceStack performBackgroundTask:^(NSManagedObjectContext *managedObjectContext) {
        __strong typeof(self) strongSelf = weakSelf;
        managedObjectContext.automaticallyMergesChangesFromParent = YES;
        managedObjectContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;
        
        NSError *error = [strongSelf cleanStalledFormVariablesInContext:managedObjectContext
                                                           forPredicate:[strongSelf formVariablesPredicateForTaskID:taskID]];
        if (!error) {
            error = [strongSelf saveFormVariables:formVariables
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

- (void)fetchTaskFormVariablesForTaskID:(NSString *)taskID
                    withCompletionBlock:(ASDKCacheServiceFormVariablesCompletionBlock)completionBlock {
    [self.persistenceStack performBackgroundTask:^(NSManagedObjectContext *managedObjectContext) {
        managedObjectContext.automaticallyMergesChangesFromParent = YES;
        managedObjectContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;
        
        NSError *error = nil;
        NSFetchRequest *fetchFormVariablesRequest = [ASDKMOFormVariable fetchRequest];
        NSArray *fetchResults = [managedObjectContext executeFetchRequest:fetchFormVariablesRequest
                                                                    error:&error];
        
        if (completionBlock) {
            if (error || !fetchResults.count) {
                completionBlock(nil, error);
            } else {
                NSMutableArray *formVariableList = [NSMutableArray array];
                
                for (ASDKMOFormVariable *moFormVariable in fetchResults) {
                    ASDKModelFormVariable *formVariable = [ASDKFormVariableCacheMapper mapCacheMOToFormVariable:moFormVariable];
                    [formVariableList addObject:formVariable];
                }
                
                completionBlock(formVariableList, nil);
            }
        }
    }];
}

- (void)cacheProcessInstanceFormDescription:(ASDKModelFormDescription *)formDescription
                       forProcessInstanceID:(NSString *)processInstanceID
                        withCompletionBlock:(ASDKCacheServiceCompletionBlock)completionBlock {
    [self.persistenceStack performBackgroundTask:^(NSManagedObjectContext *managedObjectContext) {
        managedObjectContext.automaticallyMergesChangesFromParent = YES;
        managedObjectContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;
        
        NSError *error = nil;
        
        [ASDKFormDescriptionCacheModelUpsert upsertProcessInstanceFormDescriptionToCache:formDescription
                                                                    forProcessInstanceID:processInstanceID
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

- (void)fetchProcessInstanceFormDescriptionForProcessInstance:(NSString *)processInstanceID
                                          withCompletionBlock:(ASDKCacheServiceFormDescriptionCompletionBlock)completionBlock {
    [self fetchFormDescriptionWithPredicate:[ASDKFormDescriptionCacheModelUpsert formDescriptionPredicateForProcessInstanceID:processInstanceID]
                        withCompletionBlock:completionBlock];
}

- (void)cacheProcessDefinitionFormDescription:(ASDKModelFormDescription *)formDescription
                       forProcessDefinitionID:(NSString *)processDefinitionID
                          withCompletionBlock:(ASDKCacheServiceCompletionBlock)completionBlock {
    [self.persistenceStack performBackgroundTask:^(NSManagedObjectContext *managedObjectContext) {
        managedObjectContext.automaticallyMergesChangesFromParent = YES;
        managedObjectContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;
        
        NSError *error = nil;
        
        [ASDKFormDescriptionCacheModelUpsert upsertProcessDefinitionFormDescriptionToCache:formDescription
                                                                    forProcessDefinitionID:processDefinitionID
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

- (void)fetchProcessDefinitionFormDescriptionForProcessDefinitionID:(NSString *)processDefinitionID
                                                withCompletionBlock:(ASDKCacheServiceFormDescriptionCompletionBlock)completionBlock {
    [self fetchFormDescriptionWithPredicate:[ASDKFormDescriptionCacheModelUpsert formDescriptionPredicateForProcessDefinitionID:processDefinitionID]
                        withCompletionBlock:completionBlock];
}

- (void)fetchFormDescriptionWithPredicate:(NSPredicate *)predicate
                      withCompletionBlock:(ASDKCacheServiceFormDescriptionCompletionBlock)completionBlock {
    [self.persistenceStack performBackgroundTask:^(NSManagedObjectContext *managedObjectContext) {
        managedObjectContext.automaticallyMergesChangesFromParent = YES;
        managedObjectContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;
        
        NSError *error = nil;
        
        NSFetchRequest *fetchRequest = [ASDKMOFormDescription fetchRequest];
        fetchRequest.predicate = predicate;
        NSArray *fetchResults = [managedObjectContext executeFetchRequest:fetchRequest
                                                                    error:&error];
        
        if (completionBlock) {
            ASDKMOFormDescription *moFormDescription = fetchResults.firstObject;
            
            if (error || !moFormDescription) {
                completionBlock(nil, error);
            } else {
                ASDKModelFormDescription *formDescription = [ASDKFormDescriptionCacheMapper mapCacheMOToFormDescription:moFormDescription];
                completionBlock(formDescription, nil);
            }
        }
    }];
}

- (void)cacheTaskFormFieldValuesRepresentation:(ASDKFormFieldValueRequestRepresentation *)formFieldValueRequestRepresentation
                                     forTaskID:(NSString *)taskID
                           withCompletionBlock:(ASDKCacheServiceCompletionBlock)completionBlock {
    [self.persistenceStack performBackgroundTask:^(NSManagedObjectContext *managedObjectContext) {
        managedObjectContext.automaticallyMergesChangesFromParent = YES;
        managedObjectContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;
        
        NSError *error = nil;
        
        [ASDKFormFieldValueRepresentationCacheModelUpsert upsertFormFieldValueToCache:formFieldValueRequestRepresentation
                                                                            forTaskID:taskID
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

- (void)fetchTaskFormFieldValuesRepresentationForTaskID:(NSString *)taskID
                                    withCompletionBlock:(ASDKCacheServiceTaskFormValueRepresentationCompletionBlock)completionBlock {
    [self.persistenceStack performBackgroundTask:^(NSManagedObjectContext *managedObjectContext) {
        managedObjectContext.automaticallyMergesChangesFromParent = YES;
        managedObjectContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;
        
        NSError *error = nil;
        NSFetchRequest *fetchFormFieldValuesRepresentationRequest = [ASDKMOFormFieldValueRepresentation fetchRequest];
        fetchFormFieldValuesRepresentationRequest.predicate = [NSPredicate predicateWithFormat:@"taskID == %@", taskID];
        NSArray *fetchResults = [managedObjectContext executeFetchRequest:fetchFormFieldValuesRepresentationRequest
                                                                    error:&error];
        
        if (completionBlock) {
            ASDKMOFormFieldValueRepresentation *moFormFieldValueRepresentation = fetchResults.firstObject;
            
            if (error || !moFormFieldValueRepresentation) {
                completionBlock(nil, error);
            } else {
                ASDKFormFieldValueRequestRepresentation *formFieldValueRequestRepresentation = [ASDKFormFieldValueRepresentationCacheMapper mapCacheMOToFormFieldValueRepresentation:moFormFieldValueRepresentation];
                completionBlock(formFieldValueRequestRepresentation, nil);
            }
        }
    }];
}

- (void)removeStalledFormFieldValuesRepresentationsForTaskIDs:(NSArray *)taskIDs
                                          withCompletionBlock:(ASDKCacheServiceCompletionBlock)completionBlock {
    [self.persistenceStack performBackgroundTask:^(NSManagedObjectContext *managedObjectContext) {
        managedObjectContext.automaticallyMergesChangesFromParent = YES;
        managedObjectContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;
        
        NSError *error = nil;
        
        NSFetchRequest *oldFormFieldValuesRequest = [ASDKMOFormFieldValueRepresentation fetchRequest];
        oldFormFieldValuesRequest.predicate = [NSPredicate predicateWithFormat:@"SELF.taskID IN %@", taskIDs];
        oldFormFieldValuesRequest.resultType = NSManagedObjectIDResultType;

        NSBatchDeleteRequest *removeOldFormFieldValuesRequest = [[NSBatchDeleteRequest alloc] initWithFetchRequest:oldFormFieldValuesRequest];
        removeOldFormFieldValuesRequest.resultType = NSBatchDeleteResultTypeObjectIDs;
        NSBatchDeleteResult *removeOldFormFieldValuesResult = [managedObjectContext executeRequest:removeOldFormFieldValuesRequest
                                                                                             error:&error];
        NSArray *moIDArr = removeOldFormFieldValuesResult.result;
        [NSManagedObjectContext mergeChangesFromRemoteContextSave:@{NSDeletedObjectsKey : moIDArr}
                                                     intoContexts:@[managedObjectContext]];
        if (error) {
            error = [self clearCacheStalledDataError];
        }
        
        if (!error) {
            [managedObjectContext save:&error];
        }
        
        if (completionBlock) {
            completionBlock(error);
        }
    }];
}

- (void)fetchAllTaskFormFieldValueRepresentationsWithCompletionBlock:(ASDKCacheServiceTaskFormValueRepresentationListCompletionBlock)completionBlock {
    [self.persistenceStack performBackgroundTask:^(NSManagedObjectContext *managedObjectContext) {
        managedObjectContext.automaticallyMergesChangesFromParent = YES;
        managedObjectContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;
        
        NSError *error = nil;
        NSFetchRequest *fetchFormFieldValuesRepresentationRequest = [ASDKMOFormFieldValueRepresentation fetchRequest];
        NSArray *fetchResults = [managedObjectContext executeFetchRequest:fetchFormFieldValuesRepresentationRequest
                                                                    error:&error];
        
        if (completionBlock) {
            if (error || !fetchResults.count) {
                completionBlock(nil, nil, error);
            } else {
                NSMutableArray *formFieldValueList = [NSMutableArray array];
                NSMutableArray *taskIDsList = [NSMutableArray array];
                for (ASDKMOFormFieldValueRepresentation *moFormFieldValueRepresentation in fetchResults) {
                    ASDKFormFieldValueRequestRepresentation *formFieldValueRequestRepresentation = [ASDKFormFieldValueRepresentationCacheMapper mapCacheMOToFormFieldValueRepresentation:moFormFieldValueRepresentation];
                    [formFieldValueList addObject:formFieldValueRequestRepresentation];
                    [taskIDsList addObject:moFormFieldValueRepresentation.taskID];
                }
                
                completionBlock(formFieldValueList, taskIDsList, nil);
            }
        }
    }];
}


#pragma mark -
#pragma mark Operations

- (NSError *)cleanStalledRestFieldValuesInContext:(NSManagedObjectContext *)managedObjectContext
                                     forPredicate:(NSPredicate *)predicate {
    NSError *internalError = nil;
    NSFetchRequest *oldRestFieldValuesRequest = [ASDKMOFormFieldOptionMap fetchRequest];
    oldRestFieldValuesRequest.predicate = predicate;
    oldRestFieldValuesRequest.resultType = NSManagedObjectIDResultType;
    
    NSBatchDeleteRequest *removeOldRestFieldValuesRequest = [[NSBatchDeleteRequest alloc] initWithFetchRequest:oldRestFieldValuesRequest];
    removeOldRestFieldValuesRequest.resultType = NSBatchDeleteResultTypeObjectIDs;
    NSBatchDeleteResult *removeOldRestFieldValuesResult = [managedObjectContext executeRequest:removeOldRestFieldValuesRequest
                                                                                         error:&internalError];
    NSArray *moIDArr = removeOldRestFieldValuesResult.result;
    [NSManagedObjectContext mergeChangesFromRemoteContextSave:@{NSDeletedObjectsKey : moIDArr}
                                                 intoContexts:@[managedObjectContext]];
    if (internalError) {
        return [self clearCacheStalledDataError];
    }
    
    return nil;
}

- (void)fetchRestFieldValuesWithPredicate:(NSPredicate *)predicate
                      withCompletionBlock:(ASDKCacheServiceTaskRestFieldValuesCompletionBlock)completionBlock {
    [self.persistenceStack performBackgroundTask:^(NSManagedObjectContext *managedObjectContext) {
        NSError *error = nil;
        NSArray *matchingRestFieldValueArr = nil;
        
        NSFetchRequest *formFieldOptionMapRequest = [ASDKMOFormFieldOptionMap fetchRequest];
        formFieldOptionMapRequest.predicate = predicate;
        NSArray *formFieldOptionMapArr = [managedObjectContext executeFetchRequest:formFieldOptionMapRequest
                                                                             error:&error];
        if (!error) {
            ASDKMOFormFieldOptionMap *formFieldOptionMap = formFieldOptionMapArr.firstObject;
            matchingRestFieldValueArr = [formFieldOptionMap.restFieldValueList allObjects];
        }
        
        if (completionBlock) {
            if (error || !matchingRestFieldValueArr.count) {
                completionBlock(nil, error);
            } else {
                NSMutableArray *restFieldValues = [NSMutableArray array];
                for (ASDKMOFormFieldOption *moFormFieldOption in matchingRestFieldValueArr) {
                    ASDKModelFormFieldOption *formFieldOption = [ASDKFormFieldOptionCacheMapper mapCacheMOToFormFieldOption:moFormFieldOption];
                    [restFieldValues addObject:formFieldOption];
                }
                
                completionBlock(restFieldValues, nil);
            }
        }
    }];
}

- (NSError *)saveRestFieldValuesAndGenerateFormFieldOptionMap:(NSArray *)formFieldOptionList
                                                    forTaskID:(NSString *)taskID
                                              withFormFieldID:(NSString *)fieldID
                                                    inContext:(NSManagedObjectContext *)managedObjectContext {
    // Upsert rest field values
    NSError *error = nil;
    NSArray *moFormFieldOptionList = [ASDKFormFieldOptionCacheModelUpsert upsertFormFieldOptionListToCache:formFieldOptionList
                                                                                                     error:&error
                                                                                               inMOContext:managedObjectContext];
    if (error) {
        return error;
    }
    
    // Fetch existing or create form field option map
    NSFetchRequest *formFieldOptionMapRequest = [ASDKMOFormFieldOptionMap fetchRequest];
    formFieldOptionMapRequest.predicate = [self restFieldValuesPredicateForTaskID:taskID
                                                                      formFieldID:fieldID];
    NSArray *fetchResults = [managedObjectContext executeFetchRequest:formFieldOptionMapRequest
                                                                error:&error];
    if (error) {
        return error;
    }
    
    ASDKMOFormFieldOptionMap *formFieldOptionMap = fetchResults.firstObject;
    if (!formFieldOptionMap) {
        formFieldOptionMap = [NSEntityDescription insertNewObjectForEntityForName:[ASDKMOFormFieldOptionMap entityName]
                                                           inManagedObjectContext:managedObjectContext];
    }
    
    [ASDKFormFieldOptionMapCacheMapper mapRestFieldValueList:moFormFieldOptionList
                                                   forTaskID:taskID
                                             withFormFieldID:fieldID
                                                   toCacheMO:formFieldOptionMap];
    
    return nil;
}

- (NSError *)saveRestFieldValuesAndGenerateFormFieldOptionMap:(NSArray *)formFieldOptionList
                                       forProcessDefinitionID:(NSString *)processDefinitionID
                                              withFormFieldID:(NSString *)fieldID
                                                    inContext:(NSManagedObjectContext *)managedObjectContext {
    // Upsert rest field values
    NSError *error = nil;
    NSArray *moFormFieldOptionList = [ASDKFormFieldOptionCacheModelUpsert upsertFormFieldOptionListToCache:formFieldOptionList
                                                                                                     error:&error
                                                                                               inMOContext:managedObjectContext];
    if (error) {
        return error;
    }
    
    // Fetch existing or create form field option map
    NSFetchRequest *formFieldOptionMapRequest = [ASDKMOFormFieldOptionMap fetchRequest];
    formFieldOptionMapRequest.predicate = [self restFieldValuesPredicateForProcessDefinitionID:processDefinitionID
                                                                                   formFieldID:fieldID];
    NSArray *fetchResults = [managedObjectContext executeFetchRequest:formFieldOptionMapRequest
                                                                error:&error];
    if (error) {
        return error;
    }
    
    ASDKMOFormFieldOptionMap *formFieldOptionMap = fetchResults.firstObject;
    if (!formFieldOptionMap) {
        formFieldOptionMap = [NSEntityDescription insertNewObjectForEntityForName:[ASDKMOFormFieldOptionMap entityName]
                                                           inManagedObjectContext:managedObjectContext];
    }
    
    [ASDKFormFieldOptionMapCacheMapper mapRestFieldValueList:moFormFieldOptionList
                                      forProcessDefinitionID:processDefinitionID
                                             withFormFieldID:fieldID
                                                   toCacheMO:formFieldOptionMap];
    
    return nil;
}

- (NSError *)saveRestFieldValuesAndGenerateFormFieldOptionMap:(NSArray *)formFieldOptionList
                                                    forTaskID:(NSString *)taskID
                                              withFormFieldID:(NSString *)fieldID
                                                 withColumnID:(NSString *)columnID
                                                    inContext:(NSManagedObjectContext *)managedObjectContext {
    // Upsert rest field values
    NSError *error = nil;
    NSArray *moFormFieldOptionList = [ASDKFormFieldOptionCacheModelUpsert upsertFormFieldOptionListToCache:formFieldOptionList
                                                                                                     error:&error
                                                                                               inMOContext:managedObjectContext];
    if (error) {
        return error;
    }
    
    // Fetch existing or create form field option map
    NSFetchRequest *formFieldOptionMapRequest = [ASDKMOFormFieldOptionMap fetchRequest];
    formFieldOptionMapRequest.predicate = [self restFieldValuesPredicateForTaskID:taskID
                                                                      formFieldID:fieldID
                                                                         columnID:columnID];
    NSArray *fetchResults = [managedObjectContext executeFetchRequest:formFieldOptionMapRequest
                                                                error:&error];
    if (error) {
        return error;
    }
    
    ASDKMOFormFieldOptionMap *formFieldOptionMap = fetchResults.firstObject;
    if (!formFieldOptionMap) {
        formFieldOptionMap = [NSEntityDescription insertNewObjectForEntityForName:[ASDKMOFormFieldOptionMap entityName]
                                                           inManagedObjectContext:managedObjectContext];
    }
    
    [ASDKFormFieldOptionMapCacheMapper mapRestFieldValueList:moFormFieldOptionList
                                                   forTaskID:taskID
                                             withFormFieldID:fieldID
                                                withColumnID:columnID
                                                   toCacheMO:formFieldOptionMap];
    
    return nil;
}

- (NSError *)saveRestFieldValuesAndGenerateFormFieldOptionMap:(NSArray *)formFieldOptionList
                                       forProcessDefinitionID:(NSString *)processDefinitionID
                                              withFormFieldID:(NSString *)formFieldID
                                                 withColumnID:(NSString *)columnID
                                                    inContext:(NSManagedObjectContext *)managedObjectContext {
    // Upsert rest field values
    NSError *error = nil;
    NSArray *moFormFieldOptionList = [ASDKFormFieldOptionCacheModelUpsert upsertFormFieldOptionListToCache:formFieldOptionList
                                                                                                     error:&error
                                                                                               inMOContext:managedObjectContext];
    if (error) {
        return error;
    }
    
    // Fetch existing or create form field option map
    NSFetchRequest *formFieldOptionMapRequest = [ASDKMOFormFieldOptionMap fetchRequest];
    formFieldOptionMapRequest.predicate = [self restFieldValuesPredicateForProcessDefinitionID:processDefinitionID
                                                                                   formFieldID:formFieldID
                                                                                      columnID:columnID];
    NSArray *fetchResults = [managedObjectContext executeFetchRequest:formFieldOptionMapRequest
                                                                error:&error];
    if (error) {
        return error;
    }
    
    ASDKMOFormFieldOptionMap *formFieldOptionMap = fetchResults.firstObject;
    if (!formFieldOptionMap) {
        formFieldOptionMap = [NSEntityDescription insertNewObjectForEntityForName:[ASDKMOFormFieldOptionMap entityName]
                                                           inManagedObjectContext:managedObjectContext];
    }
    
    [ASDKFormFieldOptionMapCacheMapper mapRestFieldValueList:moFormFieldOptionList
                                      forProcessDefinitionID:processDefinitionID
                                             withFormFieldID:formFieldID
                                                withColumnID:columnID
                                                   toCacheMO:formFieldOptionMap];
    return nil;
}

- (NSError *)cleanStalledFormVariablesInContext:(NSManagedObjectContext *)managedObjectContext
                                   forPredicate:(NSPredicate *)predicate {
    NSError *internalError = nil;
    NSFetchRequest *oldFormVariables = [ASDKMOFormVariable fetchRequest];
    oldFormVariables.predicate = predicate;
    oldFormVariables.resultType = NSManagedObjectIDResultType;
    
    NSBatchDeleteRequest *removeOldFormVariablesRequest = [[NSBatchDeleteRequest alloc] initWithFetchRequest:oldFormVariables];
    removeOldFormVariablesRequest.resultType = NSBatchDeleteResultTypeObjectIDs;
    NSBatchDeleteResult *removeOldFormVariablesResult = [managedObjectContext executeRequest:removeOldFormVariablesRequest
                                                                                         error:&internalError];
    NSArray *moIDArr = removeOldFormVariablesResult.result;
    [NSManagedObjectContext mergeChangesFromRemoteContextSave:@{NSDeletedObjectsKey : moIDArr}
                                                 intoContexts:@[managedObjectContext]];
    if (internalError) {
        return [self clearCacheStalledDataError];
    }
    
    return nil;
}

- (NSError *)saveFormVariables:(NSArray *)formVariables
                forTaskID:(NSString *)taskID
                inContext:(NSManagedObjectContext *)managedObjectContext {
    // Upsert form variables
    NSError *error = nil;
    NSArray *moFormVariableList = [ASDKFormVariablesCacheModelUpsert upsertFormVariableListToCache:formVariables
                                                                                         forTaskID:taskID
                                                                                             error:&error
                                                                                       inMOContext:managedObjectContext];
    return error;
}


#pragma mark -
#pragma mark Predicate construction

- (NSPredicate *)restFieldValuesPredicateForTaskID:(NSString *)taskID
                                       formFieldID:(NSString *)formFieldID {
    NSPredicate *predicate = nil;
    
    if (taskID.length || formFieldID.length) {
        predicate = [NSPredicate predicateWithFormat:@"taskID == %@ && formFieldID == %@", taskID, formFieldID];
    }
    
    return predicate;
}

- (NSPredicate *)restFieldValuesPredicateForProcessDefinitionID:(NSString *)processDefinitionID
                                                    formFieldID:(NSString *)formFieldID {
    NSPredicate *predicate = nil;
    
    if (processDefinitionID.length || formFieldID.length) {
        predicate = [NSPredicate predicateWithFormat:@"processDefinitionID == %@ && formFieldID == %@", processDefinitionID, formFieldID];
    }
    
    return predicate;
}

- (NSPredicate *)formVariablesPredicateForTaskID:(NSString *)taskID {
    NSPredicate *predicate = nil;
    
    if (taskID.length) {
        predicate = [NSPredicate predicateWithFormat:@"taskID == %@", taskID];
    }
    
    return predicate;
}

- (NSPredicate *)restFieldValuesPredicateForTaskID:(NSString *)taskID
                                       formFieldID:(NSString *)formFieldID
                                          columnID:(NSString *)columnID {
    NSPredicate *predicate = nil;
    
    if (taskID.length || formFieldID.length || columnID.length) {
        predicate = [NSPredicate predicateWithFormat:@"taskID == %@ && formFieldID == %@ && columnID == %@", taskID, formFieldID, columnID];
    }
    
    return predicate;
}

- (NSPredicate *)restFieldValuesPredicateForProcessDefinitionID:(NSString *)processDefinitionID
                                                    formFieldID:(NSString *)formFieldID
                                                       columnID:(NSString *)columnID {
    NSPredicate *predicate = nil;
    
    if (processDefinitionID.length || formFieldID.length || columnID.length) {
        predicate = [NSPredicate predicateWithFormat:@"processDefinitionID == %@ && formFieldID == %@ && columnID == %@", processDefinitionID, formFieldID, columnID];
    }
    
    return predicate;
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

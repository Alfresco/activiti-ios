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

#import "ASDKFormVariablesCacheModelUpsert.h"

// Models
#import "ASDKMOFormVariable.h"
#import "ASDKModelFormVariable.h"

// Model mappers
#import "ASDKFormVariableCacheMapper.h"


@implementation ASDKFormVariablesCacheModelUpsert

+ (NSArray *)upsertFormVariableListToCache:(NSArray *)formVariableList
                                 forTaskID:(NSString *)taskID
                                     error:(NSError **)error
                               inMOContext:(NSManagedObjectContext *)moContext {
    NSError *internalError = nil;
    NSArray *newIDs = [formVariableList valueForKey:@"modelID"];
    NSMutableArray *moFormVariables = [NSMutableArray array];
    
    NSFetchRequest *fetchFormVariablesListRequest = [ASDKMOFormVariable fetchRequest];
    fetchFormVariablesListRequest.predicate = [NSPredicate predicateWithFormat:@"modelID IN %@", newIDs];
    NSArray *formVariablesResult = [moContext executeFetchRequest:fetchFormVariablesListRequest
                                                            error:&internalError];
    
    if (!internalError) {
        NSArray *oldIDs = [formVariablesResult valueForKey:@"modelID"];
        
        // Elements to update
        NSPredicate *intersectPredicate = [NSPredicate predicateWithFormat:@"SELF IN %@", newIDs];
        NSArray *updatedIDsArr = [oldIDs filteredArrayUsingPredicate:intersectPredicate];
        
        // Elements to insert
        NSPredicate *relativeComplementPredicate = [NSPredicate predicateWithFormat:@"NOT SELF IN %@", oldIDs];
        NSArray *insertedIDsArr = [newIDs filteredArrayUsingPredicate:relativeComplementPredicate];
        
        // Elements to delete
        NSArray *deletedIDsArr = [oldIDs filteredArrayUsingPredicate:relativeComplementPredicate];
        
        // Perform delete operations
        for (NSString *idString in deletedIDsArr) {
            NSArray *formVariablesToBeDeleted = [formVariablesResult filteredArrayUsingPredicate:[self predicateMatchingModelID:idString]];
            ASDKMOFormVariable *formVariableToBeDeleted = formVariablesToBeDeleted.firstObject;
            [moContext deleteObject:formVariableToBeDeleted];
        }
        
        // Perform insert operations
        for (NSString *idString in insertedIDsArr) {
            NSArray *formVariablesToBeInserted = [formVariableList filteredArrayUsingPredicate:[self predicateMatchingModelID:idString]];
            for (ASDKModelFormVariable *formVariable in formVariablesToBeInserted) {
                ASDKMOFormVariable *moFormVariable = [NSEntityDescription insertNewObjectForEntityForName:[ASDKMOFormVariable entityName]
                                                                                   inManagedObjectContext:moContext];
                
                [ASDKFormVariableCacheMapper mapFormVariable:formVariable
                                               forTaskWithID:taskID
                                                   toCacheMO:moFormVariable];
                
                [moFormVariables addObject:moFormVariable];
            }
        }
        
        // Perform update operations
        for (NSString *idString in updatedIDsArr) {
            NSArray *formVariableListToBeUpdated = [formVariablesResult filteredArrayUsingPredicate:[self predicateMatchingModelID:idString]];
            for (ASDKMOFormVariable *moFormVariable in formVariableListToBeUpdated) {
                NSArray *correspondentFormVariableList = [formVariableList filteredArrayUsingPredicate:[self predicateMatchingModelID:idString]];
                ASDKModelFormVariable *formVariable = correspondentFormVariableList.firstObject;
                
                [ASDKFormVariableCacheMapper mapFormVariable:formVariable
                                               forTaskWithID:taskID
                                                   toCacheMO:moFormVariable];
                
                [moFormVariables addObject:moFormVariable];
            }
        }
    }
    
    *error = internalError;
    return moFormVariables;
}

+ (NSPredicate *)predicateMatchingModelID:(NSString *)modelID {
    return [NSPredicate predicateWithFormat:@"modelID == %@", modelID];
}

@end

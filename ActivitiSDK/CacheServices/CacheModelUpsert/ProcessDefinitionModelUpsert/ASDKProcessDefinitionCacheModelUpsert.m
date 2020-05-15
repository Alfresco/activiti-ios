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

#import "ASDKProcessDefinitionCacheModelUpsert.h"

// Models
#import "ASDKMOProcessDefinition.h"
#import "ASDKModelProcessDefinition.h"

// Model mappers
#import "ASDKProcessDefinitionCacheMapper.h"

@implementation ASDKProcessDefinitionCacheModelUpsert

+ (NSArray *)upsertProcessDefinitionListToCache:(NSArray *)processDefinitionList
                                          error:(NSError **)error
                                    inMOContext:(NSManagedObjectContext *)moContext {
    NSError *internalError = nil;
    NSArray *newIDs = [processDefinitionList valueForKey:@"modelID"];
    NSMutableArray *moProcessDefinitions = [NSMutableArray array];
    
    NSFetchRequest *fetchProcessDefinitionListRequest = [ASDKMOProcessDefinition fetchRequest];
    fetchProcessDefinitionListRequest.predicate = [NSPredicate predicateWithFormat:@"modelID IN %@", newIDs];
    NSArray *processDefinitionResults = [moContext executeFetchRequest:fetchProcessDefinitionListRequest
                                                                 error:&internalError];
    if (!internalError) {
        NSArray *oldIDs = [processDefinitionResults valueForKey:@"modelID"];
        
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
            NSPredicate *modelIDMatchingPredicate = [self predicateMatchingModelID:idString];
            NSArray *processDefinitionsToBeDeleted = [processDefinitionResults filteredArrayUsingPredicate:modelIDMatchingPredicate];
            ASDKMOProcessDefinition *processDefinitionToBeDeleted = processDefinitionsToBeDeleted.firstObject;
            [moContext deleteObject:processDefinitionToBeDeleted];
        }
        
        // Perform insert operations
        for (NSString *idString in insertedIDsArr) {
            NSPredicate *modelIDMatchingPredicate = [self predicateMatchingModelID:idString];
            NSArray *processDefinitionsToBeInserted = [processDefinitionList filteredArrayUsingPredicate:modelIDMatchingPredicate];
            for (ASDKModelProcessDefinition *processDefinition in processDefinitionsToBeInserted) {
                ASDKMOProcessDefinition *moProcessDefinition = [NSEntityDescription insertNewObjectForEntityForName:[ASDKMOProcessDefinition entityName]
                                                                                             inManagedObjectContext:moContext];
                [self populateMOProcessDefinition:moProcessDefinition
              withPropertiesFromProcessDefinition:processDefinition
                                      inMOContext:moContext];
                
                [moProcessDefinitions addObject:moProcessDefinition];
            }
        }
        
        // Perform update operations
        for (NSString *idString in updatedIDsArr) {
            NSPredicate *modelIDMatchingPredicate = [self predicateMatchingModelID:idString];
            NSArray *processDefinitionsToBeUpdated = [processDefinitionResults filteredArrayUsingPredicate:modelIDMatchingPredicate];
            for (ASDKMOProcessDefinition *moProcessDefinition in processDefinitionsToBeUpdated) {
                modelIDMatchingPredicate = [self predicateMatchingModelID:moProcessDefinition.modelID];
                NSArray *correspondentProcessDefinitions = [processDefinitionList filteredArrayUsingPredicate:modelIDMatchingPredicate];
                ASDKModelProcessDefinition *processDefinition = correspondentProcessDefinitions.firstObject;
                
                [self populateMOProcessDefinition:moProcessDefinition
              withPropertiesFromProcessDefinition:processDefinition
                                      inMOContext:moContext];
                
                [moProcessDefinitions addObject:moProcessDefinition];
            }
        }
    }
    
    *error = internalError;
    return moProcessDefinitions;
}

+ (ASDKMOProcessDefinition *)populateMOProcessDefinition:(ASDKMOProcessDefinition *)moProcessDefinition
                     withPropertiesFromProcessDefinition:(ASDKModelProcessDefinition *)processDefinition
                                             inMOContext:(NSManagedObjectContext *)moContext {
    [ASDKProcessDefinitionCacheMapper mapProcessDefinition:processDefinition
                                                 toCacheMO:moProcessDefinition];
    return moProcessDefinition;
}

+ (NSPredicate *)predicateMatchingModelID:(NSString *)modelID {
    return [NSPredicate predicateWithFormat:@"modelID == %@", modelID];
}

@end

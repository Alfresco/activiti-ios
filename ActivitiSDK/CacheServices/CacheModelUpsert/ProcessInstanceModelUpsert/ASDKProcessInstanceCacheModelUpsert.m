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
 *  See the License for the  specific language governing permissions and
 *  limitations under the License.
 ******************************************************************************/

#import "ASDKProcessInstanceCacheModelUpsert.h"

// Models
#import "ASDKMOProcessInstance.h"
#import "ASDKModelProcessInstance.h"
#import "ASDKModelProfile.h"
#import "ASDKMOProfile.h"

// Model mappers
#import "ASDKProcessInstanceCacheMapper.h"

// Model upsert
#import "ASDKProfileCacheModelUpsert.h"


@implementation ASDKProcessInstanceCacheModelUpsert

+ (ASDKMOProcessInstance *)upsertProcessInstanceToCache:(ASDKModelProcessInstance *)processInstance
                                                  error:(NSError **)error
                                            inMOContext:(NSManagedObjectContext *)moContext {
    NSError *internalError = nil;
    ASDKMOProcessInstance *moProcessInstance = nil;
    
    NSFetchRequest *fetchProcessInstanceRequest = [ASDKMOProcessInstance fetchRequest];
    fetchProcessInstanceRequest.predicate = [self predicateMatchingModelID:processInstance.modelID];
    NSArray *processInstanceResults = [moContext executeFetchRequest:fetchProcessInstanceRequest
                                                               error:&internalError];
    if (!internalError) {
        moProcessInstance = processInstanceResults.firstObject;
        if (!moProcessInstance) {
            moProcessInstance = [NSEntityDescription insertNewObjectForEntityForName:[ASDKMOProcessInstance entityName]
                                                              inManagedObjectContext:moContext];
        }
        
        // Map process instance properties to managed object
        [self populateMOProcessInstance:moProcessInstance
      withPropertiesFromProcessInstance:processInstance
                            inMOContext:moContext
                                  error:&internalError];
    }
    
    *error = internalError;
    return moProcessInstance;
}

+ (NSArray *)upsertProcessInstanceListToCache:(NSArray *)processInstanceList
                                        error:(NSError **)error
                                  inMOContext:(NSManagedObjectContext *)moContext {
    NSError *internalError = nil;
    NSArray *newIDs = [processInstanceList valueForKey:@"modelID"];
    NSMutableArray *moProcessInstances = [NSMutableArray array];
    
    NSFetchRequest *fetchProcessInstanceListRequest = [ASDKMOProcessInstance fetchRequest];
    fetchProcessInstanceListRequest.predicate = [NSPredicate predicateWithFormat:@"modelID IN %@", newIDs];
    NSArray *processInstanceResults = [moContext executeFetchRequest:fetchProcessInstanceListRequest
                                                               error:&internalError];
    
    if (!internalError) {
        NSArray *oldIDs = [processInstanceResults valueForKey:@"modelID"];
        
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
            NSArray *processInstancesToBeDeleted = [processInstanceResults filteredArrayUsingPredicate:modelIDMatchingPredicate];
            ASDKMOProcessInstance *processInstanceToBeDeleted = processInstancesToBeDeleted.firstObject;
            [moContext deleteObject:processInstanceToBeDeleted];
        }
        
        // Perform insert operations
        for (NSString *idString in insertedIDsArr) {
            NSPredicate *modelIDMatchingPredicate = [self predicateMatchingModelID:idString];
            NSArray *processInstancesToBeInserted = [processInstanceList filteredArrayUsingPredicate:modelIDMatchingPredicate];
            for (ASDKModelProcessInstance *processInstance in processInstancesToBeInserted) {
                ASDKMOProcessInstance *moProcessInstance = [NSEntityDescription insertNewObjectForEntityForName:[ASDKMOProcessInstance entityName]
                                                                                         inManagedObjectContext:moContext];
                [self populateMOProcessInstance:moProcessInstance
              withPropertiesFromProcessInstance:processInstance
                                    inMOContext:moContext
                                          error:&internalError];
                if (internalError) {
                    break;
                } else {
                    [moProcessInstances addObject:moProcessInstance];
                }
            }
        }
        
        if (!internalError) {
            // Perform update operations
            for (NSString *idString in updatedIDsArr) {
                NSPredicate *modelIDMatchingPredicate = [self predicateMatchingModelID:idString];
                NSArray *processInstancesToBeUpdated = [processInstanceResults filteredArrayUsingPredicate:modelIDMatchingPredicate];
                for (ASDKMOProcessInstance *moProcessInstance in processInstancesToBeUpdated) {
                    modelIDMatchingPredicate = [self predicateMatchingModelID:moProcessInstance.modelID];
                    NSArray *correspondentProcessInstances = [processInstanceList filteredArrayUsingPredicate:modelIDMatchingPredicate];
                    ASDKModelProcessInstance *processInstance = correspondentProcessInstances.firstObject;
                    
                    [self populateMOProcessInstance:moProcessInstance
                  withPropertiesFromProcessInstance:processInstance
                                        inMOContext:moContext
                                              error:&internalError];
                    if (internalError) {
                        break;
                    } else {
                        [moProcessInstances addObject:moProcessInstance];
                    }
                }
            }
        }
    }
    
    *error = internalError;
    return moProcessInstances;
}

+ (ASDKMOProcessInstance *)populateMOProcessInstance:(ASDKMOProcessInstance *)moProcessInstance
                   withPropertiesFromProcessInstance:(ASDKModelProcessInstance *)processInstance
                                         inMOContext:(NSManagedObjectContext *)moContext
                                               error:(NSError **)error {
    NSError *internalError = nil;
    
    [ASDKProcessInstanceCacheMapper mapProcessInstance:processInstance
                                             toCacheMO:moProcessInstance];
    
    // Map initiator to managed object
    if (processInstance.initiatorModel) {
        ASDKMOProfile *moProfile = [ASDKProfileCacheModelUpsert upsertProfileToCache:processInstance.initiatorModel
                                                                               error:&internalError
                                                                         inMOContext:moContext];
        if (!internalError) {
            moProcessInstance.initiator = moProfile;
        }
    }
    
    if (internalError) {
        *error = internalError;
    }
    
    return moProcessInstance;
}

+ (NSPredicate *)predicateMatchingModelID:(NSString *)modelID {
    return [NSPredicate predicateWithFormat:@"modelID == %@", modelID];
}

@end

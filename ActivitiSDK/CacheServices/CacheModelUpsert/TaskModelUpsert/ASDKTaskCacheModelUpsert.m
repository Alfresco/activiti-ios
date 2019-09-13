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

#import "ASDKTaskCacheModelUpsert.h"

// Models
#import "ASDKModelTask.h"
#import "ASDKMOTask.h"
#import "ASDKModelProfile.h"
#import "ASDKMOProfile.h"

// Model mappers
#import "ASDKTaskCacheMapper.h"
#import "ASDKProfileCacheMapper.h"

// Model upsert
#import "ASDKProfileCacheModelUpsert.h"


@implementation ASDKTaskCacheModelUpsert

+ (ASDKMOTask *)upsertTaskToCache:(ASDKModelTask *)task
                            error:(NSError **)error
                      inMOContext:(NSManagedObjectContext *)moContext {
    NSError *internalError = nil;
    ASDKMOTask *moTask = nil;
    
    NSFetchRequest *fetchTaskRequest = [ASDKMOTask fetchRequest];
    fetchTaskRequest.predicate = [NSPredicate predicateWithFormat:@"modelID == %@", task.modelID];
    NSArray *taskResults = [moContext executeFetchRequest:fetchTaskRequest
                                                    error:&internalError];
    if (!internalError) {
        moTask = taskResults.firstObject;
        if (!moTask) {
            moTask = [NSEntityDescription insertNewObjectForEntityForName:[ASDKMOTask entityName]
                                                   inManagedObjectContext:moContext];
        }
        
        // Map task properties to managed object
        [self populateMOTask:moTask
      withPropertiesFromTask:task
                 inMOContext:moContext
                       error:&internalError];
    }
    
    *error = internalError;
    return moTask;
}

+ (NSArray *)upsertTaskListToCache:(NSArray *)taskList
                             error:(NSError **)error
                       inMOContext:(NSManagedObjectContext *)moContext {
    NSError *internalError = nil;
    NSArray *newIDs = [taskList valueForKey:@"modelID"];
    NSMutableArray *moTasks = [NSMutableArray array];
    
    NSFetchRequest *fetchTaskListRequest = [ASDKMOTask fetchRequest];
    fetchTaskListRequest.predicate = [NSPredicate predicateWithFormat:@"modelID IN %@", newIDs];
    NSArray *taskResults = [moContext executeFetchRequest:fetchTaskListRequest
                                                    error:&internalError];
    if (!internalError) {
        NSArray *oldIDs = [taskResults valueForKey:@"modelID"];
        
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
            NSArray *tasksToBeDeleted = [taskResults filteredArrayUsingPredicate:modelIDMatchingPredicate];
            ASDKMOTask *taskToBeDeleted = tasksToBeDeleted.firstObject;
            [moContext deleteObject:taskToBeDeleted];
        }
        
        // Perform insert operations
        for (NSString *idString in insertedIDsArr) {
            NSPredicate *modelIDMatchingPredicate = [self predicateMatchingModelID:idString];
            NSArray *tasksToBeInserted = [taskList filteredArrayUsingPredicate:modelIDMatchingPredicate];
            for (ASDKModelTask *task in tasksToBeInserted) {
                ASDKMOTask *moTask = [NSEntityDescription insertNewObjectForEntityForName:[ASDKMOTask entityName]
                                                                   inManagedObjectContext:moContext];
                [self populateMOTask:moTask
              withPropertiesFromTask:task
                         inMOContext:moContext
                               error:&internalError];
                if (internalError) {
                    break;
                } else {
                    [moTasks addObject:moTask];
                }
            }
        }
        
        if (!internalError) {
            // Perform update operations
            for (NSString *idString in updatedIDsArr) {
                NSPredicate *modelIDMatchingPredicate = [self predicateMatchingModelID:idString];
                NSArray *tasksToBeUpdated = [taskResults filteredArrayUsingPredicate:modelIDMatchingPredicate];
                for (ASDKMOTask *moTask in tasksToBeUpdated) {
                    modelIDMatchingPredicate = [self predicateMatchingModelID:moTask.modelID];
                    NSArray *correspondentTasks = [taskList filteredArrayUsingPredicate:modelIDMatchingPredicate];
                    ASDKModelTask *task = correspondentTasks.firstObject;
                    
                    [self populateMOTask:moTask
                  withPropertiesFromTask:task
                             inMOContext:moContext
                                   error:&internalError];
                    if (internalError) {
                        break;
                    } else {
                        [moTasks addObject:moTask];
                    }
                }
            }
        }
    }
    
    *error = internalError;
    return moTasks;
}

+ (ASDKMOTask *)populateMOTask:(ASDKMOTask *)moTask
        withPropertiesFromTask:(ASDKModelTask *)task
                   inMOContext:(NSManagedObjectContext *)moContext
                         error:(NSError **)error {
    NSError *internalError = nil;
    
    [ASDKTaskCacheMapper mapTask:task
                       toCacheMO:moTask];
    
    // Map assignee to managed object
    if (task.assigneeModel) {
        ASDKMOProfile *moProfile = [ASDKProfileCacheModelUpsert upsertProfileToCache:task.assigneeModel
                                                                               error:&internalError
                                                                         inMOContext:moContext];
        if (!internalError) {
            moTask.assignee = moProfile;
        }
    }
    // Map involved people to managed object
    for (ASDKModelProfile *profile in task.involvedPeople) {
        ASDKMOProfile *moProfile = [ASDKProfileCacheModelUpsert upsertProfileToCache:profile
                                                                               error:&internalError
                                                                         inMOContext:moContext];
        if (!internalError) {
            [moTask addInvolvedPeopleObject:moProfile];
        }
    }
    
    if (internalError) {
        *error = internalError;
    }

    return moTask;
}

+ (NSPredicate *)predicateMatchingModelID:(NSString *)modelID {
    return [NSPredicate predicateWithFormat:@"modelID == %@", modelID];
}

@end

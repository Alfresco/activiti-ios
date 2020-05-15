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

#import "ASDKProcessInstanceContentCacheModelUpsert.h"

// Models
#import "ASDKMOProcessInstanceContent.h"
#import "ASDKModelProcessInstanceContent.h"
#import "ASDKMOProcessInstanceContentField.h"

// Model mappers
#import "ASDKProcessInstanceContentFieldCacheMapper.h"

// Model upsert
#import "ASDKContentCacheModelUpsert.h"
#import "ASDKProcessInstanceContentFieldCacheModelUpsert.h"

@implementation ASDKProcessInstanceContentCacheModelUpsert

+ (ASDKMOProcessInstanceContent *)upsertProcessInstanceContentToCache:(ASDKModelProcessInstanceContent *)processInstanceContent
                                                 forProcessInstanceID:(NSString *)processInstanceID
                                                                error:(NSError **)error
                                                          inMOContext:(NSManagedObjectContext *)moContext {
    NSError *internalError = nil;
    ASDKMOProcessInstanceContent *moProcessInstanceContent = nil;
    
    NSFetchRequest *fetchProcessInstanceContentRequest = [ASDKMOProcessInstanceContent fetchRequest];
    fetchProcessInstanceContentRequest.predicate = [NSPredicate predicateWithFormat:@"processInstanceID == %@", processInstanceID];
    NSArray *processInstanceContentResults = [moContext executeFetchRequest:fetchProcessInstanceContentRequest
                                                                      error:&internalError];
    
    if (!internalError) {
        moProcessInstanceContent = processInstanceContentResults.firstObject;
        if (!moProcessInstanceContent) {
            moProcessInstanceContent = [NSEntityDescription insertNewObjectForEntityForName:[ASDKMOProcessInstanceContent entityName]
                                                                     inManagedObjectContext:moContext];
        }
        
        // Map process instance content properties to managed object
        [self populateMOProcessInstanceContent:moProcessInstanceContent
      withPropertiesFromProcessInstanceContent:processInstanceContent
                          forProcessInstanceID:processInstanceID
                                   inMOContext:moContext
                                         error:&internalError];
    }
    
    *error = internalError;
    return moProcessInstanceContent;
}

+ (NSArray *)upsertProcessInstanceContentListToCache:(NSArray *)contentList
                                forProcessInstanceID:(NSString *)processInstanceID
                                               error:(NSError **)error
                                         inMOContext:(NSManagedObjectContext *)moContext {
    NSError *internalError = nil;
    NSMutableArray *moContentList = [NSMutableArray array];
    NSArray *newIDs = [[contentList valueForKey:@"field"] valueForKey:@"modelID"];
    
    NSFetchRequest *fetchContentListRequest = [ASDKMOProcessInstanceContent fetchRequest];
    fetchContentListRequest.predicate = [NSPredicate predicateWithFormat:@"processInstanceContentField.modelID IN %@", newIDs];
    NSArray *contentResults = [moContext executeFetchRequest:fetchContentListRequest
                                                       error:&internalError];
    
    if (!internalError) {
        NSArray *oldIDs = [contentResults valueForKeyPath:@"processInstanceContentField.modelID"];
        
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
            NSArray *contentListToBeDeleted = [contentResults filteredArrayUsingPredicate:[self predicateMatchingMOProcessInstanceContentFieldID:idString]];
            ASDKMOProcessInstanceContent *contentToBeDeleted = contentListToBeDeleted.firstObject;
            [moContext deleteObject:contentToBeDeleted];
        }
        
        // Perform insert operations
        for (NSString *idString in insertedIDsArr) {
            NSArray *contentListToBeInserted = [contentList filteredArrayUsingPredicate:[self predicateMatchingProcessInstanceContentFieldID:idString]];
            for (ASDKModelProcessInstanceContent *content in contentListToBeInserted) {
                ASDKMOProcessInstanceContent *moContent = [NSEntityDescription insertNewObjectForEntityForName:[ASDKMOProcessInstanceContent entityName]
                                                           
                                                                                        inManagedObjectContext:moContext];
                [self populateMOProcessInstanceContent:moContent
              withPropertiesFromProcessInstanceContent:content
                                  forProcessInstanceID:processInstanceID
                                           inMOContext:moContext
                                                 error:&internalError];
                if (internalError) {
                    break;
                } else {
                    [moContentList addObject:moContent];
                }
            }
        }
        
        if (!internalError) {
            // Perform update operations
            for (NSString *idString in updatedIDsArr) {
                NSArray *contentListToBeUpdated = [contentResults filteredArrayUsingPredicate:[self predicateMatchingMOProcessInstanceContentFieldID:idString]];
                for (ASDKMOProcessInstanceContent *moContent in contentListToBeUpdated) {
                    NSArray *correspondentContentList = [contentList filteredArrayUsingPredicate:[self predicateMatchingProcessInstanceContentFieldID:moContent.processInstanceContentField.modelID]];
                    ASDKModelProcessInstanceContent *content = correspondentContentList.firstObject;
                    
                    [self populateMOProcessInstanceContent:moContent
                  withPropertiesFromProcessInstanceContent:content
                                      forProcessInstanceID:processInstanceID
                                               inMOContext:moContext
                                                     error:&internalError];
                    
                    if (internalError) {
                        break;
                    } else {
                        [moContentList addObject:moContent];
                    }
                }
            }
        }
    }
    
    *error = internalError;
    return moContentList;
}

+ (ASDKMOProcessInstanceContent *)populateMOProcessInstanceContent:(ASDKMOProcessInstanceContent *)moProcessInstanceContent
                          withPropertiesFromProcessInstanceContent:(ASDKModelProcessInstanceContent *)processInstanceContent
                                              forProcessInstanceID:(NSString *)processInstanceID
                                                       inMOContext:(NSManagedObjectContext *)moContext
                                                             error:(NSError **)error {
    NSError *internalError = nil;
    
    moProcessInstanceContent.processInstanceID = processInstanceID;
    
    if (processInstanceContent.field) {
        moProcessInstanceContent.processInstanceContentField = [ASDKProcessInstanceContentFieldCacheModelUpsert upsertProcessInstanceContentFieldToCache:processInstanceContent.field
                                                                                                                                                   error:&internalError
                                                                                                                                             inMOContext:moContext];
    }
    
    if (processInstanceContent.contentArr.count) {
        NSArray *contentArr = [ASDKContentCacheModelUpsert upsertContentListToCache:processInstanceContent.contentArr
                                                                              error:&internalError
                                                                        inMOContext:moContext];
        [moProcessInstanceContent addContentList:[NSSet setWithArray:contentArr]];
    }
    
    if (internalError) {
        *error = internalError;
    }
    
    return moProcessInstanceContent;
}

+ (NSPredicate *)predicateMatchingProcessInstanceContentFieldID:(NSString *)fieldID {
    return [NSPredicate predicateWithFormat:@"field.modelID == %@", fieldID];
}

+ (NSPredicate *)predicateMatchingMOProcessInstanceContentFieldID:(NSString *)fieldID {
    return [NSPredicate predicateWithFormat:@"processInstanceContentField.modelID == %@", fieldID];
}

@end

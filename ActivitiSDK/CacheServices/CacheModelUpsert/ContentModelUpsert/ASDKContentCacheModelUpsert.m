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

#import "ASDKContentCacheModelUpsert.h"

// Models
#import "ASDKModelContent.h"
#import "ASDKMOContent.h"

// Model mappers
#import "ASDKContentCacheMapper.h"

// Model upsert
#import "ASDKProfileCacheModelUpsert.h"


@implementation ASDKContentCacheModelUpsert

+ (ASDKMOContent *)upsertContentToCache:(ASDKModelContent *)content
                                  error:(NSError **)error
                            inMOContext:(NSManagedObjectContext *)moContext {
    NSError *internalError = nil;
    ASDKMOContent *moContent = nil;
    
    NSFetchRequest *fetchContentRequest = [ASDKMOContent fetchRequest];
    fetchContentRequest.predicate = [self predicateMatchingModelID:content.modelID];
    NSArray *contentResults = [moContext executeFetchRequest:fetchContentRequest
                                                       error:&internalError];
    if (!internalError) {
        moContent = contentResults.firstObject;
        if (!moContent) {
            moContent = [NSEntityDescription insertNewObjectForEntityForName:[ASDKMOContent entityName]
                                                      inManagedObjectContext:moContext];
        }
        
        // Map content properties to managed object
        [self populateMOContent:moContent
      withPropertiesFromContent:content
                    inMOContext:moContext
                          error:&internalError];
    }
    
    *error = internalError;
    return moContent;
}

+ (NSArray *)upsertContentListToCache:(NSArray *)contentList
                                error:(NSError **)error
                          inMOContext:(NSManagedObjectContext *)moContext {
    NSError *internalError = nil;
    NSMutableArray *moContentList = [NSMutableArray array];
    NSArray *newIDs = [contentList valueForKey:@"modelID"];
    
    NSFetchRequest *fetchContentListRequest = [ASDKMOContent fetchRequest];
    fetchContentListRequest.predicate = [NSPredicate predicateWithFormat:@"modelID IN %@", newIDs];
    NSArray *contentResults = [moContext executeFetchRequest:fetchContentListRequest
                                                       error:&internalError];
    
    if (!internalError) {
        NSArray *oldIDs = [contentResults valueForKey:@"modelID"];
        
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
            NSArray *contentListToBeDeleted = [contentResults filteredArrayUsingPredicate:[self predicateMatchingModelID:idString]];
            ASDKMOContent *contentToBeDeleted = contentListToBeDeleted.firstObject;
            [moContext deleteObject:contentToBeDeleted];
        }
        
        // Perform insert operations
        for (NSString *idString in insertedIDsArr) {
            NSArray *contentListToBeInserted = [contentList filteredArrayUsingPredicate:[self predicateMatchingModelID:idString]];
            for (ASDKModelContent *content in contentListToBeInserted) {
                ASDKMOContent *moContent = [NSEntityDescription insertNewObjectForEntityForName:[ASDKMOContent entityName]
                                                                         inManagedObjectContext:moContext];
                [self populateMOContent:moContent
              withPropertiesFromContent:content
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
                NSArray *contentListToBeUpdated = [contentResults filteredArrayUsingPredicate:[self predicateMatchingModelID:idString]];
                for (ASDKMOContent *moContent in contentListToBeUpdated) {
                    NSArray *correspondentContentList = [contentList filteredArrayUsingPredicate:[self predicateMatchingModelID:moContent.modelID]];
                    ASDKModelContent *content = correspondentContentList.firstObject;
                    
                    [self populateMOContent:moContent
                  withPropertiesFromContent:content 
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

+ (ASDKMOContent *)populateMOContent:(ASDKMOContent *)moContent
           withPropertiesFromContent:(ASDKModelContent *)content
                         inMOContext:(NSManagedObjectContext *)moContext
                               error:(NSError **)error {
    NSError *internalError = nil;
    
    [ASDKContentCacheMapper mapContent:content
                             toCacheMO:moContent];
    
    // Map owner to managed object
    if (content.owner) {
        ASDKMOProfile *moProfile = [ASDKProfileCacheModelUpsert upsertProfileToCache:content.owner
                                                                               error:&internalError
                                                                         inMOContext:moContext];
        if (!internalError) {
            moContent.owner = moProfile;
        }
    }
    
    if (internalError) {
        *error = internalError;
    }
    
    return moContent;
}

+ (NSPredicate *)predicateMatchingModelID:(NSString *)modelID {
    return [NSPredicate predicateWithFormat:@"modelID == %@", modelID];
}

@end

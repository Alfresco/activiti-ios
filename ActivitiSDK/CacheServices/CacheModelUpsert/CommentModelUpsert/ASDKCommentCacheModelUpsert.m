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

#import "ASDKCommentCacheModelUpsert.h"

// Models
#import "ASDKModelComment.h"
#import "ASDKMOComment.h"

// Model mappers
#import "ASDKCommentCacheMapper.h"

// Model upsert
#import "ASDKProfileCacheModelUpsert.h"


@implementation ASDKCommentCacheModelUpsert

+ (ASDKMOComment *)upsertCommentToCache:(ASDKModelComment *)comment
                                  error:(NSError **)error
                            inMOContext:(NSManagedObjectContext *)moContext {
    NSError *internalError = nil;
    ASDKMOComment *moComment = nil;
    
    NSFetchRequest *fetchCommentRequest = [ASDKMOComment fetchRequest];
    fetchCommentRequest.predicate = [self predicateMatchingModelID:comment.modelID];
    NSArray *commentResults = [moContext executeFetchRequest:fetchCommentRequest
                                                       error:&internalError];
    if (!internalError) {
        moComment = commentResults.firstObject;
        if (!moComment) {
            moComment = [NSEntityDescription insertNewObjectForEntityForName:[ASDKMOComment entityName]
                                                      inManagedObjectContext:moContext];
        }
        
        // Map comment properties to managed object
        [self populateMOComment:moComment
      withPropertiesFromComment:comment
                    inMOContext:moContext
                          error:&internalError];
    }
    
    *error = internalError;
    return moComment;
}

+ (NSArray *)upsertCommentListToCache:(NSArray *)commentList
                                error:(NSError **)error
                          inMOContext:(NSManagedObjectContext *)moContext {
    NSError *internalError = nil;
    NSMutableArray *moCommentList = [NSMutableArray array];
    NSArray *newIDs = [commentList valueForKey:@"modelID"];
    
    NSFetchRequest *fetchCommentListRequest = [ASDKMOComment fetchRequest];
    fetchCommentListRequest.predicate = [NSPredicate predicateWithFormat:@"modelID IN %@", newIDs];
    NSArray *commentResults = [moContext executeFetchRequest:fetchCommentListRequest
                                                       error:&internalError];
    
    if (!internalError) {
        NSArray *oldIDs = [commentResults valueForKey:@"modelID"];
        
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
            NSArray *commentListToBeDeleted = [commentResults filteredArrayUsingPredicate:[self predicateMatchingModelID:idString]];
            ASDKMOComment *commentToBeDeleted = commentListToBeDeleted.firstObject;
            [moContext deleteObject:commentToBeDeleted];
        }
        
        // Perform insert operations
        for (NSString *idString in insertedIDsArr) {
            NSArray *commentListToBeInserted = [commentList filteredArrayUsingPredicate:[self predicateMatchingModelID:idString]];
            for (ASDKModelComment *comment in commentListToBeInserted) {
                ASDKMOComment *moComment = [NSEntityDescription insertNewObjectForEntityForName:[ASDKMOComment entityName]
                                                                         inManagedObjectContext:moContext];
                [self populateMOComment:moComment
              withPropertiesFromComment:comment
                            inMOContext:moContext
                                  error:&internalError];
                if (internalError) {
                    break;
                } else {
                    [moCommentList addObject:moComment];
                }
            }
        }
        
        if (!internalError) {
            // Perform update operations
            for (NSString *idString in updatedIDsArr) {
                NSArray *commentListToBeUpdated = [commentResults filteredArrayUsingPredicate:[self predicateMatchingModelID:idString]];
                for (ASDKMOComment *moComment in commentListToBeUpdated) {
                    NSArray *correspondentCommentList = [commentList filteredArrayUsingPredicate:[self predicateMatchingModelID:moComment.modelID]];
                    ASDKModelComment *comment = correspondentCommentList.firstObject;
                    
                    [self populateMOComment:moComment
                  withPropertiesFromComment:comment
                                inMOContext:moContext
                                      error:&internalError];
                    if (internalError) {
                        break;
                    } else {
                        [moCommentList addObject:moComment];
                    }
                }
            }
        }
    }
    
    *error = internalError;
    return moCommentList;
}

+ (ASDKMOComment *)populateMOComment:(ASDKMOComment *)moComment
           withPropertiesFromComment:(ASDKModelComment *)comment
                         inMOContext:(NSManagedObjectContext *)moContext
                               error:(NSError **)error {
    NSError *internalError = nil;
    
    [ASDKCommentCacheMapper mapComment:comment
                             toCacheMO:moComment];
    
    // Map author to managed object
    if (comment.authorModel) {
        ASDKMOProfile *moProfile = [ASDKProfileCacheModelUpsert upsertProfileToCache:comment.authorModel
                                                                               error:&internalError
                                                                         inMOContext:moContext];
        if (!internalError) {
            moComment.author = moProfile;
        }
    }
    
    if (internalError) {
        *error = internalError;
    }
    
    return moComment;
}

+ (NSPredicate *)predicateMatchingModelID:(NSString *)modelID {
    return [NSPredicate predicateWithFormat:@"modelID == %@", modelID];
}

@end

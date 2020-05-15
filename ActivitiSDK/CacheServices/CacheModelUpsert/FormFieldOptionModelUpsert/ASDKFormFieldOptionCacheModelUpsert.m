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

#import "ASDKFormFieldOptionCacheModelUpsert.h"

// Models
#import "ASDKMOFormFieldOption.h"
#import "ASDKModelFormFieldOption.h"

// Model mappers
#import "ASDKFormFieldOptionCacheMapper.h"

@implementation ASDKFormFieldOptionCacheModelUpsert

+ (NSArray *)upsertFormFieldOptionListToCache:(NSArray *)formFieldOptionList
                                        error:(NSError **)error
                                  inMOContext:(NSManagedObjectContext *)moContext {
    NSError *internalError = nil;
    NSArray *newIDs = [formFieldOptionList valueForKey:@"modelID"];
    NSMutableArray *moFormFieldOptions = [NSMutableArray array];
    
    NSFetchRequest *fetchRestFieldValueListRequest = [ASDKMOFormFieldOption fetchRequest];
    fetchRestFieldValueListRequest.predicate = [NSPredicate predicateWithFormat:@"modelID IN %@", newIDs];
    NSArray *restFieldValueResults = [moContext executeFetchRequest:fetchRestFieldValueListRequest
                                                              error:&internalError];
    
    if (!internalError) {
        NSArray *oldIDs = [restFieldValueResults valueForKey:@"modelID"];
        
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
            NSArray *restFieldValuesToBeDeleted = [restFieldValueResults filteredArrayUsingPredicate:modelIDMatchingPredicate];
            ASDKMOFormFieldOption *formFieldOptionToBeDeleted = restFieldValuesToBeDeleted.firstObject;
            [moContext deleteObject:formFieldOptionToBeDeleted];
        }
        
        // Perform insert operations
        for (NSString *idString in insertedIDsArr) {
            NSPredicate *modelIDMatchingPredicate = [self predicateMatchingModelID:idString];
            NSArray *restFieldValuesToBeInserted = [formFieldOptionList filteredArrayUsingPredicate:modelIDMatchingPredicate];
            for (ASDKModelFormFieldOption *restFieldValue in restFieldValuesToBeInserted) {
                ASDKMOFormFieldOption *moRestFieldValue = [NSEntityDescription insertNewObjectForEntityForName:[ASDKMOFormFieldOption entityName]
                                                                                        inManagedObjectContext:moContext];
                [self populateMORestFieldValue:moRestFieldValue
              withPropertiesFromRestFieldValue:restFieldValue];
                
                [moFormFieldOptions addObject:moRestFieldValue];
            }
        }
        
        // Perform update operations
        for (NSString *idString in updatedIDsArr) {
            NSPredicate *modelIDMatchingPredicate = [self predicateMatchingModelID:idString];
            NSArray *restFieldValuesToBeUpdated = [restFieldValueResults filteredArrayUsingPredicate:modelIDMatchingPredicate];
            for (ASDKMOFormFieldOption *moFormFieldOption in restFieldValuesToBeUpdated) {
                modelIDMatchingPredicate = [self predicateMatchingModelID:moFormFieldOption.modelID];
                NSArray *correspondentRestFieldValue = [formFieldOptionList filteredArrayUsingPredicate:modelIDMatchingPredicate];
                ASDKModelFormFieldOption *formFieldOption = correspondentRestFieldValue.firstObject;
                
                [self populateMORestFieldValue:moFormFieldOption
              withPropertiesFromRestFieldValue:formFieldOption];
                
                [moFormFieldOptions addObject:moFormFieldOption];
            }
        }
    }
    
    *error = internalError;
    return moFormFieldOptions;
}

+ (ASDKMOFormFieldOption *)populateMORestFieldValue:(ASDKMOFormFieldOption *)moFormFieldOption
                      withPropertiesFromRestFieldValue:(ASDKModelFormFieldOption *)formFieldOption {
    [ASDKFormFieldOptionCacheMapper mapFormFieldOption:formFieldOption
                                             toCacheMO:moFormFieldOption];
    
    return moFormFieldOption;
}

+ (NSPredicate *)predicateMatchingModelID:(NSString *)modelID {
    return [NSPredicate predicateWithFormat:@"modelID == %@", modelID];
}

@end

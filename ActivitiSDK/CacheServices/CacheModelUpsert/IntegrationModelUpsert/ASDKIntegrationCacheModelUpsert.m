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

#import "ASDKIntegrationCacheModelUpsert.h"

// Models
#import "ASDKMOIntegrationAccount.h"
#import "ASDKModelIntegrationAccount.h"

// Model mappers
#import "ASDKIntegrationCacheMapper.h"

@implementation ASDKIntegrationCacheModelUpsert

+ (NSArray *)upsertIntegrationListToCache:(NSArray *)integrationList
                                    error:(NSError **)error
                              inMOContext:(NSManagedObjectContext *)moContext {
    NSError *internalError = nil;
    NSArray *newIDs = [integrationList valueForKey:@"integrationServiceID"];
    NSMutableArray *moIntegrationList = [NSMutableArray array];
    
    NSFetchRequest *fetchIntegrationListRequest = [ASDKMOIntegrationAccount fetchRequest];
    fetchIntegrationListRequest.predicate = [NSPredicate predicateWithFormat:@"integrationServiceID IN %@", newIDs];
    NSArray *integrationListResults = [moContext executeFetchRequest:fetchIntegrationListRequest
                                                               error:&internalError];
    if (!internalError) {
        NSArray *oldIDs = [integrationListResults valueForKey:@"integrationServiceID"];
        
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
            NSPredicate *modelIDMatchingPredicate = [self predicateMatchingIntegrationServiceID:idString];
            NSArray *integrationAccountsToBeDeleted = [integrationListResults filteredArrayUsingPredicate:modelIDMatchingPredicate];
            ASDKMOIntegrationAccount *integrationAccountToBeDeleted = integrationAccountsToBeDeleted.firstObject;
            [moContext deleteObject:integrationAccountToBeDeleted];
        }
        
        // Perform insert operations
        for (NSString *idString in insertedIDsArr) {
            NSPredicate *modelIDMatchingPredicate = [self predicateMatchingIntegrationServiceID:idString];
            NSArray *integrationAccountsToBeInserted = [integrationList filteredArrayUsingPredicate:modelIDMatchingPredicate];
            for (ASDKModelIntegrationAccount *integrationAccount in integrationAccountsToBeInserted) {
                ASDKMOIntegrationAccount *moIntegrationAccount = [NSEntityDescription insertNewObjectForEntityForName:[ASDKMOIntegrationAccount entityName]
                                                                                               inManagedObjectContext:moContext];
                [self populateMOIntegrationAccount:moIntegrationAccount
              withPropertiesFromIntegrationAccount:integrationAccount
                                       inMOContext:moContext];
                
                [moIntegrationList addObject:moIntegrationAccount];
            }
        }
        
        // Perform update operations
        for (NSString *idString in updatedIDsArr) {
            NSPredicate *modelIDMathcingPredicate = [self predicateMatchingIntegrationServiceID:idString];
            NSArray *integrationAccountsToBeUpdated = [integrationListResults filteredArrayUsingPredicate:modelIDMathcingPredicate];
            for (ASDKMOIntegrationAccount *moIntegrationAccount in integrationAccountsToBeUpdated) {
                modelIDMathcingPredicate = [self predicateMatchingIntegrationServiceID:moIntegrationAccount.integrationServiceID];
                NSArray *correspondentIntegrationAccounts = [integrationList filteredArrayUsingPredicate:modelIDMathcingPredicate];
                ASDKModelIntegrationAccount *integrationAccount = correspondentIntegrationAccounts.firstObject;
                
                [self populateMOIntegrationAccount:moIntegrationAccount
              withPropertiesFromIntegrationAccount:integrationAccount
                                       inMOContext:moContext];
                
                [moIntegrationList addObject:moIntegrationAccount];
            }
        }
    }
    
    *error = internalError;
    return moIntegrationList;
}

+ (ASDKMOIntegrationAccount *)populateMOIntegrationAccount:(ASDKMOIntegrationAccount *)moIntegrationAccount
                      withPropertiesFromIntegrationAccount:(ASDKModelIntegrationAccount *)integrationAccount
                                               inMOContext:(NSManagedObjectContext *)moContext {
    [ASDKIntegrationCacheMapper mapIntegrationAccount:integrationAccount
                                            toCacheMO:moIntegrationAccount];
    return moIntegrationAccount;
}

+ (NSPredicate *)predicateMatchingIntegrationServiceID:(NSString *)integrationServiceID {
    return [NSPredicate predicateWithFormat:@"integrationServiceID == %@", integrationServiceID];
}

@end

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

#import "ASDKProcessInstanceContentFieldCacheModelUpsert.h"

// Models
#import "ASDKMOProcessInstanceContentField.h"
#import "ASDKModelProcessInstanceContentField.h"

// Cache mappers
#import "ASDKProcessInstanceContentFieldCacheMapper.h"

@implementation ASDKProcessInstanceContentFieldCacheModelUpsert

+ (ASDKMOProcessInstanceContentField *)upsertProcessInstanceContentFieldToCache:(ASDKModelProcessInstanceContentField *)processInstanceContentField
                                                                          error:(NSError **)error
                                                                    inMOContext:(NSManagedObjectContext *)moContext {
    NSError *internalError = nil;
    ASDKMOProcessInstanceContentField *moProcessInstanceContentField = nil;
    
    NSFetchRequest *fetchProcessInstanceContentRequest = [ASDKMOProcessInstanceContentField fetchRequest];
    fetchProcessInstanceContentRequest.predicate = [NSPredicate predicateWithFormat:@"modelID == %@", processInstanceContentField.modelID];
    NSArray *processInstanceContentFieldResults = [moContext executeFetchRequest:fetchProcessInstanceContentRequest
                                                                           error:&internalError];
    if (!internalError) {
        moProcessInstanceContentField = processInstanceContentFieldResults.firstObject;
        if (!moProcessInstanceContentField) {
            moProcessInstanceContentField = [NSEntityDescription insertNewObjectForEntityForName:[ASDKMOProcessInstanceContentField entityName]
                                                                          inManagedObjectContext:moContext];
        }
        
        // Map properties to managed object
        [ASDKProcessInstanceContentFieldCacheMapper mapProcessInstanceContentField:processInstanceContentField
                                                                         toCacheMO:moProcessInstanceContentField];
    }
    
    *error = internalError;
    return moProcessInstanceContentField;
}

@end

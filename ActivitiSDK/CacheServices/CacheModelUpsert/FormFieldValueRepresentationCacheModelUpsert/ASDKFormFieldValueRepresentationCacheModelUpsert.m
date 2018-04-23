/*******************************************************************************
 * Copyright (C) 2005-2017 Alfresco Software Limited.
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

#import "ASDKFormFieldValueRepresentationCacheModelUpsert.h"

// Models
#import "ASDKMOFormFieldValueRepresentation.h"
#import "ASDKFormFieldValueRequestRepresentation.h"

// Mappers
#import "ASDKFormFieldValueRepresentationCacheMapper.h"


@implementation ASDKFormFieldValueRepresentationCacheModelUpsert


#pragma mark -
#pragma mark Public interface

+ (ASDKMOFormFieldValueRepresentation *)upsertFormFieldValueToCache:(ASDKFormFieldValueRequestRepresentation *)formFieldValueRequestRepresentation
                                                          forTaskID:(NSString *)taskID
                                                              error:(NSError **)error
                                                        inMOContext:(NSManagedObjectContext *)moContext {
    NSError *internalError = nil;
    ASDKMOFormFieldValueRepresentation *moFormFieldValueRepresentation = nil;
    NSFetchRequest *fetchFormFieldValueRepresentationRequest = [ASDKMOFormFieldValueRepresentation fetchRequest];
    fetchFormFieldValueRepresentationRequest.predicate = [NSPredicate predicateWithFormat:@"taskID == %@", taskID];
    NSArray *formFieldValueRepresentationResults = [moContext executeFetchRequest:fetchFormFieldValueRepresentationRequest
                                                                            error:&internalError];
    if (!internalError) {
        moFormFieldValueRepresentation = formFieldValueRepresentationResults.firstObject;
        if (!moFormFieldValueRepresentation) {
            moFormFieldValueRepresentation = [NSEntityDescription insertNewObjectForEntityForName:[ASDKMOFormFieldValueRepresentation entityName]
                                                                           inManagedObjectContext:moContext];
        }
        
        [ASDKFormFieldValueRepresentationCacheMapper mapFormFieldValueRepresentation:formFieldValueRequestRepresentation
                                                                       forTaskWithID:taskID
                                                                           toCacheMO:moFormFieldValueRepresentation];
    }
    
    *error = internalError;
    return moFormFieldValueRepresentation;
}

@end

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

#import "ASDKFormDescriptionCacheModelUpsert.h"

// Models
#import "ASDKMOFormDescription.h"
#import "ASDKModelFormDescription.h"

// Mappers
#import "ASDKFormDescriptionCacheMapper.h"


typedef NS_ENUM(NSInteger, ASDKFormDescriptionType) {
    ASDKFormDescriptionTypeUndefined = -1,
    ASDKFormDescriptionTypeTask = 1,
    ASDKFormDescriptionTypeProcessInstance,
    ASDKFormDescriptionTypeProcessDefinition
};

@implementation ASDKFormDescriptionCacheModelUpsert


#pragma mark -
#pragma mark Public interface

+ (ASDKMOFormDescription *)upsertTaskFormDescriptionToCache:(ASDKModelFormDescription *)formDescription
                                                  forTaskID:(NSString *)taskID
                                                      error:(NSError **)error
                                                inMOContext:(NSManagedObjectContext *)moContext {
    return [self upsertGenericFormDescriptionToCache:formDescription
                                            formType:ASDKFormDescriptionTypeTask
                                            idString:taskID
                                               error:error
                                         inMOContext:moContext];
}

+ (ASDKMOFormDescription *)upsertProcessInstanceFormDescriptionToCache:(ASDKModelFormDescription *)formDescription
                                                  forProcessInstanceID:(NSString *)processInstanceID
                                                                 error:(NSError **)error
                                                           inMOContext:(NSManagedObjectContext *)moContext {
    return [self upsertGenericFormDescriptionToCache:formDescription
                                            formType:ASDKFormDescriptionTypeProcessInstance
                                            idString:processInstanceID
                                               error:error
                                         inMOContext:moContext];
}

+ (ASDKMOFormDescription *)upsertProcessDefinitionFormDescriptionToCache:(ASDKModelFormDescription *)formDescription
                                                  forProcessDefinitionID:(NSString *)processDefinitionID
                                                                   error:(NSError **)error
                                                             inMOContext:(NSManagedObjectContext *)moContext {
    return [self upsertGenericFormDescriptionToCache:formDescription
                                            formType:ASDKFormDescriptionTypeProcessDefinition
                                            idString:processDefinitionID
                                               error:error
                                         inMOContext:moContext];
}

+ (ASDKMOFormDescription *)upsertGenericFormDescriptionToCache:(ASDKModelFormDescription *)formDescription
                                                      formType:(ASDKFormDescriptionType)formType
                                                      idString:(NSString *)idString
                                                         error:(NSError **)error
                                                   inMOContext:(NSManagedObjectContext *)moContext {
    NSError *internalError = nil;
    ASDKMOFormDescription *moFormDescription = nil;
    
    NSFetchRequest *fetchFormDescriptionRequest = [ASDKMOFormDescription fetchRequest];
    
    NSPredicate *predicate = nil;
    switch (formType) {
        case ASDKFormDescriptionTypeTask: {
            predicate = [self formDescriptionPredicateForTaskID:idString];
        }
            break;
        case ASDKFormDescriptionTypeProcessInstance: {
            predicate = [self formDescriptionPredicateForProcessInstanceID:idString];
        }
            break;
            
        case ASDKFormDescriptionTypeProcessDefinition: {
            predicate = [self formDescriptionPredicateForProcessDefinitionID:idString];
        }
            break;
            
        default: break;
    }
    fetchFormDescriptionRequest.predicate = predicate;
    NSArray *formDescriptionResults = [moContext executeFetchRequest:fetchFormDescriptionRequest
                                                               error:&internalError];
    
    if (!internalError) {
        moFormDescription = formDescriptionResults.firstObject;
        if (!moFormDescription) {
            moFormDescription = [NSEntityDescription insertNewObjectForEntityForName:[ASDKMOFormDescription entityName]
                                                              inManagedObjectContext:moContext];
        }
        
        // Map form description to managed object
        switch (formType) {
            case ASDKFormDescriptionTypeTask: {
                [ASDKFormDescriptionCacheMapper mapFormDescription:formDescription
                                                     forTaskWithID:idString
                                                         toCacheMO:moFormDescription];
            }
                break;
                
            case ASDKFormDescriptionTypeProcessInstance: {
                [ASDKFormDescriptionCacheMapper mapFormDescription:formDescription
                                              forProcessInstanceID:idString
                                                         toCacheMO:moFormDescription];
            }
                break;
                
            case ASDKFormDescriptionTypeProcessDefinition: {
                [ASDKFormDescriptionCacheMapper mapFormDescription:formDescription
                                            forProcessDefinitionID:idString
                                                         toCacheMO:moFormDescription];
            }
                break;
                
            default: break;
        }
    }
    
    *error = internalError;
    return moFormDescription;
}

+ (NSPredicate *)formDescriptionPredicateForTaskID:(NSString *)taskID {
    NSPredicate *predicate = nil;
    
    if (taskID.length) {
        predicate = [NSPredicate predicateWithFormat:@"taskID == %@", taskID];
    }
    
    return predicate;
}

+ (NSPredicate *)formDescriptionPredicateForProcessInstanceID:(NSString *)processInstanceID {
    NSPredicate *predicate = nil;
    
    if (processInstanceID.length) {
        predicate = [NSPredicate predicateWithFormat:@"processInstanceID == %@", processInstanceID];
    }
    
    return predicate;
}

+ (NSPredicate *)formDescriptionPredicateForProcessDefinitionID:(NSString *)processDefinitionID {
    NSPredicate *predicate = nil;
    
    if (processDefinitionID.length) {
        predicate = [NSPredicate predicateWithFormat:@"processDefinitionID == %@", processDefinitionID];
    }
    
    return predicate;
}

@end

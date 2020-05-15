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

#import "ASDKBaseParserOperationWorker.h"

@implementation ASDKBaseParserOperationWorker

- (void)parseContentDictionary:(NSDictionary *)contentDictionary
                        ofType:(NSString *)contentType
           withCompletionBlock:(ASDKParserCompletionBlock)completionBlock
                         queue:(dispatch_queue_t)completionQueue {
    // Implement in subclasses
}

- (BOOL)validateJSONPropertyMappingOfClass:(Class <MTLJSONSerializing>)modelClass
                     withContentDictionary:(NSDictionary *)contentDictionary
                                     error:(NSError **)error {
    if (![contentDictionary isKindOfClass:[NSDictionary class]]) {
        if (error != NULL) *error = [self unexpectedContentDictionaryError:modelClass];
        return NO;
    }
    
    NSDictionary *jsonMappingDictionary = [modelClass JSONKeyPathsByPropertyKey];
    NSSet *modelKeyPathsSet = [NSSet setWithArray:[jsonMappingDictionary allValues]];
    NSSet *jsonKeyPathsSet = [NSSet setWithArray:[contentDictionary allKeys]];
    
    BOOL propertiesAreMappedFromJSON = [jsonKeyPathsSet intersectsSet:modelKeyPathsSet];
    
    if (!propertiesAreMappedFromJSON) {
        if (error != NULL) *error = [self invalidJSONMappingErrorForModelClass:modelClass];
    }
    
    return propertiesAreMappedFromJSON;
}

- (NSError *)invalidJSONMappingErrorForModelClass:(Class)modelClass {
    NSDictionary *userInfo = @{NSLocalizedDescriptionKey: @"Invalid JSON keypath mapping",
                               NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:@"Model could not be created because an invalid JSON was provided for model class: %@", NSStringFromClass(modelClass)]};
    return [NSError errorWithDomain:MTLJSONAdapterErrorDomain
                               code:MTLJSONAdapterErrorInvalidJSONMapping
                           userInfo:userInfo];
}

- (NSError *)unexpectedContentDictionaryError:(Class)modelClass {
    NSDictionary *userInfo = @{NSLocalizedDescriptionKey : @"Unexpected data structure instead of JSON dictionary.",
                               NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:@"Parsing operation cannot proceed because an invalid data structure was provided for model class: %@", NSStringFromClass(modelClass)]};
    return [NSError errorWithDomain:MTLJSONAdapterErrorDomain
                               code:MTLJSONAdapterErrorInvalidJSONDictionary
                           userInfo:userInfo];
}

@end

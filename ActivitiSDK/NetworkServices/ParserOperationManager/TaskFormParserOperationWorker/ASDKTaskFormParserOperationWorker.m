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

#import "ASDKTaskFormParserOperationWorker.h"
#import "ASDKModelFormDescription.h"
#import "ASDKModelFormFieldOption.h"
#import "ASDKModelFormVariable.h"

@import Mantle;

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

@implementation ASDKTaskFormParserOperationWorker

#pragma mark -
#pragma mark ASDKParserOperationWorker Protocol

- (void)parseContentDictionary:(NSDictionary *)contentDictionary
                        ofType:(NSString *)contentType
           withCompletionBlock:(ASDKParserCompletionBlock)completionBlock
                         queue:(dispatch_queue_t)completionQueue {
    NSParameterAssert(contentDictionary);
    NSParameterAssert(contentType);
    NSParameterAssert(completionBlock);
    
    if ([CREATE_STRING(ASDKTaskFormParserContentTypeFormModels) isEqualToString:contentType]) {
        NSError *parserError = nil;
        ASDKModelFormDescription *formDescription = nil;
        Class modelClass = ASDKModelFormDescription.class;
        
        if ([self validateJSONPropertyMappingOfClass:modelClass
                               withContentDictionary:contentDictionary
                                               error:&parserError]) {
            formDescription = [MTLJSONAdapter modelOfClass:ASDKModelFormDescription.class
                                        fromJSONDictionary:contentDictionary
                                                     error:&parserError];
        }
        
        dispatch_async(completionQueue, ^{
            completionBlock(formDescription, parserError, nil);
        });
    } else if ([CREATE_STRING(ASDKTaskFormParserContentTypeRestFieldValues) isEqualToString:contentType]) {
        NSError *parserError = nil;
        NSArray *responseArray = (NSArray *)contentDictionary;
        NSArray *restFormFieldOptions = [MTLJSONAdapter modelsOfClass:ASDKModelFormFieldOption.class
                                                        fromJSONArray:responseArray
                                                                error:&parserError];
        
        dispatch_async(completionQueue, ^{
            completionBlock(restFormFieldOptions, parserError, nil);
        });
    } else if ([CREATE_STRING(ASDKTaskFormParserContentTypeFormVariables) isEqualToString:contentType]) {
        NSError *parserError = nil;
        NSArray *responseArray = (NSArray *)contentDictionary;
        NSArray *formVariablesValues = [MTLJSONAdapter modelsOfClass:ASDKModelFormVariable.class
                                                       fromJSONArray:responseArray
                                                               error:&parserError];
        dispatch_async(completionQueue, ^{
            completionBlock(formVariablesValues, parserError, nil);
        });
    }
}

- (NSArray *)availableServices {
    return @[CREATE_STRING(ASDKTaskFormParserContentTypeFormModels),
             CREATE_STRING(ASDKTaskFormParserContentTypeRestFieldValues),
             CREATE_STRING(ASDKTaskFormParserContentTypeFormVariables)];
}

@end

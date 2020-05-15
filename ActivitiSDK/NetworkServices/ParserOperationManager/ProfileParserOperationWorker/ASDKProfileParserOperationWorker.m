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

#import "ASDKProfileParserOperationWorker.h"
#import "ASDKModelProfile.h"
#import "ASDKModelContent.h"

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

@implementation ASDKProfileParserOperationWorker


#pragma mark -
#pragma mark ASDKParserOperationWorker Protocol

- (void)parseContentDictionary:(NSDictionary *)contentDictionary
                        ofType:(NSString *)contentType
           withCompletionBlock:(ASDKParserCompletionBlock)completionBlock
                         queue:(dispatch_queue_t)completionQueue {
    NSParameterAssert(contentDictionary);
    NSParameterAssert(contentType);
    NSParameterAssert(completionBlock);
    
    if ([CREATE_STRING(ASDKProfileParserContentTypeProfile) isEqualToString:contentType]) {
        NSError *parserError = nil;
        ASDKModelProfile *modelProfile = nil;
        Class modelClass = ASDKModelProfile.class;
        
        if ([self validateJSONPropertyMappingOfClass:modelClass
                               withContentDictionary:contentDictionary
                                               error:&parserError]) {
            modelProfile = [MTLJSONAdapter modelOfClass:ASDKModelProfile.class
                                     fromJSONDictionary:contentDictionary
                                                  error:&parserError];
        }
        
        dispatch_async(completionQueue, ^{
            completionBlock(modelProfile, parserError, nil);
        });
    }
    
    if ([CREATE_STRING(ASDKProfileParserContentTypeContent) isEqualToString:contentType]) {
        NSError *parserError = nil;
        ASDKModelContent *content = nil;
        Class modelClass = ASDKModelContent.class;
        
        if ([self validateJSONPropertyMappingOfClass:modelClass
                               withContentDictionary:contentDictionary
                                               error:&parserError]) {
            content = [MTLJSONAdapter modelOfClass:modelClass
                                fromJSONDictionary:contentDictionary
                                             error:&parserError];
        }
        
        dispatch_async(completionQueue, ^{
            completionBlock(content, parserError, nil);
        });
    }
}

- (NSArray *)availableServices {
    return @[CREATE_STRING(ASDKProfileParserContentTypeProfile),
             CREATE_STRING(ASDKProfileParserContentTypeContent)];
}

@end

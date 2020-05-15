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

#import "ASDKProcessParserOperationWorker.h"

// Constants
#import "ASDKNetworkServiceConstants.h"

// Model
#import "ASDKModelPaging.h"
#import "ASDKModelProcessDefinition.h"
#import "ASDKModelProcessInstance.h"
#import "ASDKModelProcessInstanceContent.h"
#import "ASDKModelComment.h"

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

@implementation ASDKProcessParserOperationWorker

#pragma mark -
#pragma mark ASDKParserOperationWorker Protocol

- (void)parseContentDictionary:(NSDictionary *)contentDictionary
                        ofType:(NSString *)contentType
           withCompletionBlock:(ASDKParserCompletionBlock)completionBlock
                         queue:(dispatch_queue_t)completionQueue {
    NSParameterAssert(contentDictionary);
    NSParameterAssert(contentType);
    NSParameterAssert(completionBlock);
    
    if ([CREATE_STRING(ASDKProcessParserContentTypeProcessDefinitionList) isEqualToString:contentType]) {
        NSError *parserError = nil;
        ASDKModelPaging *paging = nil;
        NSArray *processDefinitionList = nil;
        Class pagingClass = ASDKModelPaging.class;
        
        if ([self validateJSONPropertyMappingOfClass:pagingClass
                               withContentDictionary:contentDictionary
                                               error:&parserError]) {
            paging = [MTLJSONAdapter modelOfClass:ASDKModelPaging.class
                               fromJSONDictionary:contentDictionary
                                            error:&parserError];
            processDefinitionList = [MTLJSONAdapter modelsOfClass:ASDKModelProcessDefinition.class
                                                    fromJSONArray:contentDictionary[kASDKAPIJSONKeyData]
                                                            error:&parserError];
        }
        
        dispatch_async(completionQueue, ^{
            completionBlock(processDefinitionList, parserError, paging);
        });
    }
    if ([CREATE_STRING(ASDKProcessParserContentTypeProcessInstanceList) isEqualToString:contentType]) {
        NSError *parserError = nil;
        ASDKModelPaging *paging = nil;
        NSArray *processInstanceList = nil;
        Class pagingClass = ASDKModelPaging.class;
        
        if ([self validateJSONPropertyMappingOfClass:pagingClass
                               withContentDictionary:contentDictionary
                                               error:&parserError]) {
            paging = [MTLJSONAdapter modelOfClass:ASDKModelPaging.class
                               fromJSONDictionary:contentDictionary
                                            error:&parserError];
            processInstanceList = [MTLJSONAdapter modelsOfClass:ASDKModelProcessInstance.class
                                                  fromJSONArray:contentDictionary[kASDKAPIJSONKeyData]
                                                          error:&parserError];
        }
        
        dispatch_async(completionQueue, ^{
            completionBlock(processInstanceList, parserError, paging);
        });
    }
    if ([CREATE_STRING(ASDKProcessParserContentTypeStartProcessInstance) isEqualToString:contentType] ||
        [CREATE_STRING(ASDKProcessParserContentTypeProcessInstanceDetails) isEqualToString:contentType]) {
        NSError *parserError = nil;
        ASDKModelProcessInstance *processInstance = nil;
        Class modelClass = ASDKModelProcessInstance.class;
        
        if([self validateJSONPropertyMappingOfClass:modelClass
                              withContentDictionary:contentDictionary
                                              error:&parserError]) {
            processInstance = [MTLJSONAdapter modelOfClass:modelClass
                                        fromJSONDictionary:contentDictionary
                                                     error:&parserError];
        }
        
        dispatch_async(completionQueue, ^{
            completionBlock(processInstance, parserError, nil);
        });
    }
    if ([CREATE_STRING(ASDKProcessParserContentTypeProcessInstanceContent) isEqualToString:contentType]) {
        NSError *parserError = nil;
        NSMutableArray *contentList = [NSMutableArray array];
        Class modelClass = ASDKModelProcessInstanceContent.class;
        NSArray *processInstanceContentModels = contentDictionary[kASDKAPIJSONKeyData];
        
        if (!processInstanceContentModels) {
            parserError = [self invalidJSONMappingErrorForModelClass:modelClass];
        }
        for(NSDictionary *contentDict in processInstanceContentModels) {
            if ([self validateJSONPropertyMappingOfClass:modelClass
                                   withContentDictionary:contentDict
                                                   error:&parserError]) {
                ASDKModelProcessInstanceContent *processContentModel = [MTLJSONAdapter modelOfClass:ASDKModelProcessInstanceContent.class
                                                                                 fromJSONDictionary:contentDict
                                                                                              error:&parserError];
                [contentList addObject:processContentModel];
            } else break;
        }
        
        dispatch_async(completionQueue, ^{
            completionBlock(!contentList.count ? nil : contentList, parserError, nil);
        });
    }
    if ([CREATE_STRING(ASDKProcessParserContentTypeProcessInstanceComments) isEqualToString:contentType]) {
        NSError *parserError = nil;
        ASDKModelPaging *paging = nil;
        NSArray *commentList = nil;
        Class pagingClass = ASDKModelPaging.class;
        
        if ([self validateJSONPropertyMappingOfClass:pagingClass
                               withContentDictionary:contentDictionary
                                               error:&parserError]) {
            paging = [MTLJSONAdapter modelOfClass:ASDKModelPaging.class
                               fromJSONDictionary:contentDictionary
                                            error:&parserError];
            commentList = [MTLJSONAdapter modelsOfClass:ASDKModelComment.class
                                          fromJSONArray:contentDictionary[kASDKAPIJSONKeyData]
                                                  error:&parserError];
        }
        
        dispatch_async(completionQueue, ^{
            completionBlock(commentList, parserError, paging);
        });
    }
    if ([CREATE_STRING(ASDKProcessParserContentTypeProcessInstanceComment) isEqualToString:contentType]) {
        NSError *parserError = nil;
        ASDKModelComment *comment = nil;
        Class modelClass = ASDKModelComment.class;
        
        if ([self validateJSONPropertyMappingOfClass:modelClass
                               withContentDictionary:contentDictionary
                                               error:&parserError]) {
            comment = [MTLJSONAdapter modelOfClass:modelClass
                                fromJSONDictionary:contentDictionary
                                             error:&parserError];
        }
        
        dispatch_async(completionQueue, ^{
            completionBlock(comment, parserError, nil);
        });
    }
}

- (NSArray *)availableServices {
    return @[CREATE_STRING(ASDKProcessParserContentTypeProcessDefinitionList),
             CREATE_STRING(ASDKProcessParserContentTypeProcessInstanceList),
             CREATE_STRING(ASDKProcessParserContentTypeStartProcessInstance),
             CREATE_STRING(ASDKProcessParserContentTypeProcessInstanceDetails),
             CREATE_STRING(ASDKProcessParserContentTypeProcessInstanceContent),
             CREATE_STRING(ASDKProcessParserContentTypeProcessInstanceComments),
             CREATE_STRING(ASDKProcessParserContentTypeProcessInstanceComment)];
}

@end

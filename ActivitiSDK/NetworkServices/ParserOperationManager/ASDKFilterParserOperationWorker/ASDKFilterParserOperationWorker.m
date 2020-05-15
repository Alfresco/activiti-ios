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

#import "ASDKFilterParserOperationWorker.h"

// Constants
#import "ASDKLogConfiguration.h"
#import "ASDKNetworkServiceConstants.h"

// Models
#import "ASDKModelPaging.h"
#import "ASDKModelFilter.h"

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

static const int activitiSDKLogLevel = ASDK_LOG_LEVEL_VERBOSE; // | ASDK_LOG_FLAG_TRACE;

@implementation ASDKFilterParserOperationWorker

- (void)parseContentDictionary:(NSDictionary *)contentDictionary
                        ofType:(NSString *)contentType
           withCompletionBlock:(ASDKParserCompletionBlock)completionBlock
                         queue:(dispatch_queue_t)completionQueue {
    NSParameterAssert(contentDictionary);
    NSParameterAssert(contentType);
    NSParameterAssert(completionBlock);
    
    if ([CREATE_STRING(ASDKFilterParserContentTypeFilterList) isEqualToString:contentType]) {
        NSError *parserError = nil;
        ASDKModelPaging *paging = nil;
        NSMutableArray *filterList = nil;
        Class pagingClass = ASDKModelPaging.class;
        
        if ([self validateJSONPropertyMappingOfClass:pagingClass
                               withContentDictionary:contentDictionary
                                               error:&parserError]) {
            paging = [MTLJSONAdapter modelOfClass:pagingClass
                               fromJSONDictionary:contentDictionary
                                            error:&parserError];
            
            filterList = [NSMutableArray array];
            for (NSDictionary *filterDescription in contentDictionary[kASDKAPIJSONKeyData]) {
                // Extract nested filter information
                ASDKModelFilter *filter = [MTLJSONAdapter modelOfClass:ASDKModelFilter.class
                                                    fromJSONDictionary:filterDescription[kASDKAPIJSONKeyFilter]
                                                                 error:&parserError];
                if (parserError) {
                    ASDKLogError(@"Internal loop parser error for filter model.Reason:%@", parserError.localizedDescription);
                }
                
                // Manualy extract filter general description information and update the converted model
                filter.name = filterDescription[kASDKAPIJSONKeyName];
                filter.modelID = [NSString stringWithFormat:@"%@", filterDescription[kASDKAPIJSONKeyID]];
                if (filterDescription[kASDKAPIJSONKeyApplicationID]) {
                    filter.applicationID = [NSString stringWithFormat:@"%@", filterDescription[kASDKAPIJSONKeyApplicationID]];
                }
                
                [filterList addObject:filter];
            }
        }
        
        dispatch_async(completionQueue, ^{
            completionBlock(filterList, parserError, paging);
        });
    }
    
    if ([CREATE_STRING(ASDKFilterParserContentTypeFilterDetails) isEqualToString:contentType]) {
        NSError *parserError = nil;
        ASDKModelFilter *filter = nil;
        Class modelClass = ASDKModelFilter.class;
        
        if ([self validateJSONPropertyMappingOfClass:modelClass
                               withContentDictionary:contentDictionary
                                               error:&parserError]) {
            filter = [MTLJSONAdapter modelOfClass:modelClass
                               fromJSONDictionary:contentDictionary
                                            error:&parserError];
        }
        
        dispatch_async(completionQueue, ^{
            completionBlock(filter, parserError, nil);
        });
    }
}

- (NSArray *)availableServices {
    return @[CREATE_STRING(ASDKFilterParserContentTypeFilterList),
             CREATE_STRING(ASDKFilterParserContentTypeFilterDetails)];
}

@end

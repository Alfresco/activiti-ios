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

@import Foundation;
@import Mantle;
@class ASDKModelPaging;

#define CREATE_STRING(varName) @#varName

typedef void  (^ASDKParserCompletionBlock) (id parsedObject, NSError *error, ASDKModelPaging *paging);

@protocol ASDKParserOperationWorkerProtocol <NSObject>

- (void)parseContentDictionary:(NSDictionary *)contentDictionary
                        ofType:(NSString *)contentType
           withCompletionBlock:(ASDKParserCompletionBlock)completionBlock
                         queue:(dispatch_queue_t)completionQueue;

@optional
- (NSArray *)availableServices;
- (BOOL)validateJSONPropertyMappingOfClass:(Class <MTLJSONSerializing>)modelClass
                     withContentDictionary:(NSDictionary *)contentDictionary
                                     error:(NSError **)error;

@end

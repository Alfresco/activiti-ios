/*******************************************************************************
 * Copyright (C) 2005-2018 Alfresco Software Limited.
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

#import "ASDKFilterNetworkServices.h"

// Constants
#import "ASDKLogConfiguration.h"

// Categories
#import "NSURLSessionTask+ASDKAdditions.h"

// Models
#import "ASDKModelPaging.h"
#import "ASDKFilterListRequestRepresentation.h"
#import "ASDKFilterCreationRequestRepresentation.h"

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

static const int activitiSDKLogLevel = ASDK_LOG_LEVEL_VERBOSE; // | ASDK_LOG_FLAG_TRACE;

@interface ASDKFilterNetworkServices ()

@property (strong, nonatomic) NSMutableArray *networkOperations;

@end

@implementation ASDKFilterNetworkServices


#pragma mark -
#pragma mark Life cycle

- (instancetype)init {
    self = [super init];
    
    if (self) {
        self.networkOperations = [NSMutableArray array];
    }
    
    return self;
}


#pragma mark -
#pragma mark ASDKFilterNetworkService Protocol

- (void)fetchTaskFilterListWithCompletionBlock:(ASDKFilterListCompletionBlock)completionBlock {
    [self fetchTaskFilterListWithFilter:nil
                    withCompletionBlock:completionBlock];
}

- (void)fetchTaskFilterListWithFilter:(ASDKFilterListRequestRepresentation *)filter
                  withCompletionBlock:(ASDKFilterListCompletionBlock)completionBlock {
    // Check mandatory fields
    NSParameterAssert(completionBlock);
    NSParameterAssert(self.resultsQueue);
    
    __weak typeof(self) weakSelf = self;
    __block NSURLSessionDataTask *dataTask =
    [self.requestOperationManager GET:[self.servicePathFactory taskFilterListServicePath]
                           parameters:[filter jsonDictionary]
                             progress:nil
                              success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        __strong typeof(self) strongSelf = weakSelf;
        
        // Remove operation reference
        [strongSelf.networkOperations removeObject:dataTask];
        
        NSDictionary *responseDictionary = (NSDictionary *)responseObject;
        ASDKLogVerbose(@"Filter list fetched successfully for request: %@",
                       [task stateDescriptionForResponse:responseDictionary]);
        
        // Parse response data
        NSString *parserContentType = CREATE_STRING(ASDKFilterParserContentTypeFilterList);
        
        [strongSelf.parserOperationManager
         parseContentDictionary:responseDictionary
         ofType:parserContentType
         withCompletionBlock:^(id parsedObject, NSError *error, ASDKModelPaging *paging) {
            if (error) {
                ASDKLogError(kASDKAPIParserManagerConversionErrorFormat, parserContentType, error.localizedDescription);
                dispatch_async(weakSelf.resultsQueue, ^{
                    completionBlock(nil, error, nil);
                });
            } else {
                ASDKLogVerbose(kASDKAPIParserManagerConversionFormat, parserContentType, parsedObject);
                dispatch_async(weakSelf.resultsQueue, ^{
                    completionBlock(parsedObject, nil, paging);
                });
            }
        }];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        __strong typeof(self) strongSelf = weakSelf;
        
        // Remove operation reference
        [strongSelf.networkOperations removeObject:dataTask];
        
        ASDKLogError(@"Failed to fetch filter list for request: %@",
                     [task stateDescriptionForError:error]);
        
        dispatch_async(strongSelf.resultsQueue, ^{
            completionBlock(nil, error, nil);
        });
    }];
    
    // Keep network operation reference to be able to cancel it
    [self.networkOperations addObject:dataTask];
}

- (void)fetchProcessInstanceFilterListWithCompletionBlock:(ASDKFilterListCompletionBlock)completionBlock {
    [self fetchProcessInstanceFilterListWithFilter:nil
                               withCompletionBlock:completionBlock];
}

- (void)fetchProcessInstanceFilterListWithFilter:(ASDKFilterListRequestRepresentation *)filter
                             withCompletionBlock:(ASDKFilterListCompletionBlock)completionBlock {
    // Check mandatory fields
    NSParameterAssert(completionBlock);
    NSParameterAssert(self.resultsQueue);
    
    __weak typeof(self) weakSelf = self;
    __block NSURLSessionDataTask *dataTask =
    [self.requestOperationManager GET:[self.servicePathFactory processInstanceFilterListServicePath]
                           parameters:[filter jsonDictionary]
                             progress:nil
                              success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        __strong typeof(self) strongSelf = weakSelf;
        
        // Remove operation reference
        [strongSelf.networkOperations removeObject:dataTask];
        
        NSDictionary *responseDictionary = (NSDictionary *)responseObject;
        ASDKLogVerbose(@"Filter list fetched successfully for request: %@",
                       [task stateDescriptionForResponse:responseDictionary]);
        
        // Parse response data
        NSString *parserContentType = CREATE_STRING(ASDKFilterParserContentTypeFilterList);
        
        [strongSelf.parserOperationManager
         parseContentDictionary:responseDictionary
         ofType:parserContentType
         withCompletionBlock:^(id parsedObject, NSError *error, ASDKModelPaging *paging) {
            if (error) {
                ASDKLogError(kASDKAPIParserManagerConversionErrorFormat, parserContentType, error.localizedDescription);
                dispatch_async(weakSelf.resultsQueue, ^{
                    completionBlock(nil, error, nil);
                });
            } else {
                ASDKLogVerbose(kASDKAPIParserManagerConversionFormat, parserContentType, parsedObject);
                dispatch_async(weakSelf.resultsQueue, ^{
                    completionBlock(parsedObject, nil, paging);
                });
            }
        }];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        __strong typeof(self) strongSelf = weakSelf;
        
        // Remove operation reference
        [strongSelf.networkOperations removeObject:dataTask];
        
        ASDKLogError(@"Failed to fetch filter list for request: %@",
                     [task stateDescriptionForError:error]);
        
        dispatch_async(strongSelf.resultsQueue, ^{
            completionBlock(nil, error, nil);
        });
    }];
    
    // Keep network operation reference to be able to cancel it
    [self.networkOperations addObject:dataTask];
}

- (void)createUserTaskFilterWithRepresentation:(ASDKFilterCreationRequestRepresentation *)filter
                           withCompletionBlock:(ASDKFilterModelCompletionBlock)completionBlock {
    // Check mandatory fields
    NSParameterAssert(filter);
    NSParameterAssert(completionBlock);
    NSParameterAssert(self.resultsQueue);
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(self.resultsQueue, ^{
        __strong typeof(self) strongSelf = weakSelf;
        
        __block NSURLSessionDataTask *dataTask =
        [strongSelf.requestOperationManager POST:[strongSelf.servicePathFactory taskFilterListServicePath]
                                      parameters:[filter jsonDictionary]
                                        progress:nil
                                         success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            // Remove operation reference
            [weakSelf.networkOperations removeObject:dataTask];
            
            [weakSelf handleSuccessfulFilterCreationResponseForTask:task
                                                     responseObject:responseObject
                                                    completionBlock:completionBlock];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            // Remove operation reference
            [weakSelf.networkOperations removeObject:dataTask];
            
            [weakSelf handleFailedFilterCreationResponseForTask:task
                                                          error:error
                                            withCompletionBlock:completionBlock];
        }];
        
        // Keep network operation reference to be able to cancel it
        [strongSelf.networkOperations addObject:dataTask];
    });
}

- (void)createProcessInstanceTaskFilterWithRepresentation:(ASDKFilterCreationRequestRepresentation *)filter
                                      withCompletionBlock:(ASDKFilterModelCompletionBlock)completionBlock {
    // Check mandatory fields
    NSParameterAssert(filter);
    NSParameterAssert(completionBlock);
    NSParameterAssert(self.resultsQueue);
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(self.resultsQueue, ^{
        __strong typeof(self) strongSelf = weakSelf;
        
        __block NSURLSessionDataTask *dataTask =
        [strongSelf.requestOperationManager POST:[strongSelf.servicePathFactory processInstanceFilterListServicePath]
                                      parameters:[filter jsonDictionary]
                                        progress:nil
                                         success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            // Remove operation reference
            [weakSelf.networkOperations removeObject:dataTask];
            
            [weakSelf handleSuccessfulFilterCreationResponseForTask:task
                                                     responseObject:responseObject
                                                    completionBlock:completionBlock];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            // Remove operation reference
            [weakSelf.networkOperations removeObject:dataTask];
            
            [weakSelf handleFailedFilterCreationResponseForTask:task
                                                          error:error
                                            withCompletionBlock:completionBlock];
        }];
        
        // Keep network operation reference to be able to cancel it
        [strongSelf.networkOperations addObject:dataTask];
    });
}

- (void)cancelAllNetworkOperations {
    [self.networkOperations makeObjectsPerformSelector:@selector(cancel)];
    [self.networkOperations removeAllObjects];
}


#pragma mark -
#pragma mark Private interface

- (void)handleSuccessfulFilterCreationResponseForTask:(NSURLSessionDataTask *)task
                                       responseObject:(id)responseObject
                                      completionBlock:(ASDKFilterModelCompletionBlock)completionBlock {
    NSDictionary *responseDictionary = (NSDictionary *)responseObject;
    ASDKLogVerbose(@"Filter created successfully for request: %@",
                   [task stateDescriptionForResponse:responseDictionary]);
    
    // Parse response data
    __weak typeof(self) weakSelf = self;
    NSString *parserContentType = CREATE_STRING(ASDKFilterParserContentTypeFilterDetails);
    
    [self.parserOperationManager
     parseContentDictionary:responseDictionary
     ofType:parserContentType
     withCompletionBlock:^(id parsedObject, NSError *error, ASDKModelPaging *paging) {
        if (error) {
            ASDKLogError(kASDKAPIParserManagerConversionErrorFormat, parserContentType, error.localizedDescription);
            dispatch_async(weakSelf.resultsQueue, ^{
                completionBlock(nil, error);
            });
        } else {
            ASDKLogVerbose(kASDKAPIParserManagerConversionFormat, parserContentType, parsedObject);
            dispatch_async(weakSelf.resultsQueue, ^{
                completionBlock(parsedObject, nil);
            });
        }
    }];
}

- (void)handleFailedFilterCreationResponseForTask:(NSURLSessionDataTask *)task
                                            error:(NSError *)error
                              withCompletionBlock:(ASDKFilterModelCompletionBlock)completionBlock {
    ASDKLogError(@"Failed to create filter for request: %@",
                 [task stateDescriptionForError:error]);
    
    dispatch_async(self.resultsQueue, ^{
        completionBlock(nil, error);
    });
}

@end

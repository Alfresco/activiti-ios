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

#import "ASDKIntegrationNetworkServices.h"

// Constants
#import "ASDKLogConfiguration.h"
#import "ASDKNetworkServiceConstants.h"

// Categories
#import "NSURLSessionTask+ASDKAdditions.h"

// Model
#import "ASDKIntegrationNodeContentRequestRepresentation.h"
#import "ASDKModelContent.h"

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

static const int activitiSDKLogLevel = ASDK_LOG_LEVEL_VERBOSE; // | ASDK_LOG_FLAG_TRACE;

@interface ASDKIntegrationNetworkServices ()

@property (strong, nonatomic) NSMutableArray *networkOperations;

@end

@implementation ASDKIntegrationNetworkServices


#pragma mark -
#pragma mark Life cycle

- (instancetype)init {
    self = [super init];
    
    if (self) {
        self.networkOperations = [NSMutableArray array];
    }
    
    return self;
}

- (void)fetchIntegrationAccountsWithCompletionBlock:(ASDKIntegrationAccountListCompletionBlock)completionBlock {
    // Check mandatory properties
    NSParameterAssert(completionBlock);
    NSParameterAssert(self.resultsQueue);
    
    __weak typeof(self) weakSelf = self;
    __block NSURLSessionDataTask *dataTask =
    [self.requestOperationManager GET:[self.servicePathFactory integrationAccountsServicePath]
                           parameters:nil
                             progress:nil
                              success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                  __strong typeof(self) strongSelf = weakSelf;
                                  
                                  // Remove operation reference
                                  [strongSelf.networkOperations removeObject:dataTask];
                                  
                                  NSDictionary *responseDictionary = (NSDictionary *)responseObject;
                                  ASDKLogVerbose(@"Integration accounts list fetched successfully for request: %@",
                                                 [task stateDescriptionForResponse:responseDictionary]);
                                  
                                  // Parse response data
                                  NSString *parserContentType = CREATE_STRING(ASDKIntegrationParserContentTypeAccountList);
                                  
                                  [self.parserOperationManager
                                   parseContentDictionary:responseDictionary
                                   ofType:parserContentType
                                   withCompletionBlock:^(id parsedObject, NSError *error, ASDKModelPaging *paging) {
                                       if (error) {
                                           ASDKLogError(kASDKAPIParserManagerConversionErrorFormat, parserContentType, error.localizedDescription);
                                           dispatch_async(self.resultsQueue, ^{
                                               completionBlock(nil, error, nil);
                                           });
                                       } else {
                                           ASDKLogVerbose(kASDKAPIParserManagerConversionFormat, parserContentType, parsedObject);
                                           dispatch_async(self.resultsQueue, ^{
                                               completionBlock(parsedObject, nil, paging);
                                           });
                                       }
                                   }];
                              } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                  __strong typeof(self) strongSelf = weakSelf;
                                  
                                  // Remove operation reference
                                  [strongSelf.networkOperations removeObject:dataTask];
                                  
                                  ASDKLogError(@"Failed to fetch integration accounts list for request: %@",
                                               [task stateDescriptionForError:error]);
                                  
                                  dispatch_async(self.resultsQueue, ^{
                                      completionBlock(nil, error, nil);
                                  });
                              }];
    
    // Keep network operation reference to be able to cancel it
    [self.networkOperations addObject:dataTask];
}

- (void)fetchIntegrationNetworksForSourceID:(NSString *)sourceID
                            completionBlock:(ASDKIntegrationNetworkListCompletionBlock)completionBlock {
    // Check mandatory properties
    NSParameterAssert(completionBlock);
    NSParameterAssert(sourceID);
    NSParameterAssert(self.resultsQueue);
    
    __weak typeof(self) weakSelf = self;
    __block NSURLSessionDataTask *dataTask =
    [self.requestOperationManager GET:[NSString stringWithFormat:[self.servicePathFactory integrationNetworksServicePathFormat], sourceID]
                           parameters:nil
                             progress:nil
                              success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                  __strong typeof(self) strongSelf = weakSelf;
                                  
                                  // Remove operation reference
                                  [strongSelf.networkOperations removeObject:dataTask];
                                  
                                  NSDictionary *responseDictionary = (NSDictionary *)responseObject;
                                  ASDKLogVerbose(@"Integration network list fetched successfully for request: %@",
                                                 [task stateDescriptionForResponse:responseDictionary]);
                                  
                                  // Parse response data
                                  NSString *parserContentType = CREATE_STRING(ASDKIntegrationParserContentTypeNetworkList);
                                  
                                  [self.parserOperationManager
                                   parseContentDictionary:responseDictionary
                                   ofType:parserContentType
                                   withCompletionBlock:^(id parsedObject, NSError *error, ASDKModelPaging *paging) {
                                       if (error) {
                                           ASDKLogError(@"Error parsing integration network list. Description:%@", error.localizedDescription);
                                           
                                           dispatch_async(self.resultsQueue, ^{
                                               completionBlock(nil, error, nil);
                                           });
                                       } else {
                                           NSArray *integrationAccountsList = (NSArray *)parsedObject;
                                           ASDKLogVerbose(@"Successfully parsed model object:%@", integrationAccountsList);
                                           
                                           dispatch_async(self.resultsQueue, ^{
                                               completionBlock(integrationAccountsList, nil, paging);
                                           });
                                       }
                                   }];
                              } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                  __strong typeof(self) strongSelf = weakSelf;
                                  
                                  // Remove operation reference
                                  [strongSelf.networkOperations removeObject:dataTask];
                                  
                                  ASDKLogError(@"Failed to fetch integration network list for request: %@",
                                               [task stateDescriptionForError:error]);
                                  
                                  dispatch_async(self.resultsQueue, ^{
                                      completionBlock(nil, error, nil);
                                  });
                              }];
    
    // Keep network operation reference to be able to cancel it
    [self.networkOperations addObject:dataTask];
}

- (void)fetchIntegrationSitesForSourceID:(NSString *)sourceID
                               networkID:(NSString *)networkID
                         completionBlock:(ASDKIntegrationSiteListCompletionBlock)completionBlock {
    // Check mandatory properties
    NSParameterAssert(completionBlock);
    NSParameterAssert(sourceID);
    NSParameterAssert(networkID);
    NSParameterAssert(self.resultsQueue);
    
    __weak typeof(self) weakSelf = self;
    __block NSURLSessionDataTask *dataTask =
    [self.requestOperationManager GET:[NSString stringWithFormat:[self.servicePathFactory integrationSitesServicePathFormat],sourceID, networkID]
                           parameters:nil
                             progress:nil
                              success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                  __strong typeof(self) strongSelf = weakSelf;
                                  
                                  // Remove operation reference
                                  [strongSelf.networkOperations removeObject:dataTask];
                                  
                                  NSDictionary *responseDictionary = (NSDictionary *)responseObject;
                                  ASDKLogVerbose(@"Integration site list fetched successfully for request: %@",
                                                 [task stateDescriptionForResponse:responseDictionary]);
                                  
                                  // Parse response data
                                  NSString *parserContentType = CREATE_STRING(ASDKIntegrationParserContentTypeSiteList);
                                  
                                  [self.parserOperationManager
                                   parseContentDictionary:responseDictionary
                                   ofType:parserContentType
                                   withCompletionBlock:^(id parsedObject, NSError *error, ASDKModelPaging *paging) {
                                       if (error) {
                                           ASDKLogError(kASDKAPIParserManagerConversionErrorFormat, parserContentType, error.localizedDescription);
                                           dispatch_async(self.resultsQueue, ^{
                                               completionBlock(nil, error, nil);
                                           });
                                       } else {
                                           ASDKLogVerbose(kASDKAPIParserManagerConversionFormat, parserContentType, parsedObject);
                                           dispatch_async(self.resultsQueue, ^{
                                               completionBlock(parsedObject, nil, paging);
                                           });
                                       }
                                   }];
                              } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                  __strong typeof(self) strongSelf = weakSelf;
                                  
                                  // Remove operation reference
                                  [strongSelf.networkOperations removeObject:dataTask];
                                  
                                  ASDKLogError(@"Failed to fetch integration site list for request: %@",
                                               [task stateDescriptionForError:error]);
                                  
                                  dispatch_async(self.resultsQueue, ^{
                                      completionBlock(nil, error, nil);
                                  });
                              }];
    
    // Keep network operation reference to be able to cancel it
    [self.networkOperations addObject:dataTask];
}

- (void)fetchIntegrationContentForSourceID:(NSString *)sourceID
                                 networkID:(NSString *)networkID
                                    siteID:(NSString *)siteID
                           completionBlock:(ASDKIntegrationContentListCompletionBlock)completionBlock {
    // Check mandatory properties
    NSParameterAssert(completionBlock);
    NSParameterAssert(sourceID);
    NSParameterAssert(networkID);
    NSParameterAssert(siteID);
    NSParameterAssert(self.resultsQueue);
    
    __weak typeof(self) weakSelf = self;
    __block NSURLSessionDataTask *dataTask =
    [self.requestOperationManager GET:[NSString stringWithFormat:[self.servicePathFactory integrationSiteContentServicePathFormat], sourceID, networkID, siteID]
                           parameters:nil
                             progress:nil
                              success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                  __strong typeof(self) strongSelf = weakSelf;
                                  
                                  // Remove operation reference
                                  [strongSelf.networkOperations removeObject:dataTask];
                                  
                                  NSDictionary *responseDictionary = (NSDictionary *)responseObject;
                                  ASDKLogVerbose(@"Integration site content fetched successfully for request: %@",
                                                 [task stateDescriptionForResponse:responseDictionary]);
                                  
                                  // Parse response data
                                  NSString *parserContentType = CREATE_STRING(ASDKIntegrationParserContentTypeSiteContentList);
                                  
                                  [self.parserOperationManager
                                   parseContentDictionary:responseDictionary
                                   ofType:parserContentType
                                   withCompletionBlock:^(id parsedObject, NSError *error, ASDKModelPaging *paging) {
                                       if (error) {
                                           ASDKLogError(kASDKAPIParserManagerConversionErrorFormat, parserContentType, error.localizedDescription);
                                           dispatch_async(self.resultsQueue, ^{
                                               completionBlock(nil, error, nil);
                                           });
                                       } else {
                                           ASDKLogVerbose(kASDKAPIParserManagerConversionFormat, parserContentType, parsedObject);
                                           dispatch_async(self.resultsQueue, ^{
                                               completionBlock(parsedObject, nil, paging);
                                           });
                                       }
                                   }];
                              } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                  __strong typeof(self) strongSelf = weakSelf;
                                  
                                  // Remove operation reference
                                  [strongSelf.networkOperations removeObject:task];
                                  
                                  ASDKLogError(@"Failed to fetch integration site content for request: %@",
                                               [task stateDescriptionForError:error]);
                                  
                                  dispatch_async(self.resultsQueue, ^{
                                      completionBlock(nil, error, nil);
                                  });
                              }];
    
    // Keep network operation reference to be able to cancel it
    [self.networkOperations addObject:dataTask];
}

- (void)fetchIntegrationFolderContentForSourceID:(NSString *)sourceID
                                       networkID:(NSString *)networkID
                                        folderID:(NSString *)folderID
                                 completionBlock:(ASDKIntegrationContentListCompletionBlock)completionBlock {
    // Check mandatory properties
    NSParameterAssert(completionBlock);
    NSParameterAssert(sourceID);
    NSParameterAssert(networkID);
    NSParameterAssert(folderID);
    NSParameterAssert(self.resultsQueue);
    
    __weak typeof(self) weakSelf = self;
    __block NSURLSessionDataTask *dataTask =
    [self.requestOperationManager GET:[NSString stringWithFormat:[self.servicePathFactory integrationFolderContentServicePathFormat], sourceID, networkID, folderID]
                           parameters:nil
                             progress:nil
                              success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                  __strong typeof(self) strongSelf = weakSelf;
                                  
                                  // Remove operation reference
                                  [strongSelf.networkOperations removeObject:dataTask];
                                  
                                  NSDictionary *responseDictionary = (NSDictionary *)responseObject;
                                  ASDKLogVerbose(@"Integration folder content fetched successfully for request: %@",
                                                 [task stateDescriptionForResponse:responseDictionary]);
                                  
                                  // Parse response data
                                  NSString *parserContentType = CREATE_STRING(ASDKIntegrationParserContentTypeFolderContentList);
                                  
                                  [self.parserOperationManager
                                   parseContentDictionary:responseDictionary
                                   ofType:parserContentType
                                   withCompletionBlock:^(id parsedObject, NSError *error, ASDKModelPaging *paging) {
                                       if (error) {
                                           ASDKLogError(kASDKAPIParserManagerConversionErrorFormat, parserContentType, error.localizedDescription);
                                           dispatch_async(self.resultsQueue, ^{
                                               completionBlock(nil, error, nil);
                                           });
                                       } else {
                                           ASDKLogVerbose(kASDKAPIParserManagerConversionFormat, parserContentType, parsedObject);
                                           dispatch_async(self.resultsQueue, ^{
                                               completionBlock(parsedObject, nil, paging);
                                           });
                                       }
                                   }];
                              } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                  __strong typeof(self) strongSelf = weakSelf;
                                  
                                  // Remove operation reference
                                  [strongSelf.networkOperations removeObject:dataTask];
                                  
                                  ASDKLogError(@"Failed to fetch integration folder content for request: %@",
                                               [task stateDescriptionForError:error]);
                                  
                                  dispatch_async(self.resultsQueue, ^{
                                      completionBlock(nil, error, nil);
                                  });
                              }];
    
    // Keep network operation reference to be able to cancel it
    [self.networkOperations addObject:dataTask];
}

- (void)uploadIntegrationContentWithRepresentation:(ASDKIntegrationNodeContentRequestRepresentation *)nodeContentRepresentation
                                   completionBlock:(ASDKIntegrationContentUploadCompletionBlock)completionBlock {
    // Check mandatory properties
    NSParameterAssert(completionBlock);
    NSParameterAssert(nodeContentRepresentation);
    NSParameterAssert(self.resultsQueue);
    
    __weak typeof(self) weakSelf = self;
    __block NSURLSessionDataTask *dataTask =
    [self.requestOperationManager POST:[self.servicePathFactory integrationContentUploadServicePath]
                            parameters:[nodeContentRepresentation jsonDictionary]
                              progress:nil
                               success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                   __strong typeof(self) strongSelf = weakSelf;
                                   
                                   // Remove operation reference
                                   [strongSelf.networkOperations removeObject:dataTask];
                                   
                                   NSDictionary *responseDictionary = (NSDictionary *)responseObject;
                                   ASDKLogVerbose(@"Integration content uploaded successfully for request: %@",
                                                  [task stateDescriptionForResponse:responseDictionary]);
                                   
                                   // Parse response data
                                   NSString *parserContentType = CREATE_STRING(ASDKIntegrationParserContentTypeUploadedContent);
                                   
                                   [self.parserOperationManager
                                    parseContentDictionary:responseDictionary
                                    ofType:parserContentType
                                    withCompletionBlock:^(id parsedObject, NSError *error, ASDKModelPaging *paging) {
                                        if (error) {
                                            ASDKLogError(kASDKAPIParserManagerConversionErrorFormat, parserContentType, error.localizedDescription);
                                            dispatch_async(self.resultsQueue, ^{
                                                completionBlock(nil, error);
                                            });
                                        } else {
                                            ASDKModelContent *content = (ASDKModelContent *)parsedObject;
                                            ASDKLogVerbose(@"Successfully parsed model object:%@", content);
                                            
                                            dispatch_async(self.resultsQueue, ^{
                                                completionBlock(content, nil);
                                            });
                                        }
                                    }];
                               } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                   __strong typeof(self) strongSelf = weakSelf;
                                   
                                   // Remove operation reference
                                   [strongSelf.networkOperations removeObject:dataTask];
                                   
                                   ASDKLogError(@"Failed to upload integration content for request: %@",
                                                [task stateDescriptionForError:error]);
                                   
                                   dispatch_async(self.resultsQueue, ^{
                                       completionBlock(nil, error);
                                   });
                               }];
    
    // Keep network operation reference to be able to cancel it
    [self.networkOperations addObject:dataTask];
}

- (void)uploadIntegrationContentForTaskID:(NSString *)taskID
                       withRepresentation:(ASDKIntegrationNodeContentRequestRepresentation *)nodeContentRepresentation
                          completionBlock:(ASDKIntegrationContentUploadCompletionBlock)completionBlock {
    // Check mandatory properties
    NSParameterAssert(taskID);
    NSParameterAssert(nodeContentRepresentation);
    NSParameterAssert(completionBlock);
    NSParameterAssert(self.resultsQueue);
    
    __weak typeof(self) weakSelf = self;
    __block NSURLSessionDataTask *dataTask =
    [self.requestOperationManager POST:[NSString stringWithFormat:[self.servicePathFactory integrationContentUploadForTaskServicePathFormat], taskID]
                            parameters:[nodeContentRepresentation jsonDictionary]
                              progress:nil
                               success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                   __strong typeof(self) strongSelf = weakSelf;
                                   
                                   // Remove operation reference
                                   [strongSelf.networkOperations removeObject:dataTask];
                                   
                                   NSDictionary *responseDictionary = (NSDictionary *)responseObject;
                                   ASDKLogVerbose(@"Task integration content uploaded successfully for request: %@",
                                                  [task stateDescriptionForResponse:responseDictionary]);
                                   
                                   // Parse response data
                                   NSString *parserContentType = CREATE_STRING(ASDKIntegrationParserContentTypeUploadedContent);
                                   
                                   [self.parserOperationManager
                                    parseContentDictionary:responseDictionary
                                    ofType:parserContentType
                                    withCompletionBlock:^(id parsedObject, NSError *error, ASDKModelPaging *paging) {
                                        if (error) {
                                            ASDKLogError(kASDKAPIParserManagerConversionErrorFormat, parserContentType, error.localizedDescription);
                                            dispatch_async(self.resultsQueue, ^{
                                                completionBlock(nil, error);
                                            });
                                        } else {
                                            ASDKLogVerbose(kASDKAPIParserManagerConversionFormat, parserContentType, parsedObject);
                                            dispatch_async(self.resultsQueue, ^{
                                                completionBlock(parsedObject, nil);
                                            });
                                        }
                                    }];
                               } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                   __strong typeof(self) strongSelf = weakSelf;
                                   
                                   // Remove operation reference
                                   [strongSelf.networkOperations removeObject:dataTask];
                                   
                                   ASDKLogError(@"Failed to upload task integration content for request: %@",
                                                [task stateDescriptionForError:error]);
                                   
                                   dispatch_async(self.resultsQueue, ^{
                                       completionBlock(nil, error);
                                   });
                               }];
    
    // Keep network operation reference to be able to cancel it
    [self.networkOperations addObject:dataTask];
}


- (void)cancelAllNetworkOperations {
    [self.networkOperations makeObjectsPerformSelector:@selector(cancel)];
    [self.networkOperations removeAllObjects];
}

@end

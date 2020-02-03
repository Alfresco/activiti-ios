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

#import "ASDKProcessInstanceNetworkServices.h"

// Constants
#import "ASDKNetworkServiceConstants.h"
#import "ASDKDiskServicesConstants.h"
#import "ASDKLogConfiguration.h"

// Categories
#import "NSURLSessionTask+ASDKAdditions.h"

// Model
#import "ASDKFilterRequestRepresentation.h"
#import "ASDKStartProcessRequestRepresentation.h"


#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

static const int activitiSDKLogLevel = ASDK_LOG_LEVEL_VERBOSE; // | ASDK_LOG_FLAG_TRACE;

@interface ASDKProcessInstanceNetworkServices ()

@property (strong, nonatomic) NSMutableArray *networkOperations;

@end

@implementation ASDKProcessInstanceNetworkServices

#pragma mark -
#pragma mark Life cycle

- (instancetype)init {
    self = [super init];
    
    if (self) {
        self.networkOperations = [NSMutableArray array];
    }
    
    return self;
}

- (void)fetchProcessInstanceListWithFilterRepresentation:(ASDKFilterRequestRepresentation *)filter
                                         completionBlock:(ASDKProcessInstanceListCompletionBlock)completionBlock {
    // Check mandatory properties
    NSParameterAssert(filter);
    NSParameterAssert(completionBlock);
    NSParameterAssert(self.resultsQueue);
    
    __weak typeof(self) weakSelf = self;
    __block NSURLSessionDataTask *dataTask =
    [self.requestOperationManager POST:[self.servicePathFactory processInstancesListServicePath]
                            parameters:[filter jsonDictionary]
                              progress:nil
                               success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        __strong typeof(self) strongSelf = weakSelf;
        
        // Remove operation reference
        [strongSelf.networkOperations removeObject:dataTask];
        
        NSDictionary *responseDictionary = (NSDictionary *)responseObject;
        ASDKLogVerbose(@"Process instance list fetched successfully for request: %@",
                       [task stateDescriptionForResponse:responseDictionary]);
        
        // Parse response data
        NSString *parserContentType = CREATE_STRING(ASDKProcessParserContentTypeProcessInstanceList);
        
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
        
        ASDKLogError(@"Failed to fetch process instance list for request: %@",
                     [task stateDescriptionForError:error]);
        
        dispatch_async(self.resultsQueue, ^{
            completionBlock(nil, error, nil);
        });
    }];
    
    // Keep network operation reference to be able to cancel it
    [self.networkOperations addObject:dataTask];
}

- (void)startProcessInstanceWithStartProcessRequestRepresentation:(ASDKStartProcessRequestRepresentation *)request
                                                  completionBlock:(ASDKProcessInstanceCompletionBlock)completionBlock {
    
    // Check mandatory properties
    NSParameterAssert(request);
    NSParameterAssert(completionBlock);
    NSParameterAssert(self.resultsQueue);
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(self.resultsQueue, ^{
        __strong typeof(self) strongSelf = weakSelf;
        
        __block NSURLSessionDataTask *dataTask =
        [strongSelf.requestOperationManager POST:[strongSelf.servicePathFactory startProcessInstanceServicePath]
                                      parameters:[request jsonDictionary]
                                        progress:nil
                                         success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            // Remove operation reference
            [weakSelf.networkOperations removeObject:dataTask];
            
            NSDictionary *responseDictionary = (NSDictionary *)responseObject;
            ASDKLogVerbose(@"Process instance started successfully for request: %@",
                           [task stateDescriptionForResponse:responseDictionary]);
            
            // Parse response data
            NSString *parserContentType = CREATE_STRING(ASDKProcessParserContentTypeStartProcessInstance);
            
            [weakSelf.parserOperationManager
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
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            // Remove operation reference
            [weakSelf.networkOperations removeObject:dataTask];
            
            ASDKLogError(@"Failed to start process instance for request: %@",
                         [task stateDescriptionForError:error]);
            
            dispatch_async(weakSelf.resultsQueue, ^{
                completionBlock(nil, error);
            });
        }];
        
        // Keep network operation reference to be able to cancel it
        [strongSelf.networkOperations addObject:dataTask];
    });
}

- (void)fetchProcessInstanceDetailsForID:(NSString *)processInstanceID
                         completionBlock:(ASDKProcessInstanceCompletionBlock)completionBlock {
    NSParameterAssert(processInstanceID);
    NSParameterAssert(completionBlock);
    NSParameterAssert(self.resultsQueue);
    
    __weak typeof(self) weakSelf = self;
    __block NSURLSessionDataTask *dataTask =
    [self.requestOperationManager GET:[NSString stringWithFormat:[self.servicePathFactory processInstanceDetailsServicePathFormat], processInstanceID]
                           parameters:nil
                             progress:nil
                              success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        __strong typeof(self) strongSelf = weakSelf;
        
        // Remove operation reference
        [strongSelf.networkOperations removeObject:dataTask];
        
        NSDictionary *responseDictionary = (NSDictionary *)responseObject;
        ASDKLogVerbose(@"Process instance details fetched successfully for request: %@",
                       [task stateDescriptionForResponse:responseDictionary]);
        
        // Parse response data
        NSString *parserContentType = CREATE_STRING(ASDKProcessParserContentTypeProcessInstanceDetails);
        
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
                ASDKModelProcessInstance *processInstanceDetails = (ASDKModelProcessInstance *)parsedObject;
                ASDKLogVerbose(kASDKAPIParserManagerConversionFormat, parserContentType, parsedObject);
                dispatch_async(self.resultsQueue, ^{
                    completionBlock(processInstanceDetails, nil);
                });
            }
        }];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        __strong typeof(self) strongSelf = weakSelf;
        
        // Remove operation reference
        [strongSelf.networkOperations removeObject:dataTask];
        
        ASDKLogError(@"Failed to fetch process instance details for request: %@",
                     [task stateDescriptionForError:error]);
        
        dispatch_async(self.resultsQueue, ^{
            completionBlock(nil, error);
        });
    }];
    
    // Keep network operation reference to be able to cancel it
    [self.networkOperations addObject:dataTask];
}

- (void)fetchProcesInstanceContentForProcessInstanceID:(NSString *)processInstanceID
                                       completionBlock:(ASDKProcessInstanceContentCompletionBlock)completionBlock {
    // Check mandatory properties
    NSParameterAssert(processInstanceID);
    NSParameterAssert(completionBlock);
    NSParameterAssert(self.resultsQueue);
    
    __weak typeof(self) weakSelf = self;
    __block NSURLSessionDataTask *dataTask =
    [self.requestOperationManager GET:[NSString stringWithFormat:[self.servicePathFactory processInstanceContentServicePathFormat], processInstanceID]
                           parameters:nil
                             progress:nil
                              success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        __strong typeof(self) strongSelf = weakSelf;
        
        // Remove operation reference
        [strongSelf.networkOperations removeObject:dataTask];
        
        NSDictionary *responseDictionary = (NSDictionary *)responseObject;
        ASDKLogVerbose(@"Process instance content fetched successfully for request: %@",
                       [task stateDescriptionForResponse:responseDictionary]);
        
        // Parse response data
        NSString *parserContentType = CREATE_STRING(ASDKProcessParserContentTypeProcessInstanceContent);
        
        [strongSelf.parserOperationManager
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
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        __strong typeof(self) strongSelf = weakSelf;
        
        // Remove operation reference
        [strongSelf.networkOperations removeObject:dataTask];
        
        ASDKLogError(@"Failed to fetch process instance content for request: %@",
                     [task stateDescriptionForError:error]);
        
        dispatch_async(strongSelf.resultsQueue, ^{
            completionBlock(nil, error);
        });
    }];
    
    // Keep network operation reference to be able to cancel it
    [self.networkOperations addObject:dataTask];
}

- (void)fetchProcessInstanceCommentsForProcessInstanceID:(NSString *)processInstanceID
                                         completionBlock:(ASDKProcessInstanceCommentsCompletionBlock)completionBlock {
    // Check mandatory properties
    NSParameterAssert(processInstanceID);
    NSParameterAssert(completionBlock);
    NSParameterAssert(self.resultsQueue);
    
    __weak typeof(self) weakSelf = self;
    __block NSURLSessionDataTask *dataTask =
    [self.requestOperationManager GET:[NSString stringWithFormat:[self.servicePathFactory processInstanceCommentServicePathFormat], processInstanceID]
                           parameters:nil
                             progress:nil
                              success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        __strong typeof(self) strongSelf = weakSelf;
        
        // Remove operation reference
        [strongSelf.networkOperations removeObject:dataTask];
        
        NSDictionary *responseDictionary = (NSDictionary *)responseObject;
        ASDKLogVerbose(@"Process instance comments fetched successfully for request: %@",
                       [task stateDescriptionForResponse:responseDictionary]);
        
        // Parse response data
        NSString *parserContentType = CREATE_STRING(ASDKProcessParserContentTypeProcessInstanceComments);
        
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
        
        ASDKLogError(@"Failed to fetch process instance comments for request: %@",
                     [task stateDescriptionForError:error]);
        
        dispatch_async(strongSelf.resultsQueue, ^{
            completionBlock(nil, error, nil);
        });
    }];
    
    // Keep network operation reference to be able to cancel it
    [self.networkOperations addObject:dataTask];
}

- (void)createComment:(NSString *)comment
 forProcessInstanceID:(NSString *)processInstanceID
      completionBlock:(ASDKProcessInstanceCreateCommentCompletionBlock)completionBlock {
    // Check mandatory properties
    NSParameterAssert(comment);
    NSParameterAssert(processInstanceID);
    NSParameterAssert(completionBlock);
    NSParameterAssert(self.resultsQueue);
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(self.resultsQueue, ^{
        __strong typeof(self) strongSelf = weakSelf;
        
        __block NSURLSessionDataTask *dataTask =
        [strongSelf.requestOperationManager POST:[NSString stringWithFormat:[strongSelf.servicePathFactory processInstanceCommentServicePathFormat], processInstanceID]
                                      parameters:@{kASDKAPIMessageParameter : comment}
                                        progress:nil
                                         success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            // Remove operation reference
            [weakSelf.networkOperations removeObject:dataTask];
            
            NSDictionary *responseDictionary = (NSDictionary *)responseObject;
            ASDKLogVerbose(@"Comment created successfully for request: %@",
                           [task stateDescriptionForResponse:responseDictionary]);
            
            // Parse response data
            NSString *parserContentType = CREATE_STRING(ASDKProcessParserContentTypeProcessInstanceComment);
            
            [weakSelf.parserOperationManager
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
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            // Remove operation reference
            [weakSelf.networkOperations removeObject:dataTask];
            
            ASDKLogError(@"Failed to create process instance comment for request: %@",
                         [task stateDescriptionForError:error]);
            
            dispatch_async(weakSelf.resultsQueue, ^{
                completionBlock(nil, error);
            });
        }];
        
        // Keep network operation reference to be able to cancel it
        [strongSelf.networkOperations addObject:dataTask];
    });
}

- (void)deleteProcessInstanceWithID:(NSString *)processInstanceID
                    completionBlock:(ASDKProcessInstanceDeleteCompletionBlock)completionBlock {
    // Check mandatory properties
    NSParameterAssert(processInstanceID);
    NSParameterAssert(completionBlock);
    NSParameterAssert(self.resultsQueue);
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(self.resultsQueue, ^{
        __strong typeof(self) strongSelf = weakSelf;
        
        __block NSURLSessionDataTask *dataTask =
        [strongSelf.requestOperationManager DELETE:[NSString stringWithFormat:[strongSelf.servicePathFactory processInstanceDetailsServicePathFormat], processInstanceID]
                                        parameters:nil
                                           success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            // Remove operation reference
            [weakSelf.networkOperations removeObject:dataTask];
            
            // Check status code
            NSInteger statusCode = [task statusCode];
            if (ASDKHTTPCode200OK == statusCode) {
                ASDKLogVerbose(@"The process instance was deleted successfully for request: %@",
                               [task stateDescriptionForResponse:[NSHTTPURLResponse localizedStringForStatusCode:statusCode]]);
                
                dispatch_async(weakSelf.resultsQueue, ^{
                    completionBlock(YES, nil);
                });
            } else {
                ASDKLogError(@"Failed to delete process instance for request: %@",
                             [task stateDescriptionForResponse:[NSHTTPURLResponse localizedStringForStatusCode:statusCode]]);
                
                dispatch_async(weakSelf.resultsQueue, ^{
                    completionBlock(NO, nil);
                });
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            // Remove operation reference
            [weakSelf.networkOperations removeObject:dataTask];
            
            ASDKLogError(@"Failed to delete process instance for request: %@",
                         [task stateDescriptionForError:error]);
            
            dispatch_async(weakSelf.resultsQueue, ^{
                completionBlock(NO, error);
            });
        }];
        
        // Keep network operation reference to be able to cancel it
        [strongSelf.networkOperations addObject:dataTask];
    });
}

- (void)downloadAuditLogForProcessInstanceWithID:(NSString *)processInstanceID
                              allowCachedResults:(BOOL)allowCachedResults
                                   progressBlock:(ASDKProcessInstanceContentDownloadProgressBlock)progressBlock
                                 completionBlock:(ASDKProcessInstanceContentDownloadCompletionBlock)completionBlock {
    // Check mandatory properties
    NSParameterAssert(processInstanceID);
    NSParameterAssert(completionBlock);
    NSParameterAssert(self.resultsQueue);
    
    // If content already exists return the URL to it to the caller and the caller
    // explicitly mentioned cached results are expected return the existing data
    NSString *auditLogFileName = [NSString stringWithFormat:kASDKAuditLogFilenameFormat, processInstanceID];
    NSString *downloadPathForContent = [self.diskServices downloadPathForResourceWithIdentifier:processInstanceID
                                                                                       filename:auditLogFileName];
    if (allowCachedResults && [self.diskServices doesFileAlreadyExistsForResouceWithIdentifier:processInstanceID
                                                                                      filename:auditLogFileName]) {
        ASDKLogVerbose(@"Didn't performed content request. Providing cached result for audit log content of process instance with ID: %@", processInstanceID);
        dispatch_async(self.resultsQueue, ^{
            NSURL *downloadURL = [NSURL fileURLWithPath:downloadPathForContent];
            completionBlock(downloadURL, YES, nil);
        });
        
        return;
    }
    
    NSString *urlString = [[NSURL URLWithString:[NSString stringWithFormat:[self.servicePathFactory processInstanceAuditLogServicePathFormat], processInstanceID] relativeToURL:self.requestOperationManager.baseURL] absoluteString];
    NSError *downloadRequestError = nil;
    NSURLRequest *downloadRequest =
    [self.requestOperationManager.requestSerializer requestWithMethod:@"GET"
                                                            URLString:urlString
                                                           parameters:nil
                                                                error:&downloadRequestError];
    if (downloadRequestError) {
        ASDKLogError(@"Cannot create request to download content. Reason:%@", downloadRequestError.localizedDescription);
        dispatch_async(self.resultsQueue, ^{
            completionBlock(nil, NO, downloadRequestError);
        });
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(self.resultsQueue, ^{
        __strong typeof(self) strongSelf = weakSelf;
        
        __block NSURLSessionDownloadTask *downloadTask =
        [strongSelf.requestOperationManager downloadTaskWithRequest:downloadRequest
                                                           progress:nil
                                                        destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
            return [NSURL fileURLWithPath:downloadPathForContent];
        } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
            // Remove operation reference
            [weakSelf.networkOperations removeObject:downloadTask];
            
            if (!error) {
                // Check status code
                NSInteger statusCode = ((NSHTTPURLResponse *)response).statusCode;
                if (ASDKHTTPCode200OK == statusCode) {
                    ASDKLogVerbose(@"The audit log content was successfully downloaded with request: %@",
                                   [downloadTask stateDescriptionForResponse:[NSHTTPURLResponse localizedStringForStatusCode:statusCode]]);
                    
                    dispatch_async(weakSelf.resultsQueue, ^{
                        NSURL *downloadURL = [NSURL fileURLWithPath:downloadPathForContent];
                        completionBlock(downloadURL, NO, nil);
                    });
                } else {
                    ASDKLogVerbose(@"The audit log content failed to download with request: %@",
                                   [downloadTask stateDescriptionForResponse:[NSHTTPURLResponse localizedStringForStatusCode:statusCode]]);
                    
                    dispatch_async(weakSelf.resultsQueue, ^{
                        completionBlock(nil, NO, nil);
                    });
                }
            } else {
                ASDKLogError(@"Failed to download audit log content with request: %@ - %@.\nBody:%@.\nReason:%@",
                             downloadRequest.HTTPMethod,
                             downloadRequest.URL.absoluteString,
                             [[NSString alloc] initWithData:downloadRequest.HTTPBody encoding:NSUTF8StringEncoding],
                             error.localizedDescription);
                dispatch_async(weakSelf.resultsQueue, ^{
                    completionBlock(nil, NO, error);
                });
            }
        }];
        
        // If a progress block is provided report transfer progress information
        if (progressBlock) {
            [strongSelf.requestOperationManager setDownloadTaskDidWriteDataBlock:^(NSURLSession * _Nonnull session,
                                                                                   NSURLSessionDownloadTask * _Nonnull downloadTask,
                                                                                   int64_t bytesWritten,
                                                                                   int64_t totalBytesWritten,
                                                                                   int64_t totalBytesExpectedToWrite) {
                dispatch_async(weakSelf.resultsQueue, ^{
                    progressBlock([weakSelf.diskServices sizeStringForByteCount:totalBytesWritten] , nil);
                });
            }];
        }
        
        [downloadTask resume];
        
        // Keep network operation reference to be able to cancel it
        [strongSelf.networkOperations addObject:downloadTask];
    });
}

- (void)cancelAllTaskNetworkOperations {
    [self.networkOperations makeObjectsPerformSelector:@selector(cancel)];
    [self.networkOperations removeAllObjects];
}

@end

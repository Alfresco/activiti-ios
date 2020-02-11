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

#import "ASDKFormNetworkServices.h"

// Constants
#import "ASDKLogConfiguration.h"
#import "ASDKNetworkServiceConstants.h"

// Categories
#import "NSURLSessionTask+ASDKAdditions.h"

// Model
#import "ASDKFormFieldValueRequestRepresentation.h"



#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

static const int activitiSDKLogLevel = ASDK_LOG_LEVEL_VERBOSE; // | ASDK_LOG_FLAG_TRACE;

@interface ASDKFormNetworkServices ()

@property (strong, nonatomic) NSMutableArray *networkOperations;

@end

@implementation ASDKFormNetworkServices


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
#pragma mark ASDKFormNetworkService Protocol

- (void)startFormForProcessDefinitionID:(NSString *)processDefinitionID
                        completionBlock:(ASDKFormModelsCompletionBlock)completionBlock {
    // Check mandatory properties
    NSParameterAssert(processDefinitionID);
    NSParameterAssert(completionBlock);
    NSParameterAssert(self.resultsQueue);
    
    __weak typeof(self) weakSelf = self;
    __block NSURLSessionDataTask *dataTask =
    [self.requestOperationManager GET:[NSString stringWithFormat:[self.servicePathFactory processDefinitionStartFormServicePathFormat], processDefinitionID]
                           parameters:nil
                             progress:nil
                              success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        __strong typeof(self) strongSelf = weakSelf;
        
        // Remove operation reference
        [strongSelf.networkOperations removeObject:dataTask];
        
        [strongSelf handleSuccessfulFormModelsResponseForTask:task
                                               responseObject:responseObject
                                          withCompletionBlock:completionBlock];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        __strong typeof(self) strongSelf = weakSelf;
        
        // Remove operation reference
        [strongSelf.networkOperations removeObject:dataTask];
        
        ASDKLogError(@"Failed to start form for request: %@",
                     [task stateDescriptionForError:error]);
        
        dispatch_async(strongSelf.resultsQueue, ^{
            completionBlock(nil, error);
        });
    }];
    
    // Keep network operation reference to be able to cancel it
    [self.networkOperations addObject:dataTask];
}

- (void)startFormForProcessInstanceID:(NSString *)processInstanceID
                      completionBlock:(ASDKFormModelsCompletionBlock)completionBlock {
    // Check mandatory properties
    NSParameterAssert(processInstanceID);
    NSParameterAssert(completionBlock);
    NSParameterAssert(self.resultsQueue);
    
    __weak typeof(self) weakSelf = self;
    __block NSURLSessionDataTask *dataTask =
    [self.requestOperationManager GET:[NSString stringWithFormat:[self.servicePathFactory processInstanceStartFormServicePathFormat], processInstanceID]
                           parameters:nil
                             progress:nil
                              success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        __strong typeof(self) strongSelf = weakSelf;
        
        // Remove operation reference
        [strongSelf.networkOperations removeObject:dataTask];
        
        [strongSelf handleSuccessfulFormModelsResponseForTask:task
                                               responseObject:responseObject
                                          withCompletionBlock:completionBlock];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        __strong typeof(self) strongSelf = weakSelf;
        
        // Remove operation reference
        [strongSelf.networkOperations removeObject:dataTask];
        
        ASDKLogError(@"Failed to start form for request: %@",
                     [task stateDescriptionForError:error]);
        
        dispatch_async(strongSelf.resultsQueue, ^{
            completionBlock(nil, error);
        });
    }];
    
    // Keep network operation reference to be able to cancel it
    [self.networkOperations addObject:dataTask];
}

- (void)completeFormForTaskID:(NSString *)taskID
withFormFieldValueRequestRepresentation:(ASDKFormFieldValueRequestRepresentation *)formFieldValuesRepresentation
              completionBlock:(ASDKFormCompletionBlock)completionBlock {
    // Check mandatory properties
    NSParameterAssert(taskID);
    NSParameterAssert(formFieldValuesRepresentation);
    NSParameterAssert(self.resultsQueue);
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(self.resultsQueue, ^{
        __strong typeof(self) strongSelf = weakSelf;
        
        __block NSURLSessionDataTask *dataTask =
        [strongSelf.requestOperationManager POST:[NSString stringWithFormat:[strongSelf.servicePathFactory taskFormServicePathFormat], taskID]
                                      parameters:[formFieldValuesRepresentation jsonDictionary]
                                        progress:nil
                                         success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            // Remove operation reference
            [weakSelf.networkOperations removeObject:dataTask];
            
            NSDictionary *responseDictionary = (NSDictionary *)responseObject;
            ASDKLogVerbose(@"Form completed with success for request: %@",
                           [task stateDescriptionForResponse:responseDictionary]);
            
            dispatch_async(weakSelf.resultsQueue, ^{
                completionBlock(YES, nil);
            });
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            // Remove operation reference
            [weakSelf.networkOperations removeObject:dataTask];
            
            ASDKLogError(@"Failed to complete form for request: %@",
                         [task stateDescriptionForError:error]);
            
            dispatch_async(weakSelf.resultsQueue, ^{
                completionBlock(NO, error);
            });
        }];
        
        // Keep network operation reference to be able to cancel it
        [strongSelf.networkOperations addObject:dataTask];
    });
}

- (void)completeFormForProcessDefinition:(ASDKModelProcessDefinition *)processDefinition
withFormFieldValuesRequestRepresentation:(ASDKFormFieldValueRequestRepresentation *)formFieldValuesRepresentation
                         completionBlock:(ASDKStarFormCompletionBlock)completionBlock {
    NSParameterAssert(processDefinition );
    NSParameterAssert(formFieldValuesRepresentation);
    NSParameterAssert(self.resultsQueue);
    
    // Add the process definition ID to the list of passed parameters
    NSMutableDictionary *requestParameters = [NSMutableDictionary dictionaryWithDictionary: [formFieldValuesRepresentation jsonDictionary]];
    [requestParameters setObject:processDefinition.modelID
                          forKey:kASDKAPIProcessDefinitionIDParameter];
    [requestParameters setObject:processDefinition.name
                          forKey:kASDKAPIGenericNameParameter];
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(self.resultsQueue, ^{
        __strong typeof(self) strongSelf = weakSelf;
        
        __block NSURLSessionDataTask *dataTask =
        [strongSelf.requestOperationManager POST:[strongSelf.servicePathFactory startFormCompletionPath]
                                      parameters:requestParameters
                                        progress:nil
                                         success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            // Remove operation reference
            [weakSelf.networkOperations removeObject:dataTask];
            
            NSDictionary *responseDictionary = (NSDictionary *)responseObject;
            ASDKLogVerbose(@"Form completed successfully for request: %@",
                           [task stateDescriptionForResponse:responseDictionary]);
            
            // Parse response data
            NSString *parserContentType = CREATE_STRING(ASDKProcessParserContentTypeProcessInstanceDetails);
            
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
            
            ASDKLogError(@"Failed to complete form for request: %@",
                         [task stateDescriptionForError:error]);
            
            dispatch_async(weakSelf.resultsQueue, ^{
                completionBlock(nil, error);
            });
        }];
        
        // Keep network operation reference to be able to cancel it
        [strongSelf.networkOperations addObject:dataTask];
    });
}

- (void)saveFormForTaskID:(NSString *)taskID
withFormFieldValuesRequestRepresentation:(ASDKFormFieldValueRequestRepresentation *)formFieldValuesRepresentation
          completionBlock:(ASDKFormSaveBlock)completionBlock {
    // Check mandatory properties
    NSParameterAssert(taskID);
    NSParameterAssert(formFieldValuesRepresentation);
    NSParameterAssert(self.resultsQueue);
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(self.resultsQueue, ^{
        __strong typeof(self) strongSelf = weakSelf;
        
        __block NSURLSessionDataTask *dataTask =
        [strongSelf.requestOperationManager POST:[NSString stringWithFormat:[strongSelf.servicePathFactory saveFormServicePathFormat], taskID]
                                      parameters:[formFieldValuesRepresentation jsonDictionary]
                                        progress:nil
                                         success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            // Remove operation reference
            [weakSelf.networkOperations removeObject:dataTask];
            
            NSDictionary *responseDictionary = (NSDictionary *)responseObject;
            ASDKLogVerbose(@"Form was successfully saved with request: %@",
                           [task stateDescriptionForResponse:responseDictionary]);
            
            dispatch_async(weakSelf.resultsQueue, ^{
                completionBlock(YES, nil);
            });
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            // Remove operation reference
            [weakSelf.networkOperations removeObject:dataTask];
            
            ASDKLogError(@"Failed to save form for request: %@",
                         [task stateDescriptionForError:error]);
            
            dispatch_async(weakSelf.resultsQueue, ^{
                completionBlock(NO, error);
            });
        }];
        
        // Keep network operation reference to be able to cancel it
        [strongSelf.networkOperations addObject:dataTask];
    });
}

- (void)fetchFormForTaskWithID:(NSString *)taskID
               completionBlock:(ASDKFormModelsCompletionBlock)completionBlock {
    // Check mandatory properties
    NSParameterAssert(taskID);
    NSParameterAssert(completionBlock);
    NSParameterAssert(self.resultsQueue);
    
    __weak typeof(self) weakSelf = self;
    __block NSURLSessionDataTask *dataTask =
    [self.requestOperationManager GET:[NSString stringWithFormat:[self.servicePathFactory taskFormServicePathFormat], taskID]
                           parameters:nil
                             progress:nil
                              success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        __strong typeof(self) strongSelf = weakSelf;
        
        // Remove operation reference
        [strongSelf.networkOperations removeObject:dataTask];
        
        [strongSelf handleSuccessfulFormModelsResponseForTask:dataTask
                                               responseObject:responseObject
                                          withCompletionBlock:completionBlock];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        __strong typeof(self) strongSelf = weakSelf;
        
        // Remove operation reference
        [strongSelf.networkOperations removeObject:dataTask];
        
        ASDKLogError(@"Failed to fetch form for request: %@",
                     [task stateDescriptionForError:error]);
        
        dispatch_async(strongSelf.resultsQueue, ^{
            completionBlock(nil, error);
        });
    }];
    
    // Keep network operation reference to be able to cancel it
    [self.networkOperations addObject:dataTask];
}

- (void)fetchFormVariablesForTaskWithID:(NSString *)taskID
                        completionBlock:(ASDKFormVariablesCompletionBlock)completionBlock {
    // Check mandatory properties
    NSParameterAssert(taskID);
    NSParameterAssert(completionBlock);
    
    __weak typeof(self) weakSelf = self;
    __block NSURLSessionDataTask *dataTask =
    [self.requestOperationManager GET:[NSString stringWithFormat:[self.servicePathFactory taskFormVariablesPathFormat], taskID]
                           parameters:nil
                             progress:nil
                              success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        __strong typeof(self) strongSelf = weakSelf;
        
        // Remove operation reference
        [strongSelf.networkOperations removeObject:dataTask];
        
        NSDictionary *responseDictionary = (NSDictionary *)responseObject;
        ASDKLogVerbose(@"Fetch rest field values with success for request: %@",
                       [task stateDescriptionForResponse:responseDictionary]);
        
        // Parse response data
        NSString *parserContentType = CREATE_STRING(ASDKTaskFormParserContentTypeFormVariables);
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
        
        ASDKLogError(@"Failed to fetch rest field values for request: %@",
                     [task stateDescriptionForError:error]);
        
        dispatch_async(strongSelf.resultsQueue, ^{
            completionBlock(nil, error);
        });
    }];
}

- (void)uploadContentWithModel:(ASDKModelFileContent *)file
                   contentData:(NSData *)contentData
                 progressBlock:(ASDKFormContentProgressBlock)progressBlock
               completionBlock:(ASDKFormContentUploadCompletionBlock)completionBlock {
    // Check mandatory properties
    NSParameterAssert(file);
    NSParameterAssert(contentData);
    NSParameterAssert(completionBlock);
    NSParameterAssert(self.resultsQueue);
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(self.resultsQueue, ^{
        __strong typeof(self) strongSelf = weakSelf;
        
        __block NSURLSessionDataTask *dataTask =
        [strongSelf.requestOperationManager POST:[strongSelf.servicePathFactory contentFieldUploadServicePath]
                                      parameters:nil
                       constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            NSError *error = nil;
            
            [formData appendPartWithFileData:contentData
                                        name:kASDKAPIContentUploadMultipartParameter
                                    fileName:file.fileName
                                    mimeType:file.mimeType];
            
            if (error) {
                ASDKLogError(@"An error occured while appending multipart form data from file %@.", file.modelFileURL);
            }
        } progress:^(NSProgress * _Nonnull uploadProgress) {
            // If a progress block is provided report transfer progress information
            if (progressBlock) {
                NSUInteger percentProgress = (NSUInteger) (uploadProgress.completedUnitCount * 100 / uploadProgress.totalUnitCount);
                
                dispatch_async(weakSelf.resultsQueue, ^{
                    progressBlock(percentProgress, nil);
                });
            }
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            // Remove operation reference
            [weakSelf.networkOperations removeObject:dataTask];
            
            NSDictionary *responseDictionary = (NSDictionary *)responseObject;
            ASDKLogVerbose(@"Form field content succesfully uploaded for request: %@",
                           [task stateDescriptionForResponse:responseDictionary]);
            
            // Parse response data
            NSString *parserContentType = CREATE_STRING(ASDKTaskDetailsParserContentTypeContent);
            
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
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                        // Generate the file path
                        if (![weakSelf.diskServices doesFileAlreadyExistsForContent:parsedObject]) {
                            NSString *downloadPathForContent = [weakSelf.diskServices downloadPathForContent:parsedObject];
                            NSError *error = nil;
                            
                            // Save it into file system
                            BOOL isWritten = [contentData writeToFile:downloadPathForContent
                                                              options:kNilOptions
                                                                error:&error];
                            if (isWritten) {
                                ASDKLogVerbose(@"Local storage is written");
                            } else {
                                ASDKLogError(@"Error while storing local storage %@", error);
                            }
                        }
                    });
                    dispatch_async(weakSelf.resultsQueue, ^{
                        completionBlock(parsedObject, nil);
                    });
                }
            }];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            // Remove operation reference
            [weakSelf.networkOperations removeObject:dataTask];
            
            ASDKLogError(@"Failed to upload form field content for request: %@",
                         [task stateDescriptionForError:error]);
            
            dispatch_async(weakSelf.resultsQueue, ^{
                completionBlock(nil, error);
            });
        }];
        
        // Keep network operation reference to be able to cancel it
        [strongSelf.networkOperations addObject:dataTask];
    });
}

- (void)downloadContentWithModel:(ASDKModelContent *)content
              allowCachedResults:(BOOL)allowCachedResults
                   progressBlock:(ASDKFormContentDownloadProgressBlock)progressBlock
                 completionBlock:(ASDKFormContentDownloadCompletionBlock)completionBlock {
    // Check mandatory properties
    NSParameterAssert(content);
    NSParameterAssert(completionBlock);
    NSParameterAssert(self.resultsQueue);
    
    NSString *downloadPathForContent = [self.diskServices downloadPathForContent:content];
    
    // If content already exists return the URL to it to the caller and the caller
    // explicitly mentioned cached results are expected return the existing data
    if (allowCachedResults && [self.diskServices doesFileAlreadyExistsForContent:content]) {
        ASDKLogVerbose(@"Didn't performed content request. Providing cached result for content with ID: %@", content.modelID);
        dispatch_async(self.resultsQueue, ^{
            NSURL *downloadURL = [NSURL fileURLWithPath:downloadPathForContent];
            completionBlock(content.modelID, downloadURL, YES, nil);
        });
        
        return;
    }
    
    NSString *urlString = [[NSURL URLWithString:[NSString stringWithFormat:[self.servicePathFactory taskContentDownloadServicePathFormat], content.modelID] relativeToURL:self.requestOperationManager.baseURL] absoluteString];
    NSError *downloadRequestError = nil;
    NSURLRequest *downloadRequest =
    [self.requestOperationManager.requestSerializer requestWithMethod:@"GET"
                                                            URLString:urlString
                                                           parameters:nil
                                                                error:&downloadRequestError];
    if (downloadRequestError) {
        ASDKLogError(@"Cannot create request to download content. Reason:%@", downloadRequestError.localizedDescription);
        dispatch_async(self.resultsQueue, ^{
            completionBlock(nil, nil, NO, downloadRequestError);
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
                NSInteger statusCode = ((NSHTTPURLResponse *)response).statusCode;
                ASDKLogVerbose(@"The form field content was successfully downloaded with request: %@",
                               [downloadTask stateDescriptionForResponse:[NSHTTPURLResponse localizedStringForStatusCode:statusCode]]);
                
                dispatch_async(weakSelf.resultsQueue, ^{
                    NSURL *downloadURL = [NSURL fileURLWithPath:downloadPathForContent];
                    completionBlock(content.modelID, downloadURL, NO, nil);
                });
            } else {
                ASDKLogError(@"Failed to download content for task with request: %@ - %@.\nBody:%@.\nReason:%@",
                             downloadRequest.HTTPMethod,
                             downloadRequest.URL.absoluteString,
                             [[NSString alloc] initWithData:downloadRequest.HTTPBody encoding:NSUTF8StringEncoding],
                             error.localizedDescription);
                dispatch_async(weakSelf.resultsQueue, ^{
                    completionBlock(nil, nil, NO, error);
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


- (void)fetchRestFieldValuesForTaskWithID:(NSString *)taskID
                              withFieldID:(NSString *)fieldID
                          completionBlock:(ASDKFormRestFieldValuesCompletionBlock)completionBlock {
    // Check mandatory properties
    NSParameterAssert(taskID);
    NSParameterAssert(fieldID);
    NSParameterAssert(completionBlock);
    NSParameterAssert(self.resultsQueue);
    
    __weak typeof(self) weakSelf = self;
    __block NSURLSessionDataTask *dataTask =
    [self.requestOperationManager GET:[NSString stringWithFormat:[self.servicePathFactory restFieldValuesServicePathFormat], taskID, fieldID]
                           parameters:nil
                             progress:nil
                              success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        __strong typeof(self) strongSelf = weakSelf;
        
        // Remove operation reference
        [strongSelf.networkOperations removeObject:dataTask];
        
        NSDictionary *responseDictionary = (NSDictionary *)responseObject;
        
        ASDKLogVerbose(@"Fetch rest field values with success for request: %@",
                       [task stateDescriptionForResponse:responseDictionary]);
        
        // Parse response data
        NSString *parserContentType = CREATE_STRING(ASDKTaskFormParserContentTypeRestFieldValues);
        
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
        
        ASDKLogError(@"Failed to fetch rest field values for request: %@",
                     [task stateDescriptionForError:error]);
        
        dispatch_async(strongSelf.resultsQueue, ^{
            completionBlock(nil, error);
        });
    }];
    
    // Keep network operation reference to be able to cancel it
    [self.networkOperations addObject:dataTask];
}

- (void)fetchRestFieldValuesForTaskWithID:(NSString *)taskID
                              withFieldID:(NSString *)fieldID
                             withColumnID:(NSString *)columnID
                          completionBlock:(ASDKFormRestFieldValuesCompletionBlock)completionBlock {
    // Check mandatory properties
    NSParameterAssert(taskID);
    NSParameterAssert(fieldID);
    NSParameterAssert(columnID);
    NSParameterAssert(completionBlock);
    NSParameterAssert(self.resultsQueue);
    
    __weak typeof(self) weakSelf = self;
    __block NSURLSessionDataTask *dataTask =
    [self.requestOperationManager GET:[NSString stringWithFormat:[self.servicePathFactory dynamicTableRestFieldValuesServicePathFormat], taskID, fieldID, columnID]
                           parameters:nil
                             progress:nil
                              success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        __strong typeof(self) strongSelf = weakSelf;
        
        // Remove operation reference
        [strongSelf.networkOperations removeObject:dataTask];
        
        NSDictionary *responseDictionary = (NSDictionary *)responseObject;
        
        ASDKLogVerbose(@"Fetch rest field values with success for request: %@",
                       [task stateDescriptionForResponse:responseDictionary]);
        
        // Parse response data
        NSString *parserContentType = CREATE_STRING(ASDKTaskFormParserContentTypeRestFieldValues);
        
        [strongSelf.parserOperationManager
         parseContentDictionary:responseDictionary
         ofType:CREATE_STRING(ASDKTaskFormParserContentTypeRestFieldValues)
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
        
        ASDKLogError(@"Failed to fetch rest field values for request: %@",
                     [task stateDescriptionForError:error]);
        
        dispatch_async(strongSelf.resultsQueue, ^{
            completionBlock(nil, error);
        });
    }];
    
    // Keep network operation reference to be able to cancel it
    [self.networkOperations addObject:dataTask];
}

- (void)fetchRestFieldValuesForStartFormWithProcessDefinitionID:(NSString *)processDefinitionID
                                                    withFieldID:(NSString *)fieldID
                                                completionBlock:(ASDKStartFormRestFieldValuesCompletionBlock)completionBlock {
    // Check mandatory properties
    NSParameterAssert(processDefinitionID);
    NSParameterAssert(fieldID);
    NSParameterAssert(completionBlock);
    NSParameterAssert(self.resultsQueue);
    
    __weak typeof(self) weakSelf = self;
    __block NSURLSessionDataTask *dataTask =
    [self.requestOperationManager GET:[NSString stringWithFormat:[self.servicePathFactory startFormRestFieldValuesServicePathFormat], processDefinitionID, fieldID]
                           parameters:nil
                             progress:nil
                              success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        __strong typeof(self) strongSelf = weakSelf;
        
        // Remove operation reference
        [strongSelf.networkOperations removeObject:dataTask];
        
        NSDictionary *responseDictionary = (NSDictionary *)responseObject;
        
        ASDKLogVerbose(@"Fetch rest field values with success for request: %@",
                       [task stateDescriptionForResponse:responseDictionary]);
        
        // Parse response data
        NSString *parserContentType = CREATE_STRING(ASDKTaskFormParserContentTypeRestFieldValues);
        
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
        
        ASDKLogError(@"Failed to fetch rest field values for request: %@",
                     [task stateDescriptionForError:error]);
        
        dispatch_async(strongSelf.resultsQueue, ^{
            completionBlock(nil, error);
        });
    }];
    
    // Keep network operation reference to be able to cancel it
    [self.networkOperations addObject:dataTask];
}

- (void)fetchRestFieldValuesForStartFormWithProcessDefinitionID:(NSString *)processDefinitionID
                                                    withFieldID:(NSString *)fieldID
                                                   withColumnID:(NSString *)columnID
                                                completionBlock:(ASDKStartFormRestFieldValuesCompletionBlock)completionBlock {
    // Check mandatory properties
    NSParameterAssert(processDefinitionID);
    NSParameterAssert(fieldID);
    NSParameterAssert(completionBlock);
    NSParameterAssert(self.resultsQueue);
    
    __weak typeof(self) weakSelf = self;
    __block NSURLSessionDataTask *dataTask =
    [self.requestOperationManager GET:[NSString stringWithFormat:[self.servicePathFactory startFormDynamicTableRestFieldValuesServicePathFormat], processDefinitionID, fieldID, columnID]
                           parameters:nil
                             progress:nil
                              success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        __strong typeof(self) strongSelf = weakSelf;
        
        // Remove operation reference
        [strongSelf.networkOperations removeObject:dataTask];
        
        NSDictionary *responseDictionary = (NSDictionary *)responseObject;
        
        ASDKLogVerbose(@"Fetch rest field values with success for request: %@",
                       [task stateDescriptionForResponse:responseDictionary]);
        
        // Parse response data
        NSString *parserContentType = CREATE_STRING(ASDKTaskFormParserContentTypeRestFieldValues);
        
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
        
        ASDKLogError(@"Failed to fetch rest field values for request: %@",
                     [task stateDescriptionForError:error]);
        
        dispatch_async(strongSelf.resultsQueue, ^{
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


#pragma mark -
#pragma mark Private interface

- (void)handleSuccessfulFormModelsResponseForTask:(NSURLSessionDataTask *)task
                                   responseObject:(id)responseObject
                              withCompletionBlock:(ASDKFormModelsCompletionBlock)completionBlock {
    NSDictionary *responseDictionary = (NSDictionary *)responseObject;
    ASDKLogVerbose(@"Form fetched with success for request:%@",
                   [task stateDescriptionForResponse:responseDictionary]);
    
    // Parse response data
    NSString *parserContentType = CREATE_STRING(ASDKTaskFormParserContentTypeFormModels);
    
    [self.parserOperationManager parseContentDictionary:responseDictionary
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
}

@end

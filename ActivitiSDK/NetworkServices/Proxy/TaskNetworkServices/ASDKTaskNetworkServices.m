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

#import "ASDKTaskNetworkServices.h"

// Constants
#import "ASDKLogConfiguration.h"
#import "ASDKNetworkServiceConstants.h"
#import "ASDKDiskServicesConstants.h"

// Categories
#import "NSURLSessionTask+ASDKAdditions.h"

// Model
#import "ASDKTaskRequestRepresentation.h"
#import "ASDKFilterRequestRepresentation.h"
#import "ASDKTaskUpdateRequestRepresentation.h"
#import "ASDKTaskCreationRequestRepresentation.h"
#import "ASDKTaskChecklistOrderRequestRepresentation.h"
#import "ASDKModelPaging.h"
#import "ASDKModelFileContent.h"

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

static const int activitiSDKLogLevel = ASDK_LOG_LEVEL_VERBOSE; // | ASDK_LOG_FLAG_TRACE;

@interface ASDKTaskNetworkServices ()

@property (strong, nonatomic) NSMutableArray *networkOperations;

@end

@implementation ASDKTaskNetworkServices


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
#pragma mark ASDKTaskNetworkService Protocol

- (void)fetchTaskListWithTaskRepresentationFilter:(ASDKTaskRequestRepresentation *)filter
                                  completionBlock:(ASDKTaskListCompletionBlock)completionBlock {
    // Check mandatory properties
    NSParameterAssert(filter);
    NSParameterAssert(completionBlock);
    NSParameterAssert(self.resultsQueue);
    
    __weak typeof(self) weakSelf = self;
    __block NSURLSessionDataTask *dataTask =
    [self.requestOperationManager POST:[self.servicePathFactory taskListServicePath]
                            parameters:[filter jsonDictionary]
                              progress:nil
                               success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        __strong typeof(self) strongSelf = weakSelf;
        
        // Remove operation reference
        [strongSelf.networkOperations removeObject:dataTask];
        
        [strongSelf handleSuccessfulTaskListResponseForTask:task
                                             responseObject:responseObject
                                            completionBlock:completionBlock];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        __strong typeof(self) strongSelf = weakSelf;
        
        // Remove operation reference
        [strongSelf.networkOperations removeObject:dataTask];
        
        [strongSelf handleFailedTaskListResponseForTask:task
                                                  error:error
                                        completionBlock:completionBlock];
    }];
    
    // Keep network operation reference to be able to cancel it
    [self.networkOperations addObject:dataTask];
}

- (void)fetchTaskListWithFilterRepresentation:(ASDKFilterRequestRepresentation *)filter
                              completionBlock:(ASDKTaskListCompletionBlock)completionBlock {
    // Check mandatory properties
    NSParameterAssert(filter);
    NSParameterAssert(completionBlock);
    NSParameterAssert(self.resultsQueue);
    
    __weak typeof(self) weakSelf = self;
    __block NSURLSessionDataTask *dataTask =
    [self.requestOperationManager POST:[self.servicePathFactory taskListFromFilterServicePath]
                            parameters:[filter jsonDictionary]
                              progress:nil
                               success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        __strong typeof(self) strongSelf = weakSelf;
        
        // Remove operation reference
        [strongSelf.networkOperations removeObject:dataTask];
        
        [strongSelf handleSuccessfulTaskListResponseForTask:task
                                             responseObject:responseObject
                                            completionBlock:completionBlock];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        __strong typeof(self) strongSelf = weakSelf;
        
        // Remove operation reference
        [strongSelf.networkOperations removeObject:dataTask];
        
        [strongSelf handleFailedTaskListResponseForTask:task
                                                  error:error
                                        completionBlock:completionBlock];
    }];
    
    // Keep network operation reference to be able to cancel it
    [self.networkOperations addObject:dataTask];
}

- (void)fetchTaskDetailsForTaskID:(NSString *)taskID
                  completionBlock:(ASDKTaskDetailsCompletionBlock)completionBlock {
    // Check mandatory properties
    NSParameterAssert(taskID);
    NSParameterAssert(completionBlock);
    NSParameterAssert(self.resultsQueue);
    
    __weak typeof(self) weakSelf = self;
    __block NSURLSessionDataTask *dataTask =
    [self.requestOperationManager GET:[NSString stringWithFormat:[self.servicePathFactory taskDetailsServicePathFormat], taskID]
                           parameters:nil
                             progress:nil
                              success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        __strong typeof(self) strongSelf = weakSelf;
        
        // Remove operation reference
        [strongSelf.networkOperations removeObject:dataTask];
        
        NSDictionary *responseDictionary = (NSDictionary *)responseObject;
        ASDKLogVerbose(@"Task details fetched successfully for request: %@",
                       [task stateDescriptionForResponse:responseDictionary]);
        
        // Parse response data
        NSString *parserContentType = CREATE_STRING(ASDKTaskDetailsParserContentTypeTaskDetails);
        
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
        
        ASDKLogError(@"Failed to fetch task details for request: %@",
                     [task stateDescriptionForError:error]);
        
        dispatch_async(strongSelf.resultsQueue, ^{
            completionBlock(nil, error);
        });
    }];
    
    // Keep network operation reference to be able to cancel it
    [self.networkOperations addObject:dataTask];
}

- (void)fetchTaskContentForTaskID:(NSString *)taskID
                  completionBlock:(ASDKTaskContentCompletionBlock)completionBlock {
    // Check mandatory properties
    NSParameterAssert(taskID);
    NSParameterAssert(completionBlock);
    NSParameterAssert(self.resultsQueue);
    
    __weak typeof(self) weakSelf = self;
    __block NSURLSessionDataTask *dataTask =
    [self.requestOperationManager GET:[NSString stringWithFormat:[self.servicePathFactory taskContentServicePathFormat], taskID]
                           parameters:nil
                             progress:nil
                              success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        __strong typeof(self) strongSelf = weakSelf;
        
        // Remove operation reference
        [strongSelf.networkOperations removeObject:dataTask];
        
        NSDictionary *responseDictionary = (NSDictionary *)responseObject;
        ASDKLogVerbose(@"Task content fetched successfully for request: %@",
                       [task stateDescriptionForResponse:responseDictionary]);
        
        // Parse response data
        NSString *parserContentType = CREATE_STRING(ASDKTaskDetailsParserContentTypeContent);
        
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
        
        ASDKLogError(@"Failed to fetch task content for request: %@",
                     [task stateDescriptionForError:error]);
        
        dispatch_async(strongSelf.resultsQueue, ^{
            completionBlock(nil, error);
        });
    }];
    
    // Keep network operation reference to be able to cancel it
    [self.networkOperations addObject:dataTask];
}

- (void)fetchTaskCommentsForTaskID:(NSString *)taskID
                   completionBlock:(ASDKTaskCommentsCompletionBlock)completionBlock {
    // Check mandatory properties
    NSParameterAssert(taskID);
    NSParameterAssert(completionBlock);
    NSParameterAssert(self.resultsQueue);
    
    __weak typeof(self) weakSelf = self;
    __block NSURLSessionDataTask *dataTask =
    [self.requestOperationManager GET:[NSString stringWithFormat:[self.servicePathFactory taskCommentServicePathFormat], taskID]
                           parameters:nil
                             progress:nil
                              success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        __strong typeof(self) strongSelf = weakSelf;
        
        // Remove operation reference
        [strongSelf.networkOperations removeObject:dataTask];
        
        NSDictionary *responseDictionary = (NSDictionary *)responseObject;
        ASDKLogVerbose(@"Task comments fetched successfully for request: %@",
                       [task stateDescriptionForResponse:responseDictionary]);
        
        // Parse response data
        NSString *parserContentType = CREATE_STRING(ASDKTaskDetailsParserContentTypeComments);
        
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
        
        ASDKLogError(@"Failed to fetch task comments for request: %@",
                     [task stateDescriptionForError:error]);
        
        dispatch_async(strongSelf.resultsQueue, ^{
            completionBlock(nil, error, nil);
        });
    }];
    
    // Keep network operation reference to be able to cancel it
    [self.networkOperations addObject:dataTask];
}

- (void)createComment:(NSString *)comment
            forTaskID:(NSString *)taskID
      completionBlock:(ASDKTaskCreateCommentCompletionBlock)completionBlock {
    // Check mandatory properties
    NSParameterAssert(comment);
    NSParameterAssert(taskID);
    NSParameterAssert(completionBlock);
    NSParameterAssert(self.resultsQueue);
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(self.resultsQueue, ^{
        __strong typeof(self) strongSelf = weakSelf;
        
        __block NSURLSessionDataTask *dataTask =
        [strongSelf.requestOperationManager POST:[NSString stringWithFormat:[self.servicePathFactory taskCommentServicePathFormat], taskID]
                                      parameters:@{kASDKAPIMessageParameter : comment}
                                        progress:nil
                                         success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            // Remove operation reference
            [weakSelf.networkOperations removeObject:dataTask];
            
            NSDictionary *responseDictionary = (NSDictionary *)responseObject;
            ASDKLogVerbose(@"Comment created successfully for request: %@",
                           [task stateDescriptionForResponse:responseDictionary]);
            
            // Parse response data
            NSString *parserContentType = CREATE_STRING(ASDKTaskDetailsParserContentTypeComment);
            
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
            
            ASDKLogError(@"Failed to create task comment for request: %@",
                         [task stateDescriptionForError:error]);
            
            dispatch_async(weakSelf.resultsQueue, ^{
                completionBlock(nil, error);
            });
        }];
        
        // Keep network operation reference to be able to cancel it
        [strongSelf.networkOperations addObject:dataTask];
    });
}

- (void)updateTaskForTaskID:(NSString *)taskID
     withTaskRepresentation:(ASDKTaskUpdateRequestRepresentation *)taskRepresentation
            completionBlock:(ASDKTaskUpdateCompletionBlock)completionBlock {
    // Check mandatory properties
    NSParameterAssert(taskID);
    NSParameterAssert(completionBlock);
    NSParameterAssert(self.resultsQueue);
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(self.resultsQueue, ^{
        __strong typeof(self) strongSelf = weakSelf;
        
        __block NSURLSessionDataTask *dataTask =
        [strongSelf.requestOperationManager PUT:[NSString stringWithFormat:[self.servicePathFactory taskDetailsServicePathFormat], taskID]
                                     parameters:[taskRepresentation jsonDictionary]
                                        success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            // Remove operation reference
            [weakSelf.networkOperations removeObject:dataTask];
            
            NSInteger statusCode = [task statusCode];
            ASDKLogVerbose(@"The task details were updated successfully for request: %@",
                           [task stateDescriptionForResponse:[NSHTTPURLResponse localizedStringForStatusCode:statusCode]]);
            
            dispatch_async(weakSelf.resultsQueue, ^{
                completionBlock(YES, nil);
            });
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            // Remove operation reference
            [weakSelf.networkOperations removeObject:dataTask];
            
            ASDKLogError(@"Failed to update task details for request: %@",
                         [task stateDescriptionForError:error]);
            
            dispatch_async(weakSelf.resultsQueue, ^{
                completionBlock(NO, error);
            });
        }];
        
        // Keep network operation reference to be able to cancel it
        [strongSelf.networkOperations addObject:dataTask];
    });
}

- (void)completeTaskForTaskID:(NSString *)taskID
              completionBlock:(ASDKTaskCompleteCompletionBlock)completionBlock {
    // Check mandatory properties
    NSParameterAssert(taskID);
    NSParameterAssert(completionBlock);
    NSParameterAssert(self.resultsQueue);
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(self.resultsQueue, ^{
        __strong typeof(self) strongSelf = weakSelf;
        
        __block NSURLSessionDataTask *dataTask =
        [strongSelf.requestOperationManager PUT:[NSString stringWithFormat:[self.servicePathFactory taskActionCompleteServicePathFormat], taskID]
                                     parameters:nil
                                        success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            // Remove operation reference
            [weakSelf.networkOperations removeObject:dataTask];
            
            NSInteger statusCode = [task statusCode];
            ASDKLogVerbose(@"The task was marked as completed successfully for request: %@",
                           [task stateDescriptionForResponse:[NSHTTPURLResponse localizedStringForStatusCode:statusCode]]);
            
            dispatch_async(weakSelf.resultsQueue, ^{
                completionBlock(YES, nil);
            });
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            // Remove operation reference
            [weakSelf.networkOperations removeObject:dataTask];
            
            ASDKLogError(@"Failed to mark task as completed for request: %@",
                         [task stateDescriptionForError:error]);
            
            dispatch_async(weakSelf.resultsQueue, ^{
                completionBlock(NO, error);
            });
        }];
        
        // Keep network operation reference to be able to cancel it
        [strongSelf.networkOperations addObject:dataTask];
    });
}

- (void)uploadContentWithModel:(ASDKModelFileContent *)file
                     forTaskID:(NSString *)taskID
                 progressBlock:(ASDKTaskContentProgressBlock)progressBlock
               completionBlock:(ASDKTaskContentUploadCompletionBlock)completionBlock {
    // Check mandatory properties
    NSParameterAssert(file);
    NSParameterAssert(taskID);
    NSParameterAssert(completionBlock);
    NSParameterAssert(self.resultsQueue);
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(self.resultsQueue, ^{
        __strong typeof(self) strongSelf = weakSelf;
        
        __block NSURLSessionDataTask *dataTask =
        [strongSelf.requestOperationManager POST:[NSString stringWithFormat:[strongSelf.servicePathFactory taskContentUploadServicePathFormat], taskID]
                                      parameters:@{kASDKAPIIsRelatedContentParameter : @(YES)}
                       constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            NSError *error = nil;
            [formData appendPartWithFileURL:file.modelFileURL
                                       name:kASDKAPIContentUploadMultipartParameter
                                   fileName:file.fileName
                                   mimeType:file.mimeType
                                      error:&error];
            
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
            ASDKLogVerbose(@"Task content succesfully uploaded for request: %@",
                           [task stateDescriptionForResponse:responseDictionary]);
            
            // Parse response data
            NSString *parserContentType = CREATE_STRING(ASDKTaskDetailsParserContentTypeContent);
            [weakSelf.parserOperationManager parseContentDictionary:responseDictionary
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
            
            ASDKLogError(@"Failed to upload task content for request:%@",
                         [task stateDescriptionForError:error]);
            
            dispatch_async(weakSelf.resultsQueue, ^{
                completionBlock(nil, error);
            });
        }];
        
        // Keep network operation reference to be able to cancel it
        [strongSelf.networkOperations addObject:dataTask];
    });
}

- (void)uploadContentWithModel:(ASDKModelFileContent *)file
                   contentData:(NSData *)contentData
                     forTaskID:(NSString *)taskID
                 progressBlock:(ASDKTaskContentProgressBlock)progressBlock
               completionBlock:(ASDKTaskContentUploadCompletionBlock)completionBlock {
    // Check mandatory properties
    NSParameterAssert(file);
    NSParameterAssert(contentData);
    NSParameterAssert(taskID);
    NSParameterAssert(completionBlock);
    NSParameterAssert(self.resultsQueue);
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(self.resultsQueue, ^{
        __strong typeof(self) strongSelf = weakSelf;
        
        __block NSURLSessionDataTask *dataTask =
        [strongSelf.requestOperationManager POST:[NSString stringWithFormat:[strongSelf.servicePathFactory taskContentUploadServicePathFormat], taskID]
                                      parameters:@{kASDKAPIIsRelatedContentParameter : @(YES)}
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
                
                ASDKLogVerbose(@"Content: %@ for task with ID:%@ is %lu%% uploaded", file.modelFileURL, taskID, (unsigned long)percentProgress);
                
                dispatch_async(weakSelf.resultsQueue, ^{
                    progressBlock(percentProgress, nil);
                });
            }
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            // Remove operation reference
            [weakSelf.networkOperations removeObject:dataTask];
            
            NSDictionary *responseDictionary = (NSDictionary *)responseObject;
            ASDKLogVerbose(@"Task content succesfully uploaded for request: %@",
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
                    dispatch_async(weakSelf.resultsQueue, ^{
                        completionBlock(parsedObject, nil);
                    });
                }
            }];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            // Remove operation reference
            [weakSelf.networkOperations removeObject:dataTask];
            
            ASDKLogError(@"Failed to upload task content for request: %@",
                         [task stateDescriptionForError:error]);
            
            dispatch_async(weakSelf.resultsQueue, ^{
                completionBlock(nil, error);
            });
        }];
        
        // Keep network operation reference to be able to cancel it
        [strongSelf.networkOperations addObject:dataTask];
    });
}

- (void)deleteContent:(ASDKModelContent *)content
      completionBlock:(ASDKTaskContentDeletionCompletionBlock)completionBlock {
    // Check mandatory properties
    NSParameterAssert(content);
    NSParameterAssert(completionBlock);
    NSParameterAssert(self.resultsQueue);
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(self.resultsQueue, ^{
        __strong typeof(self) strongSelf = weakSelf;
        
        __block NSURLSessionDataTask *dataTask =
        [strongSelf.requestOperationManager DELETE:[NSString stringWithFormat:[strongSelf.servicePathFactory contentServicePathFormat], content.modelID]
                                        parameters:nil
                                           success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            // Remove operation reference
            [weakSelf.networkOperations removeObject:dataTask];
            
            NSInteger statusCode = [task statusCode];
            ASDKLogVerbose(@"The task content was successfully deleted with request: %@",
                           [task stateDescriptionForResponse:[NSHTTPURLResponse localizedStringForStatusCode:statusCode]]);
            
            dispatch_async(weakSelf.resultsQueue, ^{
                completionBlock(YES, nil);
            });
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            // Remove operation reference
            [weakSelf.networkOperations removeObject:dataTask];
            
            ASDKLogError(@"Failed to delete content for task with request: %@",
                         [task stateDescriptionForError:error]);
            
            dispatch_async(weakSelf.resultsQueue, ^{
                completionBlock(NO, error);
            });
        }];
        
        // Keep network operation reference to be able to cancel it
        [strongSelf.networkOperations addObject:dataTask];
    });
}

- (void)downloadContent:(ASDKModelContent *)content
     allowCachedResults:(BOOL)allowCachedResults
          progressBlock:(ASDKTaskContentDownloadProgressBlock)progressBlock
        completionBlock:(ASDKTaskContentDownloadCompletionBlock)completionBlock {
    // Check mandatory properties
    NSParameterAssert(content);
    NSParameterAssert(completionBlock);
    NSParameterAssert(self.resultsQueue);
    
    NSString *downloadPathForContent = [self.diskServices downloadPathForContent:content];
    
    // If content already exists and the caller is expecting cached results return the resource URL
    if (allowCachedResults && [self.diskServices doesFileAlreadyExistsForContent:content]) {
        ASDKLogVerbose(@"Didn't performed content request. Providing cached result for content with ID: %@", content.modelID);
        dispatch_async(self.resultsQueue, ^{
            NSURL *downloadURL = [NSURL fileURLWithPath:downloadPathForContent];
            completionBlock(downloadURL, YES, nil);
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
                NSInteger statusCode = ((NSHTTPURLResponse *)response).statusCode;
                ASDKLogVerbose(@"The task content was successfully downloaded with request: %@",
                               [downloadTask stateDescriptionForResponse:[NSHTTPURLResponse localizedStringForStatusCode:statusCode]]);
                
                dispatch_async(weakSelf.resultsQueue, ^{
                    NSURL *downloadURL = [NSURL fileURLWithPath:downloadPathForContent];
                    completionBlock(downloadURL, NO, nil);
                });
            } else {
                ASDKLogError(@"Failed to download content for task with request: %@ - %@.\nBody:%@.\nReason:%@",
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
                NSString *formattedSize = [weakSelf.diskServices sizeStringForByteCount:totalBytesWritten];
                ASDKLogVerbose(@"Downloaded %@ of content with ID:%@ ", formattedSize, content.modelID);
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

- (void)downloadThumbnailForContent:(ASDKModelContent *)content
                 allowCachedResults:(BOOL)allowCachedResults
                      progressBlock:(ASDKTaskContentDownloadProgressBlock)progressBlock
                    completionBlock:(ASDKTaskContentDownloadCompletionBlock)completionBlock {
    // Check mandatory properties
    NSParameterAssert(content);
    NSParameterAssert(completionBlock);
    NSParameterAssert(self.resultsQueue);
    
    NSString *downloadPathForThumbnail = [self.diskServices downloadPathForContentThumbnail:content];
    
    // If content already exists and the caller is expecting cached results return the resource URL
    if (allowCachedResults && [self.diskServices doesThumbnailAlreadyExistsForContent:content]) {
        ASDKLogVerbose(@"Didn't performed content request. Providing cached thumbnail result for content with ID: %@", content.modelID);
        dispatch_async(self.resultsQueue, ^{
            NSURL *downloadURL = [NSURL fileURLWithPath:downloadPathForThumbnail];
            completionBlock(downloadURL, YES, nil);
        });
        
        return;
    }
    
    NSString *urlString = [[NSURL URLWithString:[NSString stringWithFormat:[self.servicePathFactory taskContentThumbnailServicePathFormat], content.modelID] relativeToURL:self.requestOperationManager.baseURL] absoluteString];
    NSError *downloadRequestError = nil;
    NSURLRequest *downloadRequest =
    [self.requestOperationManager.requestSerializer requestWithMethod:@"GET"
                                                            URLString:urlString
                                                           parameters:nil
                                                                error:&downloadRequestError];
    
    if (downloadRequestError) {
        ASDKLogError(@"Cannot create request to download content thumbnail. Reason:%@", downloadRequestError.localizedDescription);
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
            return [NSURL fileURLWithPath:downloadPathForThumbnail];
        } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
            // Remove operation reference
            [weakSelf.networkOperations removeObject:downloadTask];
            
            if (!error) {
                NSInteger statusCode = ((NSHTTPURLResponse *)response).statusCode;
                ASDKLogVerbose(@"The task content thumbnail was successfully downloaded with request: %@",
                               [downloadTask stateDescriptionForResponse:[NSHTTPURLResponse localizedStringForStatusCode:statusCode]]);
                
                dispatch_async(weakSelf.resultsQueue, ^{
                    NSURL *downloadURL = [NSURL fileURLWithPath:downloadPathForThumbnail];
                    completionBlock(downloadURL, NO, nil);
                });
            } else {
                ASDKLogError(@"Failed to download content thumbnail for task with request: %@ - %@.\nBody:%@.\nReason:%@",
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

- (void)involveUserWithID:(NSString *)userID
                forTaskID:(NSString *)taskID
          completionBlock:(ASDKTaskUserInvolvementCompletionBlock)completionBlock {
    NSParameterAssert(userID);
    NSParameterAssert(taskID);
    NSParameterAssert(completionBlock);
    NSParameterAssert(self.resultsQueue);
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(self.resultsQueue, ^{
        __strong typeof(self) strongSelf = weakSelf;
        
        __block NSURLSessionDataTask *dataTask =
        [strongSelf.requestOperationManager PUT:[NSString stringWithFormat:[strongSelf.servicePathFactory taskUserInvolveServicePathFormat], taskID]
                                     parameters:@{kASDKAPIUserIdParameter : userID}
                                        success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            // Remove operation reference
            [weakSelf.networkOperations removeObject:dataTask];
            
            [weakSelf handleSuccessfulTaskUserInvolvementResponseForTask:task
                                                       isRemoveOperation:NO
                                                         completionBlock:completionBlock];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            // Remove operation reference
            [weakSelf.networkOperations removeObject:dataTask];
            
            [weakSelf handleFailedTaskUserInvolveResponseForTask:task
                                                           error:error
                                               isRemoveOperation:NO
                                                 completionBlock:completionBlock];
        }];
        
        // Keep network operation reference to be able to cancel it
        [strongSelf.networkOperations addObject:dataTask];
    });
}

- (void)involveUserWithEmailAddress:(NSString *)userEmailAddress
                          forTaskID:(NSString *)taskID
                    completionBlock:(ASDKTaskUserInvolvementCompletionBlock)completionBlock {
    NSParameterAssert(userEmailAddress);
    NSParameterAssert(taskID);
    NSParameterAssert(completionBlock);
    NSParameterAssert(self.resultsQueue);
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(self.resultsQueue, ^{
        __strong typeof(self) strongSelf = weakSelf;
        
        __block NSURLSessionDataTask *dataTask =
        [strongSelf.requestOperationManager PUT:[NSString stringWithFormat:[strongSelf.servicePathFactory taskUserInvolveServicePathFormat], taskID]
                                     parameters:@{kASDKAPIEmailParameter : userEmailAddress}
                                        success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            // Remove operation reference
            [weakSelf.networkOperations removeObject:dataTask];
            
            [weakSelf handleSuccessfulTaskUserInvolvementResponseForTask:task
                                                       isRemoveOperation:NO
                                                         completionBlock:completionBlock];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            // Remove operation reference
            [weakSelf.networkOperations removeObject:dataTask];
            
            [weakSelf handleFailedTaskUserInvolveResponseForTask:task
                                                           error:error
                                               isRemoveOperation:NO
                                                 completionBlock:completionBlock];
        }];
        
        // Keep network operation reference to be able to cancel it
        [strongSelf.networkOperations addObject:dataTask];
    });
}

- (void)removeInvolvedUserWithID:(NSString *)userID
                       forTaskID:(NSString *)taskID
                 completionBlock:(ASDKTaskUserInvolvementCompletionBlock)completionBlock {
    NSParameterAssert(userID);
    NSParameterAssert(taskID);
    NSParameterAssert(completionBlock);
    NSParameterAssert(self.resultsQueue);
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(self.resultsQueue, ^{
        __strong typeof(self) strongSelf = weakSelf;
        
        __block NSURLSessionDataTask *dataTask =
        [strongSelf.requestOperationManager PUT:[NSString stringWithFormat:[strongSelf.servicePathFactory taskUserRemoveInvolvedServicePathFormat], taskID]
                                     parameters:@{kASDKAPIUserIdParameter : userID}
                                        success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            // Remove operation reference
            [weakSelf.networkOperations removeObject:dataTask];
            
            [weakSelf handleSuccessfulTaskUserInvolvementResponseForTask:task
                                                       isRemoveOperation:YES
                                                         completionBlock:completionBlock];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            // Remove operation reference
            [weakSelf.networkOperations removeObject:dataTask];
            
            [weakSelf handleFailedTaskUserInvolveResponseForTask:task
                                                           error:error
                                               isRemoveOperation:YES
                                                 completionBlock:completionBlock];
        }];
        
        // Keep network operation reference to be able to cancel it
        [strongSelf.networkOperations addObject:dataTask];
    });
}

- (void)removeInvolvedUserWithEmailAddress:(NSString *)userEmailAddress
                                 forTaskID:(NSString *)taskID
                           completionBlock:(ASDKTaskUserInvolvementCompletionBlock)completionBlock {
    NSParameterAssert(userEmailAddress);
    NSParameterAssert(taskID);
    NSParameterAssert(completionBlock);
    NSParameterAssert(self.resultsQueue);
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(self.resultsQueue, ^{
        __strong typeof(self) strongSelf = weakSelf;
        
        __block NSURLSessionDataTask *dataTask =
        [strongSelf.requestOperationManager PUT:[NSString stringWithFormat:[strongSelf.servicePathFactory taskUserRemoveInvolvedServicePathFormat], taskID]
                                     parameters:@{kASDKAPIEmailParameter : userEmailAddress}
                                        success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            // Remove operation reference
            [weakSelf.networkOperations removeObject:dataTask];
            
            [weakSelf handleSuccessfulTaskUserInvolvementResponseForTask:task
                                                       isRemoveOperation:YES
                                                         completionBlock:completionBlock];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            // Remove operation reference
            [weakSelf.networkOperations removeObject:dataTask];
            
            [weakSelf handleFailedTaskUserInvolveResponseForTask:task
                                                           error:error
                                               isRemoveOperation:YES
                                                 completionBlock:completionBlock];
        }];
        
        // Keep network operation reference to be able to cancel it
        [strongSelf.networkOperations addObject:dataTask];
    });
}

- (void)createTaskWithRepresentation:(ASDKTaskCreationRequestRepresentation *)taskRepresentation
                     completionBlock:(ASDKTaskDetailsCompletionBlock)completionBlock {
    // Check mandatory properties
    NSParameterAssert(taskRepresentation);
    NSParameterAssert(completionBlock);
    NSParameterAssert(self.resultsQueue);
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(self.resultsQueue, ^{
        __strong typeof(self) strongSelf = weakSelf;
        
        __block NSURLSessionDataTask *dataTask =
        [strongSelf.requestOperationManager
         POST:[strongSelf.servicePathFactory taskCreationServicePath]
         parameters:[taskRepresentation jsonDictionary]
         progress:nil
         success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            // Remove operation reference
            [weakSelf.networkOperations removeObject:dataTask];
            
            [weakSelf handleSuccessfulTaskCreationResponseForTask:task
                                                   responseObject:responseObject
                                                  completionBlock:completionBlock];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            // Remove operation reference
            [weakSelf.networkOperations removeObject:dataTask];
            
            [weakSelf handleFailedTaskCreationResponseForTask:task
                                                        error:error
                                              completionBlock:completionBlock];
        }];
        
        // Keep network operation reference to be able to cancel it
        [strongSelf.networkOperations addObject:dataTask];
    });
}

- (void)claimTaskWithID:(NSString *)taskID
        completionBlock:(ASDKTaskClaimCompletionBlock)completionBlock {
    NSParameterAssert(taskID);
    NSParameterAssert(completionBlock);
    NSParameterAssert(self.resultsQueue);
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(self.resultsQueue, ^{
        __strong typeof(self) strongSelf = weakSelf;
        
        __block NSURLSessionDataTask *dataTask =
        [strongSelf.requestOperationManager PUT:[NSString stringWithFormat:[strongSelf.servicePathFactory taskClaimServicePathFormat], taskID]
                                     parameters:nil
                                        success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            // Remove operation reference
            [weakSelf.networkOperations removeObject:dataTask];
            
            NSInteger statusCode = [task statusCode];
            ASDKLogVerbose(@"The task has been successfully claimed with request: %@",
                           [task stateDescriptionForResponse:[NSHTTPURLResponse localizedStringForStatusCode:statusCode]]);
            
            dispatch_async(weakSelf.resultsQueue, ^{
                completionBlock(YES, nil);
            });
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            // Remove operation reference
            [weakSelf.networkOperations removeObject:dataTask];
            
            ASDKLogError(@"Failed to claim task with request: %@",
                         [task stateDescriptionForError:error]);
            
            dispatch_async(weakSelf.resultsQueue, ^{
                completionBlock(NO, error);
            });
        }];
        
        // Keep network operation reference to be able to cancel it
        [strongSelf.networkOperations addObject:dataTask];
    });
}

- (void)unclaimTaskWithID:(NSString *)taskID
          completionBlock:(ASDKTaskClaimCompletionBlock)completionBlock {
    NSParameterAssert(taskID);
    NSParameterAssert(completionBlock);
    NSParameterAssert(self.resultsQueue);
    
    __weak typeof(self) weakSelf = self;
    
    dispatch_async(self.resultsQueue, ^{
        __strong typeof(self) strongSelf = weakSelf;
        
        __block NSURLSessionDataTask *dataTask =
        [strongSelf.requestOperationManager PUT:[NSString stringWithFormat:[strongSelf.servicePathFactory taskUnclaimServicePathFormat], taskID]
                                     parameters:nil
                                        success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            // Remove operation reference
            [weakSelf.networkOperations removeObject:dataTask];
            
            NSInteger statusCode = [task statusCode];
            ASDKLogVerbose(@"The task has been successfully unclaimed with request: %@",
                           [task stateDescriptionForResponse:[NSHTTPURLResponse localizedStringForStatusCode:statusCode]]);
            
            dispatch_async(weakSelf.resultsQueue, ^{
                completionBlock(NO, nil);
            });
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            // Remove operation reference
            [weakSelf.networkOperations removeObject:dataTask];
            
            ASDKLogError(@"Failed to unclaim task with request: %@",
                         [task stateDescriptionForError:error]);
            
            dispatch_async(weakSelf.resultsQueue, ^{
                completionBlock(YES, error);
            });
        }];
        
        // Keep network operation reference to be able to cancel it
        [strongSelf.networkOperations addObject:dataTask];
    });
}

- (void)assignTaskWithID:(NSString *)taskID
                  toUser:(ASDKModelUser *)user
         completionBlock:(ASDKTaskDetailsCompletionBlock)completionBlock {
    // Check mandatory properties
    NSParameterAssert(taskID);
    NSParameterAssert(user);
    NSParameterAssert(completionBlock);
    NSParameterAssert(self.resultsQueue);
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(self.resultsQueue, ^{
        __strong typeof(self) strongSelf = weakSelf;
        
        __block NSURLSessionDataTask *dataTask =
        [strongSelf.requestOperationManager PUT:[NSString stringWithFormat:[strongSelf.servicePathFactory taskAssignServicePathFormat], taskID]
                                     parameters:@{kASDKAPIAssigneeParameter: user.modelID}
                                        success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            // Remove operation reference
            [weakSelf.networkOperations removeObject:dataTask];
            
            NSDictionary *responseDictionary = (NSDictionary *)responseObject;
            ASDKLogVerbose(@"Task assigned successfully for request: %@",
                           [task stateDescriptionForResponse:responseDictionary]);
            
            // Parse response data
            NSString *parserContentType = CREATE_STRING(ASDKTaskDetailsParserContentTypeTaskDetails);
            
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
            
            ASDKLogError(@"Failed to assign task for request: %@",
                         [task stateDescriptionForError:error]);
            
            dispatch_async(weakSelf.resultsQueue, ^{
                completionBlock(nil, error);
            });
        }];
        
        // Keep network operation reference to be able to cancel it
        [strongSelf.networkOperations addObject:dataTask];
    });
}

- (void)downloadAuditLogForTaskWithID:(NSString *)taskID
                   allowCachedResults:(BOOL)allowCachedResults
                        progressBlock:(ASDKTaskContentDownloadProgressBlock)progressBlock
                      completionBlock:(ASDKTaskContentDownloadCompletionBlock)completionBlock {
    // Check mandatory properties
    NSParameterAssert(taskID);
    NSParameterAssert(completionBlock);
    NSParameterAssert(self.resultsQueue);
    
    // If content already exists and the caller is expecting cached results return the resource URL
    NSString *auditLogFileName = [NSString stringWithFormat:kASDKAuditLogFilenameFormat, taskID];
    NSString *downloadPathForContent = [self.diskServices downloadPathForResourceWithIdentifier:taskID
                                                                                       filename:auditLogFileName];
    if (allowCachedResults && [self.diskServices doesFileAlreadyExistsForResouceWithIdentifier:taskID
                                                                                      filename:auditLogFileName]) {
        ASDKLogVerbose(@"Didn't performed content request. Providing cached result for audit log content of task with ID: %@", taskID);
        dispatch_async(self.resultsQueue, ^{
            NSURL *downloadURL = [NSURL fileURLWithPath:downloadPathForContent];
            completionBlock(downloadURL, YES, nil);
        });
        
        return;
    }
    
    NSString *urlString = [[NSURL URLWithString:[NSString stringWithFormat:[self.servicePathFactory taskAuditLogServicePathFormat], taskID] relativeToURL:self.requestOperationManager.baseURL] absoluteString];
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
                NSInteger statusCode = ((NSHTTPURLResponse *)response).statusCode;
                ASDKLogVerbose(@"The audit log content was successfully downloaded with request: %@",
                               [downloadTask stateDescriptionForResponse:[NSHTTPURLResponse localizedStringForStatusCode:statusCode]]);
                
                dispatch_async(weakSelf.resultsQueue, ^{
                    NSURL *downloadURL = [NSURL fileURLWithPath:downloadPathForContent];
                    completionBlock(downloadURL, NO, nil);
                });
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

- (void)fetchChecklistForTaskWithID:(NSString *)taskID
                    completionBlock:(ASDKTaskListCompletionBlock)completionBlock {
    // Check mandatory properties
    NSParameterAssert(taskID);
    NSParameterAssert(completionBlock);
    NSParameterAssert(self.resultsQueue);
    
    __weak typeof(self) weakSelf = self;
    __block NSURLSessionDataTask *dataTask =
    [self.requestOperationManager GET:[NSString stringWithFormat:[self.servicePathFactory taskCheckListServicePathFormat], taskID]
                           parameters:nil
                             progress:nil
                              success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        __strong typeof(self) strongSelf = weakSelf;
        
        // Remove operation reference
        [strongSelf.networkOperations removeObject:dataTask];
        
        [strongSelf handleSuccessfulTaskListResponseForTask:dataTask
                                             responseObject:responseObject
                                            completionBlock:completionBlock];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        __strong typeof(self) strongSelf = weakSelf;
        
        // Remove operation reference
        [strongSelf.networkOperations removeObject:dataTask];
        
        [strongSelf handleFailedTaskListResponseForTask:dataTask
                                                  error:error
                                        completionBlock:completionBlock];
    }];
    
    // Keep network operation reference to be able to cancel it
    [self.networkOperations addObject:dataTask];
}

- (void)createChecklistWithRepresentation:(ASDKTaskCreationRequestRepresentation *)checklistRepresentation
                                   taskID:(NSString *)taskID
                          completionBlock:(ASDKTaskDetailsCompletionBlock)completionBlock; {
    NSParameterAssert(checklistRepresentation);
    NSParameterAssert(completionBlock);
    NSParameterAssert(self.resultsQueue);
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(self.resultsQueue, ^{
        __strong typeof(self) strongSelf = weakSelf;
        
        __block NSURLSessionDataTask *dataTask =
        [strongSelf.requestOperationManager POST:[NSString stringWithFormat:[strongSelf.servicePathFactory taskCheckListServicePathFormat], taskID]
                                      parameters:[checklistRepresentation jsonDictionary]
                                        progress:nil
                                         success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            // Remove operation reference
            [weakSelf.networkOperations removeObject:dataTask];
            
            [weakSelf handleSuccessfulTaskCreationResponseForTask:dataTask
                                                   responseObject:responseObject
                                                  completionBlock:completionBlock];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            // Remove operation reference
            [weakSelf.networkOperations removeObject:dataTask];
            
            [weakSelf handleFailedTaskCreationResponseForTask:dataTask
                                                        error:error
                                              completionBlock:completionBlock];
        }];
        
        // Keep network operation reference to be able to cancel it
        [strongSelf.networkOperations addObject:dataTask];
    });
}

- (void)updateChecklistOrderWithRepresentation:(ASDKTaskChecklistOrderRequestRepresentation *)orderRepresentation
                                        taskID:(NSString *)taskID
                               completionBlock:(ASDKTaskUpdateCompletionBlock)completionBlock {
    NSParameterAssert(orderRepresentation);
    NSParameterAssert(taskID);
    NSParameterAssert(completionBlock);
    
    __weak typeof(self) weakSelf = self;
    
    dispatch_async(self.resultsQueue, ^{
        __strong typeof(self) strongSelf = weakSelf;
        
        __block NSURLSessionDataTask *dataTask =
        [strongSelf.requestOperationManager PUT:[NSString stringWithFormat:[strongSelf.servicePathFactory taskCheckListServicePathFormat], taskID]
                                     parameters:[orderRepresentation jsonDictionary]
                                        success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            // Remove operation reference
            [weakSelf.networkOperations removeObject:dataTask];
            
            NSInteger statusCode = [task statusCode];
            ASDKLogVerbose(@"The checklist order was updated successfully for request: %@",
                           [task stateDescriptionForResponse:[NSHTTPURLResponse localizedStringForStatusCode:statusCode]]);
            
            dispatch_async(weakSelf.resultsQueue, ^{
                completionBlock(YES, nil);
            });
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            // Remove operation reference
            [weakSelf.networkOperations removeObject:dataTask];
            
            ASDKLogError(@"Failed to update checklist order for request: %@",
                         [task stateDescriptionForError:error]);
            
            dispatch_async(weakSelf.resultsQueue, ^{
                completionBlock(NO, error);
            });
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

- (void)handleSuccessfulTaskListResponseForTask:(NSURLSessionDataTask *)task
                                 responseObject:(id)responseObject
                                completionBlock:(ASDKTaskListCompletionBlock)completionBlock {
    NSDictionary *responseDictionary = (NSDictionary *)responseObject;
    ASDKLogVerbose(@"Task list fetched successfully for request: %@",
                   [task stateDescriptionForResponse:responseDictionary]);
    
    // Parse response data
    NSString *parserContentType = CREATE_STRING(ASDKTaskDetailsParserContentTypeTaskList);
    
    __weak typeof(self) weakSelf = self;
    [self.parserOperationManager parseContentDictionary:responseDictionary
                                                 ofType:parserContentType
                                    withCompletionBlock:^(id parsedObject, NSError *error, ASDKModelPaging *paging) {
        __strong typeof(self) strongSelf = weakSelf;
        if (error) {
            ASDKLogError(kASDKAPIParserManagerConversionErrorFormat, parserContentType, error.localizedDescription);
            dispatch_async(strongSelf.resultsQueue, ^{
                completionBlock(nil, error, nil);
            });
        } else {
            ASDKLogVerbose(kASDKAPIParserManagerConversionFormat, parserContentType, parsedObject);
            dispatch_async(strongSelf.resultsQueue, ^{
                completionBlock(parsedObject, nil, paging);
            });
        }
    }];
}

- (void)handleSuccessfulTaskCreationResponseForTask:(NSURLSessionDataTask *)task
                                     responseObject:(id)responseObject
                                    completionBlock:(ASDKTaskDetailsCompletionBlock)completionBlock {
    NSDictionary *responseDictionary = (NSDictionary *)responseObject;
    ASDKLogVerbose(@"Task created successfully for request: %@",
                   [task stateDescriptionForResponse:responseDictionary]);
    
    
    // Parse response data
    NSString *parserContentType = CREATE_STRING(ASDKTaskDetailsParserContentTypeTaskDetails);
    
    __weak typeof(self) weakSelf = self;
    [self.parserOperationManager parseContentDictionary:responseDictionary
                                                 ofType:parserContentType
                                    withCompletionBlock:^(id parsedObject, NSError *error, ASDKModelPaging *paging) {
        __strong typeof(self) strongSelf = weakSelf;
        if (error) {
            ASDKLogError(kASDKAPIParserManagerConversionErrorFormat, parserContentType, error.localizedDescription);
            dispatch_async(strongSelf.resultsQueue, ^{
                completionBlock(nil, error);
            });
        } else {
            ASDKLogVerbose(kASDKAPIParserManagerConversionFormat, parserContentType, parsedObject);
            dispatch_async(strongSelf.resultsQueue, ^{
                completionBlock(parsedObject, nil);
            });
        }
    }];
}

- (void)handleSuccessfulTaskUserInvolvementResponseForTask:(NSURLSessionTask *)task
                                         isRemoveOperation:(BOOL)isRemoveOperation
                                           completionBlock:(ASDKTaskUserInvolvementCompletionBlock)completionBlock {
    NSInteger statusCode = [task statusCode];
    if (isRemoveOperation) {
        ASDKLogVerbose(@"The user's involvement was successfully removed for request: %@",
                       [task stateDescriptionForResponse:[NSHTTPURLResponse localizedStringForStatusCode:statusCode]]);
        dispatch_async(self.resultsQueue, ^{
            completionBlock(NO, nil);
        });
    } else {
        ASDKLogVerbose(@"The user was successfully involved for request: %@",
                       [task stateDescriptionForResponse:[NSHTTPURLResponse localizedStringForStatusCode:statusCode]]);
        dispatch_async(self.resultsQueue, ^{
            completionBlock(YES, nil);
        });
    }
}

- (void)handleFailedTaskListResponseForTask:(NSURLSessionDataTask *)task
                                      error:(NSError *)error
                            completionBlock:(ASDKTaskListCompletionBlock)completionBlock {
    ASDKLogError(@"Operation failed for request: %@",
                 [task stateDescriptionForError:error]);
    
    dispatch_async(self.resultsQueue, ^{
        completionBlock(nil, error, nil);
    });
}

- (void)handleFailedTaskCreationResponseForTask:(NSURLSessionDataTask *)task
                                          error:(NSError *)error
                                completionBlock:(ASDKTaskDetailsCompletionBlock)completionBlock {
    ASDKLogError(@"Failed to create task for request: %@",
                 [task stateDescriptionForError:error]);
    
    dispatch_async(self.resultsQueue, ^{
        completionBlock(nil, error);
    });
}

- (void)handleFailedTaskUserInvolveResponseForTask:(NSURLSessionDataTask *)task
                                             error:(NSError *)error
                                 isRemoveOperation:(BOOL)isRemoveOperation
                                   completionBlock:(ASDKTaskUserInvolvementCompletionBlock)completionBlock {
    if (isRemoveOperation) {
        ASDKLogError(@"Failed to remove involvement user for request: %@",
                     [task stateDescriptionForError:error]);
        
        dispatch_async(self.resultsQueue, ^{
            completionBlock(YES, error);
        });
    } else {
        ASDKLogError(@"Failed to involve user for request: %@",
                     [task stateDescriptionForError:error]);
        
        dispatch_async(self.resultsQueue, ^{
            completionBlock(NO, error);
        });
    }
}

@end

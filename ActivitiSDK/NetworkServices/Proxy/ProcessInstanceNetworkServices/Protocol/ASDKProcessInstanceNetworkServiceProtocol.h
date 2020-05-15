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

#import <Foundation/Foundation.h>

@class ASDKModelPaging,
ASDKFilterRequestRepresentation,
ASDKStartProcessRequestRepresentation,
ASDKModelProcessInstance,
ASDKModelComment;

typedef void  (^ASDKProcessInstanceListCompletionBlock)          (NSArray *processes, NSError *error, ASDKModelPaging *paging);
typedef void  (^ASDKProcessInstanceCompletionBlock)              (ASDKModelProcessInstance *processInstance, NSError *error);
typedef void  (^ASDKProcessInstanceContentCompletionBlock)       (NSArray *contentList, NSError *error);
typedef void  (^ASDKProcessInstanceCreateCommentCompletionBlock) (ASDKModelComment *comment, NSError *error);
typedef void  (^ASDKProcessInstanceCommentsCompletionBlock)      (NSArray *commentList, NSError *error, ASDKModelPaging *paging);
typedef void  (^ASDKProcessInstanceDeleteCompletionBlock)        (BOOL isProcessInstanceDeleted, NSError *error);
typedef void  (^ASDKProcessInstanceContentDownloadProgressBlock) (NSString *formattedReceivedBytesString, NSError *error);
typedef void  (^ASDKProcessInstanceContentDownloadCompletionBlock)(NSURL *downloadedContentURL, BOOL isLocalContent, NSError *error);

@protocol ASDKProcessInstanceNetworkServiceProtocol <NSObject>

/**
 *  Fetches and returns via the completion block a list of process instances, that conforms
 *  to the properties of a filter object.
 *
 *  @param filter          Filter object describing how the process instances list should be
 *                         filtered
 *  @param completionBlock Completion block providing a process instance list, an optional
 *                         error reason and paging information
 */
- (void)fetchProcessInstanceListWithFilterRepresentation:(ASDKFilterRequestRepresentation *)filter
                                         completionBlock:(ASDKProcessInstanceListCompletionBlock)completionBlock;

/**
 *  Starts a process instance and returns it via the completion block
 *
 *  @param request             Request object containing the process definition id, name and optional start form data
 *  @param completionBlock     Completion block providing the started process instance and an optional
 *                             error reason
 */
- (void)startProcessInstanceWithStartProcessRequestRepresentation:(ASDKStartProcessRequestRepresentation *)request
                                                  completionBlock:(ASDKProcessInstanceCompletionBlock)completionBlock;

/**
 *  Fetches and returns via the completion block the process instance details for a provided process instance ID
 *
 *  @param processInstanceID The process instance ID for which the process instance details are fetched
 */
- (void)fetchProcessInstanceDetailsForID:(NSString *)processInstanceID
                         completionBlock:(ASDKProcessInstanceCompletionBlock)completionBlock;

/**
 *  Fetches and returns via the provided completion block a ASDKModelProcessInstanceContent object list that contains
 *  a description of the attached content for the given process instance ID.
 *
 *  @param processInstanceID    ID of the process instance for which the content is requested
 *  @param completionBlock      Completion block providing the content object list and an optional error reason
 */
- (void)fetchProcesInstanceContentForProcessInstanceID:(NSString *)processInstanceID
                                       completionBlock:(ASDKProcessInstanceContentCompletionBlock)completionBlock;

/**
 *  Fetches and returns via the provided completion block a list of ASDKModelComment objects describing
 *  comments made by other users on the mentioned process instance.
 *
 *  @param processInstanceID    ID of the process instance for which the comments list is requested
 *  @param completionBlock      Completion block providing the comments list, an optional error reason and
 *                              pagination information
 */
- (void)fetchProcessInstanceCommentsForProcessInstanceID:(NSString *)processInstanceID
                                         completionBlock:(ASDKProcessInstanceCommentsCompletionBlock)completionBlock;

/**
 *  Creates and returns a comment for a mentioned process instance ID via the provided completion block
 *
 *  @param comment         The body of the content
 *  @param taskID          ID of the process instance for which the comment is created
 *  @param completionBlock Completion block providing a created comment and an optional error reason
 */
- (void)createComment:(NSString *)comment
 forProcessInstanceID:(NSString *)processInstanceID
      completionBlock:(ASDKProcessInstanceCreateCommentCompletionBlock)completionBlock;

/**
 *  Deletes a process instance given a process instance ID and reports back via a completion block the status of 
 *  the operation
 *
 *  @param processInstanceID ID of the process instance to be deleted
 *  @param completionBlock   Completion block providing the status of the delete operation and an optional error reason
 */
- (void)deleteProcessInstanceWithID:(NSString *)processInstanceID
                    completionBlock:(ASDKProcessInstanceDeleteCompletionBlock)completionBlock;

/**
 *  Downloads the audit log for the mentioned process instance and reports back via completion and progress blocks the
 *  status of the download, whether the operation was successfull and optional errors that might have occured
 *
 *  @param processInstanceID    ID of the process instance for which the audit log is requested
 *  @param allowCachedResults   Boolean value specifying if results can be provided if already present on the disk
 *  @param progressBlock        Block providing information on the download progress and an optional error reason
 *  @param completionBlock      Completion block providing an URL to the downloaded resource, whether the content is
 *                              provided from the local source and an optional error reason.
 */
- (void)downloadAuditLogForProcessInstanceWithID:(NSString *)processInstanceID
                              allowCachedResults:(BOOL)allowCachedResults
                                   progressBlock:(ASDKProcessInstanceContentDownloadProgressBlock)progressBlock
                                 completionBlock:(ASDKProcessInstanceContentDownloadCompletionBlock)completionBlock;

/**
 *  Cancells all queued or running network operations
 */
- (void)cancelAllTaskNetworkOperations;

@end

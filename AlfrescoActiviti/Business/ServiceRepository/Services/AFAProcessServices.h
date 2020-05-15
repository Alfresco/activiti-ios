/*******************************************************************************
 * Copyright (C) 2005-2020 Alfresco Software Limited.
 *
 * This file is part of the Alfresco Activiti Mobile iOS App.
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

@class AFAGenericFilterModel,
ASDKModelPaging,
ASDKModelProcessInstance,
ASDKModelProcessDefinition,
ASDKModelComment;

typedef void  (^AFAProcessServiceProcessInstanceListCompletionBlock) (NSArray *processInstanceList, NSError *error, ASDKModelPaging *paging);
typedef void  (^AFAProcessDefinitionListCompletionBlock)        (NSArray *processDefinitions, NSError *error, ASDKModelPaging *paging);
typedef void  (^AFAProcessInstanceCompletionBlock)              (ASDKModelProcessInstance *processInstance, NSError *error);
typedef void  (^AFAProcessInstanceContentCompletionBlock)       (NSArray *contentList, NSError *error);
typedef void  (^AFAProcessInstanceCreateCommentCompletionBlock) (ASDKModelComment *comment, NSError *error);
typedef void  (^AFAProcessInstanceCommentsCompletionBlock)      (NSArray *commentList, NSError *error, ASDKModelPaging *paging);
typedef void  (^AFAProcessInstanceDeleteCompletionBlock)        (BOOL isProcessInstanceDeleted, NSError *error);
typedef void  (^AFAProcessInstanceContentDownloadProgressBlock) (NSString *formattedReceivedBytesString, NSError *error);
typedef void  (^AFAProcessInstanceContentDownloadCompletionBlock)(NSURL *downloadedContentURL, BOOL isLocalContent, NSError *error);

@interface AFAProcessServices : NSObject

/**
 *  Performs a request for process instances list with properties matching defined ones within the filter model.
 *  The underlaying implementation is using a filter representation to call the API.
 *
 *  @param filter               Filter object describing what properties should be filtered
 *  @param completionBlock      Completion block providing the process instances list, an optional error reason and
 *                              pagination information
 *  @param cacheCompletionBlock Completion block providing a cached reference to the process instance list, an
 *                              optional error reason and pagination information
 */
- (void)requestProcessInstanceListWithFilter:(AFAGenericFilterModel *)filter
                         withCompletionBlock:(AFAProcessServiceProcessInstanceListCompletionBlock)completionBlock
                               cachedResults:(AFAProcessServiceProcessInstanceListCompletionBlock)cacheCompletionBlock;

/**
 *  Performs a request for the process definition list.
 *
 *  @param completionBlock      Completion block providing the process definition list, an optional error reason and
 *                              pagination information
 *  @param cacheCompletionBlock Completion block providing a cached reference to the process definition list, an
 *                              optional error reason and pagination information
 */
- (void)requestProcessDefinitionListWithCompletionBlock:(AFAProcessDefinitionListCompletionBlock)completionBlock
                                           cachedResults:(AFAProcessDefinitionListCompletionBlock)cacheCompletionBlock;

/**
 *  Performs a request for the process definition list that's associated with an application.
 *
 *  @param appID                The application for which the process definition list is fetched back
 *  @param completionBlock      Completion block providing the process definition list, an optional error reason and
 *                              pagination information
 *  @param cacheCompletionBlock Completion block providing a cached reference to the process definition list, an
 *                              optional error reason and pagination information
 */
- (void)requestProcessDefinitionListForAppID:(NSString *)appID
                         withCompletionBlock:(AFAProcessDefinitionListCompletionBlock)completionBlock
                               cachedResults:(AFAProcessDefinitionListCompletionBlock)cacheCompletionBlock;

/**
 *  Performs a request to start a process instance given it's process definition ID and the name of the instance.
 *
 *  @param processDefinitionID The process definition object for which the instance is spawned
 *  @param completionBlock     Completion block providing the process instance model and an optional error reason
 */
- (void)requestProcessInstanceStartForProcessDefinition:(ASDKModelProcessDefinition *)processDefinition
                                        completionBlock:(AFAProcessInstanceCompletionBlock)completionBlock;

/**
 *  Performs a request for the process instance details given it's process instance ID
 *
 *  @param processInstanceID    The process instance ID for which the details are requested
 *  @param completionBlock      Completion block providing the process instace details and an optional error reason
 *  @param cacheCompletionBlock Completion block providing a cached reference to the process instance details
 *                              and optional error reason
 */
- (void)requestProcessInstanceDetailsForID:(NSString *)processInstanceID
                           completionBlock:(AFAProcessInstanceCompletionBlock)completionBlock
                             cachedResults:(AFAProcessInstanceCompletionBlock)cacheCompletionBlock;

/**
 *  Performs a request for the process instance associated content given it's process instance ID
 *
 *  @param processInstanceID    The process instance ID for which the content is requested
 *  @param completionBlock      Completion block providing the process instace content list and an optional error reason
 *  @param cacheCompletionBlock Completion block providing a cached reference to the process instance content list
 *                              and optional error reason
 */
- (void)requestProcessInstanceContentForProcessInstanceID:(NSString *)processInstanceID
                                          completionBlock:(AFAProcessInstanceContentCompletionBlock)completionBlock
                                            cachedResults:(AFAProcessInstanceContentCompletionBlock)cacheCompletionBlock;

/**
 *  Performs a request for the comment list attached to the specified process instance.
 *
 *  @param processInstanceID    The ID of the process instance for which the comment list is requested
 *  @param completionBlock      Completion block providing the comment list, an optional error reason
 *                              and pagination information
 *  @param cacheCompletionBlock Completion block providing a cached reference to the process instance comment list, an
 *                              optional error reason and pagination information
 */
- (void)requestProcessInstanceCommentsForID:(NSString *)processInstanceID
                        withCompletionBlock:(AFAProcessInstanceCommentsCompletionBlock)completionBlock
                              cachedResults:(AFAProcessInstanceCommentsCompletionBlock)cacheCompletionBlock;

/**
 *  Performs a request to create a comment for a specified process instance ID
 *
 *  @param comment         Body of the comment
 *  @param taskID          ID of the process instance for which the comment is created
 *  @param completionBlock Completion block providing a reference to the created comment object and an
 *                         optional error reason.
 */
- (void)requestCreateComment:(NSString *)comment
        forProcessInstanceID:(NSString *)processInstanceID
             completionBlock:(AFAProcessInstanceCreateCommentCompletionBlock)completionBlock;

/**
 *  Deletes a process instance given a process instance ID and reports back via a completion block the status of
 *  the operation
 *
 *  @param processInstanceID ID of the process instance to be deleted
 *  @param completionBlock   Completion block providing the status of the delete operation and an optional error reason
 */
- (void)requestDeleteProcessInstanceWithID:(NSString *)processInstanceID
                           completionBlock:(AFAProcessInstanceDeleteCompletionBlock)completionBlock;

/**
 *  Performs a request to download the audit log for the mentioned process instance and reports back via completion 
 *  and progress blocks the status of the download.
 *
 *  @param processInstanceID    Process instance ID for which the audit log is requested
 *  @param allowCachedResults   Boolean value specifying if results can be provided if already present on the disk
 *  @param progressBlock        Block used to report progress updates for the download operation and an optional error
 *                              reason
 *  @param completionBlock      Completion block providing the URL location of the downloaded content, whether is a local reference
 *                              and an optional error reason
 */
- (void)requestDownloadAuditLogForProcessInstanceWithID:(NSString *)processInstanceID
                                     allowCachedResults:(BOOL)allowCachedResults
                                          progressBlock:(AFAProcessInstanceContentDownloadProgressBlock)progressBlock
                                        completionBlock:(AFAProcessInstanceContentDownloadCompletionBlock)completionBlock;

@end

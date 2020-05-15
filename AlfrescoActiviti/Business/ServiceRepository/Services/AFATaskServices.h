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
ASDKModelTask,
AFATaskUpdateModel,
ASDKModelContent,
ASDKModelUser,
ASDKModelComment,
AFATaskCreateModel;

typedef void  (^AFATaskServicesTaskListCompletionBlock)         (NSArray *taskList, NSError *error, ASDKModelPaging *paging);
typedef void  (^AFATaskServicesTaskDetailsCompletionBlock)      (ASDKModelTask *task, NSError *error);
typedef void  (^AFATaskServicesTaskContentCompletionBlock)      (NSArray *contentList, NSError *error);
typedef void  (^AFATaskServicesTaskCommentsCompletionBlock)     (NSArray *commentList, NSError *error, ASDKModelPaging *paging);
typedef void  (^AFATaskServicesTaskUpdateCompletionBlock)       (BOOL isTaskUpdated, NSError *error);
typedef void  (^AFATaskServicesTaskCompleteCompletionBlock)     (BOOL isTaskCompleted, NSError *error);
typedef void  (^AFATaskServiceTaskContentProgressBlock)         (NSUInteger progress, NSError *error);
typedef void  (^AFATaskServicesTaskContentUploadCompletionBlock)(BOOL isContentUploaded, NSError *error);
typedef void  (^AFATaskServiceTaskContentDeleteCompletionBlock) (BOOL isContentDeleted, NSError *error);
typedef void  (^AFATaskServiceTaskContentDownloadProgressBlock) (NSString *formattedReceivedBytesString, NSError *error);
typedef void  (^AFATaskServiceTaskContentDownloadCompletionBlock)(NSURL *downloadedContentURL, BOOL isLocalContent, NSError *error);
typedef void  (^AFATaskServicesUserInvolvementCompletionBlock)  (BOOL isUserInvolved, NSError *error);
typedef void  (^AFATaskServicesCreateCommentCompletionBlock)    (ASDKModelComment *comment, NSError *error);
typedef void  (^AFATaskServicesClaimCompletionBlock)            (BOOL isTaskClaimed, NSError *error);

@interface AFATaskServices : NSObject

/**
 *  Performs a request for tasks with properties defined from within the filter model.
 *  The underlaying implementation is using a filter representation to call the API.
 *
 *  @param taskFilter           Filter object describing what properties should be filtered
 *  @param completionBlock      Completion block providing the task list, an optional error reason and
 *                              pagination information
 *  @param cacheCompletionBlock Completion block providing a cached reference to the task
 *                              list, an optional error and pagination information
 */
- (void)requestTaskListWithFilter:(AFAGenericFilterModel *)taskFilter
                  completionBlock:(AFATaskServicesTaskListCompletionBlock)completionBlock
                    cachedResults:(AFATaskServicesTaskListCompletionBlock)cacheCompletionBlock;

/**
 *  Performs a request for a task's details given the task ID.
 *
 *  @param taskID               The ID of the task the details are requested for
 *  @param completionBlock      Completion block providing the task object and an optional error reason
 *  @param cacheCompletionBlock Completion block providing a cached reference to the task and an
 *                              optional error.
 */
- (void)requestTaskDetailsForID:(NSString *)taskID
                completionBlock:(AFATaskServicesTaskDetailsCompletionBlock)completionBlock
                  cachedResults:(AFATaskServicesTaskDetailsCompletionBlock)cacheCompletionBlock;

/**
 *  Performs a request for attached task content given the task ID.
 *
 *  @param taskID               The ID of the task for which the content is requested
 *  @param completionBlock      Completion block providing the content object and an optional error reason
 *  @param cacheCompletionBlock Completion block providing a cached reference to the task content list and
 *                              an optional error.
 */
- (void)requestTaskContentForID:(NSString *)taskID
                completionBlock:(AFATaskServicesTaskContentCompletionBlock)completionBlock
                  cachedResults:(AFATaskServicesTaskContentCompletionBlock)cacheCompletionBlock;

/**
 *  Performs a request for the comment list attached to the specified task.
 *
 *  @param taskID          The ID of the task for which the comment list is requested
 *  @param completionBlock Completion block providing the comment list, an optional error reason
 *                         and pagination information
 *  @param cacheCompletionBlock Completion block providing a cached reference to the
 */
- (void)requestTaskCommentsForID:(NSString *)taskID
                 completionBlock:(AFATaskServicesTaskCommentsCompletionBlock)completionBlock
                   cachedResults:(AFATaskServicesTaskCommentsCompletionBlock)cacheCompletionBlock;

/**
 *  Performs a request to update the mentioned task with properties defined from within the update model.
 *
 *  @param update          Model object describing possible fields that can be updated
 *  @param taskID          The ID of the task for which the update is requested
 *  @param completionBlock Completion block providing whether the update has succeeded or not and an
 *                         optional error reason
 */
- (void)requestTaskUpdateWithRepresentation:(AFATaskUpdateModel *)update
                                  forTaskID:(NSString *)taskID
                        withCompletionBlock:(AFATaskServicesTaskUpdateCompletionBlock)completionBlock;

/**
 *  Performs a request to mark a task as completed given it's ID
 *
 *  @param taskID          The ID of the task which is to be marked as completed
 *  @param completionBlock Completion block prodiving whether the task has been marked as completed or not
 *                         and an optional error reason
 */
- (void)requestTaskCompletionForID:(NSString *)taskID
               withCompletionBlock:(AFATaskServicesTaskCompleteCompletionBlock)completionBlock;

/**
 *  Performs a request to upload content from a provided NSData object for the given task ID. Additional information
 *  that is needed for the upload process should be provided as a URL to the resource to be uploaded.
 *
 *  @param fileURL         URL from where data content will be uploaded
 *  @param contentData     NSData object with the actual content
 *  @param taskID          The ID of the task for which the upload is requested
 *  @param progressBlock   Block used to report progress updates for the upload operation and an optional error
 *                         reason
 *  @param completionBlock Completion block providing whether the content was successfully uploaded or not and
 *                         an optional error reason
 */
- (void)requestContentUploadAtFileURL:(NSURL *)fileURL
                      withContentData:(NSData *)contentData
                            forTaskID:(NSString *)taskID
                    withProgressBlock:(AFATaskServiceTaskContentProgressBlock)progressBlock
                      completionBlock:(AFATaskServicesTaskContentUploadCompletionBlock)completionBlock;

/**
 *  Performs a request to delete the mentioned content that was previously associated with a task.
 *
 *  @param content         Content to be deleted
 *  @param completionBlock Completion block providing whether the content was successfully deleted or not and an
 *                         optional error reason
 */
- (void)requestTaskContentDeleteForContent:(ASDKModelContent *)content
                       withCompletionBlock:(AFATaskServiceTaskContentDeleteCompletionBlock)completionBlock;

/**
 *  Performs a request to download the mentioned content
 *
 *  @param content              Content to be downloaded
 *  @param allowCachedResults   Boolean value specifying if results can be provided if already present on the disk
 *  @param progressBlock        Block used to report progress updates for the download operation and an optional error
 *                              reason
 *  @param completionBlock      Completion block providing whether the content was successfully downloaded or not and
 *                              an optional error reason
 */
- (void)requestTaskContentDownloadForContent:(ASDKModelContent *)content
                          allowCachedResults:(BOOL)allowCachedResults
                           withProgressBlock:(AFATaskServiceTaskContentDownloadProgressBlock)progressBlock
                         withCompletionBlock:(AFATaskServiceTaskContentDownloadCompletionBlock)completionBlock;


/**
 *  Performs a request to download the thumbnail for the mentioned content
 *
 *  @param content              Content for which the thumbnail should be downloaded
 *  @param allowCachedResults   Boolean value specifying if results can be provided if already present on the disk
 *  @param progressBlock        Block used to report progress updates for the download operation and an optional error reason
 *  @param completionBlock      Completion block providing whether the content was successfully downloaded or not and an
 *                              optional error reason
 */
- (void)requestTaskContentThumbnailDownloadForContent:(ASDKModelContent *)content
                                   allowCachedResults:(BOOL)allowCachedResults
                                    withProgressBlock:(AFATaskServiceTaskContentDownloadProgressBlock)progressBlock
                                  withCompletionBlock:(AFATaskServiceTaskContentDownloadCompletionBlock)completionBlock;

/**
 *  Performs a request to involve the provided user in a task corresponding to the passed task ID
 *
 *  @param user            The user model object which is going to be involved
 *  @param taskID          The ID of the task for which the involvement is requested
 *  @param completionBlock Completion block providing whether the involvement operation finished successfully
 *                         and an optional error reason.
 */
- (void)requestTaskUserInvolvement:(ASDKModelUser *)user
                         forTaskID:(NSString *)taskID
                   completionBlock:(AFATaskServicesUserInvolvementCompletionBlock)completionBlock;

/**
 *  Performs a request to remove an involved user from a task corresponding to the passed task ID
 *
 *  @param user            The user model object which is going to be removed
 *  @param taskID          The ID of the task for which the involvement removal is requested
 *  @param completionBlock Completion block providing whether the involvement removal operation finished
 *                         successfully and an optional error reason.
 */
- (void)requestToRemoveTaskUserInvolvement:(ASDKModelUser *)user
                                 forTaskID:(NSString *)taskID
                           completionBlock:(AFATaskServicesUserInvolvementCompletionBlock)completionBlock;

/**
 *  Performs a request to create a comment for a specified task ID
 *
 *  @param comment         Body of the comment
 *  @param taskID          ID of the task for which the comment is created
 *  @param completionBlock Completion block providing a reference to the created comment object and an
 *                         optional error reason.
 */
- (void)requestCreateComment:(NSString *)comment
                   forTaskID:(NSString *)taskID
             completionBlock:(AFATaskServicesCreateCommentCompletionBlock)completionBlock;

/**
 *  Performs a request to create a task given a task create model representation which contains all the
 *  needed info.
 *
 *  @param taskRepresentation Model object describing all the required but not mandatory fields to create a task
 *  @param completionBlock    Completion block providing a reference to the created task object and an optional
 *                            error reason.
 */
- (void)requestCreateTaskWithRepresentation:(AFATaskCreateModel *)taskRepresentation
                            completionBlock:(AFATaskServicesTaskDetailsCompletionBlock)completionBlock;

/**
 *  Performs a request to claim a task given it's ID
 *
 *  @param taskID          ID of the task which should be claimed
 *  @param completionBlock Completion block providing information on whether the task has been claimed and an optional
 *                         error reason.
 */
- (void)requestTaskClaimForTaskID:(NSString *)taskID
                  completionBlock:(AFATaskServicesClaimCompletionBlock)completionBlock;

/**
 *  Performs a request to unclaim a task given it's ID
 *
 *  @param taskID          ID of the task which should be unclaimed
 *  @param completionBlock Completion block providing information on whether the task has been unclaimed and an optional
 *                         error reason.
 */
- (void)requestTaskUnclaimForTaskID:(NSString *)taskID
                    completionBlock:(AFATaskServicesClaimCompletionBlock)completionBlock;

/**
 *  Performs a request to assign a task described by it's task ID to a specified user
 *
 *  @param taskID          ID of the task to be assigned
 *  @param user            Model object of the user that will be assigned with the task
 *  @param completionBlock Completion block providing an updated task object and an optional error reason
 */
- (void)requestTaskAssignForTaskWithID:(NSString *)taskID
                                toUser:(ASDKModelUser *)user
                       completionBlock:(AFATaskServicesTaskDetailsCompletionBlock)completionBlock;

/**
 *  Performs a request to download the audit log for the mentioned task and reports back via completion and progress blocks
 *  the status of the download.
 *
 *  @param taskID               Task ID for which the audit log is requested
 *  @param allowCachedResults   Boolean value specifying if results can be provided if already present on the disk
 *  @param progressBlock        Block used to report progress updates for the download operation and an optional error
 *                              reason
 *  @param completionBlock      Completion block providing the URL location of the downloaded content, whether is a local reference
 *                              and an optional error reason
 */
- (void)requestDownloadAuditLogForTaskWithID:(NSString *)taskID
                          allowCachedResults:(BOOL)allowCachedResults
                               progressBlock:(AFATaskServiceTaskContentDownloadProgressBlock)progressBlock
                             completionBlock:(AFATaskServiceTaskContentDownloadCompletionBlock)completionBlock;

/**
 *  Performs a request for the checklist of a defined taskID
 *
 *  @param taskID               ID of the task for which the checklist is requested
 *  @param completionBlock      Completion block providing the list of checklist elements, an optional error reason and pagination
 *                              information
 *  @param cacheCompletionBlock Completion block providing a cached reference to the task checklist, an optional error
 *                              and pagination information
 */
- (void)requestChecklistForTaskWithID:(NSString *)taskID
                      completionBlock:(AFATaskServicesTaskListCompletionBlock)completionBlock
                        cachedResults:(AFATaskServicesTaskListCompletionBlock)cacheCompletionBlock;

/**
 *  Creates a checklist based on the passed representation
 *
 *  @param taskRepresentation Object encapsulating the information that needs to used for creating the checklist
 *  @param taskID             ID of the task for which the checklist is being created
 *  @param completionBlock    Completion block providing the newly created task object details and an optional
 *                            error reason
 */
- (void)requestChecklistCreateWithRepresentation:(AFATaskCreateModel *)taskRepresentation
                                          taskID:(NSString *)taskID
                                 completionBlock:(AFATaskServicesTaskDetailsCompletionBlock)completionBlock;

/**
 *  Adjusts the checklist element order as described in the attached order array
 *
 *  @param orderArray      An array object containing checklist ID elements in which the order of the elements
 *                         dictates the order of checklist elements to be adjusted
 *  @param taskID          ID of the task for which the checklist order is being adjusted
 *  @param completionBlock Completion block providing whether the order of the elements has been adjusted and an
 *                         optional error reason.
 */
- (void)requestChecklistOrderUpdateWithOrderArrat:(NSArray *)orderArray
                                           taskID:(NSString *)taskID
                                  completionBlock:(AFATaskServicesTaskUpdateCompletionBlock)completionBlock;

@end

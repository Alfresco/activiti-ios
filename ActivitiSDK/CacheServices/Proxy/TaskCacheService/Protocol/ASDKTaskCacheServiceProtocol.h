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
ASDKTaskListQuerryRequestRepresentation,
ASDKModelTask;

typedef void (^ASDKCacheServiceTaskListCompletionBlock) (NSArray *taskList, NSError *error, ASDKModelPaging *paging);
typedef void (^ASDKCacheServiceTaskDetailsCompletionBlock) (ASDKModelTask *task, NSError *error);
typedef void (^ASDKCacheServiceTaskContentListCompletionBlock) (NSArray *taskContentList, NSError *error);
typedef void (^ASDKCacheServiceTaskCommentListCompletionBlock) (NSArray *commentList, NSError *error, ASDKModelPaging *paging);

@protocol ASDKTaskCacheServiceProtocol <NSObject>

/**
 * Caches provided tasks by leveraging information from the filter that was provided
 * to the actual network request and reports the operation success over a completion block.
 * The filter is provided to identify information such as to which application the tasks
 * are afiliated, what task page are we loading in etc.
 *
 * @param taskList          List of tasks to be cached
 * @param filter            Filter object describing the membership of tasks in relation
 *                          to applications and specific page that has been loaded.
 * @param completionBlock   Completion block indicating the success of the operation
 */
- (void)cacheTaskList:(NSArray *)taskList
          usingFilter:(ASDKFilterRequestRepresentation *)filter
  withCompletionBlock:(ASDKCacheServiceCompletionBlock)completionBlock;

/**
 * Fetches a subset of the task list conforming to the passed filter description.
 * The filter contains information such as to which application are the tasks afiliated to
 * the page at which the tasks are retrieved and so on.
 *
 * @param completionBlock   Completion block providing a list of model objects, paging
 *                          information and an optional error reason
 * @param filter:           Filter object describing the rules of selection from the total available set
 */
- (void)fetchTaskList:(ASDKCacheServiceTaskListCompletionBlock)completionBlock
          usingFilter:(ASDKFilterRequestRepresentation *)filter;

/**
 * Caches provided tasks by leveraging information from the filter that was provided
 * to the actual network request and repots the operation success over a completion block.
 * Note that this implementation uses querry API filter representations. The filter is
 * provided to identify which tasks are affiliated to which process instances and also
 * describe the state of the affiliated tasks.
 *
 * @param taskList          List of tasks to be cached
 * @param filter            Filter object describing the membership of tasks in relation to
 *                          process instances and task states
 * @param completionBlock   Completion block indicating the success of the operation
 */
- (void)cacheTaskList:(NSArray *)taskList
    usingQuerryFilter:(ASDKTaskListQuerryRequestRepresentation *)filter
  withCompletionBlock:(ASDKCacheServiceCompletionBlock)completionBlock;

/**
 * Fetches a subset of the task list conforming to the passed filter description.
 * Note that this implementation uses querry API filter representations. The filter is
 * provided to identify which tasks are affiliated to which process instances and also
 * describe the state of the affiliated tasks.
 *
 * @param completionBlock   Completion block providing a list of model objects, paging
 *                          information and an optional error reason
 * @param filter            Filter object describing the rules of selection from the total available set
 */
- (void)fetchTaskList:(ASDKCacheServiceTaskListCompletionBlock)completionBlock
    usingQuerryFilter:(ASDKTaskListQuerryRequestRepresentation *)filter;

/**
 * Caches provided task details and reports the operation success over a completion block.
 *
 * @param task              Task model to be cached
 * @param completionBlock   Completion block indicating the success of the operation
 */
- (void)cacheTaskDetails:(ASDKModelTask *)task
     withCompletionBlock:(ASDKCacheServiceCompletionBlock)completionBlock;

/**
 * Fetches and reports via a completion block the task details for the specified id.
 *
 * @param taskID            Task id for which the details are requested
 * @param completionBlock   Completion block providing a task model object and an
 *                          optional error reason
 */
- (void)fetchTaskDetailsForID:(NSString *)taskID
          withCompletionBlock:(ASDKCacheServiceTaskDetailsCompletionBlock)completionBlock;

/**
 * Caches provided task content list that is afiliated with a task.
 *
 * @param taskContentList   List of task content objects to be cached
 * @param taskID            Task ID for which the task content list is to be cached
 * @param completionBlock   Completion block indicating the success of the operation
 */
- (void)cacheTaskContentList:(NSArray *)taskContentList
               forTaskWithID:(NSString *)taskID
         withCompletionBlock:(ASDKCacheServiceCompletionBlock)completionBlock;

/**
 * Fetches and reports via a completion block the task content list for the specified
 * task ID.
 *
 * @param taskID            Task ID for which the content list is requested
 * @param completionBlock   Completion block providing a list of task content objects and
 *                          additional error reason
 */
- (void)fetchTaskContentListForTaskWithID:(NSString *)taskID
                      withCompletionBlock:(ASDKCacheServiceTaskContentListCompletionBlock)completionBlock;

/**
 * Caches provided task comment list that is afiliated with a task.
 *
 * @param taskCommentList   List of task comments to be cached
 * @param taskID            Task ID for which the task comment list is to be cached
 * @param completionBlock   Completion block indicating the success of the operation
 */
- (void)cacheTaskCommentList:(NSArray *)taskCommentList
               forTaskWithID:(NSString *)taskID
         withCompletionBlock:(ASDKCacheServiceCompletionBlock)completionBlock;

/**
 * Fetches and reports via a completion block the task comment list for the specified 
 * task ID.
 *
 * @param taskID            Task ID for which the comment list is requested
 * @param completionBlock   Completion block providing a list of comments, paging information
 *                          and optional error reason
 */
- (void)fetchTaskCommentListForTaskWithID:(NSString *)taskID
                      withCompletionBlock:(ASDKCacheServiceTaskCommentListCompletionBlock)completionBlock;

/**
 * Caches provided task checklist that is afiliated with a task.
 *
 * @param taskChecklist     List of task checklist elements to be cached
 * @param taskID            The ID for which the task checklist is to be cached
 * @param completionBlock   Completion block indicating the success of the operation
 */
- (void)cacheTaskChecklist:(NSArray *)taskChecklist
             forTaskWithID:(NSString *)taskID
       withCompletionBlock:(ASDKCacheServiceCompletionBlock)completionBlock;

/**
 * Fetches and reports via a completion block the task checklist for the specified
 * task ID.
 *
 * @param taskID            Task ID for which the checklist is requested
 * @param completionBlock   Completion block providing a list of tasks, paging information
 *                          and optional error reason
 */
- (void)fetchTaskCheckListForTaskWithID:(NSString *)taskID
                    withCompletionBlock:(ASDKCacheServiceTaskListCompletionBlock)completionBlock;

@end

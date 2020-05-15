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

@import UIKit;

@class AFATableController,
ASDKModelUser,
ASDKModelContent,
ASDKIntegrationNodeContentRequestRepresentation;

typedef NS_ENUM(NSInteger, AFATaskDetailsSectionType) {
    AFATaskDetailsSectionTypeTaskDetails = 0,
    AFATaskDetailsSectionTypeForm,
    AFATaskDetailsSectionTypeChecklist,
    AFATaskDetailsSectionTypeContributors,
    AFATaskDetailsSectionTypeFilesContent,
    AFATaskDetailsSectionTypeComments,
    AFATaskDetailsSectionTypeEnumCount
};

typedef void (^AFATaskDetailsDataSourceCompletionBlock)  (NSError *error, BOOL registerCellActions);
typedef void (^AFATaskDeleteContentDataSourceCompletionBlock) (BOOL isContentDeleted, NSError *error);
typedef void (^AFATaskDataSourceErrorCompletionBlock) (NSError *error);
typedef void (^AFATaskUserInvolvementDataSourceCompletionBlock) (BOOL isUserInvolved, NSError *error);
typedef void (^AFATaskUpdateDataSourceCompletionBlock) (BOOL isTaskUpdated, NSError *error);
typedef void (^AFATaskCompleteDataSourceCompletionBlock) (BOOL isTaskCompleted, NSError *error);
typedef void (^AFATaskClaimingDataSourceCompletionBlock) (BOOL isTaskClaimed, NSError *error);

@protocol AFATaskDetailsDataSourceProtocol <NSObject>

@property (strong, nonatomic, readonly) UIColor     *themeColor;
@property (strong, nonatomic, readonly) NSString    *taskID;
@property (strong, nonatomic) NSMutableDictionary   *sectionModels;
@property (strong, nonatomic) AFATableController    *tableController;
@property (strong, nonatomic) NSMutableDictionary   *cellFactories;
@property (assign, nonatomic) BOOL                  isConnectivityAvailable;

- (instancetype)initWithTaskID:(NSString *)taskID
                  parentTaskID:(NSString *)parentTaskID
                    themeColor:(UIColor *)themeColor;

- (void)taskDetailsWithCompletionBlock:(AFATaskDetailsDataSourceCompletionBlock)completionBlock
                    cachedResultsBlock:(AFATaskDetailsDataSourceCompletionBlock)cachedResultsBlock;
- (void)updateTaskDueDateWithDate:(NSDate *)dueDate;
- (void)deleteContentForTaskAtIndex:(NSInteger)index
                withCompletionBlock:(AFATaskDeleteContentDataSourceCompletionBlock)completionBlock;
- (void)taskContributorsWithCompletionBlock:(AFATaskDataSourceErrorCompletionBlock)completionBlock
                         cachedResultsBlock:(AFATaskDataSourceErrorCompletionBlock)cachedResulstBlock;
- (void)removeInvolvementForUser:(ASDKModelUser *)user
             withCompletionBlock:(AFATaskUserInvolvementDataSourceCompletionBlock)completionBlock;
- (void)taskContentWithCompletionBlock:(AFATaskDataSourceErrorCompletionBlock)completionBlock
                    cachedResultsBlock:(AFATaskDataSourceErrorCompletionBlock)cachedResultsBlock;
- (void)taskCommentsWithCompletionBlock:(AFATaskDataSourceErrorCompletionBlock)completionBlock
                     cachedResultsBlock:(AFATaskDataSourceErrorCompletionBlock)cachedResultsBlock;
- (void)taskChecklistWithCompletionBlock:(AFATaskDataSourceErrorCompletionBlock)completionBlock
                      cachedResultsBlock:(AFATaskDataSourceErrorCompletionBlock)cachedResultsBlock;
- (void)updateCurrentTaskDetailsWithCompletionBlock:(AFATaskUpdateDataSourceCompletionBlock)completionBlock;
- (void)completeTaskWithCompletionBlock:(AFATaskCompleteDataSourceCompletionBlock)completionBlock;
- (void)claimTaskWithCompletionBlock:(AFATaskClaimingDataSourceCompletionBlock)completionBlock;
- (void)unclaimTaskWithCompletionBlock:(AFATaskClaimingDataSourceCompletionBlock)completionBlock;
- (void)updateChecklistOrderWithCompletionBlock:(AFATaskDataSourceErrorCompletionBlock)completionBlock;
- (void)uploadIntegrationContentForNode:(ASDKIntegrationNodeContentRequestRepresentation *)nodeContentRepresentation
                    withCompletionBlock:(AFATaskDataSourceErrorCompletionBlock)completionBlock;

- (NSDate *)taskDueDate;
- (ASDKModelUser *)involvedUserAtIndex:(NSInteger)index;
- (ASDKModelContent *)attachedContentAtIndex:(NSInteger)index;

- (id)cellFactoryForSectionType:(AFATaskDetailsSectionType)sectionType;
- (id)reusableTableControllerModelForSectionType:(AFATaskDetailsSectionType)sectionType;
- (void)updateTableControllerForSectionType:(AFATaskDetailsSectionType)sectionType;

@end

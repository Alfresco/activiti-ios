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

#import "AFATaskDetailsDataSource.h"

// Categories
#import "NSDate+AFADateAdditions.h"

// Models
#import "AFATableControllerTaskDetailsModel.h"
#import "AFATableControllerTaskContributorsModel.h"
#import "AFATableControllerContentModel.h"
#import "AFATableControllerCommentModel.h"
#import "AFATaskUpdateModel.h"

// Cell factories
#import "AFATableControllerTaskDetailsCellFactory.h"
#import "AFATaskChecklistCellFactory.h"
#import "AFATableControllerContentCellFactory.h"
#import "AFATableControllerTaskContributorsCellFactory.h"
#import "AFATableControllerCommentCellFactory.h"

// Managers
#import "AFATableController.h"
#import "AFATaskServices.h"
#import "AFAServiceRepository.h"
#import "AFAProfileServices.h"
#import "AFAIntegrationServices.h"

@interface AFATaskDetailsDataSource ()

// Services
@property (strong, nonatomic) AFAProfileServices        *requestProfileService;
@property (strong, nonatomic) AFATaskServices           *fetchTaskDetailsService;
@property (strong, nonatomic) AFATaskServices           *fetchParentTaskService;
@property (strong, nonatomic) AFATaskServices           *deleteTaskContentService;
@property (strong, nonatomic) AFATaskServices           *removeUserService;
@property (strong, nonatomic) AFATaskServices           *fetchTaskContentService;
@property (strong, nonatomic) AFATaskServices           *fetchTaskCommentsService;
@property (strong, nonatomic) AFATaskServices           *fetchTaskChecklistService;
@property (strong, nonatomic) AFATaskServices           *updateTaskService;
@property (strong, nonatomic) AFATaskServices           *completeTaskService;
@property (strong, nonatomic) AFATaskServices           *claimTaskService;
@property (strong, nonatomic) AFATaskServices           *unclaimTaskService;
@property (strong, nonatomic) AFATaskServices           *updateChecklistOrderService;
@property (strong, nonatomic) AFAIntegrationServices    *uploadIntegrationTaskContentService;

// Models
@property (strong, nonatomic) AFATableControllerTaskDetailsModel *cachedTaskDetailsModel;
@property (strong, nonatomic) AFATableControllerTaskDetailsModel *remoteTaskDetailsModel;
@property (strong, nonatomic) NSError *cachedTaskDetailsError;
@property (strong, nonatomic) NSError *remoteTaskDetailsError;

@end

@implementation AFATaskDetailsDataSource

- (instancetype)initWithTaskID:(NSString *)taskID
                  parentTaskID:(NSString *)parentTaskID
                    themeColor:(UIColor *)themeColor {
    self = [super init];
    
    if (self) {
        _taskID = taskID;
        _parentTaskID = parentTaskID;
        _themeColor = themeColor;
        _sectionModels = [NSMutableDictionary dictionary];
        _cellFactories = [NSMutableDictionary dictionary];
        _tableController = [AFATableController new];
        
        _requestProfileService = [AFAProfileServices new];
        _fetchTaskDetailsService = [AFATaskServices new];
        _fetchParentTaskService = [AFATaskServices new];
        _deleteTaskContentService = [AFATaskServices new];
        _removeUserService = [AFATaskServices new];
        _fetchTaskContentService = [AFATaskServices new];
        _fetchTaskCommentsService = [AFATaskServices new];
        _fetchTaskChecklistService = [AFATaskServices new];
        _updateTaskService = [AFATaskServices new];
        _completeTaskService = [AFATaskServices new];
        _claimTaskService = [AFATaskServices new];
        _unclaimTaskService = [AFATaskServices new];
        _updateChecklistOrderService = [AFATaskServices new];
        _uploadIntegrationTaskContentService = [AFAIntegrationServices new];
        
        [self setupCellFactoriesWithThemeColor:themeColor];
        
        // Set the default cell factory to task details
        self.tableController.cellFactory = [self cellFactoryForSectionType:AFATaskDetailsSectionTypeTaskDetails];
    }
    
    return self;
}


#pragma mark -
#pragma mark Public interface

- (void)taskDetailsWithCompletionBlock:(AFATaskDetailsDataSourceCompletionBlock)completionBlock
                    cachedResultsBlock:(AFATaskDetailsDataSourceCompletionBlock)cachedResultsBlock {
    /* Task details information is comprised out of multiple services aggregations
     1. Fetch the task details for the current task ID
     2. Fetch the parent task if applicable
     3. If the current task is claimable and has an assignee then fetch the
     current user profile to also check if the task is already claimed and
     can be dequeued.
     */
    self.cachedTaskDetailsModel = [AFATableControllerTaskDetailsModel new];
    self.remoteTaskDetailsModel = [AFATableControllerTaskDetailsModel new];
    
    self.cachedTaskDetailsModel.isConnectivityAvailable = self.isConnectivityAvailable;
    self.remoteTaskDetailsModel.isConnectivityAvailable = self.isConnectivityAvailable;
    
    dispatch_group_t remoteTaskDetailsGroup = dispatch_group_create();
    dispatch_group_t cachedTaskDetailsGroup = dispatch_group_create();
    
    // 1
    dispatch_group_enter(remoteTaskDetailsGroup);
    dispatch_group_enter(cachedTaskDetailsGroup);
    [self fetchDetailsForTaskWithID:self.taskID
                remoteDispatchGroup:remoteTaskDetailsGroup
                cachedDispatchGroup:cachedTaskDetailsGroup];
    
    // 2
    if (self.parentTaskID) {
        dispatch_group_enter(remoteTaskDetailsGroup);
        dispatch_group_enter(cachedTaskDetailsGroup);
        [self fetchDetailsForParentTaskWithID:self.parentTaskID
                          remoteDispatchGroup:remoteTaskDetailsGroup
                          cachedDispatchGroup:cachedTaskDetailsGroup];
    }
    
    // 3
    dispatch_group_enter(remoteTaskDetailsGroup);
    dispatch_group_enter(cachedTaskDetailsGroup);
    [self fetchCurrentProfileInRemoteDispatchGroup:remoteTaskDetailsGroup
                               cachedDispatchGroup:cachedTaskDetailsGroup];
    
    // Report result once all prerequisites are met
    __weak typeof(self) weakSelf = self;
    dispatch_group_notify(cachedTaskDetailsGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, kNilOptions), ^{
        __strong typeof(self) strongSelf = weakSelf;
        
        BOOL registerCellActions = [strongSelf registerTaskDetailsCellActionsForModel:self.cachedTaskDetailsModel];
        if (cachedResultsBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                cachedResultsBlock(weakSelf.cachedTaskDetailsError, registerCellActions);
            });
        }
    });
    
    dispatch_group_notify(remoteTaskDetailsGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, kNilOptions), ^{
        __strong typeof(self) strongSelf = weakSelf;
        
        BOOL registerCellActions = [strongSelf registerTaskDetailsCellActionsForModel:self.remoteTaskDetailsModel];
        if (completionBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(weakSelf.remoteTaskDetailsError, registerCellActions);
            });
        }
    });
}

- (void)updateTaskDueDateWithDate:(NSDate *)dueDate {
    AFATableControllerTaskDetailsModel *taskDetailsModel = [self reusableTableControllerModelForSectionType:AFATaskDetailsSectionTypeTaskDetails];
    taskDetailsModel.currentTask.dueDate = dueDate;
}

- (void)deleteContentForTaskAtIndex:(NSInteger)index
                withCompletionBlock:(AFATaskDeleteContentDataSourceCompletionBlock)completionBlock {
    AFATableControllerContentModel *taskContentModel = [self reusableTableControllerModelForSectionType:AFATaskDetailsSectionTypeFilesContent];
    ASDKModelContent *selectedContentModel = taskContentModel.attachedContentArr[index];
    
    [self.deleteTaskContentService requestTaskContentDeleteForContent:selectedContentModel
                                                  withCompletionBlock:^(BOOL isContentDeleted, NSError *error) {
                                                      if (completionBlock) {
                                                          completionBlock(isContentDeleted, error);
                                                      }
                                                  }];
}

- (void)taskContributorsWithCompletionBlock:(AFATaskDataSourceErrorCompletionBlock)completionBlock
                         cachedResultsBlock:(AFATaskDataSourceErrorCompletionBlock)cachedResulstBlock {
    __weak typeof(self) weakSelf = self;
    [self.fetchTaskDetailsService requestTaskDetailsForID:self.taskID
                                          completionBlock:^(ASDKModelTask *task, NSError *error) {
                                              __strong typeof(self) strongSelf = weakSelf;
                                              
                                              if (!error) {
                                                  [strongSelf handleTaskContributorsResponseForTask:task];
                                              }
                                              if (completionBlock) {
                                                  completionBlock(error);
                                              }
                                          } cachedResults:^(ASDKModelTask *task, NSError *error) {
                                              __strong typeof(self) strongSelf = weakSelf;
                                              
                                              if (!error) {
                                                  [strongSelf handleTaskContributorsResponseForTask:task];
                                              }
                                              if (cachedResulstBlock) {
                                                  cachedResulstBlock(error);
                                              }
                                          }];
}

- (void)removeInvolvementForUser:(ASDKModelUser *)user
             withCompletionBlock:(AFATaskUserInvolvementDataSourceCompletionBlock)completionBlock {
    [self.removeUserService requestToRemoveTaskUserInvolvement:user
                                                     forTaskID:self.taskID
                                               completionBlock:^(BOOL isUserInvolved, NSError *error) {
                                                   if (completionBlock) {
                                                       completionBlock(isUserInvolved, error);
                                                   }
                                               }];
}

- (void)taskContentWithCompletionBlock:(AFATaskDataSourceErrorCompletionBlock)completionBlock
                    cachedResultsBlock:(AFATaskDataSourceErrorCompletionBlock)cachedResultsBlock {
    __weak typeof(self) weakSelf = self;
    [self.fetchTaskContentService requestTaskContentForID:self.taskID
                                          completionBlock:^(NSArray *contentList, NSError *error) {
                                              __strong typeof(self) strongSelf = weakSelf;
                                              
                                              if (!error) {
                                                  [strongSelf handleTaskContentListResponse:contentList];
                                              }
                                              if (completionBlock) {
                                                  completionBlock(error);
                                              }
                                          } cachedResults:^(NSArray *contentList, NSError *error) {
                                              __strong typeof(self) strongSelf = weakSelf;
                                              
                                              if (!error) {
                                                  [strongSelf handleTaskContentListResponse:contentList];
                                              }
                                              if (cachedResultsBlock) {
                                                  cachedResultsBlock(error);
                                              }
                                          }];
}

- (void)taskCommentsWithCompletionBlock:(AFATaskDataSourceErrorCompletionBlock)completionBlock
                     cachedResultsBlock:(AFATaskDataSourceErrorCompletionBlock)cachedResultsBlock {
    __weak typeof(self) weakSelf = self;
    [self.fetchTaskCommentsService requestTaskCommentsForID:self.taskID
                                            completionBlock:^(NSArray *commentList, NSError *error, ASDKModelPaging *paging) {
                                                __strong typeof(self) strongSelf = weakSelf;
                                                
                                                if (!error) {
                                                    [strongSelf handleTaskCommentListResponse:commentList
                                                                                       paging:paging];
                                                }
                                                if (completionBlock) {
                                                    completionBlock(error);
                                                }
                                            } cachedResults:^(NSArray *commentList, NSError *error, ASDKModelPaging *paging) {
                                                __strong typeof(self) strongSelf = weakSelf;
                                                
                                                if (!error) {
                                                    [strongSelf handleTaskCommentListResponse:commentList
                                                                                       paging:paging];
                                                }
                                                if (cachedResultsBlock) {
                                                    cachedResultsBlock(error);
                                                }
                                            }];
}

- (void)taskChecklistWithCompletionBlock:(AFATaskDataSourceErrorCompletionBlock)completionBlock
                      cachedResultsBlock:(AFATaskDataSourceErrorCompletionBlock)cachedResultsBlock {
    __weak typeof(self) weakSelf = self;
    [self.fetchTaskChecklistService requestChecklistForTaskWithID:self.taskID
                                                  completionBlock:^(NSArray *taskList, NSError *error, ASDKModelPaging *paging) {
                                                      __strong typeof(self) strongSelf = weakSelf;
                                                      
                                                      if (!error) {
                                                          [strongSelf handleTaskChecklistResponse:taskList];
                                                      }
                                                      if (completionBlock) {
                                                          completionBlock(error);
                                                      }
                                                  } cachedResults:^(NSArray *taskList, NSError *error, ASDKModelPaging *paging) {
                                                      __strong typeof(self) strongSelf = weakSelf;
                                                      
                                                      if (!error) {
                                                          [strongSelf handleTaskChecklistResponse:taskList];
                                                      }
                                                      if (cachedResultsBlock) {
                                                          cachedResultsBlock(error);
                                                      }
                                                  }];
}

- (void)updateCurrentTaskDetailsWithCompletionBlock:(AFATaskUpdateDataSourceCompletionBlock)completionBlock {
    AFATaskUpdateModel *taskUpdate = [AFATaskUpdateModel new];
    AFATableControllerTaskDetailsModel *taskDetailsModel = [self reusableTableControllerModelForSectionType:AFATaskDetailsSectionTypeTaskDetails];
    taskUpdate.taskDueDate = taskDetailsModel.currentTask.dueDate;
    
    __weak typeof(self) weakSelf = self;
    [self.updateTaskService requestTaskUpdateWithRepresentation:taskUpdate
                                                      forTaskID:self.taskID
                                            withCompletionBlock:^(BOOL isTaskUpdated, NSError *error) {
                                                __strong typeof(self) strongSelf = weakSelf;
                                                
                                                if (!isTaskUpdated) {
                                                    // Rollback changes
                                                    AFATableControllerTaskDetailsModel *taskDetailsModel = [strongSelf reusableTableControllerModelForSectionType:AFATaskDetailsSectionTypeTaskDetails];
                                                    taskDetailsModel.currentTask.dueDate = nil;
                                                }
                                                
                                                if (completionBlock) {
                                                    completionBlock(isTaskUpdated, error);
                                                }
                                            }];
}

- (void)completeTaskWithCompletionBlock:(AFATaskCompleteDataSourceCompletionBlock)completionBlock {
    [self.completeTaskService requestTaskCompletionForID:self.taskID
                                     withCompletionBlock:^(BOOL isTaskCompleted, NSError *error) {
                                         if (completionBlock) {
                                             completionBlock(isTaskCompleted, error);
                                         }
                                     }];
}

- (void)claimTaskWithCompletionBlock:(AFATaskClaimingDataSourceCompletionBlock)completionBlock {
    [self.claimTaskService requestTaskClaimForTaskID:self.taskID
                                     completionBlock:^(BOOL isTaskClaimed, NSError *error) {
                                         if (completionBlock) {
                                             completionBlock(isTaskClaimed, error);
                                         }
                                     }];
}

- (void)unclaimTaskWithCompletionBlock:(AFATaskClaimingDataSourceCompletionBlock)completionBlock {
    [self.unclaimTaskService requestTaskUnclaimForTaskID:self.taskID
                                         completionBlock:^(BOOL isTaskClaimed, NSError *error) {
                                             if (completionBlock) {
                                                 completionBlock(isTaskClaimed, error);
                                             }
                                         }];
}

- (void)updateChecklistOrderWithCompletionBlock:(AFATaskDataSourceErrorCompletionBlock)completionBlock {
    AFATableControllerChecklistModel *taskChecklistModel = [self reusableTableControllerModelForSectionType:AFATaskDetailsSectionTypeChecklist];
    
    [self.updateChecklistOrderService requestChecklistOrderUpdateWithOrderArrat:[taskChecklistModel checkListIDs]
                                                                         taskID:self.taskID
                                                                completionBlock:^(BOOL isTaskUpdated, NSError *error) {
                                                                    
                                                                    if (completionBlock) {
                                                                        completionBlock(error);
                                                                    }
                                                                }];
}

- (void)uploadIntegrationContentForNode:(ASDKIntegrationNodeContentRequestRepresentation *)nodeContentRepresentation
                    withCompletionBlock:(AFATaskDataSourceErrorCompletionBlock)completionBlock {
    [self.uploadIntegrationTaskContentService requestUploadIntegrationContentForTaskID:self.taskID
                                                                    withRepresentation:nodeContentRepresentation
                                                                        completionBloc:^(ASDKModelContent *contentModel, NSError *error) {
                                                                            if (completionBlock) {
                                                                                completionBlock(error);
                                                                            }
                                                                        }];
}

- (NSDate *)taskDueDate {
    AFATableControllerTaskDetailsModel *taskDetailsModel = [self reusableTableControllerModelForSectionType:AFATaskDetailsSectionTypeTaskDetails];
    
    // If there is a previously registered due date, use that one for the date picker
    // If not, pick the current date
    NSDate *dueDate = taskDetailsModel.currentTask.dueDate ? taskDetailsModel.currentTask.dueDate : [[NSDate date] endOfToday];
    
    //Change model's date according to the default pick
    taskDetailsModel.currentTask.dueDate = dueDate;
    
    return dueDate;
}

- (ASDKModelUser *)involvedUserAtIndex:(NSInteger)index {
    AFATableControllerTaskContributorsModel *taskContributorsModel = [self reusableTableControllerModelForSectionType:AFATaskDetailsSectionTypeContributors];
    ASDKModelProfile *contributor = (ASDKModelProfile *)taskContributorsModel.involvedPeople[index];
    
    ASDKModelUser *userModel = [ASDKModelUser new];
    userModel.modelID = contributor.modelID;
    userModel.email = contributor.email;
    userModel.userFirstName = contributor.userFirstName;
    userModel.userLastName = contributor.userLastName;
    
    return userModel;
}

- (ASDKModelContent *)attachedContentAtIndex:(NSInteger)index {
    AFATableControllerContentModel *taskContentModel = [self reusableTableControllerModelForSectionType:AFATaskDetailsSectionTypeFilesContent];
    return (ASDKModelContent *)taskContentModel.attachedContentArr[index];
}

- (id)cellFactoryForSectionType:(AFATaskDetailsSectionType)sectionType {
    return self.cellFactories[@(sectionType)];
}

- (id)reusableTableControllerModelForSectionType:(AFATaskDetailsSectionType)sectionType {
    id reusableObject = nil;
    
    reusableObject = self.sectionModels[@(sectionType)];
    if (!reusableObject) {
        switch (sectionType) {
            case AFATaskDetailsSectionTypeTaskDetails: {
                reusableObject = [AFATableControllerTaskDetailsModel new];
            }
                break;
                
            case AFATaskDetailsSectionTypeContributors: {
                reusableObject = [AFATableControllerTaskContributorsModel new];
            }
                break;
                
            case AFATaskDetailsSectionTypeFilesContent: {
                reusableObject = [AFATableControllerContentModel new];
            }
                break;
                
            case AFATaskDetailsSectionTypeComments: {
                reusableObject = [AFATableControllerCommentModel new];
            }
                break;
                
            default:
                break;
        }
    }
    
    return reusableObject;
}

- (void)updateTableControllerForSectionType:(AFATaskDetailsSectionType)sectionType {
    self.tableController.model = [self reusableTableControllerModelForSectionType:sectionType];
    self.tableController.cellFactory = [self cellFactoryForSectionType:sectionType];
}


#pragma mark -
#pragma mark Response handlers

- (void)handleTaskContributorsResponseForTask:(ASDKModelTask *)task {
    // Extract the number of collaborators for the given task
    AFATableControllerTaskContributorsModel *taskContributorsModel = [AFATableControllerTaskContributorsModel new];
    taskContributorsModel.isConnectivityAvailable = self.isConnectivityAvailable;
    taskContributorsModel.involvedPeople = task.involvedPeople;
    self.sectionModels[@(AFATaskDetailsSectionTypeContributors)] = taskContributorsModel;
    
    [self updateTableControllerForSectionType:AFATaskDetailsSectionTypeContributors];
    
    // Check if the task is already completed and in that case mark the table
    // controller as not editable
    BOOL isEditable = !(task.endDate && task.duration) && self.isConnectivityAvailable;
    self.tableController.isEditable = isEditable;
}

- (void)handleTaskContentListResponse:(NSArray *)contentList {
    AFATableControllerContentModel *taskContentModel = [AFATableControllerContentModel new];
    taskContentModel.isConnectivityAvailable = self.isConnectivityAvailable;
    taskContentModel.attachedContentArr = contentList;
    self.sectionModels[@(AFATaskDetailsSectionTypeFilesContent)] = taskContentModel;
    
    [self updateTableControllerForSectionType:AFATaskDetailsSectionTypeFilesContent];
    
    AFATableControllerTaskDetailsModel *taskDetailsModel = [self reusableTableControllerModelForSectionType:AFATaskDetailsSectionTypeTaskDetails];
    BOOL isEditable = ![taskDetailsModel isCompletedTask] && self.isConnectivityAvailable;
    self.tableController.isEditable = isEditable;
}

- (void)handleTaskCommentListResponse:(NSArray *)commentList
                               paging:(ASDKModelPaging *)paging {
    // Extract the updated result
    AFATableControllerCommentModel *taskCommentModel = [AFATableControllerCommentModel new];
    NSSortDescriptor *newestCommentsSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"creationDate"
                                                                                   ascending:NO];
    taskCommentModel.commentListArr = [commentList sortedArrayUsingDescriptors:@[newestCommentsSortDescriptor]];
    taskCommentModel.paging = paging;
    self.sectionModels[@(AFATaskDetailsSectionTypeComments)] = taskCommentModel;
    
    [self updateTableControllerForSectionType:AFATaskDetailsSectionTypeComments];
}

- (void)handleTaskChecklistResponse:(NSArray *)taskList {
    AFATableControllerChecklistModel *taskChecklistModel = [AFATableControllerChecklistModel new];
    taskChecklistModel.delegate = [self cellFactoryForSectionType:AFATaskDetailsSectionTypeChecklist];
    taskChecklistModel.checklistArr = taskList;
    self.sectionModels[@(AFATaskDetailsSectionTypeChecklist)] = taskChecklistModel;
    
    [self updateTableControllerForSectionType:AFATaskDetailsSectionTypeChecklist];
    
    AFATableControllerTaskDetailsModel *taskDetailsModel = [self reusableTableControllerModelForSectionType:AFATaskDetailsSectionTypeTaskDetails];
    BOOL isEditable = ![taskDetailsModel isCompletedTask] && self.isConnectivityAvailable;
    self.tableController.isEditable = isEditable;
}


#pragma mark -
#pragma mark Helpers

- (void)setupCellFactoriesWithThemeColor:(UIColor *)themeColor {
    // Details cell factory
    AFATableControllerTaskDetailsCellFactory *detailsCellFactory = [AFATableControllerTaskDetailsCellFactory new];
    detailsCellFactory.appThemeColor = themeColor;
    
    // Checklist cell factory
    AFATaskChecklistCellFactory *checklistCellFactory = [AFATaskChecklistCellFactory new];
    checklistCellFactory.appThemeColor = themeColor;
    
    // Content cell factory
    AFATableControllerContentCellFactory *contentCellFactory = [AFATableControllerContentCellFactory new];
    
    // Contributors cell factory
    AFATableControllerTaskContributorsCellFactory *contributorsCellFactory = [AFATableControllerTaskContributorsCellFactory new];
    
    // Comment cell factory
    AFATableControllerCommentCellFactory *commentCellFactory = [AFATableControllerCommentCellFactory new];
    
    self.cellFactories[@(AFATaskDetailsSectionTypeTaskDetails)] = detailsCellFactory;
    self.cellFactories[@(AFATaskDetailsSectionTypeChecklist)] = checklistCellFactory;
    self.cellFactories[@(AFATaskDetailsSectionTypeContributors)] = contributorsCellFactory;
    self.cellFactories[@(AFATaskDetailsSectionTypeFilesContent)] = contentCellFactory;
    self.cellFactories[@(AFATaskDetailsSectionTypeComments)] = commentCellFactory;
}

- (void)fetchDetailsForTaskWithID:(NSString *)taskID
              remoteDispatchGroup:(dispatch_group_t)remoteDispatchGroup
              cachedDispatchGroup:(dispatch_group_t)cachedDispatchGroup {
    
    __weak typeof(self) weakSelf = self;
    [self.fetchTaskDetailsService requestTaskDetailsForID:taskID
                                          completionBlock:^(ASDKModelTask *task, NSError *error) {
                                              __strong typeof(self) strongSelf = weakSelf;
                                              
                                              strongSelf.remoteTaskDetailsError = error;
                                              
                                              if (!error) {
                                                  strongSelf.remoteTaskDetailsModel.currentTask = task;
                                              }
                                              
                                              dispatch_group_leave(remoteDispatchGroup);
                                          } cachedResults:^(ASDKModelTask *task, NSError *error) {
                                              __strong typeof(self) strongSelf = weakSelf;
                                              
                                              strongSelf.cachedTaskDetailsError = error;
                                              
                                              if (!error) {
                                                  strongSelf.cachedTaskDetailsModel.currentTask = task;
                                                  
                                                  // If the parent task information is not present when
                                                  // fetching the task details perform an additional request
                                                  if (!strongSelf.parentTaskID && task.parentTaskID) {
                                                      dispatch_group_enter(remoteDispatchGroup);
                                                      dispatch_group_enter(cachedDispatchGroup);
                                                      [strongSelf fetchDetailsForParentTaskWithID:task.parentTaskID remoteDispatchGroup:remoteDispatchGroup
                                                                              cachedDispatchGroup:cachedDispatchGroup];
                                                  }
                                              }
                                              
                                              dispatch_group_leave(cachedDispatchGroup);
                                          }];
}

- (void)fetchDetailsForParentTaskWithID:(NSString *)parentTaskID
                    remoteDispatchGroup:(dispatch_group_t)remoteDispatchGroup
                    cachedDispatchGroup:(dispatch_group_t)cachedDispatchGroup {
    __weak typeof(self) weakSelf = self;
    
    [self.fetchParentTaskService requestTaskDetailsForID:parentTaskID
                                         completionBlock:^(ASDKModelTask *task, NSError *error) {
                                             __strong typeof(self) strongSelf = weakSelf;
                                             
                                             strongSelf.remoteTaskDetailsError = error;
                                             
                                             if (!error) {
                                                 strongSelf.remoteTaskDetailsModel.parentTask = task;
                                             }
                                             
                                             dispatch_group_leave(remoteDispatchGroup);
                                         } cachedResults:^(ASDKModelTask *task, NSError *error) {
                                             __strong typeof(self) strongSelf = weakSelf;
                                             
                                             strongSelf.cachedTaskDetailsError = error;
                                             
                                             if (!error) {
                                                 strongSelf.cachedTaskDetailsModel.parentTask = task;
                                             }
                                             
                                             dispatch_group_leave(cachedDispatchGroup);
                                         }];
}

- (void)fetchCurrentProfileInRemoteDispatchGroup:(dispatch_group_t)remoteDispatchGroup
                             cachedDispatchGroup:(dispatch_group_t)cachedDispatchGroup {
    __weak typeof(self) weakSelf = self;
    [self.requestProfileService requestProfileWithCompletionBlock:^(ASDKModelProfile *profile, NSError *error) {
        __strong typeof(self) strongSelf = weakSelf;
        
        strongSelf.remoteTaskDetailsError = error;
        
        if (!error) {
            strongSelf.remoteTaskDetailsModel.userProfile = profile;
        }
        dispatch_group_leave(remoteDispatchGroup);
    } cachedResults:^(ASDKModelProfile *profile, NSError *error) {
        __strong typeof(self) strongSelf = weakSelf;
        
        strongSelf.cachedTaskDetailsError = error;
        
        if (!error) {
            strongSelf.cachedTaskDetailsModel.userProfile = profile;
        }
        dispatch_group_leave(cachedDispatchGroup);
    }];
}

- (BOOL)registerTaskDetailsCellActionsForModel:(AFATableControllerTaskDetailsModel *)taskDetailsModel {
    BOOL registerCellActions = NO;
    
    if (!self.sectionModels[@(AFATaskDetailsSectionTypeTaskDetails)]) {
        // Cell actions for all the cell factories are registered after the initial task details
        // are loaded
        registerCellActions = YES;
    }
    
    if (taskDetailsModel.currentTask && taskDetailsModel.userProfile) {
        self.sectionModels[@(AFATaskDetailsSectionTypeTaskDetails)] = taskDetailsModel;
    }
    [self updateTableControllerForSectionType:AFATaskDetailsSectionTypeTaskDetails];
    
    return registerCellActions;
}

@end

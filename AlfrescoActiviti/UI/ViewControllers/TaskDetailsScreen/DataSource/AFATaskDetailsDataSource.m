/*******************************************************************************
 * Copyright (C) 2005-2017 Alfresco Software Limited.
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
#import "AFAFormServices.h"
#import "AFAProfileServices.h"
#import "AFAIntegrationServices.h"


@implementation AFATaskDetailsDataSource

- (instancetype)initWithTaskID:(NSString *)taskID
                    themeColor:(UIColor *)themeColor {
    self = [super init];
    
    if (self) {
        _taskID = taskID;
        _themeColor = themeColor;
        _sectionModels = [NSMutableDictionary dictionary];
        _cellFactories = [NSMutableDictionary dictionary];
        _tableController = [AFATableController new];
        
        [self setupCellFactoriesWithThemeColor:themeColor];
        
        // Set the default cell factory to task details
        self.tableController.cellFactory = [self cellFactoryForSectionType:AFATaskDetailsSectionTypeTaskDetails];
    }
    
    return self;
}


#pragma mark -
#pragma mark Public interface

- (void)taskDetailsWithCompletionBlock:(void (^)(NSError *error, BOOL registerCellActions))completionBlock {
    AFATaskServices *taskServices = [[AFAServiceRepository sharedRepository] serviceObjectForPurpose:AFAServiceObjectTypeTaskServices];
    
    __weak typeof(self) weakSelf = self;
    [taskServices requestTaskDetailsForID:self.taskID
                      withCompletionBlock:^(ASDKModelTask *task, NSError *taskDetailsError) {
                          __strong typeof(self) strongSelf = weakSelf;
                          BOOL registerCellActions = NO;
                          
                          if (!taskDetailsError) {
                              AFATableControllerTaskDetailsModel *taskDetailsModel = [AFATableControllerTaskDetailsModel new];
                              taskDetailsModel.currentTask = task;
                              
                              if (!strongSelf.sectionModels[@(AFATaskDetailsSectionTypeTaskDetails)]) {
                                  // Cell actions for all the cell factories are registered after the initial task details
                                  // are loaded
                                  registerCellActions = YES;
                              }
                              strongSelf.sectionModels[@(AFATaskDetailsSectionTypeTaskDetails)] = taskDetailsModel;
                              
                              // If the current task is claimable and has an assignee then fetch the
                              // current user profile to also check if the task is already claimed and
                              // can be dequeued
                              dispatch_group_t taskDetailsGroup = dispatch_group_create();
                              
                              // Fetch profile information
                              dispatch_group_enter(taskDetailsGroup);
                              AFAProfileServices *profileServices = [[AFAServiceRepository sharedRepository] serviceObjectForPurpose:AFAServiceObjectTypeProfileServices];
                              __block ASDKModelProfile *currentUserProfile = nil;
                              __block BOOL hadEncounteredAnError = NO;
                              [profileServices requestProfileWithCompletionBlock:^(ASDKModelProfile *profile, NSError *error) {
                                  if (hadEncounteredAnError) {
                                      return;
                                  } else {
                                      hadEncounteredAnError = error ? YES : NO;
                                      if (!hadEncounteredAnError) {
                                          currentUserProfile = profile;
                                      } else {
                                          if (completionBlock) {
                                              completionBlock(error, registerCellActions);
                                          }
                                      }
                                      dispatch_group_leave(taskDetailsGroup);
                                  }
                              }];
                              
                              // Fetch parent task if applicable
                              __block ASDKModelTask *parentTask = nil;
                              if (task.parentTaskID) {
                                  dispatch_group_enter(taskDetailsGroup);
                                  [taskServices requestTaskDetailsForID:task.parentTaskID
                                                    withCompletionBlock:^(ASDKModelTask *task, NSError *error) {
                                                        if (hadEncounteredAnError) {
                                                            return;
                                                        } else {
                                                            hadEncounteredAnError = error ? YES : NO;
                                                            if (!hadEncounteredAnError) {
                                                                parentTask = task;
                                                            } else {
                                                                if (completionBlock) {
                                                                    completionBlock(error, registerCellActions);
                                                                }
                                                            }
                                                            dispatch_group_leave(taskDetailsGroup);
                                                        }
                                                    }];
                              }
                              
                              dispatch_group_notify(taskDetailsGroup, dispatch_get_main_queue(), ^{
                                  AFATableControllerTaskDetailsModel *taskDetailsModel = weakSelf.sectionModels[@(AFATaskDetailsSectionTypeTaskDetails)];
                                  taskDetailsModel.userProfile = currentUserProfile;
                                  taskDetailsModel.parentTask = parentTask;
                                  
                                  [weakSelf updateTableControllerForSectionType:AFATaskDetailsSectionTypeTaskDetails];
                                  
                                  if (completionBlock) {
                                      completionBlock(nil, registerCellActions);
                                  }
                              });
                          }
                          
                          if (completionBlock) {
                              completionBlock(taskDetailsError, NO);
                          }
                      }];
}

- (void)updateTaskDueDateWithDate:(NSDate *)dueDate {
    AFATableControllerTaskDetailsModel *taskDetailsModel = [self reusableTableControllerModelForSectionType:AFATaskDetailsSectionTypeTaskDetails];
    taskDetailsModel.currentTask.dueDate = dueDate;
}

- (void)deleteContentForTaskAtIndex:(NSInteger)index
                withCompletionBlock:(void (^)(BOOL isContentDeleted, NSError *error))completionBlock {
    AFATaskServices *taskServices = [[AFAServiceRepository sharedRepository] serviceObjectForPurpose:AFAServiceObjectTypeTaskServices];
    
    AFATableControllerContentModel *taskContentModel = [self reusableTableControllerModelForSectionType:AFATaskDetailsSectionTypeFilesContent];
    ASDKModelContent *selectedContentModel = taskContentModel.attachedContentArr[index];
    
    [taskServices requestTaskContentDeleteForContent:selectedContentModel
                                 withCompletionBlock:^(BOOL isContentDeleted, NSError *error) {
                                     if (completionBlock) {
                                         completionBlock(isContentDeleted, error);
                                     }
                                 }];
}

- (void)taskContributorsWithCompletionBlock:(void (^)(NSError *error))completionBlock {
    AFATaskServices *taskServices = [[AFAServiceRepository sharedRepository] serviceObjectForPurpose:AFAServiceObjectTypeTaskServices];
    
    __weak typeof(self) weakSelf = self;
    [taskServices requestTaskDetailsForID:self.taskID
                      withCompletionBlock:^(ASDKModelTask *task, NSError *error) {
                          __strong typeof(self) strongSelf = weakSelf;
                          
                          if (!error) {
                              // Extract the number of collaborators for the given task
                              AFATableControllerTaskContributorsModel *taskContributorsModel = [AFATableControllerTaskContributorsModel new];
                              taskContributorsModel.involvedPeople = task.involvedPeople;
                              strongSelf.sectionModels[@(AFATaskDetailsSectionTypeContributors)] = taskContributorsModel;
                              
                              [strongSelf updateTableControllerForSectionType:AFATaskDetailsSectionTypeContributors];
                              
                              // Check if the task is already completed and in that case mark the table
                              // controller as not editable
                              strongSelf.tableController.isEditable = !(task.endDate && task.duration);
                          }
                          
                          if (completionBlock) {
                              completionBlock(error);
                          }
                      }];
}

- (void)removeInvolvementForUser:(ASDKModelUser *)user
             withCompletionBlock:(void (^)(BOOL isUserInvolved, NSError *error))completionBlock {
    AFATaskServices *taskService = [[AFAServiceRepository sharedRepository] serviceObjectForPurpose:AFAServiceObjectTypeTaskServices];
    
    [taskService requestToRemoveTaskUserInvolvement:user
                                          forTaskID:self.taskID
                                    completionBlock:^(BOOL isUserInvolved, NSError *error) {
                                        if (completionBlock) {
                                            completionBlock(isUserInvolved, error);
                                        }
                                    }];
}

- (void)saveTaskForm {
    AFAFormServices *formService = [[AFAServiceRepository sharedRepository] serviceObjectForPurpose:AFAServiceObjectTypeFormServices];
    ASDKFormEngineActionHandler *formEngineActionHandler = [formService formEngineActionHandler];
    [formEngineActionHandler saveForm];
}

- (void)taskContentWithCompletionBlock:(void (^)(NSError *))completionBlock {
    AFATaskServices *taskServices = [[AFAServiceRepository sharedRepository] serviceObjectForPurpose:AFAServiceObjectTypeTaskServices];
    
    __weak typeof(self) weakSelf = self;
    [taskServices requestTaskContentForID:self.taskID
                      withCompletionBlock:^(NSArray *contentList, NSError *error) {
                          __strong typeof(self) strongSelf = weakSelf;
                          
                          if (!error) {
                              AFATableControllerContentModel *taskContentModel = [AFATableControllerContentModel new];
                              taskContentModel.attachedContentArr = contentList;
                              strongSelf.sectionModels[@(AFATaskDetailsSectionTypeFilesContent)] = taskContentModel;
                              
                              [strongSelf updateTableControllerForSectionType:AFATaskDetailsSectionTypeFilesContent];
                              
                              AFATableControllerTaskDetailsModel *taskDetailsModel = [strongSelf reusableTableControllerModelForSectionType:AFATaskDetailsSectionTypeTaskDetails];
                              strongSelf.tableController.isEditable = ![taskDetailsModel isCompletedTask];
                          }
                          
                          if (completionBlock) {
                              completionBlock(error);
                          }
                      }];
}

- (void)taskCommentsWithCompletionBlock:(void (^)(NSError *error))completionBlock {
    AFATaskServices *taskServices = [[AFAServiceRepository sharedRepository] serviceObjectForPurpose:AFAServiceObjectTypeTaskServices];
    
    __weak typeof(self) weakSelf = self;
    [taskServices requestTaskCommentsForID:self.taskID
                       withCompletionBlock:^(NSArray *commentList, NSError *error, ASDKModelPaging *paging) {
                           __strong typeof(self) strongSelf = weakSelf;
                           
                           if (!error) {
                               // Extract the updated result
                               AFATableControllerCommentModel *taskCommentModel = [AFATableControllerCommentModel new];
                               NSSortDescriptor *newestCommentsSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"creationDate"
                                                                                                              ascending:NO];
                               taskCommentModel.commentListArr = [commentList sortedArrayUsingDescriptors:@[newestCommentsSortDescriptor]];
                               taskCommentModel.paging = paging;
                               strongSelf.sectionModels[@(AFATaskDetailsSectionTypeComments)] = taskCommentModel;
                               
                               [strongSelf updateTableControllerForSectionType:AFATaskDetailsSectionTypeComments];
                           }
                           
                           if (completionBlock) {
                               completionBlock(error);
                           }
                       }];
}

- (void)taskChecklistWithCompletionBlock:(void (^)(NSError *error))completionBlock {
    AFATaskServices *taskServices = [[AFAServiceRepository sharedRepository] serviceObjectForPurpose:AFAServiceObjectTypeTaskServices];
    
    __weak typeof(self) weakSelf = self;
    [taskServices requestChecklistForTaskWithID:self.taskID
                                completionBlock:^(NSArray *taskList, NSError *error, ASDKModelPaging *paging) {
                                    __strong typeof(self) strongSelf = weakSelf;
                                    
                                    if (!error) {
                                        AFATableControllerChecklistModel *taskChecklistModel = [AFATableControllerChecklistModel new];
                                        taskChecklistModel.delegate = [strongSelf cellFactoryForSectionType:AFATaskDetailsSectionTypeChecklist];
                                        taskChecklistModel.checklistArr = taskList;
                                        strongSelf.sectionModels[@(AFATaskDetailsSectionTypeChecklist)] = taskChecklistModel;
                                        
                                        [strongSelf updateTableControllerForSectionType:AFATaskDetailsSectionTypeChecklist];
                                        
                                        AFATableControllerTaskDetailsModel *taskDetailsModel = [self reusableTableControllerModelForSectionType:AFATaskDetailsSectionTypeTaskDetails];
                                        strongSelf.tableController.isEditable = ![taskDetailsModel isCompletedTask];
                                    }
                                    
                                    if (completionBlock) {
                                        completionBlock(error);
                                    }
                                }];
}

- (void)updateCurrentTaskDetailsWithCompletionBlock:(void (^)(BOOL isTaskUpdated, NSError *error))completionBlock {
    AFATaskServices *taskServices = [[AFAServiceRepository sharedRepository] serviceObjectForPurpose:AFAServiceObjectTypeTaskServices];
    
    AFATaskUpdateModel *taskUpdate = [AFATaskUpdateModel new];
    AFATableControllerTaskDetailsModel *taskDetailsModel = [self reusableTableControllerModelForSectionType:AFATaskDetailsSectionTypeTaskDetails];
    taskUpdate.taskDueDate = taskDetailsModel.currentTask.dueDate;
    
    __weak typeof(self) weakSelf = self;
    [taskServices requestTaskUpdateWithRepresentation:taskUpdate
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

- (void)completeTaskWithCompletionBlock:(void (^)(BOOL isTaskCompleted, NSError *error))completionBlock {
    AFATaskServices *taskServices = [[AFAServiceRepository sharedRepository] serviceObjectForPurpose:AFAServiceObjectTypeTaskServices];
    
    [taskServices requestTaskCompletionForID:self.taskID
                         withCompletionBlock:^(BOOL isTaskCompleted, NSError *error) {
                             if (completionBlock) {
                                 completionBlock(isTaskCompleted, error);
                             }
                         }];
}

- (void)claimTaskWithCompletionBlock:(void (^)(BOOL isTaskClaimed, NSError *error))completionBlock {
    AFATaskServices *taskService = [[AFAServiceRepository sharedRepository] serviceObjectForPurpose:AFAServiceObjectTypeTaskServices];
    
    [taskService requestTaskClaimForTaskID:self.taskID
                           completionBlock:^(BOOL isTaskClaimed, NSError *error) {
                               if (completionBlock) {
                                   completionBlock(isTaskClaimed, error);
                               }
                           }];
}

- (void)unclaimTaskWithCompletionBlock:(void (^)(BOOL isTaskClaimed, NSError *error))completionBlock {
    AFATaskServices *taskService = [[AFAServiceRepository sharedRepository] serviceObjectForPurpose:AFAServiceObjectTypeTaskServices];
    
    [taskService requestTaskUnclaimForTaskID:self.taskID
                             completionBlock:^(BOOL isTaskClaimed, NSError *error) {
                                 if (completionBlock) {
                                     completionBlock(isTaskClaimed, error);
                                 }
                             }];
}

- (void)updateChecklistOrderWithCompletionBlock:(void (^)(NSError *error))completionBlock {
    AFATaskServices *taskService = [[AFAServiceRepository sharedRepository] serviceObjectForPurpose:AFAServiceObjectTypeTaskServices];
    AFATableControllerChecklistModel *taskChecklistModel = [self reusableTableControllerModelForSectionType:AFATaskDetailsSectionTypeChecklist];
    
    [taskService requestChecklistOrderUpdateWithOrderArrat:[taskChecklistModel checkListIDs]
                                                    taskID:self.taskID
                                           completionBlock:^(BOOL isTaskUpdated, NSError *error) {
                                               
                                               if (completionBlock) {
                                                   completionBlock(error);
                                               }
                                           }];
}

- (void)uploadIntegrationContentForNode:(ASDKIntegrationNodeContentRequestRepresentation *)nodeContentRepresentation
                    withCompletionBlock:(void (^)(NSError *error))completionBlock {
    AFAIntegrationServices *integrationService = [[AFAServiceRepository sharedRepository] serviceObjectForPurpose:AFAServiceObjectTypeIntegrationServices];
    
    [integrationService requestUploadIntegrationContentForTaskID:self.taskID
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
#pragma mark Private interface

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

@end
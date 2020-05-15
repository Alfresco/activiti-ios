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

#import "AFAProcessInstanceDetailsDataSource.h"

// Models
#import "AFATableControllerProcessInstanceDetailsModel.h"
#import "AFATableControllerProcessInstanceTasksModel.h"
#import "AFATableControllerProcessInstanceContentModel.h"
#import "AFATableControllerCommentModel.h"
#import "AFAGenericFilterModel.h"

// Cell factories
#import "AFATableControllerProcessInstanceDetailsCellFactory.h"
#import "AFATableControllerProcessInstanceTasksCellFactory.h"
#import "AFATableControllerContentCellFactory.h"
#import "AFATableControllerCommentCellFactory.h"

// Managers
#import "AFAProcessServices.h"
#import "AFAServiceRepository.h"
#import "AFAQueryServices.h"

@interface AFAProcessInstanceDetailsDataSource ()

// Services
@property (strong, nonatomic) AFAQueryServices      *fetchActiveTaskListService;
@property (strong, nonatomic) AFAQueryServices      *fetchCompletedTaskListService;
@property (strong, nonatomic) AFAProcessServices    *fetchProcessInstanceDetailsService;
@property (strong, nonatomic) AFAProcessServices    *fetchProcessInstanceContentService;
@property (strong, nonatomic) AFAProcessServices    *fetchProcessInstanceCommentsService;
@property (strong, nonatomic) AFAProcessServices    *deleteProcessInstanceService;

// Models
@property (strong, nonatomic) AFATableControllerProcessInstanceTasksModel *cachedProcessInstanceTasksModel;
@property (strong, nonatomic) AFATableControllerProcessInstanceTasksModel *remoteProcessInstanceTasksModel;
@property (strong, nonatomic) NSError               *cachedTaskListError;
@property (strong, nonatomic) NSError               *remoteTaskListError;

@end

@implementation AFAProcessInstanceDetailsDataSource

- (instancetype)initWithProcessInstanceID:(NSString *)processInstanceID
                               themeColor:(UIColor *)themeColor {
    self = [super init];
    
    if (self) {
        _processInstanceID = processInstanceID;
        _themeColor = themeColor;
        _sectionModels = [NSMutableDictionary dictionary];
        _cellFactories = [NSMutableDictionary dictionary];
        _tableController = [AFATableController new];
        
        _fetchActiveTaskListService = [AFAQueryServices new];
        _fetchCompletedTaskListService = [AFAQueryServices new];
        _fetchProcessInstanceDetailsService = [AFAProcessServices new];
        _fetchProcessInstanceContentService = [AFAProcessServices new];
        _fetchProcessInstanceCommentsService = [AFAProcessServices new];
        _deleteProcessInstanceService = [AFAProcessServices new];
        
        [self setUpCellFactoriesWithThemeColor:themeColor];
        
        // Set the default cell factory to process instace details
        self.tableController.cellFactory = [self cellFactoryForSectionType:AFAProcessInstanceDetailsSectionTypeDetails];
    }
    
    return self;
}


#pragma mark -
#pragma mark Public interface

- (void)processInstanceDetailsWithCompletionBlock:(AFAProcessInstanceDetailsDataSourceCompletionBlock)completionBlock
                               cachedResultsBlock:(AFAProcessInstanceDetailsDataSourceCompletionBlock)cachedResultsBlock {
    __weak typeof(self) weakSelf = self;
    [self.fetchProcessInstanceDetailsService
     requestProcessInstanceDetailsForID:self.processInstanceID
     completionBlock:^(ASDKModelProcessInstance *processInstance, NSError *error) {
         __strong typeof(self) strongSelf = weakSelf;
         
         BOOL registerCellActions = NO;
         
         if (!error) {
             registerCellActions = [strongSelf registerProcessInstanceDetailsCellActionsForModel:processInstance];
         }
         
         if (completionBlock) {
             completionBlock(error, registerCellActions);
         }
         
     } cachedResults:^(ASDKModelProcessInstance *processInstance, NSError *error) {
         __strong typeof(self) strongSelf = weakSelf;
         
         BOOL registerCellActions = NO;
         
         if (!error) {
             registerCellActions = [strongSelf registerProcessInstanceDetailsCellActionsForModel:processInstance];
         }
         
         if (completionBlock) {
             completionBlock(error, registerCellActions);
         }
     }];
}

- (void)processInstanceActiveAndCompletedTasksWithCompletionBlock:(AFAProcessInstanceDataSourceErrorCompletionBlock)completionBlock
                                               cachedResultsBlock:(AFAProcessInstanceDataSourceErrorCompletionBlock)cachedResultsBlock {
    /* Active and completed tasks information is comprised out of multiple services
     * aggregations
     * 1. Fetch the active tasks for the current process instance
     * 2. Fetch the completed tasks for the current process instance
     */
    AFATableControllerProcessInstanceDetailsModel *processInstanceDetailsModel = [self reusableTableControllerModelForSectionType:AFAProcessInstanceDetailsSectionTypeDetails];
    
    self.cachedProcessInstanceTasksModel = [AFATableControllerProcessInstanceTasksModel new];
    self.cachedProcessInstanceTasksModel.isStartFormDefined = processInstanceDetailsModel.currentProcessInstance.isStartFormDefined;
    
    self.remoteProcessInstanceTasksModel = [AFATableControllerProcessInstanceTasksModel new];
    self.remoteProcessInstanceTasksModel.isStartFormDefined = processInstanceDetailsModel.currentProcessInstance.isStartFormDefined;
    
    dispatch_group_t remoteTaskListGroup = dispatch_group_create();
    dispatch_group_t cachedTaskListGroup = dispatch_group_create();
    
    // 1
    dispatch_group_enter(remoteTaskListGroup);
    dispatch_group_enter(cachedTaskListGroup);
    
    AFAGenericFilterModel *activeTasksFilter = [AFAGenericFilterModel new];
    activeTasksFilter.processInstanceID = self.processInstanceID;
    [self fetchProcessInstanceActiveTasksWithFilter:activeTasksFilter
                                remoteDispatchGroup:remoteTaskListGroup
                                cachedDispatchGroup:cachedTaskListGroup];
    
    // 2
    dispatch_group_enter(remoteTaskListGroup);
    dispatch_group_enter(cachedTaskListGroup);
    
    AFAGenericFilterModel *completedTasksFilter = [AFAGenericFilterModel new];
    completedTasksFilter.processInstanceID = self.processInstanceID;
    completedTasksFilter.state = AFAGenericFilterStateTypeCompleted;
    
    [self fetchProcessInstanceCompletedTasksWithFilter:completedTasksFilter
                                   remoteDispatchGroup:remoteTaskListGroup
                                   cachedDispatchGroup:cachedTaskListGroup];
    
    // Report result once all prerequisites are met
    __weak typeof(self) weakSelf = self;
    dispatch_group_notify(cachedTaskListGroup, dispatch_get_main_queue(), ^{
        __strong typeof(self) strongSelf = weakSelf;
        
        if ([strongSelf.cachedProcessInstanceTasksModel hasTaskListAvailable]) {
            strongSelf.sectionModels[@(AFAProcessInstanceDetailsSectionTypeTaskStatus)] = strongSelf.cachedProcessInstanceTasksModel;
        }
        [strongSelf updateTableControllerForSectionType:AFAProcessInstanceDetailsSectionTypeTaskStatus];
        
        if (cachedResultsBlock) {
            cachedResultsBlock(strongSelf.cachedTaskListError);
        }
    });
    
    dispatch_group_notify(remoteTaskListGroup, dispatch_get_main_queue(), ^{
        __strong typeof(self) strongSelf = weakSelf;
        
        if ([strongSelf.remoteProcessInstanceTasksModel hasTaskListAvailable]) {
            strongSelf.sectionModels[@(AFAProcessInstanceDetailsSectionTypeTaskStatus)] = strongSelf.remoteProcessInstanceTasksModel;
        }
        [strongSelf updateTableControllerForSectionType:AFAProcessInstanceDetailsSectionTypeTaskStatus];
        
        if (completionBlock) {
            completionBlock(strongSelf.remoteTaskListError);
        }
    });
}

- (void)processInstanceContentWithCompletionBlock:(AFAProcessInstanceDataSourceErrorCompletionBlock)completionBlock
                               cachedResultsBlock:(AFAProcessInstanceDataSourceErrorCompletionBlock)cachedResultsBlock {
    __weak typeof(self) weakSelf = self;
    [self.fetchProcessInstanceContentService
     requestProcessInstanceContentForProcessInstanceID:self.processInstanceID
     completionBlock:^(NSArray *contentList, NSError *error) {
         __strong typeof(self) strongSelf = weakSelf;
         
         if (!error) {
             [strongSelf handleProcessInstanceContentListResponse:contentList];
         }
         
         if (completionBlock) {
             completionBlock(error);
         }
     } cachedResults:^(NSArray *contentList, NSError *error) {
         __strong typeof(self) strongSelf = weakSelf;
         
         if (!error) {
             [strongSelf handleProcessInstanceContentListResponse:contentList];
         }
         
         if (cachedResultsBlock) {
             cachedResultsBlock(error);
         }
     }];
}

- (void)processInstanceCommentsWithCompletionBlock:(AFAProcessInstanceDataSourceErrorCompletionBlock)completionBlock
                                cachedResultsBlock:(AFAProcessInstanceDataSourceErrorCompletionBlock)cachedResultsBlock {
    __weak typeof(self) weakSelf = self;
    [self.fetchProcessInstanceCommentsService
     requestProcessInstanceCommentsForID:self.processInstanceID
     withCompletionBlock:^(NSArray *commentList, NSError *error, ASDKModelPaging *paging) {
         __strong typeof(self) strongSelf = weakSelf;
         
         if (!error) {
             [strongSelf handleProcessInstanceCommentListResponse:commentList
                                                           paging:paging];
         }
         
         if (completionBlock) {
             completionBlock(error);
         }
     } cachedResults:^(NSArray *commentList, NSError *error, ASDKModelPaging *paging) {
         __strong typeof(self) strongSelf = weakSelf;
         
         if (!error) {
             [strongSelf handleProcessInstanceCommentListResponse:commentList
                                                           paging:paging];
         }
         
         if (cachedResultsBlock) {
             cachedResultsBlock(error);
         }
     }];
}

- (void)deleteCurrentProcessInstanceWithCompletionBlock:(void (^)(NSError *error))completionBlock {
    [self.deleteProcessInstanceService requestDeleteProcessInstanceWithID:self.processInstanceID
                                                          completionBlock:^(BOOL isProcessInstanceDeleted, NSError *error) {
                                                              if (completionBlock) {
                                                                  completionBlock(error);
                                                              }
                                                          }];
}

- (id)cellFactoryForSectionType:(AFAProcessInstanceDetailsSectionType)sectionType {
    return self.cellFactories[@(sectionType)];
}

- (id)reusableTableControllerModelForSectionType:(AFAProcessInstanceDetailsSectionType)sectionType {
    id reusableObject = nil;
    
    reusableObject = self.sectionModels[@(sectionType)];
    if (!reusableObject) {
        switch (sectionType) {
            case AFAProcessInstanceDetailsSectionTypeDetails: {
                reusableObject = [AFATableControllerProcessInstanceDetailsModel new];
            }
                break;
            case AFAProcessInstanceDetailsSectionTypeTaskStatus: {
                reusableObject = [AFATableControllerProcessInstanceTasksModel new];
            }
                break;
                
            case AFAProcessInstanceDetailsSectionTypeContent: {
                reusableObject = [AFATableControllerProcessInstanceContentModel new];
            }
                break;
                
            case AFAProcessInstanceDetailsSectionTypeComments: {
                reusableObject = [AFATableControllerCommentModel new];
            }
                
            default:
                break;
        }
    }
    
    return reusableObject;
}

- (void)updateTableControllerForSectionType:(AFAProcessInstanceDetailsSectionType)sectionType {
    self.tableController.model = [self reusableTableControllerModelForSectionType:sectionType];
    self.tableController.cellFactory = [self cellFactoryForSectionType:sectionType];
}


#pragma mark -
#pragma mark Response handlers

- (BOOL)registerProcessInstanceDetailsCellActionsForModel:(ASDKModelProcessInstance *)processInstance {
    BOOL registerCellActions = NO;
    
    AFATableControllerProcessInstanceDetailsModel *processInstanceDetailsModel = [AFATableControllerProcessInstanceDetailsModel new];
    processInstanceDetailsModel.isConnectivityAvailable = self.isConnectivityAvailable;
    processInstanceDetailsModel.currentProcessInstance = processInstance;
    
    if (!self.sectionModels[@(AFAProcessInstanceDetailsSectionTypeDetails)]) {
        // Cell actions for all the cell factories are registered after the initial process instance
        // details are loaded
        registerCellActions = YES;
    }
    
    self.sectionModels[@(AFAProcessInstanceDetailsSectionTypeDetails)] = processInstanceDetailsModel;
    [self updateTableControllerForSectionType:AFAProcessInstanceDetailsSectionTypeDetails];
    
    return registerCellActions;
}

- (void)handleProcessInstanceContentListResponse:(NSArray *)contentList {
    AFATableControllerProcessInstanceContentModel *processInstanceContentModel = [AFATableControllerProcessInstanceContentModel new];
    processInstanceContentModel.attachedContentArr = contentList;
    self.sectionModels[@(AFAProcessInstanceDetailsSectionTypeContent)] = processInstanceContentModel;
    [self updateTableControllerForSectionType:AFAProcessInstanceDetailsSectionTypeContent];
    self.tableController.isEditable = NO;
}

- (void)handleProcessInstanceCommentListResponse:(NSArray *)commentList
                                          paging:(ASDKModelPaging *)paging {
    // Extract the updated result
    AFATableControllerCommentModel *processInstanceCommentModel = [AFATableControllerCommentModel new];
    
    NSSortDescriptor *newestCommentsSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:NSStringFromSelector(@selector(creationDate))
                                                                                   ascending:NO];
    processInstanceCommentModel.commentListArr = [commentList sortedArrayUsingDescriptors:@[newestCommentsSortDescriptor]];
    processInstanceCommentModel.paging = paging;
    self.sectionModels[@(AFAProcessInstanceDetailsSectionTypeComments)] = processInstanceCommentModel;
    [self updateTableControllerForSectionType:AFAProcessInstanceDetailsSectionTypeComments];
}


#pragma mark -
#pragma mark Private interface

- (void)setUpCellFactoriesWithThemeColor:(UIColor *)themeColor {
    // Register process instance details cell factory
    AFATableControllerProcessInstanceDetailsCellFactory *processInstanceDetailsCellFactory = [AFATableControllerProcessInstanceDetailsCellFactory new];
    processInstanceDetailsCellFactory.appThemeColor = themeColor;
    
    // Register process instance task status cell factory
    AFATableControllerProcessInstanceTasksCellFactory *processInstanceTasksCellFactory = [AFATableControllerProcessInstanceTasksCellFactory new];
    processInstanceTasksCellFactory.appThemeColor = themeColor;
    
    // Register process instance content cell factory
    AFATableControllerContentCellFactory *processInstanceContentCellFactory = [AFATableControllerContentCellFactory new];
    processInstanceContentCellFactory.appThemeColor = themeColor;
    
    // Register process instance comments cell factory
    AFATableControllerCommentCellFactory *processInstanceDetailsCommentCellFactory = [AFATableControllerCommentCellFactory new];
    
    self.cellFactories[@(AFAProcessInstanceDetailsSectionTypeDetails)] = processInstanceDetailsCellFactory;
    self.cellFactories[@(AFAProcessInstanceDetailsSectionTypeTaskStatus)] = processInstanceTasksCellFactory;
    self.cellFactories[@(AFAProcessInstanceDetailsSectionTypeContent)] = processInstanceContentCellFactory;
    self.cellFactories[@(AFAProcessInstanceDetailsSectionTypeComments)] = processInstanceDetailsCommentCellFactory;
}

- (void)fetchProcessInstanceActiveTasksWithFilter:(AFAGenericFilterModel *)filter
                              remoteDispatchGroup:(dispatch_group_t)remoteDispatchGroup
                              cachedDispatchGroup:(dispatch_group_t)cachedDispatchGroup {
    __weak typeof(self) weakSelf = self;
    
    [self.fetchActiveTaskListService requestTaskListWithFilter:filter
                                               completionBlock:^(NSArray *taskList, NSError *error, ASDKModelPaging *paging) {
                                                   __strong typeof(self) strongSelf = weakSelf;
                                                   
                                                   strongSelf.remoteTaskListError = error;
                                                   
                                                   if (!error) {
                                                       strongSelf.remoteProcessInstanceTasksModel.activeTasks = taskList;
                                                   }
                                                   
                                                   dispatch_group_leave(remoteDispatchGroup);
                                               } cachedResults:^(NSArray *taskList, NSError *error, ASDKModelPaging *paging) {
                                                   __strong typeof(self) strongSelf = weakSelf;
                                                   
                                                   strongSelf.cachedTaskListError = error;
                                                   
                                                   if (!error) {
                                                       strongSelf.cachedProcessInstanceTasksModel.activeTasks = taskList;
                                                   }
                                                   
                                                   dispatch_group_leave(cachedDispatchGroup);
                                               }];
}

- (void)fetchProcessInstanceCompletedTasksWithFilter:(AFAGenericFilterModel *)filter
                                 remoteDispatchGroup:(dispatch_group_t)remoteDispatchGroup
                                 cachedDispatchGroup:(dispatch_group_t)cachedDispatchGroup {
    __weak typeof(self) weakSelf = self;
    
    [self.fetchCompletedTaskListService requestTaskListWithFilter:filter
                                                  completionBlock:^(NSArray *taskList, NSError *error, ASDKModelPaging *paging) {
                                                      __strong typeof(self) strongSelf = weakSelf;
                                                      
                                                      strongSelf.remoteTaskListError = error;
                                                      
                                                      if (!error) {
                                                          strongSelf.remoteProcessInstanceTasksModel.completedTasks = taskList;
                                                      }
                                                      
                                                      dispatch_group_leave(remoteDispatchGroup);
                                                  } cachedResults:^(NSArray *taskList, NSError *error, ASDKModelPaging *paging) {
                                                      __strong typeof(self) strongSelf = weakSelf;
                                                      
                                                      strongSelf.cachedTaskListError = error;
                                                      
                                                      if (!error) {
                                                          strongSelf.cachedProcessInstanceTasksModel.completedTasks = taskList;
                                                      }
                                                      
                                                      dispatch_group_leave(cachedDispatchGroup);
                                                  }];
}

@end

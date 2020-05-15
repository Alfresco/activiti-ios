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

#import "AFATaskListViewDataSource.h"

// Constants
#import "AFAUIConstants.h"

// Models
#import "AFAListResponseModel.h"

// Cells
#import "AFATaskListStyleCell.h"

// View controllers
#import "AFAFilterViewController.h"

// Managers
#import "AFATaskServices.h"

@interface AFATaskListViewDataSource ()

@property (strong, nonatomic) AFATaskServices *fetchTaskListService;

@end

@implementation AFATaskListViewDataSource


#pragma mark -
#pragma mark Public interface

- (instancetype)initWithDataEntries:(NSArray *)dataEntries
                         themeColor:(UIColor *)themeColor {
    self = [super init];
    if (self) {
        _tasks = dataEntries;
        _themeColor = themeColor;
        _fetchTaskListService = [AFATaskServices new];
    }
    
    return self;
}

- (NSArray *)dataEntries {
    return self.tasks;
}

- (void)loadFilterListForController:(AFAFilterViewController *)filterController {
    [filterController loadTaskFilterList];
}

- (void)loadContentListForFilter:(AFAGenericFilterModel *)filter
             withCompletionBlock:(AFAListHandleCompletionBlock)completionBlock
                   cachedResults:(AFAListHandleCompletionBlock)cacheCompletionBlock {
    __weak typeof(self) weakSelf = self;
    [self.fetchTaskListService requestTaskListWithFilter:filter
                                         completionBlock:^(NSArray *taskList, NSError *error, ASDKModelPaging *paging) {
                                             __strong typeof(self) strongSelf = weakSelf;
                                             completionBlock(strongSelf, [self responseModelForTaskList:taskList
                                                                                                  error:error
                                                                                                  paging:paging]);
                                         } cachedResults:^(NSArray *taskList, NSError *error, ASDKModelPaging *paging) {
                                             __strong typeof(self) strongSelf = weakSelf;
                                             
                                             cacheCompletionBlock(strongSelf, [self responseModelForTaskList:taskList
                                                                                                       error:error
                                                                                                       paging:paging]);
                                         }];
}

- (void)processAdditionalEntries:(NSArray *)additionalEntriesArr
                       forPaging:(ASDKModelPaging *)paging {
    _tasks = [self processAdditionalEntries:additionalEntriesArr
                         forExistingEntries:self.tasks
                                     paging:paging];
    
    // When loading a new list, compute the total number of pages
    // but reset it only when completely loading another list
    if (!paging.start) {
        _totalPages = [self totalPagesForPaging:paging
                                    dataEntries:_tasks];
    }
    
    _preloadCellIdx = [self preloadCellIndexForPaging:paging
                                          dataEntries:_tasks];
}

- (AFAListResponseModel *)responseModelForTaskList:(NSArray *)taskList
                                             error:(NSError *)error
                                             paging:(ASDKModelPaging *)paging {
    AFAListResponseModel *response = [AFAListResponseModel new];
    response.objectList = taskList;
    response.error = error;
    response.paging = paging;
    
    return response;
}


#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    return self.tasks.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AFATaskListStyleCell *listCell = [tableView dequeueReusableCellWithIdentifier:kCellIDTaskListStyle];
    [listCell setupWithTask:self.tasks[indexPath.row]];
    listCell.applicationThemeColor = self.themeColor;
    
    return listCell;
}

@end

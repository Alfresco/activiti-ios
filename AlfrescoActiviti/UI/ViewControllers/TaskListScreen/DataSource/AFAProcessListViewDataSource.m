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

#import "AFAProcessListViewDataSource.h"

// Constants
#import "AFAUIConstants.h"

// Models
#import "AFAGenericFilterModel.h"
#import "AFAListResponseModel.h"

// Cells
#import "AFATaskListStyleCell.h"

// View controllers
#import "AFAFilterViewController.h"

// Managers
#import "AFAProcessServices.h"

@interface AFAProcessListViewDataSource ()

@property (strong, nonatomic) AFAProcessServices *fetchProcessInstanceListService;

@end

@implementation AFAProcessListViewDataSource


#pragma mark -
#pragma mark Public interface

- (instancetype)initWithDataEntries:(NSArray *)dataEntries
                         themeColor:(UIColor *)themeColor {
    self = [super init];
    if (self) {
        _processInstances = dataEntries;
        _themeColor = themeColor;
        _fetchProcessInstanceListService = [AFAProcessServices new];
    }
    
    return self;
}

- (NSArray *)dataEntries {
    return _processInstances;
}

- (void)loadFilterListForController:(AFAFilterViewController *)filterController {
    [filterController loadProcessInstanceFilterList];
}

- (void)loadContentListForFilter:(AFAGenericFilterModel *)filter
             withCompletionBlock:(AFAListHandleCompletionBlock)completionBlock
                   cachedResults:(AFAListHandleCompletionBlock)cacheCompletionBlock {
    __weak typeof(self) weakSelf = self;
    [self.fetchProcessInstanceListService
     requestProcessInstanceListWithFilter:filter
     withCompletionBlock:^(NSArray *processInstanceList, NSError *error, ASDKModelPaging *paging) {
         __strong typeof(self) strongSelf = weakSelf;
         
         completionBlock(strongSelf, [strongSelf responseModelForProcessInstanceList:processInstanceList
                                                                               error:error
                                                                              paging:paging]);
     } cachedResults:^(NSArray *processInstanceList, NSError *error, ASDKModelPaging *paging) {
         __strong typeof(self) strongSelf = weakSelf;
         
         completionBlock(strongSelf, [strongSelf responseModelForProcessInstanceList:processInstanceList
                                                                               error:error
                                                                              paging:paging]);
     }];
}

- (void)processAdditionalEntries:(NSArray *)additionalEntriesArr
                       forPaging:(ASDKModelPaging *)paging {
    _processInstances = [self processAdditionalEntries:additionalEntriesArr
                                    forExistingEntries:self.processInstances
                                                paging:paging];
    
    // When loading a new list, compute the total number of pages
    // but reset it only when completely loading another list
    if (!paging.start) {
        _totalPages = [self totalPagesForPaging:paging
                                    dataEntries:_processInstances];
    }
    
    _preloadCellIdx = [self preloadCellIndexForPaging:paging
                                          dataEntries:_processInstances];
}

- (AFAListResponseModel *)responseModelForProcessInstanceList:(NSArray *)processInstanceList
                                                        error:(NSError *)error
                                                       paging:(ASDKModelPaging *)paging {
    AFAListResponseModel *response = [AFAListResponseModel new];
    response.objectList = processInstanceList;
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
    return self.processInstances.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AFATaskListStyleCell *listCell = [tableView dequeueReusableCellWithIdentifier:kCellIDTaskListStyle];
    [listCell setupWithProcessInstance:self.processInstances[indexPath.row]];
    listCell.applicationThemeColor = self.themeColor;
    
    return listCell;
}

@end

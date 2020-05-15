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

#import "AFATableControllerProcessInstanceDetailsCellFactory.h"

// Cells
#import "AFANameTableViewCell.h"
#import "AFAShowDiagramTableViewCell.h"
#import "AFACreatedDateTableViewCell.h"
#import "AFAAssigneeTableViewCell.h"
#import "AFACompletedDateTableViewCell.h"
#import "AFAAuditLogTableViewCell.h"

// Constants
#import "AFAUIConstants.h"

// Model
#import "AFATableControllerProcessInstanceDetailsModel.h"

@interface AFATableControllerProcessInstanceDetailsCellFactory () <AFAShowDiagramTableViewCellDelegate,
                                                                   AFAAuditLogTableViewCellDelegate>

@end

@implementation AFATableControllerProcessInstanceDetailsCellFactory

#pragma mark -
#pragma mark AFATableViewCellFactory Delegate

- (UITableViewCell *)tableView:(UITableView *)tableView
              cellForIndexPath:(NSIndexPath *)indexPath
                      forModel:(id<AFATableViewModelDelegate>)model {
    UITableViewCell *cell = nil;
    
    AFATableControllerProcessInstanceDetailsModel *currentModel = (AFATableControllerProcessInstanceDetailsModel *)model;
    
    if (![currentModel isCompletedProcessInstance]) {
        // Handle process instance details cell section rows
        switch (indexPath.row) {
            case AFAProcessInstanceDetailsCellTypeProcessName: {
                cell = [self dequeuedNameCellAtIndexPath:indexPath
                                           fromTableView:tableView
                                               withModel:currentModel];
            }
                break;
                
            case AFAProcessInstanceDetailsCellTypeShowDiagram: {
                cell = [self dequeuedShowDiagramCellAtIndexPath:indexPath
                                                fromTableView:tableView
                                                    withModel:currentModel];
            }
                break;
                
            case AFAProcessInstanceDetailsCellTypeStartedBy: {
                cell = [self dequeuedStartedByCellAtIndexPath:indexPath
                                                fromTableView:tableView
                                                    withModel:currentModel];
                
            }
                break;
                
            case AFAProcessInstanceDetailsCellTypeStartDate: {
                cell = [self dequeuedStartedCellAtIndexPath:indexPath
                                              fromTableView:tableView
                                                  withModel:currentModel];
            }
                break;
                
            default:
                break;
        }
    } else {
        // Handle completed process instance details cell section rows
        switch (indexPath.row) {
            case AFACompletedProcessInstanceDetailsCellTypeProcessName: {
                cell = [self dequeuedNameCellAtIndexPath:indexPath
                                           fromTableView:tableView
                                               withModel:currentModel];
            }
                break;
                
            case AFACompletedProcessInstanceDetailsCellTypeShowDiagram: {
                cell = [self dequeuedShowDiagramCellAtIndexPath:indexPath
                                                  fromTableView:tableView
                                                      withModel:currentModel];
            }
                break;
                
            case AFACompletedProcessInstanceDetailsCellTypeStartedBy: {
                cell = [self dequeuedStartedByCellAtIndexPath:indexPath
                                                fromTableView:tableView
                                                    withModel:currentModel];
            }
                break;
                
            case AFACompletedProcessInstanceDetailsCellTypeStartDate: {
                cell = [self dequeuedStartedCellAtIndexPath:indexPath
                                              fromTableView:tableView
                                                  withModel:currentModel];
            }
                break;
                
            case AFACompletedProcessInstanceDetailsCellTypeEndDate: {
                cell = [self dequedCompletedDateCellAtIndexPath:indexPath
                                                  fromTableView:tableView
                                                      withModel:currentModel];
            }
                break;
                
            case AFACompletedProcessInstanceDetailsCellTypeAuditLog: {
                cell = [self dequeuedAuditLogCellAtIndexPath:indexPath
                                               fromTableView:tableView
                                                   withModel:currentModel];
            }
                break;
                
            default:
                break;
        }
        
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath
         forModel:(id<AFATableViewModelDelegate>)model {
    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    
    // Explictly set your cell's layout margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}


#pragma mark -
#pragma mark AFAShowDiagramTableViewCell Delegate

- (void)onProcessControl {
    AFATableControllerCellActionBlock actionBlock = [self actionForCellOfType:AFAProcessInstanceDetailsCellTypeProcessControl];
    if (actionBlock) {
        actionBlock(nil);
    }
}

- (void)onShowDiagram {
    // TODO: Add implementation
}


#pragma mark -
#pragma mark AFAAuditLogTableViewCellDelegate

- (void)onViewAuditLog {
    AFATableControllerCellActionBlock actionBlock = [self actionForCellOfType:AFACompletedProcessInstanceDetailsCellTypeAuditLog];
    if (actionBlock) {
        actionBlock(nil);
    }
}


#pragma mark -
#pragma mark Public interface

- (NSInteger)cellTypeForProcessControlCell {
    return AFAProcessInstanceDetailsCellTypeProcessControl;
}

- (NSInteger)cellTypeForAuditLogCell {
    return AFACompletedProcessInstanceDetailsCellTypeAuditLog;
}


#pragma mark -
#pragma mark Convenience methods

- (UITableViewCell *)dequeuedNameCellAtIndexPath:(NSIndexPath *)indexPath
                                   fromTableView:(UITableView *)tableView
                                       withModel:(id<AFATableViewModelDelegate>)model {
    AFANameTableViewCell *nameCell = [tableView dequeueReusableCellWithIdentifier:kCellIDProcessInstanceDetailsName
                                                                     forIndexPath:indexPath];
    [nameCell setUpCellWithProcessInstance:[model itemAtIndexPath:indexPath]];
    
    return nameCell;
}

- (UITableViewCell *)dequeuedShowDiagramCellAtIndexPath:(NSIndexPath *)indexPath
                                        fromTableView:(UITableView *)tableView
                                            withModel:(id<AFATableViewModelDelegate>)model {
    AFAShowDiagramTableViewCell *showDiagramCell = [tableView dequeueReusableCellWithIdentifier:kCellIDProcessInstanceDetailsShowDiagram
                                                                                   forIndexPath:indexPath];
    showDiagramCell.delegate = self;
    [showDiagramCell setupWithProcessInstance:[model itemAtIndexPath:indexPath]];
    [showDiagramCell setUpWithThemeColor:self.appThemeColor];
    [showDiagramCell updateStateForConnectivity:[(AFATableControllerProcessInstanceDetailsModel *)model isConnectivityAvailable]];
    
    return showDiagramCell;
}

- (UITableViewCell *)dequeuedStartedByCellAtIndexPath:(NSIndexPath *)indexPath
                                        fromTableView:(UITableView *)tableView
                                            withModel:(id<AFATableViewModelDelegate>)model {
    AFAAssigneeTableViewCell *assigneeCell = [tableView dequeueReusableCellWithIdentifier:kCellIDProcessInstanceDetailsStartedBy
                                                                             forIndexPath:indexPath];
    [assigneeCell setupCellWithProcessInstance:[model itemAtIndexPath:indexPath]];
    return assigneeCell;
}

- (UITableViewCell *)dequeuedStartedCellAtIndexPath:(NSIndexPath *)indexPath
                                      fromTableView:(UITableView *)tableView
                                          withModel:(id<AFATableViewModelDelegate>)model {
    AFACreatedDateTableViewCell *startedDateCell = [tableView dequeueReusableCellWithIdentifier:kCellIDProcessInstanceDetailsStarted
                                                                                   forIndexPath:indexPath];
    [startedDateCell setUpCellWithProcessInstance:[model itemAtIndexPath:indexPath]];
    
    return startedDateCell;
}

- (UITableViewCell *)dequedCompletedDateCellAtIndexPath:(NSIndexPath *)indexPath
                                          fromTableView:(UITableView *)tableView
                                              withModel:(id<AFATableViewModelDelegate>)model {
    AFACompletedDateTableViewCell *completedDateCell = [tableView dequeueReusableCellWithIdentifier:kCellIDProcessInstanceDetailsCompletedDate
                                                                                       forIndexPath:indexPath];
    [completedDateCell setupCellWithProcessInstance:[model itemAtIndexPath:indexPath]];
    
    return completedDateCell;
}

- (UITableViewCell *)dequeuedAuditLogCellAtIndexPath:(NSIndexPath *)indexPath
                                       fromTableView:(UITableView *)tableView
                                           withModel:(id<AFATableViewModelDelegate>)model {
    AFAAuditLogTableViewCell *auditLogCell = [tableView dequeueReusableCellWithIdentifier:kCellIDAuditLog
                                                                             forIndexPath:indexPath];
    auditLogCell.delegate = self;
    
    return auditLogCell;
}

@end

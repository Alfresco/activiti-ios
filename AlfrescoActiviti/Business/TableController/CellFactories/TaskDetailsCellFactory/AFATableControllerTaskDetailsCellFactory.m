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

#import "AFATableControllerTaskDetailsCellFactory.h"

// Cells
#import "AFANameTableViewCell.h"
#import "AFACompleteTableViewCell.h"
#import "AFARequeueTableViewCell.h"
#import "AFAAssigneeTableViewCell.h"
#import "AFADueTableViewCell.h"
#import "AFADescriptionTableViewCell.h"
#import "AFACreatedDateTableViewCell.h"
#import "AFAProcessMembershipTableViewCell.h"
#import "AFATaskMembershipTableViewCell.h"
#import "AFACompletedDateTableViewCell.h"
#import "AFADurationTableViewCell.h"
#import "AFAClaimTableViewCell.h"
#import "AFAAuditLogTableViewCell.h"
#import "AFAAttachFormTableViewCell.h"

// Constants
#import "AFAUIConstants.h"
#import "AFABusinessConstants.h"

// Model
#import "AFATableControllerTaskDetailsModel.h"

@interface AFATableControllerTaskDetailsCellFactory () <AFADueTableViewCellDelegate,
AFACompleteTableViewCellDelegate,
AFAProcessMembershipTableViewCellDelegate,
AFATaskMembershipTableViewCellDelegate,
AFAClaimTableViewCellDelegate,
AFAAssigneeTableViewCellDelegate,
AFAAuditLogTableViewCellDelegate,
AFAAttachFormTableViewCellDelegate>

@end

@implementation AFATableControllerTaskDetailsCellFactory


#pragma mark -
#pragma mark AFATableViewCellFactoryDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView
              cellForIndexPath:(NSIndexPath *)indexPath
                      forModel:(id<AFATableViewModelDelegate>)model {
    UITableViewCell *cell = nil;
    AFATableControllerTaskDetailsModel *currentModel = (AFATableControllerTaskDetailsModel *)model;
    
    if (![currentModel isCompletedTask]) {
        if ([currentModel isFormDefined]) {
            if ([currentModel canBeRequeued]) {
                cell = [self taskDetailsCellOfRequeueableTaskWithDefinedFormForIndexPath:indexPath
                                                                               tableView:tableView
                                                                                   model:currentModel];
            } else if ([currentModel isClaimableTask]) {
                cell = [self taskDetailsCellOfTaskWithoutDefinedFormForIndexPath:indexPath
                                                                       tableView:tableView
                                                                           model:currentModel];
            } else {
                cell = [self taskDetailsCellOfTaskWithDefinedFormForIndexPath:indexPath
                                                                    tableView:tableView
                                                                        model:currentModel];
            }
        } else {
            cell = [self taskDetailsCellOfTaskWithoutDefinedFormForIndexPath:indexPath
                                                                   tableView:tableView
                                                                       model:currentModel];
        }
    } else {
        cell = [self completedCellForIndexPath:indexPath
                                     tableView:tableView
                                         model:currentModel];
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
#pragma mark AFAAssigneeTableViewCellDelegate

- (void)onChangeAssignee {
    AFATableControllerCellActionBlock actionBlock = [self actionForCellOfType:AFATaskDetailsCellTypeReAssign];
    if (actionBlock) {
        actionBlock(nil);
    }
}


#pragma mark -
#pragma mark AFADueTableViewCellDelegate

- (void)onAddDueDateTap {
    AFATableControllerCellActionBlock actionBlock = [self actionForCellOfType:AFATaskDetailsCellTypeDue];
    if (actionBlock) {
        actionBlock(nil);
    }
}


#pragma mark -
#pragma mark AFACompleteTableViewCellDelegate

- (void)onCompleteTask {
    AFATableControllerCellActionBlock actionBlock = [self actionForCellOfType:AFATaskDetailsCellTypeComplete];
    if (actionBlock) {
        actionBlock(nil);
    }
}

- (void)onRequeueTask {
    AFATableControllerCellActionBlock actionBlock = [self actionForCellOfType:AFATaskDetailsCellTypeRequeue];
    if (actionBlock) {
        actionBlock(nil);
    }
}


#pragma mark -
#pragma mark AFAProcessMembershipTableViewCellDelegate

- (void)onViewProcessTap {
    AFATableControllerCellActionBlock actionBlock = [self actionForCellOfType:AFATaskDetailsCellTypePartOf];
    if (actionBlock) {
        actionBlock(@{kCellFactoryCellParameterActionType : @(AFATaskDetailsPartOfCellTypeProcess)});
    }
}


#pragma mark -
#pragma mark AFATaskMembershipTableViewCellDelegate

- (void)onViewTaskTap {
    AFATableControllerCellActionBlock actionBlock = [self actionForCellOfType:AFATaskDetailsCellTypePartOf];
    if (actionBlock) {
        actionBlock(@{kCellFactoryCellParameterActionType : @(AFATaskDetailsPartOfCellTypeTask)});
    }
}


#pragma mark -
#pragma mark AFAClaimTableViewCellDelegate

- (void)onClaimTask {
    AFATableControllerCellActionBlock actionBlock = [self actionForCellOfType:AFATaskDetailsCellTypeClaim];
    if (actionBlock) {
        actionBlock(nil);
    }
}


#pragma mark -
#pragma mark AFAAuditLogTableViewCellDelegate

- (void)onViewAuditLog {
    AFATableControllerCellActionBlock actionBlock = [self actionForCellOfType:AFACompletedTaskDetailsCellTypeAuditLog];
    if (actionBlock) {
        actionBlock(nil);
    }
}


#pragma mark -
#pragma mark AFAAttachFormTableViewCellDelegate

- (void)onViewAttachedFormTap {
    AFATableControllerCellActionBlock actionBlock = [self actionForCellOfType:AFADefinedFormTaskDetailsCellTypeAttachedForm];
    if (actionBlock) {
        actionBlock(nil);
    }
}


#pragma mark -
#pragma mark Public interface

- (NSInteger)cellTypeForDueDateCell {
    return AFATaskDetailsCellTypeDue;
}

- (NSInteger)cellTypeForCompleteCell {
    return AFATaskDetailsCellTypeComplete;
}

- (NSInteger)cellTypeForPartOfCell {
    return AFATaskDetailsCellTypePartOf;
}

- (NSInteger)cellTypeForClaimCell {
    return AFATaskDetailsCellTypeClaim;
}

- (NSInteger)cellTypeForRequeueCell {
    return AFATaskDetailsCellTypeRequeue;
}

- (NSInteger)cellTypeForReAssignCell {
    return AFATaskDetailsCellTypeReAssign;
}

- (NSInteger)cellTypeForAuditLogCell {
    return AFACompletedTaskDetailsCellTypeAuditLog;
}

- (NSInteger)cellTypeForAttachedFormCell {
    return AFADefinedFormTaskDetailsCellTypeAttachedForm;
}


#pragma mark -
#pragma mark Convenience methods

- (UITableViewCell *)taskDetailsCellOfTaskWithoutDefinedFormForIndexPath:(NSIndexPath *)indexPath
                                                               tableView:(UITableView *)tableView
                                                                   model:(AFATableControllerTaskDetailsModel *)model {
    switch (indexPath.row) {
        case AFATaskDetailsCellTypeTaskName: {
            return [self dequeuedNameCellAtIndexPath:indexPath
                                       fromTableView:tableView
                                           withModel:model];
        }
            
        case AFATaskDetailsCellTypeComplete: {
            // There are cases when the user needs to be displayed on the same
            // position as the complete cell with choices regarding claiming
            // and / or completing the task
            if ([model isClaimableTask]) {
                return [self dequeuedClaimCellAtIndexPath:indexPath
                                            fromTableView:tableView
                                                withModel:model];
            } else {
                return [self dequeuedCompleteCellAtIndexPath:indexPath
                                               fromTableView:tableView
                                                   withModel:model];
            }
        }
            
        case AFATaskDetailsCellTypeAssignee: {
            return [self dequeuedAssigneeCellAtIndexPath:indexPath
                                           fromTableView:tableView
                                               withModel:model];
        }
            
        case AFATaskDetailsCellTypeCreated: {
            return [self dequeuedCreatedDateCellAtIndexPath:indexPath
                                              fromTableView:tableView
                                                  withModel:model];
        }
            
        case AFATaskDetailsCellTypeDue: {
            return [self dequeuedDueCellAtIndexPath:indexPath
                                      fromTableView:tableView
                                          withModel:model];
        }
            
        case AFATaskDetailsCellTypePartOf: {
            if ([model isChecklistTask]) {
                return [self dequeuedTaskMembershipCellAtIndexPath:indexPath
                                                     fromTableView:tableView
                                                         withModel:model];
            } else {
                return [self dequeuedProcessMembershipCellAtIndexPath:indexPath
                                                        fromTableView:tableView
                                                            withModel:model];
            }
        }
            
        case AFATaskDetailsCellTypeDescription: {
            return [self dequeuedDescriptionCellAtIndexPath:indexPath
                                              fromTableView:tableView
                                                  withModel:model];
        }
            
        default: break;
    }
    
    return nil;
}

- (UITableViewCell *)taskDetailsCellOfTaskWithDefinedFormForIndexPath:(NSIndexPath *)indexPath
                                                            tableView:(UITableView *)tableView
                                                                model:(AFATableControllerTaskDetailsModel *)model {
    switch (indexPath.row) {
        case AFADefinedFormTaskDetailsCellTypeTaskName: {
            return [self dequeuedNameCellAtIndexPath:indexPath
                                       fromTableView:tableView
                                           withModel:model];
        }
            
        case AFADefinedFormTaskDetailsCellTypeAssignee: {
            return [self dequeuedAssigneeCellAtIndexPath:indexPath
                                           fromTableView:tableView
                                               withModel:model];
        }
            
        case AFADefinedFormTaskDetailsCellTypeCreated: {
            return [self dequeuedCreatedDateCellAtIndexPath:indexPath
                                              fromTableView:tableView
                                                  withModel:model];
        }
            
        case AFADefinedFormTaskDetailsCellTypeDue: {
            return [self dequeuedDueCellAtIndexPath:indexPath
                                      fromTableView:tableView
                                          withModel:model];
        }
            
        case AFADefinedFormTaskDetailsCellTypePartOf: {
            if ([model isChecklistTask]) {
                return [self dequeuedTaskMembershipCellAtIndexPath:indexPath
                                                     fromTableView:tableView
                                                         withModel:model];
            } else {
                return [self dequeuedProcessMembershipCellAtIndexPath:indexPath
                                                        fromTableView:tableView
                                                            withModel:model];
            }
        }
            
        case AFADefinedFormTaskDetailsCellTypeDescription: {
            return [self dequeuedDescriptionCellAtIndexPath:indexPath
                                              fromTableView:tableView
                                                  withModel:model];
        }
            
        case AFADefinedFormTaskDetailsCellTypeAttachedForm: {
            return [self dequeuedAttachedFormCellAtIndexPath:indexPath
                                               fromTableView:tableView
                                                   withModel:model];
        }
            
        default: break;
    }
    
    return nil;
}

- (UITableViewCell *)taskDetailsCellOfRequeueableTaskWithDefinedFormForIndexPath:(NSIndexPath *)indexPath
                                                                       tableView:(UITableView *)tableView
                                                                           model:(AFATableControllerTaskDetailsModel *)model {
    switch (indexPath.row) {
        case AFADefinedFormClaimableTaskDetailsCellTypeTaskName: {
            return [self dequeuedNameCellAtIndexPath:indexPath
                                       fromTableView:tableView
                                           withModel:model];
        }
            
        case AFADefinedFormClaimableTaskDetailsCellTypeRequeue: {
            return [self dequeuedRequeueCellAtIndexPath:indexPath
                                          fromTableView:tableView
                                              withModel:model];
        }
            
        case AFADefinedFormClaimableTaskDetailsCellTypeAssignee: {
            return [self dequeuedAssigneeCellAtIndexPath:indexPath
                                           fromTableView:tableView
                                               withModel:model];
        }
            
        case AFADefinedFormClaimableTaskDetailsCellTypeCreated: {
            return [self dequeuedCreatedDateCellAtIndexPath:indexPath
                                              fromTableView:tableView
                                                  withModel:model];
        }
            
        case AFADefinedFormClaimableTaskDetailsCellTypeDue: {
            return [self dequeuedDueCellAtIndexPath:indexPath
                                      fromTableView:tableView
                                          withModel:model];
        }
            
        case AFADefinedFormClaimableTaskDetailsCellTypePartOf: {
            if ([model isChecklistTask]) {
                return [self dequeuedTaskMembershipCellAtIndexPath:indexPath
                                                     fromTableView:tableView
                                                         withModel:model];
            } else {
                return [self dequeuedProcessMembershipCellAtIndexPath:indexPath
                                                        fromTableView:tableView
                                                            withModel:model];
            }
        }
            
        case AFADefinedFormClaimableTaskDetailsCellTypeDescription: {
            return [self dequeuedDescriptionCellAtIndexPath:indexPath
                                              fromTableView:tableView
                                                  withModel:model];
        }
            
        case AFADefinedFormClaimableTaskDetailsCellTypeAttachedForm: {
            return [self dequeuedAttachedFormCellAtIndexPath:indexPath
                                               fromTableView:tableView
                                                   withModel:model];
        }
            
        default: break;
    }
    
    return nil;
}

- (UITableViewCell *)completedCellForIndexPath:(NSIndexPath *)indexPath
                                     tableView:(UITableView *)tableView
                                         model:(AFATableControllerTaskDetailsModel *)model {
    switch (indexPath.row) {
        case AFACompletedTaskDetailsCellTypeTaskName: {
            return [self dequeuedNameCellAtIndexPath:indexPath
                                       fromTableView:tableView
                                           withModel:model];
        }
            
        case AFACompletedTaskDetailsCellTypeAssignee: {
            return [self dequeuedAssigneeCellAtIndexPath:indexPath
                                           fromTableView:tableView
                                               withModel:model];
        }
            
        case AFACompletedTaskDetailsCellTypeCreated: {
            return [self dequeuedCreatedDateCellAtIndexPath:indexPath
                                              fromTableView:tableView
                                                  withModel:model];
        }
            
        case AFACompletedTaskDetailsCellTypeDue: {
            return [self dequeuedDueCellAtIndexPath:indexPath
                                      fromTableView:tableView
                                          withModel:model];
        }
            
        case AFACompletedTaskDetailsCellTypeEnd: {
            return [self dequeuedEndDateCellAtIndexPath:indexPath
                                          fromTableView:tableView
                                              withModel:model];
        }
            
        case AFACompletedTaskDetailsCellTypeDuration: {
            return [self dequeuedDurationCellAtIndexPath:indexPath
                                           fromTableView:tableView
                                               withModel:model];
        }
            
        case AFACompletedTaskDetailsCellTypePartOf: {
            if ([model isChecklistTask]) {
                return [self dequeuedTaskMembershipCellAtIndexPath:indexPath
                                                     fromTableView:tableView
                                                         withModel:model];
            } else {
                return [self dequeuedProcessMembershipCellAtIndexPath:indexPath
                                                        fromTableView:tableView
                                                            withModel:model];
            }
        }
            
        case AFACompletedTaskDetailsCellTypeAuditLog: {
            return [self dequeueAuditLogCellAtIndexPath:indexPath
                                          fromTableView:tableView
                                              withModel:model];
        }
            
        case AFACompletedTaskDetailsCellTypeDescription: {
            return [self dequeuedDescriptionCellAtIndexPath:indexPath
                                              fromTableView:tableView
                                                  withModel:model];
        }
            
        case AFACompletedTaskDetailsCellTypeAttachedForm: {
            return [self dequeuedAttachedFormCellAtIndexPath:indexPath
                                               fromTableView:tableView
                                                   withModel:model];
        }
            
        default: break;
    }
    
    return nil;
}


- (UITableViewCell *)dequeuedNameCellAtIndexPath:(NSIndexPath *)indexPath
                                   fromTableView:(UITableView *)tableView
                                       withModel:(id<AFATableViewModelDelegate>)model {
    AFANameTableViewCell *nameCell = [tableView dequeueReusableCellWithIdentifier:kCellIDTaskDetailsName
                                                                     forIndexPath:indexPath];
    [nameCell setUpCellWithTask:[model itemAtIndexPath:indexPath]];
    
    return nameCell;
}

- (UITableViewCell *)dequeuedCompleteCellAtIndexPath:(NSIndexPath *)indexPath
                                       fromTableView:(UITableView *)tableView
                                           withModel:(id<AFATableViewModelDelegate>)model {
    AFACompleteTableViewCell *completeCell = [tableView dequeueReusableCellWithIdentifier:kCellIDTaskDetailsComplete
                                                                             forIndexPath:indexPath];
    completeCell.delegate = self;
    [completeCell setUpWithThemeColor:self.appThemeColor];
    [completeCell updateStateForConnectivity:[(AFATableControllerTaskDetailsModel *)model isConnectivityAvailable]];
    
    // Enable the requeue button if it's the case
    BOOL displayRequeueButton = [(AFATableControllerTaskDetailsModel *)model canBeRequeued];
    completeCell.requeueRoundedBorderView.hidden = !displayRequeueButton;
    completeCell.requeueTaskButton.hidden = !displayRequeueButton;
    
    return completeCell;
}

- (UITableViewCell *)dequeuedRequeueCellAtIndexPath:(NSIndexPath *)indexPath
                                      fromTableView:(UITableView *)tableView
                                          withModel:(id<AFATableViewModelDelegate>)model {
    AFARequeueTableViewCell *requeueCell = [tableView dequeueReusableCellWithIdentifier:kCellIDTaskDetailsRequeue
                                                                           forIndexPath:indexPath];
    requeueCell.delegate = self;
    [requeueCell setUpWithThemeColor:self.appThemeColor];
    [requeueCell updateStateForConnectivity:[(AFATableControllerTaskDetailsModel *)model isConnectivityAvailable]];
    
    return requeueCell;
}

- (UITableViewCell *)dequeuedClaimCellAtIndexPath:(NSIndexPath *)indexPath
                                    fromTableView:(UITableView *)tableView
                                        withModel:(id<AFATableViewModelDelegate>)model {
    AFAClaimTableViewCell *claimCell = [tableView dequeueReusableCellWithIdentifier:kCellIDTaskDetailsClaim
                                                                       forIndexPath:indexPath];
    claimCell.delegate = self;
    [claimCell setUpWithThemeColor:self.appThemeColor];
    [claimCell updateStateForConnectivity:[(AFATableControllerTaskDetailsModel *)model isConnectivityAvailable]];
    
    return claimCell;
}

- (UITableViewCell *)dequeuedAssigneeCellAtIndexPath:(NSIndexPath *)indexPath
                                       fromTableView:(UITableView *)tableView
                                           withModel:(id<AFATableViewModelDelegate>)model {
    AFAAssigneeTableViewCell *assigneeCell = [tableView dequeueReusableCellWithIdentifier:kCellIDTaskDetailsAssignee
                                                                             forIndexPath:indexPath];
    [assigneeCell setUpCellWithTask:[model itemAtIndexPath:indexPath]
            isConnectivityAvailable:[(AFATableControllerTaskDetailsModel *)model isConnectivityAvailable]];
    assigneeCell.delegate = self;
    
    return assigneeCell;
}

- (UITableViewCell *)dequeuedCreatedDateCellAtIndexPath:(NSIndexPath *)indexPath
                                          fromTableView:(UITableView *)tableView
                                              withModel:(id<AFATableViewModelDelegate>)model {
    AFACreatedDateTableViewCell *createdDateCell = [tableView dequeueReusableCellWithIdentifier:kCellIDTaskDetailsCreated
                                                                                   forIndexPath:indexPath];
    [createdDateCell setUpCellWithTask:[model itemAtIndexPath:indexPath]];
    
    return createdDateCell;
}

- (UITableViewCell *)dequeuedDueCellAtIndexPath:(NSIndexPath *)indexPath
                                  fromTableView:(UITableView *)tableView
                                      withModel:(id<AFATableViewModelDelegate>)model {
    AFADueTableViewCell *dueCell = [tableView dequeueReusableCellWithIdentifier:kCellIDTaskDetailsDue
                                                                   forIndexPath:indexPath];
    [dueCell setUpCellWithTask:[model itemAtIndexPath:indexPath]];
    [dueCell updateStateForConnectivity:[(AFATableControllerTaskDetailsModel *)model isConnectivityAvailable]];
    dueCell.delegate = self;
    
    return dueCell;
}

- (UITableViewCell *)dequeuedProcessMembershipCellAtIndexPath:(NSIndexPath *)indexPath
                                                fromTableView:(UITableView *)tableView
                                                    withModel:(id<AFATableViewModelDelegate>)model {
    AFAProcessMembershipTableViewCell *processCell = [tableView dequeueReusableCellWithIdentifier:kCellIDTaskDetailsProcess
                                                                                     forIndexPath:indexPath];
    [processCell setUpCellWithTask:[model itemAtIndexPath:indexPath]];
    processCell.delegate = self;
    
    return processCell;
}

- (UITableViewCell *)dequeuedTaskMembershipCellAtIndexPath:(NSIndexPath *)indexPath
                                             fromTableView:(UITableView *)tableView
                                                 withModel:(id<AFATableViewModelDelegate>)model {
    AFATaskMembershipTableViewCell *taskCell = [tableView dequeueReusableCellWithIdentifier:kCellIDTaskDetailsTask
                                                                               forIndexPath:indexPath];
    [taskCell setUpCellWithTask:((AFATableControllerTaskDetailsModel *)model).parentTask];
    taskCell.delegate = self;
    
    return taskCell;
}

- (UITableViewCell *)dequeuedDescriptionCellAtIndexPath:(NSIndexPath *)indexPath
                                          fromTableView:(UITableView *)tableView
                                              withModel:(id<AFATableViewModelDelegate>)model {
    AFADescriptionTableViewCell *descriptionCell = [tableView dequeueReusableCellWithIdentifier:kCellIDTaskDetailsDescription
                                                                                   forIndexPath:indexPath];
    [descriptionCell setUpCellWithTask:[model itemAtIndexPath:indexPath]];
    
    return descriptionCell;
}

- (UITableViewCell *)dequeuedEndDateCellAtIndexPath:(NSIndexPath *)indexPath
                                      fromTableView:(UITableView *)tableView
                                          withModel:(id<AFATableViewModelDelegate>)model {
    AFACompletedDateTableViewCell *completedDateCell = [tableView dequeueReusableCellWithIdentifier:kCellIDTaskDetailsCompletedDate
                                                                                       forIndexPath:indexPath];
    [completedDateCell setUpCellWithTask:[model itemAtIndexPath:indexPath]];
    return completedDateCell;
}

- (UITableViewCell *)dequeuedDurationCellAtIndexPath:(NSIndexPath *)indexPath
                                       fromTableView:(UITableView *)tableView
                                           withModel:(id<AFATableViewModelDelegate>)model {
    AFADurationTableViewCell *durationCell = [tableView dequeueReusableCellWithIdentifier:kCellIDTaskDetailsDuration
                                                                             forIndexPath:indexPath];
    [durationCell setUpCellWithTask:[model itemAtIndexPath:indexPath]];
    
    return durationCell;
}

- (UITableViewCell *)dequeueAuditLogCellAtIndexPath:(NSIndexPath *)indexPath
                                      fromTableView:(UITableView *)tableView
                                          withModel:(id<AFATableViewModelDelegate>)model {
    AFAAuditLogTableViewCell *auditCell = [tableView dequeueReusableCellWithIdentifier:kCellIDAuditLog
                                                                          forIndexPath:indexPath];
    auditCell.delegate = self;
    
    return auditCell;
}

- (UITableViewCell *)dequeuedAttachedFormCellAtIndexPath:(NSIndexPath *)indexPath
                                           fromTableView:(UITableView *)tableView
                                               withModel:(id<AFATableViewModelDelegate>)model {
    AFAAttachFormTableViewCell *attachFormCell = [tableView dequeueReusableCellWithIdentifier:kCellIDTaskDetailsAttachedForm
                                                                                 forIndexPath:indexPath];
    attachFormCell.delegate = self;
    return attachFormCell;
}

@end

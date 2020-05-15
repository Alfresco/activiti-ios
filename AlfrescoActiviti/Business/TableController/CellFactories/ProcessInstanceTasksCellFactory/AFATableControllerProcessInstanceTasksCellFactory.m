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

#import "AFATableControllerProcessInstanceTasksCellFactory.h"

// Constants
#import "AFAUIConstants.h"
#import "AFABusinessConstants.h"
#import "AFALocalizationConstants.h"

// Cells
#import "AFATaskDetailsStyleTableViewCell.h"
#import "AFAStartFormTableViewCell.h"
#import "AFASimpleSectionHeaderCell.h"

@implementation AFATableControllerProcessInstanceTasksCellFactory

#pragma mark -
#pragma mark AFATableViewCellFactory Delegate

- (UITableViewCell *)tableView:(UITableView *)tableView
              cellForIndexPath:(NSIndexPath *)indexPath
                      forModel:(id<AFATableViewModelDelegate>)model {
    id currentModel = [model itemAtIndexPath:indexPath];
    UITableViewCell *cell = nil;
    
    if (currentModel) {
        AFATaskDetailsStyleTableViewCell *taskDetailsCell = [tableView dequeueReusableCellWithIdentifier:kCellIDProcessInstanceDetailsTask
                                                                                            forIndexPath:indexPath];
        [taskDetailsCell setUpCellWithTask:currentModel];
        taskDetailsCell.applicationThemeColor = self.appThemeColor;
        
        cell = taskDetailsCell;
    } else {
        AFAStartFormTableViewCell *startFormCell = [tableView dequeueReusableCellWithIdentifier:kCellIDStartForm
                                                                                   forIndexPath:indexPath];
        startFormCell.nameLabel.text = NSLocalizedString(kLocalizationProcessInstanceDetailsScreenStartFormText, @"Start form text");
        startFormCell.applicationThemeColor = self.appThemeColor;
        
        cell = startFormCell;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath
         forModel:(id<AFATableViewModelDelegate>)model {
    // Remove seperator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    
    // Explictly set your cell's layout margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (UIView *)tableView:(UITableView *)tableView
viewForHeaderInSection:(NSInteger)section
             forModel:(id<AFATableViewModelDelegate>)model {
    // First check if we have entries for the current section
    // and if we don't hide the header for it
    if ([model numberOfRowsInSection:section]) {
        AFASimpleSectionHeaderCell *simpleSectionHeaderCell = [tableView dequeueReusableCellWithIdentifier:kCellIDProcessInstanceDetailsTaskHeader];
        simpleSectionHeaderCell.sectionTitleLabel.text = [model titleForHeaderInSection:section];
        [simpleSectionHeaderCell setUpWithThemeColor:self.appThemeColor];
        
        return simpleSectionHeaderCell;
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView
heightForHeaderInSection:(NSInteger)section
            forModel:(id<AFATableViewModelDelegate>)model {
    CGFloat headerHeight = [model numberOfRowsInSection:section] ? 44.0f : .0f;
    return headerHeight;
}

- (BOOL)tableView:(UITableView *)tableView
shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    AFATableControllerCellActionBlock actionBlock = [self actionForCellOfType:AFAProcessInstanceTaskCellTypeSeeDetails];
    if (actionBlock) {
        actionBlock(@{kCellFactoryCellParameterCellIndexpath : indexPath});
        
        // Deselect the content cell
        [tableView deselectRowAtIndexPath:indexPath
                                 animated:NO];
    }
}


#pragma mark -
#pragma mark Public interface

- (NSInteger)cellTypeForTaskDetails {
    return AFAProcessInstanceTaskCellTypeSeeDetails;
}

@end

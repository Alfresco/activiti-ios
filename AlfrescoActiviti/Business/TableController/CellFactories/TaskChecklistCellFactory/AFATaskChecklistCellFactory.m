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

#import "AFATaskChecklistCellFactory.h"

// Constants
#import "AFAUIConstants.h"

// Cells
#import "AFAChecklistTableViewCell.h"

@interface AFATaskChecklistCellFactory () <AFATableControllerChecklistModelDelegate>

@end

@implementation AFATaskChecklistCellFactory


#pragma mark -
#pragma mark AFATableViewCellFactory Delegate

- (UITableViewCell *)tableView:(UITableView *)tableView
              cellForIndexPath:(NSIndexPath *)indexPath
                      forModel:(id<AFATableViewModelDelegate>)model {
    AFAChecklistTableViewCell *checklistCell = [tableView dequeueReusableCellWithIdentifier:kCellIDTaskChecklist
                                                                               forIndexPath:indexPath];
    [checklistCell setUpCellWithTask:[model itemAtIndexPath:indexPath]];
    checklistCell.applicationThemeColor = self.appThemeColor;
    return checklistCell;
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

- (BOOL)tableView:(UITableView *)tableView
shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView
canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView
           editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleNone;
}


#pragma mark -
#pragma mark AFATableControllerChecklistModelDelegate

- (void)didUpdateChecklistOrder {
    AFATableControllerCellActionBlock actionBlock = [self actionForCellOfType:AFAChecklistCellTypeReorder];
    if (actionBlock) {
        actionBlock(nil);
    }
}


#pragma mark -
#pragma mark Public interface

- (NSInteger)cellTypeForReorder {
    return AFAChecklistCellTypeReorder;
}

@end

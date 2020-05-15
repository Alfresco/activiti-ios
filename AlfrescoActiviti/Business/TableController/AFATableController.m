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

#import "AFATableController.h"

@implementation AFATableController


#pragma mark -
#pragma mark Tableview Delegate & Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger sectionCount = 0;
    
    if ([self.model respondsToSelector:@selector(numberOfSections)]) {
        sectionCount = [self.model numberOfSections];
    }
    
    return sectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    NSInteger rowNumberForSelectedSection = 0;
    
    if ([self.model respondsToSelector:@selector(numberOfRowsInSection:)]) {
        rowNumberForSelectedSection = [self.model numberOfRowsInSection:section];
    }
    
    return rowNumberForSelectedSection;
}

- (UIView *)tableView:(UITableView *)tableView
viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = nil;
    
    if ([self.cellFactory respondsToSelector:@selector(tableView:viewForHeaderInSection:forModel:)]) {
        headerView = [self.cellFactory tableView:tableView
                          viewForHeaderInSection:section
                                        forModel:self.model];
    }
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView
heightForHeaderInSection:(NSInteger)section {
    CGFloat headerHeight = .0f;
    
    if ([self.cellFactory respondsToSelector:@selector(tableView:heightForHeaderInSection:forModel:)]) {
        headerHeight = [self.cellFactory tableView:tableView
                          heightForHeaderInSection:section
                                          forModel:self.model];
    }
    
    return headerHeight;
}

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.cellFactory respondsToSelector:@selector(tableView:willDisplayCell:forRowAtIndexPath:forModel:)]) {
        [self.cellFactory tableView:tableView
                    willDisplayCell:cell
                  forRowAtIndexPath:indexPath
                           forModel:self.model];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    
    if ([self.cellFactory respondsToSelector:@selector(tableView:cellForIndexPath:forModel:)]) {
        cell = [self.cellFactory tableView:tableView
                          cellForIndexPath:indexPath
                                  forModel:self.model];
    }
    
    if (!cell) {
        cell = [UITableViewCell new];
    }
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView
shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    BOOL shouldHighlight = NO;
    
    if ([self.cellFactory respondsToSelector:@selector(tableView:shouldHighlightRowAtIndexPath:)]) {
        shouldHighlight = [self.cellFactory tableView:tableView
                        shouldHighlightRowAtIndexPath:indexPath];
    }
    
    return shouldHighlight;
}

- (BOOL)tableView:(UITableView *)tableView
canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    BOOL canEditRow = NO;
    
    if ([self.cellFactory respondsToSelector:@selector(tableView:canEditRowAtIndexPath:)]) {
        canEditRow = [self.cellFactory tableView:tableView
                           canEditRowAtIndexPath:indexPath];
    }
    
    return canEditRow && self.isEditable;
}

- (BOOL)tableView:(UITableView *)tableView
canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    BOOL canMoveRow = NO;
    
    if ([self.model respondsToSelector:@selector(tableView:canMoveRowAtIndexPath:)]) {
        canMoveRow = [self.model tableView:tableView
                           canMoveRowAtIndexPath:indexPath];
    }
    
    return canMoveRow;
}

- (void)tableView:(UITableView *)tableView
moveRowAtIndexPath:(NSIndexPath *)fromIndexPath
      toIndexPath:(NSIndexPath *)toIndexPath {
    if ([self.model respondsToSelector:@selector(tableView:moveRowAtIndexPath:toIndexPath:)]) {
        [self.model tableView:tableView
                 moveRowAtIndexPath:fromIndexPath
                        toIndexPath:toIndexPath];
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView
           editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCellEditingStyle editingStyle = UITableViewCellEditingStyleNone;
    
    if ([self.cellFactory respondsToSelector:@selector(tableView:editingStyleForRowAtIndexPath:)]) {
        editingStyle = [self.cellFactory tableView:tableView
                     editingStyleForRowAtIndexPath:indexPath];
    }
    
    return editingStyle;
}

- (BOOL)tableView:(UITableView *)tableview
shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.cellFactory respondsToSelector:@selector(tableView:commitEditingStyle:forRowAtIndexPath:)]) {
        [self.cellFactory tableView:tableView
                 commitEditingStyle:editingStyle
                  forRowAtIndexPath:indexPath];
    }
}

-(NSArray *)tableView:(UITableView *)tableView
editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *editActions = nil;
    
    if ([self.cellFactory respondsToSelector:@selector(tableView:editActionsForRowAtIndexPath:)]) {
        editActions = [self.cellFactory tableView:tableView
                     editActionsForRowAtIndexPath:indexPath];
    }
    
    return editActions;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.cellFactory respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]) {
        [self.cellFactory tableView:tableView
            didSelectRowAtIndexPath:indexPath];
    }
}

@end

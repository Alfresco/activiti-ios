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

#import "AFATableControllerChecklistModel.h"
@import ActivitiSDK;

@implementation AFATableControllerChecklistModel

- (instancetype)init {
    self = [super init];
    if (self) {
        _isConnectivityAvailable = YES;
    }
    
    return self;
}


#pragma mark -
#pragma mark AFATableViewModel Delegate

- (NSInteger)numberOfSections {
    return 1;
}

- (NSInteger)numberOfRowsInSection:(NSInteger)section {
    return self.checklistArr.count;
}

- (id)itemAtIndexPath:(NSIndexPath *)indexPath {
    return self.checklistArr[indexPath.row];
}

- (BOOL)tableView:(UITableView *)tableView
canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView
moveRowAtIndexPath:(NSIndexPath *)fromIndexPath
      toIndexPath:(NSIndexPath *)toIndexPath {
    ASDKModelTask *taskToMove = self.checklistArr[fromIndexPath.row];
    NSMutableArray *mutableChecklistArr = [NSMutableArray arrayWithArray:self.checklistArr];
    [mutableChecklistArr removeObjectAtIndex:fromIndexPath.row];
    [mutableChecklistArr insertObject:taskToMove
                              atIndex:toIndexPath.row];
    self.checklistArr = mutableChecklistArr;
    
    if ([self.delegate respondsToSelector:@selector(didUpdateChecklistOrder)]) {
        [self.delegate didUpdateChecklistOrder];
    }
}


#pragma mark -
#pragma mark Public interface

- (NSArray *)checkListIDs {
    return [self.checklistArr valueForKeyPath:@"@unionOfObjects.modelID"];
}

@end

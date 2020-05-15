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

#import "AFAModalTaskDetailsUpdateTaskAction.h"
#import "AFATaskUpdateModel.h"

@interface AFAModalTaskDetailsUpdateTaskAction ()

@property (strong, nonatomic) AFATaskServices *updateTaskService;

@end

@implementation AFAModalTaskDetailsUpdateTaskAction

- (instancetype)init {
    self = [super init];
    if (self) {
        _updateTaskService = [AFATaskServices new];
    }
    
    return self;
}

- (void)executeAlertActionWithModel:(id)modelObject
                    completionBlock:(id)completionBlock {
    AFATaskUpdateModel *taskUpdateModel = (AFATaskUpdateModel *)modelObject;
    taskUpdateModel.taskDueDate = self.dueDate;
    [self.updateTaskService requestTaskUpdateWithRepresentation:taskUpdateModel
                                                      forTaskID:self.currentTaskID
                                            withCompletionBlock:completionBlock];
}

@end

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

#import "AFAModalTaskDetailsCreateTaskAction.h"
#import "AFAServiceRepository.h"

@interface AFAModalTaskDetailsCreateTaskAction ()

@property (strong, nonatomic) AFATaskServices *createTaskService;

@end

@implementation AFAModalTaskDetailsCreateTaskAction

- (instancetype)init {
    self = [super init];
    if (self) {
        _createTaskService = [AFATaskServices new];
    }
    
    return self;
}

- (void)executeAlertActionWithModel:(id)modelObject
                    completionBlock:(id)completionBlock {
    [self.createTaskService requestCreateTaskWithRepresentation:modelObject
                                                completionBlock:completionBlock];
}

@end

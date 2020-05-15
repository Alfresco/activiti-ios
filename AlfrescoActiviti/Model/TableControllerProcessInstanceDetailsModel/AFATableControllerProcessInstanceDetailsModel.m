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

#import "AFATableControllerProcessInstanceDetailsModel.h"
#import "AFATableControllerProcessInstanceDetailsCellFactory.h"

@implementation AFATableControllerProcessInstanceDetailsModel

#pragma mark -
#pragma mark AFATableViewModel Delegate

- (NSInteger)numberOfSections {
    return 1;
}

- (NSInteger)numberOfRowsInSection:(NSInteger)section {
    // If we're dealing with a completed process instance display additional field
    // for end date and duration
    if ([self isCompletedProcessInstance]) {
        return AFACompletedProcessInstanceDetailsCellTypeEnumCount;
    } else {
        return AFAProcessInstanceDetailsCellTypeEnumCount;
    }
}

- (id)itemAtIndexPath:(NSIndexPath *)indexPath {
    return self.currentProcessInstance;
}

- (BOOL)isCompletedProcessInstance {
    return self.currentProcessInstance.endDate ? YES : NO;
}

@end

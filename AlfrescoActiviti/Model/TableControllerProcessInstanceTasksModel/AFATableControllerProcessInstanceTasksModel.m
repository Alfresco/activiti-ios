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

#import "AFATableControllerProcessInstanceTasksModel.h"
#import "AFALocalizationConstants.h"

@implementation AFATableControllerProcessInstanceTasksModel

#pragma mark -
#pragma mark AFATableViewModel Delegate

- (NSInteger)numberOfSections {
    return self.isStartFormDefined ? AFATableControllerProcessInstanceTasksAndStartFormSectionTypeEnumCount : AFATableControllerProcessInstanceTasksSectionTypeEnumCount;
}

- (NSString *)titleForHeaderInSection:(NSInteger)section {
    NSString *sectionTitle = nil;
    
    if (self.isStartFormDefined) {
        switch (section) {
            case AFATableControllerProcessInstanceTasksAndStartFormSectionTypeActive: {
                sectionTitle = NSLocalizedString(kLocalizationProcessInstanceDetailsScreenActiveTasksText, @"Active tasks text");
            }
                break;
                
            case AFATableControllerProcessInstanceTasksAndStartFormSectionTypeStartForm: {
                sectionTitle = NSLocalizedString(kLocalizationProcessInstanceDetailsScreenStartFormText, @"Start form text");
            }
                break;
                
            case AFATableControllerProcessInstanceTasksAndStartFormSectionTypeCompleted: {
                sectionTitle = NSLocalizedString(kLocalizationProcessInstanceDetailsScreenCompletedTasksText, @"Completed tasks text");
            }
                break;
                
            default:
                break;
        }
    } else {
        switch (section) {
            case AFATableControllerProcessInstanceTasksSectionTypeActive: {
                sectionTitle = NSLocalizedString(kLocalizationProcessInstanceDetailsScreenActiveTasksText, @"Active tasks text");
            }
                break;
                
            case AFATableControllerProcessInstanceTasksSectionTypeCompleted: {
                sectionTitle = NSLocalizedString(kLocalizationProcessInstanceDetailsScreenCompletedTasksText, @"Completed tasks text");
            }
                break;
                
            default:
                break;
        }
    }
    
    return sectionTitle;
}

- (NSInteger)numberOfRowsInSection:(NSInteger)section {
    NSInteger rowCount = 0;
    
    if (self.isStartFormDefined) {
        switch (section) {
            case AFATableControllerProcessInstanceTasksAndStartFormSectionTypeActive: {
                rowCount = self.activeTasks.count;
            }
                break;
                
            case AFATableControllerProcessInstanceTasksAndStartFormSectionTypeStartForm: {
                rowCount = 1;
            }
                break;
                
            case AFATableControllerProcessInstanceTasksAndStartFormSectionTypeCompleted: {
                rowCount = self.completedTasks.count;
            }
                break;
                
            default:
                break;
        }
    } else {
        switch (section) {
            case AFATableControllerProcessInstanceTasksSectionTypeActive: {
                rowCount = self.activeTasks.count;
            }
                break;
                
            case AFATableControllerProcessInstanceTasksSectionTypeCompleted: {
                rowCount = self.completedTasks.count;
            }
                break;
                
            default:
                break;
        }
    }
    
    return rowCount;
}

- (id)itemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.isStartFormDefined) {
        switch (indexPath.section) {
            case AFATableControllerProcessInstanceTasksAndStartFormSectionTypeActive: {
                return self.activeTasks[indexPath.row];
            }
                break;
                
            case AFATableControllerProcessInstanceTasksAndStartFormSectionTypeStartForm: {
                return nil;
            }
                break;
                
            case AFATableControllerProcessInstanceTasksAndStartFormSectionTypeCompleted: {
                return self.completedTasks[indexPath.row];
            }
                break;
                
            default:
                break;
        }
    } else {
        switch (indexPath.section) {
            case AFATableControllerProcessInstanceTasksSectionTypeActive: {
                return self.activeTasks[indexPath.row];
            }
                break;
                
            case AFATableControllerProcessInstanceTasksSectionTypeCompleted: {
                return self.completedTasks[indexPath.row];
            }
                break;
                
            default:
                break;
        }
    }
    
    return nil;
}

- (BOOL)hasTaskListAvailable {
    return (self.activeTasks.count || self.completedTasks.count);
}

@end

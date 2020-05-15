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

#import "AFATableControllerCellFactory.h"
#import "AFATableController.h"

typedef NS_ENUM(NSInteger, AFAProcessInstanceDetailsCellType) {
    AFAProcessInstanceDetailsCellTypeProcessName = 0,
    AFAProcessInstanceDetailsCellTypeShowDiagram,
    AFAProcessInstanceDetailsCellTypeStartedBy,
    AFAProcessInstanceDetailsCellTypeStartDate,
    AFAProcessInstanceDetailsCellTypeEnumCount,
    // By default the enum count used to describe the number of cells for a
    // finite section, but since we're swizzling around in some scenarios
    // different cell types we moved down the position of the enum count
    // to still indicate the total number of cells present on the screen
    AFAProcessInstanceDetailsCellTypeProcessControl = 10
};

typedef NS_ENUM(NSInteger, AFACompletedProcessInstanceDetailsCellType) {
    AFACompletedProcessInstanceDetailsCellTypeProcessName = 0,
    AFACompletedProcessInstanceDetailsCellTypeShowDiagram,
    AFACompletedProcessInstanceDetailsCellTypeStartedBy,
    AFACompletedProcessInstanceDetailsCellTypeStartDate,
    AFACompletedProcessInstanceDetailsCellTypeEndDate,
    AFACompletedProcessInstanceDetailsCellTypeEnumCount,
    AFACompletedProcessInstanceDetailsCellTypeAuditLog // Audit log download function is temporary disabled
};


@interface AFATableControllerProcessInstanceDetailsCellFactory : AFATableControllerCellFactory <AFATableViewCellFactory>

@property (strong, nonatomic) UIColor *appThemeColor;

- (NSInteger)cellTypeForProcessControlCell;
- (NSInteger)cellTypeForAuditLogCell;

@end

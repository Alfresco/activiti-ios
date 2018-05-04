/*******************************************************************************
 * Copyright (C) 2005-2018 Alfresco Software Limited.
 *
 * This file is part of the Alfresco Activiti Mobile SDK.
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

#import "ASDKModelAttributable.h"

typedef NS_ENUM(NSInteger, ASDKModelFilterSortType) {
    ASDKModelFilterSortTypeUndefined   = -1,
    ASDKModelFilterSortTypeCreatedDesc = 1,
    ASDKModelFilterSortTypeCreatedAsc,
    ASDKModelFilterSortTypeDueDesc,
    ASDKModelFilterSortTypeDueAsc
};

typedef NS_ENUM(NSInteger, ASDKModelFilterStateType) {
    ASDKModelFilterStateTypeUndefined = -1,
    ASDKModelFilterStateTypeCompleted = 1,
    ASDKModelFilterStateTypeActive,
    ASDKModelFilterStateTypeRunning,
    ASDKModelFilterStateTypeAll
};

typedef NS_ENUM(NSInteger, ASDKModelFilterAssignmentType) {
    ASDKModelFilterAssignmentTypeUndefined = -1,
    ASDKModelFilterAssignmentTypeInvolved  = 1,
    ASDKModelFilterAssignmentTypeAssignee,
    ASDKModelFilterAssignmentTypeCandidate
};


@interface ASDKModelFilter : ASDKModelAttributable

@property (strong, nonatomic) NSString                      *name;
@property (assign, nonatomic) ASDKModelFilterSortType       sortType;
@property (assign, nonatomic) ASDKModelFilterStateType      state;
@property (assign, nonatomic) ASDKModelFilterAssignmentType assignmentType;
@property (strong, nonatomic) NSString                      *applicationID;

@end

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

#import <Foundation/Foundation.h>
#import "AFABaseModel.h"

typedef NS_ENUM(NSInteger, AFAGenericFilterModelSortType) {
    AFAGenericFilterModelSortTypeUndefined   = -1,
    AFAGenericFilterModelSortTypeCreatedDesc = 1,
    AFAGenericFilterModelSortTypeCreatedAsc,
    AFAGenericFilterModelSortTypeDueDesc,
    AFAGenericFilterModelSortTypeDueAsc
};

typedef NS_ENUM(NSInteger, AFAGenericFilterStateType) {
    AFAGenericFilterStateTypeUndefined = -1,
    AFAGenericFilterStateTypeCompleted = 1,
    AFAGenericFilterStateTypeActive
};

typedef NS_ENUM(NSInteger, AFAGenericFilterAssignmentType) {
    AFAGenericFilterAssignmentTypeUndefined = -1,
    AFAGenericFilterAssignmentTypeInvolved  = 1,
    AFAGenericFilterAssignmentTypeAssignee,
    AFAGenericFilterAssignmentTypeCandidate
};

typedef NS_ENUM(NSInteger, AFAGenericFilterAdditionalFilterParameterType) {
    AFAGenericFilterAdditionalFilterParameterTypeAssignee,
    AFAGenericFilterAdditionalFilterParameterTypeCandidate,
};


@interface AFAGenericFilterModel : AFABaseModel

@property (strong, nonatomic) NSString                          *filterID;
@property (strong, nonatomic) NSString                          *appDefinitionID;
@property (strong, nonatomic) NSString                          *appDeploymentID;
@property (strong, nonatomic) NSString                          *processInstanceID;
@property (strong, nonatomic) NSString                          *text;
@property (assign, nonatomic) AFAGenericFilterModelSortType     sortType;
@property (assign, nonatomic) AFAGenericFilterStateType         state;
@property (assign, nonatomic) AFAGenericFilterAssignmentType    assignmentType;
@property (assign, nonatomic) NSUInteger                        page;
@property (assign, nonatomic) NSUInteger                        size;

- (NSString *)stringValueForSortType:(AFAGenericFilterModelSortType)sortType;

@end

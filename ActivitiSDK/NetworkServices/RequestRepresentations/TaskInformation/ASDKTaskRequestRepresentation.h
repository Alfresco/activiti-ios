/*******************************************************************************
 * Copyright (C) 2005-2017 Alfresco Software Limited.
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

#import "ASDKPagingRequestRepresentation.h"

typedef NS_ENUM(NSInteger, ASDKTaskAssignmentType) {
    ASDKTaskAssignmentTypeUndefined = -1,
    ASDKTaskAssignmentTypeInvolved = 1,
    ASDKTaskAssignmentTypeAssignee,
    ASDKTaskAssignmentTypeCandidate
};

typedef NS_ENUM(NSInteger, ASDKTaskStateType) {
    ASDKTaskStateTypeUndefined = -1,
    ASDKTaskStateTypeCompleted = 1,
    ASDKTaskStateTypeActive
};

/**
 *  If properties are not set, when making the convertion to JSON and the jsonAdapterType
 *  property is set to ASDKRequestRepresentationJSONAdapterTypeExcludeNilValues they will
 *  be removed from the resulting JSON dictionary. This allows using the class to
 *  be used as a filter class for the Task list API (specifying only some fields)
 */
@interface ASDKTaskRequestRepresentation : ASDKBaseRequestRepresentation <MTLJSONSerializing>

@property (strong, nonatomic) NSString               *taskName;                       // The task name will be filtered using like semantics
@property (strong, nonatomic) NSString               *appDefinitionID;
@property (strong, nonatomic) NSString               *processDefinitionID;
@property (strong, nonatomic) NSString               *assigneeID;
@property (strong, nonatomic) NSString               *candidateID;
@property (assign, nonatomic) ASDKTaskStateType      requestTaskState;
@property (assign, nonatomic) ASDKTaskAssignmentType assignmentType;

@end

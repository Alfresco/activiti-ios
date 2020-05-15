/*******************************************************************************
 * Copyright (C) 2005-2020 Alfresco Software Limited.
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

@class ASDKModelProfile;

@interface ASDKModelTask : ASDKModelAttributable <MTLJSONSerializing>

@property (strong, nonatomic) NSString          *name;
@property (strong, nonatomic) NSString          *taskDescription;
@property (strong, nonatomic) ASDKModelProfile  *assigneeModel;
@property (strong, nonatomic) NSDate            *dueDate;
@property (strong, nonatomic) NSDate            *endDate;
@property (assign, nonatomic) NSTimeInterval    duration;
@property (assign, nonatomic) NSInteger         priority;
@property (strong, nonatomic) NSString          *processInstanceID;
@property (strong, nonatomic) NSString          *processDefinitionID;
@property (strong, nonatomic) NSString          *processDefinitionName;
@property (strong, nonatomic) NSArray           *involvedPeople;
@property (strong, nonatomic) NSString          *formKey;
@property (assign, nonatomic) BOOL              isMemberOfCandidateGroup;
@property (assign, nonatomic) BOOL              isMemberOfCandidateUsers;
@property (assign, nonatomic) BOOL              isManagerOfCandidateGroup;
@property (strong, nonatomic) NSString          *parentTaskID;
@property (strong, nonatomic) NSDate            *creationDate;
@property (strong, nonatomic) NSString          *category;
@property (strong, nonatomic) NSString          *processDefinitionDeploymentID;

@end

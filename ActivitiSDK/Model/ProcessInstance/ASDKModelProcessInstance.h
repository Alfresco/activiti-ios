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

@interface ASDKModelProcessInstance : ASDKModelAttributable

@property (strong, nonatomic) NSString          *name;
@property (strong, nonatomic) NSDate            *endDate;
@property (strong, nonatomic) NSDate            *startDate;
@property (strong, nonatomic) ASDKModelProfile  *initiatorModel;
@property (strong, nonatomic) NSString          *processDefinitionCategory;
@property (strong, nonatomic) NSString          *processDefinitionDeploymentID;
@property (strong, nonatomic) NSString          *processDefinitionDescription;
@property (strong, nonatomic) NSString          *processDefinitionID;
@property (strong, nonatomic) NSString          *processDefinitionKey;
@property (strong, nonatomic) NSString          *processDefinitionName;
@property (assign, nonatomic) NSInteger         processDefinitionVersion;
@property (assign, nonatomic) BOOL              isStartFormDefined;
@property (strong, nonatomic) NSString          *tenantID;

@end

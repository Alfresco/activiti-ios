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

typedef NS_ENUM(NSInteger, ASDKModelGroupState) {
    ASDKModelGroupStateUndefined = -1,
    ASDKModelGroupStateActive = 1,
    ASDKModelGroupStateDisabled
};

typedef NS_ENUM(NSInteger, ASDKModelGroupType) {
    ASDKModelGroupTypeUndefined = -1,
    ASDKModelGroupTypeSystem = 1,
    ASDKModelGroupTypeFunctional
};

@interface ASDKModelGroup : ASDKModelAttributable

@property (strong, nonatomic) NSString              *tenantID;
@property (strong, nonatomic) NSString              *name;
@property (strong, nonatomic) NSString              *externalID;
@property (strong, nonatomic) NSString              *parentGroupID;
@property (assign, nonatomic) ASDKModelGroupState   groupState;
@property (assign, nonatomic) ASDKModelGroupType    type;
@property (strong, nonatomic) NSArray               *subGroups;
@property (strong, nonatomic) NSArray               *userProfiles;

@end

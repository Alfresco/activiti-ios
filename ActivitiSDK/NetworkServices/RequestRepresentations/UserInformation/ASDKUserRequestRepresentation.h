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

#import "ASDKBaseRequestRepresentation.h"

/**
 *  If properties are not set, when making the convertion to JSON and the jsonAdapterType
 *  property is set to ASDKRequestRepresentationJSONAdapterTypeExcludeNilValues they will
 *  be removed from the resulting JSON dictionary. This allows using the class to
 *  be used as a filter class for the User list API (specifying only some fields)
 */
@interface ASDKUserRequestRepresentation : ASDKBaseRequestRepresentation <MTLJSONSerializing>

@property (strong, nonatomic) NSString               *filter;       // firstname / lastname
@property (strong, nonatomic) NSString               *email;
@property (strong, nonatomic) NSString               *externalID;
@property (strong, nonatomic) NSString               *externalIDCaseInsensitive;
@property (strong, nonatomic) NSString               *excludeTaskID;
@property (strong, nonatomic) NSString               *excludeProcessID;
@property (strong, nonatomic) NSString               *groupID;
@property (strong, nonatomic) NSString               *tenantID;

@end

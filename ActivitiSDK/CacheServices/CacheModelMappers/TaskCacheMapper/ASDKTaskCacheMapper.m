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

#import "ASDKTaskCacheMapper.h"

// Models
#import "ASDKMOTask.h"
#import "ASDKModelTask.h"
#import "ASDKModelProfile.h"

// Mappers
#import "ASDKProfileCacheMapper.h"

@implementation ASDKTaskCacheMapper

+ (ASDKMOTask *)mapTask:(ASDKModelTask *)task
              toCacheMO:(ASDKMOTask *)moTask {
    moTask.modelID = task.modelID;
    moTask.name = task.name;
    moTask.taskDescription = task.taskDescription;
    moTask.dueDate = task.dueDate;
    moTask.endDate = task.endDate;
    moTask.creationDate = task.creationDate;
    moTask.duration = task.duration;
    moTask.priority = task.priority;
    moTask.processInstanceID = task.processInstanceID;
    moTask.processDefinitionID = task.processDefinitionID;
    moTask.processDefinitionName = task.processDefinitionName;
    moTask.formKey = task.formKey;
    moTask.isMemberOfCandidateGroup = task.isMemberOfCandidateGroup;
    moTask.isMemberOfCandidateUsers = task.isMemberOfCandidateUsers;
    moTask.isManagerOfCandidateGroup = task.isManagerOfCandidateGroup;
    moTask.parentTaskID = task.parentTaskID;
    moTask.processDefinitionDeploymentID = task.processDefinitionDeploymentID;
    moTask.category = task.category;

    return moTask;
}

+ (ASDKModelTask *)mapCacheMOToTask:(ASDKMOTask *)moTask {
    ASDKModelTask *task = [ASDKModelTask new];
    task.modelID = moTask.modelID;
    task.name = moTask.name;
    task.taskDescription = moTask.taskDescription;
    task.dueDate = moTask.dueDate;
    task.endDate = moTask.endDate;
    task.creationDate = moTask.creationDate;
    task.duration = moTask.duration;
    task.priority = moTask.priority;
    task.processInstanceID = moTask.processInstanceID;
    task.processDefinitionID = moTask.processDefinitionID;
    task.processDefinitionName = moTask.processDefinitionName;
    task.formKey = moTask.formKey;
    task.isMemberOfCandidateGroup = moTask.isMemberOfCandidateGroup;
    task.isMemberOfCandidateUsers = moTask.isMemberOfCandidateUsers;
    task.isManagerOfCandidateGroup = moTask.isManagerOfCandidateGroup;
    task.parentTaskID = moTask.parentTaskID;
    task.processDefinitionDeploymentID = moTask.processDefinitionDeploymentID;
    task.category = moTask.category;
    
    if (moTask.assignee) {
        ASDKModelProfile *profile = [ASDKProfileCacheMapper mapCacheMOToProfile:moTask.assignee];
        task.assigneeModel = profile;
    }
    
    if (moTask.involvedPeople.count) {
        NSMutableArray *involvedPeople = [NSMutableArray array];
        for (ASDKMOProfile *moProfile in moTask.involvedPeople) {
            ASDKModelProfile *profile = [ASDKProfileCacheMapper mapCacheMOToProfile:moProfile];
            [involvedPeople addObject:profile];
        }
        task.involvedPeople = involvedPeople;
    }
    
    return task;
}

@end

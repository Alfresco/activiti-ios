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

#import "ASDKProcessInstanceContentCacheMapper.h"

// Models
#import "ASDKMOProcessInstanceContent.h"
#import "ASDKModelProcessInstanceContent.h"
#import "ASDKModelProcessInstanceContentField.h"
#import "ASDKMOContent.h"
#import "ASDKModelContent.h"

// Mappers
#import "ASDKContentCacheMapper.h"
#import "ASDKProcessInstanceContentFieldCacheMapper.h"

@implementation ASDKProcessInstanceContentCacheMapper

+ (ASDKModelProcessInstanceContent *)mapCacheMOToProcessInstanceContent:(ASDKMOProcessInstanceContent *)moProcessInstanceContent {
    ASDKModelProcessInstanceContent *processInstanceContent = [ASDKModelProcessInstanceContent new];
    if (moProcessInstanceContent.contentList.count) {
        NSMutableArray *contentArr = [NSMutableArray array];
        for (ASDKMOContent *moContent in moProcessInstanceContent.contentList) {
            ASDKModelContent *content = [ASDKContentCacheMapper mapCacheMOToContent:moContent];
            [contentArr addObject:content];
        }
        NSSortDescriptor *modelIDSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"modelID"
                                                                                ascending:YES];
        processInstanceContent.contentArr = [contentArr sortedArrayUsingDescriptors:@[modelIDSortDescriptor]];
    }
    
    if (moProcessInstanceContent.processInstanceContentField) {
        ASDKModelProcessInstanceContentField *processInstanceContentField = [ASDKProcessInstanceContentFieldCacheMapper mapCacheMOToProcessInstanceContentField:moProcessInstanceContent.processInstanceContentField];
        processInstanceContent.field = processInstanceContentField;
    }
    
    return processInstanceContent;
}

@end

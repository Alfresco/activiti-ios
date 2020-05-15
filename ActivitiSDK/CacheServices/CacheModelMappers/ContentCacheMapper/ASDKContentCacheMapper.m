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

#import "ASDKContentCacheMapper.h"

// Models
#import "ASDKModelContent.h"
#import "ASDKMOContent.h"
#import "ASDKModelProfile.h"

// Mappers
#import "ASDKProfileCacheMapper.h"


@implementation ASDKContentCacheMapper

+ (ASDKMOContent *)mapContent:(ASDKModelContent *)content
                    toCacheMO:(ASDKMOContent *)moContent {
    moContent.modelID = content.modelID;
    moContent.contentName = content.contentName;
    moContent.isModelContentAvailable = content.isModelContentAvailable;
    moContent.isLink = content.isLink;
    moContent.mimeType = content.mimeType;
    moContent.displayType = content.displayType;
    moContent.previewStatus = content.previewStatus;
    moContent.thumbnailStatus = content.thumbnailStatus;
    moContent.source = content.source;
    moContent.sourceID = content.sourceID;
    moContent.creationDate = content.creationDate;
    
    return moContent;
}

+ (ASDKModelContent *)mapCacheMOToContent:(ASDKMOContent *)moContent {
    ASDKModelContent *content = [ASDKModelContent new];
    content.modelID = moContent.modelID;
    content.contentName = moContent.contentName;
    content.isModelContentAvailable = moContent.isModelContentAvailable;
    content.isLink = moContent.isLink;
    content.mimeType = moContent.mimeType;
    content.displayType = moContent.displayType;
    content.previewStatus = moContent.previewStatus;
    content.thumbnailStatus = moContent.thumbnailStatus;
    content.source = moContent.source;
    content.sourceID = moContent.sourceID;
    content.creationDate = moContent.creationDate;
    
    if (moContent.owner) {
        ASDKModelProfile *profile = [ASDKProfileCacheMapper mapCacheMOToProfile:moContent.owner];
        content.owner = profile;
    }
    
    return content;
}

@end

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

#import "ASDKCommentCacheMapper.h"

// Models
#import "ASDKModelComment.h"
#import "ASDKMOComment.h"
#import "ASDKModelProfile.h"

// Mappers
#import "ASDKProfileCacheMapper.h"

@implementation ASDKCommentCacheMapper

+ (ASDKMOComment *)mapComment:(ASDKModelComment *)comment
                    toCacheMO:(ASDKMOComment *)moComment {
    moComment.modelID = comment.modelID;
    moComment.message = comment.message;
    moComment.creationDate = comment.creationDate;
    
    return moComment;
}

+ (ASDKModelComment *)mapCacheMOToComment:(ASDKMOComment *)moComment {
    ASDKModelComment *comment = [ASDKModelComment new];
    comment.modelID = moComment.modelID;
    comment.message = moComment.message;
    comment.creationDate = moComment.creationDate;
    
    if (moComment.author) {
        ASDKModelProfile *profile = [ASDKProfileCacheMapper mapCacheMOToProfile:moComment.author];
        comment.authorModel = profile;
    }
    
    return comment;
}

@end

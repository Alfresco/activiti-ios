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

typedef NS_ENUM(NSInteger, ASDKModelContentAvailabilityType) {
    ASDKModelContentAvailabilityTypeUndefined   = -1,
    ASDKModelContentAvailabilityTypeQueued      = 0,
    ASDKModelContentAvailabilityTypeCreated,
    ASDKModelContentAvailabilityTypeUnsupported
};

@interface ASDKModelContent : ASDKModelAttributable

@property (strong, nonatomic) NSString                          *contentName;
@property (strong, nonatomic) ASDKModelProfile                  *owner;
@property (assign, nonatomic) BOOL                              isModelContentAvailable;
@property (assign, nonatomic) BOOL                              isLink;
@property (strong, nonatomic) NSString                          *mimeType;
@property (strong, nonatomic) NSString                          *displayType;
@property (assign, nonatomic) ASDKModelContentAvailabilityType  previewStatus;
@property (assign, nonatomic) ASDKModelContentAvailabilityType  thumbnailStatus;
@property (strong, nonatomic) NSString                          *source;
@property (strong, nonatomic) NSString                          *sourceID;
@property (strong, nonatomic) NSDate                            *creationDate;

@end

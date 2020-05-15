/*******************************************************************************
 * Copyright (C) 2005-2020 Alfresco Software Limited.
 *
 * This file is part of the Alfresco Activiti Mobile iOS App.
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

#import "AFAContentPickerTaskAuditLogDownloadBehavior.h"
#import "AFATaskServices.h"

@interface AFAContentPickerTaskAuditLogDownloadBehavior ()

@property (strong, nonatomic) AFATaskServices *downloadTaskAuditLogService;

@end

@implementation AFAContentPickerTaskAuditLogDownloadBehavior

- (instancetype)init {
    self = [super init];
    if (self) {
        _downloadTaskAuditLogService = [AFATaskServices new];
    }
    
    return self;
}


#pragma mark -
#pragma mark Public interface

- (void)downloadResourceWithID:(NSString *)resourceID
            allowCachedResults:(BOOL)allowCachedResults
             withProgressBlock:(void (^)(NSString *formattedReceivedBytesString, NSError *error))progressBlock
               completionBlock:(void (^)(NSURL *downloadedContentURL, BOOL isLocalContent, NSError *error))completionBlock {
    [self.downloadTaskAuditLogService requestDownloadAuditLogForTaskWithID:resourceID
                                                        allowCachedResults:allowCachedResults
                                                             progressBlock:progressBlock
                                                           completionBlock:completionBlock];
}

@end

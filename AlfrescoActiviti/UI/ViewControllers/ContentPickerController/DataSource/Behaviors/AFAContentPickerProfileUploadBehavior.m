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

#import "AFAContentPickerProfileUploadBehavior.h"

// Managers
#import "AFAProfileServices.h"
#import "AFAServiceRepository.h"

@interface AFAContentPickerProfileUploadBehavior ()

@property (strong, nonatomic) AFAProfileServices *uploadProfileImageService;

@end

@implementation AFAContentPickerProfileUploadBehavior

- (instancetype)init {
    self = [super init];
    if (self) {
        _uploadProfileImageService = [AFAProfileServices new];
    }
    
    return self;
}


#pragma mark -
#pragma mark Public interface

- (void)uploadContentAtFileURL:(NSURL *)fileURL
               withContentData:(NSData *)contentData
                additionalData:(id)additionalData
             withProgressBlock:(void (^)(NSUInteger progress, NSError *error))progressBlock
               completionBlock:(void (^)(BOOL isContentUploaded, NSError *error))completionBlock {
    [self.uploadProfileImageService requestUploadProfileImageAtFileURL:fileURL
                                                           contentData:contentData
                                                         progressBlock:progressBlock
                                                       completionBlock:completionBlock];
}

@end

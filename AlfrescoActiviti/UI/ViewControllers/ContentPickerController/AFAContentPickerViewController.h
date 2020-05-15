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

#import "AFAContentPickerDataSourceProtocol.h"

@class ASDKModelContent,
ASDKModelIntegrationAccount;

@protocol AFAContentPickerViewControllerDelegate <NSObject>

- (void)userPickedImageAtURL:(NSURL *)imageURL;
- (void)userPickedImageFromCamera;
- (void)userDidCancelImagePick;
- (void)pickedContentHasFinishedUploading;
- (void)pickedContentHasFinishedDownloadingAtURL:(NSURL *)downloadedFileURL;

@optional
- (void)contentPickerHasBeenPresentedWithNumberOfOptions:(NSUInteger)contentOptionCount
                                              cellHeight:(CGFloat)cellHeight;
- (void)userPickerIntegrationAccount:(ASDKModelIntegrationAccount *)integrationAccount;

@end

@interface AFAContentPickerViewController : UIViewController

@property (strong, nonatomic) id<AFAContentPickerDataSourceProtocol>        dataSource;
@property (weak, nonatomic)   id<AFAContentPickerViewControllerDelegate>    delegate;
@property (strong, nonatomic) NSString                                      *taskID;

- (void)dowloadContent:(ASDKModelContent *)content
    allowCachedContent:(BOOL)allowCachedContent;

- (void)downloadAuditLogForTaskWithID:(NSString *)taskID
                   allowCachedResults:(BOOL)allowCachedResults;

- (void)downloadAuditLogForProcessInstanceWithID:(NSString *)processInstanceID
                             allowCachedResults:(BOOL)allowCachedResults;


@end

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

#import <UIKit/UIKit.h>
#import "ASDKModelFormField.h"
#import "ASDKReachabilityViewController.h"

@class ASDKModelContent,
ASDKModelIntegrationAccount;

typedef void  (^ASDKFormFieldContentDownloadProgressBlock) (NSString *formattedReceivedBytesString, NSError *error);
typedef void  (^ASDKFormFieldContentDownloadCompletionBlock)(NSString *contentID, NSURL *downloadedContentURL, BOOL isLocalContent, NSError *error);

@protocol ASDKAttachFormFieldContentPickerViewControllerDelegate <NSObject>

- (void)userPickedImageAtURL:(NSURL *)imageURL;
- (void)userPickedImageFromCamera;
- (void)userDidCancelImagePick;
- (void)pickedContentHasFinishedUploading;
- (void)pickedContentHasFinishedDownloadingAtURL:(NSURL *)downloadedFileURL;
- (void)contentPickerHasBeenPresentedWithNumberOfOptions:(NSUInteger)contentOptionCount
                                              cellHeight:(CGFloat)cellHeight;
- (void)userPickerIntegrationAccount:(ASDKModelIntegrationAccount *)integrationAccount;

@end

@interface ASDKAttachFormFieldContentPickerViewController : ASDKReachabilityViewController

@property (weak, nonatomic)   id<ASDKAttachFormFieldContentPickerViewControllerDelegate>  delegate;
@property (strong, nonatomic) ASDKModelFormField                                          *currentFormField;
@property (strong, nonatomic) NSMutableSet                                                *uploadedContentIDs;


- (void)dowloadContent:(ASDKModelContent *)content
    allowCachedContent:(BOOL)allowCachedContent;

@end

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

@import UIKit;

@class ASDKModelPaging;

typedef void (^AFAContentPickerIntegrationAccountsDataSourceCompletionBlock) (NSArray *accounts, NSError *error, ASDKModelPaging *paging);

@protocol AFAContentPickerDataSourceUploadBehavior <NSObject>

- (void)uploadContentAtFileURL:(NSURL *)fileURL
               withContentData:(NSData *)contentData
                additionalData:(id)additionalData
             withProgressBlock:(void (^)(NSUInteger progress, NSError *error))progressBlock
               completionBlock:(void (^)(BOOL isContentUploaded, NSError *error))completionBlock;

@end

@protocol AFAContentPickerDataSourceDownloadBehavior <NSObject>

- (void)downloadResourceWithID:(NSString *)resourceID
            allowCachedResults:(BOOL)allowCachedResults
             withProgressBlock:(void (^)(NSString *formattedReceivedBytesString, NSError *error))progressBlock
               completionBlock:(void (^)(NSURL *downloadedContentURL, BOOL isLocalContent, NSError *error))completionBlock;

@end

@protocol AFAContentPickerDataSourceProtocol <NSObject, UITableViewDataSource>

@property (strong, nonatomic) id<AFAContentPickerDataSourceUploadBehavior>      uploadBehavior;
@property (strong, nonatomic) id<AFAContentPickerDataSourceDownloadBehavior>    downloadBehavior;
@property (strong, nonatomic, readonly) NSArray                                 *integrationAccounts;

- (void)fetchIntegrationAccountsWithCompletionBlock:(AFAContentPickerIntegrationAccountsDataSourceCompletionBlock)completionBlock
                                 cachedResultsBlock:(AFAContentPickerIntegrationAccountsDataSourceCompletionBlock)cachedResultsBlock;

@end

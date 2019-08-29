/*******************************************************************************
 * Copyright (C) 2005-2018 Alfresco Software Limited.
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

#import "AFAContentPickerViewController.h"

// Constants
#import "AFAUIConstants.h"
#import "AFALocalizationConstants.h"
#import "AFABusinessConstants.h"

// Categories
#import "UIViewController+AFAAlertAddition.h"

// Datasource
#import "AFAContentPickerDataSource.h"
#import "AFAContentPickerTaskUploadBehavior.h"
#import "AFAContentPickerTaskAuditLogDownloadBehavior.h"
#import "AFAContentPickerProcessInstanceAuditLogDownloadBehavior.h"

// Managers
#import "AFAServiceRepository.h"
#import "AFATaskServices.h"
#import "AFAProfileServices.h"
#import "AFAIntegrationServices.h"
#import "AFAProcessServices.h"
@import Photos;
@import ActivitiSDK;
@import QuickLook;

// Cells
#import "AFAAddContentTableViewCell.h"

// Views
#import <JGProgressHUD/JGProgressHUD.h>

typedef NS_ENUM(NSInteger, AFAContentPickerResourceType) {
    AFAContentPickerResourceTypeTaskAuditLog,
    AFAContentPickerResourceTypeProcessInstanceAuditLog
};

@interface AFAContentPickerViewController () <UINavigationControllerDelegate,
UIImagePickerControllerDelegate,
QLPreviewControllerDataSource,
QLPreviewControllerDelegate,
UITableViewDelegate>

@property (weak, nonatomic)   IBOutlet UITableView                          *actionsTableView;
@property (strong, nonatomic) JGProgressHUD                                 *progressHUD;
@property (strong, nonatomic) UIImagePickerController                       *imagePickerController;
@property (strong, nonatomic) QLPreviewController                           *previewController;

// Internal state properties
@property (strong, nonatomic) NSURL                                         *currentSelectedUploadResourceURL;
@property (strong, nonatomic) NSURL                                         *currentSelectedDownloadResourceURL;
@property (strong, nonatomic) NSData                                        *currentSelectedResourceData;
@property (strong, nonatomic) ASDKIntegrationLoginWebViewViewController     *integrationLoginController;
@property (strong, nonatomic) AFATaskServices                               *downloadContentService;

@end

@implementation AFAContentPickerViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        _progressHUD = [self configureProgressHUD];
        _downloadContentService = [AFATaskServices new];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.actionsTableView.delegate = self;
    self.actionsTableView.dataSource = self.dataSource;
    
    if ([self.dataSource.uploadBehavior isKindOfClass:[AFAContentPickerTaskUploadBehavior class]]) {
        [self fetchIntegrationAccounts];
    }
}


#pragma mark -
#pragma mark Getters

- (UIImagePickerController *)imagePickerController {
    if (!_imagePickerController) {
        _imagePickerController = [UIImagePickerController new];
        _imagePickerController.delegate = self;
        _imagePickerController.allowsEditing = YES;
    }
    
    return _imagePickerController;
}


#pragma mark -
#pragma mark Actions

- (void)onTakePhoto {
    __weak typeof(self) weakSelf = self;
    [ASDKPhotosLibraryService requestPhotosAuthorizationWithCompletionBlock:^(BOOL isAuthorized) {
        __strong typeof(self) strongSelf = weakSelf;
        
        if (isAuthorized) {
            strongSelf.imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
            
            [strongSelf presentViewController:strongSelf.imagePickerController
                                     animated:YES
                                   completion:nil];
        } else {
            [strongSelf showGenericErrorAlertControllerWithMessage:NSLocalizedString(kLocalizationContentPickerComponentNotAuthorizedText, @"Access not granted error")];
        }
    }];
}

- (void)onSelectPhoto {
    __weak typeof(self) weakSelf = self;
    [ASDKPhotosLibraryService requestPhotosAuthorizationWithCompletionBlock:^(BOOL isAuthorized) {
        __strong typeof(self) strongSelf = weakSelf;
        
        if (isAuthorized) {
            strongSelf.imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            
            [strongSelf presentViewController:strongSelf.imagePickerController
                                     animated:YES
                                   completion:nil];
        } else {
            [strongSelf showGenericErrorAlertControllerWithMessage:NSLocalizedString(kLocalizationContentPickerComponentNotAuthorizedText, @"Access not granted error")];
        }
    }];
}

- (void)dowloadContent:(ASDKModelContent *)content
    allowCachedContent:(BOOL)allowCachedContent {
    
    __weak typeof(self) weakSelf = self;
    // Check if the content that's about to be downloaded is available
    if (content.isModelContentAvailable) {
        [self showDownloadProgressHUD];
        [self.downloadContentService
         requestTaskContentDownloadForContent:content
         allowCachedResults:allowCachedContent
         withProgressBlock:^(NSString *formattedReceivedBytesString, NSError *error) {
             __strong typeof(self) strongSelf = weakSelf;
             
             if (!error) {
                 strongSelf.progressHUD.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(kLocalizationContentPickerComponentDownloadProgressFormat, @"Download progress format"), formattedReceivedBytesString];
             } else {
                 [strongSelf.progressHUD dismiss];
                 [strongSelf showGenericNetworkErrorAlertControllerWithMessage:NSLocalizedString(kLocalizationAlertDialogTaskContentDownloadErrorText, @"Content download error")];
             }
         } withCompletionBlock:^(NSURL *downloadedContentURL, BOOL isLocalContent, NSError *error) {
             __strong typeof(self) strongSelf = weakSelf;
             
             [strongSelf.progressHUD dismiss];
             
             if (!error) {
                 // If local content is available ask the user how he would like to preview it
                 if (isLocalContent) {
                     [strongSelf showMultipleChoiceAlertControllerWithTitle:nil
                                                                    message:NSLocalizedString(kLocalizationContentPickerComponentLocalVersionAvailableText, @"Local content available")
                                                choiceButtonTitlesAndBlocks:NSLocalizedString(kLocalizationContentPickerComponentPreviewLocalVersionText, @"Preview local content"),
                      // Preview local content option
                      ^(UIAlertAction *action) {
                          weakSelf.currentSelectedDownloadResourceURL = downloadedContentURL;
                          [weakSelf previewDownloadedContent];
                      },
                      NSLocalizedString(kLocalizationContentPickerComponentGetLatestVersionText, @"Get latest version"),
                      // Get latest version from the server
                      ^(UIAlertAction *action) {
                          [weakSelf dowloadContent:content
                                allowCachedContent:NO];
                      }, nil];
                     
                     return;
                 }
                 
                 if (downloadedContentURL &&
                     content) {
                     strongSelf.currentSelectedDownloadResourceURL = downloadedContentURL;
                     
                     strongSelf.progressHUD.textLabel.text = NSLocalizedString(kLocalizationSuccessText, @"Success text");
                     strongSelf.progressHUD.detailTextLabel.text = nil;
                     strongSelf.progressHUD.indicatorView = [[JGProgressHUDSuccessIndicatorView alloc] init];
                     
                     dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                         [weakSelf.progressHUD dismiss];
                         
                         if ([weakSelf.delegate respondsToSelector:@selector(pickedContentHasFinishedDownloadingAtURL:)]) {
                             [weakSelf.delegate pickedContentHasFinishedDownloadingAtURL:downloadedContentURL];
                         }
                         
                         // Present the quick look controller
                         [weakSelf previewDownloadedContent];
                     });
                 } else {
                     [strongSelf showGenericNetworkErrorAlertControllerWithMessage:NSLocalizedString(kLocalizationAlertDialogTaskContentDownloadErrorText, @"Content download error")];
                 }
             } else {
                 [strongSelf showGenericNetworkErrorAlertControllerWithMessage:NSLocalizedString(kLocalizationAlertDialogTaskContentDownloadErrorText, @"Content download error")];
             }
         }];
    } else {
        [self showGenericNetworkErrorAlertControllerWithMessage:NSLocalizedString(kLocalizationContentPickerComponentContentNotAvailableErrorText, @"Content not available error")];
    }
}

- (void)downloadAuditLogForTaskWithID:(NSString *)taskID
                   allowCachedResults:(BOOL)allowCachedResults {
    
    self.dataSource.downloadBehavior = [AFAContentPickerTaskAuditLogDownloadBehavior new];
    [self downloadResourceWithID:taskID
              allowCachedResults:allowCachedResults];
}

- (void)downloadAuditLogForProcessInstanceWithID:(NSString *)processInstanceID
                              allowCachedResults:(BOOL)allowCachedResults {
    self.dataSource.downloadBehavior = [AFAContentPickerProcessInstanceAuditLogDownloadBehavior new];
    [self downloadResourceWithID:processInstanceID
              allowCachedResults:allowCachedResults];
}

- (void)downloadResourceWithID:(NSString *)resourceID
            allowCachedResults:(BOOL)allowCachedResults {
    [self showDownloadProgressHUD];
    
    __weak typeof(self) weakSelf = self;
    AFATaskServiceTaskContentDownloadProgressBlock progressBlock = ^(NSString *formattedReceivedBytesString, NSError *error) {
        __strong typeof(self) strongSelf = weakSelf;
        
        if (!error) {
            strongSelf.progressHUD.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(kLocalizationContentPickerComponentDownloadProgressFormat, @"Download progress format"), formattedReceivedBytesString];
        } else {
            [strongSelf.progressHUD dismiss];
            [strongSelf showGenericNetworkErrorAlertControllerWithMessage:NSLocalizedString(kLocalizationAlertDialogTaskContentDownloadErrorText, @"Content download error")];
        }
    };
    
    AFATaskServiceTaskContentDownloadCompletionBlock completionBlock = ^(NSURL *downloadedContentURL, BOOL isLocalContent, NSError *error) {
        __strong typeof(self) strongSelf = weakSelf;
        
        [strongSelf.progressHUD dismiss];
        
        if (!error) {
            if (downloadedContentURL) {
                strongSelf.currentSelectedDownloadResourceURL = downloadedContentURL;
                
                strongSelf.progressHUD.textLabel.text = NSLocalizedString(kLocalizationSuccessText, @"Success text");
                strongSelf.progressHUD.detailTextLabel.text = nil;
                strongSelf.progressHUD.indicatorView = [[JGProgressHUDSuccessIndicatorView alloc] init];
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [weakSelf.progressHUD dismiss];
                    
                    // Present the quick look controller
                    [weakSelf previewDownloadedContent];
                });
            } else {
                [strongSelf showGenericNetworkErrorAlertControllerWithMessage:NSLocalizedString(kLocalizationAlertDialogTaskContentDownloadErrorText, @"Content download error")];
            }
        } else {
            [strongSelf showGenericNetworkErrorAlertControllerWithMessage:NSLocalizedString(kLocalizationAlertDialogTaskContentDownloadErrorText, @"Content download error")];
        }
    };
    
    [self.dataSource.downloadBehavior downloadResourceWithID:resourceID
                                          allowCachedResults:allowCachedResults
                                           withProgressBlock:progressBlock
                                             completionBlock:completionBlock];
}


- (void)previewDownloadedContent {
    if (!self.previewController) {
        self.previewController =  [QLPreviewController new];
        self.previewController.dataSource = self;
        self.previewController.delegate = self;
    } else {
        [self.previewController refreshCurrentPreviewItem];
    }
    
    [self presentViewController:self.previewController
                       animated:YES
                     completion:nil];
}

- (void)fetchIntegrationAccounts {
    __weak typeof(self) weakSelf = self;
    [self.dataSource fetchIntegrationAccountsWithCompletionBlock:^(NSArray *accounts, NSError *error, ASDKModelPaging *paging) {
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf handleIntegrationAccountListResponse:accounts
                                                   error:error];
    } cachedResultsBlock:^(NSArray *accounts, NSError *error, ASDKModelPaging *paging) {
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf handleIntegrationAccountListResponse:accounts
                                                   error:error];
    }];
}

- (void)uploadTaskContentForCurrentSelectedResource {
    __weak typeof(self) weakSelf = self;
    AFATaskServicesTaskContentUploadCompletionBlock uploadCompletionBlock = ^(BOOL isContentUploaded, NSError *error) {
        __strong typeof(self) strongSelf = weakSelf;
        
        if (isContentUploaded) {
            strongSelf.progressHUD.textLabel.text = NSLocalizedString(kLocalizationSuccessText, @"Success text");
            strongSelf.progressHUD.detailTextLabel.text = nil;
            strongSelf.progressHUD.indicatorView = [[JGProgressHUDSuccessIndicatorView alloc] init];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf.progressHUD dismiss];
                
                if ([weakSelf.delegate respondsToSelector:@selector(pickedContentHasFinishedUploading)]) {
                    [weakSelf.delegate pickedContentHasFinishedUploading];
                }
            });
        } else {
            [strongSelf showGenericNetworkErrorAlertControllerWithMessage:NSLocalizedString(kLocalizationAlertDialogTaskContentUploadErrorText, @"Content upload error")];
            [strongSelf.progressHUD dismiss];
        }
    };
    
    AFATaskServiceTaskContentProgressBlock progressBlock = ^(NSUInteger progress, NSError *error) {
        __strong typeof(self) strongSelf = weakSelf;
        
        if (!error) {
            [strongSelf.progressHUD setProgress:progress / 100.0f
                                       animated:YES];
            strongSelf.progressHUD.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(kLocalizationContentPickerComponentProgressPercentFormat, @"Percent format"), progress];
        } else {
            [strongSelf showGenericNetworkErrorAlertControllerWithMessage:NSLocalizedString(kLocalizationAlertDialogTaskContentUploadErrorText, @"Content upload error")];
        }
    };
    
    [self.dataSource.uploadBehavior uploadContentAtFileURL:self.currentSelectedUploadResourceURL
                                           withContentData:self.currentSelectedResourceData
                                            additionalData:self.taskID
                                         withProgressBlock:progressBlock
                                           completionBlock:uploadCompletionBlock];
}


#pragma mark -
#pragma mark Image Picker Controller delegate methods

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info {
    // Check if we are picking from the photo library
    if (UIImagePickerControllerSourceTypePhotoLibrary == picker.sourceType) {
        PHAsset *selectedAsset = info[UIImagePickerControllerPHAsset];
        if (selectedAsset) {
            CGRect cropRect = [info[UIImagePickerControllerCropRect] CGRectValue];
            NSInteger retinaScale = [UIScreen mainScreen].scale;
            CGSize retinaRect = CGSizeMake(cropRect.size.width * retinaScale, cropRect.size.height * retinaScale);
            
            PHImageRequestOptions *imageRequestOptions = [PHImageRequestOptions new];
            imageRequestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
            imageRequestOptions.resizeMode = PHImageRequestOptionsResizeModeExact;
            
            UIImage *editedImage = info[UIImagePickerControllerEditedImage];
            
            __weak typeof(self) weakSelf = self;
            [[PHImageManager defaultManager] requestImageForAsset:selectedAsset
                                                       targetSize:retinaRect
                                                      contentMode:PHImageContentModeAspectFit
                                                          options:imageRequestOptions
                                                    resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                                                        __strong typeof(self) strongSelf = weakSelf;
                                                        
                                                        strongSelf.currentSelectedResourceData = UIImageJPEGRepresentation(editedImage, 1.0f);
                                                        
                                                        NSURL *assetFileURL = info[@"PHImageFileURLKey"];
                                                        // It is possible for some pictures present in the photo gallery that the URL will not be
                                                        // returned by the Photos framework and for those we generate it on-demand like for the
                                                        // camera captured photos
                                                        if (assetFileURL) {
                                                            strongSelf.currentSelectedUploadResourceURL = assetFileURL;
                                                        } else {
                                                            strongSelf.currentSelectedUploadResourceURL =
                                                            [NSURL URLWithString:
                                                             [ASDKDiskServices generateFilenameForFileWithMIMEType:
                                                              [ASDKDiskServices mimeTypeByGuessingFromData:self.currentSelectedResourceData]]];
                                                        }
                                                        
                                                        [strongSelf uploadTaskContentForCurrentSelectedResource];
                                                    }];
        }
        
        if ([self.delegate respondsToSelector:@selector(userPickedImageAtURL:)]) {
            [self.delegate userPickedImageAtURL:self.currentSelectedUploadResourceURL];
        }
    } else if (UIImagePickerControllerSourceTypeCamera == picker.sourceType) {
        UIImage *cameraImage = info[UIImagePickerControllerEditedImage];
        self.currentSelectedResourceData = UIImageJPEGRepresentation(cameraImage, 1.0f);
        self.currentSelectedUploadResourceURL = [NSURL URLWithString:
                                                 [ASDKDiskServices generateFilenameForFileWithMIMEType:
                                                  [ASDKDiskServices mimeTypeByGuessingFromData:self.currentSelectedResourceData]]];
        [self uploadTaskContentForCurrentSelectedResource];
        
        if ([self.delegate respondsToSelector:@selector(userPickedImageFromCamera)]) {
            [self.delegate userPickedImageFromCamera];
        }
    }
    
    [picker dismissViewControllerAnimated:YES
                               completion:nil];
    
    // Mark progress and start content upload
    [self showUploadProgressHUD];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    if ([self.delegate respondsToSelector:@selector(userDidCancelImagePick)]) {
        [self.delegate userDidCancelImagePick];
    }
    
    [picker dismissViewControllerAnimated:YES
                               completion:nil];
}


#pragma mark -
#pragma mark Content handling

- (void)handleIntegrationAccountListResponse:(NSArray *)integrationAccountList
                                       error:(NSError *)error {
    if (!error) {
        if ([self.delegate respondsToSelector:@selector(contentPickerHasBeenPresentedWithNumberOfOptions:cellHeight:)]) {
            [self.delegate contentPickerHasBeenPresentedWithNumberOfOptions:AFAContentPickerCellTypeEnumCount + integrationAccountList.count
                                                                       cellHeight:self.actionsTableView.rowHeight];
        }
        
        [self.actionsTableView reloadData];
    } else {
        // Fail silently when offline because adding content is disabled
        if (error.code != NSURLErrorNotConnectedToInternet) {
            [self showGenericNetworkErrorAlertControllerWithMessage:NSLocalizedString(kLocalizationContentPickerComponentIntegrationAccountNotAvailableText, @"Integration account error")];
        }
    }
}


#pragma mark -
#pragma mark Integration account selection handling

- (void)handleIntegrationAccountSelectionForIndexPath:(NSIndexPath *)indexPath {
    ASDKModelIntegrationAccount *account = self.dataSource.integrationAccounts[indexPath.row - AFAContentPickerCellTypeEnumCount];
    
    if (SHOW_CLOUD_DECOMMISSION_ALERT) {
        __weak typeof(self) weakSelf = self;
        [ASDKCloudDecommissionService
         presentAlfrescoCloudDecommissioningAlertForAccount:account
         inViewController:self
         completionBlock:^{
             __strong typeof(self) strongSelf = weakSelf;
             [strongSelf handleIntegrationAccountSelectionWithAccount:account];
         }];
    } else {
        [self handleIntegrationAccountSelectionWithAccount:account];
    }
}

- (void)handleIntegrationAccountSelectionWithAccount:(ASDKModelIntegrationAccount *)account {
    if (!account.isAccountAuthorized) {
        __weak typeof(self) weakSelf = self;
        self.integrationLoginController =
        [[ASDKIntegrationLoginWebViewViewController alloc] initWithAuthorizationURL:account.authorizationURLString
                                                                    completionBlock:^(BOOL isAuthorized) {
                                                                        __strong typeof(self) strongSelf = weakSelf;
                                                                        
                                                                        if (isAuthorized) {
                                                                            [strongSelf fetchIntegrationAccounts];
                                                                            [strongSelf showIntegrationLoginHUD];
                                                                            
                                                                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                                                                [weakSelf.progressHUD dismiss];
                                                                                
                                                                                if ([weakSelf.delegate respondsToSelector:@selector(userPickerIntegrationAccount:)]) {
                                                                                    [weakSelf.delegate userPickerIntegrationAccount:account];
                                                                                }
                                                                            });
                                                                        } else {
                                                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                                                [weakSelf showGenericErrorAlertControllerWithMessage:NSLocalizedString(kLocalizationContentPickerComponentIntegrationLoginErrorText,  @"Cannot author integration service")];
                                                                            });
                                                                        }
                                                                    }];
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self.integrationLoginController];
        
        [self presentViewController:navigationController
                                 animated:YES
                               completion:nil];
    } else {
        if ([self.delegate respondsToSelector:@selector(userPickerIntegrationAccount:)]) {
            [self.delegate userPickerIntegrationAccount:account];
        }
    }
}


#pragma mark -
#pragma mark Progress hud setup

- (void)showUploadProgressHUD {
    self.progressHUD.textLabel.text = NSLocalizedString(kLocalizationContentPickerComponentUploadingText, @"Uploading text");
    self.progressHUD.indicatorView = [[JGProgressHUDPieIndicatorView alloc] init];
    [self.progressHUD showInView:self.navigationController.view];
}

- (void)showDownloadProgressHUD {
    self.progressHUD.textLabel.text = NSLocalizedString(kLocalizationContentPickerComponentDownloadingText, @"Downloading text");
    self.progressHUD.indicatorView = [[JGProgressHUDIndeterminateIndicatorView alloc] init];
    [self.progressHUD showInView:self.navigationController.view];
}

- (void)showIntegrationLoginHUD {
    self.progressHUD.textLabel.text = NSLocalizedString(kLocalizationContentPickerComponentIntegrationLoginSuccessfullText, @"Logged in successfully text");
    self.progressHUD.indicatorView = [[JGProgressHUDSuccessIndicatorView alloc] init];
    self.progressHUD.detailTextLabel.text = nil;
    [self.progressHUD showInView:self.navigationController.view];
}

- (JGProgressHUD *)configureProgressHUD {
    JGProgressHUD *hud = [[JGProgressHUD alloc] initWithStyle:JGProgressHUDStyleDark];
    hud.interactionType = JGProgressHUDInteractionTypeBlockAllTouches;
    JGProgressHUDFadeZoomAnimation *zoomAnimation = [JGProgressHUDFadeZoomAnimation animation];
    hud.animation = zoomAnimation;
    hud.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(kLocalizationContentPickerComponentProgressPercentFormat, @"Percent format"), 0];
    
    return hud;
}


#pragma mark -
#pragma mark QLPreviewController Delegate & Datasource

- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller {
    return 1;
}

- (id<QLPreviewItem> _Nonnull)previewController:(QLPreviewController * _Nonnull)controller
                             previewItemAtIndex:(NSInteger)index {
    return self.currentSelectedDownloadResourceURL;
}

#pragma mark -
#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath
                             animated:YES];
    
    switch (indexPath.row) {
        case AFAContentPickerCellTypeLocalContent: {
            [self onSelectPhoto];
        }
            break;
            
        case AFAContentPickerCellTypeCamera: {
            if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                [self showGenericErrorAlertControllerWithMessage:NSLocalizedString(kLocalizationContentPickerComponentCameraNotAvailableErrorText, @"Camera not available error text")];
            } else {
                [self onTakePhoto];
            }
        }
            break;
            
        default: { // Handle integration services cell behaviour
            [self handleIntegrationAccountSelectionForIndexPath:indexPath];
        }
            break;
    }
}

@end

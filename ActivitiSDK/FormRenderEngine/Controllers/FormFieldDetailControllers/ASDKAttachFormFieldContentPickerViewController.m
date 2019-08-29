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

#import "ASDKAttachFormFieldContentPickerViewController.h"

// Constants
#import "ASDKFormRenderEngineConstants.h"
#import "ASDKLocalizationConstants.h"
#import "ASDKNetworkServiceConstants.h"

// Categories
#import "UIViewController+ASDKAlertAddition.h"

// Models
#import "ASDKModelContent.h"
#import "ASDKModelFileContent.h"
#import "ASDKModelFormFieldAttachParameter.h"
#import "ASDKModelIntegrationAccount.h"
#import "ASDKDataAccessorResponseProgress.h"
#import "ASDKDataAccessorResponseModel.h"
#import "ASDKDataAccessorResponseFileContent.h"
#import "ASDKDataAccessorResponseCollection.h"

// Cells
#import "ASDKAddContentTableViewCell.h"

// Views
#import <JGProgressHUD/JGProgressHUD.h>

// View controllers
#import "ASDKAttachFormFieldDetailsViewController.h"
#import "ASDKIntegrationLoginWebViewViewController.h"

// Managers
#import "ASDKFormDataAccessor.h"
#import "ASDKIntegrationDataAccessor.h"
#import "ASDKDiskServices.h"
#import "ASDKKVOManager.h"
#import "ASDKPhotosLibraryService.h"
#import "ASDKCloudDecommissionService.h"
@import Photos;
@import QuickLook;

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

typedef NS_ENUM(NSInteger, ASDKAttachFormFieldDetailsCellType) {
    ASDKAttachFormFieldDetailsCellTypeLocalContent = 0,
    ASDKAttachFormFieldDetailsCellTypeCamera,
    ASDKAttachFormFieldDetailsCellTypeEnumCount
};

@interface ASDKAttachFormFieldContentPickerViewController () <UINavigationControllerDelegate,
                                                              UIImagePickerControllerDelegate,
                                                              QLPreviewControllerDataSource,
                                                              QLPreviewControllerDelegate,
                                                              ASDKDataAccessorDelegate>

@property (weak, nonatomic)   IBOutlet UITableView                          *actionsTableView;
@property (strong, nonatomic) JGProgressHUD                                 *progressHUD;
@property (strong, nonatomic) UIImagePickerController                       *imagePickerController;
@property (strong, nonatomic) QLPreviewController                           *previewController;
@property (strong, nonatomic) ASDKIntegrationLoginWebViewViewController     *integrationLoginController;

// Data accessors
@property (strong, nonatomic) ASDKFormDataAccessor                          *uploadFormContentDataAccessor;
@property (strong, nonatomic) ASDKFormDataAccessor                          *downloadFormContentDataAccessor;
@property (strong, nonatomic) ASDKIntegrationDataAccessor                   *fetchIntegrationAccountListDataAccessor;

// Internal state properties
@property (strong, nonatomic) NSURL                                         *currentSelectedUploadResourceURL;
@property (strong, nonatomic) NSURL                                         *currentSelectedDownloadResourceURL;
@property (strong, nonatomic) NSData                                        *currentSelectedResourceData;
@property (strong, nonatomic) NSArray                                       *integrationAccounts;

@property (strong, nonatomic) ASDKKVOManager                                *kvoManager;

@end

@implementation ASDKAttachFormFieldContentPickerViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        _progressHUD = [self configureProgressHUD];
        
        [self handleBindingsForNetworkConnectivity];
    }
    
    return self;
}

- (void)dealloc {
    [self.kvoManager removeObserver:self
                         forKeyPath:NSStringFromSelector(@selector(networkReachabilityStatus))];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (ASDKNetworkReachabilityStatusReachableViaWWANOrWifi == self.networkReachabilityStatus) {
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
            [strongSelf showGenericErrorAlertControllerWithMessage:ASDKLocalizedStringFromTable(kLocalizationFormContentPickerComponentNotAuthorizedText, ASDKLocalizationTable, @"Access not granted error")];

        }
    }];
}

- (void)onSelectPhoto {
    __weak typeof(self) weakSelf = self;
    [ASDKPhotosLibraryService requestPhotosAuthorizationWithCompletionBlock:^(BOOL isAuthorized) {
        __strong typeof(self) strongSelf = weakSelf;
        
        if (isAuthorized) {
            self.imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            [self presentViewController:self.imagePickerController
                               animated:YES
                             completion:nil];
        } else {
            [strongSelf showGenericErrorAlertControllerWithMessage:ASDKLocalizedStringFromTable(kLocalizationFormContentPickerComponentNotAuthorizedText, ASDKLocalizationTable, @"Access not granted error")];
        }
    }];
}

- (void)dowloadContent:(ASDKModelContent *)content
    allowCachedContent:(BOOL)allowCachedContent {
    
    [self showDownloadProgressHUD];
    
    self.downloadFormContentDataAccessor = [[ASDKFormDataAccessor alloc] initWithDelegate:self];
    self.downloadFormContentDataAccessor.cachePolicy = allowCachedContent ? ASDKServiceDataAccessorCachingPolicyCacheOnly : ASDKServiceDataAccessorCachingPolicyAPIOnly;
    [self.downloadFormContentDataAccessor downloadContentWithModel:content];
}

- (void)previewDownloadedContent {
    if (!self.previewController) {
        self.previewController =  [QLPreviewController new];
        self.previewController.dataSource = self;
        self.previewController.delegate = self;
    } else {
        [self.previewController refreshCurrentPreviewItem];
    }
    
    [self.navigationController presentViewController:self.previewController
                                            animated:YES
                                          completion:nil];
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
                                                        
                                                        [strongSelf uploadFormFieldContentForCurrentSelectedResource];
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
        [self uploadFormFieldContentForCurrentSelectedResource];
        
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
#pragma mark Service integration

- (void)fetchIntegrationAccounts {
    self.fetchIntegrationAccountListDataAccessor = [[ASDKIntegrationDataAccessor alloc] initWithDelegate:self];
    [self.fetchIntegrationAccountListDataAccessor fetchIntegrationAccounts];
}

- (void)uploadFormFieldContentForCurrentSelectedResource {
    ASDKModelFileContent *fileContentModel = [ASDKModelFileContent new];
    fileContentModel.modelFileURL = self.currentSelectedUploadResourceURL;
    
    self.uploadFormContentDataAccessor = [[ASDKFormDataAccessor alloc] initWithDelegate:self];
    [self.uploadFormContentDataAccessor uploadContentWithModel:fileContentModel
                                                   contentData:self.currentSelectedResourceData];
}


#pragma mark -
#pragma mark Progress hud setup

- (void)showUploadProgressHUD {
    self.progressHUD.textLabel.text = ASDKLocalizedStringFromTable(kLocalizationFormContentPickerComponentUploadingText, ASDKLocalizationTable, @"Uploading text");
    self.progressHUD.indicatorView = [[JGProgressHUDPieIndicatorView alloc] init];
    [self.progressHUD showInView:self.navigationController.view];
}

- (void)showDownloadProgressHUD {
    self.progressHUD.textLabel.text = ASDKLocalizedStringFromTable(kLocalizationFormContentPickerComponentDownloadingText, ASDKLocalizationTable, @"Downloading text");
    self.progressHUD.indicatorView = [[JGProgressHUDIndeterminateIndicatorView alloc] init];
    [self.progressHUD showInView:self.navigationController.view];
}

- (void)showIntegrationLoginHUD {
    self.progressHUD.textLabel.text = ASDKLocalizedStringFromTable(kLocalizationIntegrationLoginSuccessfullText, ASDKLocalizationTable, @"Logged in successfully text");
    self.progressHUD.indicatorView = [[JGProgressHUDSuccessIndicatorView alloc] init];
    self.progressHUD.detailTextLabel.text = nil;
    [self.progressHUD showInView:self.navigationController.view];
}

- (JGProgressHUD *)configureProgressHUD {
    JGProgressHUD *hud = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
    hud.interactionType = JGProgressHUDInteractionTypeBlockAllTouches;
    JGProgressHUDFadeZoomAnimation *zoomAnimation = [JGProgressHUDFadeZoomAnimation animation];
    hud.animation = zoomAnimation;
    
    hud.detailTextLabel.text = [NSString stringWithFormat:ASDKLocalizedStringFromTable(kLocalizationFormContentPickerComponentProgressPercentageFormat, ASDKLocalizationTable, @"Percent format"), 0];
    
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
#pragma mark Tableview Delegate & Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    return ASDKAttachFormFieldDetailsCellTypeEnumCount + self.integrationAccounts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ASDKAddContentTableViewCell *taskCell = [tableView dequeueReusableCellWithIdentifier:kASDKCellIDFormFieldAttachAddContent
                                                                            forIndexPath:indexPath];
    NSBundle *frameWorkBundle = [NSBundle bundleForClass:[self class]];
    
    switch (indexPath.row) {
        case ASDKAttachFormFieldDetailsCellTypeLocalContent: {
            taskCell.iconImageView.image = [UIImage imageNamed:@"phone-icon"
                                                      inBundle:frameWorkBundle
                                 compatibleWithTraitCollection:nil];
            taskCell.actionDescriptionLabel.text = ASDKLocalizedStringFromTable(kLocalizationFormContentPickerComponentLocalContentText, ASDKLocalizationTable, @"Local content text");
        }
            break;
            
        case ASDKAttachFormFieldDetailsCellTypeCamera: {
            taskCell.iconImageView.image = [UIImage imageNamed:@"camera-icon"
                                                      inBundle:frameWorkBundle
                                 compatibleWithTraitCollection:nil];
            taskCell.actionDescriptionLabel.text =  ASDKLocalizedStringFromTable(kLocalizationFormContentPickerComponentCameraContentText, ASDKLocalizationTable,@"Camera content text");
        }
            break;
            
        default: { // Handle the integration cells
            ASDKModelIntegrationAccount *account = self.integrationAccounts[indexPath.row - ASDKAttachFormFieldDetailsCellTypeEnumCount];
            
            if ([kASDKAPIServiceIDAlfrescoCloud isEqualToString:account.integrationServiceID]) {
                taskCell.iconImageView.image = [UIImage imageNamed:@"alfresco-icon"
                                                          inBundle:frameWorkBundle
                                     compatibleWithTraitCollection:nil];
                taskCell.actionDescriptionLabel.text = ASDKLocalizedStringFromTable(kLocalizationFormContentPickerComponentAlfrescoContentText, ASDKLocalizationTable, @"Alfresco cloud text");
            } else if ([kASDKAPIServiceIDBox isEqualToString:account.integrationServiceID]) {
                taskCell.iconImageView.image = [UIImage imageNamed:@"box-icon"
                                                          inBundle:frameWorkBundle
                                     compatibleWithTraitCollection:nil];
                taskCell.actionDescriptionLabel.text = ASDKLocalizedStringFromTable(kLocalizationFormContentPickerComponentBoxContentText, ASDKLocalizationTable, @"Box text");
            } else if ([kASDKAPIServiceIDGoogleDrive isEqualToString:account.integrationServiceID]) {
                taskCell.iconImageView.image = [UIImage imageNamed:@"drive-icon"
                                                          inBundle:frameWorkBundle
                                     compatibleWithTraitCollection:nil];
                taskCell.actionDescriptionLabel.text = ASDKLocalizedStringFromTable(kLocalizationFormContentPickerComponentDriveText, ASDKLocalizationTable, @"Google drive text");
            }
        }
            break;
    }
    
    return taskCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath
                             animated:YES];
    
    switch (indexPath.row) {
        case ASDKAttachFormFieldDetailsCellTypeLocalContent: {
            [self onSelectPhoto];
        }
            break;
            
        case ASDKAttachFormFieldDetailsCellTypeCamera: {
            if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                [self showGenericErrorAlertControllerWithMessage:ASDKLocalizedStringFromTable(kLocalizationFormContentPickerComponentCameraNotAvailableErrorText, ASDKLocalizationTable,  @"Camera not available error text")];
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


#pragma mark -
#pragma mark ASDKDataAccessorDelegate

- (void)dataAccessor:(id<ASDKServiceDataAccessorProtocol>)dataAccessor
 didLoadDataResponse:(ASDKDataAccessorResponseBase *)response {
    if (self.uploadFormContentDataAccessor == dataAccessor) {
        [self handleFormContentUploadDataAccessorResponse:response];
    } else if (self.downloadFormContentDataAccessor == dataAccessor) {
        [self handleFormContentDownloadDataAccessorResponse:response];
    } else if (self.fetchIntegrationAccountListDataAccessor == dataAccessor) {
        [self handleIntegrationAccountListDataAccessorResponse:response];
    }
}

- (void)dataAccessorDidFinishedLoadingDataResponse:(id<ASDKServiceDataAccessorProtocol>)dataAccessor {
}


#pragma mark -
#pragma mark Data accessor response handlers

- (void)handleFormContentUploadDataAccessorResponse:(ASDKDataAccessorResponseBase *)response {
    __weak typeof(self) weakSelf = self;
    if ([response isKindOfClass:[ASDKDataAccessorResponseProgress class]]) {
        ASDKDataAccessorResponseProgress *progressResponse = (ASDKDataAccessorResponseProgress *)response;
        NSUInteger progress = progressResponse.progress;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(self) strongSelf = weakSelf;
            
            [strongSelf.progressHUD setProgress:progress / 100.0f
                                       animated:YES];
            strongSelf.progressHUD.detailTextLabel.text = [NSString stringWithFormat:ASDKLocalizedStringFromTable(kLocalizationFormContentPickerComponentProgressPercentageFormat, ASDKLocalizationTable, @"Percent format"), progress];
        });
    } else if ([response isKindOfClass:[ASDKDataAccessorResponseModel class]]) {
        ASDKDataAccessorResponseModel *contentResponse = (ASDKDataAccessorResponseModel *)response;
        ASDKModelContent *modelContent = contentResponse.model;
        
        BOOL didContentUploadSucceeded = modelContent.isModelContentAvailable && !contentResponse.error;
        if (didContentUploadSucceeded) {
            self.progressHUD.textLabel.text = ASDKLocalizedStringFromTable(kLocalizationFormContentPickerComponentSuccessText, ASDKLocalizationTable,  @"Success text");
            self.progressHUD.detailTextLabel.text = nil;
            self.progressHUD.indicatorView = [[JGProgressHUDSuccessIndicatorView alloc] init];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                __strong typeof(self) strongSelf = weakSelf;
                
                [strongSelf.progressHUD dismiss];
                
                // add content to attach field
                //
                // if multiple files allowed -> add
                // otherwise -> replace
                
                ASDKModelFormFieldAttachParameter *formFieldParameters = (ASDKModelFormFieldAttachParameter *)strongSelf.currentFormField.formFieldParams;
                NSMutableArray *currentValuesArray = nil;
                
                if (formFieldParameters.allowMultipleFiles) {
                    currentValuesArray = [NSMutableArray arrayWithArray:strongSelf.currentFormField.values];
                } else {
                    currentValuesArray = [NSMutableArray array];
                }
                
                [currentValuesArray addObject:modelContent];
                strongSelf.currentFormField.values = [currentValuesArray copy];
                
                // store uploaded content id
                // used for automatic selection local storage version instead of remote version
                [strongSelf.uploadedContentIDs addObject:modelContent.modelID];
                
                if ([strongSelf.delegate respondsToSelector:@selector(pickedContentHasFinishedUploading)]) {
                    [strongSelf.delegate pickedContentHasFinishedUploading];
                }
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                __strong typeof(self) strongSelf = weakSelf;
                
                [strongSelf showGenericNetworkErrorAlertControllerWithMessage:ASDKLocalizedStringFromTable(kLocalizationFormContentPickerComponentFailedText, ASDKLocalizationTable, @"Failed title")];
                [strongSelf.progressHUD dismiss];
            });
        }
    }
}

- (void)handleFormContentDownloadDataAccessorResponse:(ASDKDataAccessorResponseBase *)response {
    __weak typeof(self) weakSelf = self;
    if ([response isKindOfClass:[ASDKDataAccessorResponseProgress class]]) {
        ASDKDataAccessorResponseProgress *progressResponse = (ASDKDataAccessorResponseProgress *)response;
        NSString *formattedProgressString = progressResponse.formattedProgressString;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(self) strongSelf = weakSelf;
            
            if (!progressResponse.error) {
                strongSelf.progressHUD.detailTextLabel.text = [NSString stringWithFormat:ASDKLocalizedStringFromTable(kLocalizationFormContentPickerComponentDownloadProgressFormat, ASDKLocalizationTable, @"Download progress format"), formattedProgressString];
            } else {
                [strongSelf.progressHUD dismiss];
                [strongSelf showGenericNetworkErrorAlertControllerWithMessage:ASDKLocalizedStringFromTable(kLocalizationFormContentPickerComponentFailedText, ASDKLocalizationTable, @"Content download error")];
            }
        });
    } else if ([response isKindOfClass:[ASDKDataAccessorResponseFileContent class]]) {
        ASDKDataAccessorResponseFileContent *fileContentResponse = (ASDKDataAccessorResponseFileContent *)response;
        
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(self) strongSelf = weakSelf;
            
            if (!fileContentResponse.error) {
                // If local content is available ask the user how he would like to preview it
                if (fileContentResponse.isCachedData) {
                    [strongSelf.progressHUD dismiss];
                    
                    // if local content is uploaded then do not show modal
                    if ([strongSelf.uploadedContentIDs containsObject:fileContentResponse.content.modelID]) {
                        strongSelf.currentSelectedDownloadResourceURL = fileContentResponse.contentURL;
                        [strongSelf previewDownloadedContent];
                    } else {
                        [strongSelf showMultipleChoiceAlertControllerWithTitle:nil
                                                                       message:ASDKLocalizedStringFromTable(kLocalizationFormContentPickerComponentLocalVersionAvailableText, ASDKLocalizationTable, @"Local content available")
                                                   choiceButtonTitlesAndBlocks:ASDKLocalizedStringFromTable(kLocalizationFormContentPickerComponentPreviewLocalVersionText, ASDKLocalizationTable, @"Preview local content"),
                         // Preview local content option
                         ^(UIAlertAction *action) {
                             weakSelf.currentSelectedDownloadResourceURL = fileContentResponse.contentURL;
                             [weakSelf previewDownloadedContent];
                         },
                         ASDKLocalizedStringFromTable(kLocalizationFormContentPickerComponentGetLatestVersionText, ASDKLocalizationTable, @"Get latest version"),
                         // Get latest version from the server
                         ^(UIAlertAction *action) {
                             [weakSelf dowloadContent:fileContentResponse.content
                                   allowCachedContent:NO];
                         }, nil];
                    }
                    
                    return;
                }
                
                if (fileContentResponse.contentURL &&
                    fileContentResponse.content) {
                    strongSelf.currentSelectedDownloadResourceURL = fileContentResponse.contentURL;
                    
                    strongSelf.progressHUD.textLabel.text = ASDKLocalizedStringFromTable(kLocalizationFormContentPickerComponentSuccessText, ASDKLocalizationTable,  @"Success text");
                    strongSelf.progressHUD.detailTextLabel.text = nil;
                    strongSelf.progressHUD.indicatorView = [[JGProgressHUDSuccessIndicatorView alloc] init];
                    
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [weakSelf.progressHUD dismiss];
                        
                        if ([weakSelf.delegate respondsToSelector:@selector(pickedContentHasFinishedDownloadingAtURL:)]) {
                            [weakSelf.delegate pickedContentHasFinishedDownloadingAtURL:fileContentResponse.contentURL];
                        }
                        
                        // Present the quick look controller
                        [weakSelf previewDownloadedContent];
                    });
                } else {
                    [strongSelf showGenericNetworkErrorAlertControllerWithMessage:@"Content download error"];
                }
            } else {
                [strongSelf.progressHUD dismiss];
                [strongSelf showGenericNetworkErrorAlertControllerWithMessage:@"Content download error"];
            }
        });
    }
}

- (void)handleIntegrationAccountListDataAccessorResponse:(ASDKDataAccessorResponseBase *)response {
    ASDKDataAccessorResponseCollection *integrationAccountListResponse = (ASDKDataAccessorResponseCollection *)response;
    
    if (!integrationAccountListResponse.error) {
        // Remove all integrations for now
        self.integrationAccounts = [NSArray new];
        
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(self) strongSelf = weakSelf;
            
            if (strongSelf.delegate) {
                [strongSelf.delegate contentPickerHasBeenPresentedWithNumberOfOptions:ASDKAttachFormFieldDetailsCellTypeEnumCount + strongSelf.integrationAccounts.count
                                                                           cellHeight:weakSelf.actionsTableView.rowHeight];
            }
            [strongSelf.actionsTableView reloadData];
        });
    } else {
        [self showGenericNetworkErrorAlertControllerWithMessage:ASDKLocalizedStringFromTable(kLocalizationIntegrationBrowsingNoIntegrationAccountText, ASDKLocalizationTable, @"Failed title")];
    }
}

#pragma mark -
#pragma mark Integration account selection handling

- (void)handleIntegrationAccountSelectionForIndexPath:(NSIndexPath *)indexPath {
    ASDKModelIntegrationAccount *account = self.integrationAccounts[indexPath.row - ASDKAttachFormFieldDetailsCellTypeEnumCount];
    
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
                                                                                [weakSelf showGenericErrorAlertControllerWithMessage:ASDKLocalizedStringFromTable(kLocalizationIntegrationLoginErrorText, ASDKLocalizationTable,  @"Cannot author integration service")];
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
#pragma mark KVO Bindings

- (void)handleBindingsForNetworkConnectivity {
    self.kvoManager = [ASDKKVOManager managerWithObserver:self];
    
    __weak typeof(self) weakSelf = self;
    [self.kvoManager observeObject:self
                        forKeyPath:NSStringFromSelector(@selector(networkReachabilityStatus))
                           options:NSKeyValueObservingOptionNew
                             block:^(id observer, id object, NSDictionary *change) {
                                 ASDKNetworkReachabilityStatus networkReachabilityStatus = [change[NSKeyValueChangeNewKey] boolValue];
                                 
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     if (ASDKNetworkReachabilityStatusReachableViaWWANOrWifi == networkReachabilityStatus) {
                                         [weakSelf fetchIntegrationAccounts];
                                     }
                                 });
                             }];
}

@end

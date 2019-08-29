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

#import "ASDKIntegrationBrowsingViewController.h"

// Constants
#import "ASDKLogConfiguration.h"
#import "ASDKFormRenderEngineConstants.h"
#import "ASDKLocalizationConstants.h"

// Categories
#import "UIFont+ASDKGlyphicons.h"
#import "NSString+ASDKFontGlyphicons.h"

// Data sources
#import "ASDKIntegrationNetworksDataSource.h"
#import "ASDKIntegrationSitesDataSource.h"
#import "ASDKIntegrationSiteContentDataSource.h"
#import "ASDKIntegrationFolderContentDataSource.h"

// Model
#import "ASDKModelNetwork.h"
#import "ASDKIntegrationNodeContentRequestRepresentation.h"

// Views
#import "ASDKActivityView.h"

// Managers
#import "ASDKKVOManager.h"
#import "ASDKFormColorSchemeManager.h"

typedef NS_ENUM(NSInteger, AFAApplicationListControllerState) {
    AFAApplicationListControllerStateIdle,
    AFAApplicationListControllerStateRefreshInProgress,
};

typedef NS_ENUM(NSInteger, ASDKIntegrationBrowsingControllerState) {
    ASDKIntegrationBrowsingControllerStateIdle,
    ASDKIntegrationBrowsingControllerStateInProgress
};


#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

static const int activitiSDKLogLevel = ASDK_LOG_LEVEL_VERBOSE; // | ASDK_LOG_FLAG_TRACE;

@interface ASDKIntegrationBrowsingViewController () <ASDKIntegrationDataSourceDelegate>

@property (weak, nonatomic) IBOutlet UITableView                            *browsingTableView;
@property (weak, nonatomic) IBOutlet ASDKActivityView                       *activityView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem                        *cancelBarButtonItem;
@property (weak, nonatomic) IBOutlet UILabel                                *noContentAvailableLabel;
@property (weak, nonatomic) IBOutlet UIView                                 *refreshView;
@property (strong, nonatomic) UIRefreshControl                              *refreshControl;
@property (weak, nonatomic) IBOutlet UIButton                               *refreshButton;

// Internal state properties
@property (strong, nonatomic) id<ASDKIntegrationDataSourceProtocol>         dataSource;
@property (assign, nonatomic) ASDKIntegrationBrowsingControllerState        controllerState;
@property (assign, nonatomic) BOOL                                          isPullToRefresh;
@property (strong, nonatomic) ASDKFormColorSchemeManager                    *colorSchemeManager;

// KVO
@property (strong, nonatomic) ASDKKVOManager                                *kvoManager;

@end

@implementation ASDKIntegrationBrowsingViewController

- (instancetype)initBrowserWithDataSource:(id<ASDKIntegrationDataSourceProtocol>)dataSource {
    UIStoryboard *formStoryboard = [UIStoryboard storyboardWithName:kASDKFormStoryboardBundleName
                                                             bundle:[NSBundle bundleForClass:[self class]]];
    self = [formStoryboard instantiateViewControllerWithIdentifier:kASDKStoryboardIDIntegrationBrowsingViewController];
    if (self) {
        ASDKBootstrap *sdkBootstrap = [ASDKBootstrap sharedInstance];
        self.colorSchemeManager = [sdkBootstrap.serviceLocator serviceConformingToProtocol:@protocol(ASDKFormColorSchemeManagerProtocol)];
        
        // Set up state bindings
        self.dataSource = dataSource;
        [self handleBindingsForAppListViewController];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setBarTintColor:self.colorSchemeManager.navigationBarThemeColor];
    [self.navigationController.navigationBar setTranslucent:NO];
    // Force the status bar to be displayed as light content
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    
    self.cancelBarButtonItem.title = ASDKLocalizedStringFromTable(kLocalizationCancelButtonText, ASDKLocalizationTable, @"Cancel");
    self.cancelBarButtonItem.tintColor = self.colorSchemeManager.navigationBarTitleAndControlsColor;
    
    // Set up the browsing table view to adjust it's size automatically
    self.browsingTableView.estimatedRowHeight = 64.0f;
    self.browsingTableView.rowHeight = UITableViewAutomaticDimension;
    
    // Set up the refresh control
    UITableViewController *tableViewController = [[UITableViewController alloc] init];
    [self addChildViewController:tableViewController];
    tableViewController.tableView = self.browsingTableView;
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self
                            action:@selector(onRefresh:)
                  forControlEvents:UIControlEventValueChanged];
    tableViewController.refreshControl = self.refreshControl;
    
    self.refreshButton.titleLabel.font = [UIFont glyphiconFontWithSize:15];
    [self.refreshButton setTitle:[NSString iconStringForIconType:ASDKGlyphIconTypeRefresh]
                        forState:UIControlStateNormal];
    
    if ([self.dataSource isKindOfClass:[ASDKIntegrationNetworksDataSource class]]) {
        self.title = ASDKLocalizedStringFromTable(kLocalizationIntegrationBrowsingChooseNetworkText, ASDKLocalizationTable, @"Choose network text");
    } else if ([self.dataSource isKindOfClass:[ASDKIntegrationSitesDataSource class]]) {
        self.title = ASDKLocalizedStringFromTable(kLocalizationIntegrationBrowsingChooseSiteText, ASDKLocalizationTable, @"Choose site");
    }
    
    // Update navigation bar title
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = self.title;
    titleLabel.font = [UIFont fontWithName:@"Avenir-Book"
                                      size:17];
    titleLabel.textColor = self.colorSchemeManager.navigationBarTitleAndControlsColor;
    [titleLabel sizeToFit];
    self.navigationItem.titleView = titleLabel;
    
    self.dataSource.delegate = self;
    self.browsingTableView.dataSource = self.dataSource;
    
    [self.dataSource refreshDataSourceInformation];
}


#pragma mark -
#pragma mark Actions

- (IBAction)onCancel:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES
                                                  completion:nil];
}

- (IBAction)onRefresh:(id)sender {
    self.isPullToRefresh = YES;
    [self.dataSource refreshDataSourceInformation];
}

- (void)popChildController {
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark -
#pragma mark ASDKIntegrationDataSourceProtocol

- (void)dataSourceIsFetchingContent {
    self.controllerState = self.isPullToRefresh ? ASDKIntegrationBrowsingControllerStateIdle : ASDKIntegrationBrowsingControllerStateInProgress;
}

- (void)dataSourceFinishedFetchingContent:(BOOL)isContentAvailable {
    self.controllerState = ASDKIntegrationBrowsingControllerStateIdle;
    self.isPullToRefresh = NO;
    
    self.noContentAvailableLabel.hidden = isContentAvailable;
    self.noContentAvailableLabel.text = ASDKLocalizedStringFromTable(kLocalizationIntegrationBrowsingNoContentAvailableText, ASDKLocalizationTable, @"No content available");
    [self.browsingTableView reloadData];
    
    [[NSOperationQueue currentQueue] addOperationWithBlock:^{
        [self.refreshControl endRefreshing];
    }];
}

- (void)dataSourceEncounteredAnErrorWhileLoadingContent:(NSError *)error {
    self.controllerState = ASDKIntegrationBrowsingControllerStateIdle;
    self.isPullToRefresh = NO;
    
    ASDKLogError(@"An error occured while fetching content for the integration data source. Reason:%@", error.localizedDescription);
    
    self.refreshView.hidden = NO;
    self.noContentAvailableLabel.text = ASDKLocalizedStringFromTable(kLocalizationFormAlertDialogGenericNetworkErrorText, ASDKLocalizationTable, @"Network error text");
    self.noContentAvailableLabel.hidden = NO;
    
    [[NSOperationQueue currentQueue] addOperationWithBlock:^{
        [self.refreshControl endRefreshing];
    }];
}


#pragma mark -
#pragma mark UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ASDKIntegrationBrowsingViewController *childController = nil;
    id<ASDKIntegrationDataSourceProtocol> dataSource = nil;
    
    // If the current data source is providing network information this means
    // we're looking at the Alfresco Cloud integration and the next data source should be
    // sites for that network
    if ([self.dataSource isKindOfClass:[ASDKIntegrationNetworksDataSource class]]) {
        dataSource = [[ASDKIntegrationSitesDataSource alloc] initWithNetworkModel:[self.dataSource itemAtIndexPath:indexPath]];
    } else if ([self.dataSource isKindOfClass:[ASDKIntegrationSitesDataSource class]]) {
        dataSource =
        [[ASDKIntegrationSiteContentDataSource alloc] initWithNetworkModel:((ASDKIntegrationSitesDataSource *)self.dataSource).currentNetwork
                                                                 siteModel:[self.dataSource itemAtIndexPath:indexPath]];
    } else if ([self.dataSource isKindOfClass:[ASDKIntegrationSiteContentDataSource class]]) {
        dataSource =
        [[ASDKIntegrationFolderContentDataSource alloc] initWithNetworkModel:((ASDKIntegrationSiteContentDataSource *)self.dataSource).currentNetwork
                                                                   siteModel:((ASDKIntegrationSiteContentDataSource *)self.dataSource).currentSite
                                                                 contentNode:[self.dataSource itemAtIndexPath:indexPath]];
    } else if ([self.dataSource isKindOfClass:[ASDKIntegrationFolderContentDataSource class]]) {
        if ([self.dataSource isItemAtIndexPathAFolder:indexPath]) {
            dataSource =
            [[ASDKIntegrationFolderContentDataSource alloc] initWithNetworkModel:((ASDKIntegrationFolderContentDataSource *)self.dataSource).currentNetwork
                                                                       siteModel:((ASDKIntegrationFolderContentDataSource *)self.dataSource).currentSite
                                                                     contentNode:[self.dataSource itemAtIndexPath:indexPath]];
        } else { // Report to the delegate that a file has been chosen
            [self dismissViewControllerAnimated:YES
                                     completion:^{
                                         if ([self.delegate respondsToSelector:@selector(didPickContentNodeWithRepresentation:)]) {
                                             [self.delegate didPickContentNodeWithRepresentation:[self.dataSource nodeContentRepresentationForIndexPath:indexPath]];
                                         }
                                     }];
        }
    }
    
    // Only instantiate a child controller if it has a valid data source
    if (dataSource) {
        [dataSource setIntegrationAccount:[self.dataSource integrationAccount]];
        childController = [[ASDKIntegrationBrowsingViewController alloc] initBrowserWithDataSource:dataSource];
        childController.delegate = self.delegate;
        if ([self.dataSource respondsToSelector:@selector(nodeTitleForIndexPath:)]) {
            childController.title = [self.dataSource nodeTitleForIndexPath:indexPath];
        }
    }
    
    if (childController) {
        UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:[NSString iconStringForIconType:ASDKGlyphIconTypeChevronLeft]
                                                                       style:UIBarButtonItemStylePlain
                                                                      target:self
                                                                      action:@selector(popChildController)];
        [backButton setTitleTextAttributes:@{NSFontAttributeName           : [UIFont glyphiconFontWithSize:15],
                                             NSForegroundColorAttributeName: self.colorSchemeManager.navigationBarTitleAndControlsColor}
                                  forState:UIControlStateNormal];
        [self.navigationItem setBackBarButtonItem:backButton];
        childController.navigationItem.leftBarButtonItem = backButton;
        
        [self.navigationController pushViewController:childController
                                             animated:YES];
    } else {
        [tableView deselectRowAtIndexPath:tableView.indexPathForSelectedRow
                                 animated:YES];
    }
}


#pragma mark -
#pragma mark KVO bindings

- (void)handleBindingsForAppListViewController {
    self.kvoManager = [ASDKKVOManager managerWithObserver:self];
    
    __weak typeof(self) weakSelf = self;
    [self.kvoManager observeObject:self
                        forKeyPath:NSStringFromSelector(@selector(controllerState))
                           options:NSKeyValueObservingOptionNew
                             block:^(id observer, id object, NSDictionary *change) {
                                 __strong typeof(self) strongSelf = weakSelf;
                                 
                                 AFAApplicationListControllerState controllerState = [change[NSKeyValueChangeNewKey] boolValue];
                                 
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     strongSelf.browsingTableView.hidden = (ASDKIntegrationBrowsingControllerStateInProgress == controllerState) ? YES : NO;
                                     strongSelf.activityView.hidden = (ASDKIntegrationBrowsingControllerStateInProgress == controllerState) ? NO : YES;
                                     strongSelf.activityView.animating = (ASDKIntegrationBrowsingControllerStateInProgress == controllerState) ? YES : NO;
                                     if (ASDKIntegrationBrowsingControllerStateInProgress == controllerState) {
                                         strongSelf.refreshView.hidden = YES;
                                         strongSelf.noContentAvailableLabel.hidden = YES;
                                     }
                                 });
                             }];
}

@end

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

#import "AFAStartProcessInstanceViewController.h"
@import ActivitiSDK;

// Constants
#import "AFALocalizationConstants.h"
#import "AFAUIConstants.h"

// Categories
#import "UIViewController+AFAAlertAddition.h"
#import "NSDate+AFAStringTransformation.h"

// Data Sources
#import "AFAProcessInstanceDetailsDataSource.h"

// Managers
#import "AFAProcessServices.h"
#import "AFAServiceRepository.h"

// Views
#import "AFAActivityView.h"
#import <JGProgressHUD/JGProgressHUD.h>

// Cells
#import "AFAProcessDefinitionListStyleTableViewCell.h"

// Controllers
#import "AFAProcessStartFormViewController.h"
#import "AFAProcessInstanceDetailsViewController.h"

typedef NS_ENUM(NSUInteger, AFAStartProcessInstanceLoadingState) {
    AFAStartProcessInstanceLoadingStateIdle = 0,
    AFAStartProcessInstanceLoadingStateInProgress,
    AFAStartProcessInstanceLoadingStateEmptyList
};

@interface AFAStartProcessInstanceViewController () <AFAProcessStartFormViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem                    *backBarButtonItem;
@property (weak, nonatomic) IBOutlet UITableView                        *processTableView;
@property (weak, nonatomic) IBOutlet UILabel                            *noRecordsLabel;
@property (weak, nonatomic) IBOutlet AFAActivityView                    *loadingActivityView;
@property (strong, nonatomic) UIRefreshControl                          *refreshControl;
@property (strong, nonatomic) JGProgressHUD                             *progressHUD;
@property (weak, nonatomic) IBOutlet UIView                             *formViewContainer;
@property (strong, nonatomic) AFAProcessStartFormViewController         *processStartFormController;

// Internal state properties
@property (strong, nonatomic) NSArray                                   *processDefinitionsArr;
@property (assign, nonatomic) AFAStartProcessInstanceLoadingState       controllerState;

// Services
@property (strong, nonatomic) AFAProcessServices                        *fetchAdhocProcessDefinitionListService;
@property (strong, nonatomic) AFAProcessServices                        *fetchProcessDefinitionListService;
@property (strong, nonatomic) AFAProcessServices                        *startProcessInstanceService;

// KVO
@property (strong, nonatomic) ASDKKVOManager                             *kvoManager;

@end

@implementation AFAStartProcessInstanceViewController


#pragma mark -
#pragma mark Life cycle

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        _controllerState = AFAStartProcessInstanceLoadingStateIdle;
        _progressHUD = [self configureProgressHUD];
        
        _fetchAdhocProcessDefinitionListService = [AFAProcessServices new];
        _fetchProcessDefinitionListService = [AFAProcessServices new];
        _startProcessInstanceService = [AFAProcessServices new];
        
        // Set up state bindings
        [self handleBindingsForStartProcessInstanceViewController];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set up the task list table view to adjust it's size automatically
    self.processTableView.estimatedRowHeight = 60.0f;
    self.processTableView.rowHeight = UITableViewAutomaticDimension;
    
    [self.backBarButtonItem setTitleTextAttributes:@{NSFontAttributeName           : [UIFont glyphiconFontWithSize:15],
                                                     NSForegroundColorAttributeName: [UIColor whiteColor]}
                                          forState:UIControlStateNormal];
    self.backBarButtonItem.title = [NSString iconStringForIconType:ASDKGlyphIconTypeChevronLeft];
    
    // Update UI for current localization
    [self setupLocalization];
    
    // Set up the refresh control
    UITableViewController *tableViewController = [[UITableViewController alloc] init];
    [self addChildViewController:tableViewController];
    tableViewController.tableView = self.processTableView;
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self
                            action:@selector(refreshContentForCurrentSection)
                  forControlEvents:UIControlEventValueChanged];
    tableViewController.refreshControl = self.refreshControl;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self refreshContentForCurrentSection];
}


#pragma mark -
#pragma mark Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue
                 sender:(id)sender {
    if ([kSegueIDProcessStartFormEmbedding isEqualToString:segue.identifier]) {
        self.processStartFormController = (AFAProcessStartFormViewController *)segue.destinationViewController;
        self.processStartFormController.navigationBarThemeColor = self.navigationBarThemeColor;
        self.processStartFormController.delegate = self;
    }
    
    if ([kSegueIDProcessInstanceStartForm isEqualToString:segue.identifier]) {
        AFAProcessInstanceDetailsViewController *processInstanceDetailsController = (AFAProcessInstanceDetailsViewController *)segue.destinationViewController;
        AFAProcessInstanceDetailsDataSource *processInstanceDetailsDataSource =
        [[AFAProcessInstanceDetailsDataSource alloc] initWithProcessInstanceID:[(ASDKModelProcessInstance *)sender modelID]
                                                                    themeColor:self.navigationBarThemeColor];
        
        processInstanceDetailsController.dataSource = processInstanceDetailsDataSource;
        processInstanceDetailsController.unwindActionType = AFAProcessInstanceDetailsUnwindActionTypeStartForm;
    }
}


#pragma mark -
#pragma mark Connectivity notifications

- (void)didRestoredNetworkConnectivity {
    [super didRestoredNetworkConnectivity];
    
    [self refreshContentForCurrentSection];
}

- (void)didLoseNetworkConnectivity {
    [super didLoseNetworkConnectivity];
    
    [self refreshContentForCurrentSection];
}


#pragma mark -
#pragma mark Actions

- (IBAction)onBack:(UIBarButtonItem *)sender {
    [self performSegueWithIdentifier:kSegueIDStartProcessInstanceUnwind
                              sender:sender];
}

- (void)refreshContentForCurrentSection {
    __weak typeof(self) weakSelf = self;
    if (self.appID) {
        [self.fetchProcessDefinitionListService requestProcessDefinitionListForAppID:self.appID
                                                                 withCompletionBlock:^(NSArray *processDefinitions, NSError *error, ASDKModelPaging *paging) {
                                                                     __strong typeof(self) strongSelf = weakSelf;
                                                                     [strongSelf handleProcessDefinitionResponseForProcessDefinitions:processDefinitions
                                                                                                                               paging:paging
                                                                                                                                error:error];
                                                                 } cachedResults:^(NSArray *processDefinitions, NSError *error, ASDKModelPaging *paging) {
                                                                     __strong typeof(self) strongSelf = weakSelf;
                                                                     [strongSelf handleProcessDefinitionResponseForProcessDefinitions:processDefinitions
                                                                                                                               paging:paging
                                                                                                                                error:error];
                                                                 }];
    } else {
        [self.fetchAdhocProcessDefinitionListService requestProcessDefinitionListWithCompletionBlock:^(NSArray *processDefinitions, NSError *error, ASDKModelPaging *paging) {
            __strong typeof(self) strongSelf = weakSelf;
            [strongSelf handleProcessDefinitionResponseForProcessDefinitions:processDefinitions
                                                                      paging:paging
                                                                       error:error];
        } cachedResults:^(NSArray *processDefinitions, NSError *error, ASDKModelPaging *paging) {
            __strong typeof(self) strongSelf = weakSelf;
            [strongSelf handleProcessDefinitionResponseForProcessDefinitions:processDefinitions
                                                                      paging:paging
                                                                       error:error];
        }];
    }
}

- (void)startProcessInstanceForProcessDefinition:(ASDKModelProcessDefinition *)processDefinition {
    // Update the name of the process definition so that the process instance
    // name can include the change
    processDefinition.name = [processDefinition.name stringByAppendingFormat:@" - %@", [[NSDate date] processInstanceCreationDate]];
    if (processDefinition.hasStartForm) {
        self.formViewContainer.hidden = NO;
        self.navigationBarTitle = processDefinition.name;
        [self.processStartFormController setupStartFormForProcessDefinitionObject:processDefinition];
    } else {
        [self showStarProcessProgressHUD];
        __weak typeof(self) weakSelf = self;
        [self.startProcessInstanceService
         requestProcessInstanceStartForProcessDefinition:processDefinition
         completionBlock:^(ASDKModelProcessInstance *processInstance, NSError *error) {
             __strong typeof(self) strongSelf = weakSelf;
             
             if (!error) {
                 strongSelf.progressHUD.textLabel.text = NSLocalizedString(kLocalizationSuccessText, @"Success text");
                 strongSelf.progressHUD.detailTextLabel.text = nil;
                 strongSelf.progressHUD.indicatorView = [[JGProgressHUDSuccessIndicatorView alloc] init];
                 [strongSelf.progressHUD dismissAfterDelay:1.0f];
                 
                 dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                     [weakSelf onBack:nil];
                 });
             } else {
                 [strongSelf.progressHUD dismiss];
                 [strongSelf showGenericNetworkErrorAlertControllerWithMessage:NSLocalizedString(kLocalizationAlertDialogGenericNetworkErrorText, @"Generic network error")];
             }
         }];
    }
}


#pragma mark -
#pragma mark Content handling

- (void)handleProcessDefinitionResponseForProcessDefinitions:(NSArray *)processDefinitions
                                                      paging:(ASDKModelPaging *)paging
                                                       error:(NSError *)error {
    if (!error) {
        self.processDefinitionsArr = processDefinitions;
        
        // Reload table data
        [self.processTableView reloadData];
        
        // Display the last update date
        if (self.refreshControl) {
            self.refreshControl.attributedTitle = [[NSDate date] lastUpdatedFormattedString];
        }
    } else {
        if (error.code == NSURLErrorNotConnectedToInternet) {
            [self showWarningMessage:NSLocalizedString(kLocalizationOfflineProvidingCachedResultsText, @"Cached results text")];
        } else {
            [self showErrorMessage:NSLocalizedString(kLocalizationAlertDialogTaskContentFetchErrorText, @"Content fetching error")];
        }
    }
    
    [self endRefreshOnRefreshControl];
    
    BOOL isContentAvailable = self.processDefinitionsArr.count ? YES : NO;
    self.controllerState = isContentAvailable ? AFAStartProcessInstanceLoadingStateIdle : AFAStartProcessInstanceLoadingStateEmptyList;
}


#pragma mark -
#pragma mark AFAProcessStartFormViewControllerDelegate

- (void)didCompleteFormWithProcessInstance:(ASDKModelProcessInstance *)processInstance {
    self.formViewContainer.hidden = YES;
    [self performSegueWithIdentifier:kSegueIDProcessInstanceStartForm
                              sender:processInstance];
}


#pragma mark -
#pragma mark Progress hud setup

- (JGProgressHUD *)configureProgressHUD {
    JGProgressHUD *hud = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
    hud.interactionType = JGProgressHUDInteractionTypeBlockAllTouches;
    JGProgressHUDFadeZoomAnimation *zoomAnimation = [JGProgressHUDFadeZoomAnimation animation];
    hud.animation = zoomAnimation;
    hud.textLabel.text = [NSString stringWithFormat:NSLocalizedString(kLocalizationProcessInstanceStartInProgressText, @"Starting process text")];
    
    return hud;
}

- (void)showStarProcessProgressHUD {
    [self.progressHUD showInView:self.navigationController.view];
}


#pragma mark -
#pragma mark Tableview Delegate & Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    return self.processDefinitionsArr.count;
}

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AFAProcessDefinitionListStyleTableViewCell *processDefinitionCell = [tableView dequeueReusableCellWithIdentifier:kCellIDProcessDefinitionListStyle];
    [processDefinitionCell setupWithProcessDefinition:self.processDefinitionsArr[indexPath.row]];
    processDefinitionCell.applicationThemeColor = self.navigationBarThemeColor;
    
    return processDefinitionCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.isNetworkReachable) {
        [self startProcessInstanceForProcessDefinition:self.processDefinitionsArr[indexPath.row]];
    } else {
        [self showWarningMessage:NSLocalizedString(kLocalizationOfflineFunctionalityNotAvailableText, @"Functionality not available offline text")];
    }
    
    [tableView deselectRowAtIndexPath:indexPath
                             animated:NO];
}


#pragma mark -
#pragma mark Convenience methods

- (void)setupLocalization {
    self.navigationBarTitle = NSLocalizedString(kLocalizationProcessInstanceStartNewInstanceTitleText, @"Start process screen title");
    self.noRecordsLabel.text = NSLocalizedString(kLocalizationStartProcessInstanceScreenNoResultsText, @"No records available text");
}

- (void)endRefreshOnRefreshControl {
    __weak typeof(self) weakSelf = self;
    [[NSOperationQueue currentQueue] addOperationWithBlock:^{
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf.refreshControl endRefreshing];
    }];
}


#pragma mark -
#pragma mark KVO bindings

- (void)handleBindingsForStartProcessInstanceViewController {
    self.kvoManager = [ASDKKVOManager managerWithObserver:self];
    
    __weak typeof(self) weakSelf = self;
    [self.kvoManager observeObject:self
                        forKeyPath:NSStringFromSelector(@selector(controllerState))
                           options:NSKeyValueObservingOptionNew
                             block:^(id observer, id object, NSDictionary *change) {
                                 AFAStartProcessInstanceLoadingState controllerState = [change[NSKeyValueChangeNewKey] integerValue];
                                 
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     if (AFAStartProcessInstanceLoadingStateIdle == controllerState) {
                                         weakSelf.loadingActivityView.hidden = YES;
                                         weakSelf.loadingActivityView.animating = NO;
                                         weakSelf.processTableView.hidden = NO;
                                         weakSelf.noRecordsLabel.hidden = YES;
                                     } else if (AFAStartProcessInstanceLoadingStateInProgress == controllerState) {
                                         weakSelf.loadingActivityView.hidden = NO;
                                         weakSelf.loadingActivityView.animating = YES;
                                         weakSelf.processTableView.hidden = YES;
                                         weakSelf.noRecordsLabel.hidden = YES;
                                     } else if (AFAStartProcessInstanceLoadingStateEmptyList == controllerState) {
                                         weakSelf.loadingActivityView.hidden = YES;
                                         weakSelf.loadingActivityView.animating = NO;
                                         weakSelf.processTableView.hidden = YES;
                                         weakSelf.noRecordsLabel.hidden = NO;
                                     }
                                 });
                             }];
}

@end

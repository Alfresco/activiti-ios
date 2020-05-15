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

#import "AFAProcessInstanceDetailsViewController.h"

// Constants
#import "AFAUIConstants.h"
#import "AFALocalizationConstants.h"
#import "AFABusinessConstants.h"

// Categories
#import "NSDate+AFAStringTransformation.h"
#import "UIViewController+AFAAlertAddition.h"

// Data source
#import "AFAProcessInstanceDetailsDataSource.h"
#import "AFATaskDetailsDataSource.h"

// Models
#import "AFATableControllerProcessInstanceDetailsModel.h"
#import "AFATableControllerProcessInstanceTasksModel.h"
#import "AFAGenericFilterModel.h"
#import "AFATableControllerProcessInstanceContentModel.h"
#import "AFATableControllerCommentModel.h"

// Managers
#import "AFATableController.h"
@import ActivitiSDK;

// Cell factories
#import "AFATableControllerProcessInstanceDetailsCellFactory.h"
#import "AFATableControllerProcessInstanceTasksCellFactory.h"
#import "AFATableControllerContentCellFactory.h"
#import "AFATableControllerCommentCellFactory.h"

// Controllers
#import "AFATaskDetailsViewController.h"
#import "AFAContentPickerViewController.h"
#import "AFAAddCommentsViewController.h"
#import "AFAProcessStartFormViewController.h"
#import "AFAListViewController.h"

// Views
#import "AFAActivityView.h"
#import "AFANoContentView.h"

typedef NS_ENUM(NSUInteger, AFAProcessInstanceDetailsLoadingState) {
    AFAProcessInstanceDetailsLoadingStateIdle = 0,
    AFAProcessInstanceDetailsLoadingStateInProgress,
    AFAProcessInstanceDetailsLoadingStateEmptyList
};


@interface AFAProcessInstanceDetailsViewController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem                        *backBarButtonItem;
@property (weak, nonatomic) IBOutlet UITableView                            *processTableView;
@property (weak, nonatomic) IBOutlet AFAActivityView                        *loadingActivityView;
@property (strong, nonatomic) UIRefreshControl                              *refreshControl;
@property (weak, nonatomic) IBOutlet UIButton                               *processInstanceDetailsButton;
@property (weak, nonatomic) IBOutlet UIButton                               *processInstanceActiveTasksButton;
@property (weak, nonatomic) IBOutlet UIButton                               *processInstanceContentButton;
@property (weak, nonatomic) IBOutlet UIButton                               *processInstanceCommentsButton;
@property (weak, nonatomic) IBOutlet AFANoContentView                       *noContentView;
@property (strong, nonatomic) AFAContentPickerViewController                *contentPickerViewController;
@property (strong, nonatomic) IBOutlet UIBarButtonItem                      *addBarButtonItem;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint                     *tabBarHeightConstraint;

// Internal state properties
@property (assign, nonatomic) AFAProcessInstanceDetailsLoadingState         controllerState;
@property (assign, nonatomic) NSInteger                                     currentSelectedSection;
@property (assign, nonatomic) NSUInteger                                    initialTabBarHeight;

// KVO
@property (strong, nonatomic) ASDKKVOManager                                 *kvoManager;

@end

@implementation AFAProcessInstanceDetailsViewController


#pragma mark -
#pragma mark Life cycle

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        self.controllerState = AFAProcessInstanceDetailsLoadingStateIdle;
        
        // Set up state bindings
        [self handleBindingsForProcessInstanceDetailsViewController];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Bind table view's delegates to table controller
    self.dataSource.isConnectivityAvailable = [self isNetworkReachable];
    self.processTableView.dataSource = self.dataSource.tableController;
    self.processTableView.delegate = self.dataSource.tableController;
    self.navigationBarThemeColor = self.dataSource.themeColor;
    
    // Set up the details table view to adjust it's size automatically
    self.processTableView.estimatedRowHeight = 60.0f;
    self.processTableView.rowHeight = UITableViewAutomaticDimension;
    
    // Update UI for current localization
    [self setupLocalization];
    
    // Set up section buttons
    self.processInstanceDetailsButton.tag = AFAProcessInstanceDetailsSectionTypeDetails;
    self.processInstanceActiveTasksButton.tag = AFAProcessInstanceDetailsSectionTypeTaskStatus;
    self.processInstanceContentButton.tag = AFAProcessInstanceDetailsSectionTypeContent;
    self.processInstanceCommentsButton.tag = AFAProcessInstanceDetailsSectionTypeComments;
    self.processInstanceDetailsButton.tintColor = [self.navigationBarThemeColor colorWithAlphaComponent:.7f];
    
    // Set up the refresh control
    UITableViewController *tableViewController = [[UITableViewController alloc] init];
    [self addChildViewController:tableViewController];
    tableViewController.tableView = self.processTableView;
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self
                            action:@selector(refreshContentForCurrentSection)
                  forControlEvents:UIControlEventValueChanged];
    tableViewController.refreshControl = self.refreshControl;
    
    self.initialTabBarHeight = self.tabBarHeightConstraint.constant;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    BOOL isConnectivityAvailable = [self isNetworkReachable];
    [self refreshUIForConnectivity:isConnectivityAvailable];
    
    [self refreshContentForCurrentSection];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    if (@available(iOS 11.0, *)) {
        self.tabBarHeightConstraint.constant = self.initialTabBarHeight + self.view.safeAreaInsets.bottom;
    }
}


#pragma mark -
#pragma mark Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue
                 sender:(id)sender {
    if ([kSegueIDProcessInstanceTaskDetails isEqualToString:segue.identifier]) {
        AFATaskDetailsViewController *taskDetailsController = (AFATaskDetailsViewController *)segue.destinationViewController;
        ASDKModelTask *task = (ASDKModelTask *)sender;
        AFATaskDetailsDataSource *taskDetailsDataSource = [[AFATaskDetailsDataSource alloc] initWithTaskID:[task modelID]
                                                                                              parentTaskID:task.parentTaskID
                                                                                                themeColor:self.navigationBarThemeColor];
        taskDetailsController.dataSource = taskDetailsDataSource;
        taskDetailsController.unwindActionType = AFATaskDetailsUnwindActionTypeProcessInstanceDetails;
    } else if ([kSegueIDContentPickerComponentEmbedding isEqualToString:segue.identifier]) {
        self.contentPickerViewController = (AFAContentPickerViewController *)segue.destinationViewController;
    } else if ([kSegueIDProcessInstanceDetailsAddComments isEqualToString:segue.identifier]) {
        AFAAddCommentsViewController *addComentsController = (AFAAddCommentsViewController *)segue.destinationViewController;
        addComentsController.processInstanceID = self.dataSource.processInstanceID;
    } else if ([kSegueIDProcessInstanceViewCompletedStartForm isEqualToString:segue.identifier]) {
        AFATableControllerProcessInstanceDetailsModel *processInstanceDetailsModel = [self.dataSource reusableTableControllerModelForSectionType:AFAProcessInstanceDetailsSectionTypeDetails];
        AFAProcessStartFormViewController *startFormViewController = (AFAProcessStartFormViewController *)segue.destinationViewController;
        [startFormViewController setupStartFormForProcessInstanceObject:processInstanceDetailsModel.currentProcessInstance];
    }
}

- (IBAction)unwindFromTaskDetailsController:(UIStoryboardSegue *)segue {
}

- (IBAction)unwindAddProcessInstanceCommentsController:(UIStoryboardSegue *)segue {
}

- (IBAction)unwindProcessInstanceViewStartForm:(UIStoryboardSegue *)segue {
}


#pragma mark -
#pragma mark Connectivity notifications

- (void)didRestoredNetworkConnectivity {
    [super didRestoredNetworkConnectivity];
    
    self.dataSource.isConnectivityAvailable = YES;
    [self refreshUIForConnectivity:self.dataSource.isConnectivityAvailable];
    
    self.controllerState = AFAProcessInstanceDetailsLoadingStateInProgress;
    [self refreshContentForCurrentSection];
}

- (void)didLoseNetworkConnectivity {
    [super didLoseNetworkConnectivity];
    
    self.dataSource.isConnectivityAvailable = NO;
    [self refreshUIForConnectivity:self.dataSource.isConnectivityAvailable];
    
    [self refreshContentForCurrentSection];
}

- (void)refreshUIForConnectivity:(BOOL)isConnected {
    self.addBarButtonItem.enabled = isConnected;
}


#pragma mark -
#pragma mark Actions

- (IBAction)onBack:(id)sender {
    switch (self.unwindActionType) {
        case AFAProcessInstanceDetailsUnwindActionTypeProcessList: {
            [self performSegueWithIdentifier:kSegueIDProcessInstanceDetailsUnwind
                                      sender:sender];
        }
            break;
            
        case AFAProcessInstanceDetailsUnwindActionTypeStartForm: {
            [self performSegueWithIdentifier:kSegueIDProcessInstanceStartFormUnwind
                                      sender:sender];
        }
            break;
            
        case AFAProcessInstanceDetailsUnwindActionTypeTaskDetails: {
            [self performSegueWithIdentifier:kSegueIDTaskDetailsViewProcessUnwind
                                      sender:sender];
        }
            break;
            
        default:
            break;
    }
}

- (IBAction)onSectionSwitch:(UIButton *)sender {
    UIButton *sectionButton = (UIButton *)sender;
    
    // Check whether the user is tapping the same section
    if (self.currentSelectedSection != sectionButton.tag) {
        // Un-select the former selected button
        UIButton *lastSelectedSectionButton = [self buttonForSection:self.currentSelectedSection];
        lastSelectedSectionButton.tintColor = [UIColor blackColor];
        
        // Highlight the current selection
        self.currentSelectedSection = sectionButton.tag;
        UIButton *currentSectionButton = [self buttonForSection:self.currentSelectedSection];
        currentSectionButton.tintColor = [self.navigationBarThemeColor colorWithAlphaComponent:.7f];
        
        // Update the controller state and refresh the appropiate section
        self.controllerState = AFAProcessInstanceDetailsLoadingStateInProgress;
        
        [self refreshContentForCurrentSection];
        [self.processTableView reloadData];
    }
}

- (void)refreshContentForCurrentSection {
    [self.dataSource updateTableControllerForSectionType:self.currentSelectedSection];
    
    self.navigationItem.rightBarButtonItem = nil;
    
    switch (self.currentSelectedSection) {
        case AFAProcessInstanceDetailsSectionTypeDetails: {
            self.navigationBarTitle = NSLocalizedString(kLocalizationProcessInstanceDetailsScreenTitleText, @"Process instance details screen title");
            [self refreshProcessInstanceDetails];
        }
            break;
            
        case AFAProcessInstanceDetailsSectionTypeTaskStatus: {
            self.navigationBarTitle = NSLocalizedString(kLocalizationProcessInstanceDetailsScreenActiveAndCompletedText, @"Active and completed tasks screen title");
            [self refreshProcessInstanceActiveAndCompletedTasks];
        }
            break;
            
        case AFAProcessInstanceDetailsSectionTypeContent: {
            self.navigationBarTitle = NSLocalizedString(kLocalizationTaskDetailsScreenContentTitleText, @"Attached content screen title");
            [self refreshProcessInstanceContent];
        }
            break;
            
        case AFAProcessInstanceDetailsSectionTypeComments: {
            self.navigationBarTitle = NSLocalizedString(kLocalizationTaskDetailsScreenCommentsTitleText, @"Comments screen title");
            [self refreshProcessInstanceComments];
            
            self.navigationItem.rightBarButtonItem = self.addBarButtonItem;
        }
            break;
            
        default:
            break;
    }
    
}

- (void)refreshProcessInstanceDetails {
    __weak typeof(self) weakSelf = self;
    [self.dataSource processInstanceDetailsWithCompletionBlock:^(NSError *error, BOOL registerCellActions) {
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf handleProcessInstanceDetailsResponseWithErrorStatus:error
                                                    registerCellActions:registerCellActions];
    } cachedResultsBlock:^(NSError *error, BOOL registerCellActions) {
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf handleProcessInstanceDetailsResponseWithErrorStatus:error
                                                    registerCellActions:registerCellActions];
    }];
}

- (void)refreshProcessInstanceActiveAndCompletedTasks {
    __weak typeof(self) weakSelf = self;
    [self.dataSource processInstanceActiveAndCompletedTasksWithCompletionBlock:^(NSError *error) {
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf handleProcessInstanceActiveAndCompletedTasksResponseWithErrorStatus:error];
    } cachedResultsBlock:^(NSError *error) {
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf handleProcessInstanceActiveAndCompletedTasksResponseWithErrorStatus:error];
    }];
}

- (void)refreshProcessInstanceContent {
    self.controllerState = AFAProcessInstanceDetailsLoadingStateInProgress;
    
    __weak typeof(self) weakSelf = self;
    [self.dataSource processInstanceContentWithCompletionBlock:^(NSError *error) {
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf handleProcessInstanceContentListResponseWithErrorStatus:error];
    } cachedResultsBlock:^(NSError *error) {
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf handleProcessInstanceContentListResponseWithErrorStatus:error];
    }];
}

- (void)refreshProcessInstanceComments {
    self.controllerState = AFAProcessInstanceDetailsLoadingStateInProgress;
    
    __weak typeof(self) weakSelf = self;
    [self.dataSource processInstanceCommentsWithCompletionBlock:^(NSError *error) {
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf handleProcessInstanceCommentListResponseWithErrorStatus:error];
    } cachedResultsBlock:^(NSError *error) {
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf handleProcessInstanceCommentListResponseWithErrorStatus:error];
    }];
}

- (IBAction)onAdd:(UIBarButtonItem *)sender {
    if (AFAProcessInstanceDetailsSectionTypeComments == self.currentSelectedSection) {
        [self performSegueWithIdentifier:kSegueIDProcessInstanceDetailsAddComments
                                  sender:sender];
    }
}

- (void)deleteCurrentProcessInstance {
    self.controllerState = AFAProcessInstanceDetailsLoadingStateInProgress;
    
    __weak typeof(self) weakSelf = self;
    [self.dataSource deleteCurrentProcessInstanceWithCompletionBlock:^(NSError *error) {
        __strong typeof(self) strongSelf = weakSelf;
        
        if (!error) {
            [self performSegueWithIdentifier:kSegueIDProcessInstanceDetailsUnwind
                                      sender:nil];
        } else {
            [strongSelf showGenericNetworkErrorAlertControllerWithMessage:NSLocalizedString(kLocalizationAlertDialogTaskContentFetchErrorText, @"Content fetching error")];
        }
        
        strongSelf.controllerState  = AFAProcessInstanceDetailsLoadingStateIdle;
    }];
}


#pragma mark -
#pragma mark Cell actions

- (void)registerCellActions {
    AFATableControllerProcessInstanceDetailsCellFactory *processInstanceDetailsCellFactory = [self.dataSource cellFactoryForSectionType:AFAProcessInstanceDetailsSectionTypeDetails];
    AFATableControllerProcessInstanceTasksCellFactory *processInstanceTasksCellFactory = [self.dataSource cellFactoryForSectionType:AFAProcessInstanceDetailsSectionTypeTaskStatus];
    AFATableControllerContentCellFactory *processInstanceContentCellFactory = [self.dataSource cellFactoryForSectionType:AFAProcessInstanceDetailsSectionTypeContent];
    
    __weak typeof(self) weakSelf = self;
    [processInstanceDetailsCellFactory registerCellAction:^(NSDictionary *changeParameters) {
        __strong typeof(self) strongSelf = weakSelf;
        
        AFATableControllerProcessInstanceDetailsModel *processInstanceDetailsModel = [strongSelf.dataSource reusableTableControllerModelForSectionType:AFAProcessInstanceDetailsSectionTypeDetails];
        
        NSString *alertMessage = nil;
        NSString *processInstanceName = processInstanceDetailsModel.currentProcessInstance.name;
        if ([processInstanceDetailsModel isCompletedProcessInstance]) {
            alertMessage = [NSString stringWithFormat:NSLocalizedString(kLocalizationProcessInstanceDetailsScreenDeleteProcessConfirmationFormat, @"Delete process instance text"), processInstanceName ? processInstanceName : @""];
        } else {
            alertMessage = [NSString stringWithFormat:NSLocalizedString(kLocalizationProcessInstanceDetailsScreenCancelProcessConfirmationFormat, @"Cancel process instance text"), processInstanceName ? processInstanceName : @""];
        }
        
        [strongSelf showConfirmationAlertControllerWithMessage:alertMessage
                                       confirmationBlockAction:^{
                                           [weakSelf deleteCurrentProcessInstance];
                                       }];
    } forCellType:[processInstanceDetailsCellFactory cellTypeForProcessControlCell]];
    
    [processInstanceTasksCellFactory registerCellAction:^(NSDictionary *changeParameters) {
        __strong typeof(self) strongSelf = weakSelf;
        
        NSIndexPath *taskIndexpath = changeParameters[kCellFactoryCellParameterCellIndexpath];
        AFATableControllerProcessInstanceTasksModel *processInstanceTasks = [strongSelf.dataSource reusableTableControllerModelForSectionType:AFAProcessInstanceDetailsSectionTypeTaskStatus];
        ASDKModelTask *currentTask = [processInstanceTasks itemAtIndexPath:taskIndexpath];
        
        if (currentTask) {
            [strongSelf performSegueWithIdentifier:kSegueIDProcessInstanceTaskDetails
                                            sender:currentTask];
        } else if (processInstanceTasks.isStartFormDefined) {
            [strongSelf performSegueWithIdentifier:kSegueIDProcessInstanceViewCompletedStartForm
                                            sender:nil];
        }
    } forCellType:[processInstanceTasksCellFactory cellTypeForTaskDetails]];
    
    [processInstanceContentCellFactory registerCellAction:^(NSDictionary *changeParameters) {
        // It is possible that at the time of the download request the content's availability status
        // is changed. We perform an additional refresh once content is requested to be downloaded
        // so it's status has the latest value
        __strong typeof(self) strongSelf = weakSelf;
        
        strongSelf.controllerState = AFAProcessInstanceDetailsLoadingStateInProgress;
        
        [self.dataSource processInstanceContentWithCompletionBlock:^(NSError *error) {
            NSIndexPath *contentToDownloadIndexPath = changeParameters[kCellFactoryCellParameterCellIndexpath];
            AFATableControllerProcessInstanceContentModel *processInstanceContentModel = [weakSelf.dataSource reusableTableControllerModelForSectionType:AFAProcessInstanceDetailsSectionTypeContent];
            ASDKModelContent *contentToDownload = ((ASDKModelProcessInstanceContent *)processInstanceContentModel.attachedContentArr[contentToDownloadIndexPath.section]).contentArr[contentToDownloadIndexPath.row];
            
            [weakSelf.contentPickerViewController dowloadContent:contentToDownload
                                              allowCachedContent:YES];
            strongSelf.controllerState = AFAProcessInstanceDetailsLoadingStateIdle;
        } cachedResultsBlock:^(NSError *error) {
            
        }];
    } forCellType:[processInstanceContentCellFactory cellTypeForDownloadContent]];
    
    // Certain actions are performed for completed or ongoing process instances so there is
    // no reason to register all of them at all times
    AFATableControllerProcessInstanceDetailsModel *processInstanceDetailsModel = [self.dataSource reusableTableControllerModelForSectionType:AFAProcessInstanceDetailsSectionTypeDetails];
    
    if ([processInstanceDetailsModel isCompletedProcessInstance]) {
        [processInstanceDetailsCellFactory registerCellAction:^(NSDictionary *changeParameters) {
            __strong typeof(self) strongSelf = weakSelf;
            
            [strongSelf.contentPickerViewController downloadAuditLogForProcessInstanceWithID:strongSelf.dataSource.processInstanceID
                                                                          allowCachedResults:YES];
        } forCellType:[processInstanceDetailsCellFactory cellTypeForAuditLogCell]];
    }
}


#pragma mark -
#pragma mark Content handling

- (void)handleProcessInstanceDetailsResponseWithErrorStatus:(NSError *)error
                                        registerCellActions:(BOOL)registerCellActions {
    AFATableControllerProcessInstanceDetailsModel *processInstanceDetailsModel = [self.dataSource reusableTableControllerModelForSectionType:AFAProcessInstanceDetailsSectionTypeDetails];
    
    if (registerCellActions) {
        [self registerCellActions];
    }
    
    if (!error) {
        [self.processTableView reloadData];
        
        // Display the last update date
        if (self.refreshControl) {
            self.refreshControl.attributedTitle = [[NSDate date] lastUpdatedFormattedString];
        }
    } else {
        if (error.code == NSURLErrorNotConnectedToInternet) {
            [self showWarningMessage:NSLocalizedString(kLocalizationOfflineProvidingCachedResultsText, @"Cached results text")];
        } else {
            [self showErrorMessage:NSLocalizedString(kLocalizationAlertDialogGenericNetworkErrorText, @"Generic network error")];
        }
    }
    
    [self endRefreshOnRefreshControl];
    
    BOOL isContentAvailable = processInstanceDetailsModel.currentProcessInstance ? YES : NO;
    self.controllerState = isContentAvailable ? AFAProcessInstanceDetailsLoadingStateIdle : AFAProcessInstanceDetailsLoadingStateEmptyList;
}

- (void)handleProcessInstanceActiveAndCompletedTasksResponseWithErrorStatus:(NSError *)error {
    AFATableControllerProcessInstanceTasksModel *processInstanceTaskModel = [self.dataSource reusableTableControllerModelForSectionType:AFAProcessInstanceDetailsSectionTypeTaskStatus];
    
    if (!error) {
        [self.processTableView reloadData];
        
        // Display the last update date
        if (self.refreshControl) {
            self.refreshControl.attributedTitle = [[NSDate date] lastUpdatedFormattedString];
        }
    } else {
        if (error.code == NSURLErrorNotConnectedToInternet) {
            [self showWarningMessage:NSLocalizedString(kLocalizationOfflineProvidingCachedResultsText, @"Cached results text")];
        } else {
            [self showErrorMessage:NSLocalizedString(kLocalizationAlertDialogGenericNetworkErrorText, @"Generic network error")];
        }
    }
    
    self.noContentView.iconImageView.image = [UIImage imageNamed:@"tasks-large-icon"];
    self.noContentView.descriptionLabel.text = NSLocalizedString(kLocalizationProcessInstanceDetailsScreenNoTasksAvailableText, @"No tasks available text");

    [self endRefreshOnRefreshControl];
    
    BOOL isContentAvailable = ([processInstanceTaskModel hasTaskListAvailable] || processInstanceTaskModel.isStartFormDefined) ? YES : NO;
    self.controllerState = isContentAvailable ? AFAProcessInstanceDetailsLoadingStateIdle : AFAProcessInstanceDetailsLoadingStateEmptyList;
}

- (void)handleProcessInstanceContentListResponseWithErrorStatus:(NSError *)error {
    AFATableControllerProcessInstanceContentModel *processInstanceContentModel = [self.dataSource reusableTableControllerModelForSectionType:AFAProcessInstanceDetailsSectionTypeContent];
    
    if (!error) {
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
    
    self.noContentView.iconImageView.image = [UIImage imageNamed:@"documents-large-icon"];
    self.noContentView.descriptionLabel.text = NSLocalizedString(kLocalizationNoContentScreenFilesNotEditableText, @"No files available not editable");
    
    [self endRefreshOnRefreshControl];
    
    BOOL isContentAvailable = processInstanceContentModel.attachedContentArr.count ? YES : NO;
    self.controllerState = isContentAvailable ? AFAProcessInstanceDetailsLoadingStateIdle : AFAProcessInstanceDetailsLoadingStateEmptyList;
}

- (void)handleProcessInstanceCommentListResponseWithErrorStatus:(NSError *)error {
    AFATableControllerProcessInstanceDetailsModel *processInstanceDetailsModel = [self.dataSource reusableTableControllerModelForSectionType:AFAProcessInstanceDetailsSectionTypeDetails];
    AFATableControllerCommentModel *processInstanceCommentModel = [self.dataSource reusableTableControllerModelForSectionType:
                                                                   AFAProcessInstanceDetailsSectionTypeComments];
    
    if (!error) {
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
    
    self.noContentView.iconImageView.image = [UIImage imageNamed:@"comments-large-icon"];
    self.noContentView.descriptionLabel.text = [processInstanceDetailsModel isCompletedProcessInstance] ? NSLocalizedString(kLocalizationNoContentScreenCommentsNotEditableText, @"No comments available not editable text") : NSLocalizedString(kLocalizationNoContentScreenCommentsText, @"No comments available text") ;
    
    [self endRefreshOnRefreshControl];
    
    BOOL isContentAvailable = processInstanceCommentModel.commentListArr.count ? YES : NO;
    self.controllerState = isContentAvailable ? AFAProcessInstanceDetailsLoadingStateIdle : AFAProcessInstanceDetailsLoadingStateEmptyList;
}


#pragma mark -
#pragma mark Convenience methods

- (void)setupLocalization {
    self.navigationBarTitle = NSLocalizedString(kLocalizationProcessInstanceDetailsScreenTitleText, @"Process instance details title");
    [self.backBarButtonItem setTitleTextAttributes:@{NSFontAttributeName           : [UIFont glyphiconFontWithSize:15],
                                                     NSForegroundColorAttributeName: [UIColor whiteColor]}
                                          forState:UIControlStateNormal];
    self.backBarButtonItem.title = [NSString iconStringForIconType:ASDKGlyphIconTypeChevronLeft];
}


- (UIButton *)buttonForSection:(AFAProcessInstanceDetailsSectionType)sectionType {
    switch (sectionType) {
        case AFAProcessInstanceDetailsSectionTypeDetails: {
            return self.processInstanceDetailsButton;
        }
            break;
            
        case AFAProcessInstanceDetailsSectionTypeTaskStatus: {
            return self.processInstanceActiveTasksButton;
        }
            break;
            
        case AFAProcessInstanceDetailsSectionTypeContent: {
            return self.processInstanceContentButton;
        }
            break;
            
        case AFAProcessInstanceDetailsSectionTypeComments: {
            return self.processInstanceCommentsButton;
        }
            break;
            
        default: return nil;
            break;
    }
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

- (void)handleBindingsForProcessInstanceDetailsViewController {
    self.kvoManager = [ASDKKVOManager managerWithObserver:self];
    
    __weak typeof(self) weakSelf = self;
    [self.kvoManager observeObject:self
                        forKeyPath:NSStringFromSelector(@selector(controllerState))
                           options:NSKeyValueObservingOptionNew
                             block:^(id observer, id object, NSDictionary *change) {
                                 AFAProcessInstanceDetailsLoadingState controllerState = [change[NSKeyValueChangeNewKey] integerValue];
                                 
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     if (AFAProcessInstanceDetailsLoadingStateIdle == controllerState) {
                                         weakSelf.loadingActivityView.hidden = YES;
                                         weakSelf.loadingActivityView.animating = NO;
                                         weakSelf.processTableView.hidden = NO;
                                         weakSelf.noContentView.hidden = YES;
                                     } else if (AFAProcessInstanceDetailsLoadingStateInProgress == controllerState) {
                                         weakSelf.loadingActivityView.hidden = NO;
                                         weakSelf.loadingActivityView.animating = YES;
                                         weakSelf.processTableView.hidden = YES;
                                         weakSelf.noContentView.hidden = YES;
                                     } else if (AFAProcessInstanceDetailsLoadingStateEmptyList == controllerState) {
                                         weakSelf.loadingActivityView.hidden = YES;
                                         weakSelf.loadingActivityView.animating = NO;
                                         weakSelf.processTableView.hidden = YES;
                                         weakSelf.noContentView.hidden = NO;
                                     }
                                 });
                             }];
}


@end

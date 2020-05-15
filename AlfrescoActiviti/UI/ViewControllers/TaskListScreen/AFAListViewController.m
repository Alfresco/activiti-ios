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

// Controllers
#import "AFAListViewController.h"
#import "AFAFilterViewController.h"
#import "AFATaskDetailsViewController.h"
#import "AFAStartProcessInstanceViewController.h"
#import "AFAProcessInstanceDetailsViewController.h"
#import "AFAModalTaskDetailsViewController.h"

// Constants
#import "AFAUIConstants.h"
#import "AFABusinessConstants.h"
#import "AFALocalizationConstants.h"

// Categories
#import "UIColor+AFATheme.h"
#import "NSDate+AFAStringTransformation.h"
#import "UIView+AFAViewAnimations.h"
#import "UIViewController+AFAAlertAddition.h"
#import "UIView+AFAImageEffects.h"

// Models
#import "AFAGenericFilterModel.h"
#import "ASDKModelTask.h"
#import "AFAListResponseModel.h"

// View models
#import "AFATaskListViewModel.h"
#import "AFAProcessListViewModel.h"

// Data sources
#import "AFATaskListViewDataSource.h"
#import "AFAProcessListViewDataSource.h"
#import "AFAProcessInstanceDetailsDataSource.h"
#import "AFATaskDetailsDataSource.h"

// Managers
#import "AFAProcessServices.h"
#import "AFAServiceRepository.h"
#import "AFAModalTaskDetailsCreateTaskAction.h"
@import ActivitiSDK;

// Views
#import "ASDKRoundedBorderView.h"
#import "AFAActivityView.h"

typedef NS_ENUM(NSInteger, AFAListControllerState) {
    AFAListControllerStateIdle = 0,
    AFAListControllerStateRefreshInProgress,
    AFAListControllerStateEmptyList
};

typedef NS_ENUM(NSInteger, AFAListButtonType) {
    AFAListButtonTypeUndefined          = -1,
    AFAListButtonTypeTasks              = 0,
    AFAListButtonTypeProcessInstances
};


@interface AFAListViewController () <AFAFilterViewControllerDelegate,
AFAModalTaskDetailsViewControllerDelegate,
UITextFieldDelegate,
UITableViewDelegate>

// Task list related
@property (weak, nonatomic)   IBOutlet UITableView                          *listTableView;
@property (weak, nonatomic)   IBOutlet UILabel                              *noRecordsLabel;
@property (weak, nonatomic)   IBOutlet UIView                               *refreshView;
@property (weak, nonatomic)   IBOutlet ASDKRoundedBorderView                *searchView;
@property (strong, nonatomic) UIRefreshControl                              *refreshControl;
@property (strong, nonatomic) IBOutlet UIView                               *loadingFooterView;
@property (weak, nonatomic)   IBOutlet AFAActivityView                      *preloadingActivityView;
@property (weak, nonatomic)   IBOutlet AFAActivityView                      *loadingActivityView;
@property (weak, nonatomic)   IBOutlet UITextField                          *searchTextField;
@property (weak, nonatomic)   IBOutlet UIBarButtonItem                      *backBarButtonItem;
@property (weak, nonatomic)   IBOutlet UIBarButtonItem                      *addBarButtonItem;
@property (weak, nonatomic)   IBOutlet UIButton                             *taskListButton;
@property (weak, nonatomic)   IBOutlet UIButton                             *processListButton;
@property (weak, nonatomic)   IBOutlet UIView                               *underlineView;
@property (weak, nonatomic)   IBOutlet NSLayoutConstraint                   *underlineTaskListButtonConstraint;
@property (weak, nonatomic)   IBOutlet NSLayoutConstraint                   *tabBarHeightConstraint;
@property (weak, nonatomic)   IBOutlet NSLayoutConstraint                   *tabBarUnderlineBottomConstraint;


// Advanced search related
@property (weak, nonatomic)   IBOutlet UIButton                             *advancedSearchButton;
@property (weak, nonatomic)   IBOutlet UIButton                             *refreshButton;
@property (weak, nonatomic)   IBOutlet UIView                               *advancedSearchOverlayView;
@property (weak, nonatomic)   IBOutlet UIView                               *advancedFilterContainerView;
@property (weak, nonatomic)   IBOutlet NSLayoutConstraint                   *advancedSearchContainerTopConstraint;
@property (strong, nonatomic) AFAFilterViewController                       *filterViewController;
@property (weak, nonatomic)   IBOutlet ASDKRoundedBorderView                *advancedSearchRoundedBorderView;
@property (weak, nonatomic)   IBOutlet NSLayoutConstraint                   *advancedSearchContainerHeightConstraint;

// Internal state properties
@property (strong, nonatomic) AFAGenericFilterModel                         *currentFilter;
@property (assign, nonatomic) AFAListControllerState                        controllerState;
@property (assign, nonatomic) BOOL                                          isAdvancedSearchInProgress;
@property (strong, nonatomic) id<AFAListDataSourceProtocol>                 dataSource;
@property (strong, nonatomic) AFAListBaseViewModel                          *currentListViewModel;
@property (assign, nonatomic) NSUInteger                                    initialTabBarHeight;

// KVO
@property (strong, nonatomic) ASDKKVOManager                                *kvoManager;

@end

@implementation AFAListViewController


#pragma mark -
#pragma mark Life cycle

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        _controllerState = AFAListControllerStateIdle;
        
        // Set up state bindings
        [self handleBindingsForTaskListViewController];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Prepare the layout for the set content type
    self.navigationBarTitle = [self.currentListViewModel navigationBarTitle];
    self.navigationBarThemeColor = [self.currentListViewModel navigationBarThemeColor];
    
    // Register the application color with the SDK color scheme
    ASDKBootstrap *sdkBootStrap = [ASDKBootstrap sharedInstance];
    ASDKFormColorSchemeManager *colorSchemeManager = [sdkBootStrap.serviceLocator serviceConformingToProtocol:@protocol(ASDKFormColorSchemeManagerProtocol)];
    colorSchemeManager.navigationBarThemeColor = self.navigationBarThemeColor;
    colorSchemeManager.navigationBarTitleAndControlsColor = [UIColor whiteColor];
    
    // Set up the refresh control
    UITableViewController *tableViewController = [[UITableViewController alloc] init];
    [self addChildViewController:tableViewController];
    tableViewController.tableView = self.listTableView;
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self
                            action:@selector(refreshContentList)
                  forControlEvents:UIControlEventValueChanged];
    tableViewController.refreshControl = self.refreshControl;
    
    self.listTableView.estimatedRowHeight = 78.0f;
    self.listTableView.rowHeight = UITableViewAutomaticDimension;
    self.listTableView.tableFooterView = nil;
    
    // Set up list table view delegates and data source
    self.dataSource = [[AFATaskListViewDataSource alloc] initWithDataEntries:nil
                                                                  themeColor:self.navigationBarThemeColor];
    self.listTableView.dataSource = self.dataSource;
    self.listTableView.delegate = self;
    
    self.advancedFilterContainerView.hidden = YES;
    
    [self.backBarButtonItem setTitleTextAttributes:@{NSFontAttributeName           : [UIFont glyphiconFontWithSize:15],
                                                     NSForegroundColorAttributeName: [UIColor whiteColor]}
                                          forState:UIControlStateNormal];
    self.backBarButtonItem.title = [NSString iconStringForIconType:ASDKGlyphIconTypeChevronLeft];
    self.refreshButton.titleLabel.font = [UIFont glyphiconFontWithSize:15];
    [self.refreshButton setTitle:[NSString iconStringForIconType:ASDKGlyphIconTypeRefresh]
                        forState:UIControlStateNormal];
    
    self.taskListButton.tag = AFAListButtonTypeTasks;
    self.processListButton.tag = AFAListButtonTypeProcessInstances;
    
    // Update the controller's state - Waiting for input from the filter controller
    [self updateSceneForCurrentViewModel];
    
    self.initialTabBarHeight = self.tabBarHeightConstraint.constant;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self searchWithTerm:self.searchTextField.text];
    
    [self refreshUIForConnectivity:[self isNetworkReachable]];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    // Adjust tab bar for view's safe area
    if (@available(iOS 11.0, *)) {
        self.tabBarHeightConstraint.constant = self.initialTabBarHeight + self.view.safeAreaInsets.bottom;
        self.tabBarUnderlineBottomConstraint.constant = self.view.safeAreaInsets.bottom;
    }
}


#pragma mark -
#pragma mark Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue
                 sender:(id)sender {
    if ([kSegueIDAdvancedSearchMenuEmbedding isEqualToString:segue.identifier]) {
        self.filterViewController = (AFAFilterViewController *)segue.destinationViewController;
        if (!self.currentListViewModel) {
            self.currentListViewModel = self.taskListViewModel;
        }
        self.filterViewController.currentApp = self.currentListViewModel.application;
        self.filterViewController.delegate = self;
    }
    
    if ([kSegueIDTaskDetails isEqualToString:segue.identifier]) {
        AFATaskDetailsViewController *detailsViewController = (AFATaskDetailsViewController *)segue.destinationViewController;
        
        ASDKModelTask *selectedTask = self.dataSource.dataEntries[[self.listTableView indexPathForCell:(UITableViewCell *)sender].row];
        AFATaskDetailsDataSource *taskDetailsDataSource = [[AFATaskDetailsDataSource alloc] initWithTaskID:selectedTask.modelID
                                                                                              parentTaskID:selectedTask.parentTaskID
                                                                                                themeColor:self.navigationBarThemeColor];
        
        detailsViewController.dataSource = taskDetailsDataSource;
    }
    
    if ([kSegueIDStartProcessInstance isEqualToString:segue.identifier]) {
        AFAStartProcessInstanceViewController *startProcessInstanceViewController = (AFAStartProcessInstanceViewController *)segue.destinationViewController;
        startProcessInstanceViewController.appID = self.currentListViewModel.application.modelID;
        startProcessInstanceViewController.navigationBarThemeColor = self.navigationBarThemeColor;
    }
    
    if ([kSegueIDProcessInstanceDetails isEqualToString:segue.identifier]) {
        AFAProcessInstanceDetailsViewController *processInstanceDetailsController = (AFAProcessInstanceDetailsViewController *)segue.destinationViewController;
        ASDKModelProcessInstance *currentSelectedProcessInstance = self.dataSource.dataEntries[[self.listTableView indexPathForCell:(UITableViewCell *)sender].row];
        AFAProcessInstanceDetailsDataSource *processInstanceDetailsDataSource =
        [[AFAProcessInstanceDetailsDataSource alloc] initWithProcessInstanceID:currentSelectedProcessInstance.modelID
                                                                    themeColor:self.navigationBarThemeColor];
        
        processInstanceDetailsController.dataSource = processInstanceDetailsDataSource;
        processInstanceDetailsController.unwindActionType = AFAProcessInstanceDetailsUnwindActionTypeProcessList;
    }
}

- (IBAction)unwindTaskListController:(UIStoryboardSegue *)segue {
}

- (IBAction)unwindStartProcessInstanceController:(UIStoryboardSegue *)segue {
}

- (IBAction)unwindProcessInstanceDetailsController:(UIStoryboardSegue *)segue {
}

- (IBAction)unwindStartFormProcessInstanceDetailsController:(UIStoryboardSegue *)segue {
}


#pragma mark -
#pragma mark Connectivity notifications

- (void)didRestoredNetworkConnectivity {
    [super didRestoredNetworkConnectivity];
    
    [self searchWithTerm:self.searchTextField.text];
    
    [self refreshUIForConnectivity:YES];
}

- (void)didLoseNetworkConnectivity {
    [super didLoseNetworkConnectivity];
    
    [self searchWithTerm:self.searchTextField.text];
    
    [self refreshUIForConnectivity:NO];
}

- (void)refreshUIForConnectivity:(BOOL)isConnected {
    self.addBarButtonItem.enabled = isConnected;
}


#pragma mark -
#pragma mark Actions

- (IBAction)onRefresh:(id)sender {
    // Perform the refresh operation only when there is a filter available
    if (self.currentFilter) {
        [self searchWithTerm:self.searchTextField.text];
    } else {
        [self showErrorMessage:NSLocalizedString(kLocalizationAlertDialogGenericNetworkErrorText, @"Generic network error")];
    }
}

- (IBAction)onAdvancedSearch:(id)sender {
    [self toggleAdvancedSearchView];
}

- (void)refreshContentList {
    // Remove any filter information so that all record entries could be
    // re-fetched any checked for updates
    self.searchTextField.text = nil;
    self.currentFilter.page = 0;
    
    [self fetchContentList];
}

- (IBAction)onContentOverlayTap:(id)sender {
    [self handleToggleEventOnContentOnverlayView];
}

- (IBAction)onSectionChange:(UIButton *)sender {
    AFAListBaseViewModel *viewModelToLoad = nil;
    if (AFAListButtonTypeTasks == sender.tag) {
        viewModelToLoad = self.taskListViewModel;
        self.dataSource = [[AFATaskListViewDataSource alloc] initWithDataEntries:nil
                                                                      themeColor:self.navigationBarThemeColor];
    } else {
        viewModelToLoad = self.processListViewModel;
        self.dataSource = [[AFAProcessListViewDataSource alloc] initWithDataEntries:nil
                                                                         themeColor:self.navigationBarThemeColor];
    }
    
    if (viewModelToLoad != self.currentListViewModel) {
        self.controllerState = AFAListControllerStateRefreshInProgress;
        self.listTableView.contentOffset = CGPointZero;
        self.searchTextField.text = nil;
        
        self.currentListViewModel = viewModelToLoad;
        self.listTableView.dataSource = self.dataSource;
        [self updateSceneForCurrentViewModel];
        [self animateUnderlineContentSectionForType:sender.tag];
        
        // Fetch the filter list according to what section the user selected
        [self.dataSource loadFilterListForController:self.filterViewController];
    }
}

- (IBAction)onAdd:(UIBarButtonItem *)sender {
    if (self.processListViewModel == self.currentListViewModel) {
        [self performSegueWithIdentifier:kSegueIDStartProcessInstance
                                  sender:sender];
    } else {
        AFAModalTaskDetailsViewController *addTaskController = [self.storyboard instantiateViewControllerWithIdentifier:kStoryboardIDModalTaskDetailsViewController];
        addTaskController.alertTitle = NSLocalizedString(kLocalizationAddTaskScreenTitleText, @"New task title");
        addTaskController.confirmButtonTitle = NSLocalizedString(kLocalizationAddTaskScreenCreateButtonText, @"Confirm button");
        addTaskController.applicationID = self.currentListViewModel.application.modelID;
        addTaskController.appThemeColor = self.navigationBarThemeColor;
        addTaskController.delegate = self;
        
        AFAModalTaskDetailsCreateTaskAction *createTaskAction = [AFAModalTaskDetailsCreateTaskAction new];
        addTaskController.confirmAlertAction =  createTaskAction;
        
        addTaskController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        addTaskController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        
        [self presentViewController:addTaskController
                           animated:YES
                         completion:nil];
    }
}


#pragma mark -
#pragma mark Content handling

- (void)fetchContentList {
    // Based on the chosen list content type fetch the list of tasks or the process
    // instance list with the default filter provided by the filter controller
    self.currentFilter.size = kDefaultTaskListFetchSize;
    self.currentFilter.appDeploymentID = self.currentListViewModel.application.deploymentID;
    
    __weak typeof(self) weakSelf = self;
    [self.dataSource loadContentListForFilter:self.currentFilter
                          withCompletionBlock:^(id<AFAListDataSourceProtocol> dataSource, AFAListResponseModel *response) {
                              __strong typeof(self) strongSelf = weakSelf;
                              
                              [strongSelf handleListRequestResponseFromDataSource:dataSource
                                                                         response:response
                                                                 isCachedResponse:NO];
                          } cachedResults:^(id<AFAListDataSourceProtocol> dataSource, AFAListResponseModel *response) {
                              __strong typeof(self) strongSelf = weakSelf;
                              
                              [strongSelf handleListRequestResponseFromDataSource:dataSource
                                                                         response:response
                                                                 isCachedResponse:YES];
                          }];
}

- (void)fetchListForSearchTerm:(NSString *)searchTerm {
    // Pass the existing defined filter
    self.currentFilter.text = searchTerm;
    self.currentFilter.page = 0;
    self.currentFilter.appDefinitionID = self.currentListViewModel.application.modelID;
    
    [self fetchContentList];
}

- (void)fetchNextPageForCurrentList {
    self.currentFilter.page += 1;
    
    [self fetchContentList];
}

- (void)handleListRequestResponseFromDataSource:(id<AFAListDataSourceProtocol>)dataSource
                                       response:(AFAListResponseModel *)response
                               isCachedResponse:(BOOL)isCachedResponse {
    // Make sure the handling is performed for the current active data source
    if ([dataSource class] != [self.dataSource class]) {
        return;
    }
    
    if (!response.error) {
        // Display the last update date
        if (self.refreshControl) {
            self.refreshControl.attributedTitle = [[NSDate date] lastUpdatedFormattedString];
        }
        [self.dataSource processAdditionalEntries:response.objectList
                                        forPaging:response.paging];
        
        [self.listTableView reloadData];
    } else {
        if (isCachedResponse) {
            [self.dataSource processAdditionalEntries:nil
                                            forPaging:nil];
            [self.listTableView reloadData];
        } else {
            if (response.error.code == NSURLErrorNotConnectedToInternet) {
                [self showWarningMessage:NSLocalizedString(kLocalizationOfflineProvidingCachedResultsText, @"Cached results text")];
            } else {
                [self showErrorMessage:NSLocalizedString(kLocalizationAlertDialogGenericNetworkErrorText, @"Generic network error")];
            }
        }
    }
    
    BOOL isContentAvailable = self.dataSource.dataEntries.count ? YES : NO;
    self.controllerState = isContentAvailable ? AFAListControllerStateIdle : AFAListControllerStateEmptyList;
    
    [self endRefreshOnRefreshControl];
    
    // If an activity indicator is present in the table's footer view remove it
    if (self.listTableView.tableFooterView) {
        [UIView beginAnimations:nil
                        context:NULL];
        self.preloadingActivityView.animating = NO;
        self.listTableView.tableFooterView = nil;
        [UIView commitAnimations];
    }
}


#pragma mark -
#pragma mark Convenience methods

- (void)endRefreshOnRefreshControl {
    __weak typeof(self) weakSelf = self;
    [[NSOperationQueue currentQueue] addOperationWithBlock:^{
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf.refreshControl endRefreshing];
    }];
}


#pragma mark -
#pragma mark AFAFilterViewController Delegate

- (void)filterModelsDidLoadWithDefaultFilter:(AFAGenericFilterModel *)filterModel
                                  filterType:(AFAFilterType)filterType
                            isCachedResponse:(BOOL)isCachedResponse
                                       error:(NSError *)error {
    // Pre-compute missing filters error
    NSString *formattedMissingFiltersString = nil;
    
    if (!filterModel) {
        NSString *filterTypeString = nil;
        if (filterType == AFAFilterTypeTask) {
            filterTypeString = NSLocalizedString(kLocalizationListScreenTasksText, @"Tasks text");
        } else {
            filterTypeString = NSLocalizedString(kLocalizationListScreenProcessInstancesText, @"Process instances text");
        }
        
        formattedMissingFiltersString = [NSString stringWithFormat:NSLocalizedString(kLocalizationListScreenMissingFiltersFormat, @"Missing filters error"), filterTypeString, filterTypeString];
    }
    
    if (error) {
        if (!filterModel) {
            // If no cached data is available notify the user, otherwise fail silently
            BOOL isSilentFail = NO;
            
            if (!isCachedResponse) {
                if (!self.currentFilter) {
                    self.controllerState = AFAListControllerStateEmptyList;
                    [self showErrorMessage:formattedMissingFiltersString];
                } else { // Faily silently
                    isSilentFail = YES;
                }
            } else { // Fail silently
                isSilentFail = YES;
            }
            
            if (isSilentFail) {
                self.controllerState = AFAListControllerStateIdle;
            }
        }
    } else {
        if (!filterModel) {
            // Remote filters are missing, notify the user
            if (!isCachedResponse) {
                self.controllerState = AFAListControllerStateEmptyList;
                [self showErrorMessage:formattedMissingFiltersString];
                self.currentFilter = nil;
            } else {
                self.controllerState = AFAListControllerStateEmptyList;
                self.currentFilter = nil;
            }
        } else { // Positive flow
            if ((AFAFilterTypeTask == filterType &&
                 [self.dataSource isKindOfClass:[AFATaskListViewDataSource class]]) ||
                (AFAFilterTypeProcessInstance == filterType &&
                 [self.dataSource isKindOfClass:[AFAProcessListViewDataSource class]])) {
                    // Store the filter reference for further reuse
                    self.currentFilter = filterModel;
                    
                    [self fetchContentList];
                }
        }
    }
}

- (void)searchWithFilterModel:(AFAGenericFilterModel *)filterModel {
    self.listTableView.contentOffset = CGPointZero;
    
    // Store the filter returned by the task filter controller
    // and check also for values written inside the search box
    self.currentFilter = filterModel;
    
    [self searchWithTerm:self.searchTextField.text];
    [self handleToggleEventOnContentOnverlayView];
}

- (void)searchWithTerm:(NSString *)term {
    if (self.currentFilter) {
        self.controllerState = AFAListControllerStateRefreshInProgress;
        
        [self fetchListForSearchTerm:term];
    }
}

- (void)clearFilterInputText {
    self.searchTextField.text = nil;
}


#pragma mark -
#pragma mark AFAModalTaskDetailsViewControllerDelegate Delegate

- (void)didCreateTask:(ASDKModelTask *)task {
    [self.listTableView setContentOffset:CGPointZero
                                animated:NO];
    [self searchWithTerm:self.searchTextField.text];
}


#pragma mark -
#pragma mark Animations

- (void)handleToggleEventOnContentOnverlayView {
    // Check whether the overlay is displayed within a search context or
    // and advanced search context
    if (self.isAdvancedSearchInProgress) {
        [self toggleAdvancedSearchView];
    } else {
        [self toggleContentTransparentOverlay];
        [self.view endEditing:YES];
    }
}

- (void)toggleAdvancedSearchView {
    // Resign keyboard if transitioning from an active advanced search
    if (self.isAdvancedSearchInProgress) {
        [self.view endEditing:YES];
        [self.filterViewController rollbackFilterValuesToFilter:self.currentFilter];
    }
    
    // Switch state
    self.isAdvancedSearchInProgress = !self.isAdvancedSearchInProgress;
    self.advancedSearchRoundedBorderView.backgroundColor = self.isAdvancedSearchInProgress ? self.navigationBarThemeColor : [UIColor whiteColor];
    [self.advancedSearchButton setTitleColor:self.isAdvancedSearchInProgress ? [UIColor whiteColor] : [UIColor darkGreyTextColor]
                                    forState:UIControlStateNormal];
    
    // Make sure the advanced filter container view is visible
    // before animating
    self.advancedFilterContainerView.hidden = NO;
    
    // Compute updated constraint value
    CGFloat advancedSearchContainerTopConstraintValue = CGRectGetHeight(self.advancedFilterContainerView.frame) + CGRectGetHeight(self.searchView.frame);
    self.advancedSearchContainerTopConstraint.constant = self.isAdvancedSearchInProgress ? -30 : -advancedSearchContainerTopConstraintValue;
    
    CGFloat maximumAdmittedHeightForFilterView = CGRectGetHeight(self.view.frame) - 10;
    self.advancedSearchContainerHeightConstraint.constant = [self.filterViewController contentSizeForFilterView].height > maximumAdmittedHeightForFilterView ? maximumAdmittedHeightForFilterView : [self.filterViewController contentSizeForFilterView].height;
    
    [self toggleContentTransparentOverlay];
    
    [UIView animateWithDuration:kDefaultAnimationTime
                          delay:.0f
         usingSpringWithDamping:.7f
          initialSpringVelocity:5.0f
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         [self.view layoutIfNeeded];
                     } completion:^(BOOL finished) {
                         //  If the advanced search in not active anymore then hide the containing container
                         if (!self.isAdvancedSearchInProgress) {
                             self.advancedFilterContainerView.hidden = YES;
                         }
                     }];
}

- (void)toggleContentTransparentOverlay {
    CGFloat overlayAlphaValue = self.isAdvancedSearchInProgress ? .5f : self.advancedSearchOverlayView.alpha ? .0f : .5f;
    
    [self.advancedSearchOverlayView animateAlpha:overlayAlphaValue
                                    withDuration:kOverlayAlphaChangeTime
                             withCompletionBlock:nil];
}

- (void)animateUnderlineContentSectionForType:(AFAListButtonType)buttonType {
    // The order of enabling, disabling the constraints matter so we are obliged
    // to write the longer version for these checks
    switch (buttonType) {
        case AFAListButtonTypeTasks: {
            self.underlineTaskListButtonConstraint.priority = UILayoutPriorityDefaultHigh;
        }
            break;
            
        case AFAListButtonTypeProcessInstances: {
            self.underlineTaskListButtonConstraint.priority = UILayoutPriorityFittingSizeLevel;
        }
            break;
            
        default: break;
    }
    
    self.processListButton.tintColor = (AFAListButtonTypeProcessInstances == buttonType) ? [UIColor enabledControlColor] : [UIColor disabledControlColor];
    self.taskListButton.tintColor = (AFAListButtonTypeTasks == buttonType) ? [UIColor enabledControlColor] : [UIColor disabledControlColor];
    
    [UIView animateWithDuration:kDefaultAnimationTime
                          delay:.0f
         usingSpringWithDamping:1.0f
          initialSpringVelocity:5.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         [self.view layoutIfNeeded];
                     } completion:nil];
}


#pragma mark -
#pragma mark UITextField Delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [self toggleContentTransparentOverlay];
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self searchWithTerm:textField.text];
    [self handleToggleEventOnContentOnverlayView];
    
    return YES;
}


#pragma mark -
#pragma mark UITableViewDelegate

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
    
    // If we've reached the preload cell trigger a request for the new page
    if (self.dataSource.preloadCellIdx &&
        self.dataSource.preloadCellIdx == indexPath.row &&
        self.currentFilter.page < self.dataSource.totalPages) {
        // Display the activity view at the end of the table while content is fetched
        tableView.tableFooterView = self.loadingFooterView;
        self.preloadingActivityView.animating = YES;
        
        [self fetchNextPageForCurrentList];
    }
}

// Hide cell separators after the last row with content
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return .01f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc] init];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.dataSource isKindOfClass:[AFATaskListViewDataSource class]]) {
        [self performSegueWithIdentifier:kSegueIDTaskDetails
                                  sender:[tableView cellForRowAtIndexPath:indexPath]];
    } else {
        [self performSegueWithIdentifier:kSegueIDProcessInstanceDetails
                                  sender:[tableView cellForRowAtIndexPath:indexPath]];
    }
}


#pragma mark -
#pragma mark View model related

- (void)updateSceneForCurrentViewModel {
    self.noRecordsLabel.text = [self.currentListViewModel noRecordsLabelText];
    self.searchTextField.placeholder = [self.currentListViewModel searchTextFieldPlacholderText];
}


#pragma mark -
#pragma mark KVO bindings

- (void)handleBindingsForTaskListViewController {
    self.kvoManager = [ASDKKVOManager managerWithObserver:self];
    
    __weak typeof(self) weakSelf = self;
    [self.kvoManager observeObject:self
                        forKeyPath:NSStringFromSelector(@selector(controllerState))
                           options:NSKeyValueObservingOptionNew
                             block:^(id observer, id object, NSDictionary *change) {
                                 AFAListControllerState controllerState = [change[NSKeyValueChangeNewKey] integerValue];
                                 
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     if (AFAListControllerStateIdle == controllerState) {
                                         weakSelf.loadingActivityView.hidden = YES;
                                         weakSelf.loadingActivityView.animating = NO;
                                         weakSelf.listTableView.hidden = NO;
                                         weakSelf.refreshView.hidden = YES;
                                         weakSelf.noRecordsLabel.hidden = YES;
                                     } else if (AFAListControllerStateRefreshInProgress == controllerState) {
                                         weakSelf.loadingActivityView.hidden = NO;
                                         weakSelf.loadingActivityView.animating = YES;
                                         weakSelf.listTableView.hidden = YES;
                                         weakSelf.refreshView.hidden = YES;
                                         weakSelf.noRecordsLabel.hidden = YES;
                                     } else if (AFAListControllerStateEmptyList == controllerState) {
                                         weakSelf.loadingActivityView.hidden = YES;
                                         weakSelf.loadingActivityView.animating = NO;
                                         weakSelf.listTableView.hidden = YES;
                                         weakSelf.refreshView.hidden = NO;
                                         weakSelf.noRecordsLabel.hidden = NO;
                                     }
                                 });
                             }];
}

@end

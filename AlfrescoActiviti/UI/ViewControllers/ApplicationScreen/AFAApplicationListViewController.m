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

#import "AFAApplicationListViewController.h"

// Constants
#import "AFALocalizationConstants.h"
#import "AFABusinessConstants.h"
#import "AFAUIConstants.h"
#import "UIColor+AFATheme.h"

// Categories
#import "UIViewController+AFAAlertAddition.h"
#import "NSDate+AFAStringTransformation.h"
#import "UIColor+AFATheme.h"

// View models
#import "AFATaskListViewModel.h"
#import "AFAProcessListViewModel.h"

// Views
#import "AFAActivityView.h"

// Cells
#import "AFAApplicationListStyleCell.h"

// Managers
#import "AFAAppServices.h"

// Controllers
#import "AFAListViewController.h"


typedef NS_ENUM(NSInteger, AFAApplicationListControllerState) {
    AFAApplicationListControllerStateIdle,
    AFAApplicationListControllerStateRefreshInProgress,
    AFAApplicationListControllerStateEmptyList
};

@interface AFAApplicationListViewController ()

@property (weak, nonatomic) IBOutlet UITableView                            *applicationListTableView;
@property (weak, nonatomic) IBOutlet AFAActivityView                        *activityView;
@property (weak, nonatomic) IBOutlet UILabel                                *noApplicationsLabel;
@property (weak, nonatomic) IBOutlet UIView                                 *refreshView;
@property (strong, nonatomic) UIRefreshControl                              *refreshControl;
@property (weak, nonatomic) IBOutlet UIButton                               *refreshButton;

// Internal state properties
@property (strong, nonatomic) NSArray                                       *applicationListArr;
@property (assign, nonatomic) AFAApplicationListControllerState             controllerState;

// Services
@property (strong, nonatomic) AFAAppServices                                *requestApplicationsService;
@property (strong, nonatomic) ASDKKVOManager                                *kvoManager;

@end

@implementation AFAApplicationListViewController


#pragma mark -
#pragma mark Life cycle

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        _controllerState = AFAApplicationListControllerStateIdle;
        _applicationListArr = [NSMutableArray array];
        _requestApplicationsService = [AFAAppServices new];
        
        // Set up state bindings
        [self handleBindingsForAppListViewController];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Update navigation bar title
    self.navigationBarTitle = NSLocalizedString(kLocalizationAppScreenTitleText, @"Application title");
    
    // Set up the refresh control
    UITableViewController *tableViewController = [[UITableViewController alloc] init];
    [self addChildViewController:tableViewController];
    tableViewController.tableView = self.applicationListTableView;
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self
                            action:@selector(fetchRuntimeApplicationList)
                  forControlEvents:UIControlEventValueChanged];
    tableViewController.refreshControl = self.refreshControl;
    
    self.refreshButton.titleLabel.font = [UIFont glyphiconFontWithSize:15];
    [self.refreshButton setTitle:[NSString iconStringForIconType:ASDKGlyphIconTypeRefresh]
                        forState:UIControlStateNormal];
    
    // Set up the details table view to adjust it's size automatically
    self.applicationListTableView.estimatedRowHeight = 65.0f;
    self.applicationListTableView.rowHeight = UITableViewAutomaticDimension;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Update the navigation bar theme color
    self.navigationBarThemeColor = [UIColor applicationThemeDefaultColor];
    if (self.delegate) {
        [self.delegate changeThemeColor:self.navigationBarThemeColor];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self onRefresh:nil];
}


#pragma mark -
#pragma mark Connectivity notifications

- (void)didRestoredNetworkConnectivity {
    [super didRestoredNetworkConnectivity];
    
    self.controllerState = AFAApplicationListControllerStateRefreshInProgress;
    [self onRefresh:nil];
}

- (void)didLoseNetworkConnectivity {
    [super didLoseNetworkConnectivity];
    
    [self onRefresh:nil];
}


#pragma mark -
#pragma mark Actions

- (IBAction)onRefresh:(id)sender {
    self.refreshView.hidden = YES;
    self.noApplicationsLabel.hidden = YES;
    
    // Just show the activity view when a full screen reload is in progress
    // Use the pull-to-refresh mechanism otherwise
    self.controllerState = AFAApplicationListControllerStateRefreshInProgress;
    
    // Fetch runtime application list
    [self fetchRuntimeApplicationList];
}

- (IBAction)onMenu:(id)sender {
    [self toggleMenu:sender];
}


#pragma mark -
#pragma mark Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue
                 sender:(id)sender {
    if ([kSegueIDList isEqualToString:segue.identifier]) {
        AFAListViewController *listViewController = (AFAListViewController *)segue.destinationViewController;
        
        ASDKModelApp *application = self.applicationListArr[[self.applicationListTableView indexPathForCell:(UITableViewCell *)sender].row];
        AFATaskListViewModel *taskListViewModel = [[AFATaskListViewModel alloc] initWithApplication:application];
        AFAProcessListViewModel *processListViewModel = [[AFAProcessListViewModel alloc] initWithApplication:application];
        listViewController.taskListViewModel = taskListViewModel;
        listViewController.processListViewModel = processListViewModel;
    }
}

- (IBAction)unwindApplicationListController:(UIStoryboardSegue *)segue {
}


#pragma mark -
#pragma mark Service integration

- (void)fetchRuntimeApplicationList {
    __weak typeof(self) weakSelf = self;
    
    [self.requestApplicationsService requestRuntimeAppDefinitionsWithCompletionBlock:^(NSArray *appDefinitionsList, NSError *error, ASDKModelPaging *paging) {
        __strong typeof(self) strongSelf = weakSelf;
        
        if (!error) {
            BOOL isContentAvailable = appDefinitionsList.count ? YES : NO;
            strongSelf.controllerState = isContentAvailable ? AFAApplicationListControllerStateIdle : AFAApplicationListControllerStateEmptyList;
            
            strongSelf.applicationListArr = appDefinitionsList;
            [self.applicationListTableView reloadData];
            
            // Display the last update date
            if (strongSelf.refreshControl) {
                strongSelf.refreshControl.attributedTitle = [[NSDate date] lastUpdatedFormattedString];
            }
        } else {
            if (error.code == NSURLErrorNotConnectedToInternet) {
                [self showWarningMessage:NSLocalizedString(kLocalizationOfflineProvidingCachedResultsText, @"Cached results text")];
            } else {
                [self showErrorMessage:NSLocalizedString(kLocalizationAlertDialogGenericNetworkErrorText, @"Generic network error")];
            }
        }
        
        [[NSOperationQueue currentQueue] addOperationWithBlock:^{
            [weakSelf.refreshControl endRefreshing];
        }];
    } cachedResults:^(NSArray *appDefinitionsList, NSError *error, ASDKModelPaging *paging) {
        __strong typeof(self) strongSelf = weakSelf;
        
        BOOL isContentAvailable = appDefinitionsList.count ? YES : NO;
        strongSelf.controllerState = isContentAvailable ? AFAApplicationListControllerStateIdle : AFAApplicationListControllerStateEmptyList;
        
        if (!error) {
            if (appDefinitionsList) {
                strongSelf.applicationListArr = appDefinitionsList;
                [self.applicationListTableView reloadData];
            }
        }
        
        [[NSOperationQueue currentQueue] addOperationWithBlock:^{
            [weakSelf.refreshControl endRefreshing];
        }];
    }];
}


#pragma mark -
#pragma mark Tableview Delegate & Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    return self.applicationListArr.count;
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
    AFAApplicationListStyleCell *applicationCell = [tableView dequeueReusableCellWithIdentifier:kCellIDApplicationListStyle];
    // Set up the cell with task details
    [applicationCell setupWithApplication:self.applicationListArr[indexPath.row]];
    
    return applicationCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath
                             animated:YES];
    
    if (self.delegate) {
        ASDKModelApp *application = self.applicationListArr[indexPath.row];
        UIColor *themeColor = [UIColor applicationColorForTheme:application.theme];
        [self.delegate changeThemeColor:themeColor];
    }
    
    [self performSegueWithIdentifier:kSegueIDList
                              sender:[tableView cellForRowAtIndexPath:indexPath]];
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
                                 AFAApplicationListControllerState controllerState = [change[NSKeyValueChangeNewKey] integerValue];
                                 
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     if (AFAApplicationListControllerStateIdle == controllerState) {
                                         weakSelf.activityView.hidden = YES;
                                         weakSelf.activityView.animating = NO;
                                         weakSelf.applicationListTableView.hidden = NO;
                                         weakSelf.refreshView.hidden = YES;
                                         weakSelf.noApplicationsLabel.hidden = YES;
                                     } else if (AFAApplicationListControllerStateRefreshInProgress == controllerState) {
                                         weakSelf.activityView.hidden = NO;
                                         weakSelf.activityView.animating = YES;
                                         weakSelf.applicationListTableView.hidden = YES;
                                         weakSelf.refreshView.hidden = YES;
                                         weakSelf.noApplicationsLabel.hidden = YES;
                                     } else if (AFAApplicationListControllerStateEmptyList == controllerState) {
                                         weakSelf.activityView.hidden = YES;
                                         weakSelf.activityView.animating = NO;
                                         weakSelf.applicationListTableView.hidden = YES;
                                         weakSelf.refreshView.hidden = NO;
                                         weakSelf.noApplicationsLabel.hidden = NO;
                                     }
                                 });
                             }];
}


@end

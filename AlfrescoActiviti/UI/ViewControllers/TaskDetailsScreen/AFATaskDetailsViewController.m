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

#import "AFATaskDetailsViewController.h"

// Constants
#import "AFAUIConstants.h"
#import "AFABusinessConstants.h"
#import "AFALocalizationConstants.h"

// Categories
#import "UIViewController+AFAAlertAddition.h"
#import "NSDate+AFAStringTransformation.h"
#import "NSDate+AFADateAdditions.h"
#import "UIColor+AFATheme.h"

// Data source
#import "AFAContentPickerDataSource.h"
#import "AFAContentPickerTaskUploadBehavior.h"
#import "AFAProcessInstanceDetailsDataSource.h"
#import "AFATaskDetailsDataSource.h"

// Managers
#import "AFAServiceRepository.h"
#import "AFATableController.h"
#import "AFATableControllerTaskDetailsCellFactory.h"
#import "AFATaskChecklistCellFactory.h"
#import "AFATableControllerTaskContributorsCellFactory.h"
#import "AFATableControllerContentCellFactory.h"
#import "AFATableControllerCommentCellFactory.h"
#import "AFAProfileServices.h"
#import "AFAIntegrationServices.h"
#import "AFAUserServices.h"
#import "AFAModalTaskDetailsCreateChecklistAction.h"
#import "AFAModalTaskDetailsUpdateTaskAction.h"
@import ActivitiSDK;

// Models
#import "AFATableControllerTaskDetailsModel.h"
#import "AFATableControllerTaskContributorsModel.h"
#import "AFATableControllerContentModel.h"
#import "AFATableControllerCommentModel.h"
#import "AFATaskUpdateModel.h"
#import "AFATableControllerChecklistModel.h"

// Views
#import "AFAActivityView.h"
#import "AFANoContentView.h"
#import "AFAConfirmationView.h"

// Controllers
#import "AFAContentPickerViewController.h"
#import "AFATaskFormViewController.h"
#import "AFAPeoplePickerViewController.h"
#import "AFAProcessInstanceDetailsViewController.h"
#import "AFAAddCommentsViewController.h"
#import "AFAModalTaskDetailsViewController.h"
#import "AFAModalPeoplePickerViewController.h"

typedef NS_ENUM(NSUInteger, AFATaskDetailsLoadingState) {
    AFATaskDetailsLoadingStateIdle = 0,
    AFATaskDetailsLoadingStateRefreshInProgress,
    AFATaskDetailsLoadingStateEmptyList
};

@interface AFATaskDetailsViewController () <AFAContentPickerViewControllerDelegate,
AFATaskFormViewControllerDelegate,
ASDKIntegrationBrowsingDelegate,
AFAConfirmationViewDelegate,
AFAModalTaskDetailsViewControllerDelegate,
AFAModalPeoplePickerViewControllerDelegate>

@property (weak, nonatomic)   IBOutlet UIBarButtonItem                      *backBarButtonItem;
@property (weak, nonatomic)   IBOutlet UITableView                          *taskDetailsTableView;
@property (weak, nonatomic)   IBOutlet AFAActivityView                      *loadingActivityView;
@property (strong, nonatomic) UIRefreshControl                              *refreshControl;
@property (weak, nonatomic)   IBOutlet UIButton                             *taskDetailsButton;
@property (weak, nonatomic)   IBOutlet UIButton                             *taskChecklistButton;
@property (weak, nonatomic)   IBOutlet UIButton                             *taskFormButton;
@property (weak, nonatomic)   IBOutlet UIButton                             *taskContentButton;
@property (weak, nonatomic)   IBOutlet UIButton                             *taskContributorsButton;
@property (weak, nonatomic)   IBOutlet UIButton                             *taskCommentsButton;
@property (weak, nonatomic)   IBOutlet UIToolbar                            *datePickerToolbar;
@property (weak, nonatomic)   IBOutlet UIView                               *contentPickerContainer;
@property (weak, nonatomic)   IBOutlet UIView                               *fullScreenOverlayView;
@property (weak, nonatomic)   IBOutlet NSLayoutConstraint                   *datePickerBottomConstraint;
@property (weak, nonatomic)   IBOutlet NSLayoutConstraint                   *contentPickerContainerBottomConstraint;
@property (weak, nonatomic)   IBOutlet NSLayoutConstraint                   *contentPickerContainerHeightConstraint;
@property (weak, nonatomic)   IBOutlet UIView                               *datePickerContainerView;
@property (strong, nonatomic) UIDatePicker                                  *datePicker;
@property (strong, nonatomic) AFAContentPickerViewController                *contentPickerViewController;
@property (strong, nonatomic) AFATaskFormViewController                     *taskFormViewController;
@property (weak, nonatomic)   IBOutlet UIView                               *formViewContainer;
@property (weak, nonatomic)   IBOutlet NSLayoutConstraint                   *taskDetailsTableViewTopConstraint;
@property (strong, nonatomic) IBOutlet UIBarButtonItem                      *addBarButtonItem;
@property (strong, nonatomic) UIBarButtonItem                               *editBarButtonItem;
@property (weak, nonatomic)   IBOutlet AFANoContentView                     *noContentView;
@property (strong, nonatomic) ASDKIntegrationBrowsingViewController         *integrationBrowsingController;
@property (weak, nonatomic)   IBOutlet AFAConfirmationView                  *confirmationView;
@property (strong, nonatomic) IBOutlet UILongPressGestureRecognizer         *longPressGestureRecognizer;
@property (weak, nonatomic)   IBOutlet NSLayoutConstraint                   *tabBarHeightConstraint;
@property (weak, nonatomic)   IBOutlet NSLayoutConstraint                   *datepickerHeightConstraint;

// Internal state properties
@property (assign, nonatomic) AFATaskDetailsLoadingState                    controllerState;
@property (assign, nonatomic) NSInteger                                     currentSelectedSection;
@property (assign, nonatomic) NSUInteger                                    initialTabBarHeight;
@property (assign, nonatomic) NSUInteger                                    initialDatePickerHeight;
@property (assign, nonatomic) NSUInteger                                    initialContentPickerContainerHeight;

// KVO
@property (strong, nonatomic) ASDKKVOManager                                *kvoManager;

@end

@implementation AFATaskDetailsViewController

#pragma mark -
#pragma mark Life cycle

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _controllerState = AFATaskDetailsLoadingStateIdle;
        
        // Set up state bindings
        [self handleBindingsForTaskListViewController];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Bind table view's delegates to table controller
    self.taskDetailsTableView.dataSource = self.dataSource.tableController;
    self.taskDetailsTableView.delegate = self.dataSource.tableController;
    self.navigationBarThemeColor = self.dataSource.themeColor;
    
    // Set up the details table view to adjust it's size automatically
    self.taskDetailsTableView.estimatedRowHeight = 60.0f;
    self.taskDetailsTableView.rowHeight = UITableViewAutomaticDimension;
    
    // Update UI for current localization
    [self setupLocalization];
    
    // Set up section buttons
    self.taskDetailsButton.tag = AFATaskDetailsSectionTypeTaskDetails;
    self.taskChecklistButton.tag = AFATaskDetailsSectionTypeChecklist;
    self.taskFormButton.tag = AFATaskDetailsSectionTypeForm;
    self.taskContentButton.tag = AFATaskDetailsSectionTypeFilesContent;
    self.taskContributorsButton.tag = AFATaskDetailsSectionTypeContributors;
    self.taskCommentsButton.tag = AFATaskDetailsSectionTypeComments;
    self.currentSelectedSection = AFATaskDetailsSectionTypeTaskDetails;
    self.taskDetailsButton.tintColor = [self.navigationBarThemeColor colorWithAlphaComponent:.7f];
    
    // Set up the refresh control
    UITableViewController *tableViewController = [[UITableViewController alloc] init];
    [self addChildViewController:tableViewController];
    tableViewController.tableView = self.taskDetailsTableView;
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self
                            action:@selector(refreshContentForCurrentSection)
                  forControlEvents:UIControlEventValueChanged];
    tableViewController.refreshControl = self.refreshControl;
    
    // Add shaddow to date picker toolbar
    self.datePickerToolbar.layer.masksToBounds = NO;
    self.datePickerToolbar.layer.shadowOffset = CGSizeMake(0, -.5f);
    self.datePickerToolbar.layer.shadowRadius = 2.0f;
    self.datePickerToolbar.layer.shadowOpacity = 0.5;
    
    // Make sure the add button is not pressent on certain categories.
    // It will be enabled based on the current section selection
    self.navigationItem.rightBarButtonItem = nil;
    
    // Set up edit button for ad-hoc task details section
    self.editBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                                                           target:self
                                                                           action:@selector(onTaskDetailsEdit:)];
    self.editBarButtonItem.tintColor = [UIColor whiteColor];
    
    self.confirmationView.delegate = self;
    
    self.initialTabBarHeight = self.tabBarHeightConstraint.constant;
    self.initialDatePickerHeight = self.datepickerHeightConstraint.constant;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    BOOL isConnectivityAvailable = [self isNetworkReachable];
    
    self.dataSource.isConnectivityAvailable = isConnectivityAvailable;
    [self refreshUIForConnectivity:isConnectivityAvailable];
    
    [self refreshContentForCurrentSection];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    // Adjust tab bar for view's safe area
    if (@available(iOS 11.0, *)) {
        self.tabBarHeightConstraint.constant = self.initialTabBarHeight + self.view.safeAreaInsets.bottom;
        self.datepickerHeightConstraint.constant = self.initialDatePickerHeight + self.view.safeAreaInsets.bottom;
    }
}

#pragma mark -
#pragma mark Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([kSegueIDContentPickerComponentEmbedding isEqualToString:segue.identifier]) {
        self.contentPickerViewController = (AFAContentPickerViewController *)segue.destinationViewController;
        self.contentPickerViewController.delegate = self;
        self.contentPickerViewController.taskID = self.dataSource.taskID;
        
        AFAContentPickerTaskUploadBehavior *taskUploadBehavior = [AFAContentPickerTaskUploadBehavior new];
        AFAContentPickerDataSource *contentPickerDataSource = [AFAContentPickerDataSource new];
        contentPickerDataSource.uploadBehavior = taskUploadBehavior;
        
        self.contentPickerViewController.dataSource = contentPickerDataSource;
    } else if ([kSegueIDFormComponent isEqualToString:segue.identifier]) {
        self.taskFormViewController = (AFATaskFormViewController *)segue.destinationViewController;
        self.taskFormViewController.delegate = self;
    } else if ([kSegueIDTaskDetailsAddContributor isEqualToString:segue.identifier]) {
        AFAPeoplePickerViewController *peoplePickerViewController = (AFAPeoplePickerViewController *)segue.destinationViewController;
        peoplePickerViewController.taskID = self.dataSource.taskID;
        
        // Based on the current section decide what kind of people picker controller type
        // is going to be configured
        if (AFATaskDetailsSectionTypeTaskDetails == self.currentSelectedSection) {
            peoplePickerViewController.peoplePickerType = AFAPeoplePickerControllerTypeReAssign;
        } else {
            peoplePickerViewController.peoplePickerType = AFAPeoplePickerControllerTypeInvolve;
        }
    } else if ([kSegueIDTaskDetailsViewProcess isEqualToString:segue.identifier]) {
        AFAProcessInstanceDetailsViewController *processInstanceDetailsController = (AFAProcessInstanceDetailsViewController *)segue.destinationViewController;
        
        AFATableControllerTaskDetailsModel *taskDetailsModel = [self.dataSource reusableTableControllerModelForSectionType:AFATaskDetailsSectionTypeTaskDetails];
        AFAProcessInstanceDetailsDataSource *processInstanceDetailsDataSource =
        [[AFAProcessInstanceDetailsDataSource alloc] initWithProcessInstanceID:taskDetailsModel.currentTask.processInstanceID
                                                                    themeColor:self.navigationBarThemeColor];
        
        processInstanceDetailsController.dataSource = processInstanceDetailsDataSource;
        processInstanceDetailsController.unwindActionType = AFAProcessInstanceDetailsUnwindActionTypeTaskDetails;
    } else if ([kSegueIDTaskDetailsAddComments isEqualToString:segue.identifier]) {
        AFAAddCommentsViewController *addCommentsViewController = (AFAAddCommentsViewController *)segue.destinationViewController;
        addCommentsViewController.taskID = self.dataSource.taskID;
    } else if([kSegueIDTaskDetailsChecklist isEqualToString:segue.identifier]) {
        AFATaskDetailsViewController *taskDetailsViewController = (AFATaskDetailsViewController *)segue.destinationViewController;
        
        AFATableControllerChecklistModel *checklistModel = [self.dataSource reusableTableControllerModelForSectionType:AFATaskDetailsSectionTypeChecklist];
        ASDKModelTask *selectedTask = ((ASDKModelTask *)[checklistModel itemAtIndexPath:[self.taskDetailsTableView indexPathForCell:(UITableViewCell *)sender]]);
        
        AFATaskDetailsDataSource *taskDetailsDataSource = [[AFATaskDetailsDataSource alloc] initWithTaskID:selectedTask.modelID
                                                                                              parentTaskID:selectedTask.parentTaskID
                                                                                                themeColor:self.navigationBarThemeColor];
        taskDetailsViewController.dataSource = taskDetailsDataSource;
        taskDetailsViewController.unwindActionType = AFATaskDetailsUnwindActionTypeChecklist;
    } else if ([kSegueIDTaskDetailsViewTask isEqualToString:segue.identifier]) {
        AFATaskDetailsViewController *taskDetailsViewController = (AFATaskDetailsViewController *)segue.destinationViewController;
        
        AFATableControllerTaskDetailsModel *taskDetailsModel = [self.dataSource reusableTableControllerModelForSectionType:AFATaskDetailsSectionTypeTaskDetails];
        AFATaskDetailsDataSource *taskDetailsDataSource =
        [[AFATaskDetailsDataSource alloc] initWithTaskID:taskDetailsModel.currentTask.parentTaskID
                                            parentTaskID:nil
                                              themeColor:self.navigationBarThemeColor];
        taskDetailsViewController.dataSource = taskDetailsDataSource;
        taskDetailsViewController.unwindActionType = AFATaskDetailsUnwindActionTypeChecklist;
    }
}

- (IBAction)unwindPeoplePickerController:(UIStoryboardSegue *)segue {
}

- (IBAction)unwindViewProcessInstanceDetailsController:(UIStoryboardSegue *)segue {
}

- (IBAction)unwindAddCommentsController:(UIStoryboardSegue *)segue {
}

- (IBAction)unwindTaskChecklistController:(UIStoryboardSegue *)sender {
}


#pragma mark -
#pragma mark Connectivity notifications

- (void)didRestoredNetworkConnectivity {
    [super didRestoredNetworkConnectivity];
    
    self.dataSource.isConnectivityAvailable = YES;
    [self refreshUIForConnectivity:self.dataSource.isConnectivityAvailable];
    
    self.controllerState = AFATaskDetailsLoadingStateRefreshInProgress;
    [self refreshContentForCurrentSection];
}

- (void)didLoseNetworkConnectivity {
    [super didLoseNetworkConnectivity];
    
    self.dataSource.isConnectivityAvailable = NO;
    [self refreshUIForConnectivity:self.dataSource.isConnectivityAvailable];
    
    [self refreshContentForCurrentSection];
    
    /* When having the form controller being displayed, the SDK will not provide
     * whether the results are cached or from the network due to the high number of
     * possible combinations of the internal components. For that case, manually
     * display the cached results message
     */
    if (AFATaskDetailsSectionTypeForm == self.currentSelectedSection) {
        [self showWarningMessage:NSLocalizedString(kLocalizationOfflineProvidingCachedResultsText, @"Cached results text")];
    }
}

- (void)refreshUIForConnectivity:(BOOL)isConnected {
    self.addBarButtonItem.enabled = isConnected;
    self.editBarButtonItem.enabled = isConnected;
    if (!isConnected) {
        if (!self.contentPickerContainer.hidden) {
            [self onFullscreenOverlayTap:nil];
        }
    }
}


#pragma mark -
#pragma mark Actions

- (IBAction)onBack:(id)sender {
    NSString *backSegueIdentifier = nil;
    
    switch (self.unwindActionType) {
        case AFATaskDetailsUnwindActionTypeTaskList: {
            backSegueIdentifier = kSegueIDTaskDetailsUnwind;
        }
            break;
            
        case AFATaskDetailsUnwindActionTypeProcessInstanceDetails: {
            backSegueIdentifier = kSegueIDProcessInstanceTaskDetailsUnwind;
        }
            break;
            
        case AFATaskDetailsUnwindActionTypeChecklist: {
            backSegueIdentifier = kSegueIDTaskDetailsChecklistUnwind;
        }
            break;
            
        default: break;
    }
    
    [self performSegueWithIdentifier:backSegueIdentifier
                              sender:sender];
}

- (IBAction)onSectionSwitch:(id)sender {
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
        
        // Exit editing mode if applicable
        [self.taskDetailsTableView setEditing:NO
                                     animated:YES];
        
        // Update the controller state and refresh the appropiate section
        self.controllerState = AFATaskDetailsLoadingStateRefreshInProgress;
        
        [self refreshContentForCurrentSection];
        [self.taskDetailsTableView reloadData];
    }
}

- (IBAction)onFullscreenOverlayTap:(id)sender {
    [self toggleFullscreenOverlayView];
    
    if (AFATaskDetailsSectionTypeFilesContent == self.currentSelectedSection) {
        [self toggleContentPickerComponent];
    }
}

- (void)onFormSave {
    [self.taskFormViewController saveForm];
}

- (void)onTaskDetailsEdit:(id)sender {
    AFAModalTaskDetailsViewController *editTaskController = [self.storyboard instantiateViewControllerWithIdentifier:kStoryboardIDModalTaskDetailsViewController];
    
    AFATableControllerTaskDetailsModel *taskDetailsModel = [self.dataSource reusableTableControllerModelForSectionType:AFATaskDetailsSectionTypeTaskDetails];
    editTaskController.alertTitle = NSLocalizedString(kLocalizationAddTaskScreenUpdateTitleText, @"Update task title");
    editTaskController.confirmButtonTitle = NSLocalizedString(kLocalizationAlertDialogConfirmText, @"Confirm button");
    editTaskController.taskName = taskDetailsModel.currentTask.name;
    editTaskController.taskDescription = taskDetailsModel.currentTask.taskDescription;
    editTaskController.appThemeColor = self.navigationBarThemeColor;
    editTaskController.delegate = self;
    
    AFAModalTaskDetailsUpdateTaskAction *updateTaskAction = [AFAModalTaskDetailsUpdateTaskAction new];
    updateTaskAction.currentTaskID = self.dataSource.taskID;
    updateTaskAction.dueDate = [self.dataSource taskDueDate];
    editTaskController.confirmAlertAction = updateTaskAction;
    
    editTaskController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    editTaskController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    [self presentViewController:editTaskController
                       animated:YES
                     completion:nil];
}

- (IBAction)onAdd:(UIBarButtonItem *)sender {
    if (AFATaskDetailsSectionTypeFilesContent == self.currentSelectedSection) {
        [self toggleFullscreenOverlayView];
        [self toggleContentPickerComponent];
    } else if (AFATaskDetailsSectionTypeChecklist == self.currentSelectedSection) {
        AFAModalTaskDetailsViewController *addTaskController = [self.storyboard instantiateViewControllerWithIdentifier:kStoryboardIDModalTaskDetailsViewController];
        addTaskController.alertTitle = NSLocalizedString(kLocalizationAddTaskScreenChecklistTitleText, @"New checklist title");
        addTaskController.confirmButtonTitle = NSLocalizedString(kLocalizationAddTaskScreenCreateButtonText, @"Confirm button");
        addTaskController.appThemeColor = self.navigationBarThemeColor;
        addTaskController.delegate = self;
        
        AFAModalTaskDetailsCreateChecklistAction *createCheckListAction = [AFAModalTaskDetailsCreateChecklistAction new];
        createCheckListAction.parentTaskID = self.dataSource.taskID;
        addTaskController.confirmAlertAction = createCheckListAction;
        
        addTaskController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        addTaskController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        
        [self presentViewController:addTaskController
                           animated:YES
                         completion:nil];
    } else if (AFATaskDetailsSectionTypeContributors == self.currentSelectedSection) {
        if ([AFAUserServices isLoggedInOnCloud]) {
            AFAModalPeoplePickerViewController *addContributorController = [self.storyboard instantiateViewControllerWithIdentifier:kStoryboardIDModalPeoplePickerViewController];
            addContributorController.alertTitle = NSLocalizedString(kLocalizationPeoplePickerControllerTitleText, @"Add contributor title");
            addContributorController.appThemeColor = self.navigationBarThemeColor;
            addContributorController.taskID = self.dataSource.taskID;
            addContributorController.delegate = self;
            
            addContributorController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
            addContributorController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            
            [self presentViewController:addContributorController
                               animated:YES
                             completion:nil];
        } else {
            [self performSegueWithIdentifier:kSegueIDTaskDetailsAddContributor
                                      sender:sender];
        }
    } else if (AFATaskDetailsSectionTypeComments == self.currentSelectedSection) {
        [self performSegueWithIdentifier:kSegueIDTaskDetailsAddComments
                                  sender:sender];
    }
}

- (IBAction)onTableLongPress:(UILongPressGestureRecognizer *)sender {
    if (AFATaskDetailsSectionTypeChecklist == self.currentSelectedSection) {
        
        if (!self.taskDetailsTableView.editing) {
            [self.taskDetailsTableView setEditing:YES
                                         animated:YES];
        }
    }
}

- (IBAction)onDatePickerRemove:(id)sender {
    [self updateTaskDueDateWithDate:nil];
}

- (IBAction)onDatePickerDone:(id)sender {
    [self updateTaskDueDateWithDate:self.datePicker.date];
}

- (void)refreshContentForCurrentSection {
    if ([self isDueDatePickerVisible]) {
        [self toggleDatePickerComponent];
    }
    
    [self.dataSource updateTableControllerForSectionType:self.currentSelectedSection];
    
    BOOL displayTaskFormContainerView = NO;
    self.navigationItem.rightBarButtonItem = nil;
    
    AFATableControllerTaskDetailsModel *taskDetailsModel = [self.dataSource reusableTableControllerModelForSectionType:AFATaskDetailsSectionTypeTaskDetails];
    
    switch (self.currentSelectedSection) {
        case AFATaskDetailsSectionTypeTaskDetails: {
            self.navigationBarTitle = NSLocalizedString(kLocalizationTaskDetailsScreenTaskDetailsTitleText, @"Task details title");
            [self refreshTaskDetails];
        }
            break;
            
        case AFATaskDetailsSectionTypeChecklist: {
            self.navigationBarTitle = NSLocalizedString(kLocalizationTaskDetailsScreenChecklistTitleText, @"Task checklist title");
            [self refreshTaskChecklist];
            
            if (![taskDetailsModel isCompletedTask]) {
                self.navigationItem.rightBarButtonItem = self.addBarButtonItem;
            }
        }
            break;
            
        case AFATaskDetailsSectionTypeForm: {
            if (!self.isNetworkReachable) {
                [self showWarningMessage:NSLocalizedString(kLocalizationOfflineProvidingCachedResultsText, @"Cached results text")];
            }
            self.navigationBarTitle = NSLocalizedString(kLocalizationTaskDetailsScreenTaskFormTitleText, @"Task form title");
            displayTaskFormContainerView = YES;
            AFATableControllerTaskDetailsModel *taskDetailsModel = [self.dataSource reusableTableControllerModelForSectionType:AFATaskDetailsSectionTypeTaskDetails];
            [self.taskFormViewController formForTask:taskDetailsModel.currentTask];
        }
            break;
            
        case AFATaskDetailsSectionTypeContributors: {
            self.navigationBarTitle = NSLocalizedString(kLocalizationTaskDetailsScreenInvolvedPeopleText, @"Contributors title");
            [self refreshTaskContributors];
            
            if (![taskDetailsModel isCompletedTask]) {
                self.navigationItem.rightBarButtonItem = self.addBarButtonItem;
            }
        }
            break;
            
        case AFATaskDetailsSectionTypeFilesContent: {
            self.navigationBarTitle = NSLocalizedString(kLocalizationTaskDetailsScreenContentTitleText, @"Content title");
            [self refreshTaskContent];
            
            if (![taskDetailsModel isCompletedTask]) {
                self.navigationItem.rightBarButtonItem = self.addBarButtonItem;
            }
        }
            break;
            
        case AFATaskDetailsSectionTypeComments: {
            self.navigationBarTitle = NSLocalizedString(kLocalizationTaskDetailsScreenCommentsTitleText, @"Comments title");
            [self refreshTaskComments];
            
            if (![taskDetailsModel isCompletedTask]) {
                self.navigationItem.rightBarButtonItem = self.addBarButtonItem;
            }
        }
            break;
            
        default:
            break;
    }
    
    self.formViewContainer.hidden = !displayTaskFormContainerView;
}

- (void)onContentDeleteForTaskAtIndex:(NSInteger)taskIdx {
    self.controllerState = AFATaskDetailsLoadingStateRefreshInProgress;
    
    __weak typeof(self) weakSelf = self;
    [self.dataSource deleteContentForTaskAtIndex:taskIdx
                             withCompletionBlock:^(BOOL isContentDeleted, NSError *error) {
                                 __strong typeof(self) strongSelf = weakSelf;
                                 strongSelf.controllerState = AFATaskDetailsLoadingStateIdle;
                                 
                                 if (!isContentDeleted) {
                                     [strongSelf showGenericNetworkErrorAlertControllerWithMessage:NSLocalizedString(kLocalizationAlertDialogTaskContentDeleteErrorText, @"Task delete error")];
                                 } else {
                                     [strongSelf refreshTaskContent];
                                 }
                             }];
}

- (void)onRemoveInvolvedUserForCurrentTask:(ASDKModelUser *)user {
    self.controllerState = AFATaskDetailsLoadingStateRefreshInProgress;
    
    __weak typeof(self) weakSelf = self;
    [self.dataSource removeInvolvementForUser:user
                          withCompletionBlock:^(BOOL isUserInvolved, NSError *error) {
                              __strong typeof(self) strongSelf = weakSelf;
                              strongSelf.controllerState = AFATaskDetailsLoadingStateIdle;
                              
                              if (!error && !isUserInvolved) {
                                  [strongSelf refreshTaskContributors];
                              } else {
                                  [strongSelf showGenericNetworkErrorAlertControllerWithMessage:NSLocalizedString(kLocalizationAlertDialogTaskContentDeleteErrorText, @"Task delete error")];
                              }
                          }];
}

- (void)refreshTaskDetails {
    __weak typeof(self) weakSelf = self;
    [self.dataSource taskDetailsWithCompletionBlock:^(NSError *error, BOOL registerCellActions) {
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf handleTaskDetailsResponseWithErrorStatus:error
                                         registerCellActions:registerCellActions];
    } cachedResultsBlock:^(NSError *error, BOOL registerCellActions) {
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf handleTaskDetailsResponseWithErrorStatus:error
                                         registerCellActions:registerCellActions];
    }];
}

- (void)refreshTaskContributors {
    __weak typeof(self) weakSelf = self;
    [self.dataSource taskContributorsWithCompletionBlock:^(NSError *error) {
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf handleTaskContributorsListResponseWithErrorStatus:error];
    } cachedResultsBlock:^(NSError *error) {
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf handleTaskContributorsListResponseWithErrorStatus:error];
    }];
}

- (void)refreshTaskContent {
    __weak typeof(self) weakSelf = self;
    [self.dataSource taskContentWithCompletionBlock:^(NSError *error) {
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf handleTaskContentListResponseWithErrorStatus:error];
    } cachedResultsBlock:^(NSError *error) {
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf handleTaskContentListResponseWithErrorStatus:error];
    }];
}

- (void)refreshTaskComments {
    __weak typeof(self) weakSelf = self;
    [self.dataSource taskCommentsWithCompletionBlock:^(NSError *error) {
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf handleTaskCommentListResponseWithErrorStatus:error];
    } cachedResultsBlock:^(NSError *error) {
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf handleTaskCommentListResponseWithErrorStatus:error];
    }];
}

- (void)refreshTaskChecklist {
    __weak typeof(self) weakSelf = self;
    [self.dataSource taskChecklistWithCompletionBlock:^(NSError *error) {
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf handleTaskChecklistResponseWithErrorStatus:error];
    } cachedResultsBlock:^(NSError *error) {
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf handleTaskChecklistResponseWithErrorStatus:error];
    }];
}

- (void)updateTaskDetails {
    self.controllerState = AFATaskDetailsLoadingStateRefreshInProgress;
    
    __weak typeof(self) weakSelf = self;
    [self.dataSource updateCurrentTaskDetailsWithCompletionBlock:^(BOOL isTaskUpdated, NSError *error) {
        __strong typeof(self) strongSelf = weakSelf;
        strongSelf.controllerState = AFATaskDetailsLoadingStateIdle;
        
        if (!isTaskUpdated) {
            [strongSelf showGenericNetworkErrorAlertControllerWithMessage:NSLocalizedString(kLocalizationAlertDialogTaskUpdateErrorText, @"Task update error")];
            [strongSelf.taskDetailsTableView reloadData];
        }
        
    }];
}

- (void)completeTask {
    __weak typeof(self) weakSelf = self;
    [self.dataSource completeTaskWithCompletionBlock:^(BOOL isTaskCompleted, NSError *error) {
        __strong typeof(self) strongSelf = weakSelf;
        if (!isTaskCompleted) {
            [strongSelf showGenericNetworkErrorAlertControllerWithMessage:NSLocalizedString(kLocalizationAlertDialogTaskUpdateErrorText, @"Task update error")];
        } else {
            // Pop the controller and see the refreshed list
            [strongSelf onBack:nil];
        }
    }];
}

- (void)claimTask {
    self.controllerState = AFATaskDetailsLoadingStateRefreshInProgress;
    
    __weak typeof(self) weakSelf = self;
    [self.dataSource claimTaskWithCompletionBlock:^(BOOL isTaskClaimed, NSError *error) {
        __strong typeof(self) strongSelf = weakSelf;
        strongSelf.controllerState = AFATaskDetailsLoadingStateIdle;
        
        if (!error) {
            // Trigger a task details refresh
            [strongSelf refreshTaskDetails];
        } else {
            [strongSelf showGenericNetworkErrorAlertControllerWithMessage:NSLocalizedString(kLocalizationAlertDialogGenericNetworkErrorText, @"Generic network error")];
        }
    }];
}

- (void)unclaimTask {
    self.controllerState = AFATaskDetailsLoadingStateRefreshInProgress;
    
    __weak typeof(self) weakSelf = self;
    [self.dataSource unclaimTaskWithCompletionBlock:^(BOOL isTaskClaimed, NSError *error) {
        __strong typeof(self) strongSelf = weakSelf;
        strongSelf.controllerState = AFATaskDetailsLoadingStateIdle;
        
        if (!error ) {
            // Trigger a task details refresh
            [strongSelf refreshTaskDetails];
        } else {
            [strongSelf showGenericNetworkErrorAlertControllerWithMessage:NSLocalizedString(kLocalizationAlertDialogGenericNetworkErrorText, @"Generic network error")];
        }
    }];
}

- (void)updateChecklistOrder {
    // Mark that a general refresh operation is in progress
    self.controllerState = AFATaskDetailsLoadingStateRefreshInProgress;
    
    __weak typeof(self) weakSelf = self;
    [self.dataSource updateChecklistOrderWithCompletionBlock:^(NSError *error) {
        __strong typeof(self) strongSelf = weakSelf;
        strongSelf.controllerState = AFATaskDetailsLoadingStateIdle;
        
        if (error) {
            [strongSelf showGenericNetworkErrorAlertControllerWithMessage:NSLocalizedString(kLocalizationAlertDialogGenericNetworkErrorText, @"Generic network error")];
        }
    }];
}


#pragma mark -
#pragma mark Cell factories and cell actions

- (void)registerCellActions {
    AFATableControllerTaskDetailsCellFactory *detailsCellFactory = [self.dataSource cellFactoryForSectionType:AFATaskDetailsSectionTypeTaskDetails];
    AFATaskChecklistCellFactory *checklistCellFactory = [self.dataSource cellFactoryForSectionType:AFATaskDetailsSectionTypeChecklist];
    AFATableControllerContentCellFactory *contentCellFactory = [self.dataSource cellFactoryForSectionType:AFATaskDetailsSectionTypeFilesContent];
    AFATableControllerTaskContributorsCellFactory *contributorsCellFactory = [self.dataSource cellFactoryForSectionType:AFATaskDetailsSectionTypeContributors];
    
    // Certain actions are performed for completed or ongoing tasks so there is no reason to
    // register all of them at all times
    AFATableControllerTaskDetailsModel *taskDetailsModel = [self.dataSource reusableTableControllerModelForSectionType:AFATaskDetailsSectionTypeTaskDetails];
    __weak typeof(self) weakSelf = self;
    if ([taskDetailsModel isCompletedTask]) {
        [detailsCellFactory registerCellAction:^(NSDictionary *changeParameters) {
            __strong typeof(self) strongSelf = weakSelf;
            
            [strongSelf.contentPickerViewController downloadAuditLogForTaskWithID:strongSelf.dataSource.taskID
                                                               allowCachedResults:YES];
        } forCellType:[detailsCellFactory cellTypeForAuditLogCell]];
        
        
    } else {
        [detailsCellFactory registerCellAction:^(NSDictionary *changeParameters) {
            __strong typeof(self) strongSelf = weakSelf;
            
            [strongSelf performSegueWithIdentifier:kSegueIDTaskDetailsAddContributor
                                            sender:nil];
        } forCellType:[detailsCellFactory cellTypeForReAssignCell]];
        
        [detailsCellFactory registerCellAction:^(NSDictionary *changeParameters) {
            // Pick date cell action
            __strong typeof(self) strongSelf = weakSelf;
            
            // Display the date picker
            [strongSelf toggleDatePickerComponent];
            
            [strongSelf.datePicker setDate:[strongSelf.dataSource taskDueDate]
                                  animated:YES];
            [strongSelf.taskDetailsTableView reloadData];
        } forCellType:[detailsCellFactory cellTypeForDueDateCell]];
        
        [detailsCellFactory registerCellAction:^(NSDictionary *changeParameters) {
            __strong typeof(self) strongSelf = weakSelf;
            
            [strongSelf completeTask];
        } forCellType:[detailsCellFactory cellTypeForCompleteCell]];
        
        [detailsCellFactory registerCellAction:^(NSDictionary *changeParameters) {
            __strong typeof(self) strongSelf = weakSelf;
            
            [strongSelf claimTask];
        } forCellType:[detailsCellFactory cellTypeForClaimCell]];
        
        [detailsCellFactory registerCellAction:^(NSDictionary *changeParameters) {
            __strong typeof(self) strongSelf = weakSelf;
            
            [strongSelf unclaimTask];
        } forCellType:[detailsCellFactory cellTypeForRequeueCell]];
        
        [contributorsCellFactory registerCellAction:^(NSDictionary *changeParameters) {
            __strong typeof(self) strongSelf = weakSelf;
            
            NSInteger contributorToDeleteIdx = [changeParameters[kCellFactoryCellParameterCellIdx] integerValue];
            ASDKModelUser *contributorToDelete = [strongSelf.dataSource involvedUserAtIndex:contributorToDeleteIdx];
            
            [strongSelf showConfirmationAlertControllerWithMessage:[NSString stringWithFormat:NSLocalizedString(kLocalizationAlertDialogDeleteContributorQuestionFormat, @"Delete contributor confirmation question"), [contributorToDelete normalisedName]]
                                           confirmationBlockAction:^{
                                               [weakSelf onRemoveInvolvedUserForCurrentTask:contributorToDelete];
                                           }];
        } forCellType:[contributorsCellFactory cellTypeForDeleteContributor]];
        
        [checklistCellFactory registerCellAction:^(NSDictionary *changeParameters) {
            __strong typeof(self) strongSelf = weakSelf;
            
            // Make the confirm overlay visible
            if (strongSelf.confirmationView.hidden) {
                [strongSelf toggleConfirmationOverlayView];
                strongSelf.longPressGestureRecognizer.enabled = NO;
            }
        } forCellType:[checklistCellFactory cellTypeForReorder]];
        
        [contentCellFactory registerCellAction:^(NSDictionary *changeParameters) {
            // Cell content delete action
            __strong typeof(self) strongSelf = weakSelf;
            
            NSInteger contentToDeleteIdx = [changeParameters[kCellFactoryCellParameterCellIdx] integerValue];
            [strongSelf showConfirmationAlertControllerWithMessage:[NSString stringWithFormat:NSLocalizedString(kLocalizationAlertDialogDeleteContentQuestionFormat, @"Delete confirmation question"), [strongSelf.dataSource attachedContentAtIndex:contentToDeleteIdx].contentName]
                                           confirmationBlockAction:^{
                                               [weakSelf onContentDeleteForTaskAtIndex:contentToDeleteIdx];
                                           }];
        } forCellType:[contentCellFactory cellTypeForDeleteContent]];
    }
    
    [detailsCellFactory registerCellAction:^(NSDictionary *changeParameters) {
        __strong typeof(self) strongSelf = weakSelf;
        
        if (AFATaskDetailsPartOfCellTypeProcess == [changeParameters[kCellFactoryCellParameterActionType] intValue]) {
            [strongSelf performSegueWithIdentifier:kSegueIDTaskDetailsViewProcess
                                            sender:nil];
        } else {
            [strongSelf performSegueWithIdentifier:kSegueIDTaskDetailsViewTask
                                            sender:nil];
        }
    } forCellType:[detailsCellFactory cellTypeForPartOfCell]];
    
    [detailsCellFactory registerCellAction:^(NSDictionary *changeParameters) {
        [self onSectionSwitch:self.taskFormButton];
    } forCellType:[detailsCellFactory cellTypeForAttachedFormCell]];
    
    // Cell content download action
    [contentCellFactory registerCellAction:^(NSDictionary *changeParameters) {
        // It is possible that at the time of the download request the content's availability status
        // is changed. We perform an additional refresh once content is requested to be downloaded
        // so it's status has the latest value
        __strong typeof(self) strongSelf = weakSelf;
        NSInteger contentToDownloadIdx = ((NSIndexPath *)changeParameters[kCellFactoryCellParameterCellIndexpath]).row;
        
        strongSelf.controllerState = AFATaskDetailsLoadingStateRefreshInProgress;
        [strongSelf.dataSource taskContentWithCompletionBlock:^(NSError *error) {
            [weakSelf handleContentDownloadwithErrorStatus:error
                                            forCellAtIndex:contentToDownloadIdx];
        } cachedResultsBlock:^(NSError *error) {
            [weakSelf handleContentDownloadwithErrorStatus:error
                                            forCellAtIndex:contentToDownloadIdx];
        }];
    } forCellType:[contentCellFactory cellTypeForDownloadContent]];
}


#pragma mark -
#pragma mark Content handling

- (void)handleTaskDetailsResponseWithErrorStatus:(NSError *)error
                             registerCellActions:(BOOL)registerCellActions {
    AFATableControllerTaskDetailsModel *taskDetailsModel = [self.dataSource reusableTableControllerModelForSectionType:AFATaskDetailsSectionTypeTaskDetails];
    
    if (registerCellActions) {
        [self registerCellActions];
    }
    
    if (!error) {
        // For ad-hoc tasks expose an edit button option
        if ([taskDetailsModel isAdhocTask] && ![taskDetailsModel isCompletedTask]) {
            self.navigationItem.rightBarButtonItem = self.editBarButtonItem;
        }
        
        // Enable the task form button if the task has a form key defined
        // and if it's the case, the task has been claimed in advance
        BOOL isFormSectionEnabled = YES;
        if (![taskDetailsModel isFormDefined]) {
            isFormSectionEnabled = NO;
        } else {
            if (![taskDetailsModel isCompletedTask] && [taskDetailsModel isClaimableTask]) {
                isFormSectionEnabled = NO;
            }
        }
        self.taskFormButton.enabled = isFormSectionEnabled;
        
        [self.taskDetailsTableView reloadData];
        
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
    
#warning handle error when loading task details
    
    [self endRefreshOnRefreshControl];
    
    BOOL isContentAvailable = taskDetailsModel.currentTask ? YES : NO;
    self.controllerState = isContentAvailable ? AFATaskDetailsLoadingStateIdle : AFATaskDetailsLoadingStateEmptyList;
}

- (void)handleTaskContributorsListResponseWithErrorStatus:(NSError *)error {
    AFATableControllerTaskContributorsModel *taskContributorsModel = [self.dataSource reusableTableControllerModelForSectionType:AFATaskDetailsSectionTypeContributors];
    
    if (!error) {
        [self.taskDetailsTableView reloadData];
        
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
    
    AFATableControllerTaskDetailsModel *taskDetailsModel = [self.dataSource reusableTableControllerModelForSectionType:AFATaskDetailsSectionTypeTaskDetails];
    self.noContentView.iconImageView.image = [UIImage imageNamed:@"contributors-large-icon"];
    self.noContentView.descriptionLabel.text = [taskDetailsModel isCompletedTask] ? NSLocalizedString(kLocalizationNoContentScreenContributorsNotEditableText, @"No contributors available not editable text") : NSLocalizedString(kLocalizationNoContentScreenContributorsText, @"No contributors available text");
    
    [self endRefreshOnRefreshControl];
    
    BOOL isContentAvailable = taskContributorsModel.involvedPeople.count ? YES : NO;
    self.controllerState = isContentAvailable ? AFATaskDetailsLoadingStateIdle : AFATaskDetailsLoadingStateEmptyList;
}

- (void)handleTaskContentListResponseWithErrorStatus:(NSError *)error {
    AFATableControllerContentModel *taskContentModel = [self.dataSource reusableTableControllerModelForSectionType:AFATaskDetailsSectionTypeFilesContent];
    
    if (!error) {
        [self.taskDetailsTableView reloadData];
        
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
    
    AFATableControllerTaskDetailsModel *taskDetailsModel = [self.dataSource reusableTableControllerModelForSectionType:AFATaskDetailsSectionTypeTaskDetails];
    
    self.noContentView.iconImageView.image = [UIImage imageNamed:@"documents-large-icon"];
    self.noContentView.descriptionLabel.text = [taskDetailsModel isCompletedTask] ? NSLocalizedString(kLocalizationNoContentScreenFilesNotEditableText, @"No files available not editable") :  NSLocalizedString(kLocalizationNoContentScreenFilesText, @"No files available text");
    
    [self endRefreshOnRefreshControl];
    
    BOOL isContentAvailable = taskContentModel.attachedContentArr.count ? YES : NO;
    self.controllerState = isContentAvailable ? AFATaskDetailsLoadingStateIdle : AFATaskDetailsLoadingStateEmptyList;
}

- (void)handleTaskCommentListResponseWithErrorStatus:(NSError *)error {
    AFATableControllerCommentModel *commentModel = [self.dataSource reusableTableControllerModelForSectionType:AFATaskDetailsSectionTypeComments];
    
    if (!error) {
        [self.taskDetailsTableView reloadData];
        
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
    
    AFATableControllerTaskDetailsModel *taskDetailsModel = [self.dataSource reusableTableControllerModelForSectionType:AFATaskDetailsSectionTypeTaskDetails];
    
    self.noContentView.iconImageView.image = [UIImage imageNamed:@"comments-large-icon"];
    self.noContentView.descriptionLabel.text = [taskDetailsModel isCompletedTask] ? NSLocalizedString(kLocalizationNoContentScreenCommentsNotEditableText, @"No comments available not editable text") : NSLocalizedString(kLocalizationNoContentScreenCommentsText, @"No comments available text") ;
    
    [self endRefreshOnRefreshControl];
    
    BOOL isContentAvailable = commentModel.commentListArr.count ? YES : NO;
    self.controllerState = isContentAvailable ? AFATaskDetailsLoadingStateIdle : AFATaskDetailsLoadingStateEmptyList;
}

- (void)handleTaskChecklistResponseWithErrorStatus:(NSError *)error {
    AFATableControllerChecklistModel *taskChecklistModel = [self.dataSource reusableTableControllerModelForSectionType:AFATaskDetailsSectionTypeChecklist];
    
    if (!error) {
        [self.taskDetailsTableView reloadData];
        
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
    
    AFATableControllerTaskDetailsModel *taskDetailsModel = [self.dataSource reusableTableControllerModelForSectionType:AFATaskDetailsSectionTypeTaskDetails];
    
    self.noContentView.iconImageView.image = [UIImage imageNamed:@"checklist-large-icon"];
    self.noContentView.descriptionLabel.text = [taskDetailsModel isCompletedTask] ? NSLocalizedString(kLocalizationNoContentScreenChecklistNotEditableText, @"No comments available not editable text") : NSLocalizedString(kLocalizationNoContentScreenChecklistEditableText, @"No comments available text");
    
    [self endRefreshOnRefreshControl];
    
    BOOL isContentAvailable = taskChecklistModel.checklistArr.count ? YES : NO;
    self.controllerState = isContentAvailable ? AFATaskDetailsLoadingStateIdle : AFATaskDetailsLoadingStateEmptyList;
}

- (void)handleContentDownloadwithErrorStatus:(NSError *)error
                              forCellAtIndex:(NSInteger)contentIndex
{
    if (!error) {
        [self.contentPickerViewController dowloadContent:[self.dataSource attachedContentAtIndex:contentIndex]
                                      allowCachedContent:YES];
    } else {
        if (error.code == NSURLErrorNotConnectedToInternet) {
            [self showWarningMessage:NSLocalizedString(kLocalizationOfflineProvidingCachedResultsText, @"Cached results text")];
        } else {
            [self showErrorMessage:NSLocalizedString(kLocalizationAlertDialogTaskContentFetchErrorText, @"Content fetching error")];
        }
    }
    
    self.controllerState = AFATaskDetailsLoadingStateIdle;
}


#pragma mark -
#pragma mark Convenience methods

- (void)setupLocalization {
    self.navigationBarTitle = NSLocalizedString(kLocalizationTaskDetailsScreenTaskDetailsTitleText, @"Task details title");
    [self.backBarButtonItem setTitleTextAttributes:@{NSFontAttributeName           : [UIFont glyphiconFontWithSize:15],
                                                     NSForegroundColorAttributeName: [UIColor whiteColor]}
                                          forState:UIControlStateNormal];
    self.backBarButtonItem.title = [NSString iconStringForIconType:ASDKGlyphIconTypeChevronLeft];
}

- (UIButton *)buttonForSection:(AFATaskDetailsSectionType)sectionType {
    switch (sectionType) {
        case AFATaskDetailsSectionTypeTaskDetails: {
            return self.taskDetailsButton;
        }
            break;
            
        case AFATaskDetailsSectionTypeForm: {
            return self.taskFormButton;
        }
            break;
            
        case AFATaskDetailsSectionTypeChecklist: {
            return self.taskChecklistButton;
        }
            break;
            
        case AFATaskDetailsSectionTypeFilesContent: {
            return self.taskContentButton;
        }
            break;
            
        case AFATaskDetailsSectionTypeContributors: {
            return self.taskContributorsButton;
        }
            break;
            
        case AFATaskDetailsSectionTypeComments: {
            return self.taskCommentsButton;
        }
            
        default: {
            return nil;
        }
            break;
    }
}

- (void)updateTaskDueDateWithDate:(NSDate *)date {
    [self.dataSource updateTaskDueDateWithDate:date];
    
    // Trigger an update request
    [self updateTaskDetails];
    
    // Dismiss the date picker
    [self toggleDatePickerComponent];
    [self.taskDetailsTableView reloadData];
}

- (BOOL)isDueDatePickerVisible {
    return !self.datePickerBottomConstraint.constant ? YES : NO;
}


- (void)toggleFullscreenOverlayView {
    CGFloat alphaValue = !self.fullScreenOverlayView.alpha ? .4f : .0f;
    if (alphaValue) {
        self.fullScreenOverlayView.hidden = NO;
    }
    
    [UIView animateWithDuration:kDefaultAnimationTime animations:^{
        self.fullScreenOverlayView.alpha = alphaValue;
    } completion:^(BOOL finished) {
        if (!alphaValue) {
            self.fullScreenOverlayView.hidden = YES;
        }
    }];
}

- (void)toggleConfirmationOverlayView {
    CGFloat alphaValue = !self.confirmationView.alpha ? 1.0f : .0f;
    if (alphaValue) {
        self.confirmationView.hidden = NO;
    }
    
    [UIView animateWithDuration:kDefaultAnimationTime animations:^{
        self.confirmationView.alpha = alphaValue;
    } completion:^(BOOL finished) {
        if (!alphaValue) {
            self.confirmationView.hidden = YES;
        }
    }];
}

- (void)toggleDatePickerComponent {
    // Check whether the date picker component is initialized
    if (!self.datePicker) {
        self.datePicker = [UIDatePicker new];
        self.datePicker.datePickerMode = UIDatePickerModeDate;
        [self.datePickerContainerView addSubview:self.datePicker];
        
        NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:self.datePicker
                                                                         attribute:NSLayoutAttributeTop
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.datePickerContainerView
                                                                         attribute:NSLayoutAttributeTop
                                                                        multiplier:1
                                                                          constant:0];
        NSLayoutConstraint *leadingConstraint = [NSLayoutConstraint constraintWithItem:self.datePicker
                                                                             attribute:NSLayoutAttributeLeading
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                toItem:self.datePickerContainerView
                                                                             attribute:NSLayoutAttributeLeading
                                                                            multiplier:1
                                                                              constant:0];
        
        [NSLayoutConstraint activateConstraints:@[leadingConstraint, topConstraint]];
    }
    
    NSInteger datePickerConstant = 0;
    NSInteger taskDetailsTableViewTopConstant = 0;
    if (!self.datePickerBottomConstraint.constant) {
        if (@available(iOS 11, *)) {
            datePickerConstant = -(self.datepickerHeightConstraint.constant + CGRectGetHeight(self.datePickerToolbar.frame) + self.view.safeAreaInsets.bottom);
        } else {
            datePickerConstant = -(self.datepickerHeightConstraint.constant + CGRectGetHeight(self.datePickerToolbar.frame) + 10);
        }
    } else {
        if (self.taskDetailsTableView.contentSize.height + CGRectGetHeight(self.datePicker.frame) + CGRectGetHeight(self.datePickerToolbar.frame) - 10 > CGRectGetHeight(self.view.frame)) {
            taskDetailsTableViewTopConstant = -CGRectGetHeight(self.datePicker.frame) / 2;
        }
    }
    
    [self.view layoutIfNeeded];
    [UIView animateWithDuration:kDefaultAnimationTime
                          delay:0
         usingSpringWithDamping:.9f
          initialSpringVelocity:20.0f
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.datePickerBottomConstraint.constant = datePickerConstant;
                         self.taskDetailsTableViewTopConstraint.constant = taskDetailsTableViewTopConstant;
                         [self.view layoutIfNeeded];
                     } completion:nil];
}

- (void)toggleContentPickerComponent {
    NSInteger contentPickerConstant = 0;
    if (!self.contentPickerContainerBottomConstraint.constant) {
        if (@available(iOS 11.0, *)) {
            self.contentPickerContainerHeightConstraint.constant = self.initialContentPickerContainerHeight + self.view.safeAreaInsets.bottom;
            contentPickerConstant = self.contentPickerContainerHeightConstraint.constant;
        } else {
            contentPickerConstant = self.contentPickerContainerHeightConstraint.constant;
        }
    }
    
    // Show the content picker container
    if (contentPickerConstant) {
        self.contentPickerContainer.hidden = NO;
    }
    
    [self.view layoutIfNeeded];
    [UIView animateWithDuration:kDefaultAnimationTime
                          delay:0
         usingSpringWithDamping:.95f
          initialSpringVelocity:20.0f
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.contentPickerContainerBottomConstraint.constant = contentPickerConstant;
                         [self.view layoutIfNeeded];
                     } completion:^(BOOL finished) {
                         if (!contentPickerConstant) {
                             self.contentPickerContainer.hidden = YES;
                         }
                     }];
}

- (void)endRefreshOnRefreshControl {
    __weak typeof(self) weakSelf = self;
    [[NSOperationQueue currentQueue] addOperationWithBlock:^{
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf.refreshControl endRefreshing];
    }];
}


#pragma mark -
#pragma mark AFAContentPickerViewController Delegate

- (void)userPickedImageAtURL:(NSURL *)imageURL {
    [self onFullscreenOverlayTap:nil];
}

- (void)userDidCancelImagePick {
    [self onFullscreenOverlayTap:nil];
}

- (void)pickedContentHasFinishedUploading {
    [self refreshContentForCurrentSection];
    [self.taskDetailsTableView reloadData];
}

- (void)userPickedImageFromCamera {
    [self onFullscreenOverlayTap:nil];
}

- (void)pickedContentHasFinishedDownloadingAtURL:(NSURL *)downloadedFileURL {
}

- (void)contentPickerHasBeenPresentedWithNumberOfOptions:(NSUInteger)contentOptionCount
                                              cellHeight:(CGFloat)cellHeight {
    self.contentPickerContainerHeightConstraint.constant = contentOptionCount * cellHeight;
    self.initialContentPickerContainerHeight = self.contentPickerContainerHeightConstraint.constant;
}

- (void)userPickerIntegrationAccount:(ASDKModelIntegrationAccount *)integrationAccount {
    [self onFullscreenOverlayTap:nil];
    
    // Initialize the browsing controller at a top network level based on the selected integration account
    if ([kASDKAPIServiceIDAlfrescoCloud isEqualToString:integrationAccount.integrationServiceID]) {
        ASDKIntegrationNetworksDataSource *dataSource = [[ASDKIntegrationNetworksDataSource alloc] initWithIntegrationAccount:integrationAccount];
        self.integrationBrowsingController = [[ASDKIntegrationBrowsingViewController alloc] initBrowserWithDataSource:dataSource];
        self.integrationBrowsingController.delegate = self;
    } else {
        self.integrationBrowsingController = nil;
    }
    
    // If the controller has been successfully initiated present it
    if (self.integrationBrowsingController) {
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self.integrationBrowsingController];
        
        [self presentViewController:navigationController
                           animated:YES
                         completion:nil];
    }
}


#pragma mark -
#pragma mark AFATaskFormViewControllerDelegate

- (void)formDidLoadWithError:(NSError *)error {
    if (!error &&
        [self.taskFormViewController.taskFormRenderEngine.actionHandler isSaveFormActionAvailable]) {
        UIBarButtonItem *saveBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"save-icon"]
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(onFormSave)];
        saveBarButtonItem.tintColor = [UIColor whiteColor];
        self.navigationItem.rightBarButtonItem = saveBarButtonItem;
    }
}

- (void)userDidCompleteForm {
    [self onBack:nil];
}

- (void)presentFormDetailController:(UIViewController *)controller {
    // If no back button is provided by the sdk for the controller to be presented
    // then add a default one with a simple pop action
    if (!controller.navigationItem.leftBarButtonItem) {
        UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:[NSString iconStringForIconType:ASDKGlyphIconTypeChevronLeft]
                                                                       style:UIBarButtonItemStylePlain
                                                                      target:self
                                                                      action:@selector(popFormDetailController)];
        [backButton setTitleTextAttributes:@{NSFontAttributeName           : [UIFont glyphiconFontWithSize:15],
                                             NSForegroundColorAttributeName: [UIColor whiteColor]}
                                  forState:UIControlStateNormal];
        controller.navigationItem.leftBarButtonItem = backButton;
    }
    
    [self.navigationController pushViewController:controller
                                         animated:YES];
}

- (UINavigationController *)formNavigationController {
    return self.navigationController;
}

- (void)popFormDetailController {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)formDidLoadPrerequisitesWithError:(NSError *)error {
    self.controllerState = AFATaskDetailsLoadingStateIdle;
}


#pragma mark -
#pragma mark ASDKIntegrationBrowsingDelegate

- (void)didPickContentNodeWithRepresentation:(ASDKIntegrationNodeContentRequestRepresentation *)nodeContentRepresentation {
    __weak typeof(self) weakSelf = self;
    [self.dataSource uploadIntegrationContentForNode:nodeContentRepresentation
                                 withCompletionBlock:^(NSError *error) {
                                     __strong typeof(self) strongSelf = weakSelf;
                                     
                                     if (!error) {
                                         [strongSelf pickedContentHasFinishedUploading];
                                     } else {
                                         [strongSelf showGenericNetworkErrorAlertControllerWithMessage:NSLocalizedString(kLocalizationAlertDialogTaskContentUploadErrorText, @"Content upload error")];
                                     }
                                 }];
}


#pragma mark -
#pragma mark AFAConfirmationViewDelegate

- (void)didConfirmAction {
    [self.taskDetailsTableView setEditing:NO
                                 animated:YES];
    [self toggleConfirmationOverlayView];
    [self updateChecklistOrder];
    self.longPressGestureRecognizer.enabled = YES;
}


#pragma mark -
#pragma mark AFAModalTaskDetailsViewControllerDelegate

- (void)didCreateTask:(ASDKModelTask *)task {
    [self refreshTaskChecklist];
}

- (void)didUpdateCurrentTask {
    [self refreshContentForCurrentSection];
}


#pragma mark -
#pragma mark AFAModalPeoplePickerViewControllerDelegate

- (void)didInvolveUserWithEmailAddress:(NSString *)emailAddress {
    [self refreshContentForCurrentSection];
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
                                 __strong typeof(self) strongSelf = weakSelf;
                                 AFATaskDetailsLoadingState controllerState = [change[NSKeyValueChangeNewKey] integerValue];
                                 
                                 // Update progress status for underlaying models
                                 if ([self.dataSource.tableController.model respondsToSelector:@selector(isRefreshInProgress)]) {
                                     BOOL isRefreshInProgress = (AFATaskDetailsLoadingStateRefreshInProgress == controllerState) ? YES : NO;
                                     ((AFATableControllerContentModel *)strongSelf.dataSource.tableController.model).isRefreshInProgress = isRefreshInProgress;
                                 }
                                 
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     if (AFATaskDetailsLoadingStateIdle == controllerState) {
                                         weakSelf.loadingActivityView.hidden = YES;
                                         weakSelf.loadingActivityView.animating = NO;
                                         weakSelf.taskDetailsTableView.hidden = NO;
                                         weakSelf.noContentView.hidden = YES;
                                     } else if (AFATaskDetailsLoadingStateRefreshInProgress == controllerState) {
                                         weakSelf.loadingActivityView.hidden = NO;
                                         weakSelf.loadingActivityView.animating = YES;
                                         weakSelf.taskDetailsTableView.hidden = YES;
                                         weakSelf.noContentView.hidden = YES;
                                     } else if (AFATaskDetailsLoadingStateEmptyList == controllerState) {
                                         weakSelf.loadingActivityView.hidden = YES;
                                         weakSelf.loadingActivityView.animating = NO;
                                         weakSelf.taskDetailsTableView.hidden = YES;
                                         weakSelf.noContentView.hidden = NO;
                                     }
                                 });
                             }];
}

@end

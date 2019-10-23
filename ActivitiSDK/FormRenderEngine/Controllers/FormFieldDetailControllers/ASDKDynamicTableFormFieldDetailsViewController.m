/*******************************************************************************
 * Copyright (C) 2005-2018 Alfresco Software Limited.
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

#import "ASDKDynamicTableFormFieldDetailsViewController.h"
#import "ASDKBootstrap.h"

// Views
#import "ASDKNoContentView.h"
#import "ASDKActivityView.h"

// Constants
#import "ASDKFormRenderEngineConstants.h"
#import "ASDKLocalizationConstants.h"

// Categories
#import "UIViewController+ASDKAlertAddition.h"

// Models
#import "ASDKModelDynamicTableColumnDefinitionFormField.h"
#import "ASDKModelDynamicTableFormField.h"
#import "ASDKModelFormFieldValue.h"

// Cells
#import "ASDKDynamicTableRowHeaderTableViewCell.h"
#import "ASDKDynamicTableColumnTableViewCell.h"

// Protocols
#import "ASDKFormCellProtocol.h"


static const int activitiSDKLogLevel = ASDK_LOG_LEVEL_VERBOSE; // | ASDK_LOG_FLAG_TRACE;

@interface ASDKDynamicTableFormFieldDetailsViewController () <ASDKFormRenderEngineDelegate>

@property (weak, nonatomic) IBOutlet UITableView        *rowsWithVisibleColumnsTableView;
@property (weak, nonatomic) IBOutlet ASDKNoContentView  *noRowsView;
@property (weak, nonatomic) IBOutlet ASDKActivityView   *activityView;

@property (strong, nonatomic) ASDKModelFormField        *currentFormField;
@property (assign, nonatomic) NSInteger                 selectedRowIndex;
@property (strong, nonatomic) NSArray                   *visibleRowColumns;
@property (strong, nonatomic) NSDictionary              *columnDefinitions;
@property (strong, nonatomic) ASDKFormRenderEngine      *dynamicTableRenderEngine;

- (IBAction)addDynamicTableRow:(id)sender;
- (void)deleteCurrentDynamicTableRow;

@end

@implementation ASDKDynamicTableFormFieldDetailsViewController


#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Update the navigation bar title
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = self.currentFormField.fieldName;
    titleLabel.font = [UIFont fontWithName:@"Avenir-Book"
                                      size:17];
    titleLabel.textColor = [UIColor whiteColor];
    [titleLabel sizeToFit];
    self.navigationItem.titleView = titleLabel;
    
    // Configure table view
    self.rowsWithVisibleColumnsTableView.estimatedRowHeight = 44.0f;
    self.rowsWithVisibleColumnsTableView.rowHeight = UITableViewAutomaticDimension;
    
    // Remove add row button for completed forms
    if (ASDKModelFormFieldRepresentationTypeReadOnly == self.currentFormField.representationType) {
        self.navigationItem.rightBarButtonItem = nil;
        self.noRowsView.descriptionLabel.text = ASDKLocalizedStringFromTable(kLocalizationDynamicTableNoRowsNotEditableText, ASDKLocalizationTable, @"No rows, not editable text");
    } else {
        self.noRowsView.descriptionLabel.text = ASDKLocalizedStringFromTable(kLocalizationDynamicTableNoRowsText, ASDKLocalizationTable, @"No rows text");
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self refreshContent];
}


#pragma mark -
#pragma mark Actions

- (void)validateDynamicTableEntriesForCurrentRowAndPopController {
    NSArray *currentDynamicTableRowFormFields = self.currentFormField.values[self.selectedRowIndex];
    BOOL areDynamicTableRowEntriesValid = YES;
    
    for (ASDKModelDynamicTableColumnDefinitionFormField *rowFormField in currentDynamicTableRowFormFields) {
        BOOL hasValueDefined = (rowFormField.metadataValue.attachedValue.length ||
                                rowFormField.values.count ||
                                rowFormField.metadataValue.option) ? YES : NO;
        
        if (rowFormField.isRequired && !hasValueDefined) {
            areDynamicTableRowEntriesValid = NO;
            break;
        }
    }
    
    if (!areDynamicTableRowEntriesValid) {
        UIAlertController *requiredFieldsAlertController = [UIAlertController alertControllerWithTitle:nil
                                                                                               message:ASDKLocalizedStringFromTable(kLocalizationDynamicTableIncompleteRowDataText, ASDKLocalizationTable, @"Incomplete row warning")
                                                                                        preferredStyle:UIAlertControllerStyleAlert];
        __weak typeof(self) weakSelf = self;
        UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:ASDKLocalizedStringFromTable(kLocalizationFormAlertDialogYesButtonText, ASDKLocalizationTable, @"YES button title")
                                                                style:UIAlertActionStyleDestructive
                                                              handler:^(UIAlertAction * _Nonnull action) {
                                                                  __strong typeof(self) strongSelf = weakSelf;
                                                                  
                                                                  NSMutableArray *rowEntries = [NSMutableArray arrayWithArray:self.currentFormField.values];
                                                                  [rowEntries removeObjectAtIndex:strongSelf.selectedRowIndex];
                                                                  strongSelf.currentFormField.values = [NSArray arrayWithArray:rowEntries];
                                                                  
                                                                  [[self.navigationDelegate formNavigationController] popViewControllerAnimated:YES];
                                                              }];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:ASDKLocalizedStringFromTable(kLocalizationCancelButtonText, ASDKLocalizationTable, @"Cancel button title") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        
        [requiredFieldsAlertController addAction:confirmAction];
        [requiredFieldsAlertController addAction:cancelAction];
        
        [[self.navigationDelegate formNavigationController] presentViewController:requiredFieldsAlertController
                                                                         animated:YES
                                                                       completion:nil];
    } else {
        [[self.navigationDelegate formNavigationController] popViewControllerAnimated:YES];
    }
}

- (IBAction)addDynamicTableRow:(id)sender {
    ASDKModelDynamicTableFormField *dynamicTableFormField = (ASDKModelDynamicTableFormField *) self.currentFormField;
    NSMutableArray *newDynamicTableRows = [NSMutableArray new];
    if (self.currentFormField.values) {
        [newDynamicTableRows addObjectsFromArray:dynamicTableFormField.values];
    }
    
    // make deepcopy of column definitions
    NSError *error = nil;
    NSData *buffer = [NSKeyedArchiver archivedDataWithRootObject:dynamicTableFormField.columnDefinitions
                                           requiringSecureCoding:NO
                                                           error:&error];
    NSArray* dynamicTableDeepCopy = [NSKeyedUnarchiver unarchivedObjectOfClass:NSArray.class
                                                                      fromData:buffer
                                                                         error:&error];
    if (error) {
        ASDKLogError(@"Encountered an error while un/archiving the column definitions");
    }
    
    
    // and add them as a new table row
    [newDynamicTableRows addObject:dynamicTableDeepCopy];
    
    self.currentFormField.values = [[NSMutableArray alloc] initWithArray:newDynamicTableRows];
    [self determineVisibleRowColumnsWithFormFieldValues:self.currentFormField.values];
    
    NSUInteger sectionIdxForAddedElement = [newDynamicTableRows indexOfObject:dynamicTableDeepCopy];
    [self didEditRow:sectionIdxForAddedElement];
}

- (void)deleteCurrentDynamicTableRow {
    __weak typeof(self) weakSelf = self;
    
    [self showConfirmationAlertControllerWithMessage:ASDKLocalizedStringFromTable(kLocalizationFormDynamicTableDeleteRowConfirmationText, ASDKLocalizationTable,@"Delete row confirmation question")
                             confirmationBlockAction:^{
                                 __strong typeof(self) strongSelf = weakSelf;
                                 
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     NSMutableArray *formFieldValues = [NSMutableArray arrayWithArray:strongSelf.currentFormField.values];
                                     [formFieldValues removeObjectAtIndex:strongSelf.selectedRowIndex];
                                     strongSelf.currentFormField.values = [formFieldValues copy];
                                     [strongSelf determineVisibleRowColumnsWithFormFieldValues:strongSelf.currentFormField.values];
                                     [strongSelf.navigationController popToViewController:strongSelf
                                                                                 animated:YES];
                                 });
                             }];
}


#pragma mark -
#pragma mark ASDKFormFieldDetailsControllerProtocol

- (void)setupWithFormFieldModel:(ASDKModelFormField *)formFieldModel {
    self.currentFormField = formFieldModel;
}


#pragma mark -
#pragma mark  ASDKFormRenderEngineDelegate

- (void)didRenderedFormController:(UICollectionViewController<ASDKFormControllerNavigationProtocol> *)formController
                            error:(NSError *)error {
    if (formController && !error) {
        if (ASDKModelFormFieldRepresentationTypeReadOnly != self.currentFormField.representationType) {
            formController.navigationItem.rightBarButtonItem = [self deleteRowBarButtonItemForDynamicTableController];
        }
        formController.navigationItem.titleView = [self dynamicTableControllerTitleViewForRow:self.selectedRowIndex];
        formController.navigationItem.leftBarButtonItem = [self dynamicTableControllerBackBarButtonItem];
        
        // If there is controller assigned to the selected form field notify the delegate
        // that it can begin preparing for presentation
        formController.navigationDelegate = self.navigationDelegate;
        [self.navigationDelegate prepareToPresentDetailController:formController];
    }
    
    self.activityView.animating = NO;
    self.activityView.hidden = YES;
}

- (void)didCompleteFormWithError:(NSError *)error {
    // Delete current row
    NSMutableArray *formFieldValues = [NSMutableArray arrayWithArray:self.currentFormField.values];
    [formFieldValues removeObjectAtIndex:self.selectedRowIndex];
    self.currentFormField.values = [formFieldValues copy];
    [self determineVisibleRowColumnsWithFormFieldValues:self.currentFormField.values];
    [self.navigationController popToViewController:self
                                          animated:YES];
}


#pragma mark -
#pragma mark UITableView Delegate & Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.visibleRowColumns.count;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    NSArray *rowsInSection = [self.visibleRowColumns objectAtIndex:section];
    return rowsInSection.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ASDKDynamicTableColumnTableViewCell *visibleColumnCell = [tableView dequeueReusableCellWithIdentifier:kASDKCellIDFormFieldDynamicTableRowRepresentation];
    
    ASDKModelFormField *rowFormField = self.visibleRowColumns[indexPath.section][indexPath.row];
    [visibleColumnCell setupCellWithColumnDefinitionFormField:rowFormField
                                        dynamicTableFormField:(ASDKModelDynamicTableFormField *) self.currentFormField];
    
    return visibleColumnCell;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}


-  (CGFloat)tableView:(UITableView *)tableView
heightForHeaderInSection:(NSInteger)section {
    CGFloat headerHeight = 45.0f;
    return headerHeight;
}

- (UIView *)tableView:(UITableView *)tableView
viewForHeaderInSection:(NSInteger)section {
    ASDKModelDynamicTableFormField *dynamicTableFormField = (ASDKModelDynamicTableFormField *) self.currentFormField;
    
    ASDKDynamicTableRowHeaderTableViewCell *sectionHeaderView = [tableView dequeueReusableCellWithIdentifier:kASDKCellIDFormFieldDynamicTableHeaderRepresentation];
    [sectionHeaderView setupCellWithSelectionSection:section
                                          headerText:[NSString stringWithFormat:ASDKLocalizedStringFromTable(kLocalizationFormDynamicTableRowHeaderText, ASDKLocalizationTable, @"Row header"), section + 1]
                                          isReadOnly:(ASDKModelFormFieldRepresentationTypeReadOnly == dynamicTableFormField.representationType && !dynamicTableFormField.isTableEditable)
                                   navgationDelegate:self];
    
    return sectionHeaderView;
}

#pragma mark -
#pragma mark ASDKDynamicTableRowHeaderNavigationProtocol

- (void)didEditRow:(NSInteger)section {
    // If the user is browsing a completed start form of a process instance then
    // recreate the process definition object from the process instance one
    self.dynamicTableRenderEngine = [self formRenderEngine];
    if (!self.formConfiguration.processDefinition &&
        self.formConfiguration.processInstance) {
        ASDKModelProcessDefinition *processDefinition = [ASDKModelProcessDefinition new];
        processDefinition.modelID = self.formConfiguration.processInstance.processDefinitionID;
        self.dynamicTableRenderEngine.processDefinition = processDefinition;
    } else {
        self.dynamicTableRenderEngine.processDefinition = self.formConfiguration.processDefinition;
    }
    self.dynamicTableRenderEngine.task = self.formConfiguration.task;
    
    self.activityView.hidden = NO;
    self.activityView.animating = YES;
    self.selectedRowIndex = section;
    
    if (self.dynamicTableRenderEngine.task) {
        [self.dynamicTableRenderEngine setupWithDynamicTableRowFormFields:self.currentFormField.values[section]
                                                  dynamicTableFormFieldID:self.currentFormField.modelID
                                                                taskModel:self.dynamicTableRenderEngine.task];
    } else {
        [self.dynamicTableRenderEngine setupWithDynamicTableRowFormFields:self.currentFormField.values[section]
                                                  dynamicTableFormFieldID:self.currentFormField.modelID
                                                        processDefinition:self.dynamicTableRenderEngine.processDefinition];
    }
}


#pragma mark -
#pragma mark Convenience methods

- (ASDKFormRenderEngine *)formRenderEngine {
    dispatch_queue_t formUpdatesProcessingQueue = dispatch_queue_create([[NSString stringWithFormat:@"%@.`%@ProcessingQueue", [NSBundle mainBundle].bundleIdentifier, NSStringFromClass([self class])] UTF8String], DISPATCH_QUEUE_SERIAL);
    
    ASDKBootstrap *sdkBootstrap = [ASDKBootstrap sharedInstance];
    ASDKFormNetworkServices *formNetworkService = [sdkBootstrap.serviceLocator serviceConformingToProtocol:@protocol(ASDKFormNetworkServiceProtocol)];
    formNetworkService.resultsQueue = formUpdatesProcessingQueue;
    
    ASDKFormRenderEngine *formRenderEngine = [[ASDKFormRenderEngine alloc] initWithDelegate:self];
    formRenderEngine.formNetworkServices = formNetworkService;
    
    return formRenderEngine;
}

- (void)refreshContent {
    [self determineVisibleRowColumnsWithFormFieldValues:self.currentFormField.values];
    
    // Display the no rows view if appropiate
    self.noRowsView.hidden = (self.visibleRowColumns.count > 0) ? YES : NO;
    self.noRowsView.iconImageView.image = [UIImage imageNamed:@"documents-large-icon"
                                                     inBundle:[NSBundle bundleForClass:self.class]
                                compatibleWithTraitCollection:nil];
    
    [self.rowsWithVisibleColumnsTableView reloadData];
}

- (UIBarButtonItem *)deleteRowBarButtonItemForDynamicTableController {
    UIBarButtonItem *deleteRowBarButtonItem =
    [[UIBarButtonItem alloc] initWithTitle:[NSString iconStringForIconType:ASDKGlyphIconTypeRemove2]
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(deleteCurrentDynamicTableRow)];
    
    [deleteRowBarButtonItem setTitleTextAttributes:
     @{NSFontAttributeName            : [UIFont glyphiconFontWithSize:15],
       NSForegroundColorAttributeName : [UIColor whiteColor]}
                                          forState:UIControlStateNormal];
    
    return deleteRowBarButtonItem;
}

- (void)determineVisibleRowColumnsWithFormFieldValues:(NSArray *)values {
    NSMutableArray *visibleColumnsInRows = [[NSMutableArray alloc] init];
    
    for (NSArray *row in values) {
        NSMutableArray *visibleColumns = [[NSMutableArray alloc] init];
        
        for (id column in row) {
            if ([column respondsToSelector:@selector(visible)]) {
                if ([column performSelector:@selector(visible)]) {
                    [visibleColumns addObject:column];
                }
            }
        }
        [visibleColumnsInRows addObject:visibleColumns];
    }
    
    self.visibleRowColumns = [NSArray arrayWithArray:visibleColumnsInRows];
}

- (UILabel *)dynamicTableControllerTitleViewForRow:(NSInteger)row{
    UILabel *titleLabel = [UILabel new];
    titleLabel.text = [NSString stringWithFormat:ASDKLocalizedStringFromTable(kLocalizationFormDynamicTableRowHeaderText, ASDKLocalizationTable, @"Row header"), row + 1];
    titleLabel.font = [UIFont fontWithName:@"Avenir-Book"
                                      size:17];
    titleLabel.textColor = [UIColor whiteColor];
    [titleLabel sizeToFit];
    
    return titleLabel;
}

- (UIBarButtonItem *)dynamicTableControllerBackBarButtonItem {
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:[NSString iconStringForIconType:ASDKGlyphIconTypeChevronLeft]
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(validateDynamicTableEntriesForCurrentRowAndPopController)];
    [backButton setTitleTextAttributes:@{NSFontAttributeName           : [UIFont glyphiconFontWithSize:15],
                                         NSForegroundColorAttributeName: [UIColor whiteColor]}
                              forState:UIControlStateNormal];
    return backButton;
}

@end

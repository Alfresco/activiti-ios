/*******************************************************************************
 * Copyright (C) 2005-2016 Alfresco Software Limited.
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

// Cells
#import "ASDKDynamicTableRowHeaderTableViewCell.h"
#import "ASDKDynamicTableColumnTableViewCell.h"

// Protocols
#import "ASDKFormCellProtocol.h"

@interface ASDKDynamicTableFormFieldDetailsViewController ()

@property (weak, nonatomic) IBOutlet UITableView        *rowsWithVisibleColumnsTableView;
@property (weak, nonatomic) IBOutlet ASDKNoContentView  *noRowsView;
@property (weak, nonatomic) IBOutlet ASDKActivityView   *activityView;
@property (weak, nonatomic) IBOutlet UIView             *blurEffectView;

@property (strong, nonatomic) ASDKModelFormField        *currentFormField;
@property (assign, nonatomic) NSInteger                 selectedRowIndex;
@property (strong, nonatomic) NSArray                   *visibleRowColumns;
@property (strong, nonatomic) NSDictionary              *columnDefinitions;

- (IBAction)addDynamicTableRow:(id)sender;
- (void)deleteCurrentDynamicTableRow;

@end

@implementation ASDKDynamicTableFormFieldDetailsViewController

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
        self.noRowsView.descriptionLabel.text = ASDKLocalizedStringFromTable(kLocalizationDynamicTableNoRowsNotEditable, ASDKLocalizationTable, @"No rows, not editable text");
    } else {
        self.noRowsView.descriptionLabel.text = ASDKLocalizedStringFromTable(kLocalizationDynamicTableNoRows, ASDKLocalizationTable, @"No rows text");
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [self refreshContent];
}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (void)refreshContent {
    [self determineVisibleRowColumnsWithFormFieldValues:self.currentFormField.values];
    
    // Display the no rows view if appropiate
    self.noRowsView.hidden = (self.visibleRowColumns.count > 0) ? YES : NO;
    self.noRowsView.iconImageView.image = [UIImage imageNamed:@"documents-large-icon"
                                                     inBundle:[NSBundle bundleForClass:self.class]
                                compatibleWithTraitCollection:nil];
    
    [self.rowsWithVisibleColumnsTableView reloadData];
}

- (IBAction)addDynamicTableRow:(id)sender {
    ASDKModelDynamicTableFormField *dynamicTableFormField = (ASDKModelDynamicTableFormField *) self.currentFormField;
    NSMutableArray *newDynamicTableRows = [NSMutableArray new];
    if (self.currentFormField.values) {
        [newDynamicTableRows addObjectsFromArray:dynamicTableFormField.values];
    }
    
    // make deepcopy of column definitions
    NSArray* dynamicTableDeepCopy = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:dynamicTableFormField.columnDefinitions]];
    
    // and add them as a new table row
    [newDynamicTableRows addObject:dynamicTableDeepCopy];
    
    self.currentFormField.values = [[NSMutableArray alloc] initWithArray:newDynamicTableRows];
    [self determineVisibleRowColumnsWithFormFieldValues:self.currentFormField.values];
    
    [self refreshContent];
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

#pragma mark -
#pragma mark ASDKFormFieldDetailsControllerProtocol

- (void)setupWithFormFieldModel:(ASDKModelFormField *)formFieldModel {
    self.currentFormField = formFieldModel;
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
    ASDKBootstrap *sdkBootstrap = [ASDKBootstrap sharedInstance];
    ASDKFormRenderEngine *currentFormRenderEngine = [sdkBootstrap.serviceLocator serviceConformingToProtocol:@protocol(ASDKFormRenderEngineProtocol)];
    ASDKFormRenderEngine *newFormRenderEngine = [ASDKFormRenderEngine new];
    
    newFormRenderEngine.formNetworkServices = currentFormRenderEngine.formNetworkServices;
    
    // If the user is browsing a completed start form of a process instance then
    // recreate the process definition object from the process instance one
    if (!currentFormRenderEngine.processDefinition &&
        currentFormRenderEngine.processInstance) {
        ASDKModelProcessDefinition *processDefinition = [ASDKModelProcessDefinition new];
        processDefinition.modelID = currentFormRenderEngine.processInstance.processDefinitionID;
        newFormRenderEngine.processDefinition = processDefinition;
    } else {
        newFormRenderEngine.processDefinition = currentFormRenderEngine.processDefinition;
    }
    newFormRenderEngine.task = currentFormRenderEngine.task;
    
    self.blurEffectView.hidden = NO;
    self.activityView.hidden = NO;
    self.activityView.animating = YES;
    
    __weak typeof(self) weakSelf = self;
    if (newFormRenderEngine.task) {
        [newFormRenderEngine setupWithDynamicTableRowFormFields:self.currentFormField.values[section]
                                        dynamicTableFormFieldID:self.currentFormField.modelID
                                                      taskModel:newFormRenderEngine.task
                                          renderCompletionBlock:^(UICollectionViewController<ASDKFormControllerNavigationProtocol> *formController, NSError *error) {
                                              __strong typeof(self) strongSelf = weakSelf;
                                              
                                              if (formController && !error) {
                                                  strongSelf.selectedRowIndex = section;
                                                  
                                                  if (ASDKModelFormFieldRepresentationTypeReadOnly != strongSelf.currentFormField.representationType) {
                                                      UIBarButtonItem *deleteRowBarButtonItem =
                                                      [[UIBarButtonItem alloc] initWithTitle:[NSString iconStringForIconType:ASDKGlyphIconTypeRemove2]
                                                                                       style:UIBarButtonItemStylePlain
                                                                                      target:strongSelf
                                                                                      action:@selector(deleteCurrentDynamicTableRow)];
                                                      
                                                      [deleteRowBarButtonItem setTitleTextAttributes:
                                                       @{NSFontAttributeName            : [UIFont glyphiconFontWithSize:15],
                                                         NSForegroundColorAttributeName : [UIColor whiteColor]}
                                                                                            forState:UIControlStateNormal];
                                                      
                                                      formController.navigationItem.rightBarButtonItem = deleteRowBarButtonItem;
                                                  }
                                                  
                                                  UILabel *titleLabel = [UILabel new];
                                                  titleLabel.text = [NSString stringWithFormat:ASDKLocalizedStringFromTable(kLocalizationFormDynamicTableRowHeaderText, ASDKLocalizationTable, @"Row header"), section + 1];
                                                  titleLabel.font = [UIFont fontWithName:@"Avenir-Book"
                                                                                    size:17];
                                                  titleLabel.textColor = [UIColor whiteColor];
                                                  [titleLabel sizeToFit];
                                                  
                                                  formController.navigationItem.titleView = titleLabel;
                                                  
                                                  // If there is controller assigned to the selected form field notify the delegate
                                                  // that it can begin preparing for presentation
                                                  formController.navigationDelegate = strongSelf.navigationDelegate;
                                                  [self.navigationDelegate prepareToPresentDetailController:formController];
                                              }
                                              
                                              strongSelf.activityView.animating = NO;
                                              strongSelf.activityView.hidden = YES;
                                              strongSelf.blurEffectView.hidden = YES;
                                          } formCompletionBlock:^(BOOL isRowDeleted, NSError *error) {
                                          }];
    } else {
        [newFormRenderEngine setupWithDynamicTableRowFormFields:self.currentFormField.values[section]
                                        dynamicTableFormFieldID:self.currentFormField.modelID
                                              processDefinition:newFormRenderEngine.processDefinition
                                          renderCompletionBlock:^(UICollectionViewController<ASDKFormControllerNavigationProtocol> *formController, NSError *error) {
                                              __strong typeof(self) strongSelf = weakSelf;
                                              
                                              if (formController && !error) {
                                                  // If there is controller assigned to the selected form field notify the delegate
                                                  // that it can begin preparing for presentation
                                                  formController.navigationDelegate = strongSelf.navigationDelegate;
                                                  [strongSelf.navigationDelegate prepareToPresentDetailController:formController];
                                              }
                                              
                                              strongSelf.activityView.animating = NO;
                                              strongSelf.activityView.hidden = YES;
                                              strongSelf.blurEffectView.hidden = YES;
                                          } formCompletionBlock:^(BOOL isRowDeleted, NSError *error) {
                                              __strong typeof(self) strongSelf = weakSelf;
                                              
                                              // delete current row
                                              NSMutableArray *formFieldValues = [NSMutableArray arrayWithArray:strongSelf.currentFormField.values];
                                              [formFieldValues removeObjectAtIndex:section];
                                              strongSelf.currentFormField.values = [formFieldValues copy];
                                              [strongSelf determineVisibleRowColumnsWithFormFieldValues:self.currentFormField.values];
                                              [strongSelf.navigationController popToViewController:self animated:YES];
                                          }];
    }
}

@end
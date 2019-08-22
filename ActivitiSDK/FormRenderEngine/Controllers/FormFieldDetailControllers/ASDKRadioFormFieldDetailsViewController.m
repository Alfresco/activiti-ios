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

#import "ASDKRadioFormFieldDetailsViewController.h"

// Constants
#import "ASDKFormRenderEngineConstants.h"

// Models
#import "ASDKModelFormField.h"
#import "ASDKModelFormFieldOption.h"
#import "ASDKModelFormFieldValue.h"

// Cells
#import "ASDKRadioOptionTableViewCell.h"

static NSInteger const kInvalidOptionSelection = -1;

@interface ASDKRadioFormFieldDetailsViewController ()

@property (strong, nonatomic) ASDKModelFormField    *currentFormField;
@property (weak, nonatomic)   IBOutlet UITableView  *optionTableView;
@property (assign, nonatomic) NSInteger             currentOptionSelection;

@end

@implementation ASDKRadioFormFieldDetailsViewController

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
    self.optionTableView.estimatedRowHeight = 44.0f;
    self.optionTableView.rowHeight = UITableViewAutomaticDimension;
    
    // Set an invalid option selection so that the checkmark isn't set until the user picks one manually
    self.currentOptionSelection = kInvalidOptionSelection;
    
    // Pick up index information from metadata if it exists
    if (self.currentFormField.metadataValue) {
        NSPredicate *metadataPredicate = [NSPredicate predicateWithFormat:@"name==%@", self.currentFormField.metadataValue.option.attachedValue];
        ASDKModelFormFieldOption *formFieldOption = [self.currentFormField.formFieldOptions filteredArrayUsingPredicate:metadataPredicate].firstObject;
        self.currentOptionSelection = [self.currentFormField.formFieldOptions indexOfObject:formFieldOption];
    } else if (self.currentFormField.values) {
        // TODO: Should dynamic table fields be formatted conform regular drop down fields??
        NSPredicate *optionPredicate = nil;
        if ([self.currentFormField.values.firstObject isKindOfClass:NSDictionary.class]) {
            optionPredicate = [NSPredicate predicateWithFormat:@"name==%@", self.currentFormField.values.firstObject[@"name"]];
        } else {
            if (ASDKModelFormFieldTypeRestField == self.currentFormField.fieldType) {
                optionPredicate = [NSPredicate predicateWithFormat:@"modelID == %@", self.currentFormField.values.firstObject];
            } else {
                optionPredicate = [NSPredicate predicateWithFormat:@"name==%@", self.currentFormField.values.firstObject];
            }
        }
        ASDKModelFormFieldOption *formFieldOption = [self.currentFormField.formFieldOptions filteredArrayUsingPredicate:optionPredicate].firstObject;
        
        NSUInteger optionIdx = [self.currentFormField.formFieldOptions indexOfObject:formFieldOption];
        if (optionIdx != NSNotFound) {
            self.currentOptionSelection = optionIdx;
        }
    }
}


#pragma mark -
#pragma mark ASDKFormFieldDetailsControllerProtocol

- (void)setupWithFormFieldModel:(ASDKModelFormField *)formFieldModel {
    self.currentFormField = formFieldModel;
}


#pragma mark -
#pragma mark UITableView Delegate & Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    NSUInteger formFieldOptionsCount = self.currentFormField.formFieldOptions.count;
    return formFieldOptionsCount ? formFieldOptionsCount : self.currentFormField.values.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ASDKRadioOptionTableViewCell *radioCell = [tableView dequeueReusableCellWithIdentifier:kASDKCellIDFormFieldRadioOptionRepresentation
                                                                              forIndexPath:indexPath];
    
    NSUInteger formFieldOptionsCount = self.currentFormField.formFieldOptions.count;
    NSString *optionName = nil;
    if (!formFieldOptionsCount) {
        optionName = self.currentFormField.values[indexPath.row];
    } else {
        optionName = [(ASDKModelFormFieldOption *)self.currentFormField.formFieldOptions[indexPath.row] name];
    }
    radioCell.radioOptionLabel.text = optionName;
    radioCell.checkMarkIconImageView.hidden = !(self.currentOptionSelection == indexPath.row);
    
    if (ASDKModelFormFieldRepresentationTypeReadOnly == self.currentFormField.representationType) {
        radioCell.userInteractionEnabled = NO;
        radioCell.radioOptionLabel.enabled = NO;
        radioCell.checkMarkIconImageView.tintColor = [UIColor lightGrayColor];
    }
    
    return radioCell;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.currentOptionSelection = indexPath.row;
    
    // Propagate the change after the state of the checkbox has changed
    ASDKModelFormFieldValue *formFieldValue = [ASDKModelFormFieldValue new];
    
    ASDKModelFormFieldValue *optionFormFieldValue = [ASDKModelFormFieldValue new];
    optionFormFieldValue.attachedValue = [(ASDKModelFormFieldOption *)self.currentFormField.formFieldOptions[indexPath.row] name];
    formFieldValue.option = optionFormFieldValue;
    
    self.currentFormField.metadataValue = formFieldValue;
    
    // Notify the value transaction delegate there has been a change with the provided form field model
    if ([self.valueTransactionDelegate respondsToSelector:@selector(updatedMetadataValueForFormField:inCell:)]) {
        [self.valueTransactionDelegate updatedMetadataValueForFormField:self.currentFormField
                                                                 inCell:nil];
    }
    
    [tableView reloadData];
}

@end

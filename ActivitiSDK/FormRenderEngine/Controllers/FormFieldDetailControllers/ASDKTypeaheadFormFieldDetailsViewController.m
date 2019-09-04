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

#import "ASDKTypeaheadFormFieldDetailsViewController.h"

// Constants
#import "ASDKFormRenderEngineConstants.h"

// Models
#import "ASDKModelFormField.h"
#import "ASDKModelFormFieldOption.h"
#import "ASDKModelFormFieldValue.h"
#import "ASDKModelFormVariable.h"

// Cells
#import "ASDKTypeaheadValueTableViewCell.h"
#import "ASDKTypeaheadSuggestionTableViewCell.h"


@interface ASDKTypeaheadFormFieldDetailsViewController () <UITextFieldDelegate>

@property (weak, nonatomic)   IBOutlet UITableView          *optionTableView;
@property (weak, nonatomic)   IBOutlet NSLayoutConstraint   *optionTableViewBottomConstraint;

// Internal state
@property (strong, nonatomic) ASDKModelFormField            *currentFormField;
@property (strong, nonatomic) NSArray                       *typeaheadSuggestionsArr;
@property (strong, nonatomic) NSString                      *suggestionString;

@end

@implementation ASDKTypeaheadFormFieldDetailsViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillShow:)
                                                     name:UIKeyboardWillShowNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillHide:)
                                                     name:UIKeyboardWillHideNotification
                                                   object:nil];
    }
    
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

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
}

#pragma mark -
#pragma mark ASDKFormFieldDetailsControllerProtocol

- (void)setupWithFormFieldModel:(ASDKModelFormField *)formFieldModel {
    self.currentFormField = formFieldModel;
}


#pragma mark -
#pragma mark UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    // If we've emptied the typeahead form field dispose of all suggestions
    
    NSArray *indexPathsToBeRemovedArr = nil;
    NSArray *indexPathsToBeAddedArr = nil;
    NSArray *typeaheadSuggestionsArr = nil;
    
    if (!range.location && !string.length) {
        indexPathsToBeRemovedArr = [self indexPathArrayOfCleanedSuggestions];
        typeaheadSuggestionsArr = nil;
    } else {
        NSString *suggestionTitleString = [textField.text stringByAppendingString:string];
        if(!string.length) {
            suggestionTitleString = [suggestionTitleString substringToIndex:suggestionTitleString.length - 1];
        }
        
        self.suggestionString = suggestionTitleString;
        NSArray *matchingTypeaheadSuggestionsArr = [self matchingTypeaheadSuggestionsForTitle:suggestionTitleString];
        indexPathsToBeRemovedArr = [self indexPathArrayOfCleanedSuggestions];
        indexPathsToBeAddedArr = [self indexPathArrayForSuggestionCount:matchingTypeaheadSuggestionsArr.count];
        
        typeaheadSuggestionsArr = matchingTypeaheadSuggestionsArr;
    }
    
    [self.optionTableView beginUpdates];
    self.typeaheadSuggestionsArr = typeaheadSuggestionsArr;
    
    [self.optionTableView insertRowsAtIndexPaths:indexPathsToBeAddedArr
                                withRowAnimation:UITableViewRowAnimationNone];
    [self.optionTableView deleteRowsAtIndexPaths:indexPathsToBeRemovedArr
                                withRowAnimation:UITableViewRowAnimationNone];
    [self.optionTableView endUpdates];
    
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    self.currentFormField.metadataValue = nil;
    self.typeaheadSuggestionsArr = nil;
    [self.optionTableView reloadData];
    
    return YES;
}


#pragma mark -
#pragma mark UITableView Delegate & Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    return self.typeaheadSuggestionsArr.count + 1; // Additional field represents the always visible input typeahead value cell
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    UITableViewCell *typeaheadCell = nil;
    
    if (indexPath.row == 0) {
        NSString *optionValue = [self optionValueForTypeaheadCell];
        
        ASDKTypeaheadValueTableViewCell *typeaheadValueCell =
        [tableView dequeueReusableCellWithIdentifier:kASDKCellIDFormFieldTypeaheadRepresentation
                                        forIndexPath:indexPath];
        typeaheadValueCell.inputTextField.text = optionValue;
        
        if (ASDKModelFormFieldRepresentationTypeReadOnly == self.currentFormField.representationType) {
            typeaheadValueCell.userInteractionEnabled = NO;
            typeaheadValueCell.inputTextField.textColor = [UIColor lightGrayColor];
        } else {
            [typeaheadValueCell.inputTextField becomeFirstResponder];
            typeaheadValueCell.inputTextField.delegate = self;
        }
        
        typeaheadCell = typeaheadValueCell;
    } else {
        ASDKTypeaheadSuggestionTableViewCell *typeaheadSuggestionCell =
        [tableView dequeueReusableCellWithIdentifier:kASDKCellIDFormFieldTypeaheadSuggestionRepresentation
                                        forIndexPath:indexPath];
        ASDKModelFormFieldOption *formFieldOption = self.typeaheadSuggestionsArr[indexPath.row - 1];
        typeaheadSuggestionCell.suggestionLabel.attributedText = [self boldAttributedStringMatchingString:self.suggestionString
                                                                                                   source:formFieldOption.name];
        typeaheadCell = typeaheadSuggestionCell;
    }
    
    return typeaheadCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row) {
        [self.view endEditing:YES];
        
        ASDKModelFormFieldOption *formFieldOption = self.typeaheadSuggestionsArr[indexPath.row - 1];
        
        // Propagate the change after an option has been selected
        ASDKModelFormFieldValue *formFieldValue = [ASDKModelFormFieldValue new];
        
        ASDKModelFormFieldValue *optionFormFieldValue = [ASDKModelFormFieldValue new];
        optionFormFieldValue.attachedValue = formFieldOption.name;
        formFieldValue.option = optionFormFieldValue;
        
        self.currentFormField.metadataValue = formFieldValue;
        
        // Notify the value transaction delegate there has been a change with the provided form field model
        if ([self.valueTransactionDelegate respondsToSelector:@selector(updatedMetadataValueForFormField:inCell:)]) {
            [self.valueTransactionDelegate updatedMetadataValueForFormField:self.currentFormField
                                                                     inCell:nil];
        }
        
        // Clean visible suggestions
        self.typeaheadSuggestionsArr = nil;
        [tableView reloadData];
    }
}

#pragma mark -
#pragma mark Convenience methods

- (NSArray *)indexPathArrayOfCleanedSuggestions {
    NSMutableArray *indexPathsToBeRemovedArr = [NSMutableArray array];
    for (NSUInteger idx = 0; idx < self.typeaheadSuggestionsArr.count; idx++) {
        NSIndexPath *indexPathToBeRemoved = [NSIndexPath indexPathForRow:idx + 1
                                                               inSection:0];
        [indexPathsToBeRemovedArr addObject:indexPathToBeRemoved];
    }
    
    return indexPathsToBeRemovedArr;
}

- (NSArray *)indexPathArrayForSuggestionCount:(NSUInteger)suggestionCount {
    NSMutableArray *indexPathsToBeAddedArr = [NSMutableArray array];
    for (NSUInteger idx = 0; idx < suggestionCount; idx++) {
        NSIndexPath *indexPathToBeAdded = [NSIndexPath indexPathForRow:idx + 1
                                                             inSection:0];
        [indexPathsToBeAddedArr addObject:indexPathToBeAdded];
    }
    
    return indexPathsToBeAddedArr;
}

- (NSArray *)matchingTypeaheadSuggestionsForTitle:(NSString *)title {
    NSPredicate *typeaheadSuggestionPredicate = [NSPredicate predicateWithFormat:@"SELF.name CONTAINS[cd] %@", title];
    NSArray *formFieldOptionsArr = self.currentFormField.formFieldOptions;
    NSArray *matchingTypeaheadSuggestions = [formFieldOptionsArr filteredArrayUsingPredicate:typeaheadSuggestionPredicate];
    
    return matchingTypeaheadSuggestions;
}

- (NSMutableAttributedString *)boldAttributedStringMatchingString:(NSString *)suggestion
                                                           source:(NSString *)sourceString {
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont fontWithName:@"Avenir-Book"
                                                                      size:17]};
    NSDictionary *subAttributes = @{NSFontAttributeName:[UIFont fontWithName:@"Avenir-Heavy"
                                                                        size:17]};
    
    const NSRange range = [sourceString.lowercaseString rangeOfString:suggestion.lowercaseString];
    
    // Create the attributed string (text + attributes)
    NSMutableAttributedString *attributedText =
    [[NSMutableAttributedString alloc] initWithString:sourceString
                                           attributes:attributes];
    [attributedText setAttributes:subAttributes
                            range:range];
    
    return attributedText;
}

- (NSString *)optionValueForTypeaheadCell {
    NSString *optionValue = nil;
    
    if (self.currentFormField.values.count) {
        NSString *labelValue = nil;
        
        NSString *formFieldValue = self.currentFormField.values.firstObject;
        NSPredicate *metadataPredicate = [NSPredicate predicateWithFormat:@"modelID == %@", formFieldValue];
        ASDKModelFormFieldOption *formFieldOption = [self.currentFormField.formFieldOptions filteredArrayUsingPredicate:metadataPredicate].firstObject;
        labelValue = formFieldOption.name;
        
        if (!labelValue) {
            ASDKModelFormVariable *formVariable = self.currentFormField.formFieldParams.values.firstObject;
            labelValue = formVariable.value;
        }
        
        if (ASDKModelFormFieldRepresentationTypeReadOnly == self.currentFormField.representationType) {
            if (formFieldValue.length) {
                optionValue = formFieldValue;
            }
            
            if (labelValue.length) {
                if (optionValue.length) {
                    optionValue = [NSString stringWithFormat:@"%@ (%@)", optionValue, labelValue];
                }
            }
            
            if (!optionValue.length) {
                optionValue = kASDKFormFieldEmptyStringValue;
            }
        } else {
            optionValue = labelValue;
        }
    } else {
        optionValue = self.currentFormField.metadataValue.option.attachedValue;
    }
    
    return optionValue;
}


#pragma mark -
#pragma mark Keyboard handling

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    NSValue *kbFrame = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    NSTimeInterval animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGRect keyboardFrame = [kbFrame CGRectValue];
    CGRect finalKeyboardFrame = [self.view convertRect:keyboardFrame
                                              fromView:self.view.window];
    
    int kbHeight = finalKeyboardFrame.size.height;
    int height = kbHeight + self.optionTableViewBottomConstraint.constant;
    self.optionTableViewBottomConstraint.constant = height;
    
    [UIView animateWithDuration:animationDuration
                     animations:^{
                         [self.view layoutIfNeeded];
                     }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    NSTimeInterval animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    self.optionTableViewBottomConstraint.constant = 0;
    
    [UIView animateWithDuration:animationDuration
                     animations:^{
                         [self.view layoutIfNeeded];
                     }];
}


@end

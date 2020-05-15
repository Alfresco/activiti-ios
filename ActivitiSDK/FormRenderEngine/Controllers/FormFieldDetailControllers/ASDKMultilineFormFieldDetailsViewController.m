/*******************************************************************************
 * Copyright (C) 2005-2020 Alfresco Software Limited.
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


#import "ASDKMultilineFormFieldDetailsViewController.h"

// Constants
#import "ASDKFormRenderEngineConstants.h"

// Models
#import "ASDKModelFormField.h"
#import "ASDKModelFormFieldValue.h"

// Managers
#import "ASDKBootstrap.h"
#import "ASDKServiceLocator.h"
#import "ASDKFormColorSchemeManager.h"

@interface ASDKMultilineFormFieldDetailsViewController () <UITextViewDelegate>

@property (strong, nonatomic) ASDKModelFormField            *currentFormField;
@property (weak, nonatomic) IBOutlet UITextView             *multilineTextView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint     *multilineBottomConstraint;

@end

@implementation ASDKMultilineFormFieldDetailsViewController

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
    
    self.multilineTextView.delegate = self;
    
    // Update the navigation bar title
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = self.currentFormField.fieldName;
    titleLabel.font = [UIFont fontWithName:@"Avenir-Book"
                                      size:17];
    titleLabel.textColor = [UIColor whiteColor];
    [titleLabel sizeToFit];
    self.navigationItem.titleView = titleLabel;
    
    // Setup label and text area
    if (self.currentFormField.metadataValue) {
        self.multilineTextView.text = self.currentFormField.metadataValue.attachedValue;
    } else {
        self.multilineTextView.text = self.currentFormField.values.firstObject;
    }
    
    if (ASDKModelFormFieldRepresentationTypeReadOnly == self.currentFormField.representationType ||
        ASDKModelFormFieldRepresentationTypeReadonlyText == self.currentFormField.representationType) {
        ASDKBootstrap *sdkBootstrap = [ASDKBootstrap sharedInstance];
        ASDKFormColorSchemeManager *colorSchemeManager = [sdkBootstrap.serviceLocator serviceConformingToProtocol:@protocol(ASDKFormColorSchemeManagerProtocol)];
        
        self.multilineTextView.editable = NO;
        self.multilineTextView.textColor = colorSchemeManager.formViewFilledInValueColor;
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    [self.multilineTextView setContentOffset:CGPointZero
                                    animated:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.multilineTextView becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.multilineTextView resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet *)touches
           withEvent:(UIEvent *)event{
    [self.multilineTextView resignFirstResponder];
    [super touchesBegan:touches
              withEvent:event];
}


#pragma mark -
#pragma mark ASDKFormFieldDetailsControllerProtocol

- (void)setupWithFormFieldModel:(ASDKModelFormField *)formFieldModel {
    self.currentFormField = formFieldModel;
}


#pragma mark -
#pragma mark TextView Delegate methods

- (void)textViewDidEndEditing:(UITextView *)textView {
    ASDKModelFormFieldValue *formFieldValue = [ASDKModelFormFieldValue new];
    formFieldValue.attachedValue = textView.text;

    self.currentFormField.metadataValue = formFieldValue;
    
    // Notify the value transaction delegate there has been a change with the provided form field model
    if ([self.valueTransactionDelegate respondsToSelector:@selector(updatedMetadataValueForFormField:inCell:)]) {
        [self.valueTransactionDelegate updatedMetadataValueForFormField:self.currentFormField
                                                                 inCell:nil];
    }
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
    int height = kbHeight + self.multilineBottomConstraint.constant;
    self.multilineBottomConstraint.constant = height;
    
    [UIView animateWithDuration:animationDuration
                     animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    NSTimeInterval animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    self.multilineBottomConstraint.constant = 8;
    
    [UIView animateWithDuration:animationDuration
                     animations:^{
        [self.view layoutIfNeeded];
    }];
}

@end

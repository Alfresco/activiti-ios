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

#import "AFAModalTaskDetailsViewController.h"
#import <QuartzCore/QuartzCore.h>

// Constants
#import "AFAUIConstants.h"
#import "AFALocalizationConstants.h"

// Categories
#import "UIColor+AFATheme.h"
#import "UIViewController+AFAAlertAddition.h"

// Managers
#import "AFAProfileServices.h"
#import "AFAServiceRepository.h"
#import "AFAModalTaskDetailsCreateTaskAction.h"
#import "AFAModalTaskDetailsUpdateTaskAction.h"
#import "AFAModalTaskDetailsCreateChecklistAction.h"
@import ActivitiSDK;

// Models
#import "AFATaskCreateModel.h"
#import "AFATaskUpdateModel.h"

// Views
#import <JGProgressHUD/JGProgressHUD.h>

@interface AFAModalTaskDetailsViewController ()

@property (weak, nonatomic) IBOutlet UIView             *alertContainerView;
@property (weak, nonatomic) IBOutlet UILabel            *alertTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel            *nameLabel;
@property (weak, nonatomic) IBOutlet UITextField        *nameTextField;
@property (weak, nonatomic) IBOutlet UILabel            *descriptionLabel;
@property (weak, nonatomic) IBOutlet UITextView         *descriptionTextView;
@property (weak, nonatomic) IBOutlet UIButton           *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton           *confirmButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *alertContainerViewVerticalConstraint;
@property (strong, nonatomic) JGProgressHUD             *progressHUD;

// Services
@property (strong, nonatomic) AFAProfileServices        *requestProfileService;

@end

@implementation AFAModalTaskDetailsViewController

- (void)dealloc {
    [self.alertContainerView removeObserver:self
                                 forKeyPath:@"bounds"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        _requestProfileService = [AFAProfileServices new];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillChange:)
                                                     name:UIKeyboardWillChangeFrameNotification
                                                   object:nil];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set up localization
    self.alertTitleLabel.text = self.alertTitle;
    self.nameLabel.text = NSLocalizedString(kLocalizationAddTaskScreenNameLabelText, @"Name label");
    self.descriptionLabel.text = NSLocalizedString(kLocalizationAddTaskScreenDescriptionLabelText, @"Description label");
    [self.cancelButton setTitle:NSLocalizedString(kLocalizationAlertDialogCancelButtonText, @"Cancel button")
                       forState:UIControlStateNormal];
    self.confirmButton.backgroundColor = self.appThemeColor;
    [self.confirmButton setTitle:self.confirmButtonTitle
                        forState:UIControlStateNormal];
    self.nameTextField.text = self.taskName;
    self.descriptionTextView.text = self.taskDescription;
    [self validateTaskNameFieldForString:self.nameTextField.text];
    
    self.progressHUD = [self configureProgressHUD];
    
    [self.alertContainerView addObserver:self
                              forKeyPath:@"bounds"
                                 options:NSKeyValueObservingOptionNew
                                 context:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.alertContainerView.alpha = .0f;
    self.alertContainerView.transform = CGAffineTransformMakeScale(1.3f, 1.3f);
    
    // Apply a fade-in animation
    [UIView animateWithDuration:kOverlayAlphaChangeTime
                          delay:.0f
         usingSpringWithDamping:.5f
          initialSpringVelocity:5.0f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.alertContainerView.alpha = 1.0f;
                         self.alertContainerView.transform = CGAffineTransformMakeScale(1.0, 1.0);
                     } completion:nil];
}

- (void)keyboardWillChange:(NSNotification *)notification {
    CGRect keyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    self.alertContainerViewVerticalConstraint.constant = (keyboardFrame.origin.y == self.view.frame.size.height) ? .0f : - CGRectGetHeight(keyboardFrame) / 2.0f;
    [self.view layoutIfNeeded];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark -
#pragma mark Action

- (IBAction)onCancel:(id)sender {
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

- (IBAction)onConfirm:(id)sender {
    [self.view endEditing:YES];
    [self.progressHUD showInView:self.view];
    
    // First fetch information about the user creating the task
    __weak typeof(self) weakSelf = self;
    AFATaskServicesTaskDetailsCompletionBlock taskDetailsCompletionBlock = ^(ASDKModelTask *task, NSError *error) {
        __strong typeof(self) strongSelf = weakSelf;
        
        if (!error) {
            strongSelf.progressHUD.textLabel.text = NSLocalizedString(kLocalizationSuccessText, @"Success text");
            strongSelf.progressHUD.detailTextLabel.text = nil;
            strongSelf.progressHUD.indicatorView = [[JGProgressHUDSuccessIndicatorView alloc] init];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf.progressHUD dismiss];
                
                if ([weakSelf.delegate respondsToSelector:@selector(didCreateTask:)]) {
                    [weakSelf.delegate didCreateTask:task];
                }
                [weakSelf dismissViewControllerAnimated:YES
                                             completion:nil];
            });
        } else {
            [strongSelf.progressHUD dismiss];
            [strongSelf showGenericNetworkErrorAlertControllerWithMessage:NSLocalizedString(kLocalizationAlertDialogGenericNetworkErrorText, @"Generic network error")];
        }
    };
    
    AFATaskServicesTaskUpdateCompletionBlock taskDetailsUpdateCompletionBlock = ^(BOOL isTaskUpdated, NSError *error) {
        __strong typeof(self) strongSelf = weakSelf;
        
        if (!error) {
            strongSelf.progressHUD.textLabel.text = NSLocalizedString(kLocalizationSuccessText, @"Success text");
            strongSelf.progressHUD.detailTextLabel.text = nil;
            strongSelf.progressHUD.indicatorView = [[JGProgressHUDSuccessIndicatorView alloc] init];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf.progressHUD dismiss];
                
                if ([weakSelf.delegate respondsToSelector:@selector(didUpdateCurrentTask)]) {
                    [weakSelf.delegate didUpdateCurrentTask];
                }
                [weakSelf dismissViewControllerAnimated:YES
                                             completion:nil];
            });
        } else {
            [strongSelf.progressHUD dismiss];
            [strongSelf showGenericNetworkErrorAlertControllerWithMessage:NSLocalizedString(kLocalizationAlertDialogGenericNetworkErrorText, @"Generic network error")];
        }
    };

    [self.requestProfileService requestProfileWithCompletionBlock:^(ASDKModelProfile *profile, NSError *error) {
        __strong typeof(self) strongSelf = weakSelf;
        if (!error) {
            if ([self.confirmAlertAction respondsToSelector:@selector(executeAlertActionWithModel:completionBlock:)]) {
                if ([self.confirmAlertAction isKindOfClass:[AFAModalTaskDetailsCreateTaskAction class]] ||
                    [self.confirmAlertAction isKindOfClass:[AFAModalTaskDetailsCreateChecklistAction class]]) {
                    AFATaskCreateModel *taskCreateModel = [AFATaskCreateModel new];
                    taskCreateModel.taskName = self.nameTextField.text;
                    taskCreateModel.taskDescription = self.descriptionTextView.text;
                    taskCreateModel.applicationID = self.applicationID;
                    taskCreateModel.assigneeID = profile.modelID;
                    
                    [self.confirmAlertAction executeAlertActionWithModel:taskCreateModel
                                                         completionBlock:taskDetailsCompletionBlock];
                } else if ([self.confirmAlertAction isKindOfClass:[AFAModalTaskDetailsUpdateTaskAction class]]) {
                    AFATaskUpdateModel *taskUpdate = [AFATaskUpdateModel new];
                    taskUpdate.taskName = self.nameTextField.text;
                    taskUpdate.taskDescription = self.descriptionTextView.text;
                    
                    [self.confirmAlertAction executeAlertActionWithModel:taskUpdate
                                                         completionBlock:taskDetailsUpdateCompletionBlock];
                }
                
            }
        } else {
            [strongSelf.progressHUD dismiss];
            [strongSelf showGenericNetworkErrorAlertControllerWithMessage:NSLocalizedString(kLocalizationAlertDialogGenericNetworkErrorText, @"Generic network error")];
        }
    }];
}

- (IBAction)onKeyboardDismiss:(UITapGestureRecognizer *)sender {
    [self.view endEditing:YES];
}

- (IBAction)onTaskNameTextFieldChange:(UITextField *)sender {
    [self validateTaskNameFieldForString:sender.text];
}


#pragma mark -
#pragma mark Progress hud setup

- (JGProgressHUD *)configureProgressHUD {
    JGProgressHUD *hud = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
    hud.interactionType = JGProgressHUDInteractionTypeBlockAllTouches;
    JGProgressHUDFadeZoomAnimation *zoomAnimation = [JGProgressHUDFadeZoomAnimation animation];
    hud.animation = zoomAnimation;
    hud.textLabel.text = self.progressTitle;
    
    return hud;
}


#pragma mark -
#pragma mark Convenience methods

- (void)validateTaskNameFieldForString:(NSString *)taskName {
    BOOL enableCreateButton = [taskName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length ? YES : NO;
    
    self.confirmButton.enabled = enableCreateButton;
    [self.confirmButton setBackgroundColor:enableCreateButton ? self.appThemeColor : [UIColor disabledControlColor]];
}


#pragma mark -
#pragma mark KVO handling

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context {
    if (object == self.alertContainerView) {
        UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:self.alertContainerView.bounds];
        self.alertContainerView.layer.masksToBounds = NO;
        self.alertContainerView.layer.shadowColor = [UIColor blackColor].CGColor;
        self.alertContainerView.layer.shadowOffset = CGSizeMake(0.0f, 5.0f);
        self.alertContainerView.layer.shadowOpacity = 0.5f;
        self.alertContainerView.layer.shadowPath = shadowPath.CGPath;
    }
}

@end

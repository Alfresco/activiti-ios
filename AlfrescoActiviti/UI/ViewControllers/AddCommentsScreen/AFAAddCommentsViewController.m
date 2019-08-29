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

#import "AFAAddCommentsViewController.h"

// Constants
#import "AFALocalizationConstants.h"
#import "AFAUIConstants.h"

// Categories
#import "UIFont+ASDKGlyphicons.h"
#import "NSString+ASDKFontGlyphicons.h"
#import "UIViewController+AFAAlertAddition.h"

// Managers
#import "AFATaskServices.h"
#import "AFAProcessServices.h"
#import "AFAServiceRepository.h"

// Views
#import <JGProgressHUD/JGProgressHUD.h>

@interface AFAAddCommentsViewController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem            *backBarButtonItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem            *confirmBarButtonItem;
@property (weak, nonatomic) IBOutlet UITextView                 *commentsTextView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint         *commentsTextViewBottomConstraint;

// Internal state properties
@property (strong, nonatomic) JGProgressHUD                     *progressHUD;

// Services
@property (strong, nonatomic) AFATaskServices                   *createTaskCommentService;
@property (strong, nonatomic) AFAProcessServices                *createProcessInstanceCommentService;

@end

@implementation AFAAddCommentsViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        _progressHUD = [self configureProgressHUD];
        _createTaskCommentService = [AFATaskServices new];
        _createProcessInstanceCommentService = [AFAProcessServices new];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillChange:)
                                                     name:UIKeyboardWillChangeFrameNotification
                                                   object:nil];
    }
    
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.backBarButtonItem setTitleTextAttributes:@{NSFontAttributeName           : [UIFont glyphiconFontWithSize:15],
                                                     NSForegroundColorAttributeName: [UIColor whiteColor]}
                                          forState:UIControlStateNormal];
    self.backBarButtonItem.title = [NSString iconStringForIconType:ASDKGlyphIconTypeChevronLeft];
    
    [self.confirmBarButtonItem setTitleTextAttributes:@{NSFontAttributeName            : [UIFont glyphiconFontWithSize:15],
                                                        NSForegroundColorAttributeName : [UIColor whiteColor]}
                                             forState:UIControlStateNormal];
    self.confirmBarButtonItem.title = [NSString iconStringForIconType:ASDKGlyphIconTypeOk2];
    
    self.navigationBarTitle = NSLocalizedString(kLocalizationAddCommentsScreenTitleText, @"Add comment screen title");
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.commentsTextView becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)keyboardWillChange:(NSNotification *)notification {
    CGRect keyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    self.commentsTextViewBottomConstraint.constant = CGRectGetHeight(keyboardFrame) + 8.0f;
    [self.view layoutIfNeeded];
}


#pragma mark -
#pragma mark Actions

- (IBAction)onBack:(UIBarButtonItem *)sender {
    if (self.taskID) {
        [self performSegueWithIdentifier:kSegueIDTaskDetailsAddCommentsUnwind
                                  sender:sender];
    } else {
        [self performSegueWithIdentifier:kSegueIDProcessInstanceDetailsAddCommentsUnwind
                                  sender:sender];
    }
}

- (IBAction)onConfirm:(id)sender {
    // If the user entered some input text go ahead and post the comment
    if (self.commentsTextView.text.length) {
        __weak typeof(self) weakSelf = self;
        void (^commentCompletionBlock)(ASDKModelComment *comment, NSError *error) = ^(ASDKModelComment *comment, NSError *error) {
            __strong typeof(self) strongSelf = weakSelf;
            if (!error) {
                    strongSelf.progressHUD.textLabel.text = NSLocalizedString(kLocalizationSuccessText, @"Success text");
                    strongSelf.progressHUD.detailTextLabel.text = nil;
                    strongSelf.progressHUD.indicatorView = [[JGProgressHUDSuccessIndicatorView alloc] init];
                [strongSelf.progressHUD dismissAfterDelay:1.0f];
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [weakSelf onBack:nil];
                });
            } else {
                [strongSelf.progressHUD dismiss];
                [strongSelf showGenericNetworkErrorAlertControllerWithMessage:NSLocalizedString(kLocalizationAlertDialogGenericNetworkErrorText, @"Generic network error")];
            }
        };
        
        [self.progressHUD showInView:self.navigationController.view];
        
        // Check whether we need to add a task or process instance comment
        if (self.taskID) {
            [self.createTaskCommentService requestCreateComment:self.commentsTextView.text
                                                      forTaskID:self.taskID
                                                completionBlock:commentCompletionBlock];
        } else {
            [self.createProcessInstanceCommentService requestCreateComment:self.commentsTextView.text
                                                      forProcessInstanceID:self.processInstanceID
                                                           completionBlock:commentCompletionBlock];
        }
    } else {
        [self showGenericErrorAlertControllerWithMessage:NSLocalizedString(kLocalizationAddCommentScreenEmptyCommentErrorText, @"Add some text error text")];
    }
}


#pragma mark -
#pragma mark Progress hud setup

- (JGProgressHUD *)configureProgressHUD {
    JGProgressHUD *hud = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
    hud.interactionType = JGProgressHUDInteractionTypeBlockAllTouches;
    JGProgressHUDFadeZoomAnimation *zoomAnimation = [JGProgressHUDFadeZoomAnimation animation];
    hud.animation = zoomAnimation;
    hud.textLabel.text = [NSString stringWithFormat:NSLocalizedString(kLocalizationAddCommentScreenPostInProgressText, @"Adding comment text")];
    
    return hud;
}

@end

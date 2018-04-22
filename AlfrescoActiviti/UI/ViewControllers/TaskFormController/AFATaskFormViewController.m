/*******************************************************************************
 * Copyright (C) 2005-2017 Alfresco Software Limited.
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

#import "AFATaskFormViewController.h"

// Categories
#import "UIViewController+AFAAlertAddition.h"

// Constants
#import "AFALocalizationConstants.h"
#import "AFABusinessConstants.h"

// Managers
#import "AFAServiceRepository.h"
@import ActivitiSDK;

// Views
#import <JGProgressHUD/JGProgressHUD.h>
#import "AFANoContentView.h"

// Views
#import "AFAActivityView.h"

@interface AFATaskFormViewController() <ASDKFormControllerNavigationProtocol,
                                        ASDKFormRenderEngineDelegate>

@property (weak, nonatomic)   IBOutlet AFAActivityView      *activityView;
@property (weak, nonatomic)   IBOutlet AFANoContentView     *noContentView;
@property (strong, nonatomic) JGProgressHUD                 *progressHUD;

@property (strong, nonatomic) ASDKModelTask                 *task;

@end


@implementation AFATaskFormViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        dispatch_queue_t formUpdatesProcessingQueue = dispatch_queue_create([[NSString stringWithFormat:@"%@.`%@ProcessingQueue", [NSBundle mainBundle].bundleIdentifier, NSStringFromClass([self class])] UTF8String], DISPATCH_QUEUE_SERIAL);
        
        ASDKBootstrap *sdkBootstrap = [ASDKBootstrap sharedInstance];
        ASDKFormNetworkServices *formNetworkService = [sdkBootstrap.serviceLocator serviceConformingToProtocol:@protocol(ASDKFormNetworkServiceProtocol)];
        formNetworkService.resultsQueue = formUpdatesProcessingQueue;
        
        _taskFormRenderEngine = [[ASDKFormRenderEngine alloc] initWithDelegate:self];
        _taskFormRenderEngine.formNetworkServices = formNetworkService;
        
        _progressHUD = [self configureProgressHUD];
    }
    
    return self;
}


#pragma mark -
#pragma mark Public interface

- (void)formForTask:(ASDKModelTask *)task {
    NSParameterAssert(task);
    
    if (![task.modelID isEqualToString:self.task.modelID]) {
        self.task = task;
        
        self.activityView.hidden = NO;
        self.activityView.animating = YES;
        
        [self.taskFormRenderEngine setupWithTaskModel:self.task];
    } else {
        if ([self.delegate respondsToSelector:@selector(formDidLoadWithError:)]) {
            [self.delegate formDidLoadWithError:nil];
        }
    }
}

- (void)saveForm {
    [self.taskFormRenderEngine.actionHandler saveForm];
}


#pragma mark -
#pragma mark ASDKFormControllerNavigationProtocol

- (void)prepareToPresentDetailController:(UIViewController *)controller {
    if ([self.delegate respondsToSelector:@selector(presentFormDetailController:)]) {
        [self.delegate presentFormDetailController:controller];
    }
}

- (UINavigationController *)formNavigationController {
    if ([self.delegate respondsToSelector:@selector(formNavigationController)]) {
        return [self.delegate formNavigationController];
    }
    return nil;
}


#pragma mark -
#pragma mark ASDKFormRenderEngineDelegate

- (void)didRenderedFormController:(UICollectionViewController<ASDKFormControllerNavigationProtocol> *)formController
                            error:(NSError *)error {
    if (!error) {
        // Make sure we remove any references of old versions of the form controller
        for (id childController in self.childViewControllers) {
            if ([childController isKindOfClass:[UICollectionViewController class]]) {
                [((UICollectionViewController *)childController).view removeFromSuperview];
                [(UICollectionViewController *)childController removeFromParentViewController];
            }
        }
        
        formController.navigationDelegate = self;
        [self addChildViewController:formController];
        
        UIView *formView = formController.view;
        formView.frame = self.view.bounds;
        [formView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.view addSubview:formController.view];
        
        NSDictionary *views = NSDictionaryOfVariableBindings(formView);
        
        [self.view addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[formView]|"
                                                 options:0
                                                 metrics:nil
                                                   views:views]];
        [self.view addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|[formView]-%d-|", 40]
                                                 options:0
                                                 metrics:nil
                                                   views:views]];
    } else {
        self.noContentView.iconImageView.image = [UIImage imageNamed:@"form-warning-icon"];
        self.noContentView.hidden = NO;
        
        if (kASDKFormRenderEngineUnsupportedFormFieldsCode == error.code) {
            self.noContentView.descriptionLabel.text =
            NSLocalizedString(kLocalizationAlertDialogTaskFormUnsupportedFormFieldsText, @"Unsupported form fields error");
        } else {
            self.noContentView.descriptionLabel.text =
            NSLocalizedString(kLocalizationAlertDialogTaskFormCannotSetUpErrorText, @"Form set up error");
        }
    }
    
    self.activityView.animating = NO;
    self.activityView.hidden = YES;
    
    if ([self.delegate respondsToSelector:@selector(formDidLoadWithError:)]) {
        [self.delegate formDidLoadWithError:error];
    }
}

- (void)didCompleteFormWithError:(NSError *)error {
    if (error) {
        [self showGenericNetworkErrorAlertControllerWithMessage:NSLocalizedString(kLocalizationAlertDialogTaskFormCannotSetUpErrorText, @"Form set up error")];
    } else {
        if ([self.delegate respondsToSelector:@selector(userDidCompleteForm)]) {
            [self.delegate userDidCompleteForm];
        }
    }
}

- (void)didSaveFormWithError:(NSError *)error {
    [self saveFormWithError:error
              isOfflineForm:NO];
}

- (void)didSaveFormInOfflineMode {
    [self saveFormWithError:nil
              isOfflineForm:YES];
}

- (void)saveFormWithError:(NSError *)error
            isOfflineForm:(BOOL)isOfflineForm {
    [self showFormSaveIndicatorView];
    
    if (!error) {
        __weak typeof(self) weakSelf = self;
        
        CGFloat messageDismissDurationInSeconds;
        NSString *saveMessage = nil;
        
        if (isOfflineForm) {
            saveMessage = NSLocalizedString(kLocalizationTaskDetailsScreenTaskFormSavedOfflineText, @"Task form is saved offline text");
            messageDismissDurationInSeconds = 4.0;
        } else {
            saveMessage = NSLocalizedString(kLocalizationTaskDetailsScreenTaskFormSavedText, "Task form is saved text");
            messageDismissDurationInSeconds = 0.3;
        }
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            __strong typeof(self) strongSelf = weakSelf;
            
            strongSelf.progressHUD.textLabel.text = saveMessage;
            strongSelf.progressHUD.detailTextLabel.text = nil;
            strongSelf.progressHUD.layoutChangeAnimationDuration = 0.3;
            strongSelf.progressHUD.indicatorView = [[JGProgressHUDSuccessIndicatorView alloc] init];
        });
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(messageDismissDurationInSeconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            __strong typeof(self) strongSelf = weakSelf;
            
            [strongSelf.progressHUD dismiss];
        });
    } else {
        if (error.code != NSURLErrorNotConnectedToInternet) {
            [self.progressHUD dismiss];
            [self showGenericNetworkErrorAlertControllerWithMessage:NSLocalizedString(kLocalizationAlertDialogGenericNetworkErrorText, @"Generic network error")];  
        }
    }
}


#pragma mark -
#pragma mark Progress hud setup

- (JGProgressHUD *)configureProgressHUD {
    JGProgressHUD *hud = [[JGProgressHUD alloc] initWithStyle:JGProgressHUDStyleDark];
    hud.interactionType = JGProgressHUDInteractionTypeBlockAllTouches;
    JGProgressHUDFadeZoomAnimation *zoomAnimation = [JGProgressHUDFadeZoomAnimation animation];
    hud.animation = zoomAnimation;
    hud.layoutChangeAnimationDuration = .0f;
    hud.indicatorView = [[JGProgressHUDIndeterminateIndicatorView alloc] initWithHUDStyle:self.progressHUD.style];
    
    return hud;
}

- (void)showFormSaveIndicatorView {
    self.progressHUD.textLabel.text = nil;
    JGProgressHUDIndeterminateIndicatorView *indicatorView = [[JGProgressHUDIndeterminateIndicatorView alloc] initWithHUDStyle:self.progressHUD.style];
    [indicatorView setColor:[UIColor whiteColor]];
    self.progressHUD.indicatorView = indicatorView;
    [self.progressHUD showInView:self.navigationController.view];
}

@end

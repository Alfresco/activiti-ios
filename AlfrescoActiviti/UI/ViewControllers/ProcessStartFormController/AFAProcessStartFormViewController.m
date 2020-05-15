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

#import "AFAProcessStartFormViewController.h"
@import ActivitiSDK;

// Categories
#import "UIViewController+AFAAlertAddition.h"

// Constants
#import "AFALocalizationConstants.h"
#import "AFABusinessConstants.h"
#import "AFAUIConstants.h"

// Managers
#import "AFAServiceRepository.h"

// Views
#import "AFAActivityView.h"
#import "AFANoContentView.h"

typedef NS_ENUM(NSInteger, AFAProcessStartFormQueueOperationType) {
    AFAProcessStartFormQueueOperationTypeUndefined         = -1,
    AFAProcessStartFormQueueOperationTypeNone              = 0,
    AFAProcessStartFormQueueOperationTypeProcessDefinition,
    AFAProcessStartFormQueueOperationTypeProcessInstance
};

@interface AFAProcessStartFormViewController () <ASDKFormControllerNavigationProtocol,
                                                 ASDKFormRenderEngineDelegate>

@property (weak, nonatomic) IBOutlet AFAActivityView                    *activityView;
@property (weak, nonatomic) IBOutlet AFANoContentView                   *noContentView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem                    *backBarButtonItem;

// Internal state properties
@property (strong, nonatomic) ASDKModelProcessDefinition                *processDefinition;
@property (strong, nonatomic) ASDKModelProcessInstance                  *processInstance;

@property (assign, nonatomic) AFAProcessStartFormQueueOperationType     queuedOperationType;

@end

@implementation AFAProcessStartFormViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        dispatch_queue_t formUpdatesProcessingQueue = dispatch_queue_create([[NSString stringWithFormat:@"%@.`%@ProcessingQueue", [NSBundle mainBundle].bundleIdentifier, NSStringFromClass([self class])] UTF8String], DISPATCH_QUEUE_SERIAL);
        
        ASDKBootstrap *sdkBootstrap = [ASDKBootstrap sharedInstance];
        ASDKFormNetworkServices *formNetworkService = [sdkBootstrap.serviceLocator serviceConformingToProtocol:@protocol(ASDKFormNetworkServiceProtocol)];
        formNetworkService.resultsQueue = formUpdatesProcessingQueue;
        
        _startFormRenderEngine = [[ASDKFormRenderEngine alloc] initWithDelegate:self];
        _startFormRenderEngine.formNetworkServices = formNetworkService;
        
        self.queuedOperationType = AFAProcessStartFormQueueOperationTypeUndefined;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.backBarButtonItem setTitleTextAttributes:@{NSFontAttributeName           : [UIFont glyphiconFontWithSize:15],
                                                     NSForegroundColorAttributeName: [UIColor whiteColor]}
                                          forState:UIControlStateNormal];
    self.backBarButtonItem.title = [NSString iconStringForIconType:ASDKGlyphIconTypeChevronLeft];
    
    switch (self.queuedOperationType) {
        case AFAProcessStartFormQueueOperationTypeProcessDefinition: {
            self.navigationBarTitle = self.processDefinition.name;
            [self setupStartFormForProcessDefinitionObject:self.processDefinition];
        }
            break;
            
        case AFAProcessStartFormQueueOperationTypeProcessInstance: {
            self.navigationBarTitle = self.processInstance.name;
            [self setupStartFormForProcessInstanceObject:self.processInstance];
        }
            break;
            
        default:
            break;
    }
    
    self.queuedOperationType = AFAProcessStartFormQueueOperationTypeNone;
}


#pragma mark -
#pragma mark Actions

- (IBAction)onBack:(id)sender {
    [self performSegueWithIdentifier:kSegueIDProcessInstanceViewCompletedStartFormUnwind
                              sender:sender];
}

- (void)setupStartFormForProcessDefinitionObject:(ASDKModelProcessDefinition *)processDefinition {
    NSParameterAssert(processDefinition);
    
    if (self.queuedOperationType == AFAProcessStartFormQueueOperationTypeUndefined) {
        self.queuedOperationType = AFAProcessStartFormQueueOperationTypeProcessDefinition;
        self.processDefinition = processDefinition;
    } else {
        if (processDefinition != self.processDefinition ||
            self.queuedOperationType != AFAProcessStartFormQueueOperationTypeUndefined) {
            self.processDefinition = processDefinition;
            
            self.activityView.hidden = NO;
            self.activityView.animating = YES;
            
            [self.startFormRenderEngine setupWithProcessDefinition:processDefinition];
        }
    }
}

- (void)setupStartFormForProcessInstanceObject:(ASDKModelProcessInstance *)processInstance {
    NSParameterAssert(processInstance);
    
    if (self.queuedOperationType == AFAProcessStartFormQueueOperationTypeUndefined) {
        self.queuedOperationType = AFAProcessStartFormQueueOperationTypeProcessInstance;
        self.processInstance = processInstance;
    } else {
        if (processInstance != self.processInstance ||
            self.queuedOperationType != AFAProcessStartFormQueueOperationTypeUndefined) {
            self.processInstance = processInstance;
            
            self.activityView.hidden = NO;
            self.activityView.animating = YES;
            
            
            [self.startFormRenderEngine setupWithProcessInstance:processInstance];
        }
    }
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
         [NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|[formView]-%d-|", 0]
                                                 options:0
                                                 metrics:nil
                                                   views:views]];
    } else {
        if (kASDKFormRenderEngineUnsupportedFormFieldsCode == error.code) {
            self.noContentView.iconImageView.image = [UIImage imageNamed:@"form-warning-icon"];
            self.noContentView.descriptionLabel.text = NSLocalizedString(kLocalizationAlertDialogTaskFormUnsupportedFormFieldsText, @"Unsupported form fields error");
            self.noContentView.hidden = NO;
        } else {
            [self showGenericErrorAlertControllerWithMessage:NSLocalizedString(kLocalizationAlertDialogTaskFormCannotSetUpErrorText, @"Form set up error")];
        }
    }
    
    self.activityView.animating = NO;
    self.activityView.hidden = YES;
}

- (void)didCompleteStartForm:(ASDKModelProcessInstance *)processInstance
                       error:(NSError *)error {
    if (error) {
        [self showGenericNetworkErrorAlertControllerWithMessage:NSLocalizedString(kLocalizationAlertDialogTaskFormCannotSetUpErrorText, @"Form set up error")];
    } else {
        if (self.delegate) {
            [self.delegate didCompleteFormWithProcessInstance:processInstance];
        }
    }
}


#pragma mark -
#pragma mark ASDKFormControllerNavigationProtocol

- (void)prepareToPresentDetailController:(UIViewController *)controller {
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

@end

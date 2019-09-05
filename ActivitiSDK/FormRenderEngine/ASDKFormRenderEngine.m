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

#import "ASDKFormRenderEngine.h"
@import UIKit;

// Constants
#import "ASDKFormRenderEngineConstants.h"

// Controllers
#import "ASDKFormCollectionViewController.h"

// Models
#import "ASDKFormFieldValueRequestRepresentation.h"
#import "ASDKModelFormFieldValue.h"
#import "ASDKModelFormField.h"
#import "ASDKModelRestFormField.h"
#import "ASDKModelFormDescription.h"
#import "ASDKModelFormTabDescription.h"
#import "ASDKModelFormConfiguration.h"
#import "ASDKModelFormPreProcessorResponse.h"
#import "ASDKModelTaskFormPreProcessorResponse.h"
#import "ASDKModelStartFormPreProcessorResponse.h"
#import "ASDKDataAccessorResponseFormModel.h"

// Managers
#import "ASDKFormRenderDataSource.h"
#import "ASDKDynamicTableRenderDataSource.h"
#import "ASDKFormEngineActionHandler.h"
#import "ASDKFormDataAccessor.h"
#import "ASDKFormPreProcessor.h"
#import "ASDKServiceDataAccessorProtocol.h"

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

@interface ASDKFormRenderEngine () <ASDKDataAccessorDelegate,
                                    ASDKFormPreProcessorDelegate>

/**
 *  Property meant to hold a reference to the form data source
 */
@property (strong, nonatomic) ASDKFormRenderDataSource                  *dataSource;

/**
 * Property meant to hold a reference to the form controller
 */
@property (strong, nonatomic) ASDKFormCollectionViewController          *formViewController;

/**
 * Property meant to hold a reference to the form description model.
 */
@property (strong, nonatomic) ASDKModelFormDescription                  *formDescription;

/**
 * Property meant to hold a reference to a subset of elements from the form description mode
 * which describes the structure of a dynamic table.
 */
@property (strong, nonatomic) NSArray                                   *dynamicTableRowFormFields;


/**
 * Property meant to indicate whether a cache or network call has failed fetching a form description
 * and the engine is waiting for a successful operation.
 */
@property (assign, nonatomic) BOOL                                      pendingSuccessfullFormDescription;

/**
 * Data accessors responsable with fetching network or cached data
 */
@property (strong, nonatomic) ASDKFormDataAccessor                      *completeTaskFormDataAccessor;
@property (strong, nonatomic) ASDKFormDataAccessor                      *completeProcessDefinitionFormDataAccessor;
@property (strong, nonatomic) ASDKFormDataAccessor                      *saveFormDataAccessor;
@property (strong, nonatomic) ASDKFormDataAccessor                      *saveIntermediateFormDataAccessor;
@property (strong, nonatomic) ASDKFormDataAccessor                      *fetchTaskFormDescriptionDataAccessor;
@property (strong, nonatomic) ASDKFormDataAccessor                      *fetchProcessInstanceFormDescriptionDataAccessor;
@property (strong, nonatomic) ASDKFormDataAccessor                      *fetchProcessDefinitionFormDescriptionDataAccessor;

@end

@implementation ASDKFormRenderEngine


#pragma mark -
#pragma mark Life cycle

- (instancetype)initWithDelegate:(id<ASDKFormRenderEngineDelegate>)delegate {
    self = [super init];
    
    if (self) {
        _actionHandler = [ASDKFormEngineActionHandler new];
        _delegate = delegate;
    }
    
    return self;
}


#pragma mark -
#pragma mark ASDKFormRenderEngineProtocol

- (void)setupWithTaskModel:(ASDKModelTask *)task {
    NSParameterAssert(task);
    self.task = task;
    
    self.fetchTaskFormDescriptionDataAccessor = [[ASDKFormDataAccessor alloc] initWithDelegate:self];
    [self.fetchTaskFormDescriptionDataAccessor fetchFormDescriptionForTaskID:task.modelID];
}

- (void)setupWithProcessInstance:(ASDKModelProcessInstance *)processInstance {
    NSParameterAssert(processInstance);
    self.processInstance = processInstance;
    
    self.fetchProcessInstanceFormDescriptionDataAccessor = [[ASDKFormDataAccessor alloc] initWithDelegate:self];
    [self.fetchProcessInstanceFormDescriptionDataAccessor fetchFormDescriptionForProcessInstanceID:processInstance.modelID];
}

- (void)setupWithProcessDefinition:(ASDKModelProcessDefinition *)processDefinition {
    NSParameterAssert(processDefinition);
    self.processDefinition = processDefinition;
    
    self.fetchProcessDefinitionFormDescriptionDataAccessor = [[ASDKFormDataAccessor alloc] initWithDelegate:self];
    [self.fetchProcessDefinitionFormDescriptionDataAccessor fetchFormDescriptionForProcessDefinitionID:processDefinition.modelID];
}

- (void)setupWithDynamicTableRowFormFields:(NSArray *)dynamicTableRowFormFields
                   dynamicTableFormFieldID:(NSString *)dynamicTableFormFieldID
                                 taskModel:(ASDKModelTask *)task {
    // Check mandatory parameteres
    NSParameterAssert(dynamicTableRowFormFields);
    NSParameterAssert(dynamicTableFormFieldID);
    NSParameterAssert(task);
    
    self.task = task;
    self.dynamicTableRowFormFields = dynamicTableRowFormFields;
    
    self.formPreProcessor = [[ASDKFormPreProcessor alloc] initWithDelegate:self];
    [self.formPreProcessor setupWithTaskID:task.modelID
                            withFormFields:dynamicTableRowFormFields
                   withDynamicTableFieldID:dynamicTableFormFieldID];
    
    if ([self.delegate respondsToSelector:@selector(didRequestAdditionalInformationForFormDescription:)]) {
        [self.delegate didRequestAdditionalInformationForFormDescription:self.formDescription];
    }
}

- (void)setupWithDynamicTableRowFormFields:(NSArray *)dynamicTableRowFormFields
                   dynamicTableFormFieldID:(NSString *)dynamicTableFormFieldID
                         processDefinition:(ASDKModelProcessDefinition *)processDefinition {
    // Check mandatory parameteres
    NSParameterAssert(dynamicTableRowFormFields);
    NSParameterAssert(processDefinition);
    NSParameterAssert(dynamicTableFormFieldID);
    
    self.processDefinition = processDefinition;
    self.dynamicTableRowFormFields = dynamicTableRowFormFields;
    
    // Set up the data source for the form collection view controller
    self.dataSource = [[ASDKDynamicTableRenderDataSource alloc] initWithFormFields:dynamicTableRowFormFields];
    self.dataSource.isReadOnlyForm = self.task.endDate ? YES : NO;
    
    self.formPreProcessor = [[ASDKFormPreProcessor alloc] initWithDelegate:self];
    [self.formPreProcessor setupWithProcessDefinitionID:processDefinition.modelID
                                         withFormFields:dynamicTableRowFormFields
                                withDynamicTableFieldID:dynamicTableFormFieldID];
    
    if ([self.delegate respondsToSelector:@selector(didRequestAdditionalInformationForFormDescription:)]) {
        [self.delegate didRequestAdditionalInformationForFormDescription:self.formDescription];
    }
}

- (UICollectionViewController *)setupWithTabFormDescription:(ASDKModelFormTabDescription *)formDescription {
    ASDKFormRenderDataSource *dataSource = [[ASDKFormRenderDataSource alloc] initWithTabFormDescription:formDescription];
    dataSource.isReadOnlyForm = formDescription.isReadOnlyForm;
    
    UIStoryboard *formStoryboard = [UIStoryboard storyboardWithName:kASDKFormStoryboardBundleName
                                                             bundle:[NSBundle bundleForClass:[ASDKFormCollectionViewController class]]];
    ASDKFormCollectionViewController *formCollectionViewController =
    [formStoryboard instantiateViewControllerWithIdentifier:kASDKStoryboardIDCollectionController];
    dataSource.delegate = formCollectionViewController;
    formCollectionViewController.dataSource = dataSource;
    formCollectionViewController.renderDelegate = self;
    formCollectionViewController.formConfiguration = [self formConfiguration];
    
    return formCollectionViewController;
}

- (void)completeFormWithFormFieldValueRequestRepresentation:(ASDKFormFieldValueRequestRepresentation *)formFieldValueRequestRepresentation {
    // Check which complete method should be used i.e tasks or process definitions based on the
    // initialised content
    if (self.task) {
        self.completeTaskFormDataAccessor = [[ASDKFormDataAccessor alloc] initWithDelegate:self];
        [self.completeTaskFormDataAccessor completeFormForTaskID:self.task.modelID
                         withFormFieldValueRequestRepresentation:formFieldValueRequestRepresentation];
    } else if (self.processDefinition) {
        self.completeProcessDefinitionFormDataAccessor = [[ASDKFormDataAccessor alloc] initWithDelegate:self];
        [self.completeProcessDefinitionFormDataAccessor completeFormForProcessDefinition:self.processDefinition
                                                withFormFieldValuesRequestRepresentation:formFieldValueRequestRepresentation];
    }
}

- (void)saveFormWithFormFieldValueRequestRepresentation:(ASDKFormFieldValueRequestRepresentation *)formFieldValueRequestRepresentation {
    // Cache the form description locally
    if (ASDKNetworkReachabilityStatusNotReachable == self.saveFormDataAccessor.networkReachabilityStatus ||
        ASDKNetworkReachabilityStatusUnknown == self.saveFormDataAccessor.networkReachabilityStatus) {
        self.saveIntermediateFormDataAccessor = [[ASDKFormDataAccessor alloc] initWithDelegate:self];
        [self.saveIntermediateFormDataAccessor saveFormForTaskID:self.task.modelID
                                 withFormDescription:self.formDescription];
    }
    
    /*
     * Cache the form field values request representation locally and try to submit them
     * once the connectivity is restored.
     */
    self.saveFormDataAccessor = [[ASDKFormDataAccessor alloc] initWithDelegate:self];
    [self.saveFormDataAccessor saveFormForTaskID:self.task.modelID
         withFormFieldValueRequestRepresentation:formFieldValueRequestRepresentation];
}


#pragma mark -
#pragma mark ASDKDataAccessorDelegate

- (void)dataAccessor:(id<ASDKServiceDataAccessorProtocol>)dataAccessor
 didLoadDataResponse:(ASDKDataAccessorResponseBase *)response {
    if (self.completeTaskFormDataAccessor == dataAccessor) {
        [self handleTaskFormCompletionDataAccessorResponse:response];
    } else if (self.completeProcessDefinitionFormDataAccessor == dataAccessor) {
        [self handleProcessDefinitionFormCompletionDataAccessorResponse:response];
    } else if (self.saveFormDataAccessor == dataAccessor) {
        [self handleSaveFormDataAccessorResponse:response];
    } else if (self.fetchTaskFormDescriptionDataAccessor == dataAccessor) {
        [self handleTaskFormDescriptionDataAccessorResponse:response];
    } else if (self.fetchProcessInstanceFormDescriptionDataAccessor == dataAccessor) {
        [self handleProcessInstanceFormDescriptionDataAccessorResponse:response];
    } else if (self.fetchProcessDefinitionFormDescriptionDataAccessor == dataAccessor) {
        [self handleProcessDefinitionFormDescriptionDataAccessorResponse:response];
    }
}

- (void)dataAccessorDidFinishedLoadingDataResponse:(id<ASDKServiceDataAccessorProtocol>)dataAccessor {
    if (self.saveIntermediateFormDataAccessor == dataAccessor) {
        [self handleSaveIntermediateFormDataAccessorFinishResponse];
    }
}


#pragma mark -
#pragma mark ASDKFormPreProcessorDelegate

- (void)didProcessedFormFieldsWithResponse:(ASDKModelFormPreProcessorResponse *)preProcessorResponse {
    if ([self.delegate respondsToSelector:@selector(didCompleteRequestingAdditionalInformationForFormDescription:withError:)]) {
        [self.delegate didCompleteRequestingAdditionalInformationForFormDescription:self.formDescription
                                                                          withError:preProcessorResponse.error];
    }
    [self handleGenericPreProcessorResponse:preProcessorResponse];
}

- (void)didProcessedCachedFormFieldsWithResponse:(ASDKModelFormPreProcessorResponse *)preProcessorResponse {
    [self handleGenericPreProcessorResponse:preProcessorResponse];
}


#pragma mark -
#pragma mark Data accessor response handlers

- (void)handleTaskFormCompletionDataAccessorResponse:(ASDKDataAccessorResponseBase *)response {
    ASDKDataAccessorResponseConfirmation *responseConfirmation = (ASDKDataAccessorResponseConfirmation *)response;
    
    if (self.delegate) {
        dispatch_async(dispatch_get_main_queue(), ^{
           [self.delegate didCompleteFormWithError:responseConfirmation.error];
        });
    }
}

- (void)handleProcessDefinitionFormCompletionDataAccessorResponse:(ASDKDataAccessorResponseBase *)response {
    ASDKDataAccessorResponseModel *responseModel = (ASDKDataAccessorResponseModel *)response;
    ASDKModelProcessInstance *processInstance = responseModel.model;
    
    if (self.delegate) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate didCompleteStartForm:processInstance
                                          error:responseModel.error];
        });
    }
}

- (void)handleSaveFormDataAccessorResponse:(ASDKDataAccessorResponseBase *)response {
    ASDKDataAccessorResponseConfirmation *responseConfirmation = (ASDKDataAccessorResponseConfirmation *)response;
    
    if (self.delegate) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate didSaveFormWithError:responseConfirmation.error];
        });
    }
}

- (void)handleSaveIntermediateFormDataAccessorFinishResponse {
    if (self.delegate) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate didSaveFormInOfflineMode];
        });
    }
}

- (void)handleTaskFormDescriptionDataAccessorResponse:(ASDKDataAccessorResponseBase *)response {
    [self handleFormDescriptionDataAccessorResponse:response];
    
    ASDKDataAccessorResponseFormModel *formResponseModel = (ASDKDataAccessorResponseFormModel *)response;
    if (!formResponseModel.isSavedForm) {
        if (self.formDescription && formResponseModel.model) {
            self.formPreProcessor = [[ASDKFormPreProcessor alloc] initWithDelegate:self];
            [self.formPreProcessor setupWithTaskID:self.task.modelID
                                    withFormFields:self.formDescription.formFields
                           withDynamicTableFieldID:nil];
            
            if ([self.delegate respondsToSelector:@selector(didRequestAdditionalInformationForFormDescription:)]) {
                [self.delegate didRequestAdditionalInformationForFormDescription:self.formDescription];
            }
        }
    } else {
        [self handleTaskFormCreationFromCurrentFormDescription];
    }
}

- (void)handleProcessInstanceFormDescriptionDataAccessorResponse:(ASDKDataAccessorResponseBase *)response {
    [self handleFormDescriptionDataAccessorResponse:response];
    
    if (self.formDescription) {
        self.formPreProcessor = [[ASDKFormPreProcessor alloc] initWithDelegate:self];
        [self.formPreProcessor setupWithProcessDefinitionID:self.processInstance.processDefinitionID
                                             withFormFields:self.formDescription.formFields
                                    withDynamicTableFieldID:nil];
        
        if ([self.delegate respondsToSelector:@selector(didRequestAdditionalInformationForFormDescription:)]) {
            [self.delegate didRequestAdditionalInformationForFormDescription:self.formDescription];
        }
    }
}

- (void)handleProcessDefinitionFormDescriptionDataAccessorResponse:(ASDKDataAccessorResponseBase *)response {
    [self handleFormDescriptionDataAccessorResponse:response];
    
    if (self.formDescription) {
        self.formPreProcessor = [[ASDKFormPreProcessor alloc] initWithDelegate:self];
        [self.formPreProcessor setupWithProcessDefinitionID:self.processDefinition.modelID
                                             withFormFields:self.formDescription.formFields
                                    withDynamicTableFieldID:nil];
        
        if ([self.delegate respondsToSelector:@selector(didRequestAdditionalInformationForFormDescription:)]) {
            [self.delegate didRequestAdditionalInformationForFormDescription:self.formDescription];
        }
    }
}

- (void)handleFormDescriptionDataAccessorResponse:(ASDKDataAccessorResponseBase *)response {
    ASDKDataAccessorResponseModel *responseModel = (ASDKDataAccessorResponseModel *)response;
    
    // Check for form description errors first
    if (responseModel.error || !responseModel.model) {
        if (self.pendingSuccessfullFormDescription) {
            __weak typeof(self) weakSelf = self;
            dispatch_async(dispatch_get_main_queue(), ^{
                __strong typeof(self) strongSelf = weakSelf;
                
                [strongSelf.delegate didRenderedFormController:nil
                                                         error:[strongSelf renderEngineSetupError]];
            });
        } else {
            self.pendingSuccessfullFormDescription = YES;
        }
        
        if (responseModel.error && (NSURLErrorNotConnectedToInternet != responseModel.error.code)) {
            if (self.delegate) {
                __weak typeof(self) weakSelf = self;
                dispatch_async(dispatch_get_main_queue(), ^{
                    __strong typeof(self) strongSelf = weakSelf;
                    
                    [strongSelf.delegate didRenderedFormController:nil
                                                             error:responseModel.error];
                });
            }
        }
        return;
    } else {
        // If dealing with an empty cache response ignore and wait for network data
        if (responseModel.model) {
            ASDKModelFormDescription *formDescription = responseModel.model;
            
            // Deep copy all form fields so that the initial collection remains untouched by future mutations
            NSData *buffer = [NSKeyedArchiver archivedDataWithRootObject:formDescription];
            ASDKModelFormDescription *formDescriptionCopy = [NSKeyedUnarchiver unarchiveObjectWithData:buffer];
            
            self.formDescription = formDescriptionCopy;
        }
    }
}


#pragma mark -
#pragma mark Form preprocessor handlers

- (void)handleGenericPreProcessorResponse:(ASDKModelFormPreProcessorResponse *)preProcessorResponse {
    if (preProcessorResponse.dynamicTableFieldID.length) {
        [self handleDynamicTableFormPreprocessorResponse:preProcessorResponse];
    } else if ([preProcessorResponse isKindOfClass:[ASDKModelTaskFormPreProcessorResponse class]]) {
        [self handleTaskFormPreprocessorResponse:preProcessorResponse];
    } else if ([preProcessorResponse isKindOfClass:[ASDKModelStartFormPreProcessorResponse class]]) {
        [self handleStartFormPreprocessorResponse:preProcessorResponse];
    }
}

- (void)handleTaskFormPreprocessorResponse:(ASDKModelFormPreProcessorResponse *)preProcessorResponse {
    self.formDescription.formFields = preProcessorResponse.processedFormFields;
    self.formDescription.formVariables = preProcessorResponse.formVariables;
    
    [self handleTaskFormCreationFromCurrentFormDescription];
}

- (void)handleTaskFormCreationFromCurrentFormDescription {
    if ([self.formDescription doesFormDescriptionContainSupportedFormFields]) {
        // Set up the data source for the form collection view controller
        ASDKFormRenderDataSource *dataSource = [[ASDKFormRenderDataSource alloc] initWithTaskFormDescription:self.formDescription];
        dataSource.isReadOnlyForm = self.task.endDate ? YES : NO;
        
        // Always dispatch on the main queue results related to the form view
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(self) strongSelf = weakSelf;
            
            NSError *error = nil;
            UICollectionViewController<ASDKFormControllerNavigationProtocol> *formCollectionViewController =
            [strongSelf formWithDataSource:dataSource];
            
            if (!formCollectionViewController &&
                !strongSelf.formViewController) {
                error = [strongSelf renderEngineSetupError];
            }
            
            /* Report results only if dealing with an error or if it is
             * the first render of a form.
             * Note: When returning cached data along with network data
             * subsequent controllers are not provided. Only the data source
             * is updated for the already existing one
             */
            if (formCollectionViewController ||
                error) {
                if (strongSelf.delegate) {
                    [strongSelf.delegate didRenderedFormController:formCollectionViewController
                                                             error:error];
                }
            }
        });
    } else {
        if (self.delegate) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate didRenderedFormController:nil
                                                   error:[self renderEngineSetupUnsupportedFormFieldsError]];
            });
        }
    }
}

- (void)handleStartFormPreprocessorResponse:(ASDKModelFormPreProcessorResponse *)preProcessorResponse {
    self.formDescription.formFields = preProcessorResponse.processedFormFields;
    
    if ([self.formDescription doesFormDescriptionContainSupportedFormFields]) {
        // Set up the data source for the form collection view controller
        ASDKFormRenderDataSource *dataSource = [[ASDKFormRenderDataSource alloc] initWithProcessDefinitionFormDescription:self.formDescription];
        dataSource.isReadOnlyForm = self.processInstance ? YES : NO;
        
        // Always dispatch on the main queue results related to the form view
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(self) strongSelf = weakSelf;
            
            NSError *error = nil;
            UICollectionViewController<ASDKFormControllerNavigationProtocol> *formCollectionViewController =
            [strongSelf formWithDataSource:dataSource];
            
            if (!formCollectionViewController &&
                !strongSelf.formViewController) {
                error = [strongSelf renderEngineSetupError];
            }
            
            /* Report results only if dealing with an error or if it is
             * the first render of a form.
             * Note: When returning cached data along with network data
             * subsequent controllers are not provided. Only the data source
             * is updated for the already existing one
             */
            if (formCollectionViewController ||
                error) {
                if (strongSelf.delegate) {
                    [strongSelf.delegate didRenderedFormController:formCollectionViewController
                                                             error:error];
                }
            }
        });
    } else {
        if (self.delegate) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate didRenderedFormController:nil
                                                   error:[self renderEngineSetupUnsupportedFormFieldsError]];
            });
        }
    }
}

- (void)handleDynamicTableFormPreprocessorResponse:(ASDKModelFormPreProcessorResponse *)preProcessorResponse {
    // Set up the data source for the form collection view controller
    ASDKDynamicTableRenderDataSource *dataSource = [[ASDKDynamicTableRenderDataSource alloc] initWithFormFields:self.dynamicTableRowFormFields];
    dataSource.isReadOnlyForm = self.task.endDate ? YES : NO;
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
       __strong typeof(self) strongSelf = weakSelf;
        
        NSError *error = nil;
        UICollectionViewController<ASDKFormControllerNavigationProtocol> *formCollectionViewController = [strongSelf formWithDataSource:dataSource];
        
        if (!formCollectionViewController &&
            !strongSelf.formViewController) {
            error = [strongSelf renderEngineSetupError];
        }
        
        /* Report results only if dealing with an error or if it is
         * the first render of a form.
         * Note: When returning cached data along with network data
         * subsequent controllers are not provided. Only the data source
         * is updated for the already existing one
         */
        if (formCollectionViewController ||
            error) {
            if (strongSelf.delegate) {
                [strongSelf.delegate didRenderedFormController:formCollectionViewController
                                                         error:error];
            }
        }
    });
}


#pragma mark -
#pragma mark Private interface

- (ASDKFormCollectionViewController *)formWithDataSource:(ASDKFormRenderDataSource *)dataSource {
    BOOL justReplaceControllerDataSource = NO;
    
    self.dataSource = dataSource;
    
    if (!self.formViewController) {
        UIStoryboard *formStoryboard = [UIStoryboard storyboardWithName:kASDKFormStoryboardBundleName
                                                                 bundle:[NSBundle bundleForClass:[ASDKFormCollectionViewController class]]];
        self.formViewController = [formStoryboard instantiateViewControllerWithIdentifier:kASDKStoryboardIDCollectionController];
        self.formViewController.renderDelegate = self;
        self.formViewController.dataSource = self.dataSource;
        
    } else {
        self.formViewController.renderDelegate = self;
        [self.formViewController replaceExistingDataSource:dataSource];
        justReplaceControllerDataSource = YES;
    }
    
    self.dataSource.delegate = self.formViewController;
    
    // Pass on the form configuration for subsequent querries
    self.formViewController.formConfiguration = [self formConfiguration];
    
    return justReplaceControllerDataSource ? nil : self.formViewController;
}

- (ASDKModelFormConfiguration *)formConfiguration {
    ASDKModelFormConfiguration *formConfiguration = [ASDKModelFormConfiguration new];
    formConfiguration.task = self.task;
    formConfiguration.processInstance = self.processInstance;
    formConfiguration.processDefinition = self.processDefinition;
    
    return formConfiguration;
}


#pragma mark -
#pragma mark Errors

- (NSError *)renderEngineSetupError {
    NSDictionary *userInfo = @{NSLocalizedDescriptionKey            : @"Setup operation for form controller failed.",
                               NSLocalizedFailureReasonErrorKey     : @"The operation could not be completed because the form render engine could not generate the form view.",
                               NSLocalizedRecoverySuggestionErrorKey: @"Please check your form description model and make sure it has all the information needed to render."
                               };
    NSError *error = [NSError errorWithDomain:kASDKFormRenderEngineErrorDomain
                                         code:kASDKFormRenderEngineSetupErrorCode
                                     userInfo:userInfo];
    
    return error;
}

- (NSError *)renderEngineSetupUnsupportedFormFieldsError {
    NSDictionary *userInfo = @{NSLocalizedDescriptionKey :                @"Setup operation for form controller failed",
                               NSLocalizedFailureReasonErrorKey :         @"The operation could not be completed because the form description contains unsupported form fields.",
                               NSLocalizedRecoverySuggestionErrorKey :    @"Please check the web client form definition and make sure you are compliant to the mobile SDK supported form fields."
                               };
    NSError *error = [NSError errorWithDomain:kASDKFormRenderEngineErrorDomain
                                         code:kASDKFormRenderEngineUnsupportedFormFieldsCode
                                     userInfo:userInfo];
    
    return error;
}

@end

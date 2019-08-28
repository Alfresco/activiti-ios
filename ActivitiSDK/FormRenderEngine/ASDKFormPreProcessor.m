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

#import "ASDKFormPreProcessor.h"

// Data accessors
#import "ASDKFormDataAccessor.h"

// Models
#import "ASDKModelFormField.h"
#import "ASDKModelFormFieldValue.h"
#import "ASDKModelRestFormField.h"
#import "ASDKModelAmountFormField.h"
#import "ASDKModelHyperlinkFormField.h"
#import "ASDKModelDynamicTableFormField.h"
#import "ASDKModelFormFieldOption.h"
#import "ASDKDataAccessorResponseCollection.h"
#import "ASDKModelFormPreProcessorResponse.h"
#import "ASDKModelTaskFormPreProcessorResponse.h"
#import "ASDKModelStartFormPreProcessorResponse.h"

@interface ASDKFormPreProcessor ()

// Internals
@property (strong, nonatomic) NSString                              *taskID;
@property (strong, nonatomic) NSString                              *processDefinitionID;
@property (strong, nonatomic) NSString                              *dynamicTableFieldID;
@property (assign, nonatomic) BOOL                                  isStartForm;
@property (strong, nonatomic) NSMutableDictionary                   *formFieldOptionDataAccessorMap;
@property (assign, nonatomic) ASDKServiceDataAccessorCachingPolicy  cachingPolicy;
@property (strong, nonatomic) NSArray                               *processingFormFields;
@property (strong, nonatomic) NSArray                               *formVariables;
@property (strong, nonatomic) dispatch_group_t                      firstTrackDependenciesGroup;
@property (strong, nonatomic) dispatch_group_t                      secondTrackDependenciesGroup;
@property (strong, nonatomic) dispatch_queue_t                      preprocessorProcessingQueue;

// Services
@property (strong, nonatomic) ASDKFormDataAccessor                  *fetchRestFieldValuesForTaskFormDataAccessor;
@property (strong, nonatomic) ASDKFormDataAccessor                  *fetchRestFieldValuesForDynamicTableInTaskFormDataAccessor;
@property (strong, nonatomic) ASDKFormDataAccessor                  *fetchRestFieldValuesForStartFormDataAccessor;
@property (strong, nonatomic) ASDKFormDataAccessor                  *fetchRestFieldValuesForDynamicTableInStartFormDataAccessor;
@property (strong, nonatomic) ASDKFormDataAccessor                  *fetchFormVariablesDataAccessor;

@end

@implementation ASDKFormPreProcessor


#pragma mark -
#pragma mark Lifecycle

- (instancetype)initWithDelegate:(id<ASDKFormPreProcessorDelegate>)delegate {
    self = [super init];
    if (self) {
        _cachingPolicy = ASDKServiceDataAccessorCachingPolicyHybrid;
        _formFieldOptionDataAccessorMap = [NSMutableDictionary dictionary];
        _delegate = delegate;
        _preprocessorProcessingQueue = dispatch_queue_create([[NSString stringWithFormat:@"%@.`%@ProcessingQueue",
                                                                              [NSBundle bundleForClass:[self class]].bundleIdentifier,
                                                                              NSStringFromClass([self class])] UTF8String], DISPATCH_QUEUE_SERIAL);
    }
    
    return self;
}


#pragma mark -
#pragma mark Public interface

- (void)setupWithTaskID:(NSString *)taskID
         withFormFields:(NSArray *)formFields
withDynamicTableFieldID:(NSString *)dynamicTableFieldID {
    NSParameterAssert(taskID);
    NSParameterAssert(formFields);
    
    self.isStartForm = NO;
    self.taskID = taskID;
    self.dynamicTableFieldID = dynamicTableFieldID;
    self.processingFormFields = formFields;
    
    /**
     * Create dispatch groups for all the augmenting calls needed to complete the
     * form description in accordance to the caching policy
     */
    [self handleDependencyGroupCreationForFormFields:formFields];
    [self preProcessFormVariables];
    [self preprocessFormFields:formFields];
    
    ASDKModelTaskFormPreProcessorResponse *taskFormPreProcessorResponse = [ASDKModelTaskFormPreProcessorResponse new];
    taskFormPreProcessorResponse.taskID = self.taskID;
    taskFormPreProcessorResponse.dynamicTableFieldID = self.dynamicTableFieldID;
    
    [self handleDelegateNotificationWithResponse:taskFormPreProcessorResponse];
}

- (void)setupWithProcessDefinitionID:(NSString *)processDefinitionID
                      withFormFields:(NSArray *)formFields
             withDynamicTableFieldID:(NSString *)dynamicTableFieldID {
    NSParameterAssert(processDefinitionID);
    NSParameterAssert(formFields);
    
    self.isStartForm = YES;
    self.processDefinitionID = processDefinitionID;
    self.dynamicTableFieldID = dynamicTableFieldID;
    self.processingFormFields = formFields;
    
    /**
     * Create dispatch groups for all the augmenting calls needed to complete the
     * form description in accordance to the caching policy
     */
    [self handleDependencyGroupCreationForFormFields:formFields];
    [self preprocessFormFields:formFields];
    
    ASDKModelStartFormPreProcessorResponse *startFormPreProcessorResponse = [ASDKModelStartFormPreProcessorResponse new];
    startFormPreProcessorResponse.processDefinitionID = self.processDefinitionID;
    startFormPreProcessorResponse.dynamicTableFieldID = self.dynamicTableFieldID;
    
    [self handleDelegateNotificationWithResponse:startFormPreProcessorResponse];
}


#pragma mark -
#pragma mark ASDKDataAccessorDelegate

- (void)dataAccessor:(id<ASDKServiceDataAccessorProtocol>)dataAccessor
 didLoadDataResponse:(ASDKDataAccessorResponseBase *)response {
    if (self.fetchFormVariablesDataAccessor == dataAccessor) {
        ASDKDataAccessorResponseCollection *formVariableResponse = (ASDKDataAccessorResponseCollection *)response;
        self.formVariables = formVariableResponse.collection;
    } else {
        if (!response.error) {
            ASDKDataAccessorResponseCollection *restFieldValuesResponse = (ASDKDataAccessorResponseCollection *)response;
            ASDKModelFormField *correspondentFormField = [self.formFieldOptionDataAccessorMap objectForKey:dataAccessor];
            correspondentFormField.formFieldOptions = restFieldValuesResponse.collection;
        }
    }
    
    if (response.isCachedData) {
        dispatch_group_leave(self.secondTrackDependenciesGroup);
    } else {
        dispatch_group_leave(self.firstTrackDependenciesGroup);
    }
}

- (void)dataAccessorDidFinishedLoadingDataResponse:(id<ASDKServiceDataAccessorProtocol>)dataAccessor {
}


#pragma mark -
#pragma mark Private interface

- (void)preProcessFormVariables {
    if (ASDKServiceDataAccessorCachingPolicyHybrid == self.cachingPolicy) {
        dispatch_group_enter(self.secondTrackDependenciesGroup);
    }
    dispatch_group_enter(self.firstTrackDependenciesGroup);
    
    self.fetchFormVariablesDataAccessor = [[ASDKFormDataAccessor alloc] initWithDelegate:self];
    [self.fetchFormVariablesDataAccessor fetchFormVariablesForTaskID:self.taskID];
}

- (void)preprocessFormFields:(NSArray *)formFields {
    for (ASDKModelFormField *formField in formFields) {
        if (ASDKModelFormFieldTypeContainer == formField.fieldType) {
            for (ASDKModelFormField *formFieldInContainer in formField.formFields) {
                [self preProcessFormField:formFieldInContainer];
            }
        } else {
            [self preProcessFormField:formField];
        }
    }
}

- (void)preProcessFormField:(ASDKModelFormField *)formField {
    NSInteger representationType = ASDKModelFormFieldRepresentationTypeUndefined;
    
    // If dealing with read-only forms extract the representation type from the attached
    // form field params model
    if (ASDKModelFormFieldRepresentationTypeReadOnly == formField.representationType) {
        representationType = formField.formFieldParams.representationType;
    } else {
        representationType = formField.representationType;
    }
    
    switch (representationType) {
        case ASDKModelFormFieldRepresentationTypeDropdown:
        case ASDKModelFormFieldRepresentationTypeRadio:
        case ASDKModelFormFieldRepresentationTypeTypeahead: {
            [self handleMultipleChoiceFormField:formField];
        }
            break;
            
        case ASDKModelFormFieldRepresentationTypeAmount: {
            [self handleAmountFormField:formField];
        }
            break;
            
        case ASDKModelFormFieldRepresentationTypeHyperlink: {
            [self handleHyperlinkFormField:formField];
        }
            break;
            
        case ASDKModelFormFieldRepresentationTypeDynamicTable: {
            [self handleDynamicTableFormField:formField];
        }
            break;
            
        default: break;
    }
}

- (void)handleDependencyGroupCreationForFormFields:(NSArray *)formFields {
    self.firstTrackDependenciesGroup = dispatch_group_create();
    if (ASDKServiceDataAccessorCachingPolicyHybrid == self.cachingPolicy) {
        self.secondTrackDependenciesGroup = dispatch_group_create();
    }
    
    for (ASDKModelFormField *formField in formFields) {
        if (ASDKModelFormFieldTypeContainer == formField.fieldType) {
            for (ASDKModelFormField *formFieldInContainer in formField.formFields) {
                [self markGroupDependencyForFormField:formFieldInContainer];
            }
        } else {
            [self markGroupDependencyForFormField:formField];
        }
    }
}

- (void)markGroupDependencyForFormField:(ASDKModelFormField *)formField {
    NSInteger representationType = ASDKModelFormFieldRepresentationTypeUndefined;
    
    // If dealing with read-only forms extract the representation type from the attached
    // form field params model
    if (ASDKModelFormFieldRepresentationTypeReadOnly == formField.representationType) {
        representationType = formField.formFieldParams.representationType;
    } else {
        representationType = formField.representationType;
    }
    
    if (ASDKModelFormFieldRepresentationTypeDropdown == representationType ||
        ASDKModelFormFieldRepresentationTypeRadio == representationType ||
        ASDKModelFormFieldRepresentationTypeTypeahead == representationType) {
        ASDKModelRestFormField *restFormField = (ASDKModelRestFormField *)formField;
        
        if ([restFormField respondsToSelector:@selector(restURL)] &&
            restFormField.restURL) {
            // Marking entry to processing groups based on the set cache policy
            if (ASDKServiceDataAccessorCachingPolicyHybrid == self.cachingPolicy) {
                dispatch_group_enter(self.secondTrackDependenciesGroup);
            }
            dispatch_group_enter(self.firstTrackDependenciesGroup);
        }
    }
}

- (void)handleDelegateNotificationWithResponse:(ASDKModelFormPreProcessorResponse *)formPreProcessorResponse {
    // Dispatch groups finished
    __weak typeof(self) weakSelf = self;
    dispatch_group_notify(self.firstTrackDependenciesGroup, self.preprocessorProcessingQueue,^{
        __strong typeof(self) strongSelf = weakSelf;
        
        if (strongSelf.delegate) {
            // Deep copy all form fields so that the initial collection remains untouched by future mutations
            NSData *buffer = [NSKeyedArchiver archivedDataWithRootObject:strongSelf.processingFormFields];
            NSArray *processedFormFieldsCopy = [NSKeyedUnarchiver unarchiveObjectWithData:buffer];
            formPreProcessorResponse.processedFormFields = processedFormFieldsCopy;
            formPreProcessorResponse.formVariables = strongSelf.formVariables;
            
            [strongSelf.delegate didProcessedFormFieldsWithResponse:formPreProcessorResponse];
        }
    });
    
    dispatch_group_notify(self.secondTrackDependenciesGroup, self.preprocessorProcessingQueue, ^{
       __strong typeof(self) strongSelf = weakSelf;
        
        if (strongSelf.delegate) {
            // Deep copy all form fields so that the initial collection remains untouched by future mutations
            NSData *buffer = [NSKeyedArchiver archivedDataWithRootObject:strongSelf.processingFormFields];
            NSArray *processedFormFieldsCopy = [NSKeyedUnarchiver unarchiveObjectWithData:buffer];
            formPreProcessorResponse.processedFormFields = processedFormFieldsCopy;
            formPreProcessorResponse.formVariables = strongSelf.formVariables;
            
            [strongSelf.delegate didProcessedCachedFormFieldsWithResponse:formPreProcessorResponse];
        }
    });
}

- (void)handleMultipleChoiceFormField:(ASDKModelFormField *)formField {
    ASDKModelRestFormField *restFormField = (ASDKModelRestFormField *)formField;
    
    if ([restFormField respondsToSelector:@selector(restURL)] &&
        restFormField.restURL) {
        
        if (self.isStartForm) {
            if (self.dynamicTableFieldID) {
                self.fetchRestFieldValuesForDynamicTableInStartFormDataAccessor = [[ASDKFormDataAccessor alloc] initWithDelegate:self];

                // Map data accessors to appropiate form fields in order to match responses
                [self.formFieldOptionDataAccessorMap setObject:formField
                                                        forKey:self.fetchRestFieldValuesForDynamicTableInStartFormDataAccessor];
                
                [self.fetchRestFieldValuesForDynamicTableInStartFormDataAccessor
                 fetchRestFieldValuesOfStartFormWithProcessDefinitionID:self.processDefinitionID
                 withFormField:self.dynamicTableFieldID
                 withColumnID:formField.modelID];
            } else {
                self.fetchRestFieldValuesForStartFormDataAccessor = [[ASDKFormDataAccessor alloc] initWithDelegate:self];
                
                // Map data accessors to appropiate form fields in order to match responses
                [self.formFieldOptionDataAccessorMap setObject:formField
                                                        forKey:self.fetchRestFieldValuesForStartFormDataAccessor];
                
                [self.fetchRestFieldValuesForStartFormDataAccessor
                 fetchRestFieldValuesOfStartFormForProcessDefinitionID:self.processDefinitionID
                 withFormFieldID:formField.modelID];
            }
        } else {
            if (self.dynamicTableFieldID) {
                self.fetchRestFieldValuesForDynamicTableInTaskFormDataAccessor = [[ASDKFormDataAccessor alloc] initWithDelegate:self];
                
                // Map data accessors to appropiate form fields in order to match responses
                [self.formFieldOptionDataAccessorMap setObject:formField
                                                        forKey:self.fetchRestFieldValuesForDynamicTableInTaskFormDataAccessor];
                
                [self.fetchRestFieldValuesForDynamicTableInTaskFormDataAccessor fetchRestFieldValuesForTaskID:self.taskID
                                                                                  withFormFieldID:self.dynamicTableFieldID
                                                                                     withColumnID:formField.modelID];
            } else {
                self.fetchRestFieldValuesForTaskFormDataAccessor = [[ASDKFormDataAccessor alloc] initWithDelegate:self];
                
                // Map data accessors to appropiate form fields in order to match responses
                [self.formFieldOptionDataAccessorMap setObject:formField
                                                        forKey:self.fetchRestFieldValuesForTaskFormDataAccessor];
                
                [self.fetchRestFieldValuesForTaskFormDataAccessor fetchRestFieldValuesForTaskID:self.taskID
                                                                    withFormFieldID:formField.modelID];
            }
        }
    }
}

- (void)handleAmountFormField:(ASDKModelFormField *)formField {
    // Display value
    if (ASDKModelFormFieldRepresentationTypeReadOnly == formField.representationType) {
        ASDKModelAmountFormField *amountFormField = (ASDKModelAmountFormField *)formField;
        ASDKModelAmountFormField *amountFormFieldParams = (ASDKModelAmountFormField *)formField.formFieldParams;
        amountFormField.currency = amountFormFieldParams.currency;
        amountFormField.enableFractions = amountFormFieldParams.enableFractions;
    }
}

- (void)handleHyperlinkFormField:(ASDKModelFormField *)formField {
    // Display value
    if (ASDKModelFormFieldRepresentationTypeReadOnly == formField.representationType) {
        ASDKModelHyperlinkFormField *hyperlinkFormField = (ASDKModelHyperlinkFormField *)formField;
        ASDKModelHyperlinkFormField *hyperlinkFormFieldParams = (ASDKModelHyperlinkFormField *)formField.formFieldParams;
        if (hyperlinkFormFieldParams.hyperlinkURL) {
            hyperlinkFormField.hyperlinkURL = hyperlinkFormFieldParams.hyperlinkURL;
        }
        if (hyperlinkFormFieldParams.displayText) {
            hyperlinkFormField.displayText = hyperlinkFormFieldParams.displayText;
        }
    }
}

- (void)handleDynamicTableFormField:(ASDKModelFormField *)formField {
    // Populate column definition form fields with values
    if (formField.values) {
        // Display value
        if (ASDKModelFormFieldRepresentationTypeReadOnly == formField.representationType &&
            ASDKModelFormFieldRepresentationTypeDynamicTable == formField.formFieldParams.representationType &&
            !((ASDKModelDynamicTableFormField *)formField).columnDefinitions) {
            ASDKModelDynamicTableFormField *dynamicTableFormField = (ASDKModelDynamicTableFormField *)formField;
            ASDKModelDynamicTableFormField *dynamicTableFormFieldParams = (ASDKModelDynamicTableFormField *)formField.formFieldParams;
            dynamicTableFormField.columnDefinitions = dynamicTableFormFieldParams.columnDefinitions;
            dynamicTableFormField.isTableEditable = dynamicTableFormFieldParams.isTableEditable;
        }
        
        NSMutableArray *newFormFieldValues = [NSMutableArray array];
        ASDKModelDynamicTableFormField *dynamicTableFormField = (ASDKModelDynamicTableFormField *)formField;
        
        // Create column definition dictionary for quick access
        NSMutableDictionary *columnFormFieldDict = [NSMutableDictionary dictionary];
        for (ASDKModelFormField *columnFormField in dynamicTableFormField.columnDefinitions) {
            [columnFormFieldDict setValue:columnFormField
                                   forKey:columnFormField.modelID];
        }
        
        for (NSDictionary *rowValues in dynamicTableFormField.values) {
            /* Initialize array with 'column definition template' needed
             * for placing objects at specified index later
             */
            NSMutableArray *newRowFormFieldValues = [[NSMutableArray alloc] initWithCapacity:dynamicTableFormField.columnDefinitions.count];
            
            for (ASDKModelFormField *columnDefinitionTemplate in dynamicTableFormField.columnDefinitions) {
                ASDKModelFormField *newRowFormFieldValue = [columnDefinitionTemplate copy];
                if (ASDKModelFormFieldRepresentationTypeReadOnly == dynamicTableFormField.representationType) {
                    ASDKModelFormField *formFieldParams = nil;
                    if (ASDKModelFormFieldRepresentationTypeAmount == columnDefinitionTemplate.representationType) {
                        formFieldParams = [ASDKModelAmountFormField new];
                        formFieldParams.fieldName = newRowFormFieldValue.fieldName;
                    } else {
                        formFieldParams = [ASDKModelFormField new];
                    }
                    formFieldParams.representationType = newRowFormFieldValue.representationType;
                    formFieldParams.fieldName = newRowFormFieldValue.fieldName;
                    newRowFormFieldValue.formFieldParams = formFieldParams;
                    newRowFormFieldValue.representationType = ASDKModelFormFieldRepresentationTypeReadOnly;
                }
                [newRowFormFieldValues addObject:newRowFormFieldValue];
            }
            
            // Create new values based on column definition 'template'
            for (NSString *columnId in rowValues) {
                NSArray *columnDefinitionValues = [NSArray arrayWithObject:rowValues[columnId]];
                ASDKModelFormField *columnDefinitionWithValue = [[columnFormFieldDict valueForKey:columnId] copy];
                
                if (ASDKModelFormFieldRepresentationTypeReadOnly == dynamicTableFormField.representationType) {
                    ASDKModelFormField *formFieldParams = nil;
                    if (ASDKModelFormFieldRepresentationTypeAmount == columnDefinitionWithValue.representationType) {
                        formFieldParams = [ASDKModelAmountFormField new];
                        formFieldParams.fieldName = columnDefinitionWithValue.fieldName;
                    } else {
                        formFieldParams = [ASDKModelFormField new];
                    }
                    formFieldParams.representationType = columnDefinitionWithValue.representationType;
                    formFieldParams.fieldName = columnDefinitionWithValue.fieldName;
                    columnDefinitionWithValue.formFieldParams = formFieldParams;
                    
                    if (!dynamicTableFormField.isTableEditable) {
                        columnDefinitionWithValue.representationType = ASDKModelFormFieldRepresentationTypeReadOnly;
                    }
                }
                
                columnDefinitionWithValue.values = columnDefinitionValues;
                
                NSInteger newRowFormFieldValuesIndex = [self getIndexFromObjectProperty:columnId
                                                                                inArray:dynamicTableFormField.columnDefinitions];
                if (newRowFormFieldValuesIndex != NSNotFound) {
                    [newRowFormFieldValues replaceObjectAtIndex:newRowFormFieldValuesIndex
                                                     withObject:columnDefinitionWithValue];
                }
            }
            [newFormFieldValues addObject:newRowFormFieldValues];
        }
        
        formField.values = [NSArray arrayWithArray:newFormFieldValues];
    }
}

- (NSInteger)getIndexFromObjectProperty:(NSString *)property
                                inArray:(NSArray *)myArray {
    return [myArray indexOfObjectPassingTest:^(id obj, NSUInteger idx, BOOL *stop) {
        BOOL res;
        ASDKModelFormField *modelFormField = (ASDKModelFormField *)obj;
        if ([property isEqualToString:modelFormField.modelID]) {
            res = YES;
            *stop = YES;
        } else {
            res = NO;
        }
        
        return res;
    }];
}

@end

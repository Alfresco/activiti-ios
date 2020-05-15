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

#import <UIKit/UIKit.h>
#import "ASDKServiceDataAccessorProtocol.h"
#import "ASDKFormRenderEngineDelegate.h"

@class ASDKModelFormDescription,
ASDKModelFormTabDescription,
ASDKFormNetworkServices,
ASDKModelTask,
ASDKModelProcessDefinition,
ASDKModelProcessInstance,
ASDKFormFieldValueRequestRepresentation,
ASDKFormPreProcessor,
ASDKFormEngineActionHandler;


@protocol ASDKFormRenderEngineProtocol <NSObject>

/**
 * Holds a reference to the form delegate used to report state changes.
 */
@property (weak, nonatomic) id<ASDKFormRenderEngineDelegate> delegate;

/**
 *  Holds a reference to the form network service used in conjucture with the 
 *  convenience setup methods.
 */
@property (strong, nonatomic) ASDKFormNetworkServices *formNetworkServices;

/**
 * Holds a reference to the form preprocessor class used to prefetch additional
 * information needed to render the final form.
 */
@property (strong, nonatomic) ASDKFormPreProcessor *formPreProcessor;

/**
 *  Holds a reference to the form action handler object which acts as a proxy for
 *  handling actions coming from the host application and reporting form state
 *  changes inside
 */
@property (strong, nonatomic) ASDKFormEngineActionHandler *actionHandler;

/**
 * Default initializer method
 *
 * @param delegate Delegate class  used to pass form state updates
 * @return Initialized instance
 */
- (instancetype)initWithDelegate:(id<ASDKFormRenderEngineDelegate>)delegate;

/**
 *  Designated setup method for the form render engine class when it is used
 *  to show the form associated to a task. This method relies on the internal
 *  workings of the form render engine to make the API network calls on your 
 *  behalf and you will be provided with an instance of a collection view controller 
 *  via the designated delegate.
 *
 *  @param task                  Task object containing the mandatory task ID 
 *                               property.
 */
- (void)setupWithTaskModel:(ASDKModelTask *)task;

/**
 *  Designated setup method for the form render engine class when it is used to show
 *  the completed start form of a process instance. This method relies on the internal
 *  workings of the form render engine to make the API network calls on your behalf
 *  and you will be provided with an instance of a collection view controller via the
 *  designated delegate.
 *
 *  @param processInstance       Process instance object containing the mandatory process instance
 *                               ID property
 */
- (void)setupWithProcessInstance:(ASDKModelProcessInstance *)processInstance;

/**
 *  Designated setup method for the form render engine class when it is used to
 *  show the start form of a process instance. This method relies on the internal
 *  workings of the form render engine to make the API network calls on your behalf
 *  and you will be provided with an instance of a collection view controller via
 *  the designated delegate.
 *
 *  @param processDefinition     Process definition object containing the mandatory 
 *                               process definition ID property
 */
- (void)setupWithProcessDefinition:(ASDKModelProcessDefinition *)processDefinition;

/**
 *  Designated setup method for the form render engine class when it is used
 *  to show the dynamic table row associated to a task. This method relies on the internal
 *  workings of the form render engine to make the API network calls on your
 *  behalf and you will be provided with an instance of a collection view controller
 *  via the designated delegate.
 *
 *  @param dynamicTableRowFormFields    Array containing the columns (formfields) of a 
 *                                      dynamic table row
 *  @param dynamicTableFormFieldID      The ID of the dynamic table
 *  @param task                         Task object containing the mandatory task ID
 *                                      property.
 *
 */
- (void)setupWithDynamicTableRowFormFields:(NSArray *)dynamicTableRowFormFields
                   dynamicTableFormFieldID:(NSString *)dynamicTableFormFieldID
                                 taskModel:(ASDKModelTask *)task;

/**
 *  Designated setup method for the form render engine class when it is used
 *  to show the dynamic table row associated to a task. This method relies on the internal
 *  workings of the form render engine to make the API network calls on your
 *  behalf and you will be provided with an instance of a collection view controller
 *  via the designated delegate.
 *
 *  @param dynamicTableRowFormFields    Array containing the columns (formfields) of a
 *                                      dynamic table row
 *  @param dynamicTableFormFieldID      The ID of the dynamic table
 *  @param processDefinition            Process definition object containing the mandatory
 *                                      process definition ID property
 *
 */
- (void)setupWithDynamicTableRowFormFields:(NSArray *)dynamicTableRowFormFields
                   dynamicTableFormFieldID:(NSString *)dynamicTableFormFieldID
                         processDefinition:(ASDKModelProcessDefinition *)processDefinition;

/**
 *  Designated setup method for the form render engine class when it is used to show the
 *  content of a form tab. 
 *
 *  @param formDescription Description object containing form models that will be
 *                         displayed in the form view
 *  @return                A collection view controller instance containing the
 *                         the rendered form view
 */
- (UICollectionViewController *)setupWithTabFormDescription:(ASDKModelFormTabDescription *)formDescription;

/**
 *  Performs a form completion request given a form field value request representation object.
 *  
 *  @discussion: The form field value request representation object is generated by the form's
 *  data source object and contains information called form field metadata that's basically
 *  information that the user entered in the form fields.
 *
 *  @param formFieldValueRequestRepresentation Request representation object
 */
- (void)completeFormWithFormFieldValueRequestRepresentation:(ASDKFormFieldValueRequestRepresentation *)formFieldValueRequestRepresentation;

/**
 *  Performs a form save request given a form field value request representation object.
 *  
 *  @discussion:The form field value request representation object is generated by the form's
 *  data source object and contains temporary information that the user entered in the
 *  form fields.
 *
 *  @param formFieldValueRequestRepresentation Request representation object
 */
- (void)saveFormWithFormFieldValueRequestRepresentation:(ASDKFormFieldValueRequestRepresentation *)formFieldValueRequestRepresentation;

@end

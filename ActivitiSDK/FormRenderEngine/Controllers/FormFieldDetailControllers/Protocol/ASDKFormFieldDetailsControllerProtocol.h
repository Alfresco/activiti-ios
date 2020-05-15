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

#import <Foundation/Foundation.h>
#import "ASDKFormRenderEngineValueTransactionsProtocol.h"

@class ASDKModelFormField;

@protocol ASDKFormFieldDetailsControllerProtocol <NSObject>

/**
 *  Property meant to hold a reference to the delegate object that would respond
 *  to object changes that can occur inside the details view controller
 */
@property (weak, nonatomic) id<ASDKFormRenderEngineValueTransactionsProtocol> valueTransactionDelegate;

/**
 *  Designated set up method for every child view controller that is created
 *  when interacting with a form field
 *
 *  @param formFieldModel Form field model used to initialize the child controller
 */
- (void)setupWithFormFieldModel:(ASDKModelFormField *)formFieldModel;

@end

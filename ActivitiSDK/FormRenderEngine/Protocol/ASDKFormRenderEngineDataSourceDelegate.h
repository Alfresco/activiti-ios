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

typedef NS_ENUM(NSInteger, ASDKFormRenderEngineControllerOperationType) {
    ASDKFormRenderEngineControllerOperationTypeInsertSection = 0,
    ASDKFormRenderEngineControllerOperationTypeRemoveSection,
    ASDKFormRenderEngineControllerOperationTypeInsertRow,
    ASDKFormRenderEngineControllerOperationTypeRemoveRow
};

@protocol ASDKFormRenderEngineDataSourceDelegate <NSObject>

/**
 *  Data source signals the delegate controller that a change of visibility for
 *  its items occured and it should be updated with the provided operations 
 *  batch.
 *
 *
 *  @param operationsBatch Dictionary object containing index information on 
 *                         which sections or rows are to be updated. Keys for
 *                         this dictionary are found in the ASDKFormRenderEngineControllerOperationType
 *                         enumeration.
 */
- (void)requestControllerUpdateWithBatchOfOperations:(NSDictionary *)operationsBatch;

@optional
/**
 * Data source signals the delegate controller that an incosistence in the 
 * internal structure occured and it's unsafe to continue
 *
 @param error Error object describing the inconsistence that occured with possible means of recovery
 *            if applicable
 */
- (void)reportDataSourceInconsistenceError:(NSError *)error;

@end

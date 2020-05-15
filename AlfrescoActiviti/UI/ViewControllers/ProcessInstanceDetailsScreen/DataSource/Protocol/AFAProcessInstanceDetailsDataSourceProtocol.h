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

@import UIKit;

@class ASDKModelProcessInstance,
AFATableController;

typedef NS_ENUM(NSInteger, AFAProcessInstanceDetailsSectionType) {
    AFAProcessInstanceDetailsSectionTypeDetails,
    AFAProcessInstanceDetailsSectionTypeTaskStatus,
    AFAProcessInstanceDetailsSectionTypeContent,
    AFAProcessInstanceDetailsSectionTypeComments,
    AFAProcessInstanceDetailsSectionTypeEnumCount
};

typedef void (^AFAProcessInstanceDetailsDataSourceCompletionBlock)  (NSError *error, BOOL registerCellActions);
typedef void (^AFAProcessInstanceDataSourceErrorCompletionBlock) (NSError *error);

@protocol AFAProcessInstanceDetailsDataSourceProtocol <NSObject>

@property (strong, nonatomic, readonly) NSString  *processInstanceID;
@property (strong, nonatomic, readonly) UIColor   *themeColor;
@property (strong, nonatomic) NSMutableDictionary *sectionModels;
@property (strong, nonatomic) NSMutableDictionary *cellFactories;
@property (strong, nonatomic) AFATableController  *tableController;
@property (assign, nonatomic) BOOL                 isConnectivityAvailable;


- (instancetype)initWithProcessInstanceID:(NSString *)processInstanceID
                               themeColor:(UIColor *)themeColor;

- (void)processInstanceDetailsWithCompletionBlock:(AFAProcessInstanceDetailsDataSourceCompletionBlock)completionBlock
                               cachedResultsBlock:(AFAProcessInstanceDetailsDataSourceCompletionBlock)cachedResultsBlock;
- (void)processInstanceActiveAndCompletedTasksWithCompletionBlock:(AFAProcessInstanceDataSourceErrorCompletionBlock)completionBlock
                                               cachedResultsBlock:(AFAProcessInstanceDataSourceErrorCompletionBlock)cachedResultsBlock;
- (void)processInstanceContentWithCompletionBlock:(AFAProcessInstanceDataSourceErrorCompletionBlock)completionBlock
                               cachedResultsBlock:(AFAProcessInstanceDataSourceErrorCompletionBlock)cachedResultsBlock;
- (void)processInstanceCommentsWithCompletionBlock:(AFAProcessInstanceDataSourceErrorCompletionBlock)completionBlock
                                cachedResultsBlock:(AFAProcessInstanceDataSourceErrorCompletionBlock)cachedResultsBlock;
- (void)deleteCurrentProcessInstanceWithCompletionBlock:(void (^)(NSError *error))completionBlock;

- (id)cellFactoryForSectionType:(AFAProcessInstanceDetailsSectionType)sectionType;
- (id)reusableTableControllerModelForSectionType:(AFAProcessInstanceDetailsSectionType)sectionType;
- (void)updateTableControllerForSectionType:(AFAProcessInstanceDetailsSectionType)sectionType;

@end

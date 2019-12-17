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

#import <Foundation/Foundation.h>


// Login related
extern NSUInteger kDefaultLoginUnsecuredPort;
extern NSUInteger kDefaultLoginSecuredPort;
extern NSString  *kAdvancedSettingsParameters;
extern NSString  *kPersistenceStackSessionParameter;

// Task related
extern NSInteger  kDayDifferenceForHighPriorityTasks;
extern NSInteger  kDayDifferenceForMediumPriorityTasks;
extern NSInteger  kDefaultTaskListFetchSize;

/**
 *  Describes the value which will trigger a new page request for the task list. 
 *  The value is computed like this: number-of-tasks - kTaskPreloadCellThreshold
 *  This means that when you're near the last kTaskPreloadCellThreshold element
 *  a new page request will be made
 */
extern NSUInteger kTaskPreloadCellThreshold;

// Credential related
extern NSString *kCloudAuthetificationCredentialIdentifier;
extern NSString *kPremiseAuthentificationCredentialIdentifier;
extern NSString *kAIMSAuthenticationCredentialIdentifier;
extern NSString *kCloudUsernameCredentialIdentifier;
extern NSString *kPremiseUsernameCredentialIdentifier;
extern NSString *kCloudHostNameCredentialIdentifier;
extern NSString *kPremiseHostNameCredentialIdentifier;
extern NSString *kCloudSecureLayerCredentialIdentifier;
extern NSString *kPremiseSecureLayerCredentialIdentifier;
extern NSString *kPremisePortCredentialIdentifier;
extern NSString *kPremiseServiceDocumentCredentialIdentifier;
extern NSString *kAuthentificationTypeCredentialIdentifier;

// Request parameters constants
extern NSString *kRequestParameterID;
extern NSString *kRequestParameterResourceURL;
extern NSString *kRequestParameterContentData;
extern NSString *kRequestParameterSDKModel;
extern NSString *kRequestParameterAllowCachedResultsFlag;
extern NSString *kRequestParameterIsCachedResultFlag;
extern NSString *kRequestParameterOperationSucceededFlag;

// Cell factory
extern NSString *kCellFactoryCellParameterCellIdx;
extern NSString *kCellFactoryCellParameterCellIndexpath;
extern NSString *kCellFactoryCellParameterActionType;

// Error domains
extern NSString * const AFALoginViewModelErrorDomain;
extern NSString * const AFALoginViewModelWarningDomain;
extern NSInteger const kAFALoginViewModelInvalidCredentialErrorCode;
extern NSString * const AFAAIMSLoginErrorDomain;
extern NSInteger const kAFALoginSSOViewModelCancelErrorCode;

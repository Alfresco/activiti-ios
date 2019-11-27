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

#import "AFABusinessConstants.h"


#pragma mark -
#pragma mark Login related

NSUInteger kDefaultLoginUnsecuredPort                = 80;
NSUInteger kDefaultLoginSecuredPort                  = 443;
NSString *kAdvancedSettingsParameters                = @"kAdvancedSettingsParameters";


#pragma mark -
#pragma mark Task related

NSInteger kDayDifferenceForHighPriorityTasks        = 1;
NSInteger kDayDifferenceForMediumPriorityTasks      = 3;
NSUInteger kTaskPreloadCellThreshold                = 10;
NSInteger  kDefaultTaskListFetchSize                = 25;


#pragma mark -
#pragma mark Credential related

NSString *kCloudAuthetificationCredentialIdentifier     = @"kCloudAuthetificationCredentialIdentifier";
NSString *kPremiseAuthentificationCredentialIdentifier  = @"kPremiseAuthentificationCredentialIdentifier";
NSString *kAIMSAuthenticationCredentialIdentifier       = @"kAIMSAuthenticationCredentialIdentifier";
NSString *kCloudUsernameCredentialIdentifier            = @"kCloudUsernameCredentialIdentifier";
NSString *kPremiseUsernameCredentialIdentifier          = @"kPremiseUsernameCredentialIdentifier";
NSString *kUsernameCredentialIdentifier                 = @"kUsernameCredentialIdentifier";
NSString *kPasswordCredentialIdentifier                 = @"kPasswordCredentialIdentifier";
NSString *kCloudHostNameCredentialIdentifier            = @"kCloudHostNameCredentialIdentifier";
NSString *kPremiseHostNameCredentialIdentifier          = @"kPremiseHostNameCredentialIdentifier";
NSString *kCloudSecureLayerCredentialIdentifier         = @"kCloudSecureLayerCredentialIdentifier";
NSString *kPremiseSecureLayerCredentialIdentifier       = @"kPremiseSecureLayerCredentialIdentifier";
NSString *kPremisePortCredentialIdentifier              = @"kPremisePortCredentialIdentifier";
NSString *kPremiseServiceDocumentCredentialIdentifier   = @"kPremiseServiceDocumentCredentialIdentifier";
NSString *kAuthentificationTypeCredentialIdentifier     = @"kAuthentificationTypeCredentialIdentifier";


#pragma mark -
#pragma mark Request parameters constants

NSString *kRequestParameterID                       = @"id";
NSString *kRequestParameterResourceURL              = @"resourceURL";
NSString *kRequestParameterContentData              = @"contentData";
NSString *kRequestParameterSDKModel                 = @"sdkModel";
NSString *kRequestParameterAllowCachedResultsFlag   = @"allowCachedResultsFlag";
NSString *kRequestParameterIsCachedResultFlag       = @"isCachedResultFlag";
NSString *kRequestParameterOperationSucceededFlag   = @"operationSucceededFlag";


#pragma mark -
#pragma mark Cell factory

NSString  *kCellFactoryCellParameterCellIdx         = @"kCellFactoryCellParameterCellIdx";
NSString  *kCellFactoryCellParameterCellIndexpath   = @"kCellFactoryCellParameterCellIndexpath";
NSString  *kCellFactoryCellParameterActionType      = @"kCellFactoryCellParameterActionType";


#pragma mark -
#pragma mark Error domains

NSString * const AFALoginViewModelErrorDomain                   = @"AFALoginViewModelErrorDomain";
NSString * const AFALoginViewModelWarningDomain                 = @"AFALoginViewModelWarningDomain";
NSInteger const kAFALoginViewModelInvalidCredentialErrorCode    = 1;


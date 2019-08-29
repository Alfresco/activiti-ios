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

#import <UIKit/UIKit.h>

// Bootstrap
#import <ActivitiSDK/ASDKBootstrap.h>

// Model imports
#import <ActivitiSDK/ASDKModelServerConfiguration.h>
#import <ActivitiSDK/ASDKBaseRequestRepresentation.h>
#import <ActivitiSDK/ASDKPagingRequestRepresentation.h>
#import <ActivitiSDK/ASDKTaskRequestRepresentation.h>
#import <ActivitiSDK/ASDKFilterRequestRepresentation.h>
#import <ActivitiSDK/ASDKTaskUpdateRequestRepresentation.h>
#import <ActivitiSDK/ASDKFilterListRequestRepresentation.h>
#import <ActivitiSDK/ASDKUserRequestRepresentation.h>
#import <ActivitiSDK/ASDKStartProcessRequestRepresentation.h>
#import <ActivitiSDK/ASDKTaskListQuerryRequestRepresentation.h>
#import <ActivitiSDK/ASDKTaskCreationRequestRepresentation.h>
#import <ActivitiSDK/ASDKIntegrationNodeContentRequestRepresentation.h>
#import <ActivitiSDK/ASDKTaskChecklistOrderRequestRepresentation.h>
#import <ActivitiSDK/ASDKFilterCreationRequestRepresentation.h>

#import <ActivitiSDK/ASDKModelApp.h>
#import <ActivitiSDK/ASDKModelTask.h>
#import <ActivitiSDK/ASDKModelPaging.h>
#import <ActivitiSDK/ASDKModelFilter.h>
#import <ActivitiSDK/ASDKModelProfile.h>
#import <ActivitiSDK/ASDKModelContent.h>
#import <ActivitiSDK/ASDKModelComment.h>
#import <ActivitiSDK/ASDKModelFileContent.h>
#import <ActivitiSDK/ASDKModelFormDescription.h>
#import <ActivitiSDK/ASDKModelFormFieldOption.h>
#import <ActivitiSDK/ASDKModelFormField.h>
#import <ActivitiSDK/ASDKModelAmountFormField.h>
#import <ActivitiSDK/ASDKModelRestFormField.h>
#import <ActivitiSDK/ASDKModelPeopleFormField.h>
#import <ActivitiSDK/ASDKModelHyperlinkFormField.h>
#import <ActivitiSDK/ASDKModelFormFieldAttachParameter.h>
#import <ActivitiSDK/ASDKModelFormFieldFileSource.h>
#import <ActivitiSDK/ASDKModelFormTab.h>
#import <ActivitiSDK/ASDKModelFormVisibilityCondition.h>
#import <ActivitiSDK/ASDKModelDynamicTableFormField.h>
#import <ActivitiSDK/ASDKModelDynamicTableColumnDefinitionFormField.h>
#import <ActivitiSDK/ASDKModelDynamicTableColumnDefinitionAmountFormField.h>
#import <ActivitiSDK/ASDKModelDynamicTableColumnDefinitionRestFormField.h>
#import <ActivitiSDK/ASDKModelFormVariable.h>
#import <ActivitiSDK/ASDKModelFormOutcome.h>
#import <ActivitiSDK/ASDKModelProcessInstance.h>
#import <ActivitiSDK/ASDKModelProcessDefinition.h>
#import <ActivitiSDK/ASDKModelUser.h>
#import <ActivitiSDK/ASDKModelProcessInstanceContent.h>
#import <ActivitiSDK/ASDKModelProcessInstanceContentField.h>
#import <ActivitiSDK/ASDKModelGroup.h>
#import <ActivitiSDK/ASDKModelIntegrationAccount.h>
#import <ActivitiSDK/ASDKModelNetwork.h>
#import <ActivitiSDK/ASDKModelSite.h>
#import <ActivitiSDK/ASDKModelIntegrationContent.h>
#import <ActivitiSDK/ASDKFormFieldValueRequestRepresentation.h>
#import <ActivitiSDK/ASDKDataAccessorResponseModel.h>
#import <ActivitiSDK/ASDKDataAccessorResponseCollection.h>
#import <ActivitiSDK/ASDKDataAccessorResponseConfirmation.h>
#import <ActivitiSDK/ASDKDataAccessorResponseProgress.h>

#import <ActivitiSDK/ASDKIntegrationNetworksDataSource.h>
#import <ActivitiSDK/ASDKIntegrationSitesDataSource.h>
#import <ActivitiSDK/ASDKIntegrationSiteContentDataSource.h>
#import <ActivitiSDK/ASDKIntegrationFolderContentDataSource.h>

// Network services and protocols
#import <ActivitiSDK/ASDKRequestOperationManager.h>
#import <ActivitiSDK/ASDKAppNetworkServiceProtocol.h>
#import <ActivitiSDK/ASDKProfileNetworkServiceProtocol.h>
#import <ActivitiSDK/ASDKFilterNetworkServiceProtocol.h>
#import <ActivitiSDK/ASDKTaskNetworkServiceProtocol.h>
#import <ActivitiSDK/ASDKProcessInstanceNetworkServiceProtocol.h>
#import <ActivitiSDK/ASDKProcessDefinitionNetworkServiceProtocol.h>
#import <ActivitiSDK/ASDKFormNetworkServiceProtocol.h>
#import <ActivitiSDK/ASDKUserNetworkServiceProtocol.h>
#import <ActivitiSDK/ASDKQuerryNetworkServiceProtocol.h>
#import <ActivitiSDK/ASDKIntegrationNetworkServiceProtocol.h>
#import <ActivitiSDK/ASDKServicePathFactory.h>

// JSON adapters
#import <ActivitiSDK/ASDKMantleJSONAdapterExcludeZeroNil.h>
#import <ActivitiSDK/ASDKMantleJSONAdapterCustomPolicy.h>

// Response serializers
#import <ActivitiSDK/ASDKHTTPResponseSerializer.h>
#import <ActivitiSDK/ASDKJSONResponseSerializer.h>
#import <ActivitiSDK/ASDKImageResponseSerializer.h>

// Other service protocols
#import <ActivitiSDK/ASDKDiskServiceProtocol.h>
#import <ActivitiSDK/ASDKFormColorSchemeManagerProtocol.h>

// Parser manager and workers
#import <ActivitiSDK/ASDKParserOperationWorkerProtocol.h>
#import <ActivitiSDK/ASDKProcessParserOperationWorker.h>
#import <ActivitiSDK/ASDKUserParserOperationWorker.h>
#import <ActivitiSDK/ASDKProfileParserOperationWorker.h>
#import <ActivitiSDK/ASDKTaskDetailsParserOperationWorker.h>
#import <ActivitiSDK/ASDKTaskFormParserOperationWorker.h>
#import <ActivitiSDK/ASDKAppParserOperationWorker.h>
#import <ActivitiSDK/ASDKIntegrationParserOperationWorker.h>
#import <ActivitiSDK/ASDKFilterParserOperationWorker.h>

// Service locator imports
#import <ActivitiSDK/ASDKServiceLocator.h>

// Service proxies
#import <ActivitiSDK/ASDKAppNetworkServices.h>
#import <ActivitiSDK/ASDKProfileNetworkServices.h>
#import <ActivitiSDK/ASDKFilterNetworkServices.h>
#import <ActivitiSDK/ASDKTaskNetworkServices.h>
#import <ActivitiSDK/ASDKProcessInstanceNetworkServices.h>
#import <ActivitiSDK/ASDKProcessDefinitionNetworkServices.h>
#import <ActivitiSDK/ASDKFormNetworkServices.h>
#import <ActivitiSDK/ASDKUserNetworkServices.h>
#import <ActivitiSDK/ASDKQuerryNetworkServices.h>
#import <ActivitiSDK/ASDKDiskServices.h>
#import <ActivitiSDK/ASDKIntegrationNetworkServices.h>

// Data accessors
#import <ActivitiSDK/ASDKDataAccessor.h>
#import <ActivitiSDK/ASDKProfileDataAccessor.h>
#import <ActivitiSDK/ASDKApplicationsDataAccessor.h>
#import <ActivitiSDK/ASDKTaskDataAccessor.h>
#import <ActivitiSDK/ASDKFilterDataAccessor.h>
#import <ActivitiSDK/ASDKProcessInstanceDataAccessor.h>
#import <ActivitiSDK/ASDKQuerryDataAccessor.h>
#import <ActivitiSDK/ASDKProcessDefinitionDataAccessor.h>
#import <ActivitiSDK/ASDKIntegrationDataAccessor.h>
#import <ActivitiSDK/ASDKUserDataAccessor.h>

// Network delayed operation services
#import <ActivitiSDK/ASDKNetworkDelayedOperationSaveFormService.h>

// Persistence
#import <ActivitiSDK/ASDKPersistenceStack.h>

// Service categories
#import <ActivitiSDK/NSURLSessionTask+ASDKAdditions.h>
#import <ActivitiSDK/NSString+ASDKEmailValidation.h>

// Form render engine
#import <ActivitiSDK/ASDKFormRenderEngine.h>
#import <ActivitiSDK/ASDKFormControllerNavigationProtocol.h>
#import <ActivitiSDK/ASDKFormColorSchemeManager.h>
#import <ActivitiSDK/ASDKFormEngineActionHandler.h>
#import <ActivitiSDK/ASDKFormPreProcessor.h>
#import <ActivitiSDK/ASDKPhotosLibraryService.h>
#import <ActivitiSDK/ASDKCloudDecommissionService.h>

// KVO manager
#import <ActivitiSDK/ASDKKVOManager.h>

// Logger utilities
#import <ActivitiSDK/ASDKLogConfiguration.h>
#import <ActivitiSDK/ASDKLogFormatter.h>

// UI Components
#import <ActivitiSDK/ASDKRoundedBorderView.h>
#import <ActivitiSDK/ASDKFormCheckbox.h>
#import <ActivitiSDK/ASDKAvatarInitialsView.h>
#import <ActivitiSDK/ASDKIntegrationLoginWebViewViewController.h>
#import <ActivitiSDK/ASDKIntegrationBrowsingViewController.h>
#import <ActivitiSDK/ASDKReachabilityViewController.h>

// UI Categories
#import <ActivitiSDK/NSString+ASDKFontGlyphicons.h>
#import <ActivitiSDK/UIFont+ASDKGlyphicons.h>
#import <ActivitiSDK/NSString+ASDKFontGlyphiconsFiletypes.h>
#import <ActivitiSDK/UIFont+ASDKGlyphiconsFiletypes.h>

// Constants
#import <ActivitiSDK/ASDKNetworkServiceConstants.h>
#import <ActivitiSDK/ASDKAPIEndpointDefinitionList.h>
#import <ActivitiSDK/ASDKFormRenderEngineConstants.h>

// Authentication providers
#import <ActivitiSDK/ASDKBasicAuthentificationProvider.h>

//! Project version number for ActivitiSDK.
FOUNDATION_EXPORT double ActivitiSDKVersionNumber;

//! Project version string for ActivitiSDK.
FOUNDATION_EXPORT const unsigned char ActivitiSDKVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <ActivitiSDK/PublicHeader.h>



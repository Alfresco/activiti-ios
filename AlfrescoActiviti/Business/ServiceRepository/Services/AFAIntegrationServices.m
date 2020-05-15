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

#import "AFAIntegrationServices.h"
@import ActivitiSDK;


@interface AFAIntegrationServices () <ASDKDataAccessorDelegate>

// Fetch integration accounts
@property (strong, nonatomic) ASDKIntegrationDataAccessor               *fetchIntegrationAccounListDataAccessor;
@property (copy, nonatomic) AFAIntegrationAccountListCompletionBlock    integrationAccountListCompletionBlock;
@property (copy, nonatomic) AFAIntegrationAccountListCompletionBlock    integrationAccountListCachedResultsBlock;

// Upload task integration content
@property (strong, nonatomic) ASDKIntegrationDataAccessor               *uploadTaskIntegrationContentDataAccessor;
@property (copy, nonatomic) AFAIntegrationContentUploadCompletionBlock  uploadTaskIntegrationContentCompletionBlock;

@end

@implementation AFAIntegrationServices


#pragma mark -
#pragma mark Public interface

- (void)requestIntegrationAccountsWithCompletionBlock:(AFAIntegrationAccountListCompletionBlock)completionBlock
                                        cachedResults:(AFAIntegrationAccountListCompletionBlock)cacheCompletionBlock {
    NSParameterAssert(completionBlock);
    
    self.integrationAccountListCompletionBlock = completionBlock;
    self.integrationAccountListCachedResultsBlock = cacheCompletionBlock;
    
    self.fetchIntegrationAccounListDataAccessor = [[ASDKIntegrationDataAccessor alloc] initWithDelegate:self];
    [self.fetchIntegrationAccounListDataAccessor fetchIntegrationAccounts];
}

- (void)requestUploadIntegrationContentForTaskID:(NSString *)taskID
                              withRepresentation:(ASDKIntegrationNodeContentRequestRepresentation *)nodeContentRepresentation
                                  completionBloc:(AFAIntegrationContentUploadCompletionBlock)completionBlock {
    NSParameterAssert(completionBlock);
    
    self.uploadTaskIntegrationContentCompletionBlock = completionBlock;
    
    nodeContentRepresentation.isLink = NO;
    
    self.uploadTaskIntegrationContentDataAccessor = [[ASDKIntegrationDataAccessor alloc] initWithDelegate:self];
    [self.uploadTaskIntegrationContentDataAccessor uploadIntegrationContentForTaskID:taskID
                                                       withContentNodeRepresentation:nodeContentRepresentation];
}


#pragma mark -
#pragma mark ASDKDataAccessorDelegate

- (void)dataAccessor:(id<ASDKServiceDataAccessorProtocol>)dataAccessor
 didLoadDataResponse:(ASDKDataAccessorResponseBase *)response {
    if (self.fetchIntegrationAccounListDataAccessor == dataAccessor) {
        [self handleFetchAccountIntegrationDataAccessorResponse:response];
    } else if (self.uploadTaskIntegrationContentDataAccessor == dataAccessor) {
        [self handleUploadTaskIntegrationContentDataAccessorResponse:response];
    }
}

- (void)dataAccessorDidFinishedLoadingDataResponse:(id<ASDKServiceDataAccessorProtocol>)dataAccessor {
}


#pragma mark -
#pragma mark Private interface

- (void)handleFetchAccountIntegrationDataAccessorResponse:(ASDKDataAccessorResponseBase *)response {
    ASDKDataAccessorResponseCollection *integrationAccountListResponse = (ASDKDataAccessorResponseCollection *)response;
    NSArray *integrationAccountList = integrationAccountListResponse.collection;
    
    __weak typeof(self) weakSelf = self;
    if (!integrationAccountListResponse.error) {
        if (integrationAccountListResponse.isCachedData) {
            dispatch_async(dispatch_get_main_queue(), ^{
                __strong typeof(self) strongSelf = weakSelf;
                
                if (strongSelf.integrationAccountListCachedResultsBlock) {
                    strongSelf.integrationAccountListCachedResultsBlock(integrationAccountList, integrationAccountListResponse.error, integrationAccountListResponse.paging);
                    strongSelf.integrationAccountListCachedResultsBlock = nil;
                }
            });
            
            return;
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(self) strongSelf = weakSelf;
        
        if (strongSelf.integrationAccountListCompletionBlock) {
            strongSelf.integrationAccountListCompletionBlock(integrationAccountList, integrationAccountListResponse.error, integrationAccountListResponse.paging);
            strongSelf.integrationAccountListCompletionBlock = nil;
        }
    });
}

- (void)handleUploadTaskIntegrationContentDataAccessorResponse:(ASDKDataAccessorResponseBase *)response {
    ASDKDataAccessorResponseModel *contentResponseModel = (ASDKDataAccessorResponseModel *)response;
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(self) strongSelf = weakSelf;
        
        if (strongSelf.uploadTaskIntegrationContentCompletionBlock) {
            strongSelf.uploadTaskIntegrationContentCompletionBlock(contentResponseModel.model, contentResponseModel.error);
        }
    });
}

@end

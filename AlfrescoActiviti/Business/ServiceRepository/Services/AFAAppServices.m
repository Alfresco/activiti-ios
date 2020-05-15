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

#import "AFAAppServices.h"
@import ActivitiSDK;

@interface AFAAppServices () <ASDKDataAccessorDelegate>

// Runtime app definitions
@property (strong, nonatomic) ASDKApplicationsDataAccessor                      *fetchAppDataAccessor;
@property (copy, nonatomic) AFAAppServicesRuntimeAppDefinitionsCompletionBlock  runtimeAppDefinitionsCompletionBlock;
@property (copy, nonatomic) AFAAppServicesRuntimeAppDefinitionsCompletionBlock  runtimeAppDefinitionsCachedResultsBlock;

@end

@implementation AFAAppServices


#pragma mark -
#pragma mark Public interface

- (void)requestRuntimeAppDefinitionsWithCompletionBlock:(AFAAppServicesRuntimeAppDefinitionsCompletionBlock)completionBlock
                                          cachedResults:(AFAAppServicesRuntimeAppDefinitionsCompletionBlock)cacheCompletionBlock {
    NSParameterAssert(completionBlock);
    
    self.runtimeAppDefinitionsCompletionBlock = completionBlock;
    self.runtimeAppDefinitionsCachedResultsBlock = cacheCompletionBlock;
    
    self.fetchAppDataAccessor = [[ASDKApplicationsDataAccessor alloc] initWithDelegate:self];
    [self.fetchAppDataAccessor fetchRuntimeApplicationDefinitions];
}

- (void)cancellAppNetworkRequests {
    [self.fetchAppDataAccessor cancelOperations];
}


#pragma mark -
#pragma mark ASDKDataAccessorDelegate

- (void)dataAccessor:(id<ASDKServiceDataAccessorProtocol>)dataAccessor
 didLoadDataResponse:(ASDKDataAccessorResponseBase *)response {
    if (self.fetchAppDataAccessor == dataAccessor) {
        [self handleAppDataAccessorResponse:response];
    }
}

- (void)dataAccessorDidFinishedLoadingDataResponse:(id<ASDKServiceDataAccessorProtocol>)dataAccessor {
}


#pragma mark -
#pragma mark Private interface

- (void)handleAppDataAccessorResponse:(ASDKDataAccessorResponseBase *)response {
    ASDKDataAccessorResponseCollection *applicationListResponse = (ASDKDataAccessorResponseCollection *)response;
    NSArray *runtimeAppDefinitions = applicationListResponse.collection;
    
    __weak typeof(self) weakSelf = self;
    if (!applicationListResponse.error) {
        if (applicationListResponse.isCachedData) {
            dispatch_async(dispatch_get_main_queue(), ^{
                __strong typeof(self) strongSelf = weakSelf;
                
                if (strongSelf.runtimeAppDefinitionsCachedResultsBlock) {
                    strongSelf.runtimeAppDefinitionsCachedResultsBlock(runtimeAppDefinitions, nil, nil);
                    strongSelf.runtimeAppDefinitionsCachedResultsBlock = nil;
                }
            });
            
            return;
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(self) strongSelf = weakSelf;
        
        if (strongSelf.runtimeAppDefinitionsCompletionBlock) {
            strongSelf.runtimeAppDefinitionsCompletionBlock(runtimeAppDefinitions, applicationListResponse.error, nil);
            strongSelf.runtimeAppDefinitionsCompletionBlock = nil;
        }
    });
}



@end

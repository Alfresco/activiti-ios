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

#import "AFAFilterServices.h"
@import ActivitiSDK;

// Constants
#import "AFALocalizationConstants.h"


@interface AFAFilterServices () <ASDKDataAccessorDelegate>

// Default task filter list
@property (strong, nonatomic) ASDKFilterDataAccessor                    *fetchDefaultTaskFilterListDataAccessor;
@property (copy, nonatomic) AFAFilterServicesFilterListCompletionBlock  defaultTaskFilterListCompletionBlock;
@property (copy, nonatomic) AFAFilterServicesFilterListCompletionBlock  defaultTaskFilterListCachedResultsBlock;

// Application specific task filter list
@property (strong, nonatomic) ASDKFilterDataAccessor                    *fetchTaskFilterListDataAccessor;
@property (copy, nonatomic) AFAFilterServicesFilterListCompletionBlock  taskFilterListCompletionBlock;
@property (copy, nonatomic) AFAFilterServicesFilterListCompletionBlock  taskFilterListCachedResultsBlock;

// Default process instance filter list
@property (strong, nonatomic) ASDKFilterDataAccessor                    *fetchDefaultProcessInstanceFilterListDataAccessor;
@property (copy, nonatomic) AFAFilterServicesFilterListCompletionBlock  defaultProcessInstanceFilterListCompletionBlock;
@property (copy, nonatomic) AFAFilterServicesFilterListCompletionBlock  defaultProcessInstanceFilterListCachedResultsBlock;

// Application specific process instance filter list
@property (strong, nonatomic) ASDKFilterDataAccessor                    *fetchProcessInstanceFilterListDataAccessor;
@property (copy, nonatomic) AFAFilterServicesFilterListCompletionBlock  processInstanceFilterListCompletionBlock;
@property (copy, nonatomic) AFAFilterServicesFilterListCompletionBlock  processInstanceFilterListCachedResultsBlock;

@end

@implementation AFAFilterServices


#pragma mark -
#pragma mark Public interface

- (void)requestTaskFilterListWithCompletionBlock:(AFAFilterServicesFilterListCompletionBlock)completionBlock
                                   cachedResults:(AFAFilterServicesFilterListCompletionBlock)cacheCompletionBlock {
    NSParameterAssert(completionBlock);
    
    self.defaultTaskFilterListCompletionBlock = completionBlock;
    self.defaultTaskFilterListCachedResultsBlock = cacheCompletionBlock;
    
    self.fetchDefaultTaskFilterListDataAccessor = [[ASDKFilterDataAccessor alloc] initWithDelegate:self];
    [self.fetchDefaultTaskFilterListDataAccessor fetchDefaultTaskFilterList];
}

- (void)requestTaskFilterListForAppID:(NSString *)appID
                  withCompletionBlock:(AFAFilterServicesFilterListCompletionBlock)completionBlock
                        cachedResults:(AFAFilterServicesFilterListCompletionBlock)cacheCompletionBlock {
    NSParameterAssert(completionBlock);
    
    self.taskFilterListCompletionBlock = completionBlock;
    self.taskFilterListCachedResultsBlock = cacheCompletionBlock;
    
    self.fetchTaskFilterListDataAccessor = [[ASDKFilterDataAccessor alloc] initWithDelegate:self];
    [self.fetchTaskFilterListDataAccessor fetchTaskFilterListForApplicationID:appID];
}

- (void)requestProcessInstanceFilterListWithCompletionBlock:(AFAFilterServicesFilterListCompletionBlock)completionBlock
                                              cachedResults:(AFAFilterServicesFilterListCompletionBlock)cacheCompletionBlock {
    NSParameterAssert(completionBlock);
    
    self.defaultProcessInstanceFilterListCompletionBlock = completionBlock;
    self.defaultProcessInstanceFilterListCachedResultsBlock = cacheCompletionBlock;
    
    self.fetchDefaultProcessInstanceFilterListDataAccessor = [[ASDKFilterDataAccessor alloc] initWithDelegate:self];
    [self.fetchDefaultProcessInstanceFilterListDataAccessor fetchDefaultProcessInstanceFilterList];
}

- (void)requestProcessInstanceFilterListForAppID:(NSString *)appID
                             withCompletionBlock:(AFAFilterServicesFilterListCompletionBlock)completionBlock
                                   cachedResults:(AFAFilterServicesFilterListCompletionBlock)cacheCompletionBlock{
    NSParameterAssert(completionBlock);
    
    self.processInstanceFilterListCompletionBlock = completionBlock;
    self.processInstanceFilterListCachedResultsBlock = cacheCompletionBlock;
    
    self.fetchProcessInstanceFilterListDataAccessor = [[ASDKFilterDataAccessor alloc] initWithDelegate:self];
    [self.fetchProcessInstanceFilterListDataAccessor fetchProcessInstanceFilterListForApplicationID:appID];
}


#pragma mark -
#pragma mark ASDKDataAccessorDelegate

- (void)dataAccessor:(id<ASDKServiceDataAccessorProtocol>)dataAccessor
 didLoadDataResponse:(ASDKDataAccessorResponseBase *)response {
    if (self.fetchDefaultTaskFilterListDataAccessor == dataAccessor) {
        [self handleFetchDefaultTaskFilterListDataAccessorResponse:response];
    } else if (self.fetchTaskFilterListDataAccessor == dataAccessor) {
        [self handleFetchTaskFilterListDataAccessorResponse:response];
    } else if (self.fetchDefaultProcessInstanceFilterListDataAccessor == dataAccessor) {
        [self handleFetchDefaultProcessInstanceFilterListDataAccessorResponse:response];
    } else if (self.fetchProcessInstanceFilterListDataAccessor == dataAccessor) {
        [self handleFetchProcessInstanceFilterListDataAccessorResponse:response];
    }
}

- (void)dataAccessorDidFinishedLoadingDataResponse:(id<ASDKServiceDataAccessorProtocol>)dataAccessor {
}


#pragma mark -
#pragma mark Private interface

- (void)handleFetchDefaultTaskFilterListDataAccessorResponse:(ASDKDataAccessorResponseBase *)response {
    ASDKDataAccessorResponseCollection *filterListResponse = (ASDKDataAccessorResponseCollection *)response;
    NSArray *filterList = filterListResponse.collection;
    
    __weak typeof(self) weakSelf = self;
    if (!filterListResponse.error) {
        if (filterListResponse.isCachedData) {
            dispatch_async(dispatch_get_main_queue(), ^{
                __strong typeof(self) strongSelf = weakSelf;
                
                if (strongSelf.defaultTaskFilterListCachedResultsBlock) {
                    strongSelf.defaultTaskFilterListCachedResultsBlock(filterList, nil, filterListResponse.paging);
                    strongSelf.defaultTaskFilterListCachedResultsBlock = nil;
                }
            });
            
            return;
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(self) strongSelf = weakSelf;
        
        if (strongSelf.defaultTaskFilterListCompletionBlock) {
            strongSelf.defaultTaskFilterListCompletionBlock(filterList, filterListResponse.error, filterListResponse.paging);
            strongSelf.defaultTaskFilterListCompletionBlock = nil;
        }
    });
}

- (void)handleFetchTaskFilterListDataAccessorResponse:(ASDKDataAccessorResponseBase *)response {
    ASDKDataAccessorResponseCollection *filterListResponse = (ASDKDataAccessorResponseCollection *)response;
    NSArray *filterList = filterListResponse.collection;
    
    __weak typeof(self) weakSelf = self;
    if (!filterListResponse.error) {
        if (filterListResponse.isCachedData) {
            dispatch_async(dispatch_get_main_queue(), ^{
                __strong typeof(self) strongSelf = weakSelf;
                
                if (strongSelf.taskFilterListCachedResultsBlock) {
                    strongSelf.taskFilterListCachedResultsBlock(filterList, nil, filterListResponse.paging);
                    strongSelf.taskFilterListCachedResultsBlock = nil;
                }
            });
            
            return;
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(self) strongSelf = weakSelf;
        
        if (strongSelf.taskFilterListCompletionBlock) {
            strongSelf.taskFilterListCompletionBlock(filterList, filterListResponse.error, filterListResponse.paging);
            strongSelf.taskFilterListCompletionBlock = nil;
        }
    });
}

- (void)handleFetchDefaultProcessInstanceFilterListDataAccessorResponse:(ASDKDataAccessorResponseBase *)response {
    ASDKDataAccessorResponseCollection *filterListResponse = (ASDKDataAccessorResponseCollection *)response;
    NSArray *filterList = filterListResponse.collection;
    
    __weak typeof(self) weakSelf = self;
    if (!filterListResponse.error) {
        if (filterListResponse.isCachedData) {
            dispatch_async(dispatch_get_main_queue(), ^{
                __strong typeof(self) strongSelf = weakSelf;
                
                if (strongSelf.defaultProcessInstanceFilterListCachedResultsBlock) {
                    strongSelf.defaultProcessInstanceFilterListCachedResultsBlock(filterList, nil, filterListResponse.paging);
                    strongSelf.defaultProcessInstanceFilterListCachedResultsBlock = nil;
                }
            });
            
            return;
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(self) strongSelf = weakSelf;
        
        if (strongSelf.defaultProcessInstanceFilterListCompletionBlock) {
            strongSelf.defaultProcessInstanceFilterListCompletionBlock(filterList, filterListResponse.error, filterListResponse.paging);
            strongSelf.defaultProcessInstanceFilterListCompletionBlock = nil;
        }
    });
}

- (void)handleFetchProcessInstanceFilterListDataAccessorResponse:(ASDKDataAccessorResponseBase *)response {
    ASDKDataAccessorResponseCollection *filterListResponse = (ASDKDataAccessorResponseCollection *)response;
    NSArray *filterList = filterListResponse.collection;
    
    __weak typeof(self) weakSelf = self;
    if (!filterListResponse.error) {
        if (filterListResponse.isCachedData) {
            dispatch_async(dispatch_get_main_queue(), ^{
                __strong typeof(self) strongSelf = weakSelf;
                
                if (strongSelf.processInstanceFilterListCachedResultsBlock) {
                    strongSelf.processInstanceFilterListCachedResultsBlock(filterList, nil, filterListResponse.paging);
                    strongSelf.processInstanceFilterListCachedResultsBlock = nil;
                }
            });
            
            return;
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(self) strongSelf = weakSelf;
        
        if (strongSelf.processInstanceFilterListCompletionBlock) {
            strongSelf.processInstanceFilterListCompletionBlock(filterList, filterListResponse.error, filterListResponse.paging);
            strongSelf.processInstanceFilterListCompletionBlock = nil;
        }
    });
}

@end

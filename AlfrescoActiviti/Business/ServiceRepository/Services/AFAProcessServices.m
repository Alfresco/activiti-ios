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

#import "AFAProcessServices.h"
@import ActivitiSDK;

// Models
#import "AFAGenericFilterModel.h"

@interface AFAProcessServices() <ASDKDataAccessorDelegate>

// Process instance list
@property (strong, nonatomic) ASDKProcessInstanceDataAccessor                   *fetchProcessInstanceListDataAccessor;
@property (copy, nonatomic) AFAProcessServiceProcessInstanceListCompletionBlock processInstanceListCompletionBlock;
@property (copy, nonatomic) AFAProcessServiceProcessInstanceListCompletionBlock processInstanceCachedResultsBlock;

// Process instance details
@property (strong, nonatomic) ASDKProcessInstanceDataAccessor                   *fetchProcessInstanceDetailsDataAccessor;
@property (copy, nonatomic) AFAProcessInstanceCompletionBlock                   processInstanceDetailsCompletionBlock;
@property (copy, nonatomic) AFAProcessInstanceCompletionBlock                   processInstanceDetailsCachedResultsBlock;

// Process instance content
@property (strong, nonatomic) ASDKProcessInstanceDataAccessor                   *fetchProcessInstanceContentDataAccessor;
@property (copy, nonatomic) AFAProcessInstanceContentCompletionBlock            processInstanceContentCompletionBlock;
@property (copy, nonatomic) AFAProcessInstanceContentCompletionBlock            processInstanceContentCachedResultsBlock;

// Delete process instance
@property (strong, nonatomic) ASDKProcessInstanceDataAccessor                   *deleteProcessInstanceDataAccessor;
@property (copy, nonatomic) AFAProcessInstanceDeleteCompletionBlock             deleteProcessInstanceCompletionBlock;

// Create process instance comment
@property (strong, nonatomic) ASDKProcessInstanceDataAccessor                   *createProcessInstanceCommentDataAccessor;
@property (copy, nonatomic) AFAProcessInstanceCreateCommentCompletionBlock      createprocessInstanceCommentCompletionBlock;

// Process instance comment list
@property (strong, nonatomic) ASDKProcessInstanceDataAccessor                   *fetchProcessInstanceCommentListDataAccessor;
@property (copy, nonatomic)  AFAProcessInstanceCommentsCompletionBlock          processInstanceCommentsCompletionBlock;
@property (copy, nonatomic)  AFAProcessInstanceCommentsCompletionBlock          processInstanceCommentsCachedResultsBlock;

// Process instance audit log
@property (strong, nonatomic) ASDKProcessInstanceDataAccessor                   *processInstanceAuditLogDownloadDataAccessor;
@property (copy, nonatomic) AFAProcessInstanceContentDownloadProgressBlock      processInstanceAuditLogDownloadProgressBlock;
@property (copy, nonatomic) AFAProcessInstanceContentDownloadCompletionBlock    processInstanceAuditLogDownloadCompletionBlock;

// Ad-hoc process definition list
@property (strong, nonatomic) ASDKProcessDefinitionDataAccessor                 *fetchAdhocProcessDefinitionListDataAccessor;
@property (copy, nonatomic) AFAProcessDefinitionListCompletionBlock             adhocProcessDefinitionCompletionBlock;
@property (copy, nonatomic) AFAProcessDefinitionListCompletionBlock             adhocProcessDefinitionCachedResultsBlock;

// Process definition list
@property (strong, nonatomic) ASDKProcessDefinitionDataAccessor                 *fetchProcessDefinitionListDataAccessor;
@property (copy, nonatomic) AFAProcessDefinitionListCompletionBlock             processDefinitionCompletionBlock;
@property (copy, nonatomic) AFAProcessDefinitionListCompletionBlock             processDefinitionCachedResultsBlock;

// Process instance start
@property (strong, nonatomic) ASDKProcessInstanceDataAccessor                   *startProcessInstanceDataAccessor;
@property (copy, nonatomic) AFAProcessInstanceCompletionBlock                   startProcessInstanceCompletionBlock;

@end

@implementation AFAProcessServices


#pragma mark -
#pragma mark Public interface

- (void)requestProcessInstanceListWithFilter:(AFAGenericFilterModel *)filter
                         withCompletionBlock:(AFAProcessServiceProcessInstanceListCompletionBlock)completionBlock
                               cachedResults:(AFAProcessServiceProcessInstanceListCompletionBlock)cacheCompletionBlock {
    NSParameterAssert(completionBlock);
    
    self.processInstanceListCompletionBlock = completionBlock;
    self.processInstanceCachedResultsBlock = cacheCompletionBlock;
    
    // Create request representation for the filter model
    ASDKFilterRequestRepresentation *filterRequestRepresentation = [ASDKFilterRequestRepresentation new];
    filterRequestRepresentation.jsonAdapterType = ASDKRequestRepresentationJSONAdapterTypeExcludeNilValues;
    filterRequestRepresentation.appDefinitionID = filter.appDefinitionID;
    filterRequestRepresentation.filterID = filter.filterID;
    
    ASDKModelFilter *modelFilter = [ASDKModelFilter new];
    modelFilter.jsonAdapterType = ASDKModelJSONAdapterTypeExcludeNilValues;
    modelFilter.sortType = (NSInteger)filter.sortType;
    modelFilter.state = (NSInteger)filter.state;
    modelFilter.assignmentType = (NSInteger)filter.assignmentType;
    modelFilter.name = filter.text;
    
    filterRequestRepresentation.filterModel = modelFilter;
    filterRequestRepresentation.page = filter.page;
    filterRequestRepresentation.size = filter.size;
    
    self.fetchProcessInstanceListDataAccessor = [[ASDKProcessInstanceDataAccessor alloc] initWithDelegate:self];
    [self.fetchProcessInstanceListDataAccessor fetchProcessInstancesWithFilter:filterRequestRepresentation];
}

- (void)requestProcessDefinitionListWithCompletionBlock:(AFAProcessDefinitionListCompletionBlock)completionBlock
                                          cachedResults:(AFAProcessDefinitionListCompletionBlock)cacheCompletionBlock {
    NSParameterAssert(completionBlock);
    
    self.adhocProcessDefinitionCompletionBlock = completionBlock;
    self.adhocProcessDefinitionCachedResultsBlock = cacheCompletionBlock;
    
    self.fetchAdhocProcessDefinitionListDataAccessor = [[ASDKProcessDefinitionDataAccessor alloc] initWithDelegate:self];
    [self.fetchAdhocProcessDefinitionListDataAccessor fetchProcessDefinitionList];
}

- (void)requestProcessDefinitionListForAppID:(NSString *)appID
                         withCompletionBlock:(AFAProcessDefinitionListCompletionBlock)completionBlock
                               cachedResults:(AFAProcessDefinitionListCompletionBlock)cacheCompletionBlock {
    NSParameterAssert(completionBlock);
    
    self.processDefinitionCompletionBlock = completionBlock;
    self.processDefinitionCachedResultsBlock = cacheCompletionBlock;
    
    self.fetchProcessDefinitionListDataAccessor = [[ASDKProcessDefinitionDataAccessor alloc] initWithDelegate:self];
    [self.fetchProcessDefinitionListDataAccessor fetchProcessDefinitionListForAppID:appID];
}

- (void)requestProcessInstanceStartForProcessDefinition:(ASDKModelProcessDefinition *)processDefinition
                                        completionBlock:(AFAProcessInstanceCompletionBlock)completionBlock {
    NSParameterAssert(completionBlock);
    
    self.startProcessInstanceCompletionBlock = completionBlock;
    
    ASDKStartProcessRequestRepresentation *startProcessRequestRepresentation = [ASDKStartProcessRequestRepresentation new];
    startProcessRequestRepresentation.jsonAdapterType = ASDKRequestRepresentationJSONAdapterTypeExcludeNilValues;
    startProcessRequestRepresentation.processDefinitionID = processDefinition.modelID;
    startProcessRequestRepresentation.name = processDefinition.name;
    
    self.startProcessInstanceDataAccessor = [[ASDKProcessInstanceDataAccessor alloc] initWithDelegate:self];
    [self.startProcessInstanceDataAccessor startProcessInstanceWithStartProcessRequestRepresentation:startProcessRequestRepresentation];
}

- (void)requestProcessInstanceDetailsForID:(NSString *)processInstanceID
                           completionBlock:(AFAProcessInstanceCompletionBlock)completionBlock
                             cachedResults:(AFAProcessInstanceCompletionBlock)cacheCompletionBlock {
    NSParameterAssert(completionBlock);
    
    self.processInstanceDetailsCompletionBlock = completionBlock;
    self.processInstanceDetailsCachedResultsBlock = cacheCompletionBlock;
    
    self.fetchProcessInstanceDetailsDataAccessor = [[ASDKProcessInstanceDataAccessor alloc] initWithDelegate:self];
    [self.fetchProcessInstanceDetailsDataAccessor fetchProcessInstanceDetailsForProcessInstanceID:processInstanceID];
}

- (void)requestProcessInstanceContentForProcessInstanceID:(NSString *)processInstanceID
                                          completionBlock:(AFAProcessInstanceContentCompletionBlock)completionBlock
                                            cachedResults:(AFAProcessInstanceContentCompletionBlock)cacheCompletionBlock {
    NSParameterAssert(completionBlock);
    
    self.processInstanceContentCompletionBlock = completionBlock;
    self.processInstanceContentCachedResultsBlock = cacheCompletionBlock;
    
    self.fetchProcessInstanceContentDataAccessor = [[ASDKProcessInstanceDataAccessor alloc] initWithDelegate:self];
    [self.fetchProcessInstanceContentDataAccessor fetchProcessInstanceContentForProcessInstanceID:processInstanceID];
}

- (void)requestProcessInstanceCommentsForID:(NSString *)processInstanceID
                        withCompletionBlock:(AFAProcessInstanceCommentsCompletionBlock)completionBlock
                              cachedResults:(AFAProcessInstanceCommentsCompletionBlock)cacheCompletionBlock {
    NSParameterAssert(completionBlock);
    
    self.processInstanceCommentsCompletionBlock = completionBlock;
    self.processInstanceCommentsCachedResultsBlock = cacheCompletionBlock;
    
    self.fetchProcessInstanceCommentListDataAccessor = [[ASDKProcessInstanceDataAccessor alloc] initWithDelegate:self];
    [self.fetchProcessInstanceCommentListDataAccessor fetchProcessInstanceCommentsForProcessInstanceID:processInstanceID];
}

- (void)requestCreateComment:(NSString *)comment
        forProcessInstanceID:(NSString *)processInstanceID
             completionBlock:(AFAProcessInstanceCreateCommentCompletionBlock)completionBlock {
    NSParameterAssert(completionBlock);
    
    self.createprocessInstanceCommentCompletionBlock = completionBlock;
    
    self.createProcessInstanceCommentDataAccessor = [[ASDKProcessInstanceDataAccessor alloc] initWithDelegate:self];
    [self.createProcessInstanceCommentDataAccessor createComment:comment
                                            forProcessInstanceID:processInstanceID];
}

- (void)requestDeleteProcessInstanceWithID:(NSString *)processInstanceID
                           completionBlock:(AFAProcessInstanceDeleteCompletionBlock)completionBlock {
    NSParameterAssert(completionBlock);
    
    self.deleteProcessInstanceCompletionBlock = completionBlock;
    
    self.deleteProcessInstanceDataAccessor = [[ASDKProcessInstanceDataAccessor alloc] initWithDelegate:self];
    [self.deleteProcessInstanceDataAccessor deleteProcessInstanceWithID:processInstanceID];
}

- (void)requestDownloadAuditLogForProcessInstanceWithID:(NSString *)processInstanceID
                                     allowCachedResults:(BOOL)allowCachedResults
                                          progressBlock:(AFAProcessInstanceContentDownloadProgressBlock)progressBlock
                                        completionBlock:(AFAProcessInstanceContentDownloadCompletionBlock)completionBlock {
    NSParameterAssert(processInstanceID);
    
    self.processInstanceAuditLogDownloadProgressBlock = progressBlock;
    self.processInstanceAuditLogDownloadCompletionBlock = completionBlock;
    
    self.processInstanceAuditLogDownloadDataAccessor = [[ASDKProcessInstanceDataAccessor alloc] initWithDelegate:self];
    self.processInstanceAuditLogDownloadDataAccessor.cachePolicy = allowCachedResults ? ASDKServiceDataAccessorCachingPolicyHybrid : ASDKServiceDataAccessorCachingPolicyAPIOnly;
    [self.processInstanceAuditLogDownloadDataAccessor downloadAuditLogForProcessInstanceWithID:processInstanceID];
}


#pragma mark -
#pragma mark ASDKDataAccessorDelegate

- (void)dataAccessor:(id<ASDKServiceDataAccessorProtocol>)dataAccessor
 didLoadDataResponse:(ASDKDataAccessorResponseBase *)response {
    if (self.fetchProcessInstanceListDataAccessor == dataAccessor) {
        [self handleFetchProcessInstanceListDataAccessorResponse:response];
    } else if (self.fetchProcessInstanceDetailsDataAccessor == dataAccessor) {
        [self handleFetchProcessInstanceDetailsDataAccessorResponse:response];
    } else if (self.fetchProcessInstanceContentDataAccessor == dataAccessor) {
        [self handleFetchProcessInstanceContentListDataAccessorResponse:response];
    } else if (self.deleteProcessInstanceDataAccessor == dataAccessor) {
        [self handleDeleteProcessInstanceDataAccessorResponse:response];
    } else if (self.createProcessInstanceCommentDataAccessor == dataAccessor) {
        [self handleCreateProcessInstanceCommentDataAccessorResponse:response];
    } else if (self.fetchProcessInstanceCommentListDataAccessor == dataAccessor) {
        [self handleFetchProcessInstanceCommentListDataAccessorResponse:response];
    } else if (self.processInstanceAuditLogDownloadDataAccessor == dataAccessor) {
        [self handleProcessInstanceAuditLogDownloadDataAccessorResponse:response];
    } else if (self.fetchAdhocProcessDefinitionListDataAccessor == dataAccessor) {
        [self handleFetchAdhocProcessDefinitionListDataAccessorResponse:response];
    } else if (self.fetchProcessDefinitionListDataAccessor == dataAccessor) {
        [self handleFetchProcessDefinitionListDataAccessorResponse:response];
    } else if (self.startProcessInstanceDataAccessor == dataAccessor) {
        [self handleStartProcessInstanceDataAccessorResponse:response];
    }
}

- (void)dataAccessorDidFinishedLoadingDataResponse:(id<ASDKServiceDataAccessorProtocol>)dataAccessor {
}


#pragma mark -
#pragma mark Private interface

- (void)handleFetchProcessInstanceListDataAccessorResponse:(ASDKDataAccessorResponseBase *)response {
    ASDKDataAccessorResponseCollection *processInstanceListResponse = (ASDKDataAccessorResponseCollection *)response;
    NSArray *processInstanceList = processInstanceListResponse.collection;
    
    __weak typeof(self) weakSelf = self;
    if (!processInstanceListResponse.error) {
        if (processInstanceListResponse.isCachedData) {
            dispatch_async(dispatch_get_main_queue(), ^{
                __strong typeof(self) strongSelf = weakSelf;
                
                if (strongSelf.processInstanceCachedResultsBlock) {
                    strongSelf.processInstanceCachedResultsBlock(processInstanceList, processInstanceListResponse.error, processInstanceListResponse.paging);
                    strongSelf.processInstanceCachedResultsBlock = nil;
                }
            });
            
            return;
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(self) strongSelf = weakSelf;
        
        if (strongSelf.processInstanceListCompletionBlock) {
            strongSelf.processInstanceListCompletionBlock(processInstanceList, processInstanceListResponse.error, processInstanceListResponse.paging);
            strongSelf.processInstanceListCompletionBlock = nil;
        }
    });
}

- (void)handleFetchProcessInstanceContentListDataAccessorResponse:(ASDKDataAccessorResponseBase *)response {
    ASDKDataAccessorResponseCollection *processInstanceContentListResponse = (ASDKDataAccessorResponseCollection *)response;
    NSArray *processInstanceContentList = processInstanceContentListResponse.collection;
    
    __weak typeof(self) weakSelf = self;
    if (!processInstanceContentListResponse.error) {
        if (processInstanceContentListResponse.isCachedData) {
            dispatch_async(dispatch_get_main_queue(), ^{
                __strong typeof(self) strongSelf = weakSelf;
                
                if (strongSelf.processInstanceContentCachedResultsBlock) {
                    strongSelf.processInstanceContentCachedResultsBlock(processInstanceContentList, processInstanceContentListResponse.error);
                    strongSelf.processInstanceContentCachedResultsBlock = nil;
                }
            });
            
            return;
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(self) strongSelf = weakSelf;
        
        if (strongSelf.processInstanceContentCompletionBlock) {
            strongSelf.processInstanceContentCompletionBlock(processInstanceContentList, processInstanceContentListResponse.error);
            strongSelf.processInstanceContentCompletionBlock = nil;
        }
    });
}

- (void)handleFetchProcessInstanceDetailsDataAccessorResponse:(ASDKDataAccessorResponseBase *)response {
    ASDKDataAccessorResponseModel *processInstanceResponse = (ASDKDataAccessorResponseModel *)response;
    
    __weak typeof(self) weakSelf = self;
    if (!processInstanceResponse.error) {
        if (processInstanceResponse.isCachedData) {
            dispatch_async(dispatch_get_main_queue(), ^{
                __strong typeof(self) strongSelf = weakSelf;
                
                if (strongSelf.processInstanceDetailsCachedResultsBlock) {
                    strongSelf.processInstanceDetailsCachedResultsBlock(processInstanceResponse.model, nil);
                    strongSelf.processInstanceDetailsCachedResultsBlock = nil;
                }
            });
            
            return;
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(self) strongSelf = weakSelf;
        
        if (strongSelf.processInstanceDetailsCompletionBlock) {
            strongSelf.processInstanceDetailsCompletionBlock(processInstanceResponse.model, processInstanceResponse.error);
            strongSelf.processInstanceDetailsCompletionBlock = nil;
        }
    });
}

- (void)handleDeleteProcessInstanceDataAccessorResponse:(ASDKDataAccessorResponseBase *)response {
    ASDKDataAccessorResponseConfirmation *processInstanceDeleteResponse = (ASDKDataAccessorResponseConfirmation *)response;
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(self) strongSelf = weakSelf;
        
        if (strongSelf.deleteProcessInstanceCompletionBlock) {
            strongSelf.deleteProcessInstanceCompletionBlock(processInstanceDeleteResponse.isConfirmation, processInstanceDeleteResponse.error);
        }
    });
}

- (void)handleCreateProcessInstanceCommentDataAccessorResponse:(ASDKDataAccessorResponseBase *)response {
    ASDKDataAccessorResponseModel *processInstanceCommentResponse = (ASDKDataAccessorResponseModel *)response;
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(self) strongSelf = weakSelf;
        
        if (strongSelf.createprocessInstanceCommentCompletionBlock) {
            strongSelf.createprocessInstanceCommentCompletionBlock(processInstanceCommentResponse.model, processInstanceCommentResponse.error);
        }
    });
}

- (void)handleFetchProcessInstanceCommentListDataAccessorResponse:(ASDKDataAccessorResponseBase *)response {
    ASDKDataAccessorResponseCollection *processInstanceCommentListResponse = (ASDKDataAccessorResponseCollection *)response;
    NSArray *processInstanceCommentList = processInstanceCommentListResponse.collection;
    
    __weak typeof(self) weakSelf = self;
    if (!processInstanceCommentListResponse.error) {
        if (processInstanceCommentListResponse.isCachedData) {
            dispatch_async(dispatch_get_main_queue(), ^{
                __strong typeof(self) strongSelf = weakSelf;
                
                if (strongSelf.processInstanceCommentsCachedResultsBlock) {
                    strongSelf.processInstanceCommentsCachedResultsBlock(processInstanceCommentList, processInstanceCommentListResponse.error, processInstanceCommentListResponse.paging);
                    strongSelf.processInstanceCommentsCachedResultsBlock = nil;
                }
            });
            
            return;
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(self) strongSelf = weakSelf;
        
        if (strongSelf.processInstanceCommentsCompletionBlock) {
            strongSelf.processInstanceCommentsCompletionBlock(processInstanceCommentList, processInstanceCommentListResponse.error, processInstanceCommentListResponse.paging);
            strongSelf.processInstanceCommentsCompletionBlock = nil;
        }
    });
}

- (void)handleProcessInstanceAuditLogDownloadDataAccessorResponse:(ASDKDataAccessorResponseBase *)response {
    __weak typeof(self) weakSelf = self;
    if ([response isKindOfClass:[ASDKDataAccessorResponseProgress class]]) {
        ASDKDataAccessorResponseProgress *progressResponse = (ASDKDataAccessorResponseProgress *)response;
        NSString *formattedProgressString = progressResponse.formattedProgressString;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(self) strongSelf = weakSelf;
            
            if (strongSelf.processInstanceAuditLogDownloadProgressBlock) {
                strongSelf.processInstanceAuditLogDownloadProgressBlock(formattedProgressString, progressResponse.error);
            }
        });
    } else if ([response isKindOfClass:[ASDKDataAccessorResponseModel class]]) {
        ASDKDataAccessorResponseModel *auditLogResponse = (ASDKDataAccessorResponseModel *)response;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(self) strongSelf = weakSelf;
            
            if (strongSelf.processInstanceAuditLogDownloadCompletionBlock) {
                strongSelf.processInstanceAuditLogDownloadCompletionBlock(auditLogResponse.model, auditLogResponse.isCachedData, auditLogResponse.error);
                strongSelf.processInstanceAuditLogDownloadCompletionBlock = nil;
                strongSelf.processInstanceAuditLogDownloadProgressBlock = nil;
            }
        });
    }
}

- (void)handleFetchProcessDefinitionListDataAccessorResponse:(ASDKDataAccessorResponseBase *)response {
    ASDKDataAccessorResponseCollection *processDefinitionListResponse = (ASDKDataAccessorResponseCollection *)response;
    NSArray *processDefinitionList = processDefinitionListResponse.collection;
    
    __weak typeof(self) weakSelf = self;
    if (!processDefinitionListResponse.error) {
        if (processDefinitionListResponse.isCachedData) {
            dispatch_async(dispatch_get_main_queue(), ^{
                __strong typeof(self) strongSelf = weakSelf;
                
                if (strongSelf.processDefinitionCachedResultsBlock) {
                    strongSelf.processDefinitionCachedResultsBlock(processDefinitionList, processDefinitionListResponse.error, processDefinitionListResponse.paging);
                    strongSelf.processDefinitionCachedResultsBlock = nil;
                }
            });
            
            return;
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(self) strongSelf = weakSelf;
        
        if (strongSelf.processDefinitionCompletionBlock) {
            strongSelf.processDefinitionCompletionBlock(processDefinitionList, processDefinitionListResponse.error, processDefinitionListResponse.paging);
        }
    });
}

- (void)handleFetchAdhocProcessDefinitionListDataAccessorResponse:(ASDKDataAccessorResponseBase *)response {
    ASDKDataAccessorResponseCollection *processDefinitionListResponse = (ASDKDataAccessorResponseCollection *)response;
    NSArray *processDefinitionList = processDefinitionListResponse.collection;
    
    __weak typeof(self) weakSelf = self;
    if (!processDefinitionListResponse.error) {
        if (processDefinitionListResponse.isCachedData) {
            dispatch_async(dispatch_get_main_queue(), ^{
                __strong typeof(self) strongSelf = weakSelf;
                
                if (strongSelf.adhocProcessDefinitionCachedResultsBlock) {
                    strongSelf.adhocProcessDefinitionCachedResultsBlock(processDefinitionList, processDefinitionListResponse.error, processDefinitionListResponse.paging);
                    strongSelf.adhocProcessDefinitionCachedResultsBlock = nil;
                }
            });
            
            return;
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(self) strongSelf = weakSelf;
        
        if (strongSelf.adhocProcessDefinitionCompletionBlock) {
            strongSelf.adhocProcessDefinitionCompletionBlock(processDefinitionList, processDefinitionListResponse.error, processDefinitionListResponse.paging);
            strongSelf.adhocProcessDefinitionCompletionBlock = nil;
        }
    });
}

- (void)handleStartProcessInstanceDataAccessorResponse:(ASDKDataAccessorResponseBase *)response {
    ASDKDataAccessorResponseModel *processInstanceStartResponse = (ASDKDataAccessorResponseModel *)response;
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(self) strongSelf = weakSelf;
        
        if (strongSelf.startProcessInstanceCompletionBlock) {
            strongSelf.startProcessInstanceCompletionBlock(processInstanceStartResponse.model, processInstanceStartResponse.error);
        }
    });
}

@end

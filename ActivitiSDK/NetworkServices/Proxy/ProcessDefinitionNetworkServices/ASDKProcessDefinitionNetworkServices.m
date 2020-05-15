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

#import "ASDKProcessDefinitionNetworkServices.h"

// Constants
#import "ASDKLogConfiguration.h"
#import "ASDKNetworkServiceConstants.h"

// Categories
#import "NSURLSessionTask+ASDKAdditions.h"

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

static const int activitiSDKLogLevel = ASDK_LOG_LEVEL_VERBOSE; // | ASDK_LOG_FLAG_TRACE;

@interface ASDKProcessDefinitionNetworkServices ()

@property (strong, nonatomic) NSMutableArray *networkOperations;

@end

@implementation ASDKProcessDefinitionNetworkServices

#pragma mark -
#pragma mark Life cycle

- (instancetype)init {
    self = [super init];
    
    if (self) {
        self.networkOperations = [NSMutableArray array];
    }
    
    return self;
}

- (void)fetchProcessDefinitionListWithCompletionBlock:(ASDKProcessDefinitionListCompletionBlock)completionBlock {
    [self fetchProcessDefinitionListForAppID:nil
                             completionBlock:completionBlock];
}

- (void)fetchProcessDefinitionListForAppID:(NSString *)appID
                           completionBlock:(ASDKProcessDefinitionListCompletionBlock)completionBlock {
    // Check mandatory properties
    NSParameterAssert(completionBlock);
    NSParameterAssert(self.resultsQueue);
    
    // Query parameters
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:kASDKAPITrueParameter
                   forKey:kASDKAPILatestParameter];
    if (appID) {
        [parameters setObject:appID
                       forKey:kASDKAPIAppDefinitionIDParameter];
    }
    
    __weak typeof(self) weakSelf = self;
    __block NSURLSessionDataTask *dataTask =
    [self.requestOperationManager GET:[self.servicePathFactory processDefinitionListServicePathFormat]
                           parameters:parameters
                             progress:nil
                              success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                  __strong typeof(self) strongSelf = weakSelf;
                                  
                                  // Remove operation reference
                                  [strongSelf.networkOperations removeObject:dataTask];
                                  
                                  NSDictionary *responseDictionary = (NSDictionary *)responseObject;
                                  ASDKLogVerbose(@"Process definitions fetched successfully for request: %@",
                                                 [task stateDescriptionForResponse:responseDictionary]);
                                  
                                  // Parse response data
                                  NSString *parserContentType = CREATE_STRING(ASDKProcessParserContentTypeProcessDefinitionList);
                                  [strongSelf.parserOperationManager
                                   parseContentDictionary:responseDictionary
                                   ofType:parserContentType
                                   withCompletionBlock:^(id parsedObject, NSError *error, ASDKModelPaging *paging) {
                                       if (error) {
                                           ASDKLogError(kASDKAPIParserManagerConversionErrorFormat, parserContentType, error.localizedDescription);
                                           dispatch_async(weakSelf.resultsQueue, ^{
                                               completionBlock(nil, error, paging);
                                           });
                                       } else {
                                           ASDKLogVerbose(kASDKAPIParserManagerConversionFormat, parserContentType, parsedObject);
                                           dispatch_async(weakSelf.resultsQueue, ^{
                                               completionBlock(parsedObject, nil, paging);
                                           });
                                       }
                                   }];
                                  
                              } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                  __strong typeof(self) strongSelf = weakSelf;
                                  
                                  // Remove operation reference
                                  [strongSelf.networkOperations removeObject:dataTask];
                                  
                                  ASDKLogError(@"Failed to fetch process definition lists for request: %@",
                                               [task stateDescriptionForError:error]);
                                  
                                  dispatch_async(strongSelf.resultsQueue, ^{
                                      completionBlock(nil, error, nil);
                                  });
                              }];
    
    // Keep network operation reference to be able to cancel it
    [self.networkOperations addObject:dataTask];
}

- (void)cancelAllTaskNetworkOperations {
    [self.networkOperations makeObjectsPerformSelector:@selector(cancel)];
    [self.networkOperations removeAllObjects];
}

@end

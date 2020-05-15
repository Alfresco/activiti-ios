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

#import "ASDKNetworkProxyBaseTest.h"

@interface ASDKIntegrationNetworkServicesTest : ASDKNetworkProxyBaseTest

@property (strong, nonatomic) ASDKIntegrationNetworkServices *integrationNetworkService;
@property (strong, nonatomic) id                              requestOperationManagerMock;

@end

@implementation ASDKIntegrationNetworkServicesTest

- (void)setUp {
    [super setUp];
    
    self.integrationNetworkService = [ASDKIntegrationNetworkServices new];
    self.integrationNetworkService.resultsQueue = dispatch_get_main_queue();
    self.integrationNetworkService.parserOperationManager = self.parserOperationManager;
    self.integrationNetworkService.servicePathFactory = [ASDKServicePathFactory new];
    self.requestOperationManagerMock = OCMClassMock([ASDKRequestOperationManager class]);
    
    ASDKIntegrationParserOperationWorker *integrationParserWorker = [ASDKIntegrationParserOperationWorker new];
    [self.integrationNetworkService.parserOperationManager registerWorker:integrationParserWorker
                                                              forServices:[integrationParserWorker availableServices]];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testThatItFetchesIntegrationAccounts {
    // expect
    XCTestExpectation *integrationAccountsExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [[[self.requestOperationManagerMock expect] andDo:^(NSInvocation *invocation) {
        ASDKTestRequestSuccessBlock successBlock;
        NSUInteger successBlockParameterIdxInMethodSignature = 5;
        [invocation getArgument:&successBlock
                        atIndex:successBlockParameterIdxInMethodSignature];
        NSURLSessionDataTask *dataTask = [self dataTaskWithStatusCode:ASDKHTTPCode200OK];
        [invocation setReturnValue:&dataTask];
        
        successBlock(dataTask, [self contentDictionaryFromJSON:@"IntegrationAccountListResponse"]);
    }] GET:OCMOCK_ANY parameters:OCMOCK_ANY progress:OCMOCK_ANY success:OCMOCK_ANY failure:OCMOCK_ANY];
    
    // when
    self.integrationNetworkService.requestOperationManager = self.requestOperationManagerMock;
    [self.integrationNetworkService fetchIntegrationAccountsWithCompletionBlock:^(NSArray *accounts, NSError *error, ASDKModelPaging *paging) {
        XCTAssertNotNil(accounts);
        XCTAssertNil(error);
        XCTAssertNotNil(paging);
        
        XCTAssert(accounts.count == 3);
        
        [integrationAccountsExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItHandlesIntegrationAccountsFetchRequestFailure {
    // expect
    XCTestExpectation *integrationAccountsExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [[[self.requestOperationManagerMock expect] andDo:^(NSInvocation *invocation) {
        ASDKTestRequestFailureBlock failureBlock;
        NSUInteger failureBlockParameterIdxInMethodSignature = 6;
        [invocation getArgument:&failureBlock
                        atIndex:failureBlockParameterIdxInMethodSignature];
        NSURLSessionDataTask *dataTask = [self dataTaskWithStatusCode:ASDKHTTPCode400BadRequest];
        [invocation setReturnValue:&dataTask];
        
        failureBlock(dataTask, [self requestGenericError]);
    }] GET:OCMOCK_ANY parameters:OCMOCK_ANY progress:OCMOCK_ANY success:OCMOCK_ANY failure:OCMOCK_ANY];
    
    // when
    self.integrationNetworkService.requestOperationManager = self.requestOperationManagerMock;
    [self.integrationNetworkService fetchIntegrationAccountsWithCompletionBlock:^(NSArray *accounts, NSError *error, ASDKModelPaging *paging) {
        XCTAssertNil(accounts);
        XCTAssertNotNil(error);
        XCTAssertNil(paging);
        
        [integrationAccountsExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItFetchesIntegrationNetworks {
    // expect
    XCTestExpectation *integrationNetworksExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [[[self.requestOperationManagerMock expect] andDo:^(NSInvocation *invocation) {
        ASDKTestRequestSuccessBlock successBlock;
        NSUInteger successBlockParameterIdxInMethodSignature = 5;
        [invocation getArgument:&successBlock
                        atIndex:successBlockParameterIdxInMethodSignature];
        NSURLSessionDataTask *dataTask = [self dataTaskWithStatusCode:ASDKHTTPCode200OK];
        [invocation setReturnValue:&dataTask];
        
        successBlock(dataTask, [self contentDictionaryFromJSON:@"IntegrationNetworkListResponse"]);
    }] GET:OCMOCK_ANY parameters:OCMOCK_ANY progress:OCMOCK_ANY success:OCMOCK_ANY failure:OCMOCK_ANY];
    
    // when
    self.integrationNetworkService.requestOperationManager = self.requestOperationManagerMock;
    [self.integrationNetworkService fetchIntegrationNetworksForSourceID:@"id"
                                                        completionBlock:^(NSArray *networks, NSError *error, ASDKModelPaging *paging) {
                                                            XCTAssertNotNil(networks);
                                                            XCTAssertNil(error);
                                                            XCTAssertNotNil(paging);
                                                            
                                                            XCTAssert(networks.count == 2);
                                                            
                                                            [integrationNetworksExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItHandlesIntegrationNetworksFetchRequestFailure {
    // expect
    XCTestExpectation *integrationNetworksExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [[[self.requestOperationManagerMock expect] andDo:^(NSInvocation *invocation) {
        ASDKTestRequestFailureBlock failureBlock;
        NSUInteger failureBlockParameterIdxInMethodSignature = 6;
        [invocation getArgument:&failureBlock
                        atIndex:failureBlockParameterIdxInMethodSignature];
        NSURLSessionDataTask *dataTask = [self dataTaskWithStatusCode:ASDKHTTPCode400BadRequest];
        [invocation setReturnValue:&dataTask];
        
        failureBlock(dataTask, [self requestGenericError]);
    }] GET:OCMOCK_ANY parameters:OCMOCK_ANY progress:OCMOCK_ANY success:OCMOCK_ANY failure:OCMOCK_ANY];
    
    // when
    self.integrationNetworkService.requestOperationManager = self.requestOperationManagerMock;
    [self.integrationNetworkService fetchIntegrationNetworksForSourceID:@"id"
                                                        completionBlock:^(NSArray *networks, NSError *error, ASDKModelPaging *paging) {
                                                            XCTAssertNil(networks);
                                                            XCTAssertNotNil(error);
                                                            XCTAssertNil(paging);
                                                            
                                                            [integrationNetworksExpectation fulfill];
                                                        }];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItFetchesIntegrationSites {
    // expect
    XCTestExpectation *integrationSitesExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [[[self.requestOperationManagerMock expect] andDo:^(NSInvocation *invocation) {
        ASDKTestRequestSuccessBlock successBlock;
        NSUInteger successBlockParameterIdxInMethodSignature = 5;
        [invocation getArgument:&successBlock
                        atIndex:successBlockParameterIdxInMethodSignature];
        NSURLSessionDataTask *dataTask = [self dataTaskWithStatusCode:ASDKHTTPCode200OK];
        [invocation setReturnValue:&dataTask];
        
        successBlock(dataTask, [self contentDictionaryFromJSON:@"IntegrationSiteListResponse"]);
    }] GET:OCMOCK_ANY parameters:OCMOCK_ANY progress:OCMOCK_ANY success:OCMOCK_ANY failure:OCMOCK_ANY];
    
    // when
    self.integrationNetworkService.requestOperationManager = self.requestOperationManagerMock;
    [self.integrationNetworkService fetchIntegrationSitesForSourceID:@"id"
                                                           networkID:@"id"
                                                     completionBlock:^(NSArray *sites, NSError *error, ASDKModelPaging *paging) {
                                                         XCTAssertNotNil(sites);
                                                         XCTAssertNil(error);
                                                         XCTAssertNotNil(paging);
                                                         
                                                         XCTAssert(sites.count == 1);
                                                         
                                                         [integrationSitesExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItHandlesIntegrationSitesFetchRequestFailure {
    // expect
    XCTestExpectation *integrationSitesExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [[[self.requestOperationManagerMock expect] andDo:^(NSInvocation *invocation) {
        ASDKTestRequestFailureBlock failureBlock;
        NSUInteger failureBlockParameterIdxInMethodSignature = 6;
        [invocation getArgument:&failureBlock
                        atIndex:failureBlockParameterIdxInMethodSignature];
        NSURLSessionDataTask *dataTask = [self dataTaskWithStatusCode:ASDKHTTPCode400BadRequest];
        [invocation setReturnValue:&dataTask];
        
        failureBlock(dataTask, [self requestGenericError]);
    }] GET:OCMOCK_ANY parameters:OCMOCK_ANY progress:OCMOCK_ANY success:OCMOCK_ANY failure:OCMOCK_ANY];
    
    // when
    self.integrationNetworkService.requestOperationManager = self.requestOperationManagerMock;
    [self.integrationNetworkService fetchIntegrationSitesForSourceID:@"id"
                                                           networkID:@"id"
                                                     completionBlock:^(NSArray *sites, NSError *error, ASDKModelPaging *paging) {
                                                         XCTAssertNil(sites);
                                                         XCTAssertNotNil(error);
                                                         XCTAssertNil(paging);
                                                         
                                                         [integrationSitesExpectation fulfill];
                                                     }];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItFetchesIntegrationContent {
    // expect
    XCTestExpectation *integrationContentExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [[[self.requestOperationManagerMock expect] andDo:^(NSInvocation *invocation) {
        ASDKTestRequestSuccessBlock successBlock;
        NSUInteger successBlockParameterIdxInMethodSignature = 5;
        [invocation getArgument:&successBlock
                        atIndex:successBlockParameterIdxInMethodSignature];
        NSURLSessionDataTask *dataTask = [self dataTaskWithStatusCode:ASDKHTTPCode200OK];
        [invocation setReturnValue:&dataTask];
        
        successBlock(dataTask, [self contentDictionaryFromJSON:@"IntegrationSiteContentResponse"]);
    }] GET:OCMOCK_ANY parameters:OCMOCK_ANY progress:OCMOCK_ANY success:OCMOCK_ANY failure:OCMOCK_ANY];
    
    // when
    self.integrationNetworkService.requestOperationManager = self.requestOperationManagerMock;
    [self.integrationNetworkService fetchIntegrationContentForSourceID:@"id"
                                                             networkID:@"id"
                                                                siteID:@"id"
                                                       completionBlock:^(NSArray *contentList, NSError *error, ASDKModelPaging *paging) {
                                                           XCTAssertNotNil(contentList);
                                                           XCTAssertNil(error);
                                                           XCTAssertNotNil(paging);
                                                           
                                                           XCTAssert(contentList.count == 1);
                                                           
                                                           [integrationContentExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItHandlesIntegrationContentFetchRequestFailure {
    // expect
    XCTestExpectation *integrationContentExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [[[self.requestOperationManagerMock expect] andDo:^(NSInvocation *invocation) {
        ASDKTestRequestFailureBlock failureBlock;
        NSUInteger failureBlockParameterIdxInMethodSignature = 6;
        [invocation getArgument:&failureBlock
                        atIndex:failureBlockParameterIdxInMethodSignature];
        NSURLSessionDataTask *dataTask = [self dataTaskWithStatusCode:ASDKHTTPCode400BadRequest];
        [invocation setReturnValue:&dataTask];
        
        failureBlock(dataTask, [self requestGenericError]);
    }] GET:OCMOCK_ANY parameters:OCMOCK_ANY progress:OCMOCK_ANY success:OCMOCK_ANY failure:OCMOCK_ANY];
    
    // when
    self.integrationNetworkService.requestOperationManager = self.requestOperationManagerMock;
    [self.integrationNetworkService fetchIntegrationContentForSourceID:@"id"
                                                             networkID:@"id"
                                                                siteID:@"id"
                                                       completionBlock:^(NSArray *contentList, NSError *error, ASDKModelPaging *paging) {
                                                           XCTAssertNil(contentList);
                                                           XCTAssertNotNil(error);
                                                           XCTAssertNil(paging);
                                                           
                                                           [integrationContentExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItFetchesIntegrationFolderContent {
    // expect
    XCTestExpectation *integrationFolderContentExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [[[self.requestOperationManagerMock expect] andDo:^(NSInvocation *invocation) {
        ASDKTestRequestSuccessBlock successBlock;
        NSUInteger successBlockParameterIdxInMethodSignature = 5;
        [invocation getArgument:&successBlock
                        atIndex:successBlockParameterIdxInMethodSignature];
        NSURLSessionDataTask *dataTask = [self dataTaskWithStatusCode:ASDKHTTPCode200OK];
        [invocation setReturnValue:&dataTask];
        
        successBlock(dataTask, [self contentDictionaryFromJSON:@"IntegrationFolderContentResponse"]);
    }] GET:OCMOCK_ANY parameters:OCMOCK_ANY progress:OCMOCK_ANY success:OCMOCK_ANY failure:OCMOCK_ANY];
    
    // when
    self.integrationNetworkService.requestOperationManager = self.requestOperationManagerMock;
    [self.integrationNetworkService fetchIntegrationFolderContentForSourceID:@"id"
                                                                   networkID:@"id"
                                                                    folderID:@"id"
                                                             completionBlock:^(NSArray *contentList, NSError *error, ASDKModelPaging *paging) {
                                                                 XCTAssertNotNil(contentList);
                                                                 XCTAssertNil(error);
                                                                 XCTAssertNotNil(paging);
                                                                 
                                                                 XCTAssert(contentList.count == 5);
                                                                 
                                                                 [integrationFolderContentExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItHandlesIntegrationFolderContentFetchRequestFailure {
    // expect
    XCTestExpectation *integrationFolderContentExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [[[self.requestOperationManagerMock expect] andDo:^(NSInvocation *invocation) {
        ASDKTestRequestFailureBlock failureBlock;
        NSUInteger failureBlockParameterIdxInMethodSignature = 6;
        [invocation getArgument:&failureBlock
                        atIndex:failureBlockParameterIdxInMethodSignature];
        NSURLSessionDataTask *dataTask = [self dataTaskWithStatusCode:ASDKHTTPCode400BadRequest];
        [invocation setReturnValue:&dataTask];
        
        failureBlock(dataTask, [self requestGenericError]);
    }] GET:OCMOCK_ANY parameters:OCMOCK_ANY progress:OCMOCK_ANY success:OCMOCK_ANY failure:OCMOCK_ANY];
    
    // when
    self.integrationNetworkService.requestOperationManager = self.requestOperationManagerMock;
    [self.integrationNetworkService fetchIntegrationFolderContentForSourceID:@"id"
                                                                   networkID:@"id"
                                                                    folderID:@"id"
                                                             completionBlock:^(NSArray *contentList, NSError *error, ASDKModelPaging *paging) {
                                                                 XCTAssertNil(contentList);
                                                                 XCTAssertNotNil(error);
                                                                 XCTAssertNil(paging);
                                                                 
                                                                 [integrationFolderContentExpectation fulfill];
                                                             }];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItUploadsIntegrationContentForNode {
    // given
    id nodeContentRepresentation = OCMClassMock([ASDKIntegrationNodeContentRequestRepresentation class]);
    
    // expect
    XCTestExpectation *integrationContentUploadExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [[[self.requestOperationManagerMock expect] andDo:^(NSInvocation *invocation) {
        ASDKTestRequestSuccessBlock successBlock;
        NSUInteger successBlockParameterIdxInMethodSignature = 5;
        [invocation getArgument:&successBlock
                        atIndex:successBlockParameterIdxInMethodSignature];
        NSURLSessionDataTask *dataTask = [self dataTaskWithStatusCode:ASDKHTTPCode200OK];
        [invocation setReturnValue:&dataTask];
        
        successBlock(dataTask, [self contentDictionaryFromJSON:@"IntegrationUploadContentResponse"]);
    }] POST:OCMOCK_ANY parameters:OCMOCK_ANY progress:OCMOCK_ANY success:OCMOCK_ANY failure:OCMOCK_ANY];
    
    // when
    self.integrationNetworkService.requestOperationManager = self.requestOperationManagerMock;
    [self.integrationNetworkService uploadIntegrationContentWithRepresentation:nodeContentRepresentation
                                                               completionBlock:^(ASDKModelContent *contentModel, NSError *error) {
                                                                   XCTAssertNotNil(contentModel);
                                                                   XCTAssertNil(error);
                                                                   
                                                                   [integrationContentUploadExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItHandlesIntegrationContentForNodeUploadRequestFailure {
    // given
    id nodeContentRepresentation = OCMClassMock([ASDKIntegrationNodeContentRequestRepresentation class]);
    
    // expect
    XCTestExpectation *integrationContentUploadExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [[[self.requestOperationManagerMock expect] andDo:^(NSInvocation *invocation) {
        ASDKTestRequestFailureBlock failureBlock;
        NSUInteger failureBlockParameterIdxInMethodSignature = 6;
        [invocation getArgument:&failureBlock
                        atIndex:failureBlockParameterIdxInMethodSignature];
        NSURLSessionDataTask *dataTask = [self dataTaskWithStatusCode:ASDKHTTPCode400BadRequest];
        [invocation setReturnValue:&dataTask];
        
        failureBlock(dataTask, [self requestGenericError]);
    }] POST:OCMOCK_ANY parameters:OCMOCK_ANY progress:OCMOCK_ANY success:OCMOCK_ANY failure:OCMOCK_ANY];
    
    // when
    self.integrationNetworkService.requestOperationManager = self.requestOperationManagerMock;
    [self.integrationNetworkService uploadIntegrationContentWithRepresentation:nodeContentRepresentation
                                                               completionBlock:^(ASDKModelContent *contentModel, NSError *error) {
                                                                   XCTAssertNil(contentModel);
                                                                   XCTAssertNotNil(error);
                                                                   
                                                                   [integrationContentUploadExpectation fulfill];
                                                               }];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItUploadsIntegrationContentForTask {
    // given
    id nodeContentRepresentation = OCMClassMock([ASDKIntegrationNodeContentRequestRepresentation class]);
    
    // expect
    XCTestExpectation *integrationContentUploadForTaskExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [[[self.requestOperationManagerMock expect] andDo:^(NSInvocation *invocation) {
        ASDKTestRequestSuccessBlock successBlock;
        NSUInteger successBlockParameterIdxInMethodSignature = 5;
        [invocation getArgument:&successBlock
                        atIndex:successBlockParameterIdxInMethodSignature];
        NSURLSessionDataTask *dataTask = [self dataTaskWithStatusCode:ASDKHTTPCode200OK];
        [invocation setReturnValue:&dataTask];
        
        successBlock(dataTask, [self contentDictionaryFromJSON:@"IntegrationUploadContentResponse"]);
    }] POST:OCMOCK_ANY parameters:OCMOCK_ANY progress:OCMOCK_ANY success:OCMOCK_ANY failure:OCMOCK_ANY];
    
    // when
    self.integrationNetworkService.requestOperationManager = self.requestOperationManagerMock;
    [self.integrationNetworkService uploadIntegrationContentForTaskID:@"id"
                                                   withRepresentation:nodeContentRepresentation
                                                      completionBlock:^(ASDKModelContent *contentModel, NSError *error) {
                                                          XCTAssertNotNil(contentModel);
                                                          XCTAssertNil(error);
                                                          
                                                          [integrationContentUploadForTaskExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItHandlesIntegrationContentForTaskUploadRequestFailure {
    // given
    id nodeContentRepresentation = OCMClassMock([ASDKIntegrationNodeContentRequestRepresentation class]);
    
    // expect
    XCTestExpectation *integrationContentUploadForTaskExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [[[self.requestOperationManagerMock expect] andDo:^(NSInvocation *invocation) {
        ASDKTestRequestFailureBlock failureBlock;
        NSUInteger failureBlockParameterIdxInMethodSignature = 6;
        [invocation getArgument:&failureBlock
                        atIndex:failureBlockParameterIdxInMethodSignature];
        NSURLSessionDataTask *dataTask = [self dataTaskWithStatusCode:ASDKHTTPCode400BadRequest];
        [invocation setReturnValue:&dataTask];
        
        failureBlock(dataTask, [self requestGenericError]);
    }] POST:OCMOCK_ANY parameters:OCMOCK_ANY progress:OCMOCK_ANY success:OCMOCK_ANY failure:OCMOCK_ANY];
    
    // when
    self.integrationNetworkService.requestOperationManager = self.requestOperationManagerMock;
    [self.integrationNetworkService uploadIntegrationContentForTaskID:@"id"
                                                   withRepresentation:nodeContentRepresentation
                                                      completionBlock:^(ASDKModelContent *contentModel, NSError *error) {
                                                          XCTAssertNil(contentModel);
                                                          XCTAssertNotNil(error);
                                                          
                                                          [integrationContentUploadForTaskExpectation fulfill];
                                                      }];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

@end

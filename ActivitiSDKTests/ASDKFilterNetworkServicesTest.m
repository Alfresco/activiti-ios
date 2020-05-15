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

@interface ASDKFilterNetworkServicesTest : ASDKNetworkProxyBaseTest

@property (strong, nonatomic) ASDKFilterNetworkServices *filterNetworkService;
@property (strong, nonatomic) id                         requestOperationManagerMock;


@end

@implementation ASDKFilterNetworkServicesTest

- (void)setUp {
    [super setUp];
    
    self.filterNetworkService = [ASDKFilterNetworkServices new];
    self.filterNetworkService.resultsQueue = dispatch_get_main_queue();
    self.filterNetworkService.parserOperationManager = self.parserOperationManager;
    self.filterNetworkService.servicePathFactory = [ASDKServicePathFactory new];
    self.requestOperationManagerMock = OCMClassMock([ASDKRequestOperationManager class]);
    
    ASDKFilterParserOperationWorker *filterParserWorker = [ASDKFilterParserOperationWorker new];
    [self.filterNetworkService.parserOperationManager registerWorker:filterParserWorker
                                                         forServices:[filterParserWorker availableServices]];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testThatItFetchesTaskFilterList {
    // expect
    XCTestExpectation *taskFilterListExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [[[self.requestOperationManagerMock expect] andDo:^(NSInvocation *invocation) {
        ASDKTestRequestSuccessBlock successBlock;
        NSUInteger successBlockParameterIdxInMethodSignature = 5;
        [invocation getArgument:&successBlock
                        atIndex:successBlockParameterIdxInMethodSignature];
        NSURLSessionDataTask *dataTask = [self dataTaskWithStatusCode:ASDKHTTPCode200OK];
        [invocation setReturnValue:&dataTask];
        
        successBlock(dataTask, [self contentDictionaryFromJSON:@"FilterListResponse"]);
    }] GET:OCMOCK_ANY parameters:OCMOCK_ANY progress:OCMOCK_ANY success:OCMOCK_ANY failure:OCMOCK_ANY];
    
    // when
    self.filterNetworkService.requestOperationManager = self.requestOperationManagerMock;
    [self.filterNetworkService fetchTaskFilterListWithCompletionBlock:^(NSArray *filterList, NSError *error, ASDKModelPaging *paging) {
        XCTAssertNotNil(filterList);
        XCTAssertNil(error);
        XCTAssertNotNil(paging);
        
        XCTAssert(filterList.count == 4);
        
        [taskFilterListExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItHandlesTaskFilterListFetchRequestFailure {
    // expect
    XCTestExpectation *taskFilterListExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
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
    self.filterNetworkService.requestOperationManager = self.requestOperationManagerMock;
    [self.filterNetworkService fetchTaskFilterListWithCompletionBlock:^(NSArray *filterList, NSError *error, ASDKModelPaging *paging) {
        XCTAssertNil(filterList);
        XCTAssertNotNil(error);
        XCTAssertNil(paging);
        
        [taskFilterListExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItFetchesProcessInstanceFilterList {
    // expect
    XCTestExpectation *processInstanceFilterListExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [[[self.requestOperationManagerMock expect] andDo:^(NSInvocation *invocation) {
        ASDKTestRequestSuccessBlock successBlock;
        NSUInteger successBlockParameterIdxInMethodSignature = 5;
        [invocation getArgument:&successBlock
                        atIndex:successBlockParameterIdxInMethodSignature];
        NSURLSessionDataTask *dataTask = [self dataTaskWithStatusCode:ASDKHTTPCode200OK];
        [invocation setReturnValue:&dataTask];
        
        successBlock(dataTask, [self contentDictionaryFromJSON:@"FilterListResponse"]);
    }] GET:OCMOCK_ANY parameters:OCMOCK_ANY progress:OCMOCK_ANY success:OCMOCK_ANY failure:OCMOCK_ANY];
    
    // when
    self.filterNetworkService.requestOperationManager = self.requestOperationManagerMock;
    [self.filterNetworkService fetchProcessInstanceFilterListWithCompletionBlock:^(NSArray *filterList, NSError *error, ASDKModelPaging *paging) {
        XCTAssertNotNil(filterList);
        XCTAssertNil(error);
        XCTAssertNotNil(paging);
        
        [processInstanceFilterListExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItHandlesProcessInstanceFilterListFetchRequestFailure {
    // expect
    XCTestExpectation *processInstanceFilterListExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
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
    self.filterNetworkService.requestOperationManager = self.requestOperationManagerMock;
    [self.filterNetworkService fetchProcessInstanceFilterListWithCompletionBlock:^(NSArray *filterList, NSError *error, ASDKModelPaging *paging) {
        XCTAssertNil(filterList);
        XCTAssertNotNil(error);
        XCTAssertNil(paging);
        
        [processInstanceFilterListExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItCreatesTaskFilter {
    // given
    id filter = OCMClassMock([ASDKFilterCreationRequestRepresentation class]);
    
    // expect
    XCTestExpectation *filterCreationExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [[[self.requestOperationManagerMock expect] andDo:^(NSInvocation *invocation) {
        ASDKTestRequestSuccessBlock successBlock;
        NSUInteger successBlockParameterIdxInMethodSignature = 5;
        [invocation getArgument:&successBlock
                        atIndex:successBlockParameterIdxInMethodSignature];
        NSURLSessionDataTask *dataTask = [self dataTaskWithStatusCode:ASDKHTTPCode200OK];
        [invocation setReturnValue:&dataTask];
        
        successBlock(dataTask, [self contentDictionaryFromJSON:@"FilterDetailsResponse"]);
    }] POST:OCMOCK_ANY parameters:OCMOCK_ANY progress:OCMOCK_ANY success:OCMOCK_ANY failure:OCMOCK_ANY];
    
    // when
    self.filterNetworkService.requestOperationManager = self.requestOperationManagerMock;
    [self.filterNetworkService createUserTaskFilterWithRepresentation:filter
                                                  withCompletionBlock:^(ASDKModelFilter *filter, NSError *error) {
                                                      XCTAssertNotNil(filter);
                                                      XCTAssertNil(error);
                                                      
                                                      [filterCreationExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItHandlesTaskFilterCreationRequestFailure {
    // given
    id filter = OCMClassMock([ASDKFilterCreationRequestRepresentation class]);
    
    // expect
    XCTestExpectation *filterCreationExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
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
    self.filterNetworkService.requestOperationManager = self.requestOperationManagerMock;
    [self.filterNetworkService createUserTaskFilterWithRepresentation:filter
                                                  withCompletionBlock:^(ASDKModelFilter *filter, NSError *error) {
                                                      XCTAssertNil(filter);
                                                      XCTAssertNotNil(error);
                                                      
                                                      [filterCreationExpectation fulfill];
                                                  }];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItCreatesProcessInstanceFilter {
    // given
    id filter = OCMClassMock([ASDKFilterCreationRequestRepresentation class]);
    
    // expect
    XCTestExpectation *filterCreationExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [[[self.requestOperationManagerMock expect] andDo:^(NSInvocation *invocation) {
        ASDKTestRequestSuccessBlock successBlock;
        NSUInteger successBlockParameterIdxInMethodSignature = 5;
        [invocation getArgument:&successBlock
                        atIndex:successBlockParameterIdxInMethodSignature];
        NSURLSessionDataTask *dataTask = [self dataTaskWithStatusCode:ASDKHTTPCode200OK];
        [invocation setReturnValue:&dataTask];
        
        successBlock(dataTask, [self contentDictionaryFromJSON:@"FilterDetailsResponse"]);
    }] POST:OCMOCK_ANY parameters:OCMOCK_ANY progress:OCMOCK_ANY success:OCMOCK_ANY failure:OCMOCK_ANY];
    
    // when
    self.filterNetworkService.requestOperationManager = self.requestOperationManagerMock;
    [self.filterNetworkService createProcessInstanceTaskFilterWithRepresentation:filter
                                                             withCompletionBlock:^(ASDKModelFilter *filter, NSError *error) {
                                                                 XCTAssertNotNil(filter);
                                                                 XCTAssertNil(error);
                                                                 
                                                                 [filterCreationExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItHandlesProcessInstanceFilterCreationRequestFailure {
    // given
    id filter = OCMClassMock([ASDKFilterCreationRequestRepresentation class]);
    
    // expect
    XCTestExpectation *filterCreationExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
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
    self.filterNetworkService.requestOperationManager = self.requestOperationManagerMock;
    [self.filterNetworkService createProcessInstanceTaskFilterWithRepresentation:filter
                                                             withCompletionBlock:^(ASDKModelFilter *filter, NSError *error) {
                                                                 XCTAssertNil(filter);
                                                                 XCTAssertNotNil(error);
                                                                 
                                                                 [filterCreationExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

@end

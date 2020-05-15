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

@interface ASDKQuerryNetworkServicesTest : ASDKNetworkProxyBaseTest

@property (strong, nonatomic) ASDKQuerryNetworkServices *querryNetworkService;
@property (strong, nonatomic) id                         requestOperationManagerMock;

@end

@implementation ASDKQuerryNetworkServicesTest

- (void)setUp {
    [super setUp];
    
    self.querryNetworkService = [ASDKQuerryNetworkServices new];
    self.querryNetworkService.resultsQueue = dispatch_get_main_queue();
    self.querryNetworkService.parserOperationManager = self.parserOperationManager;
    self.querryNetworkService.servicePathFactory = [ASDKServicePathFactory new];
    self.requestOperationManagerMock = OCMClassMock([ASDKRequestOperationManager class]);
    
    ASDKTaskDetailsParserOperationWorker *taskDetailsParserWorker = [ASDKTaskDetailsParserOperationWorker new];
    [self.querryNetworkService.parserOperationManager registerWorker:taskDetailsParserWorker
                                                          forServices:[taskDetailsParserWorker availableServices]];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testThatItFetchesTaskListWithFilter {
    // given
    id filter = OCMClassMock([ASDKTaskListQuerryRequestRepresentation class]);
    
    // expect
    XCTestExpectation *fetchTaskListExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [[[self.requestOperationManagerMock expect] andDo:^(NSInvocation *invocation) {
        ASDKTestRequestSuccessBlock successBlock;
        NSUInteger successBlockParameterIdxInMethodSignature = 5;
        [invocation getArgument:&successBlock
                        atIndex:successBlockParameterIdxInMethodSignature];
        NSURLSessionDataTask *dataTask = [self dataTaskWithStatusCode:ASDKHTTPCode200OK];
        [invocation setReturnValue:&dataTask];
        
        successBlock(dataTask, [self contentDictionaryFromJSON:@"TaskListResponse"]);
    }] POST:OCMOCK_ANY parameters:OCMOCK_ANY progress:OCMOCK_ANY success:OCMOCK_ANY failure:OCMOCK_ANY];
    
    // when
    self.querryNetworkService.requestOperationManager = self.requestOperationManagerMock;
    [self.querryNetworkService fetchTaskListWithFilterRepresentation:filter
                                                     completionBlock:^(NSArray *taskList, NSError *error, ASDKModelPaging *paging) {
                                                         XCTAssertNotNil(taskList);
                                                         XCTAssertNil(error);
                                                         XCTAssertNotNil(paging);
                                                         
                                                         XCTAssert(taskList.count == 2);
                                                         
                                                         [fetchTaskListExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItHandlesTaskListFetchWithFilterRequestFailure {
    // given
    id filter = OCMClassMock([ASDKTaskListQuerryRequestRepresentation class]);
    
    // expect
    XCTestExpectation *fetchTaskListExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
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
    self.querryNetworkService.requestOperationManager = self.requestOperationManagerMock;
    [self.querryNetworkService fetchTaskListWithFilterRepresentation:filter
                                                     completionBlock:^(NSArray *taskList, NSError *error, ASDKModelPaging *paging) {
                                                         XCTAssertNil(taskList);
                                                         XCTAssertNotNil(error);
                                                         XCTAssertNil(paging);
                                                         
                                                         [fetchTaskListExpectation fulfill];
                                                     }];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}


@end

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

@interface ASDKAppNetworkServicesTest : ASDKNetworkProxyBaseTest

@property (strong, nonatomic) ASDKAppNetworkServices *appNetworkServices;
@property (strong, nonatomic) id                      requestOperationManagerMock;

@end

@implementation ASDKAppNetworkServicesTest

- (void)setUp {
    [super setUp];
    
    self.appNetworkServices = [ASDKAppNetworkServices new];
    self.appNetworkServices.resultsQueue = dispatch_get_main_queue();
    self.appNetworkServices.parserOperationManager = self.parserOperationManager;
    self.appNetworkServices.servicePathFactory = [ASDKServicePathFactory new];
    self.requestOperationManagerMock = OCMClassMock([ASDKRequestOperationManager class]);
    
    ASDKAppParserOperationWorker *appParserWorker = [ASDKAppParserOperationWorker new];
    [self.appNetworkServices.parserOperationManager registerWorker:appParserWorker
                                                       forServices:[appParserWorker availableServices]];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testThatItFetchesRuntimeAppDefinitions {
    // expect
    XCTestExpectation *runtimeAppDefinitionsExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [[[self.requestOperationManagerMock expect] andDo:^(NSInvocation *invocation) {
        ASDKTestRequestSuccessBlock successBlock;
        NSUInteger successBlockParameterIdxInMethodSignature = 5;
        [invocation getArgument:&successBlock
                        atIndex:successBlockParameterIdxInMethodSignature];
        NSURLSessionDataTask *dataTask = [self dataTaskWithStatusCode:ASDKHTTPCode200OK];
        [invocation setReturnValue:&dataTask];
        
        successBlock(dataTask, [self contentDictionaryFromJSON:@"ApplicationListResponse"]);
    }] GET:OCMOCK_ANY parameters:OCMOCK_ANY progress:OCMOCK_ANY success:OCMOCK_ANY failure:OCMOCK_ANY];
    
    // when
    self.appNetworkServices.requestOperationManager = self.requestOperationManagerMock;
    [self.appNetworkServices fetchRuntimeAppDefinitionsWithCompletionBlock:^(NSArray *runtimeAppDefinitions, NSError *error, ASDKModelPaging *paging) {
        XCTAssertNotNil(runtimeAppDefinitions);
        XCTAssertNil(error);
        XCTAssertNotNil(paging);
        
        XCTAssert(runtimeAppDefinitions.count == 13);
        
        [runtimeAppDefinitionsExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItHandlesRuntimeAppDefinitionsFetchRequestFailure {
    // expect
    XCTestExpectation *runtimeAppDefinitionsExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
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
    self.appNetworkServices.requestOperationManager = self.requestOperationManagerMock;
    [self.appNetworkServices fetchRuntimeAppDefinitionsWithCompletionBlock:^(NSArray *runtimeAppDefinitions, NSError *error, ASDKModelPaging *paging) {
        XCTAssertNil(runtimeAppDefinitions);
        XCTAssertNotNil(error);
        XCTAssertNil(paging);
        
        [runtimeAppDefinitionsExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

@end

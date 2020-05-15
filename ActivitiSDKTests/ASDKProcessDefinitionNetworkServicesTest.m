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

@interface ASDKProcessDefinitionNetworkServicesTest : ASDKNetworkProxyBaseTest

@property (strong, nonatomic) ASDKProcessDefinitionNetworkServices *processDefinitionNetworkServices;
@property (strong, nonatomic) id                                    requestOperationManagerMock;

@end

@implementation ASDKProcessDefinitionNetworkServicesTest

- (void)setUp {
    [super setUp];
    
    self.processDefinitionNetworkServices = [ASDKProcessDefinitionNetworkServices new];
    self.processDefinitionNetworkServices.resultsQueue = dispatch_get_main_queue();
    self.processDefinitionNetworkServices.parserOperationManager = self.parserOperationManager;
    self.processDefinitionNetworkServices.servicePathFactory = [ASDKServicePathFactory new];
    self.requestOperationManagerMock = OCMClassMock([ASDKRequestOperationManager class]);
    
    ASDKProcessParserOperationWorker *processParserWorker = [ASDKProcessParserOperationWorker new];
    [self.processDefinitionNetworkServices.parserOperationManager registerWorker:processParserWorker
                                                                     forServices:[processParserWorker availableServices]];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testThatItFetchesProcessDefinitionForApplication {
    // expect
    XCTestExpectation *processDefinitionExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [[[self.requestOperationManagerMock expect] andDo:^(NSInvocation *invocation) {
        ASDKTestRequestSuccessBlock successBlock;
        NSUInteger successBlockParameterIdxInMethodSignature = 5;
        [invocation getArgument:&successBlock
                        atIndex:successBlockParameterIdxInMethodSignature];
        NSURLSessionDataTask *dataTask = [self dataTaskWithStatusCode:ASDKHTTPCode200OK];
        [invocation setReturnValue:&dataTask];
        
        successBlock(dataTask, [self contentDictionaryFromJSON:@"ProcessDefinitionListResponse"]);
    }] GET:OCMOCK_ANY parameters:OCMOCK_ANY progress:OCMOCK_ANY success:OCMOCK_ANY failure:OCMOCK_ANY];
    
    // when
    ASDKProcessDefinitionListCompletionBlock completionBlock = ^(NSArray *processDefinitions, NSError *error, ASDKModelPaging *paging) {
        XCTAssertNotNil(processDefinitions);
        XCTAssertNil(error);
        XCTAssertNotNil(paging);
        
        XCTAssert(processDefinitions.count == 1);
    };
    
    self.processDefinitionNetworkServices.requestOperationManager = self.requestOperationManagerMock;
    [self.processDefinitionNetworkServices fetchProcessDefinitionListWithCompletionBlock:^(NSArray *processDefinitions, NSError *error, ASDKModelPaging *paging) {
        completionBlock(processDefinitions, error, paging);
        [processDefinitionExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:1.0f
                                 handler:nil];
}

- (void)testThatItHandlesProcessDefinitionForApplicationFetchRequestFailure {
    // expect
    XCTestExpectation *processDefinitionExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
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
    self.processDefinitionNetworkServices.requestOperationManager = self.requestOperationManagerMock;
    [self.processDefinitionNetworkServices fetchProcessDefinitionListWithCompletionBlock:^(NSArray *processDefinitions, NSError *error, ASDKModelPaging *paging) {
        XCTAssertNil(processDefinitions);
        XCTAssertNotNil(error);
        XCTAssertNil(paging);
        
        [processDefinitionExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

@end

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

@interface ASDKFormNetworkServicesTest : ASDKNetworkProxyBaseTest

@property (strong, nonatomic) ASDKFormNetworkServices *formNetworkService;
@property (strong, nonatomic) id                       requestOperationManagerMock;

@end

@implementation ASDKFormNetworkServicesTest

- (void)setUp {
    [super setUp];
    
    self.formNetworkService = [ASDKFormNetworkServices new];
    self.formNetworkService.resultsQueue = dispatch_get_main_queue();
    self.formNetworkService.parserOperationManager = self.parserOperationManager;
    self.formNetworkService.servicePathFactory = [ASDKServicePathFactory new];
    self.formNetworkService.diskServices = [ASDKDiskServices new];
    self.requestOperationManagerMock = OCMClassMock([ASDKRequestOperationManager class]);
    
    ASDKTaskFormParserOperationWorker *taskFormParserWorker = [ASDKTaskFormParserOperationWorker new];
    [self.formNetworkService.parserOperationManager registerWorker:taskFormParserWorker
                                                       forServices:[taskFormParserWorker availableServices]];
    
    ASDKProcessParserOperationWorker *processParserWorker = [ASDKProcessParserOperationWorker new];
    [self.formNetworkService.parserOperationManager registerWorker:processParserWorker
                                                       forServices:[processParserWorker availableServices]];
    
    ASDKTaskDetailsParserOperationWorker *taskDetailsParserWorker = [ASDKTaskDetailsParserOperationWorker new];
    [self.formNetworkService.parserOperationManager registerWorker:taskDetailsParserWorker
                                                       forServices:[taskDetailsParserWorker availableServices]];
}

- (void)tearDown {
    [super tearDown];
    
    [ASDKDiskServices deleteLocalData];
}

- (void)testThatItStartsFormForProcessDefinition {
    // expect
    XCTestExpectation *startFormExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [[[self.requestOperationManagerMock expect] andDo:^(NSInvocation *invocation) {
        ASDKTestRequestSuccessBlock successBlock;
        NSUInteger successBlockParameterIdxInMethodSignature = 5;
        [invocation getArgument:&successBlock
                        atIndex:successBlockParameterIdxInMethodSignature];
        NSURLSessionDataTask *dataTask = [self dataTaskWithStatusCode:ASDKHTTPCode200OK];
        [invocation setReturnValue:&dataTask];
        
        successBlock(dataTask, [self contentDictionaryFromJSON:@"TaskAllFieldsFormResponse"]);
    }] GET:OCMOCK_ANY parameters:OCMOCK_ANY progress:OCMOCK_ANY success:OCMOCK_ANY failure:OCMOCK_ANY];
    
    // when
    self.formNetworkService.requestOperationManager = self.requestOperationManagerMock;
    [self.formNetworkService startFormForProcessDefinitionID:@"id"
                                           completionBlock:^(ASDKModelFormDescription *formDescription, NSError *error) {
                                               XCTAssertNotNil(formDescription);
                                               XCTAssertNil(error);
                                               XCTAssert(formDescription.formFields.count == 2);
                                               
                                               [startFormExpectation fulfill];
                                           }];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItHandlesStartFormForProcessDefinitionRequestFailure {
    // expect
    XCTestExpectation *startFormExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
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
    self.formNetworkService.requestOperationManager = self.requestOperationManagerMock;
    [self.formNetworkService startFormForProcessInstanceID:@"id"
                                           completionBlock:^(ASDKModelFormDescription *formDescription, NSError *error) {
                                               XCTAssertNil(formDescription);
                                               XCTAssertNotNil(error);
                                               
                                               [startFormExpectation fulfill];
                                           }];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItStartsFormForProcessInstance {
    // expect
    XCTestExpectation *startFormExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [[[self.requestOperationManagerMock expect] andDo:^(NSInvocation *invocation) {
        ASDKTestRequestSuccessBlock successBlock;
        NSUInteger successBlockParameterIdxInMethodSignature = 5;
        [invocation getArgument:&successBlock
                        atIndex:successBlockParameterIdxInMethodSignature];
        NSURLSessionDataTask *dataTask = [self dataTaskWithStatusCode:ASDKHTTPCode200OK];
        [invocation setReturnValue:&dataTask];
        
        successBlock(dataTask, [self contentDictionaryFromJSON:@"TaskAllFieldsFormResponse"]);
    }] GET:OCMOCK_ANY parameters:OCMOCK_ANY progress:OCMOCK_ANY success:OCMOCK_ANY failure:OCMOCK_ANY];
    
    // when
    self.formNetworkService.requestOperationManager = self.requestOperationManagerMock;
    [self.formNetworkService startFormForProcessInstanceID:@"id"
                                           completionBlock:^(ASDKModelFormDescription *formDescription, NSError *error) {
                                               XCTAssertNotNil(formDescription);
                                               XCTAssertNil(error);
                                               XCTAssert(formDescription.formFields.count == 2);
                                               
                                               [startFormExpectation fulfill];
                                           }];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItHandlesStartFormForProcessInstanceRequestFailure {
    // expect
    XCTestExpectation *startFormExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
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
    self.formNetworkService.requestOperationManager = self.requestOperationManagerMock;
    [self.formNetworkService startFormForProcessInstanceID:@"id"
                                           completionBlock:^(ASDKModelFormDescription *formDescription, NSError *error) {
                                               XCTAssertNil(formDescription);
                                               XCTAssertNotNil(error);
                                               
                                               [startFormExpectation fulfill];
                                           }];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItCompletesFormForTask {
    // given
    id formFieldValueRepresentation = [ASDKFormFieldValueRequestRepresentation new];
    
    // expect
    XCTestExpectation *taskFormCompletionExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [[[self.requestOperationManagerMock expect] andDo:^(NSInvocation *invocation) {
        ASDKTestRequestSuccessBlock successBlock;
        NSUInteger successBlockParameterIdxInMethodSignature = 5;
        [invocation getArgument:&successBlock
                        atIndex:successBlockParameterIdxInMethodSignature];
        NSURLSessionDataTask *dataTask = [self dataTaskWithStatusCode:ASDKHTTPCode200OK];
        [invocation setReturnValue:&dataTask];
        
        successBlock(dataTask, nil);
    }] POST:OCMOCK_ANY parameters:OCMOCK_ANY progress:OCMOCK_ANY success:OCMOCK_ANY failure:OCMOCK_ANY];
    
    // when
    self.formNetworkService.requestOperationManager = self.requestOperationManagerMock;
    [self.formNetworkService completeFormForTaskID:@"id"
           withFormFieldValueRequestRepresentation:formFieldValueRepresentation
                                   completionBlock:^(BOOL isFormCompleted, NSError *error) {
                                       XCTAssertTrue(isFormCompleted);
                                       XCTAssertNil(error);
                                       
                                       [taskFormCompletionExpectation fulfill];
                                   }];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItHandlesTaskFormCompletionRequestFailure {
    // given
    id formFieldValueRepresentation = [ASDKFormFieldValueRequestRepresentation new];
    
    // expect
    XCTestExpectation *taskFormCompletionExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
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
    self.formNetworkService.requestOperationManager = self.requestOperationManagerMock;
    [self.formNetworkService completeFormForTaskID:@"id"
           withFormFieldValueRequestRepresentation:formFieldValueRepresentation
                                   completionBlock:^(BOOL isFormCompleted, NSError *error) {
                                       XCTAssertFalse(isFormCompleted);
                                       XCTAssertNotNil(error);
                                       
                                       [taskFormCompletionExpectation fulfill];
                                   }];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItCompletesFormForProcessDefinition {
    // given
    id processDefinition = OCMClassMock([ASDKModelProcessDefinition class]);
    OCMStub([processDefinition modelID]).andReturn(@"100");
    OCMStub([processDefinition name]).andReturn(@"test");
    id formFieldValuesRepresentation = OCMClassMock([ASDKFormFieldValueRequestRepresentation class]);
    
    // expect
    XCTestExpectation *completeProcessDefinitionFormExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [[[self.requestOperationManagerMock expect] andDo:^(NSInvocation *invocation) {
        ASDKTestRequestSuccessBlock successBlock;
        NSUInteger successBlockParameterIdxInMethodSignature = 5;
        [invocation getArgument:&successBlock
                        atIndex:successBlockParameterIdxInMethodSignature];
        NSURLSessionDataTask *dataTask = [self dataTaskWithStatusCode:ASDKHTTPCode200OK];
        [invocation setReturnValue:&dataTask];
        
        successBlock(dataTask, [self contentDictionaryFromJSON:@"ProcessInstanceDetailsResponse"]);
    }] POST:OCMOCK_ANY parameters:OCMOCK_ANY progress:OCMOCK_ANY success:OCMOCK_ANY failure:OCMOCK_ANY];
    
    // when
    self.formNetworkService.requestOperationManager = self.requestOperationManagerMock;
    [self.formNetworkService completeFormForProcessDefinition:processDefinition
                     withFormFieldValuesRequestRepresentation:formFieldValuesRepresentation
                                              completionBlock:^(ASDKModelProcessInstance *processInstance, NSError *error) {
                                                  XCTAssertNotNil(processInstance);
                                                  XCTAssertNil(error);
                                                  
                                                  [completeProcessDefinitionFormExpectation fulfill];
                                              }];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItHandlesProcessDefinitionFormCompletionRequestFailure {
    // given
    id processDefinition = OCMClassMock([ASDKModelProcessDefinition class]);
    OCMStub([processDefinition modelID]).andReturn(@"100");
    OCMStub([processDefinition name]).andReturn(@"test");
    id formFieldValuesRepresentation = OCMClassMock([ASDKFormFieldValueRequestRepresentation class]);
    
    // expect
    XCTestExpectation *completeProcessDefinitionFormExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
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
    self.formNetworkService.requestOperationManager = self.requestOperationManagerMock;
    [self.formNetworkService completeFormForProcessDefinition:processDefinition
                     withFormFieldValuesRequestRepresentation:formFieldValuesRepresentation
                                              completionBlock:^(ASDKModelProcessInstance *processInstance, NSError *error) {
                                                  XCTAssertNil(processInstance);
                                                  XCTAssertNotNil(error);
                                                  
                                                  [completeProcessDefinitionFormExpectation fulfill];
                                              }];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItSavesFormForTask {
    // given
    id formFieldValuesRepresentation = OCMClassMock([ASDKFormFieldValueRequestRepresentation class]);
    
    // expect
    XCTestExpectation *saveFormExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [[[self.requestOperationManagerMock expect] andDo:^(NSInvocation *invocation) {
        ASDKTestRequestSuccessBlock successBlock;
        NSUInteger successBlockParameterIdxInMethodSignature = 5;
        [invocation getArgument:&successBlock
                        atIndex:successBlockParameterIdxInMethodSignature];
        NSURLSessionDataTask *dataTask = [self dataTaskWithStatusCode:ASDKHTTPCode200OK];
        [invocation setReturnValue:&dataTask];
        
        successBlock(dataTask, nil);
    }] POST:OCMOCK_ANY parameters:OCMOCK_ANY progress:OCMOCK_ANY success:OCMOCK_ANY failure:OCMOCK_ANY];
    
    // when
    self.formNetworkService.requestOperationManager = self.requestOperationManagerMock;
    [self.formNetworkService saveFormForTaskID:@"id"
      withFormFieldValuesRequestRepresentation:formFieldValuesRepresentation
                               completionBlock:^(BOOL isFormSaved, NSError *error) {
                                   XCTAssertTrue(isFormSaved);
                                   XCTAssertNil(error);
                                   
                                   [saveFormExpectation fulfill];
                               }];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItHandlesTaskFormSaveRequestFailure {
    // given
    id formFieldValuesRepresentation = OCMClassMock([ASDKFormFieldValueRequestRepresentation class]);
    
    // expect
    XCTestExpectation *saveFormExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
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
    self.formNetworkService.requestOperationManager = self.requestOperationManagerMock;
    [self.formNetworkService saveFormForTaskID:@"id"
      withFormFieldValuesRequestRepresentation:formFieldValuesRepresentation
                               completionBlock:^(BOOL isFormSaved, NSError *error) {
                                   XCTAssertFalse(isFormSaved);
                                   XCTAssertNotNil(error);
                                   
                                   [saveFormExpectation fulfill];
                               }];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItFetchesFormForTask {
    // expect
    XCTestExpectation *taskFormExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [[[self.requestOperationManagerMock expect] andDo:^(NSInvocation *invocation) {
        ASDKTestRequestSuccessBlock successBlock;
        NSUInteger successBlockParameterIdxInMethodSignature = 5;
        [invocation getArgument:&successBlock
                        atIndex:successBlockParameterIdxInMethodSignature];
        NSURLSessionDataTask *dataTask = [self dataTaskWithStatusCode:ASDKHTTPCode200OK];
        [invocation setReturnValue:&dataTask];
        
        successBlock(dataTask, [self contentDictionaryFromJSON:@"TaskAllFieldsFormResponse"]);
    }] GET:OCMOCK_ANY parameters:OCMOCK_ANY progress:OCMOCK_ANY success:OCMOCK_ANY failure:OCMOCK_ANY];
    
    // when
    self.formNetworkService.requestOperationManager = self.requestOperationManagerMock;
    [self.formNetworkService fetchFormForTaskWithID:@"id"
                                    completionBlock:^(ASDKModelFormDescription *formDescription, NSError *error) {
                                        XCTAssertNotNil(formDescription);
                                        XCTAssertNil(error);
                                        XCTAssert(formDescription.formFields.count == 2);
                                        
                                        [taskFormExpectation fulfill];
                                    }];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItHandlesTaskFormFetchRequestFailure {
    // expect
    XCTestExpectation *taskFormExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
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
    self.formNetworkService.requestOperationManager = self.requestOperationManagerMock;
    [self.formNetworkService fetchFormForTaskWithID:@"id"
                                    completionBlock:^(ASDKModelFormDescription *formDescription, NSError *error) {
                                        XCTAssertNil(formDescription);
                                        XCTAssertNotNil(error);
                                        
                                        [taskFormExpectation fulfill];
                                    }];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItHandlesUploadsFormContentProgress {
    // given
    id fileContent = OCMClassMock([ASDKModelFileContent class]);
    NSData *dummyData = [self createRandomNSDataOfSize:100];
    
    // expect
    XCTestExpectation *uploadFormContentExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [[[self.requestOperationManagerMock expect] andDo:^(NSInvocation *invocation) {
        ASDKTestRequestProgressBlock progressBlock;
        NSUInteger progressBlockParameterIdxInMethodSignature = 5;
        [invocation getArgument:&progressBlock
                        atIndex:progressBlockParameterIdxInMethodSignature];
        NSURLSessionDataTask *dataTask = [self dataTaskWithStatusCode:ASDKHTTPCode200OK];
        [invocation setReturnValue:&dataTask];
        
        NSProgress *progress = [NSProgress progressWithTotalUnitCount:100];
        progress.completedUnitCount = 20;
        
        progressBlock(progress);
    }] POST:OCMOCK_ANY parameters:OCMOCK_ANY constructingBodyWithBlock:OCMOCK_ANY progress:OCMOCK_ANY success:OCMOCK_ANY failure:OCMOCK_ANY];
    
    //when
    self.formNetworkService.requestOperationManager = self.requestOperationManagerMock;
    [self.formNetworkService uploadContentWithModel:fileContent
                                        contentData:dummyData
                                      progressBlock:^(NSUInteger progress, NSError *error) {
                                          XCTAssert(progress == 20);
                                          XCTAssertNil(error);
                                          
                                          [uploadFormContentExpectation fulfill];
                                      }
                                    completionBlock:^(ASDKModelContent *contentModel, NSError *error) {}];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItUploadsFormContent {
    // given
    id fileContent = OCMClassMock([ASDKModelFileContent class]);
    NSData *dummyData = [self createRandomNSDataOfSize:100];
    
    // expect
    XCTestExpectation *uploadFormContentExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [[[self.requestOperationManagerMock expect] andDo:^(NSInvocation *invocation) {
        ASDKTestRequestSuccessBlock successBlock;
        NSUInteger successBlockParameterIdxInMethodSignature = 6;
        [invocation getArgument:&successBlock
                        atIndex:successBlockParameterIdxInMethodSignature];
        NSURLSessionDataTask *dataTask = [self dataTaskWithStatusCode:ASDKHTTPCode200OK];
        [invocation setReturnValue:&dataTask];
        
        successBlock(dataTask, [self contentDictionaryFromJSON:@"TaskDetailsUploadContentResponse"]);
    }] POST:OCMOCK_ANY parameters:OCMOCK_ANY constructingBodyWithBlock:OCMOCK_ANY progress:OCMOCK_ANY success:OCMOCK_ANY failure:OCMOCK_ANY];
    
    //when
    self.formNetworkService.requestOperationManager = self.requestOperationManagerMock;
    [self.formNetworkService uploadContentWithModel:fileContent
                                        contentData:dummyData
                                      progressBlock:nil
                                    completionBlock:^(ASDKModelContent *contentModel, NSError *error) {
                                        XCTAssertNotNil(contentModel);
                                        XCTAssertNil(error);
                                        
                                        
                                        [uploadFormContentExpectation fulfill];
                                    }];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}


- (void)testThatItHandlesFormContentUploadRequestFailure {
    // given
    id fileContent = OCMClassMock([ASDKModelFileContent class]);
    NSData *dummyData = [self createRandomNSDataOfSize:100];
    
    // expect
    XCTestExpectation *uploadFormContentExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [[[self.requestOperationManagerMock expect] andDo:^(NSInvocation *invocation) {
        ASDKTestRequestFailureBlock failureBlock;
        NSUInteger failureBlockParameterIdxInMethodSignature = 7;
        [invocation getArgument:&failureBlock
                        atIndex:failureBlockParameterIdxInMethodSignature];
        NSURLSessionDataTask *dataTask = [self dataTaskWithStatusCode:ASDKHTTPCode400BadRequest];
        [invocation setReturnValue:&dataTask];
        
        failureBlock(dataTask, [self requestGenericError]);
    }] POST:OCMOCK_ANY parameters:OCMOCK_ANY constructingBodyWithBlock:OCMOCK_ANY progress:OCMOCK_ANY success:OCMOCK_ANY failure:OCMOCK_ANY];
    
    //when
    self.formNetworkService.requestOperationManager = self.requestOperationManagerMock;
    [self.formNetworkService uploadContentWithModel:fileContent
                                        contentData:dummyData
                                      progressBlock:nil
                                    completionBlock:^(ASDKModelContent *contentModel, NSError *error) {
                                        XCTAssertNil(contentModel);
                                        XCTAssertNotNil(error);
                                        
                                        [uploadFormContentExpectation fulfill];
                                    }];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItDownloadsFormContentAndReturnsCachedResults {
    // given
    id fileContent = OCMClassMock([ASDKModelContent class]);
    id diskServices = OCMPartialMock(self.formNetworkService.diskServices);
    OCMStub([fileContent modelID]).andReturn(@"100");
    OCMStub([fileContent contentName]).andReturn(@"IMG_001");
    
    // expect
    XCTestExpectation *downloadFormContentExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    OCMStub([diskServices doesFileAlreadyExistsForContent:OCMOCK_ANY]).andReturn(YES);
    
    // when
    self.formNetworkService.diskServices = diskServices;
    [self.formNetworkService downloadContentWithModel:fileContent
                                   allowCachedResults:YES
                                        progressBlock:nil
                                      completionBlock:^(NSString *contentID, NSURL *downloadedContentURL, BOOL isLocalContent, NSError *error) {
                                          XCTAssertNotNil(contentID);
                                          XCTAssertNotNil(downloadedContentURL);
                                          XCTAssertTrue(isLocalContent);
                                          XCTAssertNil(error);
                                          
                                          [downloadFormContentExpectation fulfill];
                                      }];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItDownloadsFormContentAndReportsProgress {
    // given
    id fileContent = OCMClassMock([ASDKModelContent class]);
    OCMStub([fileContent modelID]).andReturn(@"100");
    
    // expect
    XCTestExpectation *downloadFormContentExpectation = [self expectationWithDescription:[NSString stringWithFormat:@"%@.downloadContentCompletion", NSStringFromSelector(_cmd)]];
    XCTestExpectation *downloadFormContentProgressExpectation = [self expectationWithDescription:[NSString stringWithFormat:@"%@.downloadContentProgress", NSStringFromSelector(_cmd)]];
    
    [[[self.requestOperationManagerMock expect] andDo:^(NSInvocation *invocation) {
        void (^completionBlock)(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error);
        [invocation getArgument:&completionBlock
                        atIndex:5];
        NSURLSessionDownloadTask *downloadTask = [self downloadTaskWithStatusCode:ASDKHTTPCode200OK];
        [invocation setReturnValue:&downloadTask];
        
        id response = OCMClassMock([NSHTTPURLResponse class]);
        OCMStub([response statusCode]).andReturn(ASDKHTTPCode200OK);
        completionBlock(response, nil, nil);
    }] downloadTaskWithRequest:OCMOCK_ANY progress:OCMOCK_ANY destination:OCMOCK_ANY completionHandler:OCMOCK_ANY];
    
    [[[self.requestOperationManagerMock expect] andDo:^(NSInvocation *invocation) {
        void (^fileWritingProgressBlock) (NSURLSession * _Nonnull session, NSURLSessionDownloadTask * _Nonnull downloadTask, int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite);
        [invocation getArgument:&fileWritingProgressBlock
                        atIndex:2];
        NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        NSURLSessionDownloadTask *downloadTask = [self downloadTaskWithStatusCode:ASDKHTTPCode200OK];
        
        fileWritingProgressBlock (defaultSession, downloadTask, 0, 200, 0);
    }] setDownloadTaskDidWriteDataBlock:OCMOCK_ANY];
    
    // when
    self.formNetworkService.requestOperationManager = self.requestOperationManagerMock;
    [self.formNetworkService downloadContentWithModel:fileContent
                                   allowCachedResults:NO
                                        progressBlock:^(NSString *formattedReceivedBytesString, NSError *error) {
                                            XCTAssert([formattedReceivedBytesString isEqualToString:@"200.00 bytes"]);
                                            XCTAssertNil(error);
                                            
                                            [downloadFormContentProgressExpectation fulfill];
                                        }
                                      completionBlock:^(NSString *contentID, NSURL *downloadedContentURL, BOOL isLocalContent, NSError *error) {
                                          XCTAssertNotNil(contentID);
                                          XCTAssertNotNil(downloadedContentURL);
                                          XCTAssertFalse(isLocalContent);
                                          XCTAssertNil(error);
                                          
                                          [downloadFormContentExpectation fulfill];
                                      }];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItHandlesFormContentDownloadRequestFailure {
    // given
    id fileContent = OCMClassMock([ASDKModelContent class]);
    
    // expect
    XCTestExpectation *downloadFormContentExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [[[self.requestOperationManagerMock expect] andDo:^(NSInvocation *invocation) {
        void (^completionBlock)(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error);
        [invocation getArgument:&completionBlock
                        atIndex:5];
        NSURLSessionDownloadTask *downloadTask = [self downloadTaskWithStatusCode:ASDKHTTPCode400BadRequest];
        [invocation setReturnValue:&downloadTask];
        
        id response = OCMClassMock([NSHTTPURLResponse class]);
        OCMStub([response statusCode]).andReturn(ASDKHTTPCode200OK);
        completionBlock(response, nil, [self requestGenericError]);
    }] downloadTaskWithRequest:OCMOCK_ANY progress:OCMOCK_ANY destination:OCMOCK_ANY completionHandler:OCMOCK_ANY];
    
    // when
    self.formNetworkService.requestOperationManager = self.requestOperationManagerMock;
    [self.formNetworkService downloadContentWithModel:fileContent
                                   allowCachedResults:NO
                                        progressBlock:nil
                                      completionBlock:^(NSString *contentID, NSURL *downloadedContentURL, BOOL isLocalContent, NSError *error) {
                                          XCTAssertNil(contentID);
                                          XCTAssertNil(downloadedContentURL);
                                          XCTAssertFalse(isLocalContent);
                                          XCTAssertNotNil(error);
                                          
                                          [downloadFormContentExpectation fulfill];
                                      }];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItFetchesRestFieldValuesForTask {
    // expect
    XCTestExpectation *fetchRestFieldValuesExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [[[self.requestOperationManagerMock expect] andDo:^(NSInvocation *invocation) {
        ASDKTestRequestSuccessBlock successBlock;
        NSUInteger successBlockParameterIdxInMethodSignature = 5;
        [invocation getArgument:&successBlock
                        atIndex:successBlockParameterIdxInMethodSignature];
        NSURLSessionDataTask *dataTask = [self dataTaskWithStatusCode:ASDKHTTPCode200OK];
        [invocation setReturnValue:&dataTask];
        
        successBlock(dataTask, [self contentDictionaryFromJSON:@"TaskFormRestFieldValuesResponse"]);
    }] GET:OCMOCK_ANY parameters:OCMOCK_ANY progress:OCMOCK_ANY success:OCMOCK_ANY failure:OCMOCK_ANY];
    
    //when
    self.formNetworkService.requestOperationManager = self.requestOperationManagerMock;
    [self.formNetworkService fetchRestFieldValuesForTaskWithID:@"id"
                                                   withFieldID:@"id"
                                               completionBlock:^(NSArray *restFieldValues, NSError *error) {
                                                   XCTAssertNotNil(restFieldValues);
                                                   XCTAssertNil(error);
                                                   
                                                   XCTAssert(restFieldValues.count == 10);
                                                   
                                                   [fetchRestFieldValuesExpectation fulfill];
                                               }];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItHandlesRestFieldValuesForTaskFetchRequestFailure {
    // expect
    XCTestExpectation *fetchRestFieldValuesExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [[[self.requestOperationManagerMock expect] andDo:^(NSInvocation *invocation) {
        ASDKTestRequestFailureBlock failureBlock;
        NSUInteger failureBlockParameterIdxInMethodSignature = 6;
        [invocation getArgument:&failureBlock
                        atIndex:failureBlockParameterIdxInMethodSignature];
        NSURLSessionDataTask *dataTask = [self dataTaskWithStatusCode:ASDKHTTPCode400BadRequest];
        [invocation setReturnValue:&dataTask];
        
        failureBlock(dataTask, [self requestGenericError]);
    }] GET:OCMOCK_ANY parameters:OCMOCK_ANY progress:OCMOCK_ANY success:OCMOCK_ANY failure:OCMOCK_ANY];
    
    //when
    self.formNetworkService.requestOperationManager = self.requestOperationManagerMock;
    [self.formNetworkService fetchRestFieldValuesForTaskWithID:@"id"
                                                   withFieldID:@"id"
                                               completionBlock:^(NSArray *restFieldValues, NSError *error) {
                                                   XCTAssertNil(restFieldValues);
                                                   XCTAssertNotNil(error);
                                                   
                                                   [fetchRestFieldValuesExpectation fulfill];
                                               }];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItFetchesRestFieldValuesForTaskInDynamicTable {
    // expect
    XCTestExpectation *fetchRestFieldValuesExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [[[self.requestOperationManagerMock expect] andDo:^(NSInvocation *invocation) {
        ASDKTestRequestSuccessBlock successBlock;
        NSUInteger successBlockParameterIdxInMethodSignature = 5;
        [invocation getArgument:&successBlock
                        atIndex:successBlockParameterIdxInMethodSignature];
        NSURLSessionDataTask *dataTask = [self dataTaskWithStatusCode:ASDKHTTPCode200OK];
        [invocation setReturnValue:&dataTask];
        
        successBlock(dataTask, [self contentDictionaryFromJSON:@"TaskFormRestFieldValuesResponse"]);
    }] GET:OCMOCK_ANY parameters:OCMOCK_ANY progress:OCMOCK_ANY success:OCMOCK_ANY failure:OCMOCK_ANY];
    
    //when
    self.formNetworkService.requestOperationManager = self.requestOperationManagerMock;
    [self.formNetworkService fetchRestFieldValuesForTaskWithID:@"id"
                                                   withFieldID:@"id"
                                                  withColumnID:@"id"
                                               completionBlock:^(NSArray *restFieldValues, NSError *error) {
                                                   XCTAssertNotNil(restFieldValues);
                                                   XCTAssertNil(error);
                                                   
                                                   XCTAssert(restFieldValues.count == 10);
                                                   
                                                   [fetchRestFieldValuesExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItHandlesRestFieldValuesForTaskInDynamicTableFetchRequestFailure {
    // expect
    XCTestExpectation *fetchRestFieldValuesExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [[[self.requestOperationManagerMock expect] andDo:^(NSInvocation *invocation) {
        ASDKTestRequestFailureBlock failureBlock;
        NSUInteger failureBlockParameterIdxInMethodSignature = 6;
        [invocation getArgument:&failureBlock
                        atIndex:failureBlockParameterIdxInMethodSignature];
        NSURLSessionDataTask *dataTask = [self dataTaskWithStatusCode:ASDKHTTPCode400BadRequest];
        [invocation setReturnValue:&dataTask];
        
        failureBlock(dataTask, [self requestGenericError]);
    }] GET:OCMOCK_ANY parameters:OCMOCK_ANY progress:OCMOCK_ANY success:OCMOCK_ANY failure:OCMOCK_ANY];
    
    //when
    self.formNetworkService.requestOperationManager = self.requestOperationManagerMock;
    [self.formNetworkService fetchRestFieldValuesForTaskWithID:@"id"
                                                   withFieldID:@"id"
                                                  withColumnID:@"id"
                                               completionBlock:^(NSArray *restFieldValues, NSError *error) {
                                                   XCTAssertNil(restFieldValues);
                                                   XCTAssertNotNil(error);
                                                   
                                                   [fetchRestFieldValuesExpectation fulfill];
                                               }];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItFetchesRestFieldValuesForStartForm {
    // expect
    XCTestExpectation *fetchRestFieldValuesExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [[[self.requestOperationManagerMock expect] andDo:^(NSInvocation *invocation) {
        ASDKTestRequestSuccessBlock successBlock;
        NSUInteger successBlockParameterIdxInMethodSignature = 5;
        [invocation getArgument:&successBlock
                        atIndex:successBlockParameterIdxInMethodSignature];
        NSURLSessionDataTask *dataTask = [self dataTaskWithStatusCode:ASDKHTTPCode200OK];
        [invocation setReturnValue:&dataTask];
        
        successBlock(dataTask, [self contentDictionaryFromJSON:@"TaskFormRestFieldValuesResponse"]);
    }] GET:OCMOCK_ANY parameters:OCMOCK_ANY progress:OCMOCK_ANY success:OCMOCK_ANY failure:OCMOCK_ANY];
    
    //when
    self.formNetworkService.requestOperationManager = self.requestOperationManagerMock;
    [self.formNetworkService fetchRestFieldValuesForStartFormWithProcessDefinitionID:@"id"
                                                                         withFieldID:@"id"
                                                                     completionBlock:^(NSArray *restFieldValues, NSError *error) {
                                                                         XCTAssertNotNil(restFieldValues);
                                                                         XCTAssertNil(error);
                                                                         
                                                                         XCTAssert(restFieldValues.count == 10);
                                                                         
                                                                         [fetchRestFieldValuesExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItHandlesRestFieldValueForStartFormFetchRequestFailure {
    // expect
    XCTestExpectation *fetchRestFieldValuesExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [[[self.requestOperationManagerMock expect] andDo:^(NSInvocation *invocation) {
        ASDKTestRequestFailureBlock failureBlock;
        NSUInteger failureBlockParameterIdxInMethodSignature = 6;
        [invocation getArgument:&failureBlock
                        atIndex:failureBlockParameterIdxInMethodSignature];
        NSURLSessionDataTask *dataTask = [self dataTaskWithStatusCode:ASDKHTTPCode400BadRequest];
        [invocation setReturnValue:&dataTask];
        
        failureBlock(dataTask, [self requestGenericError]);
    }] GET:OCMOCK_ANY parameters:OCMOCK_ANY progress:OCMOCK_ANY success:OCMOCK_ANY failure:OCMOCK_ANY];
    
    //when
    self.formNetworkService.requestOperationManager = self.requestOperationManagerMock;
    [self.formNetworkService fetchRestFieldValuesForStartFormWithProcessDefinitionID:@"id"
                                                                         withFieldID:@"id"
                                                                     completionBlock:^(NSArray *restFieldValues, NSError *error) {
                                                                         XCTAssertNil(restFieldValues);
                                                                         XCTAssertNotNil(error);
                                                                         
                                                                         [fetchRestFieldValuesExpectation fulfill];
                                                                     }];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItFetchesRestFieldValuesForStartFormInDynamicTable {
    // expect
    XCTestExpectation *fetchRestFieldValuesExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [[[self.requestOperationManagerMock expect] andDo:^(NSInvocation *invocation) {
        ASDKTestRequestSuccessBlock successBlock;
        NSUInteger successBlockParameterIdxInMethodSignature = 5;
        [invocation getArgument:&successBlock
                        atIndex:successBlockParameterIdxInMethodSignature];
        NSURLSessionDataTask *dataTask = [self dataTaskWithStatusCode:ASDKHTTPCode200OK];
        [invocation setReturnValue:&dataTask];
        
        successBlock(dataTask, [self contentDictionaryFromJSON:@"TaskFormRestFieldValuesResponse"]);
    }] GET:OCMOCK_ANY parameters:OCMOCK_ANY progress:OCMOCK_ANY success:OCMOCK_ANY failure:OCMOCK_ANY];
    
    //when
    self.formNetworkService.requestOperationManager = self.requestOperationManagerMock;
    [self.formNetworkService fetchRestFieldValuesForStartFormWithProcessDefinitionID:@"id"
                                                                         withFieldID:@"id"
                                                                        withColumnID:@"id"
                                                                     completionBlock:^(NSArray *restFieldValues, NSError *error) {
                                                                         XCTAssertNotNil(restFieldValues);
                                                                         XCTAssertNil(error);
                                                                         
                                                                         XCTAssert(restFieldValues.count == 10);
                                                                         
                                                                         [fetchRestFieldValuesExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItHandlesRestFieldValuesForStartFormInDynamicTableFetchRequestFailure {
    // expect
    XCTestExpectation *fetchRestFieldValuesExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [[[self.requestOperationManagerMock expect] andDo:^(NSInvocation *invocation) {
        ASDKTestRequestFailureBlock failureBlock;
        NSUInteger failureBlockParameterIdxInMethodSignature = 6;
        [invocation getArgument:&failureBlock
                        atIndex:failureBlockParameterIdxInMethodSignature];
        NSURLSessionDataTask *dataTask = [self dataTaskWithStatusCode:ASDKHTTPCode400BadRequest];
        [invocation setReturnValue:&dataTask];
        
        failureBlock(dataTask, [self requestGenericError]);
    }] GET:OCMOCK_ANY parameters:OCMOCK_ANY progress:OCMOCK_ANY success:OCMOCK_ANY failure:OCMOCK_ANY];
    
    //when
    self.formNetworkService.requestOperationManager = self.requestOperationManagerMock;
    [self.formNetworkService fetchRestFieldValuesForStartFormWithProcessDefinitionID:@"id"
                                                                         withFieldID:@"id"
                                                                        withColumnID:@"id"
                                                                     completionBlock:^(NSArray *restFieldValues, NSError *error) {
                                                                         XCTAssertNil(restFieldValues);
                                                                         XCTAssertNotNil(error);
                                                                         
                                                                         [fetchRestFieldValuesExpectation fulfill];
                                                                     }];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

@end

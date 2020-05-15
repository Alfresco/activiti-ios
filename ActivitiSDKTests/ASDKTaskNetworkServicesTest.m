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

@interface ASDKTaskNetworkServicesTest : ASDKNetworkProxyBaseTest

@property (strong, nonatomic) ASDKTaskNetworkServices       *taskNetworkServices;
@property (strong, nonatomic) id                            requestOperationManagerMock;

@end

@implementation ASDKTaskNetworkServicesTest

- (void)setUp {
    [super setUp];
    
    self.taskNetworkServices = [ASDKTaskNetworkServices new];
    self.taskNetworkServices.resultsQueue = dispatch_get_main_queue();
    self.taskNetworkServices.parserOperationManager = self.parserOperationManager;
    self.taskNetworkServices.servicePathFactory = [ASDKServicePathFactory new];
    self.taskNetworkServices.diskServices = [ASDKDiskServices new];
    self.requestOperationManagerMock = OCMClassMock([ASDKRequestOperationManager class]);
    
    ASDKTaskDetailsParserOperationWorker *taskDetailsParserWorker = [ASDKTaskDetailsParserOperationWorker new];
    [self.taskNetworkServices.parserOperationManager registerWorker:taskDetailsParserWorker
                                                        forServices:[taskDetailsParserWorker availableServices]];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testThatItFetchesTaskListWithTaskRepresentationFilter {
    // given
    id filter = OCMClassMock([ASDKTaskRequestRepresentation class]);
    
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
    self.taskNetworkServices.requestOperationManager = self.requestOperationManagerMock;
    [self.taskNetworkServices fetchTaskListWithTaskRepresentationFilter:filter
                                                        completionBlock:^(NSArray *taskList, NSError *error, ASDKModelPaging *paging) {
                                                            XCTAssertNil(error);
                                                            XCTAssertNotNil(paging);
                                                            XCTAssertNotNil(taskList);
                                                            
                                                            XCTAssert(taskList.count == 2);
                                                            
                                                            [fetchTaskListExpectation fulfill];
                                                        }];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItHandlesTaskListRequestFailure {
    // given
    id filter = OCMClassMock([ASDKTaskRequestRepresentation class]);
    
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
    self.taskNetworkServices.requestOperationManager = self.requestOperationManagerMock;
    [self.taskNetworkServices fetchTaskListWithTaskRepresentationFilter:filter
                                                        completionBlock:^(NSArray *taskList, NSError *error, ASDKModelPaging *paging) {
                                                            XCTAssertNotNil(error);
                                                            XCTAssertNil(paging);
                                                            XCTAssertNil(taskList);
                                                            
                                                            [fetchTaskListExpectation fulfill];
                                                        }];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItFetchesTaskListWithFilter {
    // given
    id filter = OCMClassMock([ASDKFilterRequestRepresentation class]);
    
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
    self.taskNetworkServices.requestOperationManager = self.requestOperationManagerMock;
    [self.taskNetworkServices fetchTaskListWithFilterRepresentation:filter
                                                    completionBlock:^(NSArray *taskList, NSError *error, ASDKModelPaging *paging) {
                                                        XCTAssertNil(error);
                                                        XCTAssertNotNil(paging);
                                                        XCTAssertNotNil(taskList);
                                                        
                                                        XCTAssert(taskList.count == 2);
                                                        
                                                        [fetchTaskListExpectation fulfill];
                                                    }];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItHandlesFetchTaskListWithFilterRequestFailure {
    // given
    id filter = OCMClassMock([ASDKFilterRequestRepresentation class]);
    
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
    self.taskNetworkServices.requestOperationManager = self.requestOperationManagerMock;
    [self.taskNetworkServices fetchTaskListWithFilterRepresentation:filter
                                                    completionBlock:^(NSArray *taskList, NSError *error, ASDKModelPaging *paging) {
                                                        XCTAssertNotNil(error);
                                                        XCTAssertNil(paging);
                                                        XCTAssertNil(taskList);
                                                        
                                                        [fetchTaskListExpectation fulfill];
                                                    }];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItFetchesTaskDetails {
    // expect
    XCTestExpectation *fetchTaskDetailsExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [[[self.requestOperationManagerMock expect] andDo:^(NSInvocation *invocation) {
        ASDKTestRequestSuccessBlock successBlock;
        NSUInteger successBlockParameterIdxInMethodSignature = 5;
        [invocation getArgument:&successBlock
                        atIndex:successBlockParameterIdxInMethodSignature];
        NSURLSessionDataTask *dataTask = [self dataTaskWithStatusCode:ASDKHTTPCode200OK];
        [invocation setReturnValue:&dataTask];
        
        successBlock(dataTask, [self contentDictionaryFromJSON:@"TaskDetailsResponse"]);
    }] GET:OCMOCK_ANY parameters:OCMOCK_ANY progress:OCMOCK_ANY success:OCMOCK_ANY failure:OCMOCK_ANY];
    
    // when
    self.taskNetworkServices.requestOperationManager = self.requestOperationManagerMock;
    [self.taskNetworkServices fetchTaskDetailsForTaskID:@"id"
                                        completionBlock:^(ASDKModelTask *task, NSError *error) {
                                            XCTAssertNil(error);
                                            XCTAssertNotNil(task);
                                            
                                            [fetchTaskDetailsExpectation fulfill];
                                        }];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItHandlesTaskDetailsRequestFailure {
    // expect
    XCTestExpectation *fetchTaskDetailsExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
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
    self.taskNetworkServices.requestOperationManager = self.requestOperationManagerMock;
    [self.taskNetworkServices fetchTaskDetailsForTaskID:@"id"
                                        completionBlock:^(ASDKModelTask *task, NSError *error) {
                                            XCTAssertNotNil(error);
                                            XCTAssertNil(task);
                                            
                                            [fetchTaskDetailsExpectation fulfill];
                                        }];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItFetchesTaskContent {
    // expect
    XCTestExpectation *fetchTaskContentExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [[[self.requestOperationManagerMock expect] andDo:^(NSInvocation *invocation) {
        ASDKTestRequestSuccessBlock successBlock;
        NSUInteger successBlockParameterIdxInMethodSignature = 5;
        [invocation getArgument:&successBlock
                        atIndex:successBlockParameterIdxInMethodSignature];
        NSURLSessionDataTask *dataTask = [self dataTaskWithStatusCode:ASDKHTTPCode200OK];
        [invocation setReturnValue:&dataTask];
        
        successBlock(dataTask, [self contentDictionaryFromJSON:@"TaskDetailsContentListResponse"]);
    }] GET:OCMOCK_ANY parameters:OCMOCK_ANY progress:OCMOCK_ANY success:OCMOCK_ANY failure:OCMOCK_ANY];
    
    // when
    self.taskNetworkServices.requestOperationManager = self.requestOperationManagerMock;
    [self.taskNetworkServices fetchTaskContentForTaskID:@"id"
                                        completionBlock:^(NSArray *contentList, NSError *error) {
                                            XCTAssertNil(error);
                                            XCTAssertNotNil(contentList);
                                            
                                            XCTAssert(contentList.count == 2);
                                            
                                            [fetchTaskContentExpectation fulfill];
                                        }];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItHandlesTaskContentRequestFailure {
    // expect
    XCTestExpectation *fetchTaskContentExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
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
    self.taskNetworkServices.requestOperationManager = self.requestOperationManagerMock;
    [self.taskNetworkServices fetchTaskContentForTaskID:@"id"
                                        completionBlock:^(NSArray *contentList, NSError *error) {
                                            XCTAssertNil(contentList);
                                            XCTAssertNotNil(error);
                                            
                                            [fetchTaskContentExpectation fulfill];
                                        }];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItFetchesTaskComments {
    // expect
    XCTestExpectation *fetchTaskCommentsExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [[[self.requestOperationManagerMock expect] andDo:^(NSInvocation *invocation) {
        ASDKTestRequestSuccessBlock successBlock;
        NSUInteger successBlockParameterIdxInMethodSignature = 5;
        [invocation getArgument:&successBlock
                        atIndex:successBlockParameterIdxInMethodSignature];
        NSURLSessionDataTask *dataTask = [self dataTaskWithStatusCode:ASDKHTTPCode200OK];
        [invocation setReturnValue:&dataTask];
        
        successBlock(dataTask, [self contentDictionaryFromJSON:@"TaskDetailsCommentListResponse"]);
    }] GET:OCMOCK_ANY parameters:OCMOCK_ANY progress:OCMOCK_ANY success:OCMOCK_ANY failure:OCMOCK_ANY];
    
    //when
    self.taskNetworkServices.requestOperationManager = self.requestOperationManagerMock;
    [self.taskNetworkServices fetchTaskCommentsForTaskID:@"id"
                                         completionBlock:^(NSArray *commentList, NSError *error, ASDKModelPaging *paging) {
                                             XCTAssertNil(error);
                                             XCTAssertNotNil(paging);
                                             XCTAssertNotNil(commentList);
                                             
                                             XCTAssert(commentList.count == 1);
                                             
                                             [fetchTaskCommentsExpectation fulfill];
                                         }];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItHandlesTaskCommentsRequestFailure {
    // expect
    XCTestExpectation *fetchTaskCommentsExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
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
    self.taskNetworkServices.requestOperationManager = self.requestOperationManagerMock;
    [self.taskNetworkServices fetchTaskCommentsForTaskID:@"id"
                                         completionBlock:^(NSArray *commentList, NSError *error, ASDKModelPaging *paging) {
                                             XCTAssertNil(commentList);
                                             XCTAssertNil(paging);
                                             XCTAssertNotNil(error);
                                             
                                             [fetchTaskCommentsExpectation fulfill];
                                         }];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItCreatesTaskComment {
    // expect
    XCTestExpectation *createTaskCommentExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [[[self.requestOperationManagerMock expect] andDo:^(NSInvocation *invocation) {
        ASDKTestRequestSuccessBlock successBlock;
        NSUInteger successBlockParameterIdxInMethodSignature = 5;
        [invocation getArgument:&successBlock
                        atIndex:successBlockParameterIdxInMethodSignature];
        NSURLSessionDataTask *dataTask = [self dataTaskWithStatusCode:ASDKHTTPCode200OK];
        [invocation setReturnValue:&dataTask];
        
        successBlock(dataTask, [self contentDictionaryFromJSON:@"TaskDetailsCreateCommentResponse"]);
    }] POST:OCMOCK_ANY parameters:OCMOCK_ANY progress:OCMOCK_ANY success:OCMOCK_ANY failure:OCMOCK_ANY];
    
    //when
    self.taskNetworkServices.requestOperationManager = self.requestOperationManagerMock;
    [self.taskNetworkServices createComment:@"test"
                                  forTaskID:@"id"
                            completionBlock:^(ASDKModelComment *comment, NSError *error) {
                                XCTAssertNil(error);
                                XCTAssertNotNil(comment);
                                
                                [createTaskCommentExpectation fulfill];
                            }];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItHandlesTaskCreateCommentRequestFailure {
    // expect
    XCTestExpectation *createTaskCommentExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [[[self.requestOperationManagerMock expect] andDo:^(NSInvocation *invocation) {
        ASDKTestRequestFailureBlock failureBlock;
        NSUInteger failureBlockParameterIdxInMethodSignature = 6;
        [invocation getArgument:&failureBlock
                        atIndex:failureBlockParameterIdxInMethodSignature];
        NSURLSessionDataTask *dataTask = [self dataTaskWithStatusCode:ASDKHTTPCode400BadRequest];
        [invocation setReturnValue:&dataTask];
        
        failureBlock(dataTask, [self requestGenericError]);
    }] POST:OCMOCK_ANY parameters:OCMOCK_ANY progress:OCMOCK_ANY success:OCMOCK_ANY failure:OCMOCK_ANY];
    
    //when
    self.taskNetworkServices.requestOperationManager = self.requestOperationManagerMock;
    [self.taskNetworkServices createComment:@"test"
                                  forTaskID:@"id"
                            completionBlock:^(ASDKModelComment *comment, NSError *error) {
                                XCTAssertNil(comment);
                                XCTAssertNotNil(error);
                                
                                [createTaskCommentExpectation fulfill];
                            }];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItUpdatesTaskWithTaskRepresentation {
    // given
    id taskRepresentation = OCMClassMock([ASDKTaskUpdateRequestRepresentation class]);
    
    // expect
    XCTestExpectation *updateTaskExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [[[self.requestOperationManagerMock expect] andDo:^(NSInvocation *invocation) {
        ASDKTestRequestSuccessBlock successBlock;
        NSUInteger successBlockParameterIdxInMethodSignature = 4;
        [invocation getArgument:&successBlock
                        atIndex:successBlockParameterIdxInMethodSignature];
        NSURLSessionDataTask *dataTask = [self dataTaskWithStatusCode:ASDKHTTPCode200OK];
        [invocation setReturnValue:&dataTask];
        
        successBlock(dataTask, nil);
    }] PUT:OCMOCK_ANY parameters:OCMOCK_ANY success:OCMOCK_ANY failure:OCMOCK_ANY];
    
    //when
    self.taskNetworkServices.requestOperationManager = self.requestOperationManagerMock;
    [self.taskNetworkServices updateTaskForTaskID:@"id"
                           withTaskRepresentation:taskRepresentation
                                  completionBlock:^(BOOL isTaskUpdated, NSError *error) {
                                      XCTAssertTrue(isTaskUpdated);
                                      XCTAssertNil(error);
                                      
                                      [updateTaskExpectation fulfill];
                                  }];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItHandlesTaskUpdateWithTaskRepresentation {
    // given
    id taskRepresentation = OCMClassMock([ASDKTaskUpdateRequestRepresentation class]);
    
    // expect
    XCTestExpectation *updateTaskExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [[[self.requestOperationManagerMock expect] andDo:^(NSInvocation *invocation) {
        ASDKTestRequestFailureBlock failureBlock;
        NSUInteger failureBlockParameterIdxInMethodSignature = 5;
        [invocation getArgument:&failureBlock
                        atIndex:failureBlockParameterIdxInMethodSignature];
        NSURLSessionDataTask *dataTask = [self dataTaskWithStatusCode:ASDKHTTPCode400BadRequest];
        [invocation setReturnValue:&dataTask];
        
        failureBlock(dataTask, [self requestGenericError]);
    }] PUT:OCMOCK_ANY parameters:OCMOCK_ANY success:OCMOCK_ANY failure:OCMOCK_ANY];
    
    //when
    self.taskNetworkServices.requestOperationManager = self.requestOperationManagerMock;
    [self.taskNetworkServices updateTaskForTaskID:@"id"
                           withTaskRepresentation:taskRepresentation
                                  completionBlock:^(BOOL isTaskUpdated, NSError *error) {
                                      XCTAssertFalse(isTaskUpdated);
                                      XCTAssertNotNil(error);
                                      
                                      [updateTaskExpectation fulfill];
                                  }];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItCompletesTask {
    // expect
    XCTestExpectation *completeTaskExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [[[self.requestOperationManagerMock expect] andDo:^(NSInvocation *invocation) {
        ASDKTestRequestSuccessBlock successBlock;
        NSUInteger successBlockParameterIdxInMethodSignature = 4;
        [invocation getArgument:&successBlock
                        atIndex:successBlockParameterIdxInMethodSignature];
        NSURLSessionDataTask *dataTask = [self dataTaskWithStatusCode:ASDKHTTPCode200OK];
        [invocation setReturnValue:&dataTask];
        
        successBlock(dataTask, nil);
    }] PUT:OCMOCK_ANY parameters:OCMOCK_ANY success:OCMOCK_ANY failure:OCMOCK_ANY];
    
    //when
    self.taskNetworkServices.requestOperationManager = self.requestOperationManagerMock;
    [self.taskNetworkServices completeTaskForTaskID:@"id"
                                    completionBlock:^(BOOL isTaskCompleted, NSError *error) {
                                        XCTAssertTrue(isTaskCompleted);
                                        XCTAssertNil(error);
                                        
                                        [completeTaskExpectation fulfill];
                                    }];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItHandlesCompleteTaskRequestFailure {
    // expect
    XCTestExpectation *completeTaskExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [[[self.requestOperationManagerMock expect] andDo:^(NSInvocation *invocation) {
        ASDKTestRequestFailureBlock failureBlock;
        NSUInteger failureBlockParameterIdxInMethodSignature = 5;
        [invocation getArgument:&failureBlock
                        atIndex:failureBlockParameterIdxInMethodSignature];
        NSURLSessionDataTask *dataTask = [self dataTaskWithStatusCode:ASDKHTTPCode400BadRequest];
        [invocation setReturnValue:&dataTask];
        
        failureBlock(dataTask, [self requestGenericError]);
    }] PUT:OCMOCK_ANY parameters:OCMOCK_ANY success:OCMOCK_ANY failure:OCMOCK_ANY];
    
    //when
    self.taskNetworkServices.requestOperationManager = self.requestOperationManagerMock;
    [self.taskNetworkServices completeTaskForTaskID:@"id"
                                    completionBlock:^(BOOL isTaskCompleted, NSError *error) {
                                        XCTAssertFalse(isTaskCompleted);
                                        XCTAssertNotNil(error);
                                        
                                        [completeTaskExpectation fulfill];
                                    }];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItHandlesTaskContentUploadProgress {
    // given
    id fileContent = OCMClassMock([ASDKModelFileContent class]);
    
    // expect
    XCTestExpectation *uploadTaskContentExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
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
    self.taskNetworkServices.requestOperationManager = self.requestOperationManagerMock;
    [self.taskNetworkServices uploadContentWithModel:fileContent
                                           forTaskID:@"id"
                                       progressBlock:^(NSUInteger progress, NSError *error) {
                                           XCTAssertNil(error);
                                           XCTAssert(progress == 20);
                                           
                                           [uploadTaskContentExpectation fulfill];
                                       } completionBlock:^(ASDKModelContent *uploadedContent, NSError *error) {}];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItUploadsContentForTask {
    // given
    id fileContent = OCMClassMock([ASDKModelFileContent class]);
    
    // expect
    XCTestExpectation *uploadTaskContentExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
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
    self.taskNetworkServices.requestOperationManager = self.requestOperationManagerMock;
    [self.taskNetworkServices uploadContentWithModel:fileContent
                                           forTaskID:@"id"
                                       progressBlock:nil
                                     completionBlock:^(ASDKModelContent *uploadedContent, NSError *error) {
                                         XCTAssertNotNil(uploadedContent);
                                         XCTAssertNil(error);
                                         
                                         [uploadTaskContentExpectation fulfill];
                                     }];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItHandlesTaskContentUploadRequestFailure {
    // given
    id fileContent = OCMClassMock([ASDKModelFileContent class]);
    
    // expect
    XCTestExpectation *uploadTaskContentExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
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
    self.taskNetworkServices.requestOperationManager = self.requestOperationManagerMock;
    [self.taskNetworkServices uploadContentWithModel:fileContent
                                           forTaskID:@"id"
                                       progressBlock:nil
                                     completionBlock:^(ASDKModelContent *uploadedContent, NSError *error) {
                                         XCTAssertNil(uploadedContent);
                                         XCTAssertNotNil(error);
                                         
                                         [uploadTaskContentExpectation fulfill];
                                     }];
    
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItHandlesTaskContentUploadWithContentDataProgress {
    // given
    id fileContent = OCMClassMock([ASDKModelFileContent class]);
    NSData *dummyData = [self createRandomNSDataOfSize:100];
    
    // expect
    XCTestExpectation *uploadTaskContentExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
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
    self.taskNetworkServices.requestOperationManager = self.requestOperationManagerMock;
    [self.taskNetworkServices uploadContentWithModel:fileContent
                                         contentData:dummyData
                                           forTaskID:@"id"
                                       progressBlock:^(NSUInteger progress, NSError *error) {
                                           XCTAssertNil(error);
                                           XCTAssert(progress == 20);
                                           
                                           [uploadTaskContentExpectation fulfill];
                                       } completionBlock:^(ASDKModelContent *uploadedContent, NSError *error) {}];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItUploadsTaskContentForContentData {
    // given
    id fileContent = OCMClassMock([ASDKModelFileContent class]);
    NSData *dummyData = [self createRandomNSDataOfSize:100];
    
    // expect
    XCTestExpectation *uploadTaskContentExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
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
    self.taskNetworkServices.requestOperationManager = self.requestOperationManagerMock;
    [self.taskNetworkServices uploadContentWithModel:fileContent
                                         contentData:dummyData
                                           forTaskID:@"id"
                                       progressBlock:nil
                                     completionBlock:^(ASDKModelContent *uploadedContent, NSError *error) {
                                         XCTAssertNil(error);
                                         XCTAssertNotNil(uploadedContent);
                                         
                                         [uploadTaskContentExpectation fulfill];
                                     }];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
    
}

- (void)testThatItHandlesTaskContentUploadWithContentDataRequestFailure {
    // given
    id fileContent = OCMClassMock([ASDKModelFileContent class]);
    NSData *dummyData = [self createRandomNSDataOfSize:100];
    
    // expect
    XCTestExpectation *uploadTaskContentExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
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
    self.taskNetworkServices.requestOperationManager = self.requestOperationManagerMock;
    [self.taskNetworkServices uploadContentWithModel:fileContent
                                         contentData:dummyData
                                           forTaskID:@"id"
                                       progressBlock:nil
                                     completionBlock:^(ASDKModelContent *uploadedContent, NSError *error) {
                                         XCTAssertNotNil(error);
                                         XCTAssertNil(uploadedContent);
                                         
                                         [uploadTaskContentExpectation fulfill];
                                     }];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItDeletesTaskContent {
    // given
    id fileContent = OCMClassMock([ASDKModelContent class]);
    
    // expect
    XCTestExpectation *deleteTaskContentExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [[[self.requestOperationManagerMock expect] andDo:^(NSInvocation *invocation) {
        ASDKTestRequestSuccessBlock successBlock;
        NSUInteger successBlockParameterIdxInMethodSignature = 4;
        [invocation getArgument:&successBlock
                        atIndex:successBlockParameterIdxInMethodSignature];
        NSURLSessionDataTask *dataTask = [self dataTaskWithStatusCode:ASDKHTTPCode200OK];
        [invocation setReturnValue:&dataTask];
        
        successBlock(dataTask, nil);
    }] DELETE:OCMOCK_ANY parameters:OCMOCK_ANY success:OCMOCK_ANY failure:OCMOCK_ANY];
    
    //when
    self.taskNetworkServices.requestOperationManager = self.requestOperationManagerMock;
    [self.taskNetworkServices deleteContent:fileContent
                            completionBlock:^(BOOL isContentDeleted, NSError *error) {
                                XCTAssertNil(error);
                                XCTAssertTrue(isContentDeleted);
                                
                                [deleteTaskContentExpectation fulfill];
                            }];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItHandlesDeleteTaskContentRequestFailure {
    // given
    id fileContent = OCMClassMock([ASDKModelContent class]);
    
    // expect
    XCTestExpectation *deleteTaskContentExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [[[self.requestOperationManagerMock expect] andDo:^(NSInvocation *invocation) {
        ASDKTestRequestFailureBlock failureBlock;
        NSUInteger failureBlockParameterIdxInMethodSignature = 5;
        [invocation getArgument:&failureBlock
                        atIndex:failureBlockParameterIdxInMethodSignature];
        NSURLSessionDataTask *dataTask = [self dataTaskWithStatusCode:ASDKHTTPCode400BadRequest];
        [invocation setReturnValue:&dataTask];
        
        failureBlock(dataTask, [self requestGenericError]);
    }] DELETE:OCMOCK_ANY parameters:OCMOCK_ANY success:OCMOCK_ANY failure:OCMOCK_ANY];
    
    //when
    self.taskNetworkServices.requestOperationManager = self.requestOperationManagerMock;
    [self.taskNetworkServices deleteContent:fileContent
                            completionBlock:^(BOOL isContentDeleted, NSError *error) {
                                XCTAssertNotNil(error);
                                XCTAssertFalse(isContentDeleted);
                                
                                [deleteTaskContentExpectation fulfill];
                            }];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItDownloadsTaskContentAndReturnsCachedResults {
    // given
    id fileContent = OCMClassMock([ASDKModelContent class]);
    id diskServices = OCMPartialMock(self.taskNetworkServices.diskServices);
    OCMStub([fileContent modelID]).andReturn(@"100");
    OCMStub([fileContent contentName]).andReturn(@"IMG_001");
    
    // expect
    XCTestExpectation *downloadsTaskContentExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    OCMStub([diskServices doesFileAlreadyExistsForContent:OCMOCK_ANY]).andReturn(YES);
    
    // when
    self.taskNetworkServices.diskServices = diskServices;
    [self.taskNetworkServices downloadContent:fileContent
                           allowCachedResults:YES
                                progressBlock:nil
                              completionBlock:^(NSURL *downloadedContentURL, BOOL isLocalContent, NSError *error) {
                                  XCTAssertNotNil(downloadedContentURL);
                                  XCTAssertTrue(isLocalContent);
                                  XCTAssertNil(error);
                                  
                                  [downloadsTaskContentExpectation fulfill];
                              }];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItDownloadsTaskContentAndReportsProgress {
    // given
    id fileContent = OCMClassMock([ASDKModelContent class]);
    
    // expect
    XCTestExpectation *downloadTaskContentExpectation = [self expectationWithDescription:[NSString stringWithFormat:@"%@.downloadContentCompletion", NSStringFromSelector(_cmd)]];
    XCTestExpectation *downloadTaskContentProgressExpectation = [self expectationWithDescription:[NSString stringWithFormat:@"%@.downloadContentProgress", NSStringFromSelector(_cmd)]];
    
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
    self.taskNetworkServices.requestOperationManager = self.requestOperationManagerMock;
    [self.taskNetworkServices downloadContent:fileContent
                           allowCachedResults:NO
                                progressBlock:^(NSString *formattedReceivedBytesString, NSError *error) {
                                    XCTAssert([formattedReceivedBytesString isEqualToString:@"200.00 bytes"]);
                                    XCTAssertNil(error);
                                    
                                    [downloadTaskContentProgressExpectation fulfill];
                                }
                              completionBlock:^(NSURL *downloadedContentURL, BOOL isLocalContent, NSError *error) {
                                  XCTAssertNotNil(downloadedContentURL);
                                  XCTAssertFalse(isLocalContent);
                                  XCTAssertNil(error);
                                  
                                  [downloadTaskContentExpectation fulfill];
                              }];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItHandlesTaskContentDownloadRequestFailure {
    // given
    id fileContent = OCMClassMock([ASDKModelContent class]);
    
    // expect
    XCTestExpectation *downloadTaskContentExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
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
    self.taskNetworkServices.requestOperationManager = self.requestOperationManagerMock;
    [self.taskNetworkServices downloadContent:fileContent
                           allowCachedResults:NO
                                progressBlock:nil
                              completionBlock:^(NSURL *downloadedContentURL, BOOL isLocalContent, NSError *error) {
                                  XCTAssertNil(downloadedContentURL);
                                  XCTAssertFalse(isLocalContent);
                                  XCTAssertNotNil(error);
                                  
                                  [downloadTaskContentExpectation fulfill];
                              }];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItDownloadsThumbnailForContentAndReturnsCachedResults {
    // given
    id fileContent = OCMClassMock([ASDKModelContent class]);
    id diskServices = OCMPartialMock(self.taskNetworkServices.diskServices);
    OCMStub([fileContent modelID]).andReturn(@"100");
    OCMStub([fileContent contentName]).andReturn(@"IMG_001");
    
    // expect
    XCTestExpectation *downloadsTaskContentThumbnailExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    OCMStub([diskServices doesThumbnailAlreadyExistsForContent:OCMOCK_ANY]).andReturn(YES);
    
    // when
    self.taskNetworkServices.diskServices = diskServices;
    [self.taskNetworkServices downloadThumbnailForContent:fileContent
                                       allowCachedResults:YES
                                            progressBlock:nil
                                          completionBlock:^(NSURL *downloadedContentURL, BOOL isLocalContent, NSError *error) {
                                              XCTAssertNotNil(downloadedContentURL);
                                              XCTAssertTrue(isLocalContent);
                                              XCTAssertNil(error);
                                              
                                              [downloadsTaskContentThumbnailExpectation fulfill];
                                          }];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItDownloadsTaskContentThumbnailAndReportsProgress {
    // given
    id fileContent = OCMClassMock([ASDKModelContent class]);
    
    // expect
    XCTestExpectation *downloadTaskContentThumbnailExpectation = [self expectationWithDescription:[NSString stringWithFormat:@"%@.downloadContentCompletion", NSStringFromSelector(_cmd)]];
    XCTestExpectation *downloadTaskContentThumbnailProgressExpectation = [self expectationWithDescription:[NSString stringWithFormat:@"%@.downloadContentProgress", NSStringFromSelector(_cmd)]];
    
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
    self.taskNetworkServices.requestOperationManager = self.requestOperationManagerMock;
    [self.taskNetworkServices downloadThumbnailForContent:fileContent
                                       allowCachedResults:NO
                                            progressBlock:^(NSString *formattedReceivedBytesString, NSError *error) {
                                                XCTAssert([formattedReceivedBytesString isEqualToString:@"200.00 bytes"]);
                                                XCTAssertNil(error);
                                                
                                                [downloadTaskContentThumbnailProgressExpectation fulfill];
                                            } completionBlock:^(NSURL *downloadedContentURL, BOOL isLocalContent, NSError *error) {
                                                XCTAssertNotNil(downloadedContentURL);
                                                XCTAssertFalse(isLocalContent);
                                                XCTAssertNil(error);
                                                
                                                [downloadTaskContentThumbnailExpectation fulfill];
                                            }];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItHandlesTaskContentThumbnailDownloadRequestFailure {
    // given
    id fileContent = OCMClassMock([ASDKModelContent class]);
    
    // expect
    XCTestExpectation *downloadTaskContentThumbnailExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
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
    self.taskNetworkServices.requestOperationManager = self.requestOperationManagerMock;
    [self.taskNetworkServices downloadThumbnailForContent:fileContent
                                       allowCachedResults:NO
                                            progressBlock:nil
                                          completionBlock:^(NSURL *downloadedContentURL, BOOL isLocalContent, NSError *error) {
                                              XCTAssertNil(downloadedContentURL);
                                              XCTAssertFalse(isLocalContent);
                                              XCTAssertNotNil(error);
                                              
                                              [downloadTaskContentThumbnailExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItInvolvesUserWithIDForTask {
    // given
    id user = OCMClassMock([ASDKModelUser class]);
    OCMStub([user modelID]).andReturn(@"100");
    
    // expect
    XCTestExpectation *involveUserExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [[[self.requestOperationManagerMock expect] andDo:^(NSInvocation *invocation) {
        ASDKTestRequestSuccessBlock successBlock;
        NSUInteger successBlockParameterIdxInMethodSignature = 4;
        [invocation getArgument:&successBlock
                        atIndex:successBlockParameterIdxInMethodSignature];
        NSURLSessionDataTask *dataTask = [self dataTaskWithStatusCode:ASDKHTTPCode200OK];
        [invocation setReturnValue:&dataTask];
        
        successBlock(dataTask, nil);
    }] PUT:OCMOCK_ANY parameters:OCMOCK_ANY success:OCMOCK_ANY failure:OCMOCK_ANY];
    
    //when
    self.taskNetworkServices.requestOperationManager = self.requestOperationManagerMock;
    [self.taskNetworkServices involveUserWithID:@"id"
                                      forTaskID:@"id"
                                completionBlock:^(BOOL isUserInvolved, NSError *error) {
                                    XCTAssertNil(error);
                                    XCTAssertTrue(isUserInvolved);
                                    
                                    [involveUserExpectation fulfill];
                                }];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItInvolvesUserWithEmailAddressForTask {
    // given
    id user = OCMClassMock([ASDKModelUser class]);
    OCMStub([user modelID]).andReturn(@"100");
    
    // expect
    XCTestExpectation *involveUserExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [[[self.requestOperationManagerMock expect] andDo:^(NSInvocation *invocation) {
        ASDKTestRequestSuccessBlock successBlock;
        NSUInteger successBlockParameterIdxInMethodSignature = 4;
        [invocation getArgument:&successBlock
                        atIndex:successBlockParameterIdxInMethodSignature];
        NSURLSessionDataTask *dataTask = [self dataTaskWithStatusCode:ASDKHTTPCode200OK];
        [invocation setReturnValue:&dataTask];
        
        successBlock(dataTask, nil);
    }] PUT:OCMOCK_ANY parameters:OCMOCK_ANY success:OCMOCK_ANY failure:OCMOCK_ANY];
    
    //when
    self.taskNetworkServices.requestOperationManager = self.requestOperationManagerMock;
    [self.taskNetworkServices involveUserWithEmailAddress:@"email"
                                                forTaskID:@"id"
                                          completionBlock:^(BOOL isUserInvolved, NSError *error) {
                                              XCTAssertNil(error);
                                              XCTAssertTrue(isUserInvolved);
                                              
                                              [involveUserExpectation fulfill];
                                          }];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItHandlesUserWithIDInvolvementRequestFailure {
    // given
    id user = OCMClassMock([ASDKModelUser class]);
    OCMStub([user modelID]).andReturn(@"100");
    
    // expect
    XCTestExpectation *involveUserExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [[[self.requestOperationManagerMock expect] andDo:^(NSInvocation *invocation) {
        ASDKTestRequestFailureBlock failureBlock;
        NSUInteger failureBlockParameterIdxInMethodSignature = 5;
        [invocation getArgument:&failureBlock
                        atIndex:failureBlockParameterIdxInMethodSignature];
        NSURLSessionDataTask *dataTask = [self dataTaskWithStatusCode:ASDKHTTPCode400BadRequest];
        [invocation setReturnValue:&dataTask];
        
        failureBlock(dataTask, [self requestGenericError]);
    }] PUT:OCMOCK_ANY parameters:OCMOCK_ANY success:OCMOCK_ANY failure:OCMOCK_ANY];
    
    //when
    self.taskNetworkServices.requestOperationManager = self.requestOperationManagerMock;
    [self.taskNetworkServices involveUserWithID:@"id"
                                      forTaskID:@"id"
                                completionBlock:^(BOOL isUserInvolved, NSError *error) {
                                    XCTAssertNotNil(error);
                                    XCTAssertFalse(isUserInvolved);
                                    
                                    [involveUserExpectation fulfill];
                                }];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItHandlesUserWithEmailAddressInvolvementRequestFailure {
    // given
    id user = OCMClassMock([ASDKModelUser class]);
    OCMStub([user modelID]).andReturn(@"100");
    
    // expect
    XCTestExpectation *involveUserExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [[[self.requestOperationManagerMock expect] andDo:^(NSInvocation *invocation) {
        ASDKTestRequestFailureBlock failureBlock;
        NSUInteger failureBlockParameterIdxInMethodSignature = 5;
        [invocation getArgument:&failureBlock
                        atIndex:failureBlockParameterIdxInMethodSignature];
        NSURLSessionDataTask *dataTask = [self dataTaskWithStatusCode:ASDKHTTPCode400BadRequest];
        [invocation setReturnValue:&dataTask];
        
        failureBlock(dataTask, [self requestGenericError]);
    }] PUT:OCMOCK_ANY parameters:OCMOCK_ANY success:OCMOCK_ANY failure:OCMOCK_ANY];
    
    //when
    self.taskNetworkServices.requestOperationManager = self.requestOperationManagerMock;
    [self.taskNetworkServices involveUserWithEmailAddress:@"email"
                                                forTaskID:@"id"
                                          completionBlock:^(BOOL isUserInvolved, NSError *error) {
                                              XCTAssertNotNil(error);
                                              XCTAssertFalse(isUserInvolved);
                                              
                                              [involveUserExpectation fulfill];
                                          }];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItRemovesInvolvedUserWithID {
    // given
    id user = OCMClassMock([ASDKModelUser class]);
    OCMStub([user modelID]).andReturn(@"100");
    
    // expect
    XCTestExpectation *involveUserExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [[[self.requestOperationManagerMock expect] andDo:^(NSInvocation *invocation) {
        ASDKTestRequestSuccessBlock successBlock;
        NSUInteger successBlockParameterIdxInMethodSignature = 4;
        [invocation getArgument:&successBlock
                        atIndex:successBlockParameterIdxInMethodSignature];
        NSURLSessionDataTask *dataTask = [self dataTaskWithStatusCode:ASDKHTTPCode200OK];
        [invocation setReturnValue:&dataTask];
        
        successBlock(dataTask, nil);
    }] PUT:OCMOCK_ANY parameters:OCMOCK_ANY success:OCMOCK_ANY failure:OCMOCK_ANY];
    
    //when
    self.taskNetworkServices.requestOperationManager = self.requestOperationManagerMock;
    [self.taskNetworkServices removeInvolvedUserWithID:@"id"
                                             forTaskID:@"id"
                                       completionBlock:^(BOOL isUserInvolved, NSError *error) {
                                           XCTAssertFalse(isUserInvolved);
                                           XCTAssertNil(error);
                                           
                                           [involveUserExpectation fulfill];
                                       }];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItRemovesInvolvedUserWithEmailAddress {
    // given
    id user = OCMClassMock([ASDKModelUser class]);
    OCMStub([user modelID]).andReturn(@"100");
    
    // expect
    XCTestExpectation *involveUserExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [[[self.requestOperationManagerMock expect] andDo:^(NSInvocation *invocation) {
        ASDKTestRequestSuccessBlock successBlock;
        NSUInteger successBlockParameterIdxInMethodSignature = 4;
        [invocation getArgument:&successBlock
                        atIndex:successBlockParameterIdxInMethodSignature];
        NSURLSessionDataTask *dataTask = [self dataTaskWithStatusCode:ASDKHTTPCode200OK];
        [invocation setReturnValue:&dataTask];
        
        successBlock(dataTask, nil);
    }] PUT:OCMOCK_ANY parameters:OCMOCK_ANY success:OCMOCK_ANY failure:OCMOCK_ANY];
    
    //when
    self.taskNetworkServices.requestOperationManager = self.requestOperationManagerMock;
    [self.taskNetworkServices removeInvolvedUserWithEmailAddress:@"email"
                                                       forTaskID:@"id"
                                                 completionBlock:^(BOOL isUserInvolved, NSError *error) {
                                                     XCTAssertFalse(isUserInvolved);
                                                     XCTAssertNil(error);
                                                     
                                                     [involveUserExpectation fulfill];
                                                 }];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItHandlesRemoveInvolvedUserWithIDRequestFailure {
    // given
    id user = OCMClassMock([ASDKModelUser class]);
    OCMStub([user modelID]).andReturn(@"100");
    
    // expect
    XCTestExpectation *involveUserExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [[[self.requestOperationManagerMock expect] andDo:^(NSInvocation *invocation) {
        ASDKTestRequestFailureBlock failureBlock;
        NSUInteger failureBlockParameterIdxInMethodSignature = 5;
        [invocation getArgument:&failureBlock
                        atIndex:failureBlockParameterIdxInMethodSignature];
        NSURLSessionDataTask *dataTask = [self dataTaskWithStatusCode:ASDKHTTPCode400BadRequest];
        [invocation setReturnValue:&dataTask];
        
        failureBlock(dataTask, [self requestGenericError]);
    }] PUT:OCMOCK_ANY parameters:OCMOCK_ANY success:OCMOCK_ANY failure:OCMOCK_ANY];
    
    //when
    self.taskNetworkServices.requestOperationManager = self.requestOperationManagerMock;
    [self.taskNetworkServices removeInvolvedUserWithID:@"id"
                                             forTaskID:@"id"
                                       completionBlock:^(BOOL isUserInvolved, NSError *error) {
                                           XCTAssertTrue(isUserInvolved);
                                           XCTAssertNotNil(error);
                                           
                                           [involveUserExpectation fulfill];
                                       }];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItHandlesRemoveInvolvedUserWithEmailAddressRequestFailure {
    // given
    id user = OCMClassMock([ASDKModelUser class]);
    OCMStub([user modelID]).andReturn(@"100");
    
    // expect
    XCTestExpectation *involveUserExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [[[self.requestOperationManagerMock expect] andDo:^(NSInvocation *invocation) {
        ASDKTestRequestFailureBlock failureBlock;
        NSUInteger failureBlockParameterIdxInMethodSignature = 5;
        [invocation getArgument:&failureBlock
                        atIndex:failureBlockParameterIdxInMethodSignature];
        NSURLSessionDataTask *dataTask = [self dataTaskWithStatusCode:ASDKHTTPCode400BadRequest];
        [invocation setReturnValue:&dataTask];
        
        failureBlock(dataTask, [self requestGenericError]);
    }] PUT:OCMOCK_ANY parameters:OCMOCK_ANY success:OCMOCK_ANY failure:OCMOCK_ANY];
    
    //when
    self.taskNetworkServices.requestOperationManager = self.requestOperationManagerMock;
    [self.taskNetworkServices removeInvolvedUserWithEmailAddress:@"email"
                                                       forTaskID:@"id"
                                                 completionBlock:^(BOOL isUserInvolved, NSError *error) {
                                                     XCTAssertTrue(isUserInvolved);
                                                     XCTAssertNotNil(error);
                                                     
                                                     [involveUserExpectation fulfill];
                                                 }];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItCreatesTask {
    // given
    id taskRepresentation = OCMClassMock([ASDKTaskCreationRequestRepresentation class]);
    
    // expect
    XCTestExpectation *createTaskExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [[[self.requestOperationManagerMock expect] andDo:^(NSInvocation *invocation) {
        ASDKTestRequestSuccessBlock successBlock;
        NSUInteger successBlockParameterIdxInMethodSignature = 5;
        [invocation getArgument:&successBlock
                        atIndex:successBlockParameterIdxInMethodSignature];
        NSURLSessionDataTask *dataTask = [self dataTaskWithStatusCode:ASDKHTTPCode200OK];
        [invocation setReturnValue:&dataTask];
        
        successBlock(dataTask, [self contentDictionaryFromJSON:@"TaskDetailsResponse"]);
    }] POST:OCMOCK_ANY parameters:OCMOCK_ANY progress:OCMOCK_ANY success:OCMOCK_ANY failure:OCMOCK_ANY];
    
    //when
    self.taskNetworkServices.requestOperationManager = self.requestOperationManagerMock;
    [self.taskNetworkServices createTaskWithRepresentation:taskRepresentation
                                           completionBlock:^(ASDKModelTask *task, NSError *error) {
                                               XCTAssertNil(error);
                                               XCTAssertNotNil(task);
                                               
                                               [createTaskExpectation fulfill];
                                           }];
    
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItHandlesCreateTaskRequestFailure {
    // given
    id taskRepresentation = OCMClassMock([ASDKTaskCreationRequestRepresentation class]);
    
    // expect
    XCTestExpectation *createTaskExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [[[self.requestOperationManagerMock expect] andDo:^(NSInvocation *invocation) {
        ASDKTestRequestFailureBlock failureBlock;
        NSUInteger failureBlockParameterIdxInMethodSignature = 6;
        [invocation getArgument:&failureBlock
                        atIndex:failureBlockParameterIdxInMethodSignature];
        NSURLSessionDataTask *dataTask = [self dataTaskWithStatusCode:ASDKHTTPCode400BadRequest];
        [invocation setReturnValue:&dataTask];
        
        failureBlock(dataTask, [self requestGenericError]);
    }] POST:OCMOCK_ANY parameters:OCMOCK_ANY progress:OCMOCK_ANY success:OCMOCK_ANY failure:OCMOCK_ANY];
    
    //when
    self.taskNetworkServices.requestOperationManager = self.requestOperationManagerMock;
    [self.taskNetworkServices createTaskWithRepresentation:taskRepresentation
                                           completionBlock:^(ASDKModelTask *task, NSError *error) {
                                               XCTAssertNil(task);
                                               XCTAssertNotNil(error);
                                               
                                               [createTaskExpectation fulfill];
                                           }];
    
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

-  (void)testThatItClaimsTask {
    // expect
    XCTestExpectation *claimTaskExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [[[self.requestOperationManagerMock expect] andDo:^(NSInvocation *invocation) {
        ASDKTestRequestSuccessBlock successBlock;
        NSUInteger successBlockParameterIdxInMethodSignature = 4;
        [invocation getArgument:&successBlock
                        atIndex:successBlockParameterIdxInMethodSignature];
        NSURLSessionDataTask *dataTask = [self dataTaskWithStatusCode:ASDKHTTPCode200OK];
        [invocation setReturnValue:&dataTask];
        
        successBlock(dataTask, nil);
    }] PUT:OCMOCK_ANY parameters:OCMOCK_ANY success:OCMOCK_ANY failure:OCMOCK_ANY];
    
    //when
    self.taskNetworkServices.requestOperationManager = self.requestOperationManagerMock;
    [self.taskNetworkServices claimTaskWithID:@"id"
                              completionBlock:^(BOOL isTaskClaimed, NSError *error) {
                                  XCTAssertTrue(isTaskClaimed);
                                  XCTAssertNil(error);
                                  
                                  [claimTaskExpectation fulfill];
                              }];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItHandlesTaskClaimRequestFailure {
    // expect
    XCTestExpectation *claimTaskExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [[[self.requestOperationManagerMock expect] andDo:^(NSInvocation *invocation) {
        ASDKTestRequestFailureBlock failureBlock;
        NSUInteger failureBlockParameterIdxInMethodSignature = 5;
        [invocation getArgument:&failureBlock
                        atIndex:failureBlockParameterIdxInMethodSignature];
        NSURLSessionDataTask *dataTask = [self dataTaskWithStatusCode:ASDKHTTPCode400BadRequest];
        [invocation setReturnValue:&dataTask];
        
        failureBlock(dataTask, [self requestGenericError]);
    }] PUT:OCMOCK_ANY parameters:OCMOCK_ANY success:OCMOCK_ANY failure:OCMOCK_ANY];
    
    //when
    self.taskNetworkServices.requestOperationManager = self.requestOperationManagerMock;
    [self.taskNetworkServices claimTaskWithID:@"id"
                              completionBlock:^(BOOL isTaskClaimed, NSError *error) {
                                  XCTAssertFalse(isTaskClaimed);
                                  XCTAssertNotNil(error);
                                  
                                  [claimTaskExpectation fulfill];
                              }];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItUnclaimsTask {
    // expect
    XCTestExpectation *unclaimTaskExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [[[self.requestOperationManagerMock expect] andDo:^(NSInvocation *invocation) {
        ASDKTestRequestSuccessBlock successBlock;
        NSUInteger successBlockParameterIdxInMethodSignature = 4;
        [invocation getArgument:&successBlock
                        atIndex:successBlockParameterIdxInMethodSignature];
        NSURLSessionDataTask *dataTask = [self dataTaskWithStatusCode:ASDKHTTPCode200OK];
        [invocation setReturnValue:&dataTask];
        
        successBlock(dataTask, nil);
    }] PUT:OCMOCK_ANY parameters:OCMOCK_ANY success:OCMOCK_ANY failure:OCMOCK_ANY];
    
    // when
    self.taskNetworkServices.requestOperationManager = self.requestOperationManagerMock;
    [self.taskNetworkServices unclaimTaskWithID:@"id"
                                completionBlock:^(BOOL isTaskClaimed, NSError *error) {
                                    XCTAssertNil(error);
                                    XCTAssertFalse(isTaskClaimed);
                                    
                                    [unclaimTaskExpectation fulfill];
                                }];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItHandlesTaskUnclaim {
    // expect
    XCTestExpectation *unclaimTaskExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [[[self.requestOperationManagerMock expect] andDo:^(NSInvocation *invocation) {
        ASDKTestRequestFailureBlock failureBlock;
        NSUInteger failureBlockParameterIdxInMethodSignature = 5;
        [invocation getArgument:&failureBlock
                        atIndex:failureBlockParameterIdxInMethodSignature];
        NSURLSessionDataTask *dataTask = [self dataTaskWithStatusCode:ASDKHTTPCode400BadRequest];
        [invocation setReturnValue:&dataTask];
        
        failureBlock(dataTask, [self requestGenericError]);
    }] PUT:OCMOCK_ANY parameters:OCMOCK_ANY success:OCMOCK_ANY failure:OCMOCK_ANY];
    
    // when
    self.taskNetworkServices.requestOperationManager = self.requestOperationManagerMock;
    [self.taskNetworkServices unclaimTaskWithID:@"id"
                                completionBlock:^(BOOL isTaskClaimed, NSError *error) {
                                    XCTAssertNotNil(error);
                                    XCTAssertTrue(isTaskClaimed);
                                    
                                    [unclaimTaskExpectation fulfill];
                                }];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItAssignsTaskToUser {
    // given
    id user = OCMClassMock([ASDKModelUser class]);
    OCMStub([user modelID]).andReturn(@"100");
    
    // expect
    XCTestExpectation *assignTaskExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [[[self.requestOperationManagerMock expect] andDo:^(NSInvocation *invocation) {
        ASDKTestRequestSuccessBlock successBlock;
        NSUInteger successBlockParameterIdxInMethodSignature = 4;
        [invocation getArgument:&successBlock
                        atIndex:successBlockParameterIdxInMethodSignature];
        NSURLSessionDataTask *dataTask = [self dataTaskWithStatusCode:ASDKHTTPCode200OK];
        [invocation setReturnValue:&dataTask];
        
        successBlock(dataTask, [self contentDictionaryFromJSON:@"TaskDetailsResponse"]);
    }] PUT:OCMOCK_ANY parameters:OCMOCK_ANY success:OCMOCK_ANY failure:OCMOCK_ANY];
    
    // when
    self.taskNetworkServices.requestOperationManager = self.requestOperationManagerMock;
    [self.taskNetworkServices assignTaskWithID:@"id"
                                        toUser:user
                               completionBlock:^(ASDKModelTask *task, NSError *error) {
                                   XCTAssertNil(error);
                                   XCTAssertNotNil(task);
                                   
                                   [assignTaskExpectation fulfill];
                               }];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItHandlesTaskAssignmentRequestFailure {
    // given
    id user = OCMClassMock([ASDKModelUser class]);
    OCMStub([user modelID]).andReturn(@"100");
    
    // expect
    XCTestExpectation *assignTaskExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [[[self.requestOperationManagerMock expect] andDo:^(NSInvocation *invocation) {
        ASDKTestRequestFailureBlock failureBlock;
        NSUInteger failureBlockParameterIdxInMethodSignature = 5;
        [invocation getArgument:&failureBlock
                        atIndex:failureBlockParameterIdxInMethodSignature];
        NSURLSessionDataTask *dataTask = [self dataTaskWithStatusCode:ASDKHTTPCode400BadRequest];
        [invocation setReturnValue:&dataTask];
        
        failureBlock(dataTask, [self requestGenericError]);
    }] PUT:OCMOCK_ANY parameters:OCMOCK_ANY success:OCMOCK_ANY failure:OCMOCK_ANY];
    
    // when
    self.taskNetworkServices.requestOperationManager = self.requestOperationManagerMock;
    [self.taskNetworkServices assignTaskWithID:@"id"
                                        toUser:user
                               completionBlock:^(ASDKModelTask *task, NSError *error) {
                                   XCTAssertNil(task);
                                   XCTAssertNotNil(error);
                                   
                                   [assignTaskExpectation fulfill];
                               }];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItDownloadsTaskAuditAndReturnsCachedResults {
    // given
    id diskServices = OCMPartialMock(self.taskNetworkServices.diskServices);
    
    // expect
    XCTestExpectation *downloadsTaskAuditLogExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    OCMStub([diskServices doesFileAlreadyExistsForResouceWithIdentifier:OCMOCK_ANY filename:OCMOCK_ANY]).andReturn(YES);
    
    // when
    self.taskNetworkServices.diskServices = diskServices;
    [self.taskNetworkServices downloadAuditLogForTaskWithID:@"id"
                                         allowCachedResults:YES
                                              progressBlock:nil
                                            completionBlock:^(NSURL *downloadedContentURL, BOOL isLocalContent, NSError *error) {
                                                XCTAssertNotNil(downloadedContentURL);
                                                XCTAssertTrue(isLocalContent);
                                                XCTAssertNil(error);
                                                
                                                [downloadsTaskAuditLogExpectation fulfill];
                                            }];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItDownloadsTaskAuditLogAndReportsProgress {
    // expect
    XCTestExpectation *downloadTaskAuditLogExpectation = [self expectationWithDescription:[NSString stringWithFormat:@"%@.downloadContentCompletion", NSStringFromSelector(_cmd)]];
    XCTestExpectation *downloadTaskAuditLogProgressExpectation = [self expectationWithDescription:[NSString stringWithFormat:@"%@.downloadContentProgress", NSStringFromSelector(_cmd)]];
    
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
    
    self.taskNetworkServices.requestOperationManager = self.requestOperationManagerMock;
    [self.taskNetworkServices downloadAuditLogForTaskWithID:@"id"
                                         allowCachedResults:NO
                                              progressBlock:^(NSString *formattedReceivedBytesString, NSError *error) {
                                                  XCTAssert([formattedReceivedBytesString isEqualToString:@"200.00 bytes"]);
                                                  XCTAssertNil(error);
                                                  
                                                  [downloadTaskAuditLogProgressExpectation fulfill];
                                              }
                                            completionBlock:^(NSURL *downloadedContentURL, BOOL isLocalContent, NSError *error) {
                                                XCTAssertNotNil(downloadedContentURL);
                                                XCTAssertFalse(isLocalContent);
                                                XCTAssertNil(error);
                                                
                                                [downloadTaskAuditLogExpectation fulfill];
                                            }];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItHandlesDownloadTaskAuditLogRequestFailure {
    // expect
    XCTestExpectation *downloadTaskAuditLogExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
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
    self.taskNetworkServices.requestOperationManager = self.requestOperationManagerMock;
    [self.taskNetworkServices downloadAuditLogForTaskWithID:@"id"
                                         allowCachedResults:NO
                                              progressBlock:nil
                                            completionBlock:^(NSURL *downloadedContentURL, BOOL isLocalContent, NSError *error) {
                                                XCTAssertNil(downloadedContentURL);
                                                XCTAssertFalse(isLocalContent);
                                                XCTAssertNotNil(error);
                                                
                                                [downloadTaskAuditLogExpectation fulfill];
                                            }];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItFetchesCheckListForTask {
    // expect
    XCTestExpectation *fetchChecklistExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [[[self.requestOperationManagerMock expect] andDo:^(NSInvocation *invocation) {
        ASDKTestRequestSuccessBlock successBlock;
        NSUInteger successBlockParameterIdxInMethodSignature = 5;
        [invocation getArgument:&successBlock
                        atIndex:successBlockParameterIdxInMethodSignature];
        NSURLSessionDataTask *dataTask = [self dataTaskWithStatusCode:ASDKHTTPCode200OK];
        [invocation setReturnValue:&dataTask];
        
        successBlock(dataTask, [self contentDictionaryFromJSON:@"TaskListResponse"]);
    }] GET:OCMOCK_ANY parameters:OCMOCK_ANY progress:OCMOCK_ANY success:OCMOCK_ANY failure:OCMOCK_ANY];
    
    //when
    self.taskNetworkServices.requestOperationManager = self.requestOperationManagerMock;
    [self.taskNetworkServices fetchChecklistForTaskWithID:@"id"
                                          completionBlock:^(NSArray *taskList, NSError *error, ASDKModelPaging *paging) {
                                              XCTAssertNil(error);
                                              XCTAssertNotNil(taskList);
                                              XCTAssertNotNil(paging);
                                              
                                              [fetchChecklistExpectation fulfill];
                                          }];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItHandlesTaskChecklistFetchRequestFailure {
    // expect
    XCTestExpectation *fetchChecklistExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
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
    self.taskNetworkServices.requestOperationManager = self.requestOperationManagerMock;
    [self.taskNetworkServices fetchChecklistForTaskWithID:@"id"
                                          completionBlock:^(NSArray *taskList, NSError *error, ASDKModelPaging *paging) {
                                              XCTAssertNotNil(error);
                                              XCTAssertNil(taskList);
                                              XCTAssertNil(paging);
                                              
                                              [fetchChecklistExpectation fulfill];
                                          }];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItCreatesChecklistTask {
    // given
    id checklistRepresentation = OCMClassMock([ASDKTaskCreationRequestRepresentation class]);
    
    // expect
    XCTestExpectation *checklistTaskCreationExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [[[self.requestOperationManagerMock expect] andDo:^(NSInvocation *invocation) {
        ASDKTestRequestSuccessBlock successBlock;
        NSUInteger successBlockParameterIdxInMethodSignature = 5;
        [invocation getArgument:&successBlock
                        atIndex:successBlockParameterIdxInMethodSignature];
        NSURLSessionDataTask *dataTask = [self dataTaskWithStatusCode:ASDKHTTPCode200OK];
        [invocation setReturnValue:&dataTask];
        
        successBlock(dataTask, [self contentDictionaryFromJSON:@"TaskDetailsResponse"]);
    }] POST:OCMOCK_ANY parameters:OCMOCK_ANY progress:OCMOCK_ANY success:OCMOCK_ANY failure:OCMOCK_ANY];
    
    //when
    self.taskNetworkServices.requestOperationManager = self.requestOperationManagerMock;
    [self.taskNetworkServices createChecklistWithRepresentation:checklistRepresentation
                                                         taskID:@"id"
                                                completionBlock:^(ASDKModelTask *task, NSError *error) {
                                                    XCTAssertNil(error);
                                                    XCTAssertNotNil(task);
                                                    
                                                    [checklistTaskCreationExpectation fulfill];
                                                }];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItHandlesChecklistTaskCreationRequestFailure {
    // given
    id checklistRepresentation = OCMClassMock([ASDKTaskCreationRequestRepresentation class]);
    
    // expect
    XCTestExpectation *checklistTaskCreationExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [[[self.requestOperationManagerMock expect] andDo:^(NSInvocation *invocation) {
        ASDKTestRequestFailureBlock failureBlock;
        NSUInteger failureBlockParameterIdxInMethodSignature = 6;
        [invocation getArgument:&failureBlock
                        atIndex:failureBlockParameterIdxInMethodSignature];
        NSURLSessionDataTask *dataTask = [self dataTaskWithStatusCode:ASDKHTTPCode400BadRequest];
        [invocation setReturnValue:&dataTask];
        
        failureBlock(dataTask, [self requestGenericError]);
    }] POST:OCMOCK_ANY parameters:OCMOCK_ANY progress:OCMOCK_ANY success:OCMOCK_ANY failure:OCMOCK_ANY];
    
    //when
    self.taskNetworkServices.requestOperationManager = self.requestOperationManagerMock;
    [self.taskNetworkServices createChecklistWithRepresentation:checklistRepresentation
                                                         taskID:@"id"
                                                completionBlock:^(ASDKModelTask *task, NSError *error) {
                                                    XCTAssertNotNil(error);
                                                    XCTAssertNil(task);
                                                    
                                                    [checklistTaskCreationExpectation fulfill];
                                                }];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItUpdatesChecklistOrderWithRepresentation {
    // given
    id orderRepresentation = OCMClassMock([ASDKTaskChecklistOrderRequestRepresentation class]);
    
    // expect
    XCTestExpectation *checklistTaskOrderExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [[[self.requestOperationManagerMock expect] andDo:^(NSInvocation *invocation) {
        ASDKTestRequestSuccessBlock successBlock;
        NSUInteger successBlockParameterIdxInMethodSignature = 4;
        [invocation getArgument:&successBlock
                        atIndex:successBlockParameterIdxInMethodSignature];
        NSURLSessionDataTask *dataTask = [self dataTaskWithStatusCode:ASDKHTTPCode200OK];
        [invocation setReturnValue:&dataTask];
        
        successBlock(dataTask, nil);
    }] PUT:OCMOCK_ANY parameters:OCMOCK_ANY success:OCMOCK_ANY failure:OCMOCK_ANY];
    
    //when
    self.taskNetworkServices.requestOperationManager = self.requestOperationManagerMock;
    [self.taskNetworkServices updateChecklistOrderWithRepresentation:orderRepresentation
                                                              taskID:@"id"
                                                     completionBlock:^(BOOL isTaskUpdated, NSError *error) {
                                                         XCTAssertNil(error);
                                                         XCTAssertTrue(isTaskUpdated);
                                                         
                                                         [checklistTaskOrderExpectation fulfill];
                                                     }];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItHandlesChecklistOrderUpdateRequestFailure {
    // given
    id orderRepresentation = OCMClassMock([ASDKTaskChecklistOrderRequestRepresentation class]);
    
    // expect
    XCTestExpectation *checkListTaskOrderExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [[[self.requestOperationManagerMock expect] andDo:^(NSInvocation *invocation) {
        ASDKTestRequestFailureBlock failureBlock;
        NSUInteger failureBlockParameterIdxInMethodSignature = 5;
        [invocation getArgument:&failureBlock
                        atIndex:failureBlockParameterIdxInMethodSignature];
        NSURLSessionDataTask *dataTask = [self dataTaskWithStatusCode:ASDKHTTPCode400BadRequest];
        [invocation setReturnValue:&dataTask];
        
        failureBlock(dataTask, [self requestGenericError]);
    }] PUT:OCMOCK_ANY parameters:OCMOCK_ANY success:OCMOCK_ANY failure:OCMOCK_ANY];
    
    //when
    self.taskNetworkServices.requestOperationManager = self.requestOperationManagerMock;
    [self.taskNetworkServices updateChecklistOrderWithRepresentation:orderRepresentation
                                                              taskID:@"id"
                                                     completionBlock:^(BOOL isTaskUpdated, NSError *error) {
                                                         XCTAssertNotNil(error);
                                                         XCTAssertFalse(isTaskUpdated);
                                                         
                                                         [checkListTaskOrderExpectation fulfill];
                                                     }];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

@end

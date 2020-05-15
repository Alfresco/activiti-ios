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

@interface ASDKProcessInstanceNetworkServicesTest : ASDKNetworkProxyBaseTest

@property (strong, nonatomic) ASDKProcessInstanceNetworkServices *processInstanceNetworkServices;
@property (strong, nonatomic) id                                  requestOperationManagerMock;

@end

@implementation ASDKProcessInstanceNetworkServicesTest

- (void)setUp {
    [super setUp];
    
    self.processInstanceNetworkServices = [ASDKProcessInstanceNetworkServices new];
    self.processInstanceNetworkServices.resultsQueue = dispatch_get_main_queue();
    self.processInstanceNetworkServices.parserOperationManager = self.parserOperationManager;
    self.processInstanceNetworkServices.servicePathFactory = [ASDKServicePathFactory new];
    self.processInstanceNetworkServices.diskServices = [ASDKDiskServices new];
    self.requestOperationManagerMock = OCMClassMock([ASDKRequestOperationManager class]);
    
    ASDKProcessParserOperationWorker *processParserWorker = [ASDKProcessParserOperationWorker new];
    [self.processInstanceNetworkServices.parserOperationManager registerWorker:processParserWorker
                                                                   forServices:[processParserWorker availableServices]];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testThatItFetchesProcessInstanceListWithFilter {
    // given
    id filter = OCMClassMock([ASDKFilterRequestRepresentation class]);
    
    // expect
    XCTestExpectation *processInstanceListExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [[[self.requestOperationManagerMock expect] andDo:^(NSInvocation *invocation) {
        ASDKTestRequestSuccessBlock successBlock;
        NSUInteger successBlockParameterIdxInMethodSignature = 5;
        [invocation getArgument:&successBlock
                        atIndex:successBlockParameterIdxInMethodSignature];
        NSURLSessionDataTask *dataTask = [self dataTaskWithStatusCode:ASDKHTTPCode200OK];
        [invocation setReturnValue:&dataTask];
        
        successBlock(dataTask, [self contentDictionaryFromJSON:@"ProcessInstanceListResponse"]);
    }] POST:OCMOCK_ANY parameters:OCMOCK_ANY progress:OCMOCK_ANY success:OCMOCK_ANY failure:OCMOCK_ANY];
    
    // when
    self.processInstanceNetworkServices.requestOperationManager = self.requestOperationManagerMock;
    [self.processInstanceNetworkServices fetchProcessInstanceListWithFilterRepresentation:filter
                                                                          completionBlock:^(NSArray *processes, NSError *error, ASDKModelPaging *paging) {
                                                                              XCTAssertNotNil(processes);
                                                                              XCTAssertNil(error);
                                                                              XCTAssertNotNil(paging);
                                                                              
                                                                              XCTAssert(processes.count == 2);
                                                                              
                                                                              [processInstanceListExpectation fulfill];
                                                                          }];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItHandlesProcessInstanceListWithFilterFetchRequestFailure {
    // given
    id filter = OCMClassMock([ASDKFilterRequestRepresentation class]);
    
    // expect
    XCTestExpectation *processInstanceListExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
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
    self.processInstanceNetworkServices.requestOperationManager = self.requestOperationManagerMock;
    [self.processInstanceNetworkServices fetchProcessInstanceListWithFilterRepresentation:filter
                                                                          completionBlock:^(NSArray *processes, NSError *error, ASDKModelPaging *paging) {
                                                                              XCTAssertNil(processes);
                                                                              XCTAssertNotNil(error);
                                                                              XCTAssertNil(paging);
                                                                              
                                                                              [processInstanceListExpectation fulfill];
                                                                          }];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItStartsProcessInstance {
    // given
    id request = OCMClassMock([ASDKStartProcessRequestRepresentation class]);
    
    // expect
    XCTestExpectation *startProcessInstanceExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
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
    self.processInstanceNetworkServices.requestOperationManager = self.requestOperationManagerMock;
    [self.processInstanceNetworkServices startProcessInstanceWithStartProcessRequestRepresentation:request
                                                                                   completionBlock:^(ASDKModelProcessInstance *processInstance, NSError *error) {
                                                                                       XCTAssertNotNil(processInstance);
                                                                                       XCTAssertNil(error);
                                                                                       
                                                                                       [startProcessInstanceExpectation fulfill];
                                                                                   }];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItHandlesStartProcessInstanceRequestFailure {
    // given
    id request = OCMClassMock([ASDKStartProcessRequestRepresentation class]);
    
    // expect
    XCTestExpectation *startProcessInstanceExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
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
    self.processInstanceNetworkServices.requestOperationManager = self.requestOperationManagerMock;
    [self.processInstanceNetworkServices startProcessInstanceWithStartProcessRequestRepresentation:request
                                                                                   completionBlock:^(ASDKModelProcessInstance *processInstance, NSError *error) {
                                                                                       XCTAssertNil(processInstance);
                                                                                       XCTAssertNotNil(error);
                                                                                       
                                                                                       [startProcessInstanceExpectation fulfill];
                                                                                   }];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItFetchesProcessInstanceDetails {
    // expect
    XCTestExpectation *processInstanceDetailsExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [[[self.requestOperationManagerMock expect] andDo:^(NSInvocation *invocation) {
        ASDKTestRequestSuccessBlock successBlock;
        NSUInteger successBlockParameterIdxInMethodSignature = 5;
        [invocation getArgument:&successBlock
                        atIndex:successBlockParameterIdxInMethodSignature];
        NSURLSessionDataTask *dataTask = [self dataTaskWithStatusCode:ASDKHTTPCode200OK];
        [invocation setReturnValue:&dataTask];
        
        successBlock(dataTask, [self contentDictionaryFromJSON:@"ProcessInstanceDetailsResponse"]);
    }] GET:OCMOCK_ANY parameters:OCMOCK_ANY progress:OCMOCK_ANY success:OCMOCK_ANY failure:OCMOCK_ANY];
    
    // when
    self.processInstanceNetworkServices.requestOperationManager = self.requestOperationManagerMock;
    [self.processInstanceNetworkServices fetchProcessInstanceDetailsForID:@"id"
                                                          completionBlock:^(ASDKModelProcessInstance *processInstance, NSError *error) {
                                                              XCTAssertNotNil(processInstance);
                                                              XCTAssertNil(error);
                                                              
                                                              [processInstanceDetailsExpectation fulfill];
                                                          }];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItHandlesProcessInstanceDetailsFetchRequestFailure {
    // expect
    XCTestExpectation *processInstanceDetailsExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
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
    self.processInstanceNetworkServices.requestOperationManager = self.requestOperationManagerMock;
    [self.processInstanceNetworkServices fetchProcessInstanceDetailsForID:@"id"
                                                          completionBlock:^(ASDKModelProcessInstance *processInstance, NSError *error) {
                                                              XCTAssertNil(processInstance);
                                                              XCTAssertNotNil(error);
                                                              
                                                              [processInstanceDetailsExpectation fulfill];
                                                          }];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItFetchesProcessInstanceContent {
    // expect
    XCTestExpectation *processInstanceContentExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [[[self.requestOperationManagerMock expect] andDo:^(NSInvocation *invocation) {
        ASDKTestRequestSuccessBlock successBlock;
        NSUInteger successBlockParameterIdxInMethodSignature = 5;
        [invocation getArgument:&successBlock
                        atIndex:successBlockParameterIdxInMethodSignature];
        NSURLSessionDataTask *dataTask = [self dataTaskWithStatusCode:ASDKHTTPCode200OK];
        [invocation setReturnValue:&dataTask];
        
        successBlock(dataTask, [self contentDictionaryFromJSON:@"ProcessInstanceContentListResponse"]);
    }] GET:OCMOCK_ANY parameters:OCMOCK_ANY progress:OCMOCK_ANY success:OCMOCK_ANY failure:OCMOCK_ANY];
    
    // when
    self.processInstanceNetworkServices.requestOperationManager = self.requestOperationManagerMock;
    [self.processInstanceNetworkServices fetchProcesInstanceContentForProcessInstanceID:@"id"
                                                                        completionBlock:^(NSArray *contentList, NSError *error) {
                                                                            XCTAssertNotNil(contentList);
                                                                            XCTAssertNil(error);
                                                                            
                                                                            [processInstanceContentExpectation fulfill];
                                                                        }];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItHandlesProcessInstanceContentFetchRequestFailure {
    // expect
    XCTestExpectation *processInstanceContentExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
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
    self.processInstanceNetworkServices.requestOperationManager = self.requestOperationManagerMock;
    [self.processInstanceNetworkServices fetchProcesInstanceContentForProcessInstanceID:@"id"
                                                                        completionBlock:^(NSArray *contentList, NSError *error) {
                                                                            XCTAssertNil(contentList);
                                                                            XCTAssertNotNil(error);
                                                                            
                                                                            [processInstanceContentExpectation fulfill];
                                                                        }];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItFetchesProcessInstanceComments {
    // expect
    XCTestExpectation *processInstanceCommentsExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [[[self.requestOperationManagerMock expect] andDo:^(NSInvocation *invocation) {
        ASDKTestRequestSuccessBlock successBlock;
        NSUInteger successBlockParameterIdxInMethodSignature = 5;
        [invocation getArgument:&successBlock
                        atIndex:successBlockParameterIdxInMethodSignature];
        NSURLSessionDataTask *dataTask = [self dataTaskWithStatusCode:ASDKHTTPCode200OK];
        [invocation setReturnValue:&dataTask];
        
        successBlock(dataTask, [self contentDictionaryFromJSON:@"CommentListResponse"]);
    }] GET:OCMOCK_ANY parameters:OCMOCK_ANY progress:OCMOCK_ANY success:OCMOCK_ANY failure:OCMOCK_ANY];
    
    // when
    self.processInstanceNetworkServices.requestOperationManager = self.requestOperationManagerMock;
    [self.processInstanceNetworkServices fetchProcessInstanceCommentsForProcessInstanceID:@"id"
                                                                          completionBlock:^(NSArray *commentList, NSError *error, ASDKModelPaging *paging) {
                                                                              XCTAssertNotNil(commentList);
                                                                              XCTAssertNil(error);
                                                                              XCTAssertNotNil(paging);
                                                                              
                                                                              XCTAssert(commentList.count == 1);
                                                                              
                                                                              [processInstanceCommentsExpectation fulfill];
                                                                          }];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItHandlesProcessInstanceCommentsFetchRequestFailure {
    // expect
    XCTestExpectation *processInstanceCommentsExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
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
    self.processInstanceNetworkServices.requestOperationManager = self.requestOperationManagerMock;
    [self.processInstanceNetworkServices fetchProcessInstanceCommentsForProcessInstanceID:@"id"
                                                                          completionBlock:^(NSArray *commentList, NSError *error, ASDKModelPaging *paging) {
                                                                              XCTAssertNil(commentList);
                                                                              XCTAssertNotNil(error);
                                                                              XCTAssertNil(paging);
                                                                              
                                                                              [processInstanceCommentsExpectation fulfill];
                                                                          }];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItCreatesCommentForProcessInstance {
    // expect
    XCTestExpectation *processInstanceCommentCreateExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [[[self.requestOperationManagerMock expect] andDo:^(NSInvocation *invocation) {
        ASDKTestRequestSuccessBlock successBlock;
        NSUInteger successBlockParameterIdxInMethodSignature = 5;
        [invocation getArgument:&successBlock
                        atIndex:successBlockParameterIdxInMethodSignature];
        NSURLSessionDataTask *dataTask = [self dataTaskWithStatusCode:ASDKHTTPCode200OK];
        [invocation setReturnValue:&dataTask];
        
        successBlock(dataTask, [self contentDictionaryFromJSON:@"CommentDetailsResponse"]);
    }] POST:OCMOCK_ANY parameters:OCMOCK_ANY progress:OCMOCK_ANY success:OCMOCK_ANY failure:OCMOCK_ANY];
    
    // when
    self.processInstanceNetworkServices.requestOperationManager = self.requestOperationManagerMock;
    [self.processInstanceNetworkServices createComment:@"test"
                                  forProcessInstanceID:@"id"
                                       completionBlock:^(ASDKModelComment *comment, NSError *error) {
                                           XCTAssertNotNil(comment);
                                           XCTAssertNil(error);
                                           
                                           [processInstanceCommentCreateExpectation fulfill];
                                       }];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItHandlesCreateCommentForProcessInstanceRequestFailure {
    // expect
    XCTestExpectation *processInstanceCommentCreateExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
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
    self.processInstanceNetworkServices.requestOperationManager = self.requestOperationManagerMock;
    [self.processInstanceNetworkServices createComment:@"test"
                                  forProcessInstanceID:@"id"
                                       completionBlock:^(ASDKModelComment *comment, NSError *error) {
                                           XCTAssertNil(comment);
                                           XCTAssertNotNil(error);
                                           
                                           [processInstanceCommentCreateExpectation fulfill];
                                       }];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItDeletesProcessInstance {
    // expect
    XCTestExpectation *processInstanceDeleteExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [[[self.requestOperationManagerMock expect] andDo:^(NSInvocation *invocation) {
        ASDKTestRequestSuccessBlock successBlock;
        NSUInteger successBlockParameterIdxInMethodSignature = 4;
        [invocation getArgument:&successBlock
                        atIndex:successBlockParameterIdxInMethodSignature];
        NSURLSessionDataTask *dataTask = [self dataTaskWithStatusCode:ASDKHTTPCode200OK];
        [invocation setReturnValue:&dataTask];
        
        successBlock(dataTask, nil);
    }] DELETE:OCMOCK_ANY parameters:OCMOCK_ANY success:OCMOCK_ANY failure:OCMOCK_ANY];
    
    // when
    self.processInstanceNetworkServices.requestOperationManager = self.requestOperationManagerMock;
    [self.processInstanceNetworkServices deleteProcessInstanceWithID:@"id"
                                                     completionBlock:^(BOOL isProcessInstanceDeleted, NSError *error) {
                                                         XCTAssertTrue(isProcessInstanceDeleted);
                                                         XCTAssertNil(error);
                                                         
                                                         [processInstanceDeleteExpectation fulfill];
                                                     }];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItHandlesProcessInstanceDeletion {
    // expect
    XCTestExpectation *processInstanceDeleteExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [[[self.requestOperationManagerMock expect] andDo:^(NSInvocation *invocation) {
        ASDKTestRequestFailureBlock failureBlock;
        NSUInteger failureBlockParameterIdxInMethodSignature = 5;
        [invocation getArgument:&failureBlock
                        atIndex:failureBlockParameterIdxInMethodSignature];
        NSURLSessionDataTask *dataTask = [self dataTaskWithStatusCode:ASDKHTTPCode400BadRequest];
        [invocation setReturnValue:&dataTask];
        
        failureBlock(dataTask, [self requestGenericError]);
    }] DELETE:OCMOCK_ANY parameters:OCMOCK_ANY success:OCMOCK_ANY failure:OCMOCK_ANY];
    
    // when
    self.processInstanceNetworkServices.requestOperationManager = self.requestOperationManagerMock;
    [self.processInstanceNetworkServices deleteProcessInstanceWithID:@"id"
                                                     completionBlock:^(BOOL isProcessInstanceDeleted, NSError *error) {
                                                         XCTAssertFalse(isProcessInstanceDeleted);
                                                         XCTAssertNotNil(error);
                                                         
                                                         [processInstanceDeleteExpectation fulfill];
                                                     }];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItDownloadsAuditLogForProcessInstanceAndReturnsCachedResults {
    // given
    id diskServices = OCMPartialMock(self.processInstanceNetworkServices.diskServices);
    
    // expect
    XCTestExpectation *downloadAuditLogExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    OCMStub([diskServices doesFileAlreadyExistsForResouceWithIdentifier:OCMOCK_ANY filename:OCMOCK_ANY]).andReturn(YES);
    
    // when
    self.processInstanceNetworkServices.diskServices = diskServices;
    [self.processInstanceNetworkServices downloadAuditLogForProcessInstanceWithID:@"id"
                                                               allowCachedResults:YES
                                                                    progressBlock:nil
                                                                  completionBlock:^(NSURL *downloadedContentURL, BOOL isLocalContent, NSError *error) {
                                                                      XCTAssertNotNil(downloadedContentURL);
                                                                      XCTAssertTrue(isLocalContent);
                                                                      XCTAssertNil(error);
                                                                      
                                                                      [downloadAuditLogExpectation fulfill];
                                                                  }];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItDownloadsAuditLogForProcessInstanceAndReportsProgress {
    // expect
    XCTestExpectation *downloadAuditLogExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    XCTestExpectation *downloadAuditLogProgressExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    
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
    self.processInstanceNetworkServices.requestOperationManager = self.requestOperationManagerMock;
    [self.processInstanceNetworkServices downloadAuditLogForProcessInstanceWithID:@"id"
                                                               allowCachedResults:NO
                                                                    progressBlock:^(NSString *formattedReceivedBytesString, NSError *error) {
                                                                        XCTAssert([formattedReceivedBytesString isEqualToString:@"200.00 bytes"]);
                                                                        XCTAssertNil(error);
                                                                        
                                                                        [downloadAuditLogProgressExpectation fulfill];
                                                                    }
                                                                  completionBlock:^(NSURL *downloadedContentURL, BOOL isLocalContent, NSError *error) {
                                                                      XCTAssertNotNil(downloadedContentURL);
                                                                      XCTAssertFalse(isLocalContent);
                                                                      XCTAssertNil(error);
                                                                      
                                                                      [downloadAuditLogExpectation fulfill];
                                                                  }];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItHandlesAuditLogDownloadForProcessInstanceRequestFailure {
    // expect
    XCTestExpectation *downloadAuditLogExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
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
    self.processInstanceNetworkServices.requestOperationManager = self.requestOperationManagerMock;
    [self.processInstanceNetworkServices downloadAuditLogForProcessInstanceWithID:@"id"
                                                               allowCachedResults:NO
                                                                    progressBlock:nil
                                                                  completionBlock:^(NSURL *downloadedContentURL, BOOL isLocalContent, NSError *error) {
                                                                      XCTAssertNil(downloadedContentURL);
                                                                      XCTAssertFalse(isLocalContent);
                                                                      XCTAssertNotNil(error);
                                                                      
                                                                      [downloadAuditLogExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

@end

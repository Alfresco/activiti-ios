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

#import "ASDKBaseTest.h"

@interface ASDKUserParserOperationWorkerTest : ASDKBaseTest

@property (strong, nonatomic) ASDKUserParserOperationWorker *userParserWorker;

@end

@implementation ASDKUserParserOperationWorkerTest

- (void)setUp {
    [super setUp];
    
    self.userParserWorker = [ASDKUserParserOperationWorker new];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testThatItReturnsAvailableServices {
    NSArray *availableService = @[CREATE_STRING(ASDKUserParserContentTypeUserList)];
    XCTAssert([[self.userParserWorker availableServices] isEqualToArray:availableService]);
}

- (void)testThatItParsesUserList {
    // given
    NSError *error = nil;
    
    NSString *filePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"UserListResponse" ofType:@"json"];
    NSData *jsonData = [[NSData alloc] initWithContentsOfFile:filePath];
    NSDictionary *response = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:jsonData
                                                                             options:NSJSONReadingMutableContainers
                                                                               error:&error];
    XCTAssertNil(error);
    
    XCTestExpectation *expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    
    // when
    [self.userParserWorker parseContentDictionary:response
                                           ofType:CREATE_STRING(ASDKUserParserContentTypeUserList)
                              withCompletionBlock:^(id parsedObject, NSError *error, ASDKModelPaging *paging) {
                                  XCTAssertNil(error);
                                  XCTAssertNotNil(paging);
                                  XCTAssert([parsedObject isKindOfClass:[NSArray class]]);
                                  XCTAssert([(NSArray *)parsedObject count] == 2);
                                  
                                  XCTAssert(paging.total == 2);
                                  XCTAssert(paging.size == 2);
                                  XCTAssert(!paging.start);
                                  
                                  ASDKModelUser *user = [(NSArray *)parsedObject firstObject];
                                  XCTAssert([user.userFirstName isEqualToString:@"T1"]);
                                  XCTAssert([user.userLastName isEqualToString:@"U1"]);
                                  XCTAssert([user.email isEqualToString:@"t1u1@alfresco.com"]);
                                  XCTAssert([user.pictureID isEqualToString:@"4008"]);
                                  XCTAssert([user.companyName isEqualToString:@"Alfresco"]);
                                  
                                  [expectation fulfill];
                              } queue:dispatch_get_main_queue()];
    
    // then
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItHandlesInvalidJSONData {
    // expect
    XCTestExpectation *expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    
    // when
    NSDictionary *invalidContentDictionary = @{@"foo" : @"bar"};
    [self.userParserWorker parseContentDictionary:invalidContentDictionary
                                           ofType:CREATE_STRING(ASDKUserParserContentTypeUserList)
                              withCompletionBlock:^(id parsedObject, NSError *error, ASDKModelPaging *paging) {
                                  XCTAssertNotNil(error);
                                  XCTAssertNil(parsedObject);
                                  XCTAssertNil(paging);
                                  
                                  [expectation fulfill];
                              }
                                            queue:dispatch_get_main_queue()];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

@end

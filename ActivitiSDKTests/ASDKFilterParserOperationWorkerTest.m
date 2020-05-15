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

@interface ASDKFilterParserOperationWorkerTest : ASDKBaseTest

@property (strong, nonatomic) ASDKFilterParserOperationWorker *filterParserWorker;

@end

@implementation ASDKFilterParserOperationWorkerTest

- (void)setUp {
    [super setUp];
    self.filterParserWorker = [ASDKFilterParserOperationWorker new];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testThatItReturnsAvailableServices {
    NSArray *availableServices = @[CREATE_STRING(ASDKFilterParserContentTypeFilterList),
                                   CREATE_STRING(ASDKFilterParserContentTypeFilterDetails)];
    XCTAssert([[self.filterParserWorker availableServices] isEqualToArray:availableServices]);
}

- (void)testThatItParsesFilterList {
    // given
    NSError *error = nil;
    
    NSString *filePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"FilterListResponse" ofType:@"json"];
    NSData *jsonData = [[NSData alloc] initWithContentsOfFile:filePath];
    NSDictionary *response = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:jsonData
                                                                             options:NSJSONReadingMutableContainers
                                                                               error:&error];
    XCTAssertNil(error);
    
    XCTestExpectation *expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    
    // when
    [self.filterParserWorker parseContentDictionary:response
                                             ofType:CREATE_STRING(ASDKFilterParserContentTypeFilterList)
                                withCompletionBlock:^(id parsedObject, NSError *error, ASDKModelPaging *paging) {
                                    XCTAssertNil(error);
                                    XCTAssertNotNil(paging);
                                    XCTAssert([parsedObject isKindOfClass:[NSArray class]]);
                                    XCTAssert([(NSArray *)parsedObject count] == 4);
                                    
                                    XCTAssert(paging.total == 4);
                                    XCTAssert(paging.size == 4);
                                    XCTAssert(!paging.start);
                                    
                                    ASDKModelFilter *filterModel = [(NSArray *)parsedObject firstObject];
                                    XCTAssert([filterModel.applicationID isEqualToString:@"3"]);
                                    XCTAssert([filterModel.modelID isEqualToString:@"33"]);
                                    XCTAssert([filterModel.name isEqualToString:@"Involved Tasks"]);
                                    XCTAssert(filterModel.assignmentType == ASDKModelFilterAssignmentTypeInvolved);
                                    XCTAssert(filterModel.state == ASDKModelFilterStateTypeActive);
                                    XCTAssert(filterModel.sortType == ASDKModelFilterSortTypeCreatedDesc);
                                    
                                    [expectation fulfill];
                                } queue:dispatch_get_main_queue()];
    
    // then
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItParsesFilterCreationDetails {
    // given
    NSError *error = nil;
    
    NSString *filePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"FilterDetailsResponse" ofType:@"json"];
    NSData *jsonData = [[NSData alloc] initWithContentsOfFile:filePath];
    NSDictionary *response = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:jsonData
                                                                             options:NSJSONReadingMutableContainers
                                                                               error:&error];
    XCTAssertNil(error);
    
    XCTestExpectation *expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    
    // when
    [self.filterParserWorker parseContentDictionary:response
                                             ofType:CREATE_STRING(ASDKFilterParserContentTypeFilterDetails)
                                withCompletionBlock:^(id parsedObject, NSError *error, ASDKModelPaging *paging) {
                                    XCTAssertNil(error);
                                    XCTAssertNil(paging);
                                    XCTAssert([parsedObject isKindOfClass:[ASDKModelFilter class]]);
                                    
                                    ASDKModelFilter *filter = (ASDKModelFilter *)parsedObject;
                                    XCTAssert([filter.applicationID isEqualToString:@"12013"]);
                                    XCTAssert([filter.modelID isEqualToString:@"12013"]);
                                    XCTAssert([filter.name isEqualToString:@"Completed tasks"]);
                                    
                                    [expectation fulfill];
                                } queue:dispatch_get_main_queue()];
    
    // then
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItHandlesInvalidJSON {
    // expect
    XCTestExpectation *filterListExpectation = [self expectationWithDescription:[NSString stringWithFormat:@"%@.filterList", NSStringFromSelector(_cmd)]];
    XCTestExpectation *filterCreationExpectation = [self expectationWithDescription:[NSString stringWithFormat:@"%@.filterCreation", NSStringFromSelector(_cmd)]];
    
    // when
    NSDictionary *invalidContentDictionary = @{@"foo":@"bar"};
    [self.filterParserWorker parseContentDictionary:invalidContentDictionary
                                             ofType:CREATE_STRING(ASDKFilterParserContentTypeFilterList)
                                withCompletionBlock:^(id parsedObject, NSError *error, ASDKModelPaging *paging) {
                                    XCTAssertNotNil(error);
                                    XCTAssertNil(parsedObject);
                                    XCTAssertNil(paging);
                                    
                                    [filterListExpectation fulfill];
                                } queue:dispatch_get_main_queue()];
    [self.filterParserWorker parseContentDictionary:invalidContentDictionary
                                             ofType:CREATE_STRING(ASDKFilterParserContentTypeFilterDetails)
                                withCompletionBlock:^(id parsedObject, NSError *error, ASDKModelPaging *paging) {
                                    XCTAssertNotNil(error);
                                    XCTAssertNil(parsedObject);
                                    XCTAssertNil(paging);
                                    
                                    [filterCreationExpectation fulfill];
                                } queue:dispatch_get_main_queue()];
    
    [self waitForExpectationsWithTimeout:.5
                                 handler:nil];
}

@end

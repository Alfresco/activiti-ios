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

@interface ASDKAppParserOperationWorkerTest : ASDKBaseTest

@property (strong, nonatomic) ASDKAppParserOperationWorker *appParserWorker;

@end

@implementation ASDKAppParserOperationWorkerTest

- (void)setUp {
    [super setUp];
    
    self.appParserWorker = [ASDKAppParserOperationWorker new];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testThatItReturnsAvailableServices {
    NSArray *availableServices = @[CREATE_STRING(ASDKAppParserContentTypeRuntimeAppDefinitionsList)];
    XCTAssert([[self.appParserWorker availableServices] isEqualToArray:availableServices]);
}

- (void)testThatItParsesApplicationList {
    // given
    NSError *error = nil;
    
    NSString *filePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"ApplicationListResponse" ofType:@"json"];
    NSData *jsonData = [[NSData alloc] initWithContentsOfFile:filePath];
    NSDictionary *response = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:jsonData
                                                                             options:NSJSONReadingMutableContainers
                                                                               error:&error];
    XCTAssertNil(error);
    
    XCTestExpectation *expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    
    // when
    [self.appParserWorker parseContentDictionary:response
                                          ofType:CREATE_STRING(ASDKAppParserContentTypeRuntimeAppDefinitionsList)
                             withCompletionBlock:^(id parsedObject, NSError *error, ASDKModelPaging *paging) {
                                 XCTAssertNil(error);
                                 XCTAssertNotNil(paging);
                                 XCTAssert([parsedObject isKindOfClass:[NSArray class]]);
                                 XCTAssert([(NSArray *)parsedObject count] == 13);
                                 
                                 XCTAssert(paging.total == 13);
                                 XCTAssert(paging.size == 13);
                                 XCTAssert(!paging.start);
                                 
                                 ASDKModelApp *application =  (ASDKModelApp *)[(NSArray *)parsedObject objectAtIndex:4];
                                 XCTAssert([application.modelID isEqualToString:@"3"]);
                                 XCTAssert([application.icon isEqualToString:@"glyphicon-eye-open"]);
                                 XCTAssert([application.deploymentID isEqualToString:@"37727"]);
                                 XCTAssert([application.applicationModelID isEqualToString:@"37"]);
                                 XCTAssert([application.tenantID isEqualToString:@"1"]);
                                 XCTAssert(application.theme = ASDKModelAppThemeTypeFour);
                                 XCTAssertNil(application.applicationDescription);
                                 XCTAssert([application.name isEqualToString:@"Visibility conditions"]);
                                 
                                 [expectation fulfill];
                             } queue:dispatch_get_main_queue()];
    
    // then
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItHandlesInvalidJSONData {
    // expect
    XCTestExpectation *applicationListExpectation = [self expectationWithDescription:[NSString stringWithFormat:@"%@.applicationList", NSStringFromSelector(_cmd)]];
    
    // when
    NSDictionary *invalidContentDictionary = @{@"foo":@"bar"};
    [self.appParserWorker parseContentDictionary:invalidContentDictionary
                                          ofType:CREATE_STRING(ASDKAppParserContentTypeRuntimeAppDefinitionsList)
                             withCompletionBlock:^(id parsedObject, NSError *error, ASDKModelPaging *paging) {
                                 XCTAssertNotNil(error);
                                 XCTAssertNil(parsedObject);
                                 XCTAssertNil(paging);
                                 
                                 [applicationListExpectation fulfill];
                             } queue:dispatch_get_main_queue()];
    
    [self waitForExpectationsWithTimeout:.5
                                 handler:nil];
}

@end

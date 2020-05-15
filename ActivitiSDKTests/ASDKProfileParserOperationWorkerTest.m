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

@interface ASDKProfileParserOperationWorkerTest : ASDKBaseTest

@property (strong, nonatomic) ASDKProfileParserOperationWorker *profileParserWorker;

@end

@implementation ASDKProfileParserOperationWorkerTest

- (void)setUp {
    [super setUp];
    
    self.profileParserWorker = [ASDKProfileParserOperationWorker new];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testThatItReturnsAvailableServices {
    NSArray *availableService = @[CREATE_STRING(ASDKProfileParserContentTypeProfile),
                                  CREATE_STRING(ASDKProfileParserContentTypeContent)];
    XCTAssert([[self.profileParserWorker availableServices] isEqualToArray:availableService]);
}

- (void)testThatItParsesProfile {
    // given
    NSError *error = nil;
    
    NSString *filePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"ProfileDetailsResponse" ofType:@"json"];
    NSData *jsonData = [[NSData alloc] initWithContentsOfFile:filePath];
    NSDictionary *response = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:jsonData
                                                                             options:NSJSONReadingMutableContainers
                                                                               error:&error];
    XCTAssertNil(error);
    
    XCTestExpectation *expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    
    // when
    [self.profileParserWorker parseContentDictionary:response
                                              ofType:CREATE_STRING(ASDKProfileParserContentTypeProfile)
                                 withCompletionBlock:^(id parsedObject, NSError *error, ASDKModelPaging *paging) {
                                     XCTAssertNil(error);
                                     XCTAssertNil(paging);
                                     XCTAssert([parsedObject isKindOfClass:[ASDKModelProfile class]]);
                                     
                                     ASDKModelProfile *profile = (ASDKModelProfile *)parsedObject;
                                     XCTAssert([profile.tenantName isEqualToString:@"tenant1"]);
                                     XCTAssert(profile.profileState == ASDKModelProfileStateActive);
                                     XCTAssert([profile.companyName isEqualToString:@"Alfresco"]);
                                     XCTAssertNil(profile.tenantPictureID);
                                     XCTAssert([profile.modelID isEqualToString:@"2"]);
                                     XCTAssert([profile.pictureID isEqualToString:@"6006"]);
                                     XCTAssert([profile.tenantID isEqualToString:@"1"]);
                                     XCTAssert([profile.email isEqualToString:@"john.doe@alfresco.com"]);
                                     XCTAssert([profile.userFirstName isEqualToString:@"John"]);
                                     XCTAssertNil(profile.externalID);
                                     XCTAssert([profile.userLastName isEqualToString:@"Doe"]);
                                     NSDate *jsonCreatedDate = [[ASDKModelBase standardDateFormatter] dateFromString:@"2016-08-09T08:44:47.171+0000"];
                                     NSDate *jsonLastUpdateDate = [[ASDKModelBase standardDateFormatter] dateFromString:@"2016-11-08T13:31:12.702+0000"];
                                     XCTAssert(NSOrderedSame == [profile.creationDate compare:jsonCreatedDate]);
                                     XCTAssert(NSOrderedSame == [profile.lastUpdate compare:jsonLastUpdateDate]);
                                     
                                     XCTAssert(profile.groups.count == 4);
                                     ASDKModelGroup *group = (ASDKModelGroup *)profile.groups[1];
                                     XCTAssert([group.modelID isEqualToString:@"4"]);
                                     XCTAssertNil(group.externalID);
                                     XCTAssertNil(group.parentGroupID);
                                     XCTAssert([group.tenantID isEqualToString:@"1"]);
                                     XCTAssert(group.type == ASDKModelGroupTypeSystem);
                                     XCTAssertNil(group.subGroups);
                                     XCTAssert([group.name isEqualToString:@"analytics-users"]);
                                     XCTAssert(group.groupState == ASDKModelGroupStateActive);
                                     
                                     [expectation fulfill];
                                 } queue:dispatch_get_main_queue()];
    
    // then
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItParsesProfileContent {
    // given
    NSError *error = nil;
    
    NSString *filePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"ProfileContentResponse" ofType:@"json"];
    NSData *jsonData = [[NSData alloc] initWithContentsOfFile:filePath];
    NSDictionary *response = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:jsonData
                                                                             options:NSJSONReadingMutableContainers
                                                                               error:&error];
    XCTAssertNil(error);
    
    XCTestExpectation *expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    
    // when
    [self.profileParserWorker parseContentDictionary:response
                                              ofType:CREATE_STRING(ASDKProfileParserContentTypeContent)
                                 withCompletionBlock:^(id parsedObject, NSError *error, ASDKModelPaging *paging) {
                                     XCTAssertNil(error);
                                     XCTAssertNil(paging);
                                     XCTAssert([parsedObject isKindOfClass:[ASDKModelContent class]]);
                                     
                                     ASDKModelContent *content = (ASDKModelContent *)parsedObject;
                                     XCTAssert([content.modelID isEqualToString:@"7007"]);
                                     XCTAssert([content.contentName isEqualToString:@"IMG_0001.JPG"]);
                                     NSDate *jsonCreatedDate = [[ASDKModelBase standardDateFormatter] dateFromString:@"2016-11-11T13:47:09.088+0000"];
                                     XCTAssert(NSOrderedSame == [content.creationDate compare:jsonCreatedDate]);
                                     
                                     [expectation fulfill];
                                 } queue:dispatch_get_main_queue()];
    
    // then
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItHandlesInvalidJSONData {
    // expect
    XCTestExpectation *profileExpectation = [self expectationWithDescription:[NSString stringWithFormat:@"%@.profile", NSStringFromSelector(_cmd)]];
    XCTestExpectation *profileContentExpectation = [self expectationWithDescription:[NSString stringWithFormat:@"%@.profileContent", NSStringFromSelector(_cmd)]];
    
    // when
    NSDictionary *invalidContentDictionary = @{@"foo":@"bar"};
    [self.profileParserWorker parseContentDictionary:invalidContentDictionary
                                              ofType:CREATE_STRING(ASDKProfileParserContentTypeProfile)
                                 withCompletionBlock:^(id parsedObject, NSError *error, ASDKModelPaging *paging) {
                                     XCTAssertNotNil(error);
                                     XCTAssertNil(parsedObject);
                                     XCTAssertNil(paging);
                                     [profileExpectation fulfill];
                                 } queue:dispatch_get_main_queue()];
    [self.profileParserWorker parseContentDictionary:invalidContentDictionary
                                              ofType:CREATE_STRING(ASDKProfileParserContentTypeContent)
                                 withCompletionBlock:^(id parsedObject, NSError *error, ASDKModelPaging *paging) {
                                     XCTAssertNotNil(error);
                                     XCTAssertNil(parsedObject);
                                     XCTAssertNil(paging);
                                     [profileContentExpectation fulfill];
                                 } queue:dispatch_get_main_queue()];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

@end

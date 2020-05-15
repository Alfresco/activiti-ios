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

@interface ASDKProcessParserOperationWorkerTest : ASDKBaseTest

@property (strong, nonatomic) ASDKProcessParserOperationWorker *processParserWorker;

@end

@implementation ASDKProcessParserOperationWorkerTest

- (void)setUp {
    [super setUp];
    
    self.processParserWorker = [ASDKProcessParserOperationWorker new];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testThatItReturnsAvailableServices {
    NSArray *availableServices = @[CREATE_STRING(ASDKProcessParserContentTypeProcessDefinitionList),
                                   CREATE_STRING(ASDKProcessParserContentTypeProcessInstanceList),
                                   CREATE_STRING(ASDKProcessParserContentTypeStartProcessInstance),
                                   CREATE_STRING(ASDKProcessParserContentTypeProcessInstanceDetails),
                                   CREATE_STRING(ASDKProcessParserContentTypeProcessInstanceContent),
                                   CREATE_STRING(ASDKProcessParserContentTypeProcessInstanceComments),
                                   CREATE_STRING(ASDKProcessParserContentTypeProcessInstanceComment)];
    
    XCTAssert([[self.processParserWorker availableServices] isEqualToArray:availableServices]);
}

- (void)testThatItParsesProcessDefinitionList {
    // given
    NSError *error = nil;
    
    NSString *filePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"ProcessDefinitionListResponse" ofType:@"json"];
    NSData *jsonData = [[NSData alloc] initWithContentsOfFile:filePath];
    NSDictionary *response = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:jsonData
                                                                             options:NSJSONReadingMutableContainers
                                                                               error:&error];
    XCTAssertNil(error);
    
    XCTestExpectation *expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    
    // when
    [self.processParserWorker parseContentDictionary:response
                                              ofType:CREATE_STRING(ASDKProcessParserContentTypeProcessDefinitionList)
                                 withCompletionBlock:^(id parsedObject, NSError *error, ASDKModelPaging *paging) {
                                     XCTAssertNil(error);
                                     XCTAssertNotNil(paging);
                                     XCTAssert([parsedObject isKindOfClass:[NSArray class]]);
                                     XCTAssert([(NSArray *)parsedObject count] == 1);
                                     
                                     XCTAssert(paging.total == 1);
                                     XCTAssert(paging.size == 1);
                                     XCTAssert(!paging.start);
                                     
                                     ASDKModelProcessDefinition *processDefinition = [(NSArray *)parsedObject firstObject];
                                     XCTAssert([processDefinition.name isEqualToString:@"VisiblityConditionsProcess"]);
                                     XCTAssert([processDefinition.category isEqualToString:@"http://www.activiti.org/processdef"]);
                                     XCTAssert([processDefinition.deploymentID isEqualToString:@"37727"]);
                                     XCTAssertFalse(processDefinition.hasStartForm);
                                     XCTAssert([processDefinition.key isEqualToString:@"VisiblityConditionsProcess"]);
                                     XCTAssert([processDefinition.modelID isEqualToString:@"VisiblityConditionsProcess:3:37730"]);
                                     XCTAssert([processDefinition.tenantID isEqualToString:@"tenant_1"]);
                                     XCTAssert(processDefinition.version == 3);
                                     
                                     [expectation fulfill];
                                 } queue:dispatch_get_main_queue()];
    
    // then
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItParsesProcessInstanceList {
    // given
    NSError *error = nil;
    
    NSString *filePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"ProcessInstanceListResponse" ofType:@"json"];
    NSData *jsonData = [[NSData alloc] initWithContentsOfFile:filePath];
    NSDictionary *response = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:jsonData
                                                                             options:NSJSONReadingMutableContainers
                                                                               error:&error];
    XCTAssertNil(error);
    
    XCTestExpectation *expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];

    // when
    [self.processParserWorker parseContentDictionary:response
                                              ofType:CREATE_STRING(ASDKProcessParserContentTypeProcessInstanceList)
                                 withCompletionBlock:^(id parsedObject, NSError *error, ASDKModelPaging *paging) {
                                     XCTAssertNil(error);
                                     XCTAssertNotNil(paging);
                                     XCTAssert([parsedObject isKindOfClass:[NSArray class]]);
                                     XCTAssert([(NSArray *)parsedObject count] == 2);
                                     
                                     XCTAssert(paging.total == 2);
                                     XCTAssert(paging.size == 2);
                                     XCTAssert(!paging.start);
                                     
                                     ASDKModelProcessInstance *processInstance = [(NSArray *)parsedObject firstObject];
                                     XCTAssert([processInstance.name isEqualToString:@"VisiblityConditionsProcess - October 5th 2016"]);
                                     XCTAssert([processInstance.modelID isEqualToString:@"50259"]);
                                     XCTAssertNil(processInstance.endDate);
                                     XCTAssert([processInstance.processDefinitionKey isEqualToString:@"VisiblityConditionsProcess"]);
                                     XCTAssert([processInstance.processDefinitionName isEqualToString:@"VisiblityConditionsProcess"]);
                                     XCTAssert([processInstance.tenantID isEqualToString:@"tenant_1"]);
                                     XCTAssert([processInstance.initiatorModel isKindOfClass:[ASDKModelProfile class]]);
                                     XCTAssert([processInstance.processDefinitionDeploymentID isEqualToString:@"37727"]);
                                     XCTAssertFalse(processInstance.isStartFormDefined);
                                     XCTAssert(processInstance.processDefinitionVersion == 3);
                                     XCTAssertNil(processInstance.processDefinitionDescription);
                                     XCTAssert([processInstance.processDefinitionCategory isEqualToString:@"http://www.activiti.org/processdef"]);
                                     NSDate *jsonDate = [[ASDKModelBase standardDateFormatter] dateFromString:@"2016-10-05T13:54:56.326+0000"];
                                     XCTAssert(NSOrderedSame == [processInstance.startDate compare:jsonDate]);
                                     
                                     [expectation fulfill];
                                 } queue:dispatch_get_main_queue()];
    
    // then
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItParsesProcessInstanceDetails {
    // given
    NSError *error = nil;
    
    NSString *filePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"ProcessInstanceDetailsResponse" ofType:@"json"];
    NSData *jsonData = [[NSData alloc] initWithContentsOfFile:filePath];
    NSDictionary *response = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:jsonData
                                                                             options:NSJSONReadingMutableContainers
                                                                               error:&error];
    XCTAssertNil(error);
    
    XCTestExpectation *processInstanceDetailsExpectation = [self expectationWithDescription:[NSString stringWithFormat:@"%@.processInstanceDetails", NSStringFromSelector(_cmd)]];
    XCTestExpectation *startProcessInstanceExpectation = [self expectationWithDescription:[NSString stringWithFormat:@"%@.startProcessInstance", NSStringFromSelector(_cmd)]];
    
    ASDKParserCompletionBlock parserCompletionBlock = ^(id parsedObject, NSError *error, ASDKModelPaging *paging) {
        XCTAssertNil(error);
        XCTAssertNil(paging);
        XCTAssert([parsedObject isKindOfClass:[ASDKModelProcessInstance class]]);
        
        ASDKModelProcessInstance *processInstance = (ASDKModelProcessInstance *)parsedObject;
        XCTAssert([processInstance.name isEqualToString:@"StartFormProcess - 13 September 2016"]);
        XCTAssert([processInstance.modelID isEqualToString:@"37678"]);
        XCTAssert([processInstance.processDefinitionKey isEqualToString:@"StartFormProcess"]);
        XCTAssert([processInstance.processDefinitionName isEqualToString:@"StartFormProcess"]);
        XCTAssert([processInstance.tenantID isEqualToString:@"tenant_1"]);
        XCTAssert([processInstance.initiatorModel isKindOfClass:[ASDKModelProfile class]]);
        XCTAssert([processInstance.processDefinitionDeploymentID isEqualToString:@"37674"]);
        XCTAssertTrue(processInstance.isStartFormDefined);
        XCTAssert(processInstance.processDefinitionVersion == 1);
        XCTAssertNil(processInstance.processDefinitionDescription);
        XCTAssert([processInstance.processDefinitionCategory isEqualToString:@"http://www.activiti.org/processdef"]);
        
        NSDate *jsonStartDate = [[ASDKModelBase standardDateFormatter] dateFromString:@"2016-09-13T12:05:57.688+0000"];
        NSDate *jsonEndDate = [[ASDKModelBase standardDateFormatter] dateFromString:@"2016-09-13T12:07:26.473+0000"];
        XCTAssert(NSOrderedSame == [processInstance.startDate compare:jsonStartDate]);
        XCTAssert(NSOrderedSame == [processInstance.endDate compare:jsonEndDate]);
    };
    
    // when
    [self.processParserWorker parseContentDictionary:response
                                              ofType:CREATE_STRING(ASDKProcessParserContentTypeProcessInstanceDetails)
                                 withCompletionBlock:^(id parsedObject, NSError *error, ASDKModelPaging *paging) {
                                     parserCompletionBlock(parsedObject, error, paging);
                                     [processInstanceDetailsExpectation fulfill];
                                 } queue:dispatch_get_main_queue()];
    
    [self.processParserWorker parseContentDictionary:response
                                              ofType:CREATE_STRING(ASDKProcessParserContentTypeStartProcessInstance)
                                 withCompletionBlock:^(id parsedObject, NSError *error, ASDKModelPaging *paging) {
                                     parserCompletionBlock(parsedObject, error, paging);
                                     [startProcessInstanceExpectation fulfill];
                                 } queue:dispatch_get_main_queue()];
    
    // then
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItParsesProcessInstanceContentList {
    // given
    NSError *error = nil;
    
    NSString *filePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"ProcessInstanceContentListResponse" ofType:@"json"];
    NSData *jsonData = [[NSData alloc] initWithContentsOfFile:filePath];
    NSDictionary *response = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:jsonData
                                                                             options:NSJSONReadingMutableContainers
                                                                               error:&error];
    XCTAssertNil(error);
    
    XCTestExpectation *expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    
    // when
    [self.processParserWorker parseContentDictionary:response
                                              ofType:CREATE_STRING(ASDKProcessParserContentTypeProcessInstanceContent)
                                 withCompletionBlock:^(id parsedObject, NSError *error, ASDKModelPaging *paging) {
                                     XCTAssertNil(error);
                                     XCTAssertNil(paging);
                                     XCTAssert([parsedObject isKindOfClass:[NSArray class]]);
                                     XCTAssert([(NSArray *)parsedObject count] == 1);
                                     
                                     ASDKModelProcessInstanceContent *processInstanceContentList = [(NSArray *)parsedObject firstObject];
                                     XCTAssert([processInstanceContentList.field.modelID isEqualToString:@"attachform"]);
                                     XCTAssert([processInstanceContentList.field.name isEqualToString:@"Attach form"]);
                                     
                                     ASDKModelContent *processInstanceContent = [processInstanceContentList.contentArr firstObject];
                                     XCTAssert([processInstanceContent.mimeType isEqualToString:@"image/jpeg"]);
                                     XCTAssert([processInstanceContent.displayType isEqualToString:@"image"]);
                                     XCTAssert(processInstanceContent.thumbnailStatus == ASDKModelContentAvailabilityTypeQueued);
                                     XCTAssert([processInstanceContent.modelID isEqualToString:@"9013"]);
                                     XCTAssertTrue(processInstanceContent.isModelContentAvailable);
                                     XCTAssert(processInstanceContent.owner &&
                                               [processInstanceContent.owner isKindOfClass:[ASDKModelProfile class]]);
                                     XCTAssertFalse(processInstanceContent.isLink);
                                     XCTAssert(processInstanceContent.previewStatus == ASDKModelContentAvailabilityTypeQueued);
                                     XCTAssert([processInstanceContent.contentName isEqualToString:@"IMG_0003.JPG"]);
                                     NSDate *jsonDate = [[ASDKModelBase standardDateFormatter] dateFromString:@"2016-10-04T07:40:36.005+0000"];
                                     XCTAssert(NSOrderedSame == [processInstanceContent.creationDate compare:jsonDate]);
                                     
                                     [expectation fulfill];
                                 } queue:dispatch_get_main_queue()];
    
    // then
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItParsesProcessInstanceComments {
    // given
    NSError *error = nil;
    
    NSString *filePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"CommentListResponse" ofType:@"json"];
    NSData *jsonData = [[NSData alloc] initWithContentsOfFile:filePath];
    NSDictionary *response = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:jsonData
                                                                             options:NSJSONReadingMutableContainers
                                                                               error:&error];
    XCTAssertNil(error);
    
    XCTestExpectation *expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    
    // when
    [self.processParserWorker parseContentDictionary:response
                                              ofType:CREATE_STRING(ASDKProcessParserContentTypeProcessInstanceComments)
                                 withCompletionBlock:^(id parsedObject, NSError *error, ASDKModelPaging *paging) {
                                     XCTAssertNil(error);
                                     XCTAssertNotNil(paging);
                                     XCTAssert([parsedObject isKindOfClass:[NSArray class]]);
                                     XCTAssert([(NSArray *)parsedObject count] == 1);
                                     
                                     XCTAssert(paging.total == 1);
                                     XCTAssert(paging.size == 1);
                                     XCTAssert(!paging.start);
                                     
                                     ASDKModelComment *comment = [(NSArray *)parsedObject firstObject];
                                     XCTAssert([comment.modelID isEqualToString:@"6008"]);
                                     XCTAssert([comment.message isEqualToString:@"Lorem ipsum dolor sit amet."]);
                                     XCTAssert(comment.authorModel &&
                                               [comment.authorModel isKindOfClass:[ASDKModelProfile class]]);
                                     NSDate *jsonDate = [[ASDKModelBase standardDateFormatter] dateFromString:@"2016-09-28T14:05:17.629+0000"];
                                     XCTAssert(NSOrderedSame == [comment.creationDate compare:jsonDate]);
                                     
                                     [expectation fulfill];
                                 } queue:dispatch_get_main_queue()];
    
    // then
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItParsesProcessCommentCreation {
    // given
    NSError *error = nil;
    
    NSString *filePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"CommentDetailsResponse" ofType:@"json"];
    NSData *jsonData = [[NSData alloc] initWithContentsOfFile:filePath];
    NSDictionary *response = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:jsonData
                                                                             options:NSJSONReadingMutableContainers
                                                                               error:&error];
    XCTAssertNil(error);
    
    XCTestExpectation *expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    
    // when
    [self.processParserWorker parseContentDictionary:response
                                              ofType:CREATE_STRING(ASDKProcessParserContentTypeProcessInstanceComment)
                                 withCompletionBlock:^(id parsedObject, NSError *error, ASDKModelPaging *paging) {
                                     XCTAssertNil(error);
                                     XCTAssertNil(paging);
                                     XCTAssert([parsedObject isKindOfClass:[ASDKModelComment class]]);
                                     
                                     ASDKModelComment *comment = (ASDKModelComment *)parsedObject;
                                     XCTAssert([comment.modelID isEqualToString:@"7007"]);
                                     XCTAssert([comment.message isEqualToString:@"Some test comment"]);
                                     XCTAssert(comment.authorModel &&
                                               [comment.authorModel isKindOfClass:[ASDKModelProfile class]]);
                                     
                                     [expectation fulfill];
                                 } queue:dispatch_get_main_queue()];
    
    // then
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItHandlesInvalidJSONData {
    // expect
    XCTestExpectation *processDefinitionListExpectation = [self expectationWithDescription:[NSString stringWithFormat:@"%@.processDefinitionList",NSStringFromSelector(_cmd)]];
    XCTestExpectation *processInstanceListExpectation = [self expectationWithDescription:[NSString stringWithFormat:@"%@.processInstanceList",NSStringFromSelector(_cmd)]];
    XCTestExpectation *startProcessInstanceExpectation = [self expectationWithDescription:[NSString stringWithFormat:@"%@.processStartProcessInstanceExpectation",NSStringFromSelector(_cmd)]];
    XCTestExpectation *processInstanceDetailsExpectation = [self expectationWithDescription:[NSString stringWithFormat:@"%@.processInstanceDetailsExpectation",NSStringFromSelector(_cmd)]];
    XCTestExpectation *processInstanceContentExpectation = [self expectationWithDescription:[NSString stringWithFormat:@"%@.processInstanceContentExpectation",NSStringFromSelector(_cmd)]];
    XCTestExpectation *processInstanceCommentsExpectation = [self expectationWithDescription:[NSString stringWithFormat:@"%@.processInstanceCommentsExpectation",NSStringFromSelector(_cmd)]];
    XCTestExpectation *processInstanceCommentExpectation = [self expectationWithDescription:[NSString stringWithFormat:@"%@.processInstanceCommentExpectation",NSStringFromSelector(_cmd)]];
    
    // when
    NSDictionary *invalidContentDictionary = @{@"foo":@"bar"};
    [self.processParserWorker parseContentDictionary:invalidContentDictionary
                                              ofType:CREATE_STRING(ASDKProcessParserContentTypeProcessDefinitionList)
                                 withCompletionBlock:^(id parsedObject, NSError *error, ASDKModelPaging *paging) {
                                     XCTAssertNotNil(error);
                                     XCTAssertNil(parsedObject);
                                     XCTAssertNil(paging);
                                     [processDefinitionListExpectation fulfill];
                                 } queue:dispatch_get_main_queue()];
    [self.processParserWorker parseContentDictionary:invalidContentDictionary
                                              ofType:CREATE_STRING(ASDKProcessParserContentTypeProcessInstanceList)
                                 withCompletionBlock:^(id parsedObject, NSError *error, ASDKModelPaging *paging) {
                                     XCTAssertNotNil(error);
                                     XCTAssertNil(parsedObject);
                                     XCTAssertNil(paging);
                                     [processInstanceListExpectation fulfill];
                                 } queue:dispatch_get_main_queue()];
    [self.processParserWorker parseContentDictionary:invalidContentDictionary
                                              ofType:CREATE_STRING(ASDKProcessParserContentTypeStartProcessInstance)
                                 withCompletionBlock:^(id parsedObject, NSError *error, ASDKModelPaging *paging) {
                                     XCTAssertNotNil(error);
                                     XCTAssertNil(parsedObject);
                                     XCTAssertNil(paging);
                                     [startProcessInstanceExpectation fulfill];
                                 } queue:dispatch_get_main_queue()];
    [self.processParserWorker parseContentDictionary:invalidContentDictionary
                                              ofType:CREATE_STRING(ASDKProcessParserContentTypeProcessInstanceDetails)
                                 withCompletionBlock:^(id parsedObject, NSError *error, ASDKModelPaging *paging) {
                                     XCTAssertNotNil(error);
                                     XCTAssertNil(parsedObject);
                                     XCTAssertNil(paging);
                                     [processInstanceDetailsExpectation fulfill];
                                 } queue:dispatch_get_main_queue()];
    [self.processParserWorker parseContentDictionary:invalidContentDictionary
                                              ofType:CREATE_STRING(ASDKProcessParserContentTypeProcessInstanceContent)
                                 withCompletionBlock:^(id parsedObject, NSError *error, ASDKModelPaging *paging) {
                                     XCTAssertNotNil(error);
                                     XCTAssertNil(parsedObject);
                                     XCTAssertNil(paging);
                                     [processInstanceContentExpectation fulfill];
                                 } queue:dispatch_get_main_queue()];
    [self.processParserWorker parseContentDictionary:invalidContentDictionary
                                              ofType:CREATE_STRING(ASDKProcessParserContentTypeProcessInstanceComments)
                                 withCompletionBlock:^(id parsedObject, NSError *error, ASDKModelPaging *paging) {
                                     XCTAssertNotNil(error);
                                     XCTAssertNil(parsedObject);
                                     XCTAssertNil(paging);
                                     [processInstanceCommentsExpectation fulfill];
                                 } queue:dispatch_get_main_queue()];
    [self.processParserWorker parseContentDictionary:invalidContentDictionary
                                              ofType:CREATE_STRING(ASDKProcessParserContentTypeProcessInstanceComment)
                                 withCompletionBlock:^(id parsedObject, NSError *error, ASDKModelPaging *paging) {
                                     XCTAssertNotNil(error);
                                     XCTAssertNil(parsedObject);
                                     XCTAssertNil(paging);
                                     [processInstanceCommentExpectation fulfill];
                                 } queue:dispatch_get_main_queue()];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

@end

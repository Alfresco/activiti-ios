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

@interface ASDKTaskDetailsParserOperationWorkerTest : ASDKBaseTest

@property (strong, nonatomic) ASDKTaskDetailsParserOperationWorker *taskDetailsParserWorker;

@end

@implementation ASDKTaskDetailsParserOperationWorkerTest

- (void)setUp {
    [super setUp];
    
    self.taskDetailsParserWorker = [ASDKTaskDetailsParserOperationWorker new];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testThatItReturnsAvailableServices {
    NSArray *availableServices = @[CREATE_STRING(ASDKTaskDetailsParserContentTypeTaskList),
                                   CREATE_STRING(ASDKTaskDetailsParserContentTypeTaskDetails),
                                   CREATE_STRING(ASDKTaskDetailsParserContentTypeContent),
                                   CREATE_STRING(ASDKTaskDetailsParserContentTypeComments),
                                   CREATE_STRING(ASDKTaskDetailsParserContentTypeComment)];
    XCTAssert([[self.taskDetailsParserWorker availableServices] isEqualToArray:availableServices]);
}

- (void)testThatItParsesTaskList {
    // given
    NSError *error = nil;
    
    NSString *filePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"TaskListResponse" ofType:@"json"];
    NSData *jsonData = [[NSData alloc] initWithContentsOfFile:filePath];
    NSDictionary *response = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:jsonData
                                                                             options:NSJSONReadingMutableContainers
                                                                               error:&error];
    XCTAssertNil(error);
    
    XCTestExpectation *expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    
    // when
    [self.taskDetailsParserWorker parseContentDictionary:response
                                                  ofType:CREATE_STRING(ASDKTaskDetailsParserContentTypeTaskList)
                                     withCompletionBlock:^(id parsedObject, NSError *error, ASDKModelPaging *paging) {
                                         XCTAssertNil(error);
                                         XCTAssertNotNil(paging);
                                         XCTAssert([parsedObject isKindOfClass:[NSArray class]]);
                                         XCTAssert([(NSArray *)parsedObject count] == 2);
                                         
                                         XCTAssert(paging.total == 2);
                                         XCTAssert(paging.size == 2);
                                         XCTAssert(!paging.start);
                                         
                                         ASDKModelTask *task = [(NSArray *)parsedObject firstObject];
                                         XCTAssert([task.processDefinitionName isEqualToString:@"DisplayValueProcess"]);
                                         XCTAssert(!task.duration);
                                         XCTAssert([task.formKey isEqualToString:@"7008"]);
                                         XCTAssertNil(task.parentTaskID);
                                         XCTAssertFalse(task.isMemberOfCandidateUsers);
                                         XCTAssert(task.assigneeModel &&
                                                   [task.assigneeModel isKindOfClass:[ASDKModelProfile class]]);
                                         XCTAssertNil(task.dueDate);
                                         XCTAssert([task.processInstanceID isEqualToString:@"35027"]);
                                         XCTAssert([task.processDefinitionID isEqualToString:@"DisplayValueProcess:1:35004"]);
                                         XCTAssert([task.name isEqualToString:@"DisplayFormFields"]);
                                         XCTAssertNil(task.endDate);
                                         XCTAssert(task.priority == 50);
                                         XCTAssert([task.modelID isEqualToString:@"35040"]);
                                         XCTAssertFalse(task.isMemberOfCandidateGroup);
                                         XCTAssertFalse(task.isManagerOfCandidateGroup);
                                         XCTAssertNil(task.taskDescription);
                                         NSDate *jsonDate = [[ASDKModelBase standardDateFormatter] dateFromString:@"2016-09-01T11:37:17.231+0000"];
                                         XCTAssert(NSOrderedSame == [task.creationDate compare:jsonDate]);
                                         
                                         [expectation fulfill];
                                     } queue:dispatch_get_main_queue()];
    
    // then
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItParsesTaskDetails {
    // given
    NSError *error = nil;
    
    NSString *filePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"TaskDetailsResponse" ofType:@"json"];
    NSData *jsonData = [[NSData alloc] initWithContentsOfFile:filePath];
    NSDictionary *response = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:jsonData
                                                                             options:NSJSONReadingMutableContainers
                                                                               error:&error];
    XCTAssertNil(error);
    
    XCTestExpectation *expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    
    // when
    [self.taskDetailsParserWorker parseContentDictionary:response
                                                  ofType:CREATE_STRING(ASDKTaskDetailsParserContentTypeTaskDetails)
                                     withCompletionBlock:^(id parsedObject, NSError *error, ASDKModelPaging *paging) {
                                         XCTAssertNil(error);
                                         XCTAssertNil(paging);
                                         XCTAssert([parsedObject isKindOfClass:[ASDKModelTask class]]);
                                         
                                         ASDKModelTask *task = (ASDKModelTask *)parsedObject;
                                         XCTAssert([task.processDefinitionName isEqualToString:@"DisplayValueProcess"]);
                                         XCTAssert(task.duration == 7336);
                                         XCTAssert([task.formKey isEqualToString:@"7007"]);
                                         XCTAssertNil(task.parentTaskID);
                                         XCTAssertFalse(task.isMemberOfCandidateUsers);
                                         XCTAssert(task.assigneeModel &&
                                                   [task.assigneeModel isKindOfClass:[ASDKModelProfile class]]);
                                         XCTAssertNil(task.dueDate);
                                         XCTAssert([task.processInstanceID isEqualToString:@"35027"]);
                                         XCTAssert([task.processDefinitionID isEqualToString:@"DisplayValueProcess:1:35004"]);
                                         XCTAssert([task.name isEqualToString:@"AllFormFields"]);
                                         XCTAssert(task.priority == 50);
                                         XCTAssert([task.modelID isEqualToString:@"35032"]);
                                         XCTAssertFalse(task.isMemberOfCandidateGroup);
                                         XCTAssertFalse(task.isManagerOfCandidateGroup);
                                         XCTAssert([task.taskDescription isEqualToString:@"Some description text"]);
                                         NSDate *jsonCreationDate = [[ASDKModelBase standardDateFormatter] dateFromString:@"2016-09-01T11:37:09.881+0000"];
                                         NSDate *jsonEndDate = [[ASDKModelBase standardDateFormatter] dateFromString:@"2016-09-01T11:37:17.217+0000"];
                                         XCTAssert(NSOrderedSame == [task.creationDate compare:jsonCreationDate]);
                                         XCTAssert(NSOrderedSame == [task.endDate compare:jsonEndDate]);
                                         
                                         [expectation fulfill];
                                     } queue:dispatch_get_main_queue()];
    
    // then
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItParsesTaskUploadContent {
    // given
    NSError *error = nil;
    
    NSString *filePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"TaskDetailsUploadContentResponse" ofType:@"json"];
    NSData *jsonData = [[NSData alloc] initWithContentsOfFile:filePath];
    NSDictionary *response = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:jsonData
                                                                             options:NSJSONReadingMutableContainers
                                                                               error:&error];
    XCTAssertNil(error);
    
    XCTestExpectation *expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    
    // when
    [self.taskDetailsParserWorker parseContentDictionary:response
                                                  ofType:CREATE_STRING(ASDKTaskDetailsParserContentTypeContent)
                                     withCompletionBlock:^(id parsedObject, NSError *error, ASDKModelPaging *paging) {
                                         XCTAssertNil(error);
                                         XCTAssertNil(paging);
                                         XCTAssert([parsedObject isKindOfClass:[ASDKModelContent class]]);
                                         
                                         ASDKModelContent *content = (ASDKModelContent *)parsedObject;
                                         XCTAssert([content.mimeType isEqualToString:@"image/jpeg"]);
                                         XCTAssert([content.displayType isEqualToString:@"image"]);
                                         XCTAssert(content.thumbnailStatus == ASDKModelContentAvailabilityTypeQueued);
                                         XCTAssert([content.modelID isEqualToString:@"10011"]);
                                         XCTAssertTrue(content.isModelContentAvailable);
                                         XCTAssertTrue(content.owner &&
                                                       [content.owner isKindOfClass:[ASDKModelProfile class]]);
                                         XCTAssertFalse(content.isLink);
                                         XCTAssert(content.previewStatus ==  ASDKModelContentAvailabilityTypeQueued);
                                         XCTAssert([content.contentName isEqualToString:@"IMG_0004.JPG"]);
                                         NSDate *jsonCreationDate = [[ASDKModelBase standardDateFormatter] dateFromString:@"2016-11-14T09:42:30.033+0000"];
                                         XCTAssert(NSOrderedSame == [content.creationDate compare:jsonCreationDate]);
                                         
                                         [expectation fulfill];
                                     } queue:dispatch_get_main_queue()];
    
    // then
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItParsesTaskContentList {
    // given
    NSError *error = nil;
    
    NSString *filePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"TaskDetailsContentListResponse" ofType:@"json"];
    NSData *jsonData = [[NSData alloc] initWithContentsOfFile:filePath];
    NSDictionary *response = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:jsonData
                                                                             options:NSJSONReadingMutableContainers
                                                                               error:&error];
    XCTAssertNil(error);
    
    XCTestExpectation *expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    
    // when
    [self.taskDetailsParserWorker parseContentDictionary:response
                                                  ofType:CREATE_STRING(ASDKTaskDetailsParserContentTypeContent)
                                     withCompletionBlock:^(id parsedObject, NSError *error, ASDKModelPaging *paging) {
                                         XCTAssertNil(error);
                                         XCTAssertNotNil(paging);
                                         XCTAssert([parsedObject isKindOfClass:[NSArray class]]);
                                         XCTAssert([(NSArray *)parsedObject count] == 2);
                                         
                                         XCTAssert(paging.total == 2);
                                         XCTAssert(paging.size == 2);
                                         XCTAssert(!paging.start);
                                         
                                         ASDKModelContent *content = [(NSArray *)parsedObject firstObject];
                                         XCTAssert([content.mimeType isEqualToString:@"image/jpeg"]);
                                         XCTAssert([content.displayType isEqualToString:@"image"]);
                                         XCTAssert(content.thumbnailStatus == ASDKModelContentAvailabilityTypeQueued);
                                         XCTAssert([content.modelID isEqualToString:@"10010"]);
                                         XCTAssertTrue(content.isModelContentAvailable);
                                         XCTAssertTrue(content.owner &&
                                                       [content.owner isKindOfClass:[ASDKModelProfile class]]);
                                         XCTAssertFalse(content.isLink);
                                         XCTAssert(content.previewStatus ==  ASDKModelContentAvailabilityTypeQueued);
                                         XCTAssert([content.contentName isEqualToString:@"IMG_0003.JPG"]);
                                         NSDate *jsonCreationDate = [[ASDKModelBase standardDateFormatter] dateFromString:@"2016-11-14T09:41:16.589+0000"];
                                         XCTAssert(NSOrderedSame == [content.creationDate compare:jsonCreationDate]);
                                         
                                         [expectation fulfill];
                                     } queue:dispatch_get_main_queue()];
    
    // then
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItParsesTaskCommentList {
    // given
    NSError *error = nil;
    
    NSString *filePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"TaskDetailsCommentListResponse" ofType:@"json"];
    NSData *jsonData = [[NSData alloc] initWithContentsOfFile:filePath];
    NSDictionary *response = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:jsonData
                                                                             options:NSJSONReadingMutableContainers
                                                                               error:&error];
    XCTAssertNil(error);
    
    XCTestExpectation *expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    
    // when
    [self.taskDetailsParserWorker parseContentDictionary:response
                                                  ofType:CREATE_STRING(ASDKTaskDetailsParserContentTypeComments)
                                     withCompletionBlock:^(id parsedObject, NSError *error, ASDKModelPaging *paging) {
                                         XCTAssertNil(error);
                                         XCTAssertNotNil(paging);
                                         XCTAssert([parsedObject isKindOfClass:[NSArray class]]);
                                         XCTAssert([(NSArray *)parsedObject count] == 1);
                                         
                                         XCTAssert(paging.total == 1);
                                         XCTAssert(paging.size == 1);
                                         XCTAssert(!paging.start);
                                         
                                         ASDKModelComment *comment = [(NSArray *)parsedObject firstObject];
                                         XCTAssert([comment.modelID isEqualToString:@"8009"]);
                                         XCTAssert([comment.message isEqualToString:@"Some text here"]);
                                         XCTAssert(comment.authorModel &&
                                                   [comment.authorModel isKindOfClass:[ASDKModelProfile class]]);
                                         NSDate *jsonCreationDate = [[ASDKModelBase standardDateFormatter] dateFromString:@"2016-11-14T09:50:09.365+0000"];
                                         XCTAssert(NSOrderedSame == [comment.creationDate compare:jsonCreationDate]);
                                         
                                         [expectation fulfill];
                                     } queue:dispatch_get_main_queue()];
    
    // then
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItParsesTaskCommentCreation {
    // given
    NSError *error = nil;
    
    NSString *filePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"TaskDetailsCreateCommentResponse" ofType:@"json"];
    NSData *jsonData = [[NSData alloc] initWithContentsOfFile:filePath];
    NSDictionary *response = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:jsonData
                                                                             options:NSJSONReadingMutableContainers
                                                                               error:&error];
    XCTAssertNil(error);
    
    XCTestExpectation *expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    
    // when
    [self.taskDetailsParserWorker parseContentDictionary:response
                                                  ofType:CREATE_STRING(ASDKTaskDetailsParserContentTypeComment)
                                     withCompletionBlock:^(id parsedObject, NSError *error, ASDKModelPaging *paging) {
                                         XCTAssertNil(error);
                                         XCTAssertNil(paging);
                                         XCTAssert([parsedObject isKindOfClass:[ASDKModelComment class]]);
                                         
                                         ASDKModelComment *comment = (ASDKModelComment *)parsedObject;
                                         XCTAssert([comment.modelID isEqualToString:@"8010"]);
                                         XCTAssert([comment.message isEqualToString:@"Another text here..."]);
                                         XCTAssert(comment.authorModel &&
                                                   [comment.authorModel isKindOfClass:[ASDKModelProfile class]]);
                                         NSDate *jsonCreationDate = [[ASDKModelBase standardDateFormatter] dateFromString:@"2016-11-14T09:58:45.460+0000"];
                                         XCTAssert(NSOrderedSame == [comment.creationDate compare:jsonCreationDate]);
                                         
                                         [expectation fulfill];
                                     } queue:dispatch_get_main_queue()];
    
    // then
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItHandlesInvalidJSONData {
    // expect
    XCTestExpectation *taskListExpectation = [self expectationWithDescription:[NSString stringWithFormat:@"%@.taskList", NSStringFromSelector(_cmd)]];
    XCTestExpectation *taskDetailsExpectation = [self expectationWithDescription:[NSString stringWithFormat:@"%@.taskDetails", NSStringFromSelector(_cmd)]];
    XCTestExpectation *taskContentExpectation = [self expectationWithDescription:[NSString stringWithFormat:@"%@.taskContent", NSStringFromSelector(_cmd)]];
    XCTestExpectation *taskCommentListExpectation = [self expectationWithDescription:[NSString stringWithFormat:@"%@.taskCommentList", NSStringFromSelector(_cmd)]];
    XCTestExpectation *taskCreateCommentExpectation = [self expectationWithDescription:[NSString stringWithFormat:@"%@.taskCreateCommentExpectation", NSStringFromSelector(_cmd)]];
    
    // when
    NSDictionary *invalidContentDictionary = @{@"foo":@"bar"};
    [self.taskDetailsParserWorker parseContentDictionary:invalidContentDictionary
                                                  ofType:CREATE_STRING(ASDKTaskDetailsParserContentTypeTaskList)
                                     withCompletionBlock:^(id parsedObject, NSError *error, ASDKModelPaging *paging) {
                                         XCTAssertNotNil(error);
                                         XCTAssertNil(parsedObject);
                                         XCTAssertNil(paging);
                                         
                                         [taskListExpectation fulfill];
                                     } queue:dispatch_get_main_queue()];
    [self.taskDetailsParserWorker parseContentDictionary:invalidContentDictionary
                                                  ofType:CREATE_STRING(ASDKTaskDetailsParserContentTypeTaskDetails)
                                     withCompletionBlock:^(id parsedObject, NSError *error, ASDKModelPaging *paging) {
                                         XCTAssertNotNil(error);
                                         XCTAssertNil(parsedObject);
                                         XCTAssertNil(paging);
                                         
                                         [taskDetailsExpectation fulfill];
                                     } queue:dispatch_get_main_queue()];
    [self.taskDetailsParserWorker parseContentDictionary:invalidContentDictionary
                                                  ofType:CREATE_STRING(ASDKTaskDetailsParserContentTypeContent)
                                     withCompletionBlock:^(id parsedObject, NSError *error, ASDKModelPaging *paging) {
                                         XCTAssertNotNil(error);
                                         XCTAssertNil(parsedObject);
                                         XCTAssertNil(paging);
                                         
                                         [taskContentExpectation fulfill];
                                     } queue:dispatch_get_main_queue()];
    [self.taskDetailsParserWorker parseContentDictionary:invalidContentDictionary
                                                  ofType:CREATE_STRING(ASDKTaskDetailsParserContentTypeComments)
                                     withCompletionBlock:^(id parsedObject, NSError *error, ASDKModelPaging *paging) {
                                         XCTAssertNotNil(error);
                                         XCTAssertNil(parsedObject);
                                         XCTAssertNil(paging);
                                         
                                         [taskCommentListExpectation fulfill];
                                     } queue:dispatch_get_main_queue()];
    [self.taskDetailsParserWorker parseContentDictionary:invalidContentDictionary
                                                  ofType:CREATE_STRING(ASDKTaskDetailsParserContentTypeComment)
                                     withCompletionBlock:^(id parsedObject, NSError *error, ASDKModelPaging *paging) {
                                         XCTAssertNotNil(error);
                                         XCTAssertNil(parsedObject);
                                         XCTAssertNil(paging);
                                         
                                         [taskCreateCommentExpectation fulfill];
                                     } queue:dispatch_get_main_queue()];
    
    [self waitForExpectationsWithTimeout:.5
                                 handler:nil];
}

@end

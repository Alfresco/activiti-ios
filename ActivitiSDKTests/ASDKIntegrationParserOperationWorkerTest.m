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

@interface ASDKIntegrationParserOperationWorkerTest : ASDKBaseTest

@property (strong, nonatomic) ASDKIntegrationParserOperationWorker *integrationParserWorker;

@end

@implementation ASDKIntegrationParserOperationWorkerTest

- (void)setUp {
    [super setUp];
    
    self.integrationParserWorker = [ASDKIntegrationParserOperationWorker new];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testThatItReturnsAvailableServices {
    NSArray *availableServices = @[CREATE_STRING(ASDKIntegrationParserContentTypeAccountList),
                                   CREATE_STRING(ASDKIntegrationParserContentTypeNetworkList),
                                   CREATE_STRING(ASDKIntegrationParserContentTypeSiteList),
                                   CREATE_STRING(ASDKIntegrationParserContentTypeSiteContentList),
                                   CREATE_STRING(ASDKIntegrationParserContentTypeFolderContentList),
                                   CREATE_STRING(ASDKIntegrationParserContentTypeUploadedContent)];
    XCTAssert([[self.integrationParserWorker availableServices] isEqualToArray:availableServices]);
}

- (void)testThatItParsesIntegrationAccounts {
    // given
    NSError *error = nil;
    
    NSString *filePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"IntegrationAccountListResponse" ofType:@"json"];
    NSData *jsonData = [[NSData alloc] initWithContentsOfFile:filePath];
    NSDictionary *response = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:jsonData
                                                                             options:NSJSONReadingMutableContainers
                                                                               error:&error];
    XCTAssertNil(error);
    
    XCTestExpectation *expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    
    // when
    [self.integrationParserWorker parseContentDictionary:response
                                                  ofType:CREATE_STRING(ASDKIntegrationParserContentTypeAccountList)
                                     withCompletionBlock:^(id parsedObject, NSError *error, ASDKModelPaging *paging) {
                                         XCTAssertNil(error);
                                         XCTAssertNotNil(paging);
                                         XCTAssert([parsedObject isKindOfClass:[NSArray class]]);
                                         XCTAssert([(NSArray *)parsedObject count] == 3);
                                         
                                         XCTAssert(paging.total == 3);
                                         XCTAssert(paging.size == 3);
                                         XCTAssert(!paging.start);
                                         
                                         ASDKModelIntegrationAccount *alfrescoIntegrationAccount = [(NSArray *)parsedObject firstObject];
                                         XCTAssertTrue(alfrescoIntegrationAccount.isAccountAuthorized);
                                         XCTAssertTrue(alfrescoIntegrationAccount.isMetadataAllowed);
                                         XCTAssert([alfrescoIntegrationAccount.integrationServiceID isEqualToString:@"alfresco-cloud"]);
                                         
                                         ASDKModelIntegrationAccount *googleIntegrationAccount = [(NSArray *)parsedObject lastObject];
                                         XCTAssertFalse(googleIntegrationAccount.isAccountAuthorized);
                                         XCTAssertTrue(googleIntegrationAccount.isMetadataAllowed);
                                         XCTAssert([googleIntegrationAccount.integrationServiceID isEqualToString:@"google-drive"]);
                                         XCTAssertTrue(googleIntegrationAccount.authorizationURLString.length);
                                         
                                         [expectation fulfill];
                                     } queue:dispatch_get_main_queue()];
    
    // then
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItParsesNetworkList {
    // given
    NSError *error = nil;
    
    NSString *filePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"IntegrationNetworkListResponse" ofType:@"json"];
    NSData *jsonData = [[NSData alloc] initWithContentsOfFile:filePath];
    NSDictionary *response = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:jsonData
                                                                             options:NSJSONReadingMutableContainers
                                                                               error:&error];
    XCTAssertNil(error);
    
    XCTestExpectation *expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    
    // when
    [self.integrationParserWorker parseContentDictionary:response
                                                  ofType:CREATE_STRING(ASDKIntegrationParserContentTypeNetworkList)
                                     withCompletionBlock:^(id parsedObject, NSError *error, ASDKModelPaging *paging) {
                                         XCTAssertNil(error);
                                         XCTAssertNotNil(paging);
                                         XCTAssert([parsedObject isKindOfClass:[NSArray class]]);
                                         XCTAssert([(NSArray *)parsedObject count] == 2);
                                         
                                         XCTAssert(paging.total == 2);
                                         XCTAssert(paging.size == 2);
                                         XCTAssert(!paging.start);
                                         
                                         ASDKModelNetwork *network = [(NSArray *)parsedObject firstObject];
                                         XCTAssert([network.modelID isEqualToString:@"alfresco.com"]);
                                         
                                         [expectation fulfill];
                                     } queue:dispatch_get_main_queue()];
    
    // then
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItParsesSiteList {
    // given
    NSError *error = nil;
    
    NSString *filePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"IntegrationSiteListResponse" ofType:@"json"];
    NSData *jsonData = [[NSData alloc] initWithContentsOfFile:filePath];
    NSDictionary *response = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:jsonData
                                                                             options:NSJSONReadingMutableContainers
                                                                               error:&error];
    XCTAssertNil(error);
    
    XCTestExpectation *expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    
    // when
    [self.integrationParserWorker parseContentDictionary:response
                                                  ofType:CREATE_STRING(ASDKIntegrationParserContentTypeSiteList)
                                     withCompletionBlock:^(id parsedObject, NSError *error, ASDKModelPaging *paging) {
                                         XCTAssertNil(error);
                                         XCTAssertNotNil(paging);
                                         XCTAssert([parsedObject isKindOfClass:[NSArray class]]);
                                         XCTAssert([(NSArray *)parsedObject count] == 1);
                                         
                                         XCTAssert(paging.total == 1);
                                         XCTAssert(paging.size == 1);
                                         XCTAssert(!paging.start);
                                         
                                         ASDKModelSite *site = [(NSArray *)parsedObject firstObject];
                                         XCTAssert([site.modelID isEqualToString:@"activiti"]);
                                         XCTAssert([site.title isEqualToString:@"Activiti"]);
                                         
                                         [expectation fulfill];
                                     } queue:dispatch_get_main_queue()];
    
    // then
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItParsesSiteContent {
    // given
    NSError *error = nil;
    
    NSString *filePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"IntegrationFolderContentResponse" ofType:@"json"];
    NSData *jsonData = [[NSData alloc] initWithContentsOfFile:filePath];
    NSDictionary *response = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:jsonData
                                                                             options:NSJSONReadingMutableContainers
                                                                               error:&error];
    XCTAssertNil(error);
    
    XCTestExpectation *expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    
    // when
    [self.integrationParserWorker parseContentDictionary:response
                                                  ofType:CREATE_STRING(ASDKIntegrationParserContentTypeSiteContentList)
                                     withCompletionBlock:^(id parsedObject, NSError *error, ASDKModelPaging *paging) {
                                         XCTAssertNil(error);
                                         XCTAssertNotNil(paging);
                                         XCTAssert([parsedObject isKindOfClass:[NSArray class]]);
                                         XCTAssert([(NSArray *)parsedObject count] == 5);
                                         
                                         XCTAssert(paging.total == 5);
                                         XCTAssert(paging.size == 5);
                                         XCTAssert(!paging.start);
                                         
                                         ASDKModelIntegrationContent *integrationContent = [(NSArray *)parsedObject firstObject];
                                         XCTAssert([integrationContent.modelID isEqualToString:@"a7058e6e-3b3b-45dd-b578-bdfe474b20d8"]);
                                         XCTAssert([integrationContent.title isEqualToString:@"Videos"]);
                                         XCTAssert([integrationContent.simpleType isEqualToString:@"folder"]);
                                         XCTAssertTrue(integrationContent.isFolder);
                                         
                                         [expectation fulfill];
                                     } queue:dispatch_get_main_queue()];
    
    // then
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItParsesUploadIntegrationContent {
    // given
    NSError *error = nil;
    
    NSString *filePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"IntegrationUploadContentResponse" ofType:@"json"];
    NSData *jsonData = [[NSData alloc] initWithContentsOfFile:filePath];
    NSDictionary *response = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:jsonData
                                                                             options:NSJSONReadingMutableContainers
                                                                               error:&error];
    XCTAssertNil(error);
    
    XCTestExpectation *expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    
    // when
    [self.integrationParserWorker parseContentDictionary:response
                                                  ofType:CREATE_STRING(ASDKIntegrationParserContentTypeUploadedContent)
                                     withCompletionBlock:^(id parsedObject, NSError *error, ASDKModelPaging *paging) {
                                         XCTAssertNil(error);
                                         XCTAssertNil(paging);
                                         XCTAssert([parsedObject isKindOfClass:[ASDKModelContent class]]);
                                         
                                         ASDKModelContent *content = (ASDKModelContent *)parsedObject;
                                         XCTAssertNil(content.mimeType);
                                         XCTAssert([content.displayType isEqualToString:@"pdf"]);
                                         XCTAssert([content.source isEqualToString:@"alfresco-cloud"]);
                                         XCTAssert(content.thumbnailStatus == ASDKModelContentAvailabilityTypeQueued);
                                         XCTAssert(content.previewStatus ==  ASDKModelContentAvailabilityTypeQueued);
                                         XCTAssert([content.modelID isEqualToString:@"10012"]);
                                         XCTAssertFalse(content.isModelContentAvailable);
                                         XCTAssertTrue(content.owner &&
                                                       [content.owner isKindOfClass:[ASDKModelProfile class]]);
                                         XCTAssertFalse(content.isLink);
                                         
                                         XCTAssert([content.contentName isEqualToString:@"Alfresco Mobile.pdf"]);
                                         NSDate *jsonCreationDate = [[ASDKModelBase standardDateFormatter] dateFromString:@"2016-11-18T09:30:59.906+0000"];
                                         XCTAssert(NSOrderedSame == [content.creationDate compare:jsonCreationDate]);
                                         XCTAssertTrue(content.sourceID.length);
                                         
                                         [expectation fulfill];
                                     } queue:dispatch_get_main_queue()];
    
    // then
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItHandlesInvalidJSONData {
    // expect
    XCTestExpectation *accountListExpectation = [self expectationWithDescription:[NSString stringWithFormat:@"%@.accountList", NSStringFromSelector(_cmd)]];
    XCTestExpectation *networkListExpectation = [self expectationWithDescription:[NSString stringWithFormat:@"%@.networkList", NSStringFromSelector(_cmd)]];
    XCTestExpectation *siteListExpectation = [self expectationWithDescription:[NSString stringWithFormat:@"%@.siteList", NSStringFromSelector(_cmd)]];
    XCTestExpectation *siteContentListExpectation = [self expectationWithDescription:[NSString stringWithFormat:@"%@.siteContentList", NSStringFromSelector(_cmd)]];
    XCTestExpectation *folderContentListExpectation = [self expectationWithDescription:[NSString stringWithFormat:@"%@.folderContentList", NSStringFromSelector(_cmd)]];
    XCTestExpectation *uploadIntegrationContentExpectation = [self expectationWithDescription:[NSString stringWithFormat:@"%@.uploadIntegrationContent", NSStringFromSelector(_cmd)]];
    
    // when
    NSDictionary *invalidContentDictionary = @{@"foo":@"bar"};
    [self.integrationParserWorker parseContentDictionary:invalidContentDictionary
                                                  ofType:CREATE_STRING(ASDKIntegrationParserContentTypeAccountList)
                                     withCompletionBlock:^(id parsedObject, NSError *error, ASDKModelPaging *paging) {
                                         XCTAssertNotNil(error);
                                         XCTAssertNil(parsedObject);
                                         XCTAssertNil(paging);
                                         
                                         [accountListExpectation fulfill];
                                     } queue:dispatch_get_main_queue()];
    [self.integrationParserWorker parseContentDictionary:invalidContentDictionary
                                                  ofType:CREATE_STRING(ASDKIntegrationParserContentTypeNetworkList)
                                     withCompletionBlock:^(id parsedObject, NSError *error, ASDKModelPaging *paging) {
                                         XCTAssertNotNil(error);
                                         XCTAssertNil(parsedObject);
                                         XCTAssertNil(paging);
                                         
                                         [networkListExpectation fulfill];
                                     } queue:dispatch_get_main_queue()];
    [self.integrationParserWorker parseContentDictionary:invalidContentDictionary
                                                  ofType:CREATE_STRING(ASDKIntegrationParserContentTypeSiteList)
                                     withCompletionBlock:^(id parsedObject, NSError *error, ASDKModelPaging *paging) {
                                         XCTAssertNotNil(error);
                                         XCTAssertNil(parsedObject);
                                         XCTAssertNil(paging);
                                         
                                         [siteListExpectation fulfill];
                                     } queue:dispatch_get_main_queue()];
    [self.integrationParserWorker parseContentDictionary:invalidContentDictionary
                                                  ofType:CREATE_STRING(ASDKIntegrationParserContentTypeSiteContentList)
                                     withCompletionBlock:^(id parsedObject, NSError *error, ASDKModelPaging *paging) {
                                         XCTAssertNotNil(error);
                                         XCTAssertNil(parsedObject);
                                         XCTAssertNil(paging);
                                         
                                         [siteContentListExpectation fulfill];
                                     } queue:dispatch_get_main_queue()];
    [self.integrationParserWorker parseContentDictionary:invalidContentDictionary
                                                  ofType:CREATE_STRING(ASDKIntegrationParserContentTypeFolderContentList)
                                     withCompletionBlock:^(id parsedObject, NSError *error, ASDKModelPaging *paging) {
                                         XCTAssertNotNil(error);
                                         XCTAssertNil(parsedObject);
                                         XCTAssertNil(paging);
                                         
                                         [folderContentListExpectation fulfill];
                                     } queue:dispatch_get_main_queue()];
    [self.integrationParserWorker parseContentDictionary:invalidContentDictionary
                                                  ofType:CREATE_STRING(ASDKIntegrationParserContentTypeUploadedContent)
                                     withCompletionBlock:^(id parsedObject, NSError *error, ASDKModelPaging *paging) {
                                         XCTAssertNotNil(error);
                                         XCTAssertNil(parsedObject);
                                         XCTAssertNil(paging);
                                         
                                         [uploadIntegrationContentExpectation fulfill];
                                     } queue:dispatch_get_main_queue()];
    
    [self waitForExpectationsWithTimeout:.5
                                 handler:nil];
}

@end

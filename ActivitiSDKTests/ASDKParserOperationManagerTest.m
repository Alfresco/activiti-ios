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

@interface ASDKParserOperationManagerTest : ASDKBaseTest

@property (strong, nonatomic) ASDKParserOperationManager *parserManager;

@end

@implementation ASDKParserOperationManagerTest

- (void)setUp {
    [super setUp];
    
    self.parserManager = [ASDKParserOperationManager new];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testThatItParsesDataForRegisteredServices {
    // given
    NSString *workerID = @"ASDKGenericParserWorker";
    NSArray *serviceArr = @[workerID];
    NSDictionary *contentDictionary = @{@"foo":@"bar"};
    ASDKParserCompletionBlock completionBlock = ^(id parsedObject, NSError *error, ASDKModelPaging *paging) {};
    id parserWorker = OCMProtocolMock(@protocol(ASDKParserOperationWorkerProtocol));
    OCMStub([parserWorker availableServices]).andReturn(serviceArr);
    
    // expect
    OCMExpect([parserWorker parseContentDictionary:contentDictionary
                                            ofType:workerID
                               withCompletionBlock:[OCMArg any]
                                             queue:[OCMArg any]]);
    
    // when
    [self.parserManager registerWorker:parserWorker
                           forServices:serviceArr];
    [self.parserManager parseContentDictionary:contentDictionary
                                        ofType:workerID
                           withCompletionBlock:completionBlock];
}

- (void)testThatItHandlesUnregisteredJob {
    // given
    NSString *workerID = @"ASDKGenericParserWorker";
    NSArray *serviceArr = @[workerID];
    NSDictionary *contentDictionary = @{@"foo":@"bar"};
    ASDKParserCompletionBlock completionBlock = ^(id parsedObject, NSError *error, ASDKModelPaging *paging) {};
    id parserWorker = OCMProtocolMock(@protocol(ASDKParserOperationWorkerProtocol));
    OCMStub([parserWorker availableServices]).andReturn(serviceArr);
    
    // expect
    OCMReject([parserWorker parseContentDictionary:[OCMArg any]
                                            ofType:[OCMArg any]
                               withCompletionBlock:[OCMArg any]
                                             queue:[OCMArg any]]);
    
    // when
    [self.parserManager parseContentDictionary:contentDictionary
                                        ofType:workerID
                           withCompletionBlock:completionBlock];
}

@end

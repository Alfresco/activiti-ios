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

@interface NSURLSessionTaskMock : NSURLSessionTask

@end

@implementation NSURLSessionTaskMock

- (NSURLResponse *)response {
    id responseMock = OCMClassMock([NSHTTPURLResponse class]);
    OCMStub([responseMock statusCode]).andReturn(200);
    
    return responseMock;
}

- (NSURLRequest *)originalRequest {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://localhost/activiti-app/api/enterprise/profile"]];
    [request setHTTPMethod:@"GET"];
    [request setHTTPBody:[@"{\"foo\":\"bar\"}" dataUsingEncoding:NSUTF8StringEncoding]];
    return request;
}

- (NSError *)error {
    return nil;
}

@end

@interface NSURLSessionTask_ASDKAdditionsTest : ASDKBaseTest

@end

@implementation NSURLSessionTask_ASDKAdditionsTest

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testThatItReturnsStatusCode {
    // given
    NSURLSessionTaskMock *taskMock = [NSURLSessionTaskMock new];
    
    // then
    XCTAssert([(NSURLSessionTask *)taskMock statusCode] == 200);
}

- (void)testThatItCreatesRequestDescription {
    // given
    NSURLSessionTaskMock *taskMock = [NSURLSessionTaskMock new];
    
    // then
    XCTAssert([[taskMock requestDescription] isEqualToString:@"GET - https://localhost/activiti-app/api/enterprise/profile\nBody: {\"foo\":\"bar\"}\n"]);
}

- (void)testThatItCreatesStateDescription {
    // given
    NSURLSessionTaskMock *taskMock = [NSURLSessionTaskMock new];
    NSDictionary *response = @{@"foo":@"bar"};
    id error = OCMClassMock([NSError class]);
    
    NSString *successExpectedResponse = [NSString stringWithFormat:@"GET - https://localhost/activiti-app/api/enterprise/profile\nBody: {\"foo\":\"bar\"}\nResponse: %@", response];
    NSString *failedExpectedResponse = [NSString stringWithFormat:@"GET - https://localhost/activiti-app/api/enterprise/profile\nBody: {\"foo\":\"bar\"}\nError: %@", nil];
    
    
    // then
    XCTAssert([[taskMock stateDescriptionForResponse:response
                                           withError:nil] isEqualToString:successExpectedResponse]);
    XCTAssert([[taskMock stateDescriptionForResponse:response
                                          withError:error] isEqualToString:failedExpectedResponse]);
    XCTAssert([[taskMock stateDescriptionForResponse:response] isEqualToString:successExpectedResponse]);
    XCTAssert([[taskMock stateDescriptionForError:error] isEqualToString:failedExpectedResponse]);
}

@end

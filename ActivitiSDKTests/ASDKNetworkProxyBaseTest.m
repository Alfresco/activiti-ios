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

@interface NSURLSessionDataTaskMock : NSURLSessionDataTask

@property (assign, nonatomic) ASDKHTTPCode  expectedStatusCode;
@property (strong, nonatomic) NSError       *expectedError;
@property (strong, nonatomic) NSURL         *expectedBaseURL;

@end

@implementation NSURLSessionDataTaskMock

- (NSURLResponse *)response {
    id responseMock = OCMClassMock([NSHTTPURLResponse class]);
    OCMStub([responseMock statusCode]).andReturn(_expectedStatusCode);
    
    return responseMock;
}

- (NSURLRequest *)originalRequest {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:_expectedBaseURL];
    return request;
}

- (NSError *)error {
    return _expectedError;
}

@end

@interface NSURLSessionDownloadTaskMock : NSURLSessionDownloadTask

@property (assign, nonatomic) ASDKHTTPCode  expectedStatusCode;
@property (strong, nonatomic) NSError       *expectedError;
@property (strong, nonatomic) NSURL         *expectedBaseURL;

@end

@implementation NSURLSessionDownloadTaskMock

- (NSURLResponse *)response {
    id responseMock = OCMClassMock([NSHTTPURLResponse class]);
    OCMStub([responseMock statusCode]).andReturn(_expectedStatusCode);
    
    return responseMock;
}

- (NSURLRequest *)originalRequest {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:_expectedBaseURL];
    return request;
}

- (NSError *)error {
    return _expectedError;
}

- (void)resume {
}

@end

@implementation ASDKNetworkProxyBaseTest

- (void)setUp {
    [super setUp];
    self.parserOperationManager = [ASDKParserOperationManager new];
}

- (NSURLSessionDataTask *)dataTaskWithStatusCode:(ASDKHTTPCode)statusCode
                                            error:(NSError *)error {
    NSURLSessionDataTaskMock *mockTask = [NSURLSessionDataTaskMock new];
    mockTask.expectedStatusCode = statusCode;
    mockTask.expectedError = error;
    mockTask.expectedBaseURL = self.baseURL;
    
    return (NSURLSessionDataTask *)mockTask;
}

- (NSURLSessionDataTask *)dataTaskWithStatusCode:(ASDKHTTPCode)statusCode {
    return [self dataTaskWithStatusCode:statusCode
                                   error:nil];
}

- (NSURLSessionDownloadTask *)downloadTaskWithStatusCode:(ASDKHTTPCode)statusCode {
    return [self downloadTaskWithStatusCode:statusCode
                                      error:nil];
}

- (NSURLSessionDownloadTask *)downloadTaskWithStatusCode:(ASDKHTTPCode)statusCode
                                                   error:(NSError *)error {
    NSURLSessionDownloadTaskMock *mockTask = [NSURLSessionDownloadTaskMock new];
    mockTask.expectedStatusCode = statusCode;
    mockTask.expectedError = error;
    mockTask.expectedBaseURL = self.baseURL;

    return (NSURLSessionDownloadTask *)mockTask;
}

- (NSError *)requestGenericError {
    return [NSError errorWithDomain:@"com.activitiSDK.tests"
                               code:0
                           userInfo:nil];
}

@end

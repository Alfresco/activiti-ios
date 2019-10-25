/*******************************************************************************
 * Copyright (C) 2005-2018 Alfresco Software Limited.
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

@interface ASDKNetworkServiceTest : ASDKBaseTest

@property (strong,  nonatomic) ASDKNetworkService *genericNetworkService;

@end

@implementation ASDKNetworkServiceTest

- (void)setUp {
    [super setUp];
    
    id servicePathFactory = OCMClassMock([ASDKServicePathFactory class]);
    id parserOperationManager = OCMClassMock([ASDKParserOperationManager class]);
    id diskServices = OCMClassMock([ASDKDiskServices class]);
    id authenticationProvider = OCMClassMock([ASDKBasicAuthenticationProvider class]);
    ASDKRequestOperationManager *requestOperationManager = [[ASDKRequestOperationManager alloc] initWithBaseURL:[self baseURL]
                                                                                         authenticationProvider:authenticationProvider];
    self.genericNetworkService = [[ASDKNetworkService alloc] initWithRequestManager:requestOperationManager
                                                                      parserManager:parserOperationManager
                                                                 servicePathFactory:servicePathFactory
                                                                       diskServices:diskServices
                                                                       resultsQueue:nil];
}

- (void)tearDown {
    [super tearDown];
    [self deleteAllCookies];
}

- (void)testThatItReturnsDictionaryForValidJSONDictionary {
    // given
    NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:self.baseURL
                                                              statusCode:200
                                                             HTTPVersion:@"1.1"
                                                            headerFields:@{@"Content-Type": @"text/json"}];
    
    // when
    NSError *error = nil;
    id responseObject = [self.genericNetworkService.requestOperationManager.responseSerializer responseObjectForResponse:response
                                                                                                                    data:[self jsonTestData]
                                                                                                                   error:&error];
    // then
    XCTAssertNil(error, @"Serialization error should be nil");
    XCTAssert([responseObject isKindOfClass:[NSDictionary class]], @"Expected response to be a NSDictionary");
}

- (void)testThatItHandlesHTTPResponses {
    // given
    NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:self.baseURL
                                                              statusCode:200
                                                             HTTPVersion:@"1.1"
                                                            headerFields:@{@"Content-Type":@"text/html"}];
    NSData *data = [@"test" dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    
    // then
    XCTAssertTrue([self.genericNetworkService.requestOperationManager.responseSerializer validateResponse:response
                                                                                                     data:data
                                                                                                    error:&error]);
}

- (void)testThatItHandlesImageResponses {
    // given
    NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:self.baseURL
                                                              statusCode:200
                                                             HTTPVersion:@"1.1"
                                                            headerFields:@{@"Content-Type": @"image/jpeg"}];
    NSString *imagePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"alfresco-icon"
                                                                           ofType:@"jpg"];
    NSData *imageData = [NSData dataWithContentsOfFile:imagePath];
    
    // when
    NSError *error = nil;
    id responseObject = [self.genericNetworkService.requestOperationManager.responseSerializer responseObjectForResponse:response
                                                                                                                    data:imageData
                                                                                                                   error:&error];
    // then
    XCTAssert([responseObject isKindOfClass:[UIImage class]], @"Expected to be a UIImage");
}

- (void)testThatItReturnsTheAppropiateRequestSerializer {
    XCTAssert([[self.genericNetworkService requestSerializerOfType:ASDKNetworkServiceRequestSerializerTypeJSON] isKindOfClass:[AFJSONRequestSerializer class]], @"Expected AFJSONRequestSerializer class type");
    XCTAssert([[self.genericNetworkService requestSerializerOfType:ASDKNetworkServiceRequestSerializerTypeHTTP] isKindOfClass:[AFHTTPRequestSerializer class]], @"Expected AFHTTPRequestSerializer class type");
}

- (void)testThatItConfiguresServiceWithCSRFToken {
    // given
    ASDKCSRFTokenStorage *tokenStorage = [ASDKCSRFTokenStorage new];
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    
    // when
    [self.genericNetworkService configureWithCSRFTokenStorage:tokenStorage];
    
    // then
    XCTAssert([[self.genericNetworkService requestSerializerOfType:ASDKNetworkServiceRequestSerializerTypeHTTPWithCSRFToken] isKindOfClass:[AFHTTPRequestSerializer class]], @"Expected AFHTTPRequestSerializer class type");
    
    XCTAssert([[[self.genericNetworkService requestSerializerOfType:ASDKNetworkServiceRequestSerializerTypeHTTPWithCSRFToken] valueForHTTPHeaderField:kASDKAPICSRFHeaderFieldParameter] isEqualToString:[tokenStorage csrfTokenString]], @"CSRF token attached to the request serializer doesn't match with cached value");
    
    BOOL isCSRFCookieAvailable = NO;
    for (NSHTTPCookie *cookie in [cookieStorage cookies]) {
        if ([cookie.name isEqualToString:kASDKAPICSRFCookieName]) {
            isCSRFCookieAvailable = YES;
            break;
        }
    }
    XCTAssert(isCSRFCookieAvailable, @"CSRF cookie not available after configuration");
}

- (void)testThatItDoesntOverrideExistentCSRFCookie {
    // given
    id tokenStorage = OCMClassMock([ASDKCSRFTokenStorage class]);
    OCMStub([tokenStorage csrfTokenString]).andReturn(@"token");
    
    NSDictionary *cookieProperties = @{NSHTTPCookieName     : kASDKAPICSRFCookieName,
                                       NSHTTPCookieValue    : @"test",
                                       NSHTTPCookiePath     : @"/",
                                       NSHTTPCookieVersion  : @"0",
                                       NSHTTPCookieDomain   : @"localhost"};
    NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:cookieProperties];
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
    
    // when
    [self.genericNetworkService configureWithCSRFTokenStorage:tokenStorage];
    
    // then
    for (NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]) {
        if ([cookie.name isEqualToString:kASDKAPICSRFCookieName]) {
            if (![cookie.value isEqualToString:@"test"]) {
                XCTFail(@"Cookie value for CSRF doesn't match with expected value");
            }
        }
    }
}


#pragma mark -
#pragma mark Utils

- (NSData *)jsonTestData {
    return [NSJSONSerialization dataWithJSONObject:@{@"foo": @"bar"}
                                           options:(NSJSONWritingOptions)0
                                             error:nil];
}

- (void)deleteAllCookies {
    for (NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]) {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
    }
}

@end

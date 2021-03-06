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

@interface ASDKRequestOperationManagerTest : ASDKBaseTest

@property (strong, nonatomic) ASDKRequestOperationManager *requestOperationManager;

@end

@implementation ASDKRequestOperationManagerTest

- (void)setUp {
    [super setUp];
    
    NSString *hostAddress = @"localhost";
    NSString *serviceDocumentPath = @"activiti-app";
    NSString *port = @"9999";
    BOOL overSecureLayer = NO;
    
    ASDKServicePathFactory *servicePathFactory = [[ASDKServicePathFactory alloc] initWithHostAddress:hostAddress
                                                                                 serviceDocumentPath:serviceDocumentPath
                                                                                                port:port
                                                                                     overSecureLayer:overSecureLayer];
    
    id credential = OCMClassMock([ASDKModelCredentialBaseAuth class]);
    
    self.requestOperationManager = [[ASDKRequestOperationManager alloc] initWithBaseURL:servicePathFactory.baseURL
                                                                             credential:credential];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testThatItConfiguresRequestOperationManager {
    // given
    NSString *hostnameAddress = @"http://localhost:9999";
    NSURL *baseURL = [NSURL URLWithString:@"activiti-app" relativeToURL:
                      [NSURL URLWithString:[hostnameAddress stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]]];
    
    // then
    XCTAssertTrue([self isURL:self.requestOperationManager.baseURL
              equivalentToURL:baseURL]);
}

- (void)testThatItReplacesAuthenticationProvider {
    // given
    ASDKModelCredentialBaseAuth *credential = [[ASDKModelCredentialBaseAuth alloc] initWithUsername:@"test"
                                                                 password:@"test"];
    
    // when
    [self.requestOperationManager updateCredential:credential];
    
    // then
    NSDictionary *httpRequestHeaders = self.requestOperationManager.requestSerializer.HTTPRequestHeaders;

    XCTAssertEqualObjects(httpRequestHeaders[@"Authorization"], @"Basic dGVzdDp0ZXN0");
}

@end

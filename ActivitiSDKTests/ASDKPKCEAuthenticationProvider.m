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

@interface ASDKPKCEAuthentificationProviderTest : ASDKBaseTest

@end

@implementation ASDKPKCEAuthentificationProviderTest

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testThatItConfiguresProviderWithBasicAuthentication {
    // given
    ASDKModelCredentialAIMS *credential = [[ASDKModelCredentialAIMS alloc] initWithTokenType:@""
                                                                                 accessToken:@"123456789"
                                                                        accessTokenExpiresIn:0
                                                                                refreshToken:@""
                                                                       refreshTokenExpiresIn:0
                                                                                sessionState:@""];
    ASDKPKCEAuthenticationProvider *pkceAuthentication = [[ASDKPKCEAuthenticationProvider alloc] initWithCredential:credential];
    
    // then
    XCTAssertTrue([[pkceAuthentication valueForHTTPHeaderField:@"Authorization"] isEqualToString:@"Bearer 123456789"]);
}

@end

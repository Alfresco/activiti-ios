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

@interface ASDKCSRFTokenStorageTest : ASDKBaseTest

@property (strong, nonatomic) ASDKCSRFTokenStorage *tokenStorage;

@end

@implementation ASDKCSRFTokenStorageTest

- (void)setUp {
    [super setUp];
    
    self.tokenStorage = [ASDKCSRFTokenStorage new];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testThatItCreatesCSRFToken {
    // given
    NSError *error = nil;
    NSString *tokenString = [self.tokenStorage csrfTokenString];
    
    // when
    NSRegularExpression *tokenRegex = [NSRegularExpression regularExpressionWithPattern:@"[^a-zA-Z0-9]"
                                                                                options:NSRegularExpressionCaseInsensitive
                                                                                  error:&error];
    NSUInteger invalidCharacterMatchesCount = [tokenRegex numberOfMatchesInString:tokenString
                                                                          options:NSMatchingReportCompletion
                                                                            range:NSMakeRange(0, tokenString.length)];
    
    // then
    XCTAssertTrue(tokenString.length == 34 &&
                  !invalidCharacterMatchesCount);
}

- (void)testThatItReturnsCachedCSRFToken {
    // given
    NSString *csrfTokenString = [self.tokenStorage csrfTokenString];
    
    // when
    NSString *cachedCSRFTokenString = [self.tokenStorage csrfTokenString];
    
    // then
    XCTAssertTrue([csrfTokenString isEqualToString:cachedCSRFTokenString]);
}

- (void)testThatItRandomizesCSRFToken {
    // given
    NSString *csrfTokenString = [self.tokenStorage csrfTokenString];
    
    // when
    NSString *randomizedCSRFTokenString = [self.tokenStorage randomizeCSRFToken];
    
    // then
    XCTAssertFalse([csrfTokenString isEqualToString:randomizedCSRFTokenString]);
}

@end

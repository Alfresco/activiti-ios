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

@interface ASDKMantleJSONAdapterCustomPolicyTest : ASDKBaseTest

@end

@implementation ASDKMantleJSONAdapterCustomPolicyTest

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testThatItExcludesPropertiesWithCustomPolicyBlock {
    // given
    NSDictionary *dictionaryRepresentationForModel = @{@"foo" : @"bar",
                                                       @"someNilProperty": [NSNull null],
                                                       @"zeroProperty": @(0)};
    id model = OCMProtocolMock(@protocol(MTLJSONSerializing));
    OCMStub([model dictionaryValue]).andReturn(dictionaryRepresentationForModel);
    
    ASDKMantleJSONAdapterCustomPolicy *jsonAdapter = [[ASDKMantleJSONAdapterCustomPolicy alloc] initWithModelClass:model];
    jsonAdapter.policyBlock = ^(id value, NSString *key) {
        if ([key isEqualToString:@"foo"]) {
            return YES;
        }
        
        return NO;
    };
    
    // when
    NSSet *filteredPropertySet = [jsonAdapter serializablePropertyKeys:[NSSet setWithObjects:@"foo", @"someNilProperty", @"zeroProperty", nil]
                                                              forModel:model];
    
    // then
    XCTAssert(filteredPropertySet.count == 2, @"Unexpected number of elements that have been filtered");
}

@end

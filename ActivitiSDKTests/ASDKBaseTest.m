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

@implementation ASDKBaseTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

#pragma mark -
#pragma mark Public interface

- (NSURL *)baseURL {
    return [NSURL URLWithString:@"https://httpbin.org"];
}

- (BOOL)isURL:(NSURL *)firstURL equivalentToURL:(NSURL *)secondURL {
    if ([firstURL isEqual:secondURL]) {
        return YES;
    }
    if ([firstURL.scheme caseInsensitiveCompare:secondURL.scheme] != NSOrderedSame) {
        return NO;
    }
    if ([firstURL.host caseInsensitiveCompare:secondURL.host] != NSOrderedSame) {
        return NO;
    }
    if ([firstURL.path compare:secondURL.path] != NSOrderedSame) {
        return NO;
    }
    if (firstURL.port || secondURL.port) {
        if (![firstURL.port isEqual:secondURL.port]) {
            return NO;
        }
        if (firstURL.query || secondURL.query) {
            if (![firstURL.query isEqual:secondURL.query]) {
                return NO;
            }
        }
    }
    
    return YES;
}

- (NSData *)createRandomNSDataOfSize:(NSUInteger)byteSize {
    NSMutableData* theData = [NSMutableData dataWithCapacity:byteSize];
    for( unsigned int idx = 0; idx < byteSize/4; ++idx)
    {
        u_int32_t randomBits = arc4random();
        [theData appendBytes:(void*)&randomBits
                      length:4];
    }
    return theData;
}

- (NSDictionary *)contentDictionaryFromJSON:(NSString *)jsonFileName {
    NSError *error = nil;
    NSString *filePath = [[NSBundle bundleForClass:[self class]] pathForResource:jsonFileName ofType:@"json"];
    NSData *jsonData = [[NSData alloc] initWithContentsOfFile:filePath];
    NSDictionary *response = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:jsonData
                                                                             options:NSJSONReadingMutableContainers
                                                                               error:&error];
    
    return response;
}

@end

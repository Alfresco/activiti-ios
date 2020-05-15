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

#import "ASDKCSRFTokenStorage.h"

#define ASCII_START_NUMERS 0x30
#define ASCII_END_NUMERS 0x39

#define ASCII_START_LETTERS_A 0x41
#define ASCII_END_LETTERS_Z 0x5A

#define ASCII_START_LETTERS_a 0x61
#define ASCII_END_LETTERS_z 0x5A

#define CSRF_TOKEN_LENGTH 34

@interface ASDKCSRFTokenStorage ()

@property (strong, nonatomic) NSString *cachedCSRFToken;

@end

@implementation ASDKCSRFTokenStorage


#pragma mark -
#pragma mark Public API

- (NSString *)csrfTokenString {
    if (!_cachedCSRFToken) {
        _cachedCSRFToken = [self secureRandomTokenForLength:CSRF_TOKEN_LENGTH];
    }
    
    return self.cachedCSRFToken;
}

- (NSString *)randomizeCSRFToken {
    _cachedCSRFToken = [self secureRandomTokenForLength:CSRF_TOKEN_LENGTH];
    return _cachedCSRFToken;
}


#pragma mark -
#pragma mark Private API

- (NSString *)secureRandomTokenForLength:(int)length {
    NSMutableString *result = [NSMutableString string];
    while (result.length != length) {
        NSMutableData *data = [NSMutableData dataWithLength:1];
        if (!SecRandomCopyBytes(kSecRandomDefault, 1, [data mutableBytes])) {
            Byte currentChar = 0;
            [data getBytes:&currentChar
                    length:1];
            NSString *temp = [[NSString alloc] initWithData:data
                                                   encoding:NSUTF8StringEncoding];
            if (currentChar > ASCII_START_NUMERS && currentChar < ASCII_END_NUMERS) { // 0 to 9
                [result appendString:temp];
                continue;
            }
            if (currentChar > ASCII_START_LETTERS_A && currentChar < ASCII_END_LETTERS_Z) { // A to Z
                [result appendString:temp];
                continue;
            }
            if (currentChar > ASCII_START_LETTERS_a && currentChar < ASCII_END_LETTERS_z) { // a to z
                [result appendString:temp];
                continue;
            }
        } else {
            break;
        }
    }
    return result;
}

@end

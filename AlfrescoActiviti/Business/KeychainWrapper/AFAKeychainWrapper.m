/*******************************************************************************
 * Copyright (C) 2005-2018 Alfresco Software Limited.
 *
 * This file is part of the Alfresco Activiti Mobile iOS App.
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

#import "AFAKeychainWrapper.h"
#import <UIKit/UIKit.h>
#import <Security/Security.h>
#import <CommonCrypto/CommonHMAC.h>
#import "AFALogConfiguration.h"

static const int activitiLogLevel = AFA_LOG_LEVEL_VERBOSE; // | AFA_LOG_FLAG_TRACE;

// Cryptographic salt parametere value
#define SALT_KEY @"R7(tt0bT8xpBs]RtYHJjsG')FP]1N8wN.~wJ84O0?73940zY^blSzs843&Rdqe5"

// String constants
NSString *uuidKeychainIdentifier = @"uuidKeychainIdentifier";

@implementation AFAKeychainWrapper

#pragma mark - 
#pragma mark Hashing functions

+ (NSString *)securedSHA256DigestHashForStringHash:(NSUInteger)stringHash {
    NSString *computedHashString = [NSString stringWithFormat:@"%lu%@%@", (unsigned long)stringHash, SALT_KEY, [self uuidString]];
    
    return [self computeSHA256DigestForString:computedHashString];
}

+ (NSString*)computeSHA256DigestForString:(NSString*)input {
    const char *cstr = [input cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:input.length];
    uint8_t digest[CC_SHA256_DIGEST_LENGTH];
    
    // It takes in the data, how much data, and then output format, which in this case is an int array.
    CC_SHA256(data.bytes, (unsigned int)data.length, digest);
    
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
    
    // Parse through the CC_SHA256 results (stored inside of digest[]).
    for(int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", digest[i]];
    }
    
    return output;
}

#pragma mark -
#pragma mark Keychain utility methods

+ (BOOL)createKeychainData:(NSData *)data
             forIdentifier:(NSString *)identifier {
    NSMutableDictionary *dictionary = [self keychainAccessAttributesDictionaryForIdentifier:identifier];
    [dictionary setObject:data
                   forKey:(__bridge id)kSecValueData];
    
    // Protect the keychain entry so it's only valid when the device is unlocked.
    [dictionary setObject:(__bridge id)kSecAttrAccessibleWhenUnlocked
                   forKey:(__bridge id)kSecAttrAccessible];
    
    // Add.
    OSStatus status = SecItemAdd((__bridge CFDictionaryRef)dictionary, NULL);
    
    // If the addition was successful, return. Otherwise, attempt to update existing key or quit (return NO).
    if (status == errSecSuccess) {
        AFALogVerbose(@"Added value to Keychain for identifier:%@", identifier);
        return YES;
    } else if (status == errSecDuplicateItem){
        return [self updateKeychainData:data
                          forIdentifier:identifier];
    } else {
        AFALogError(@"Cannot add value to Keychain for identifier:%@", identifier);
        return NO;
    }
}

+ (BOOL)createKeychainValue:(NSString *)value
              forIdentifier:(NSString *)identifier {
    NSData *valueData = [value dataUsingEncoding:NSUTF8StringEncoding];
    return [self createKeychainData:valueData
                      forIdentifier:identifier];
}

+ (BOOL)updateKeychainData:(NSData *)data
             forIdentifier:(NSString *)identifier {
    NSMutableDictionary *searchDictionary = [self keychainAccessAttributesDictionaryForIdentifier:identifier];
    NSMutableDictionary *updateDictionary = [[NSMutableDictionary alloc] init];
    [updateDictionary setObject:data forKey:(__bridge id)kSecValueData];
    
    // Update.
    OSStatus status = SecItemUpdate((__bridge CFDictionaryRef)searchDictionary,
                                    (__bridge CFDictionaryRef)updateDictionary);
    
    if (status == errSecSuccess) {
        AFALogVerbose(@"Updated value in Keychain for identifier:%@", identifier);
        return YES;
    } else {
        AFALogError(@"Cannot update value in Keychain for identifier:%@", identifier);
        return NO;
    }
}

+ (BOOL)updateKeychainValue:(NSString *)value
              forIdentifier:(NSString *)identifier {
    NSData *valueData = [value dataUsingEncoding:NSUTF8StringEncoding];
    return [self updateKeychainData:valueData
                      forIdentifier:identifier];
}

+ (void)deleteItemFromKeychainWithIdentifier:(NSString *)identifier {
    NSMutableDictionary *searchDictionary = [self keychainAccessAttributesDictionaryForIdentifier:identifier];
    CFDictionaryRef dictionary = (__bridge CFDictionaryRef)searchDictionary;
    
    //Delete.
    SecItemDelete(dictionary);
    
    AFALogVerbose(@"Deleted value in Keychain for identifier:%@", identifier);
}

+ (NSString *)keychainStringFromMatchingIdentifier:(NSString *)identifier {
    NSData *valueData = [self searchKeychainCopyMatchingIdentifier:identifier];
    if (valueData) {
        NSString *value = [[NSString alloc] initWithData:valueData
                                                encoding:NSUTF8StringEncoding];
        return value;
    } else {
        return nil;
    }
}

+ (NSData *)dataForMatchingIdentifier:(NSString *)identifier {
    return [self searchKeychainCopyMatchingIdentifier:identifier];
}


#pragma mark - 
#pragma mark Utilities

+ (NSMutableDictionary *)keychainAccessAttributesDictionaryForIdentifier:(NSString *)identifier {
    // Setup dictionary to access keychain.
    NSMutableDictionary *searchDictionary = [[NSMutableDictionary alloc] init];
    // Specify we are using a password (rather than a certificate, internet password, etc).
    [searchDictionary setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
    // Uniquely identify this keychain accessor.
    [searchDictionary setObject:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"]
                         forKey:(__bridge id)kSecAttrService];
    // Uniquely identify the account who will be accessing the keychain.
    NSData *encodedIdentifier = [identifier dataUsingEncoding:NSUTF8StringEncoding];
    [searchDictionary setObject:encodedIdentifier forKey:(__bridge id)kSecAttrGeneric];
    [searchDictionary setObject:encodedIdentifier forKey:(__bridge id)kSecAttrAccount];
    
    return searchDictionary;
}

+ (NSData *)searchKeychainCopyMatchingIdentifier:(NSString *)identifier {
    if (!identifier.length) {
        return nil;
    }
    
    NSMutableDictionary *searchDictionary = [self keychainAccessAttributesDictionaryForIdentifier:identifier];
    // Limit search results to one.
    [searchDictionary setObject:(__bridge id)kSecMatchLimitOne forKey:(__bridge id)kSecMatchLimit];
    
    // Specify we want NSData/CFData returned.
    [searchDictionary setObject:(__bridge id)kCFBooleanTrue forKey:(__bridge id)kSecReturnData];
    
    // Search.
    NSData *result = nil;
    CFTypeRef foundDict = NULL;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)searchDictionary, &foundDict);
    
    if (status == noErr) {
        result = (__bridge_transfer NSData *)foundDict;
    } else {
        result = nil;
    }
    
    return result;
}

+ (NSString *)uuidString {
    NSString *uuidString = nil;
    if (!(uuidString = [self keychainStringFromMatchingIdentifier:uuidKeychainIdentifier])) {
        uuidString = [[NSUUID UUID] UUIDString];
        [self createKeychainValue:uuidString forIdentifier:uuidKeychainIdentifier];
    }
    
    return uuidString;
}


@end

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

#import <Foundation/Foundation.h>

/**
 *  The purpose of this class is to offer a safe way to persist credential or sensitive 
 *  data to Keychain. Every piece of information that is registered cand be wrapped 
 *  using the securedSHA256DigestHashForStringHash method to be hashed in adance so that a
 *  jailbroken device wouldn't spit out the plain username and password for example.
 */
@interface AFAKeychainWrapper : NSObject

// Hashing functions

/*
 * Returns a string constructed by this formula SHA256(HASH(inputString) + SALT + UUID)
 */
+ (NSString *)securedSHA256DigestHashForStringHash:(NSUInteger)stringHash;


// Keychain access methods

/*
* Persist a data structure in the keychain for a given identifier
*/
+ (BOOL)createKeychainData:(NSData *)data
             forIdentifier:(NSString *)identifier;

/*
 * Persist a value in the keychain for a given identifier
 */
+ (BOOL)createKeychainValue:(NSString *)value
              forIdentifier:(NSString *)identifier;

/*
* Updates the data structure in keychain for a given identifier
*/
+ (BOOL)updateKeychainData:(NSData *)data
             forIdentifier:(NSString *)identifier;

/*
 * Updates the value in keychain for a given identifier
 */
+ (BOOL)updateKeychainValue:(NSString *)value
              forIdentifier:(NSString *)identifier;

/*
 * Deletes the item in keychain for a given identifier
 */
+ (void)deleteItemFromKeychainWithIdentifier:(NSString *)identifier;

/*
 * Search the keychain value for a given identifier
 */
+ (NSString *)keychainStringFromMatchingIdentifier:(NSString *)identifier;

/*
* Search data structure in keychain for a given identifier
*/
+ (NSData *)dataForMatchingIdentifier:(NSString *)identifier;

@end

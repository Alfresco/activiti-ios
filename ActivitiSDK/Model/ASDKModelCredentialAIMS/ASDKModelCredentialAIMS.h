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

#import "ASDKModelCredentialBaseProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface ASDKModelCredentialAIMS : NSObject <ASDKModelCredentialBaseProtocol>

@property (strong, nonatomic, readonly) NSString       *tokenType;
@property (strong, nonatomic, readonly) NSString       *accessToken;
@property (assign, nonatomic, readonly) NSTimeInterval accessTokenExpiresIn;
@property (strong, nonatomic, readonly) NSString       *refreshToken;
@property (assign, nonatomic, readonly) NSTimeInterval refreshTokenExpiresIn;
@property (strong, nonatomic, readonly) NSString       *sessionState;

- (instancetype)initWithTokenType:(NSString *)tokenType
                      accessToken:(NSString *)accessToken
             accessTokenExpiresIn:(NSTimeInterval)accessTokenExpiresIn
                     refreshToken:(NSString *)refreshToken
            refreshTokenExpiresIn:(NSTimeInterval)refreshTokenExpiresIn
                     sessionState:(NSString *)sessionState;

- (NSDictionary *)decodedJWTPayloadToken;

@end

NS_ASSUME_NONNULL_END

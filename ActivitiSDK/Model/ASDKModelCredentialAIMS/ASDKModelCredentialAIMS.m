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

#import "ASDKModelCredentialAIMS.h"
#import "ASDKNetworkServiceConstants.h"

// Managers
@import JWT;


@implementation ASDKModelCredentialAIMS

- (instancetype)initWithTokenType:(NSString *)tokenType
                      accessToken:(NSString *)accessToken
             accessTokenExpiresIn:(NSTimeInterval)accessTokenExpiresIn
                     refreshToken:(NSString *)refreshToken
            refreshTokenExpiresIn:(NSTimeInterval)refreshTokenExpiresIn
                     sessionState:(NSString *)sessionState {
    self = [super init];
    
    if (self) {
        _tokenType = tokenType;
        _accessToken = accessToken;
        _accessTokenExpiresIn = accessTokenExpiresIn;
        _refreshToken = refreshToken;
        _refreshTokenExpiresIn = refreshTokenExpiresIn;
        _sessionState = sessionState;
    }
    
    return self;
}

- (NSString *)authorizationHeaderValue {
    return [NSString stringWithFormat:@"Bearer %@", self.accessToken];
}

- (BOOL)areCredentialValid {
    NSDate *tokenExpireDate = [NSDate dateWithTimeIntervalSince1970:_accessTokenExpiresIn];
    //Substract sessionExpirationTimeIntervalCheck time
    NSDate *currentDateThreshold = [tokenExpireDate dateByAddingTimeInterval:-kASDKSessionExpirationTimeIntervalCheck];
    
    if ([NSDate.date compare:currentDateThreshold] == NSOrderedDescending ||
        [NSDate.date compare:tokenExpireDate] == NSOrderedDescending) {
        return NO;
    }
    
    return YES;
}

- (NSDictionary *)decodedJWTPayloadToken {
    BOOL decodeForced = YES;
    NSNumber *options = @(decodeForced);
    NSString *jwtToken = _accessToken;

    JWTBuilder *decodeBuilder = [JWT decodeMessage:jwtToken];
    NSDictionary *decodedResult = decodeBuilder.message(jwtToken).options(options).decode;
    
    return decodedResult;
}

@end

/*******************************************************************************
 * Copyright (C) 2005-2020 Alfresco Software Limited.
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
#import "AFABaseModel.h"
#import "AFAProfileServices.h"

typedef void  (^AFALoginModelCompletionBlock) (BOOL isLoggedIn, NSError *error);

typedef NS_ENUM(NSInteger, AFALoginAuthenticationType) {
    AFALoginAuthenticationTypeCloud,
    AFALoginAuthenticationTypePremise
};

typedef NS_ENUM(NSUInteger, AFALoginAuthenticationState) {
    AFALoginAuthenticationStatePreparing,
    AFALoginAuthenticationStateInProgress,
    AFALoginAuthenticationStateAuthorized,
    AFALoginAuthenticationStateFailed,
    AFALoginAuthenticationStateCanceled,
    AFALoginAuthenticationStateLoggedOut
};

@interface AFALoginViewModel : AFABaseModel

@property (strong, nonatomic) NSAttributedString            *usernameAttributedPlaceholderText;
@property (strong, nonatomic) NSAttributedString            *passwordAttributedPlaceholderText;
@property (strong, nonatomic) NSAttributedString            *hostnameAttributedPlaceholderText;
@property (strong, nonatomic) NSAttributedString            *portAttributedPlaceholderText;
@property (strong, nonatomic) NSAttributedString            *serviceDocumentAttributedPlaceholderText;
@property (assign, nonatomic) BOOL                          isCredentialInputInProgress;
@property (strong, nonatomic, readonly) NSString            *hostName;
@property (strong, nonatomic, readonly) NSString            *username;
@property (strong, nonatomic, readonly) NSString            *password;
@property (strong, nonatomic, readonly) NSString            *port;
@property (strong, nonatomic, readonly) NSString            *serviceDocument;
@property (assign, nonatomic, readonly) BOOL                isSecureLayer;
@property (assign, nonatomic, readonly) BOOL                rememberCredentials;
@property (assign, nonatomic) AFALoginAuthenticationState   authState;
@property (assign, nonatomic) AFALoginAuthenticationType    authentificationType;
@property (strong, nonatomic, readonly) ASDKModelServerConfiguration *serverConfiguration;

- (void)updateHostNameEntry:(NSString *)hostname;
- (void)updateUserNameEntry:(NSString *)username;
- (void)updatePasswordEntry:(NSString *)password;
- (void)updatePortEntry:(NSString *)port;
- (void)updateServiceDocument:(NSString *)serviceDocument;
- (void)updateRememberCredentials:(BOOL)rememberCredentials;
- (void)updateCommunicationOverSecureLayer:(BOOL)secureLayer;

- (BOOL)canUserSignIn;
- (void)requestLoginWithCompletionBlock:(AFALoginModelCompletionBlock)completionBlock;
- (void)requestLogout;
- (void)requestLogoutForUnauthorizedAccess;
- (void)cancelLoginRequest;
- (NSString *)persistenceStackModelName;
- (void)restoreLastSuccessfullSessionLoginCredentialsForType:(AFALoginAuthenticationType)authenticationType;

+ (AFALoginAuthenticationType)lastAuthenticationType;

@end

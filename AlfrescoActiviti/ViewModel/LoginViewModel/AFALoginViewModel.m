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

#import "AFALoginViewModel.h"

// Constants
#import "AFALocalizationConstants.h"
#import "AFABusinessConstants.h"

// Categories
#import "UIColor+AFATheme.h"

// Models
#import "AFACredentialModel.h"

// Managers
#import "AFAServiceRepository.h"
#import "AFAKeychainWrapper.h"
@import ActivitiSDK;
@import ActivitiSDK.Private;

@interface AFALoginViewModel ()

@property (strong, nonatomic) AFACredentialModel *credentialModel;

// Services
@property (strong, nonatomic) AFAProfileServices        *requestProfileService;
@property (strong, nonatomic) ASDKReachabilityManager   *reachabilityManager;

@end

@implementation AFALoginViewModel


#pragma mark -
#pragma mark Life cycle

- (instancetype)init {
    self = [super init];
    
    if (self) {
        NSDictionary *placeholderAttributes = @{NSForegroundColorAttributeName : [UIColor placeholderColorForCredentialTextField]};
        
        _usernameAttributedPlaceholderText = [[NSAttributedString alloc] initWithString:NSLocalizedString(kLocalizationLoginUsernamePlaceholderText, @"Username placeholder text")
                                                                             attributes:placeholderAttributes];
        _passwordAttributedPlaceholderText = [[NSAttributedString alloc] initWithString:NSLocalizedString(kLocalizationLoginPasswordPlaceholderText, @"Password placeholder text")
                                                                             attributes:placeholderAttributes];
        _hostnameAttributedPlaceholderText = [[NSAttributedString alloc] initWithString:NSLocalizedString(kLocalizationLoginHostnamePlaceholderText, @"Hostname placeholder text")
                                                                             attributes:placeholderAttributes];
        _portAttributedPlaceholderText = [[NSAttributedString alloc] initWithString:NSLocalizedString(kLocalizationLoginPortPlaceholderText, @"Port placeholder text")
                                                                         attributes:placeholderAttributes];
        _serviceDocumentAttributedPlaceholderText = [[NSAttributedString alloc] initWithString:NSLocalizedString(kLocalizationLoginServiceDocumentPlaceholderText, @"Document placeholder text")
                                                                                    attributes:placeholderAttributes];
        _credentialModel = [AFACredentialModel new];
        _credentialModel.serviceDocument = kASDKAPIApplicationPath;
        
        _requestProfileService = [AFAProfileServices new];
        _reachabilityManager = [ASDKReachabilityManager new];
    }
    
    return self;
}


#pragma mark -
#pragma mark Getters

- (NSString *)hostName {
    return self.credentialModel.hostname;
}

- (NSString *)username {
    return self.credentialModel.username;
}

- (NSString *)password {
    return self.credentialModel.password;
}

- (NSString *)port {
    return self.credentialModel.port;
}

- (NSString *)serviceDocument {
    return self.credentialModel.serviceDocument;
}

- (BOOL)isSecureLayer {
    return self.credentialModel.isCommunicationOverSecureLayer;
}

- (BOOL)rememberCredentials {
    return self.credentialModel.rememberCredentials;
}

- (ASDKModelServerConfiguration *)serverConfiguration {
    return self.credentialModel.serverConfiguration;
}


#pragma mark -
#pragma mark Public interface

- (void)updateHostNameEntry:(NSString *)hostname {
    self.credentialModel.hostname = hostname;
}

- (void)updateUserNameEntry:(NSString *)username {
    self.credentialModel.username = username;
}

- (void)updatePasswordEntry:(NSString *)password {
    self.credentialModel.password = password;
}

- (void)updateRememberCredentials:(BOOL)rememberCredentials {
    self.credentialModel.rememberCredentials = rememberCredentials;
}

- (void)updatePortEntry:(NSString *)port {
    self.credentialModel.port = port;
}

- (void)updateServiceDocument:(NSString *)serviceDocument {
    self.credentialModel.serviceDocument = serviceDocument;
}

- (void)updateCommunicationOverSecureLayer:(BOOL)secureLayer {
    self.credentialModel.isCommunicationOverSecureLayer = secureLayer;
}

- (BOOL)canUserSignIn {
    return self.credentialModel.hostname.length &&
    self.credentialModel.username.length &&
    self.credentialModel.password.length &&
    self.credentialModel.serviceDocument.length;
}

- (void)requestLoginWithCompletionBlock:(AFALoginModelCompletionBlock)completionBlock {
    // Authorization in progress
    self.authState = AFALoginAuthenticationStateInProgress;
    
    // Initiate the Activiti SDK bootstrap with the given server configuration
    ASDKModelServerConfiguration *serverConfiguration = self.credentialModel.serverConfiguration;
    ASDKModelCredentialBaseAuth *baseAuthCredential = nil;
    if ([serverConfiguration.credential isKindOfClass:ASDKModelCredentialBaseAuth.class]) {
        baseAuthCredential = serverConfiguration.credential;
    }
    
    ASDKBootstrap *sdkBootstrap = [ASDKBootstrap sharedInstance];
    [sdkBootstrap setupServicesWithServerConfiguration:serverConfiguration];
    NSString *persistenceStackModelName = [self persistenceStackModelName];
    NSString *offlinePersistenceStackModelName = [self offlinePersistenceStackModelName];
    
    __weak typeof(self) weakSelf = self;
    void (^errorHandlingBlock)(NSError *) = ^(NSError *error) {
        __strong typeof(self) strongSelf = weakSelf;
        
        // An error occured
        strongSelf.authState = AFALoginAuthenticationStateFailed;
        completionBlock(NO, error);
    };
    
    [self.requestProfileService requestProfileWithCompletionBlock:^(ASDKModelProfile *profile, NSError *error) {
        __strong typeof(self) strongSelf = weakSelf;
        
        // Check first if the request wasn't previously canceled or verified with cached values
        if (AFALoginAuthenticationStateCanceled != strongSelf.authState &&
            AFALoginAuthenticationStatePreparing != strongSelf.authState &&
            AFALoginAuthenticationStateAuthorized != strongSelf.authState) {
            if (!error && profile) {
                // Login is successfull - Check whether the user has choosen to remember credentials
                // and store them in the keychain
                if (strongSelf.credentialModel.rememberCredentials) {
                    
                    // Store in the user defaults details of the current login
                    [strongSelf synchronizeToUserDefaultsServerConfiguration:serverConfiguration];
                    
                    // Former credentials are registered, will update them
                    if ([AFAKeychainWrapper keychainStringFromMatchingIdentifier:persistenceStackModelName]) {
                        [AFAKeychainWrapper updateKeychainValue:baseAuthCredential.password
                                                  forIdentifier:persistenceStackModelName];
                    } else { // Insert new values in the keychain
                        [AFAKeychainWrapper createKeychainValue:baseAuthCredential.password
                                                  forIdentifier:persistenceStackModelName];
                    }
                    
                    // Store credentials to match checks when offline
                    if ([AFAKeychainWrapper keychainStringFromMatchingIdentifier:offlinePersistenceStackModelName]) {
                        [AFAKeychainWrapper updateKeychainValue:baseAuthCredential.password
                                                  forIdentifier:offlinePersistenceStackModelName];
                    } else {
                        [AFAKeychainWrapper createKeychainValue:baseAuthCredential.password
                                                  forIdentifier:offlinePersistenceStackModelName];
                    }
                }
                
                strongSelf.authState = AFALoginAuthenticationStateAuthorized;
                completionBlock(YES, nil);
            } else {
                errorHandlingBlock(error);
            }
        }
    } cachedResults:^(ASDKModelProfile *profile, NSError *error) {
        __strong typeof(self) strongSelf = weakSelf;
        
        if (ASDKNetworkReachabilityStatusReachableViaWWANOrWifi != [strongSelf.reachabilityManager requestInitialReachabilityStatus]) {
            // Check first if the request wasn't previously canceled
            if (AFALoginAuthenticationStateCanceled != strongSelf.authState &&
                AFALoginAuthenticationStatePreparing != strongSelf.authState) {
                if (!error && profile) {
                    // Store in the user defaults details of the current login
                    [strongSelf synchronizeToUserDefaultsServerConfiguration:serverConfiguration];
                    
                    if ([[AFAKeychainWrapper keychainStringFromMatchingIdentifier:offlinePersistenceStackModelName] isEqualToString:baseAuthCredential.password]) {
                        strongSelf.authState = AFALoginAuthenticationStateAuthorized;
                        completionBlock(YES, nil);
                    } else {
                        NSError *invalidCredentialsError = [NSError errorWithDomain:AFALoginViewModelErrorDomain
                                                                               code:kAFALoginViewModelInvalidCredentialErrorCode
                                                                           userInfo:nil];
                        errorHandlingBlock(invalidCredentialsError);
                    }
                } else {
                    errorHandlingBlock(error);
                }
            }
        }
    }];
}

- (void)requestLogout {
    [AFAKeychainWrapper deleteItemFromKeychainWithIdentifier:[self persistenceStackModelName]];
    
    for (NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]) {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
    }
    
    self.authState = AFALoginAuthenticationStateLoggedOut;
}

- (void)requestLogoutForUnauthorizedAccess {
    [AFAKeychainWrapper deleteItemFromKeychainWithIdentifier:[self offlinePersistenceStackModelName]];
    [self requestLogout];
}

- (void)cancelLoginRequest {
    // If user performed an action, meaning the authorization state changes
    // from preparing state then cancel the authorization
    if (AFALoginAuthenticationStatePreparing != self.authState) {
        self.authState = AFALoginAuthenticationStateCanceled;
    }
    
    // Cancel also the request
    [self.requestProfileService cancellProfileNetworkRequests];
}

- (NSString *)persistenceStackModelName {
    return [ASDKPersistenceStack persistenceStackModelNameForServerConfiguration:self.credentialModel.serverConfiguration];
}

- (NSString *)offlinePersistenceStackModelName {
    return [NSString stringWithFormat:@"%@-offline", [self persistenceStackModelName]];
}

+ (AFALoginAuthenticationType)lastAuthenticationType {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *authenticationIdentifier = [userDefaults objectForKey:kAuthentificationTypeCredentialIdentifier];
    AFALoginAuthenticationType lastAuthenticationType = [authenticationIdentifier isEqualToString:kCloudAuthetificationCredentialIdentifier] ? AFALoginAuthenticationTypeCloud : AFALoginAuthenticationTypePremise;
    
    return lastAuthenticationType;
}

- (void)restoreLastSuccessfullSessionLoginCredentialsForType:(AFALoginAuthenticationType)authenticationType {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    if (AFALoginAuthenticationTypeCloud == authenticationType) {
        self.authentificationType = AFALoginAuthenticationTypeCloud;
        [self updateHostNameEntry:[userDefaults objectForKey:kCloudHostNameCredentialIdentifier]];
        [self updateCommunicationOverSecureLayer:[userDefaults boolForKey:kCloudSecureLayerCredentialIdentifier]];
        [self updateUserNameEntry:[userDefaults objectForKey:kCloudUsernameCredentialIdentifier]];
        [self updatePasswordEntry:[AFAKeychainWrapper keychainStringFromMatchingIdentifier:[self persistenceStackModelName]]];
    } else {
        self.authentificationType = AFALoginAuthenticationTypePremise;
        [self updateHostNameEntry:[userDefaults objectForKey:kPremiseHostNameCredentialIdentifier]];
        [self updateCommunicationOverSecureLayer:[userDefaults boolForKey:kPremiseSecureLayerCredentialIdentifier]];
        NSString *cachedPortString = [userDefaults objectForKey:kPremisePortCredentialIdentifier];
        if (!cachedPortString.length) {
            cachedPortString = [@(kDefaultLoginUnsecuredPort) stringValue];
        }
        [self updatePortEntry:cachedPortString];
        
        // If there is no stored value for the service document key, then fallback to the one provided inside the login model
        // at initialization time
        NSString *serviceDocumentValue = [userDefaults objectForKey:kPremiseServiceDocumentCredentialIdentifier];
        if (serviceDocumentValue.length) {
            [self updateServiceDocument:serviceDocumentValue];
        }
        
        [self updateUserNameEntry:[userDefaults objectForKey:kPremiseUsernameCredentialIdentifier]];
        [self updatePasswordEntry:[AFAKeychainWrapper keychainStringFromMatchingIdentifier:[self persistenceStackModelName]]];
    }
}


#pragma mark -
#pragma mark Private interface

- (void)synchronizeToUserDefaultsServerConfiguration:(ASDKModelServerConfiguration *)serverConfiguration {
    // Store in the user defaults which type of login is to be performed in the future
    NSString *currentAuthentificationIdentifier = (self.authentificationType == AFALoginAuthenticationTypeCloud) ? kCloudAuthetificationCredentialIdentifier : kPremiseAuthentificationCredentialIdentifier;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:currentAuthentificationIdentifier
                     forKey:kAuthentificationTypeCredentialIdentifier];
    
    ASDKModelCredentialBaseAuth *baseAuthCredential = nil;
    if ([serverConfiguration.credential isKindOfClass:ASDKModelCredentialBaseAuth.class]) {
        baseAuthCredential = serverConfiguration.credential;
    }
    
    
    if (AFALoginAuthenticationTypeCloud == self.authentificationType) {
        [userDefaults setObject:serverConfiguration.hostAddressString
                         forKey:kCloudHostNameCredentialIdentifier];
        [userDefaults setBool:serverConfiguration.isCommunicationOverSecureLayer
                       forKey:kCloudSecureLayerCredentialIdentifier];
        [userDefaults setObject:baseAuthCredential.username
                         forKey:kCloudUsernameCredentialIdentifier];
    } else {
        [userDefaults setObject:serverConfiguration.hostAddressString
                         forKey:kPremiseHostNameCredentialIdentifier];
        [userDefaults setObject:serverConfiguration.serviceDocument
                         forKey:kPremiseServiceDocumentCredentialIdentifier];
        [userDefaults setBool:serverConfiguration.isCommunicationOverSecureLayer
                       forKey:kPremiseSecureLayerCredentialIdentifier];
        [userDefaults setObject:baseAuthCredential.username
                         forKey:kPremiseUsernameCredentialIdentifier];
        if (serverConfiguration.port.length) {
            [userDefaults setObject:serverConfiguration.port
                             forKey:kPremisePortCredentialIdentifier];
        }
    }
    [userDefaults synchronize];
}

@end

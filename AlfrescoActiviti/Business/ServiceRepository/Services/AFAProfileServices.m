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

#import "AFAProfileServices.h"

// Constants
#import "AFABusinessConstants.h"

// Configurations
#import "AFALogConfiguration.h"

// Managers
#import "AFAKeychainWrapper.h"
@import ActivitiSDK;

static const int activitiLogLevel = AFA_LOG_LEVEL_VERBOSE; // | AFA_LOG_FLAG_TRACE;

@interface AFAProfileServices () <ASDKDataAccessorDelegate>

// Current profile
@property (strong, nonatomic) ASDKProfileDataAccessor                       *fetchCurrentProfileDataAccessor;
@property (copy, nonatomic) AFAProfileCompletionBlock                       currentProfileCompletionBlock;
@property (copy, nonatomic) AFAProfileCompletionBlock                       currentProfileCachedResultsBlock;

// Fetch current profile image
@property (strong, nonatomic) ASDKProfileDataAccessor                       *fetchCurrentProfileImageDataAccessor;
@property (copy, nonatomic) AFAProfileServicesProfileImageCompletionBlock   profileImageCompletionBlock;

// Update current profile
@property (strong, nonatomic) ASDKProfileDataAccessor                       *updateCurrentProfileDataAccessor;
@property (copy, nonatomic) AFAProfileCompletionBlock                       updateCurrentProfileCompletionBlock;

// Current profile password update
@property (strong, nonatomic) ASDKProfileDataAccessor                       *updateCurrentProfilePasswordDataAccessor;
@property (copy, nonatomic) AFAProfilePasswordCompletionBlock               updateProfilePasswordCompletionBlock;

// Upload current profile image
@property (strong, nonatomic) ASDKProfileDataAccessor                       *uploadCurrentProfileImageDataAccessor;
@property (copy, nonatomic) AFAProfileContentProgressBlock                  uploadCurrentProfileImageProgressBlock;
@property (copy, nonatomic) AFAProfileContentUploadCompletionBlock          uploadCurrentProfileImageCompletionBlock;

@end

@implementation AFAProfileServices


#pragma mark -
#pragma mark Public interface

- (void)requestProfileImageWithCompletionBlock:(AFAProfileServicesProfileImageCompletionBlock)completionBlock {
    NSParameterAssert(completionBlock);
    self.profileImageCompletionBlock = completionBlock;
    
    self.fetchCurrentProfileImageDataAccessor = [[ASDKProfileDataAccessor alloc] initWithDelegate:self];
    [self.fetchCurrentProfileImageDataAccessor fetchCurrentUserProfileImage];
}

- (void)requestProfileWithCompletionBlock:(AFAProfileCompletionBlock)completionBlock {
    [self requestProfileWithCompletionBlock:completionBlock
                              cachedResults:nil
                                cachePolicy:ASDKServiceDataAccessorCachingPolicyAPIOnly];
}

- (void)requestProfileWithCompletionBlock:(AFAProfileCompletionBlock)completionBlock
                            cachedResults:(AFAProfileCompletionBlock)cacheCompletionBlock {
    [self requestProfileWithCompletionBlock:completionBlock
                              cachedResults:cacheCompletionBlock
                                cachePolicy:ASDKServiceDataAccessorCachingPolicyHybrid];
}

- (void)requestProfileWithCompletionBlock:(AFAProfileCompletionBlock)completionBlock
                            cachedResults:(AFAProfileCompletionBlock)cacheCompletionBlock
                              cachePolicy:(ASDKServiceDataAccessorCachingPolicy)cachePolicy {
    NSParameterAssert(completionBlock);
    
    self.currentProfileCompletionBlock = completionBlock;
    self.currentProfileCachedResultsBlock = cacheCompletionBlock;
    
    self.fetchCurrentProfileDataAccessor = [[ASDKProfileDataAccessor alloc] initWithDelegate:self];
    self.fetchCurrentProfileDataAccessor.cachePolicy = cachePolicy;
    
    [self.fetchCurrentProfileDataAccessor fetchCurrentUserProfile];
}

- (void)requestProfileUpdateWithModel:(ASDKModelProfile *)profileModel
                      completionBlock:(AFAProfileCompletionBlock)completionBlock {
    NSParameterAssert(completionBlock);
    self.updateCurrentProfileCompletionBlock = completionBlock;
    
    self.updateCurrentProfileDataAccessor = [[ASDKProfileDataAccessor alloc] initWithDelegate:self];
    [self.updateCurrentProfileDataAccessor updateCurrentProfileWithModel:profileModel];
}

- (void)requestProfilePasswordUpdatedWithNewPassword:(NSString *)updatedPassword
                                         oldPassword:(NSString *)oldPassword
                                     completionBlock:(AFAProfilePasswordCompletionBlock)completionBlock {
    NSParameterAssert(completionBlock);
    self.updateProfilePasswordCompletionBlock = completionBlock;
    
    self.updateCurrentProfilePasswordDataAccessor = [[ASDKProfileDataAccessor alloc] initWithDelegate:self];
    [self.updateCurrentProfilePasswordDataAccessor updateCurrentProfileWithNewPassword:updatedPassword
                                                                           oldPassword:oldPassword];
}

- (void)requestUploadProfileImageAtFileURL:(NSURL *)fileURL
                               contentData:(NSData *)contentData
                             progressBlock:(AFAProfileContentProgressBlock)progressBlock
                           completionBlock:(AFAProfileContentUploadCompletionBlock)completionBlock {
    NSParameterAssert(completionBlock);
    
    self.uploadCurrentProfileImageProgressBlock = progressBlock;
    self.uploadCurrentProfileImageCompletionBlock = completionBlock;
    
    ASDKModelFileContent *fileContentModel = [ASDKModelFileContent new];
    fileContentModel.modelFileURL = fileURL;
    
    self.uploadCurrentProfileImageDataAccessor = [[ASDKProfileDataAccessor alloc] initWithDelegate:self];
    [self.uploadCurrentProfileImageDataAccessor uploadCurrentProfileImageForContentModel:fileContentModel
                                                                             contentData:contentData];
}

- (void)cancellProfileNetworkRequests {
    [self.fetchCurrentProfileDataAccessor cancelOperations];
    [self.fetchCurrentProfileImageDataAccessor cancelOperations];
    [self.updateCurrentProfileDataAccessor cancelOperations];
    [self.updateCurrentProfilePasswordDataAccessor cancelOperations];
    [self.uploadCurrentProfileImageDataAccessor cancelOperations];
}


#pragma mark -
#pragma mark ASDKDataAccessorDelegate

- (void)dataAccessor:(id<ASDKServiceDataAccessorProtocol>)dataAccessor
 didLoadDataResponse:(ASDKDataAccessorResponseBase *)response {
    if (self.fetchCurrentProfileImageDataAccessor == dataAccessor) {
        [self handleCurrentProfileImageDataAccessorResponse:response];
    } else if (self.fetchCurrentProfileDataAccessor == dataAccessor) {
        [self handleCurrentProfileDataAccessorResponse:response];
    } else if (self.updateCurrentProfileDataAccessor == dataAccessor) {
        [self handleUpdateCurrentProfileDataAccessorResponse:response];
    } else if (self.updateCurrentProfilePasswordDataAccessor == dataAccessor) {
        [self handleUpdateCurrentProfilePasswordDataAccessorResponse:response];
    } else if (self.uploadCurrentProfileImageDataAccessor == dataAccessor) {
        [self handleUploadProfileImageForCurrentProfileDataAccessorResponse:response];
    }
}

- (void)dataAccessorDidFinishedLoadingDataResponse:(id<ASDKServiceDataAccessorProtocol>)dataAccessor {
}


#pragma mark -
#pragma mark Private interface

- (void)handleCurrentProfileImageDataAccessorResponse:(ASDKDataAccessorResponseBase *)response {
    ASDKDataAccessorResponseModel *profileImageResponse = (ASDKDataAccessorResponseModel *)response;
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(self) strongSelf = weakSelf;
        
        if (strongSelf.profileImageCompletionBlock) {
            strongSelf.profileImageCompletionBlock(profileImageResponse.model, profileImageResponse.error);
            strongSelf.profileImageCompletionBlock = nil;
        }
    });
}

- (void)handleCurrentProfileDataAccessorResponse:(ASDKDataAccessorResponseBase *)response {
    ASDKDataAccessorResponseModel *profileResponse = (ASDKDataAccessorResponseModel *)response;
    ASDKModelProfile *profile = (ASDKModelProfile *)profileResponse.model;
    
    __weak typeof(self) weakSelf = self;
    if (!profileResponse.error) {
        if (profileResponse.isCachedData) {
            dispatch_async(dispatch_get_main_queue(), ^{
                __strong typeof(self) strongSelf = weakSelf;
                
                if (strongSelf.currentProfileCachedResultsBlock) {
                    strongSelf.currentProfileCachedResultsBlock(profile, nil);
                    strongSelf.currentProfileCachedResultsBlock = nil;
                }
            });
            
            return;
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(self) strongSelf = weakSelf;
        
        if (strongSelf.currentProfileCompletionBlock) {
            strongSelf.currentProfileCompletionBlock(profile, profileResponse.error);
            strongSelf.currentProfileCompletionBlock = nil;
        }
    });
}

- (void)handleUpdateCurrentProfileDataAccessorResponse:(ASDKDataAccessorResponseBase *)response {
    ASDKDataAccessorResponseModel *profileResponse = (ASDKDataAccessorResponseModel *)response;
    ASDKModelProfile *profile = (ASDKModelProfile *)profileResponse.model;
    
    if (!profileResponse.error) {
        
        // If the user updated the email address (username) then replace the authentication provider in the
        // SDK with the new username and also update the keychain values if the user checked the remember
        // credentials option
        if ([[self currentServerConfiguration].credential isKindOfClass:ASDKModelCredentialBaseAuth.class]) {
            if (![profile.email isEqualToString:((ASDKModelCredentialBaseAuth *)[self currentServerConfiguration].credential).username]) {
                [self handleCredentialUpdateRequestForUsername:profile.email
                                                      password:((ASDKModelCredentialBaseAuth *)[self currentServerConfiguration].credential).password];
            }
        }
    }
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(self) strongSelf = weakSelf;
        
        if (strongSelf.updateCurrentProfileCompletionBlock) {
            strongSelf.updateCurrentProfileCompletionBlock(profile, profileResponse.error);
            strongSelf.updateCurrentProfileCompletionBlock = nil;
        }
    });
}

- (void)handleUpdateCurrentProfilePasswordDataAccessorResponse:(ASDKDataAccessorResponseBase *)response {
    ASDKDataAccessorResponseModel *profileResponse = (ASDKDataAccessorResponseModel *)response;
    NSString *newPassword = profileResponse.model;
    
    if (!profileResponse.error) {
        
        // If the password has been updated replace the authentication provider in the SDK with
        // the new password and also update the keychain values if the user checked the remember
        // credentials option
        if (newPassword.length) {
            if ([[self currentServerConfiguration].credential isKindOfClass:ASDKModelCredentialBaseAuth.class]) {
                [self handleCredentialUpdateRequestForUsername:((ASDKModelCredentialBaseAuth *)[self currentServerConfiguration].credential).username
                                                      password:newPassword];
            }
        }
    }
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(self) strongSelf = weakSelf;
        
        if (strongSelf.updateProfilePasswordCompletionBlock) {
            strongSelf.updateProfilePasswordCompletionBlock(newPassword.length ? YES : NO, profileResponse.error);
            strongSelf.updateProfilePasswordCompletionBlock = nil;
        }
    });
}

- (void)handleUploadProfileImageForCurrentProfileDataAccessorResponse:(ASDKDataAccessorResponseBase *)response {
    __weak typeof(self) weakSelf = self;
    if ([response isKindOfClass:[ASDKDataAccessorResponseProgress class]]) {
        ASDKDataAccessorResponseProgress *progressResponse = (ASDKDataAccessorResponseProgress *)response;
        NSUInteger progress = progressResponse.progress;
        AFALogVerbose(@"Profile image is %lu%% uploaded", (unsigned long)progress);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(self) strongSelf = weakSelf;
            
            if(strongSelf.uploadCurrentProfileImageProgressBlock) {
                strongSelf.uploadCurrentProfileImageProgressBlock (progress, progressResponse.error);
            }
        });
    } else if ([response isKindOfClass:[ASDKDataAccessorResponseModel class]]) {
        ASDKDataAccessorResponseModel *contentResponse = (ASDKDataAccessorResponseModel *)response;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(self) strongSelf = weakSelf;
            
            if (strongSelf.uploadCurrentProfileImageCompletionBlock) {
                strongSelf.uploadCurrentProfileImageCompletionBlock(contentResponse.error ? NO : YES, contentResponse.error);
                strongSelf.uploadCurrentProfileImageCompletionBlock = nil;
                strongSelf.uploadCurrentProfileImageProgressBlock = nil;
            }
        });
    }
}

- (void)handleCredentialUpdateRequestForUsername:(NSString *)userName
                                        password:(NSString *)password {
    ASDKBootstrap *sdkBootstrap = [ASDKBootstrap sharedInstance];
    ASDKModelCredentialBaseAuth *baseAuthCredential = [[ASDKModelCredentialBaseAuth alloc] initWithUsername:userName
                                                                                                   password:password];
    [sdkBootstrap updateServerConfigurationWithCredential:baseAuthCredential];

    NSString *persistenceStackModelName = [ASDKPersistenceStack persistenceStackModelNameForServerConfiguration:sdkBootstrap.serverConfiguration];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *currentAuthentificationIdentifier = [userDefaults objectForKey:kAuthentificationTypeCredentialIdentifier];
    if ([currentAuthentificationIdentifier isEqualToString:kCloudAuthetificationCredentialIdentifier]) {
        [userDefaults setObject:userName
                         forKey:kCloudUsernameCredentialIdentifier];
    } else if ([currentAuthentificationIdentifier isEqualToString:kPremiseAuthentificationCredentialIdentifier]) {
        [userDefaults setObject:userName
                         forKey:kPremiseUsernameCredentialIdentifier];
    }
    [userDefaults synchronize];
    
    if ([AFAKeychainWrapper keychainStringFromMatchingIdentifier:persistenceStackModelName]) {
        [AFAKeychainWrapper updateKeychainValue:password
                                  forIdentifier:persistenceStackModelName];
    } else {
        [AFAKeychainWrapper createKeychainValue:password
                                  forIdentifier:persistenceStackModelName];
    }
}

- (ASDKModelServerConfiguration *)currentServerConfiguration {
    ASDKBootstrap *sdkBootstrap = [ASDKBootstrap sharedInstance];
    return sdkBootstrap.serverConfiguration;
}

@end

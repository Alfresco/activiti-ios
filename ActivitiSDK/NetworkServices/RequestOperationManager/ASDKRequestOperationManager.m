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

#import "ASDKRequestOperationManager.h"

// Constants
#import "ASDKLogConfiguration.h"
#import "ASDKNetworkServiceConstants.h"
#import "ASDKHTTPCodes.h"

// Models
#import "ASDKPKCEAuthenticationProvider.h"
#import "ASDKBasicAuthenticationProvider.h"
#import "ASDKModelCredentialAIMS.h"
#import "ASDKModelCredentialBaseAuth.h"


#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

static const int activitiSDKLogLevel = ASDK_LOG_LEVEL_WARN; // | ASDK_LOG_FLAG_TRACE;

@interface ASDKRequestOperationManager ()

@property (strong, nonatomic) AFHTTPRequestSerializer               *authenticationProvider;
@property (strong, nonatomic) id<ASDKModelCredentialBaseProtocol>   credential;

@end

@implementation ASDKRequestOperationManager


#pragma mark -
#pragma mark Public interface

- (instancetype)initWithBaseURL:(NSURL *)url
                     credential:(id<ASDKModelCredentialBaseProtocol>)credential {
    NSParameterAssert(url);
    
    self = [super initWithBaseURL:url];
    if (self) {
        
        ASDKLogVerbose(@"Request manager initialized with baseURL:%@", url.absoluteString);
        
        // Allow invalid certificates for test environments
#ifdef DEBUG
        ASDKLogWarn(@"Invalid SSL certificates are allowed. Configuration available just in DEBUG mode.");
        // Create a custom security policy where we allow SSLPinning
        AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
        securityPolicy.allowInvalidCertificates = YES;
        securityPolicy.validatesDomainName = NO;
        self.securityPolicy = securityPolicy;
#endif
        self.credential = credential;
        AFHTTPRequestSerializer *authenticationProvider = [self authenticationProviderForCredential:credential];
        self.authenticationProvider = authenticationProvider;
        self.requestSerializer = authenticationProvider;
        
        // Start monitoring network changes
        [self.reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            switch (status) {
                case AFNetworkReachabilityStatusReachableViaWWAN:
                case AFNetworkReachabilityStatusReachableViaWiFi: {
                    ASDKLogWarn(@"Reachability status changed. Resuming network operation queue...");
                    [[NSNotificationCenter defaultCenter] postNotificationName:kASDKAPINetworkServiceInternetConnectionAvailable
                                                                        object:nil];
                }
                    break;
                    
                case AFNetworkReachabilityStatusNotReachable: {
                    ASDKLogWarn(@"Reachability status changed. Suspending network operation queue...");
                    [[NSNotificationCenter defaultCenter] postNotificationName:kASDKAPINetworkServiceNoInternetConnection
                                                                        object:nil];
                }
                    break;
                    
                default:
                    break;
            }
        }];
        
        [self.reachabilityManager startMonitoring];
    }
    
    return self;
}

- (AFHTTPRequestSerializer *)authenticationProvider {
    return _authenticationProvider;
}

- (void)updateCredential:(id<ASDKModelCredentialBaseProtocol>)credential {
    self.credential = credential;
    
    AFHTTPRequestSerializer *authenticationProvider = [self authenticationProviderForCredential:credential];
    
    if (self.authenticationProvider != authenticationProvider) {
        self.authenticationProvider = authenticationProvider;
        self.requestSerializer = authenticationProvider;
    }
}


#pragma mark -
#pragma mark Private interface

- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request
                               uploadProgress:(void (^)(NSProgress * _Nonnull))uploadProgressBlock
                             downloadProgress:(void (^)(NSProgress * _Nonnull))downloadProgressBlock
                            completionHandler:(void (^)(NSURLResponse * _Nonnull, id _Nullable, NSError * _Nullable))completionHandler {
    __weak typeof(self) weakSelf = self;
    // Create a completion block that handles unauthorized requests and wraps the original request
    void (^authFailBlock)(NSURLResponse *response, id responseObject, NSError *error) = ^(NSURLResponse *response, id responseObject, NSError *error)
    {
        __strong typeof(self) strongSelf = weakSelf;
        
        NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
        
        if ([httpResponse statusCode] == ASDKHTTPCode401Unauthorised || ![strongSelf.credential areCredentialValid]) {
            if (self.reachabilityManager.isReachableViaWiFi || self.reachabilityManager.isReachableViaWWAN) {
                // Since there was an error, call the refresh method and then redo the original task
                // Refresh and store new fresh token as calling super into AFNetworking perfrorm the
                // request using the new token
                if (strongSelf.sessionDelegate) {
                    [strongSelf.sessionDelegate refreshNetworkSessionWithCompletionBlock:^(NSError * _Nullable error) {
                        if (!error) {
                            NSMutableURLRequest *mutableOriginalRequest = [request mutableCopy];
                            
                            // Execute original request and re-attach the newly acquired access token
                            [mutableOriginalRequest setValue:[weakSelf.authenticationProvider valueForHTTPHeaderField:@"Authorization"]
                                          forHTTPHeaderField:@"Authorization"];
                            NSURLSessionDataTask *originalTask = [super dataTaskWithRequest:mutableOriginalRequest
                                                                             uploadProgress:uploadProgressBlock
                                                                           downloadProgress:downloadProgressBlock
                                                                          completionHandler:completionHandler];
                            [originalTask resume];
                        } else {
                            ASDKLogError(@"Failed to refresh session. Reason: %@", error.localizedDescription);
                            [weakSelf postNotificationForUnauthorizedAccessWithError:error];
                        }
                    }];
                } else {
                    // If session delegate has not been set or Basic Auth is used instead of AIMS report the request
                    // status to the caller
                    [self postNotificationForUnauthorizedAccessWithError:error];
                    completionHandler(response, responseObject, error);
                }
            } else {
                completionHandler(response, responseObject, error);
            }
        } else {
            completionHandler(response, responseObject, error);
        }
    };
    
    NSURLSessionDataTask *task = nil;
    // Check if credentials are about to expire and refresh the session if it's the case
    if (![self.credential areCredentialValid] && (self.reachabilityManager.isReachableViaWiFi || self.reachabilityManager.isReachableViaWWAN)) {
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        
        if (self.sessionDelegate) {
            __weak typeof(self) weakSelf = self;
            [self.sessionDelegate refreshNetworkSessionWithCompletionBlock:^(NSError * _Nullable error) {
                __strong typeof(self) strongSelf = weakSelf;
                
                if (!error) {
                    dispatch_semaphore_signal(semaphore);
                } else {
                    ASDKLogError(@"Failed to refresh session. Reason: %@", error.localizedDescription);
                    [strongSelf postNotificationForUnauthorizedAccessWithError:error];
                }
            }];
        } else {
            // If session delegate has not been set or Basic Auth is used instead of AIMS report the request
            // status to the caller
            [self postNotificationForUnauthorizedAccessWithError:nil];
        }
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        
        NSMutableURLRequest *mutableOriginalRequest = [request mutableCopy];
        
        // Execute original request and re-attach the newly acquired access token
        [mutableOriginalRequest setValue:[weakSelf.authenticationProvider valueForHTTPHeaderField:@"Authorization"]
                      forHTTPHeaderField:@"Authorization"];
        task = [super dataTaskWithRequest:mutableOriginalRequest
                           uploadProgress:uploadProgressBlock
                         downloadProgress:downloadProgressBlock
                        completionHandler:completionHandler];
    } else { // Execute original request but capture the failure due to credential errors
        task = [super dataTaskWithRequest:request
                           uploadProgress:uploadProgressBlock
                         downloadProgress:downloadProgressBlock
                        completionHandler:authFailBlock];
    }
    
    return task;
}

- (AFJSONRequestSerializer *)authenticationProviderForCredential:(id<ASDKModelCredentialBaseProtocol>)credential {
    AFJSONRequestSerializer *authenticationProvider;
    
    if ([credential isKindOfClass:ASDKModelCredentialAIMS.class]) {
        authenticationProvider = [[ASDKPKCEAuthenticationProvider alloc] initWithCredential:credential];
    } else {
        authenticationProvider = [[ASDKBasicAuthenticationProvider alloc] initWithCredential:credential];
    }
    
    return authenticationProvider;
}

- (void)postNotificationForUnauthorizedAccessWithError:(NSError *)error {
    NSDictionary *userInfo = [error userInfo];
    [[NSNotificationCenter defaultCenter] postNotificationName:kADSKAPIUnauthorizedRequestNotification
                                                        object:nil
                                                      userInfo:userInfo];
}

@end

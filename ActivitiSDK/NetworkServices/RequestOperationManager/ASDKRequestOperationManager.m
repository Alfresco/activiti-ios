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

@interface ASDKRequestOperationManagerRequest: NSObject

@property (strong, nonatomic) NSURLRequest *request;
@property (copy, nonatomic) void (^uploadProgressBlock)(NSProgress * _Nonnull);
@property (copy, nonatomic) void (^downloadProgressBlock)(NSProgress * _Nonnull);
@property (copy, nonatomic) void (^completionHandler)(NSURLResponse * _Nonnull, id _Nullable, NSError * _Nullable);
@property (strong, nonatomic) NSString *urlString;
@property (strong, nonatomic) id parameters;
@property (copy, nonatomic) void (^bodyBlock)(id <AFMultipartFormData> formData);
@property (copy, nonatomic) void (^successBlock)(NSURLSessionDataTask *task, id responseObject);
@property (copy, nonatomic) void (^failureBlock)(NSURLSessionDataTask *task, NSError *error);
 
- (instancetype)initWithRequest:(NSURLRequest *)request
                 uploadProgress:(void (^)(NSProgress * _Nonnull))uploadProgressBlock
               downloadProgress:(void (^)(NSProgress * _Nonnull))downloadProgressBlock
              completionHandler:(void (^)(NSURLResponse * _Nonnull, id _Nullable, NSError * _Nullable))completionHandler;

- (instancetype)initWithURLString:(NSString *)urlString
                       parameters:(id)parameters
        constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block
                         progress:(nullable void (^)(NSProgress * _Nonnull))uploadProgress
                          success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                          failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;
@end

@implementation ASDKRequestOperationManagerRequest

- (instancetype)initWithRequest:(NSURLRequest *)request
                 uploadProgress:(void (^)(NSProgress * _Nonnull))uploadProgressBlock
               downloadProgress:(void (^)(NSProgress * _Nonnull))downloadProgressBlock
              completionHandler:(void (^)(NSURLResponse * _Nonnull, id _Nullable, NSError * _Nullable))completionHandler {
    self = [super init];
    if (self) {
        _request = request;
        _uploadProgressBlock = uploadProgressBlock;
        _downloadProgressBlock = downloadProgressBlock;
        _completionHandler = completionHandler;
    }
    
    return self;
}

- (instancetype)initWithURLString:(NSString *)urlString
                       parameters:(id)parameters
        constructingBodyWithBlock:(void (^)(id<AFMultipartFormData>))block
                         progress:(void (^)(NSProgress * _Nonnull))uploadProgress
                          success:(void (^)(NSURLSessionDataTask *, id))success
                          failure:(void (^)(NSURLSessionDataTask *, NSError *))failure {
    self = [super init];
    if (self) {
        _urlString = urlString;
        _parameters = parameters;
        _bodyBlock = block;
        _successBlock = success;
        _failureBlock = failure;
    }
    
    return self;
}

@end

@interface ASDKRequestOperationManager ()

@property (strong, nonatomic) AFHTTPRequestSerializer               *authenticationProvider;
@property (strong, nonatomic) id<ASDKModelCredentialBaseProtocol>   credential;
@property (strong, atomic)    NSMutableArray                        *queuedRequests;
@property (assign, atomic)    BOOL                                  isSessionRefreshInProgress;

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
        self.queuedRequests = [NSMutableArray array];
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
    NSURLSessionDataTask *task = nil;
    
    if (![self.credential areCredentialValid] &&
        (self.reachabilityManager.isReachableViaWiFi || self.reachabilityManager.isReachableViaWWAN)) {
        if (self.sessionDelegate) {
            ASDKRequestOperationManagerRequest *queuedRequest =
            [[ASDKRequestOperationManagerRequest alloc] initWithRequest:request
                                                         uploadProgress:uploadProgressBlock
                                                       downloadProgress:downloadProgressBlock
                                                      completionHandler:completionHandler];
            [self.queuedRequests addObject:queuedRequest];
            
            if (!self.isSessionRefreshInProgress) {
                self.isSessionRefreshInProgress = YES;
                
                __weak typeof(self) weakSelf = self;
                [self.sessionDelegate refreshNetworkSessionWithCompletionBlock:^(NSError * _Nullable error) {
                    __strong typeof(self) strongSelf = weakSelf;
                    
                    strongSelf.isSessionRefreshInProgress = NO;
                    
                    if (error) {
                        ASDKLogError(@"Failed to refresh session. Reason: %@", error.localizedDescription);
                        [strongSelf postNotificationForUnauthorizedAccessWithError:error];
                    } else {
                        [strongSelf executeQueuedRequests];
                    }
                }];
            }
        } else {
            // If session delegate has not been set or Basic Auth is used instead of AIMS report the request
            // status to the caller
            [self postNotificationForUnauthorizedAccessWithError:nil];
        }
    } else {
        // Execute original request
        task = [super dataTaskWithRequest:request
                           uploadProgress:uploadProgressBlock
                         downloadProgress:downloadProgressBlock
                        completionHandler:completionHandler];
    }
    
    return task;
}

- (NSURLSessionDataTask *)POST:(NSString *)URLString
                    parameters:(id)parameters
     constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block
                      progress:(nullable void (^)(NSProgress * _Nonnull))uploadProgress
                       success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                       failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
{
    NSURLSessionDataTask *task = nil;

    if (![self.credential areCredentialValid] &&
        (self.reachabilityManager.isReachableViaWiFi || self.reachabilityManager.isReachableViaWWAN)) {
        if (self.sessionDelegate) {
            ASDKRequestOperationManagerRequest *queuedRequest =
            [[ASDKRequestOperationManagerRequest alloc] initWithURLString:URLString
                                                               parameters:parameters
                                                constructingBodyWithBlock:block
                                                                 progress:uploadProgress
                                                                  success:success
                                                                  failure:failure];
            [self.queuedRequests addObject:queuedRequest];
            
            if (!self.isSessionRefreshInProgress) {
                self.isSessionRefreshInProgress = YES;
                
                __weak typeof(self) weakSelf = self;
                [self.sessionDelegate refreshNetworkSessionWithCompletionBlock:^(NSError * _Nullable error) {
                    __strong typeof(self) strongSelf = weakSelf;

                    strongSelf.isSessionRefreshInProgress = NO;

                    if (error) {
                        ASDKLogError(@"Failed to refresh session. Reason: %@", error.localizedDescription);
                        [strongSelf postNotificationForUnauthorizedAccessWithError:error];
                    } else {
                        [strongSelf executeQueuedRequests];
                    }
                }];
            } else {
                // If session delegate has not been set or Basic Auth is used instead of AIMS report the request
                // status to the caller
                [self postNotificationForUnauthorizedAccessWithError:nil];
            }
        }
    } else { // Execute original request
        task = [super POST:URLString
                parameters:parameters
 constructingBodyWithBlock:block
                  progress:uploadProgress
                   success:success
                   failure:failure];
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

- (void)executeRequest:(NSURLRequest *)request
        uploadProgress:(void (^)(NSProgress * _Nonnull))uploadProgressBlock
      downloadProgress:(void (^)(NSProgress * _Nonnull))downloadProgressBlock
     completionHandler:(void (^)(NSURLResponse * _Nonnull, id _Nullable, NSError * _Nullable))completionHandler {
    NSMutableURLRequest *mutableOriginalRequest = [request mutableCopy];
    
    // Execute original request and re-attach the newly acquired access token
    [mutableOriginalRequest setValue:[self.authenticationProvider valueForHTTPHeaderField:@"Authorization"]
                  forHTTPHeaderField:@"Authorization"];
    NSURLSessionDataTask *originalTask = [super dataTaskWithRequest:mutableOriginalRequest
                                                     uploadProgress:uploadProgressBlock
                                                   downloadProgress:downloadProgressBlock
                                                  completionHandler:completionHandler];
    [originalTask resume];
}

- (void)executeQueuedRequests {
    for (int idx = 0; idx < self.queuedRequests.count; idx++) {
        ASDKRequestOperationManagerRequest *queuedRequest = (ASDKRequestOperationManagerRequest *)self.queuedRequests[idx];
        
        if (queuedRequest.request) {
            [self executeRequest:queuedRequest.request
               uploadProgress:queuedRequest.uploadProgressBlock
             downloadProgress:queuedRequest.downloadProgressBlock
            completionHandler:queuedRequest.completionHandler];
        } else {
            [self POST:queuedRequest.urlString
            parameters:queuedRequest.parameters
constructingBodyWithBlock:queuedRequest.bodyBlock
              progress:queuedRequest.uploadProgressBlock
               success:queuedRequest.successBlock
               failure:queuedRequest.failureBlock];
        }
    }
    
    [self.queuedRequests removeAllObjects];
}

@end

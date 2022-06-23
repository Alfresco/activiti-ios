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

#import "ASDKNetworkService.h"
#import "ASDKNetworkServiceConstants.h"
#import "ActivitiSDK/ASDKBootstrap.h"
#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

@interface ASDKNetworkService()

@property (strong, nonatomic) NSDictionary *requestSerializersDict;

@end

@implementation ASDKNetworkService

#pragma mark -
#pragma mark Life cycle

- (instancetype)initWithRequestManager:(ASDKRequestOperationManager *)requestOperationManager
                         parserManager:(ASDKParserOperationManager *)parserManager
                    servicePathFactory:(ASDKServicePathFactory *)servicePathFactory
                          diskServices:(ASDKDiskServices *)diskServices
                          resultsQueue:(dispatch_queue_t)resultsQueue {
    NSParameterAssert(requestOperationManager);
    NSParameterAssert(parserManager);
    NSParameterAssert(servicePathFactory);
    
    self = [super init];
    
    if (self) {
        self.requestOperationManager = requestOperationManager;
        if (resultsQueue) {
            [self.requestOperationManager setCompletionQueue:resultsQueue];
        }
        self.parserOperationManager = parserManager;
        self.servicePathFactory = servicePathFactory;
        self.diskServices = diskServices;
        self.resultsQueue = resultsQueue;
        
        AFCompoundResponseSerializer *compoundResponseSerializer =[AFCompoundResponseSerializer compoundSerializerWithResponseSerializers:
                                                                   @[[AFJSONResponseSerializer serializer],
                                                                     [AFImageResponseSerializer serializer],
                                                                     [AFHTTPResponseSerializer serializer]]];
        self.requestOperationManager.responseSerializer = compoundResponseSerializer;
        
        AFJSONRequestSerializer *jsonRequestSerializer = [AFJSONRequestSerializer serializer];
        AFHTTPRequestSerializer *httpRequestSerializer = [AFHTTPRequestSerializer serializer];
        
        self.requestSerializersDict = @{@(ASDKNetworkServiceRequestSerializerTypeJSON) : jsonRequestSerializer,
                                        @(ASDKNetworkServiceRequestSerializerTypeHTTP) : httpRequestSerializer};
    }
    
    return self;
}

#pragma mark - 
#pragma mark Public interface

- (void)setResultsQueue:(dispatch_queue_t)resultsQueue {
    if (resultsQueue != _resultsQueue) {
        _resultsQueue = resultsQueue;
        [_parserOperationManager setCompletionQueue:resultsQueue];
    }
}

- (AFHTTPRequestSerializer *)requestSerializerOfType:(ASDKNetworkServiceRequestSerializerType)serializerType {
    return self.requestSerializersDict[@(serializerType)];
}

- (void)configureWithCSRFTokenStorage:(ASDKCSRFTokenStorage *)tokenStorage {
    NSParameterAssert(tokenStorage);
    
    AFHTTPRequestSerializer *httpWithCSRFRequestSerializer = [AFHTTPRequestSerializer serializer];
    [httpWithCSRFRequestSerializer setValue:[tokenStorage csrfTokenString]
                         forHTTPHeaderField:kASDKAPICSRFHeaderFieldParameter];
//    let sdkBootstrap = ASDKBootstrap.sharedInstance()
    ASDKBootstrap *sdkBootStrap = [ASDKBootstrap sharedInstance];
    NSString *bearerAccessToken = sdkBootStrap.accesstokenValue;
    [httpWithCSRFRequestSerializer setValue:bearerAccessToken forHTTPHeaderField:@"Authorization"];
    // sdkBootStrap.serverConfiguration
    NSMutableDictionary *requestSerializersDict = [NSMutableDictionary dictionaryWithDictionary:self.requestSerializersDict];
    [requestSerializersDict addEntriesFromDictionary:@{@(ASDKNetworkServiceRequestSerializerTypeHTTPWithCSRFToken) : httpWithCSRFRequestSerializer}];
    self.requestSerializersDict = requestSerializersDict;
    
    // Search for the CSRF cookie and if it's not available create it for future requests
    BOOL isCSRFCookieAvailable = NO;
    for (NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]) {
        if ([cookie.name isEqualToString:kASDKAPICSRFCookieName]) {
            isCSRFCookieAvailable = YES;
            break;
        }
    }
    
    if (!isCSRFCookieAvailable) {
        NSURLComponents *urlComponents = [[NSURLComponents alloc] initWithURL:self.requestOperationManager.baseURL
                                                      resolvingAgainstBaseURL:YES];
        
        NSDictionary *cookieProperties = @{NSHTTPCookieName     : kASDKAPICSRFCookieName,
                                           NSHTTPCookieValue    : [tokenStorage csrfTokenString],
                                           NSHTTPCookiePath     : @"/",
                                           NSHTTPCookieVersion  : @"0",
                                           NSHTTPCookieDomain   : urlComponents.host};
        NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:cookieProperties];
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
    }
}

@end

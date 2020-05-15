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

@import WebKit;
#import "ASDKIntegrationLoginWebViewViewController.h"

// Constants
#import "ASDKFormRenderEngineConstants.h"
#import "ASDKLogConfiguration.h"
#import "ASDKLocalizationConstants.h"
#import "ASDKNetworkServiceConstants.h"

// Model
#import "ASDKModelServerConfiguration.h"
#import "ASDKModelCredentialBaseAuth.h"

// Managers
#import "ASDKCSRFTokenStorage.h"
#import "ASDKBootstrap.h"
#import "ASDKServiceLocator.h"
#import "ASDKProfileNetworkServices.h"

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

static const int activitiSDKLogLevel = ASDK_LOG_LEVEL_VERBOSE; // | ASDK_LOG_FLAG_TRACE;

@interface ASDKIntegrationLoginWebViewViewController () <WKNavigationDelegate>

@property (weak, nonatomic)   IBOutlet WKWebView        *webViewContainer;
@property (weak, nonatomic)   IBOutlet UIBarButtonItem  *cancelBarButtonItem;
@property (strong, nonatomic) NSString                  *loginURLString;
@property (assign, nonatomic) BOOL                      isAuthorizationComplete;
@property (strong, nonatomic) ASDKIntegrationLoginWebViewViewControllerCompletionBlock completionBlock;

@end

@implementation ASDKIntegrationLoginWebViewViewController

- (instancetype)initWithAuthorizationURL:(NSString *)authorizationURLString
                         completionBlock:(ASDKIntegrationLoginWebViewViewControllerCompletionBlock)completionBlock {
    NSParameterAssert(authorizationURLString);
    NSParameterAssert(completionBlock);
    
    UIStoryboard *formStoryboard = [UIStoryboard storyboardWithName:kASDKFormStoryboardBundleName
                                                             bundle:[NSBundle bundleForClass:[self class]]];
    self = [formStoryboard instantiateViewControllerWithIdentifier:kASDKStoryboardIDIntegrationLoginWebViewController];
    if (self) {
        self.loginURLString = authorizationURLString;
        self.completionBlock = completionBlock;
    }
    
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self.cancelBarButtonItem setTitle:ASDKLocalizedStringFromTable(kLocalizationCancelButtonText, ASDKLocalizationTable, @"Cancel button")];
    self.webViewContainer.navigationDelegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    ASDKBootstrap *sdkBootstrap = [ASDKBootstrap sharedInstance];
    ASDKProfileNetworkServices *profileNetworkServices = [sdkBootstrap.serviceLocator serviceConformingToProtocol:@protocol(ASDKProfileNetworkServiceProtocol)];
    
    if ([sdkBootstrap.serverConfiguration.credential isKindOfClass: ASDKModelCredentialBaseAuth.class]) {
        ASDKModelCredentialBaseAuth *baseAuthCredential = (ASDKModelCredentialBaseAuth *)sdkBootstrap.serverConfiguration.credential;
        
        [profileNetworkServices authenticateUser:baseAuthCredential.username
                                    withPassword:baseAuthCredential.password
                             withCompletionBlock:^(BOOL didAutheticate, NSError *error) {
                                 if (didAutheticate) {
                                     ASDKLogVerbose(@"Authentication cookie retrieved successfully.\nDisplaying integration login form with request:%@", self.loginURLString);
                                     NSMutableURLRequest *loginRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:self.loginURLString]];
                                     
                                     // Attach the CSRF token to the login page request
                                     [loginRequest setValue:[profileNetworkServices.tokenStorage csrfTokenString]
                                         forHTTPHeaderField:kASDKAPICSRFHeaderFieldParameter];
                                     
                                     dispatch_async(dispatch_get_main_queue(), ^{
                                         [self.webViewContainer loadRequest:loginRequest];
                                     });
                                 } else {
                                     ASDKLogVerbose(@"An error occured while retrieving the authentication cookie.");
                                 }
        }];
    }
}


#pragma mark -
#pragma mark Actions

- (IBAction)onCancel:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}


#pragma mark -
#pragma mark UIWebView Delegate

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction
decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    // Check if the login flow has finished
    NSURLComponents *urlComponents = [NSURLComponents componentsWithString:navigationAction.request.URL.absoluteString];
    for (NSURLQueryItem *item in urlComponents.queryItems) {
        if ([item.name isEqualToString:kASDKIntegrationOauth2CodeParameter]) {
            self.isAuthorizationComplete = YES;
        }
    }
    
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    if (_isAuthorizationComplete) {
        self.completionBlock(YES);
        [self dismissViewControllerAnimated:YES
                                 completion:nil];
    }
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation
      withError:(NSError *)error {
    self.completionBlock(NO);
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

@end

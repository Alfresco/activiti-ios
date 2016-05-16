/*******************************************************************************
 * Copyright (C) 2005-2016 Alfresco Software Limited.
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

#import "ASDKIntegrationLoginWebViewViewController.h"
#import "ASDKFormRenderEngineConstants.h"
#import "ASDKLogConfiguration.h"
#import "ASDKLocalizationConstants.h"
#import "ASDKNetworkServiceConstants.h"

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

static const int activitiSDKLogLevel = ASDK_LOG_LEVEL_VERBOSE; // | ASDK_LOG_FLAG_TRACE;

@interface ASDKIntegrationLoginWebViewViewController () <UIWebViewDelegate>

@property (weak, nonatomic)   IBOutlet UIWebView        *webViewContainer;
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
    [self.cancelBarButtonItem setTitle:ASDKLocalizedStringFromTable(kLocalizationCancelButtonText, ASDKLocalizationTable, @"Cancel button")];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    ASDKLogVerbose(@"Displaying integration login form with request:%@", self.loginURLString);
    NSURLRequest *loginRequest = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:self.loginURLString]];
    [self.webViewContainer loadRequest:loginRequest];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -
#pragma mark Actions

- (IBAction)onCancel:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

#pragma mark -
#pragma mark UIWebView Delegate

- (BOOL)webView:(UIWebView *)webView
shouldStartLoadWithRequest:(NSURLRequest *)request
 navigationType:(UIWebViewNavigationType)navigationType {
    // Check if the login flow has finished
    NSURLComponents *urlComponents = [NSURLComponents componentsWithString:request.URL.absoluteString];
    for (NSURLQueryItem *item in urlComponents.queryItems) {
        if ([item.name isEqualToString:kASDKIntegrationOauth2CodeParameter]) {
            self.isAuthorizationComplete = YES;
        }
    }
    
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    if (_isAuthorizationComplete) {
        self.completionBlock(YES);
        [self dismissViewControllerAnimated:YES
                                 completion:nil];
    }
}

- (void)webView:(UIWebView *)webView
didFailLoadWithError:(NSError *)error {
    self.completionBlock(NO);
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

@end

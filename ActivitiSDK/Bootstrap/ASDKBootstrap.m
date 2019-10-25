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

#import "ASDKBootstrap.h"

// Log component imports
#import "ASDKLogConfiguration.h"
#import "ASDKLogFormatter.h"

// Service locator imports
#import "ASDKServiceLocator.h"

// Network services imports
#import "ASDKNetworkService.h"
#import "ASDKProfileNetworkServices.h"
#import "ASDKTaskNetworkServices.h"
#import "ASDKFilterNetworkServices.h"
#import "ASDKFormNetworkServices.h"
#import "ASDKAppNetworkServices.h"
#import "ASDKProcessInstanceNetworkServices.h"
#import "ASDKProcessDefinitionNetworkServices.h"
#import "ASDKUserNetworkServices.h"
#import "ASDKQuerryNetworkServices.h"
#import "ASDKIntegrationNetworkServices.h"

// Managers imports
#import "ASDKRequestOperationManager.h"
#import "ASDKParserOperationManager.h"
#import "ASDKServicePathFactory.h"
#import "ASDKProfileParserOperationWorker.h"
#import "ASDKTaskDetailsParserOperationWorker.h"
#import "ASDKTaskFormParserOperationWorker.h"
#import "ASDKAppParserOperationWorker.h"
#import "ASDKProcessParserOperationWorker.h"
#import "ASDKUserParserOperationWorker.h"
#import "ASDKIntegrationParserOperationWorker.h"
#import "ASDKDiskServices.h"
#import "ASDKFormRenderEngine.h"
#import "ASDKFormColorSchemeManager.h"
#import "ASDKFormColorSchemeManagerProtocol.h"
#import "ASDKCSRFTokenStorage.h"
#import "ASDKFilterParserOperationWorker.h"
#import "ASDKPersistenceStack.h"
#import "ASDKNetworkDelayedOperationSaveFormService.h"

// Configurations imports
#import "ASDKBasicAuthenticationProvider.h"
#import "ASDKPKCEAuthenticationProvider.h"

// Model imports
#import "ASDKModelServerConfiguration.h"

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

static const int activitiSDKLogLevel = ASDK_LOG_LEVEL_VERBOSE; // | ASDK_LOG_FLAG_TRACE;

@interface ASDKBootstrap ()

@property (strong, nonatomic) ASDKRequestOperationManager   *requestOperationManager;

@end

@implementation ASDKBootstrap

#pragma mark -
#pragma mark Singleton

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static ASDKBootstrap *sharedInstance = nil;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[super alloc] initUniqueInstance];
    });
    
    return sharedInstance;
}

- (instancetype)initUniqueInstance {
    self = [super init];
    
    if (self) {
        _serviceLocator = [ASDKServiceLocator new];
        ASDKLogVerbose(@"Service locator component...%@", _serviceLocator ? @"OK" : @"NOT_OK");
    }
    
    return self;
}


#pragma mark -
#pragma mark Public interface

- (void)setupServicesWithServerConfiguration:(ASDKModelServerConfiguration *)serverConfiguration {
    _serverConfiguration = serverConfiguration;
    
    // Register available services with the service locator repository
    ASDKLogVerbose(@"Registering services...");
    
    // Create a service path factory with the passed server configuration
    ASDKServicePathFactory *servicePathFactory = [[ASDKServicePathFactory alloc] initWithHostAddress:self.serverConfiguration.hostAddressString
                                                                                 serviceDocumentPath:self.serverConfiguration.serviceDocument
                                                                                                port:self.serverConfiguration.port
                                                                                     overSecureLayer:self.serverConfiguration.isCommunicationOverSecureLayer];
    
    // Set up the request manager
    AFJSONRequestSerializer *authenticationProvider = [self authenticationProviderForServerConfiguration:serverConfiguration];
    self.requestOperationManager = [[ASDKRequestOperationManager alloc] initWithBaseURL:servicePathFactory.baseURL
                                                                 authenticationProvider:authenticationProvider];
    
    // Set up parser services
    ASDKParserOperationManager *parserOperationManager = [self parserOperationManager];
    
    // Link the processing queues between the request and parser managers
    self.requestOperationManager.completionQueue = self.parserOperationManager.completionQueue;
    
    // Set up the disk services
    ASDKDiskServices *diskService = [ASDKDiskServices new];
    
    // Set up network services
    [self setupCSRFTokenStorageManager];
    [self setupApplicationNetworkServiceWithRequestOperationManager:self.requestOperationManager
                                                      parserManager:parserOperationManager
                                                 servicePathFactory:servicePathFactory
                                                       diskServices:diskService];
    [self setupProfileNetworkServiceWithRequestOperationManager:self.requestOperationManager
                                                  parserManager:parserOperationManager
                                             servicePathFactory:servicePathFactory
                                                   diskServices:diskService];
    [self setupTaskNetworkServiceWithRequestOperationManager:self.requestOperationManager
                                               parserManager:parserOperationManager
                                          servicePathFactory:servicePathFactory
                                                diskServices:diskService];
    [self setupFilterNetworkServiceWithRequestOperationManager:self.requestOperationManager
                                                 parserManager:parserOperationManager
                                            servicePathFactory:servicePathFactory
                                                  diskServices:diskService];
    [self setupProcessInstanceNetworkServiceWithRequestOperationManager:self.requestOperationManager
                                                          parserManager:parserOperationManager
                                                     servicePathFactory:servicePathFactory
                                                           diskServices:diskService];
    [self setupProcessDefinitionNetworkServiceWithRequestOperationManager:self.requestOperationManager
                                                            parserManager:parserOperationManager
                                                       servicePathFactory:servicePathFactory
                                                             diskServices:diskService];
    [self setupUserNetworkServiceWithRequestOperationManager:self.requestOperationManager
                                               parserManager:parserOperationManager
                                          servicePathFactory:servicePathFactory
                                                diskServices:diskService];
    [self setupFormNetworkServiceWithRequestOperationManager:self.requestOperationManager
                                               parserManager:parserOperationManager
                                          servicePathFactory:servicePathFactory
                                                diskServices:diskService];
    [self setupQuerryNetworkServiceWithRequestOperationManager:self.requestOperationManager
                                                 parserManager:parserOperationManager
                                            servicePathFactory:servicePathFactory
                                                  diskServices:diskService];
    [self setupIntegrationNetworkServiceWithRequestOperationManager:self.requestOperationManager
                                                      parserManager:parserOperationManager
                                                 servicePathFactory:servicePathFactory
                                                       diskServices:diskService];
    
    // Set up form services
    [self setupFormColorSchemeManager];
    
    // Set up persistence services
    [self setupPersistenceStack];
}

- (void)updateServerConfigurationCredentialsForUsername:(NSString *)username
                                               password:(NSString *)password {
    _serverConfiguration.username = username;
    _serverConfiguration.password = password;
    
    ASDKBasicAuthenticationProvider *authenticationProvider =
    [[ASDKBasicAuthenticationProvider alloc] initWithUserName:username
                                                     password:password];
    [self.requestOperationManager replaceAuthenticationProvider:authenticationProvider];
}

- (void)updateServerConfigurationForAccessToken:(NSString *)accessToken {
    _serverConfiguration.acessToken = accessToken;
    
    ASDKPKCEAuthenticationProvider *authenticationProvider =
    [[ASDKPKCEAuthenticationProvider alloc] initWithAccessToken:accessToken];
    [self.requestOperationManager replaceAuthenticationProvider:authenticationProvider];
}


#pragma mark -
#pragma mark Private interface

- (AFJSONRequestSerializer *)authenticationProviderForServerConfiguration:(ASDKModelServerConfiguration *)serverConfiguration {
    // Based on the server configuration object assess whether it's a basic auth or token login
    AFJSONRequestSerializer *authenticationProvider = nil;
    
    if (serverConfiguration.acessToken.length) {
        authenticationProvider = [[ASDKPKCEAuthenticationProvider alloc] initWithAccessToken:serverConfiguration.acessToken];
    } else {
        authenticationProvider = [[ASDKBasicAuthenticationProvider alloc] initWithUserName:serverConfiguration.username
                                                                                  password:serverConfiguration.password];
    }
    
    return authenticationProvider;
}

- (ASDKParserOperationManager *)parserOperationManager {
    ASDKParserOperationManager *parserOperationManager = [ASDKParserOperationManager new];
    
    ASDKProfileParserOperationWorker *profileParserWorker = [ASDKProfileParserOperationWorker new];
    [parserOperationManager registerWorker:profileParserWorker
                               forServices:[profileParserWorker availableServices]];
    ASDKAppParserOperationWorker *appParserWorker = [ASDKAppParserOperationWorker new];
    [parserOperationManager registerWorker:appParserWorker
                               forServices:[appParserWorker availableServices]];
    ASDKTaskDetailsParserOperationWorker *taskDetailsParserWorker = [ASDKTaskDetailsParserOperationWorker new];
    [parserOperationManager registerWorker:taskDetailsParserWorker
                               forServices:[taskDetailsParserWorker availableServices]];
    ASDKFilterParserOperationWorker *filterParserWorker = [ASDKFilterParserOperationWorker new];
    [parserOperationManager registerWorker:filterParserWorker
                               forServices:[filterParserWorker availableServices]];
    ASDKTaskFormParserOperationWorker *taskFormParserWorker = [ASDKTaskFormParserOperationWorker new];
    [parserOperationManager registerWorker:taskFormParserWorker
                               forServices:[taskFormParserWorker availableServices]];
    ASDKUserParserOperationWorker *userParserWorker = [ASDKUserParserOperationWorker new];
    [parserOperationManager registerWorker:userParserWorker
                               forServices:[userParserWorker availableServices]];
    ASDKIntegrationParserOperationWorker *integrationParserWorker = [ASDKIntegrationParserOperationWorker new];
    [parserOperationManager registerWorker:integrationParserWorker
                               forServices:[integrationParserWorker availableServices]];
    ASDKProcessParserOperationWorker *processParserWorker = [ASDKProcessParserOperationWorker new];
    [parserOperationManager registerWorker:processParserWorker
                               forServices:[processParserWorker availableServices]];
    
    return parserOperationManager;
}

- (void)setupProfileNetworkServiceWithRequestOperationManager:(ASDKRequestOperationManager *)requestOperationManager
                                                parserManager:(ASDKParserOperationManager *)parserManager
                                           servicePathFactory:(ASDKServicePathFactory *)servicePathFactory
                                                 diskServices:(ASDKDiskServices *)diskServices {
    ASDKProfileNetworkServices *profileNetworkService =
    [[ASDKProfileNetworkServices alloc] initWithRequestManager:requestOperationManager
                                                 parserManager:parserManager
                                            servicePathFactory:servicePathFactory
                                                  diskServices:diskServices
                                                  resultsQueue:nil];
    [profileNetworkService configureWithCSRFTokenStorage:[self.serviceLocator serviceConformingToProtocol:@protocol(ASDKCSRFTokenStorageProtocol)]];
    
    if ([_serviceLocator isServiceRegisteredForProtocol:@protocol(ASDKProfileNetworkServiceProtocol)]) {
        [_serviceLocator removeService:profileNetworkService];
    }
    [_serviceLocator addService:profileNetworkService];
    
    ASDKLogVerbose(@"Profile network services...%@", profileNetworkService ? @"OK" : @"NOT_OK");
}

- (void)setupApplicationNetworkServiceWithRequestOperationManager:(ASDKRequestOperationManager *)requestOperationManager
                                                    parserManager:(ASDKParserOperationManager *)parserManager
                                               servicePathFactory:(ASDKServicePathFactory *)servicePathFactory
                                                     diskServices:(ASDKDiskServices *)diskServices {
    ASDKAppNetworkServices *applicationNetworkService = [[ASDKAppNetworkServices alloc] initWithRequestManager:requestOperationManager
                                                                                                 parserManager:parserManager
                                                                                            servicePathFactory:servicePathFactory
                                                                                                  diskServices:diskServices
                                                                                                  resultsQueue:nil];
    
    if ([_serviceLocator isServiceRegisteredForProtocol:@protocol(ASDKAppNetworkServiceProtocol)]) {
        [_serviceLocator removeService:applicationNetworkService];
    }
    [_serviceLocator addService:applicationNetworkService];
    
    ASDKLogVerbose(@"App network services...%@", applicationNetworkService ? @"OK" : @"NOT_OK");
}

- (void)setupTaskNetworkServiceWithRequestOperationManager:(ASDKRequestOperationManager *)requestOperationManager
                                             parserManager:(ASDKParserOperationManager *)parserManager
                                        servicePathFactory:(ASDKServicePathFactory *)servicePathFactory
                                              diskServices:(ASDKDiskServices *)diskServices {
    ASDKTaskNetworkServices *taskNetworkService = [[ASDKTaskNetworkServices alloc] initWithRequestManager:requestOperationManager
                                                                                            parserManager:parserManager
                                                                                       servicePathFactory:servicePathFactory
                                                                                             diskServices:diskServices
                                                                                             resultsQueue:nil];
    
    if ([_serviceLocator isServiceRegisteredForProtocol:@protocol(ASDKTaskNetworkServiceProtocol)]) {
        [_serviceLocator removeService:taskNetworkService];
    }
    [_serviceLocator addService:taskNetworkService];
    
    ASDKLogVerbose(@"Task network services...%@", taskNetworkService ? @"OK" : @"NOT_OK");
}

- (void)setupFilterNetworkServiceWithRequestOperationManager:(ASDKRequestOperationManager *)requestOperationManager
                                               parserManager:(ASDKParserOperationManager *)parserManager
                                          servicePathFactory:(ASDKServicePathFactory *)servicePathFactory
                                                diskServices:(ASDKDiskServices *)diskServices {
    ASDKFilterNetworkServices *filterNetworkService = [[ASDKFilterNetworkServices alloc] initWithRequestManager:requestOperationManager
                                                                                                  parserManager:parserManager
                                                                                             servicePathFactory:servicePathFactory
                                                                                                   diskServices:diskServices
                                                                                                   resultsQueue:nil];
    
    if ([_serviceLocator isServiceRegisteredForProtocol:@protocol(ASDKFilterNetworkServiceProtocol)]) {
        [_serviceLocator removeService:filterNetworkService];
    }
    [_serviceLocator addService:filterNetworkService];
    
    ASDKLogVerbose(@"Filter network services...%@", filterNetworkService ? @"OK" : @"NOT_OK");
}

- (void)setupProcessInstanceNetworkServiceWithRequestOperationManager:(ASDKRequestOperationManager *)requestOperationManager
                                                        parserManager:(ASDKParserOperationManager *)parserManager
                                                   servicePathFactory:(ASDKServicePathFactory *)servicePathFactory
                                                         diskServices:(ASDKDiskServices *)diskServices {
    ASDKProcessInstanceNetworkServices *processInstanceNetworkService =
    [[ASDKProcessInstanceNetworkServices alloc] initWithRequestManager:requestOperationManager
                                                         parserManager:parserManager
                                                    servicePathFactory:servicePathFactory
                                                          diskServices:diskServices
                                                          resultsQueue:nil];
    
    if ([_serviceLocator isServiceRegisteredForProtocol:@protocol(ASDKProcessInstanceNetworkServiceProtocol)]) {
        [_serviceLocator removeService:processInstanceNetworkService];
    }
    [_serviceLocator addService:processInstanceNetworkService];
    
    ASDKLogVerbose(@"Process instance network services...%@", processInstanceNetworkService ? @"OK" : @"NOT_OK");
}

- (void)setupProcessDefinitionNetworkServiceWithRequestOperationManager:(ASDKRequestOperationManager *)requestOperationManager
                                                          parserManager:(ASDKParserOperationManager *)parserManager
                                                     servicePathFactory:(ASDKServicePathFactory *)servicePathFactory
                                                           diskServices:(ASDKDiskServices *)diskServices {
    ASDKProcessDefinitionNetworkServices *processDefinitionNetworkService =
    [[ASDKProcessDefinitionNetworkServices alloc] initWithRequestManager:requestOperationManager
                                                           parserManager:parserManager
                                                      servicePathFactory:servicePathFactory
                                                            diskServices:diskServices
                                                            resultsQueue:nil];
    
    if ([_serviceLocator isServiceRegisteredForProtocol:@protocol(ASDKProcessDefinitionNetworkServiceProtocol)]) {
        [_serviceLocator removeService:processDefinitionNetworkService];
    }
    [_serviceLocator addService:processDefinitionNetworkService];
    
    ASDKLogVerbose(@"Process definition network services...%@", processDefinitionNetworkService ? @"OK" : @"NOT_OK");
}

- (void)setupUserNetworkServiceWithRequestOperationManager:(ASDKRequestOperationManager *)requestOperationManager
                                             parserManager:(ASDKParserOperationManager *)parserManager
                                        servicePathFactory:(ASDKServicePathFactory *)servicePathFactory
                                              diskServices:(ASDKDiskServices *)diskServices {
    ASDKUserNetworkServices *userNetworkService =
    [[ASDKUserNetworkServices alloc] initWithRequestManager:requestOperationManager
                                              parserManager:parserManager
                                         servicePathFactory:servicePathFactory
                                               diskServices:diskServices
                                               resultsQueue:nil];
    
    if ([_serviceLocator isServiceRegisteredForProtocol:@protocol(ASDKUserNetworkServiceProtocol)]) {
        [_serviceLocator removeService:userNetworkService];
    }
    [_serviceLocator addService:userNetworkService];
    
    ASDKLogVerbose(@"User network services...%@", userNetworkService ? @"OK" : @"NOT_OK");
}

- (void)setupFormNetworkServiceWithRequestOperationManager:(ASDKRequestOperationManager *)requestOperationManager
                                             parserManager:(ASDKParserOperationManager *)parserManager
                                        servicePathFactory:(ASDKServicePathFactory *)servicePathFactory
                                              diskServices:(ASDKDiskServices *)diskServices {
    // Set up the form network service
    ASDKFormNetworkServices *formNetworkService = [[ASDKFormNetworkServices alloc] initWithRequestManager:requestOperationManager
                                                                                            parserManager:parserManager
                                                                                       servicePathFactory:servicePathFactory
                                                                                             diskServices:diskServices
                                                                                             resultsQueue:nil];
    
    if ([_serviceLocator isServiceRegisteredForProtocol:@protocol(ASDKFormNetworkServiceProtocol)]) {
        [_serviceLocator removeService:formNetworkService];
    }
    [_serviceLocator addService:formNetworkService];
    
    ASDKLogVerbose(@"Form network services...%@", formNetworkService ? @"OK" : @"NOT_OK");
}

- (void)setupQuerryNetworkServiceWithRequestOperationManager:(ASDKRequestOperationManager *)requestOperationManager
                                               parserManager:(ASDKParserOperationManager *)parserManager
                                          servicePathFactory:(ASDKServicePathFactory *)servicePathFactory
                                                diskServices:(ASDKDiskServices *)diskServices {
    ASDKQuerryNetworkServices *queryNetworkService = [[ASDKQuerryNetworkServices alloc] initWithRequestManager:requestOperationManager
                                                                                                 parserManager:parserManager
                                                                                            servicePathFactory:servicePathFactory
                                                                                                  diskServices:diskServices
                                                                                                  resultsQueue:nil];
    
    if ([_serviceLocator isServiceRegisteredForProtocol:@protocol(ASDKQuerryNetworkServiceProtocol)]) {
        [_serviceLocator removeService:queryNetworkService];
    }
    [_serviceLocator addService:queryNetworkService];
    
    ASDKLogVerbose(@"Query network services...%@", queryNetworkService ? @"OK" : @"NOT_OK");
}

- (void)setupIntegrationNetworkServiceWithRequestOperationManager:(ASDKRequestOperationManager *)requestOperationManager
                                                    parserManager:(ASDKParserOperationManager *)parserManager
                                               servicePathFactory:(ASDKServicePathFactory *)servicePathFactory
                                                     diskServices:(ASDKDiskServices *)diskServices {
    ASDKIntegrationNetworkServices *integrationNetworkService =
    [[ASDKIntegrationNetworkServices alloc] initWithRequestManager:requestOperationManager
                                                     parserManager:parserManager
                                                servicePathFactory:servicePathFactory
                                                      diskServices:diskServices
                                                      resultsQueue:nil];
    if ([_serviceLocator isServiceRegisteredForProtocol:@protocol(ASDKIntegrationNetworkServiceProtocol)]) {
        [_serviceLocator removeService:integrationNetworkService];
    }
    [_serviceLocator addService:integrationNetworkService];
    
    ASDKLogVerbose(@"Integration network services...%@", integrationNetworkService ? @"OK" : @"NOT_OK");
}

- (void)setupFormColorSchemeManager {
    ASDKFormColorSchemeManager *colorSchemeManager = [ASDKFormColorSchemeManager new];
    if ([_serviceLocator isServiceRegisteredForProtocol:@protocol(ASDKFormColorSchemeManagerProtocol)]) {
        [_serviceLocator removeService:colorSchemeManager];
    }
    [_serviceLocator addService:colorSchemeManager];
    
    ASDKLogVerbose(@"Form color scheme manager...%@", colorSchemeManager ? @"OK" : @"NOT_OK");
}

- (void)setupCSRFTokenStorageManager {
    // Set up the CSRF token storage manager
    ASDKCSRFTokenStorage *tokenStorage = [ASDKCSRFTokenStorage new];
    
    if ([_serviceLocator isServiceRegisteredForProtocol:@protocol(ASDKCSRFTokenStorageProtocol)]) {
        [_serviceLocator removeService:tokenStorage];
    }
    [_serviceLocator addService:tokenStorage];
    
    ASDKLogVerbose(@"CSRF token storage manager...%@", tokenStorage ? @"OK" : @"NOT_OK");
}

- (void)setupPersistenceStack {
    ASDKPersistenceStack *persistenceStack = [[ASDKPersistenceStack alloc] initWithServerConfiguration:self.serverConfiguration
                                                                                          errorHandler:^(NSError *error) {
        ASDKLogVerbose(@"Persistence stack...%@", error ? @"NOT_OK" : @"OK");
        if (error) {
            ASDKLogError(@"Reason:%@", error.localizedDescription);
        }
    }];
    if ([_serviceLocator isServiceRegisteredForProtocol:@protocol(ASDKPersistenceStackProtocol)]) {
        [_serviceLocator removeService:persistenceStack];
    }
    [_serviceLocator addService:persistenceStack];
}

@end

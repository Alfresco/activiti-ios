/*******************************************************************************
 * Copyright (C) 2005-2018 Alfresco Software Limited.
 *
 * This file is part of the Alfresco Activiti iOS App.
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

#import "AppDelegate.h"

// Constants
#import "AFABusinessConstants.h"
#import "AFALocalizationConstants.h"

// Categories
#import "UIColor+AFATheme.h"

// Managers
#import "AFAServiceRepository.h"
#import "AFAThumbnailManager.h"
#import "AFAKeychainWrapper.h"
#import "AFALogFormatter.h"

// Frameworks
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import <Buglife/Buglife.h>


static const int activitiLogLevel = AFA_LOG_LEVEL_VERBOSE; // | AFA_LOG_FLAG_TRACE;

@interface AppDelegate () <CrashlyticsDelegate, BuglifeDelegate>

@property (strong, nonatomic) DDFileLogger *fileLogger;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Cocoa Lumberjack integration
    [[DDASLLogger sharedInstance] setLogFormatter:[AFALogFormatter new]];
    [[DDTTYLogger sharedInstance] setLogFormatter:[AFALogFormatter new]];
    
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    
    self.fileLogger = [DDFileLogger new];
    self.fileLogger.maximumFileSize = 3 * 1024 * 1024;
    self.fileLogger.rollingFrequency = 3600 * 24;
    self.fileLogger.logFileManager.maximumNumberOfLogFiles = 3;
    [DDLog addLogger:self.fileLogger];
    
    // Crashlyticss integration
    CrashlyticsKit.delegate = self;
    [Fabric with:@[[Crashlytics class]]];
    
    // Buglife integration
    // Add your email key to receive bug reports
#warning Update Buglife report email
    [[Buglife sharedBuglife] startWithEmail:@"you@yourdomain.com"];
    [Buglife sharedBuglife].invocationOptions = LIFEInvocationOptionsShake;
    [Buglife sharedBuglife].delegate = self;
    
    application.delegate.window.backgroundColor = [UIColor windowBackgroundColor];
    
    return YES;
}

- (void)crashlyticsDidDetectReportForLastExecution:(CLSReport *)report
                                 completionHandler:(void (^)(BOOL))completionHandler {
    // As a precaution to keep the users safe from entering a possible crash-loop
    // if a previous crash was detected disable the auto sign-in function to at least
    // give time for the crash reports to be delivered
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    [standardUserDefaults removeObjectForKey:kCloudUsernameCredentialIdentifier];
    [standardUserDefaults removeObjectForKey:kPremiseUsernameCredentialIdentifier];
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        completionHandler(YES);
    }];
}

- (void)buglife:(nonnull Buglife *)buglife handleAttachmentRequestWithCompletionHandler:(nonnull void (^)(void))completionHandler {
    for (DDLogFileInfo *fileInfo in [self.fileLogger.logFileManager unsortedLogFileInfos]) {
        NSData *fileData = [NSData dataWithContentsOfFile:fileInfo.filePath];
        
        NSError *error =nil;
        BOOL success = [buglife addAttachmentWithData:fileData
                                                 type:LIFEAttachmentTypeIdentifierText
                                             filename:fileInfo.fileName
                                                error:&error];
        
        if (!success) {
            AFALogError(@"An error occured while attaching log information to bug report. Reason:%@", error.localizedDescription);
        }
    }
    
    completionHandler();
}

- (NSString *)buglife:(Buglife *)buglife titleForPromptWithInvocation:(LIFEInvocationOptions)invocation {
    return NSLocalizedString(kLocalizationBugReportingSheetDescriptionText, "Bug reporting text description");
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Clean up image cache
    AFAThumbnailManager *thumbnailsManager = [[AFAServiceRepository sharedRepository] serviceObjectForPurpose:AFAServiceObjectTypeThumbnailManager];
    [thumbnailsManager cleanupMemoryCache];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];
}

@end

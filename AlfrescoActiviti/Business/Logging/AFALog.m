//
//  AFALog.m
//  AlfrescoActiviti
//
//  Created by Emanuel Lupu on 28/10/2019.
//  Copyright © 2019 Emanuel Lupu-Marinei. All rights reserved.
//

#import "AFALog.h"

static const int activitiLogLevel = AFA_LOG_LEVEL_VERBOSE; // | AFA_LOG_FLAG_TRACE;

@implementation AFALog

+ (void)logError:(NSString *)errorMessage {
    AFALogError(@"%@", errorMessage);
}

+ (void)logWarning:(NSString *)warningMessage {
    AFALogWarn(@"%@", warningMessage);
}

+ (void)logInfo:(NSString *)infoMessage {
    AFALogInfo(@"%@", infoMessage);
}

+ (void)logVerbose:(NSString *)verboseMessage {
    AFALogVerbose(@"%@", verboseMessage);
}

@end

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

#import "AFALogFormatter.h"
@import ActivitiSDK;

@implementation AFALogFormatter

- (NSString *)formatLogMessage:(DDLogMessage *)logMessage {
    NSString *logLevel;
    switch (logMessage->_flag) {
        case DDLogFlagError    : logLevel = @"E"; break;
        case DDLogFlagWarning  : logLevel = @"W"; break;
        case DDLogFlagInfo     : logLevel = @"I"; break;
        case DDLogFlagDebug    : logLevel = @"D"; break;
        default                : logLevel = @"V"; break;
    }
    
    // Notice that starting iOS 7, NSDateFormatter is thread safe so even if we plug
    // the same log formatter to different log sources and run it on different threads
    // it will be safe
    NSDateFormatter *logDateFormatter = [NSDateFormatter new];
    [logDateFormatter setDateFormat:@"yyyy/MM/dd HH:mm:ss:SSS"];
    NSString *timeStampString = [logDateFormatter stringFromDate:logMessage->_timestamp];
    
    NSString *sdkBundleIdentifier = nil;
    if (ASDK_LOG_CONTEXT == logMessage.context) {
        sdkBundleIdentifier = @"ActivitiSDK";
    } else {
        // Extract the target name without all the additional bundle identifier constructs
        NSString *bundleIdentifier = [[NSBundle bundleForClass:[self class]] bundleIdentifier];
        NSRange rangeOfLastBundleIdentifierComponent = [bundleIdentifier rangeOfString:@"."
                                                                               options:NSBackwardsSearch];
        sdkBundleIdentifier = [bundleIdentifier substringWithRange:NSMakeRange(rangeOfLastBundleIdentifierComponent.location + 1, // Don't include the . character
                                                                               bundleIdentifier.length - rangeOfLastBundleIdentifierComponent.location - 1)];
    }

    return [NSString stringWithFormat:@"%@ | %@ | %@ | %@\n", timeStampString, sdkBundleIdentifier, logLevel, logMessage->_message];
}

@end

/*******************************************************************************
* Copyright (C) 2005-2020 Alfresco Software Limited.
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

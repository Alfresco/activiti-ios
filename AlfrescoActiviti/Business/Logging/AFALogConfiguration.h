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

/**
 * To support fast and flexible logging this project uses Cocoa Lumberjack.
 *
 * Here's what you need to know concerning how logging is setup for Alfresco Activiti:
 *
 * There are 4 log levels:
 * - Error
 * - Warning
 * - Info
 * - Verbose
 *
 * In addition to this, there is a Trace flag that can be enabled.
 * When tracing is enabled, it prints the parent class and methods that are being called.
 *
 * Please note that tracing is separate from the log levels.
 * For example, one could set the log level to warning, and enable tracing.
 *
 * All logging is asynchronous, except errors.
 * To use logging within your own custom files, follow the steps below.
 *
 * Step 1:
 * Import this header in your implementation file:
 *
 * #import "AFALogConfiguration.h"
 *
 * Step 2:
 * Define your logging level in your implementation file:
 *
 * static const int activitiLogLevel = AFA_LOG_LEVEL_WARN;
 *
 * If you wish to enable tracing, you could do something like this:
 *
 * static const int activitiLogLevel = AFA_LOG_FLAG_VERBOSE | AFA_LOG_FLAG_TRACE;
 *
 * Step 3:
 * Replace your NSLog statements with AFALog statements
 *
 * NSLog(@"Error description"); -> AFALogError(@"Error description");
 *
 **/

@import CocoaLumberjack;

#define AFA_LOG_CONTEXT 1

// Configure log levels.

#define AFA_LOG_FLAG_ERROR   (1 << 0) // 0...00001
#define AFA_LOG_FLAG_WARN    (1 << 1) // 0...00010
#define AFA_LOG_FLAG_INFO    (1 << 2) // 0...00100
#define AFA_LOG_FLAG_VERBOSE (1 << 3) // 0...01000

#define AFA_LOG_LEVEL_OFF     0                                            // 0...00000
#define AFA_LOG_LEVEL_ERROR   (AFA_LOG_LEVEL_OFF   | AFA_LOG_FLAG_ERROR)   // 0...00001
#define AFA_LOG_LEVEL_WARN    (AFA_LOG_LEVEL_ERROR | AFA_LOG_FLAG_WARN)    // 0...00011
#define AFA_LOG_LEVEL_INFO    (AFA_LOG_LEVEL_WARN  | AFA_LOG_FLAG_INFO)    // 0...00111
#define AFA_LOG_LEVEL_VERBOSE (AFA_LOG_LEVEL_INFO  | AFA_LOG_FLAG_VERBOSE) // 0...01111

// Setup fine grained logging for tracing method calls on the 4th bit
// Tracing will be available independent of the log level that is set

#define AFA_LOG_FLAG_TRACE   (1 << 4) // 0...10000

#define AFA_LOG_ERROR   (activitiSDKLogLevel & AFA_LOG_FLAG_ERROR)
#define AFA_LOG_WARN    (activitiSDKLogLevel & AFA_LOG_FLAG_WARN)
#define AFA_LOG_INFO    (activitiSDKLogLevel & AFA_LOG_FLAG_INFO)
#define AFA_LOG_VERBOSE (activitiSDKLogLevel & AFA_LOG_FLAG_VERBOSE)
#define AFA_LOG_TRACE   (activitiSDKLogLevel & AFA_LOG_FLAG_TRACE)

#define AFA_LOG_ASYNC_ENABLED   YES

#define AFA_LOG_ASYNC_ERROR   ( NO && AFA_LOG_ASYNC_ENABLED)
#define AFA_LOG_ASYNC_WARN    (YES && AFA_LOG_ASYNC_ENABLED)
#define AFA_LOG_ASYNC_INFO    (YES && AFA_LOG_ASYNC_ENABLED)
#define AFA_LOG_ASYNC_VERBOSE (YES && AFA_LOG_ASYNC_ENABLED)
#define AFA_LOG_ASYNC_TRACE   (YES && AFA_LOG_ASYNC_ENABLED)

// Define logging primitives

#define AFALogError(frmt, ...)    LOG_MAYBE(AFA_LOG_ASYNC_ERROR,   activitiLogLevel, AFA_LOG_FLAG_ERROR,  \
AFA_LOG_CONTEXT, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)

#define AFALogWarn(frmt, ...)     LOG_MAYBE(AFA_LOG_ASYNC_WARN,    activitiLogLevel, AFA_LOG_FLAG_WARN,   \
AFA_LOG_CONTEXT, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)

#define AFALogInfo(frmt, ...)     LOG_MAYBE(AFA_LOG_ASYNC_INFO,    activitiLogLevel, AFA_LOG_FLAG_INFO,    \
AFA_LOG_CONTEXT, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)

#define AFALogVerbose(frmt, ...)  LOG_MAYBE(AFA_LOG_ASYNC_VERBOSE, activitiLogLevel, AFA_LOG_FLAG_VERBOSE, \
AFA_LOG_CONTEXT, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)

#define AFALogTrace()             LOG_MAYBE(AFA_LOG_ASYNC_TRACE,   activitiLogLevel, AFA_LOG_FLAG_TRACE, \
AFA_LOG_CONTEXT, nil, __PRETTY_FUNCTION__, @"%@[%p]: %@", THIS_FILE, self, THIS_METHOD)

#define AFALogTrace2(frmt, ...)   LOG_MAYBE(AFA_LOG_ASYNC_TRACE,   activitiLogLevel, AFA_LOG_FLAG_TRACE, \
AFA_LOG_CONTEXT, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)

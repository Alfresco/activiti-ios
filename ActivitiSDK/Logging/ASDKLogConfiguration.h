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

/**
 * To support fast and flexible logging this project uses Cocoa Lumberjack.
 *
 * Here's what you need to know concerning how logging is setup for ActivitiSDK:
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
 * #import "ASDKLogConfiguration.h"
 *
 * Step 2:
 * Define your logging level in your implementation file:
 *
 * static const int activitiSDKLogLevel = ASDK_LOG_LEVEL_WARN;
 *
 * If you wish to enable tracing, you could do something like this:
 *
 * static const int activitiSDKLogLevel = ASDK_LOG_FLAG_VERBOSE | ASDK_LOG_FLAG_TRACE;
 *
 * Step 3:
 * Replace your NSLog statements with ASDKLog statements
 *
 * NSLog(@"Error description"); -> ASDKLogError(@"Error description");
 *
 **/

@import CocoaLumberjack;

#define ASDK_LOG_CONTEXT 0

// Configure log levels.

#define ASDK_LOG_FLAG_ERROR   (1 << 0) // 0...00001
#define ASDK_LOG_FLAG_WARN    (1 << 1) // 0...00010
#define ASDK_LOG_FLAG_INFO    (1 << 2) // 0...00100
#define ASDK_LOG_FLAG_VERBOSE (1 << 3) // 0...01000

#define ASDK_LOG_LEVEL_OFF     0                                              // 0...00000
#define ASDK_LOG_LEVEL_ERROR   (ASDK_LOG_LEVEL_OFF   | ASDK_LOG_FLAG_ERROR)   // 0...00001
#define ASDK_LOG_LEVEL_WARN    (ASDK_LOG_LEVEL_ERROR | ASDK_LOG_FLAG_WARN)    // 0...00011
#define ASDK_LOG_LEVEL_INFO    (ASDK_LOG_LEVEL_WARN  | ASDK_LOG_FLAG_INFO)    // 0...00111
#define ASDK_LOG_LEVEL_VERBOSE (ASDK_LOG_LEVEL_INFO  | ASDK_LOG_FLAG_VERBOSE) // 0...01111

// Setup fine grained logging for tracing method calls on the 4th bit
// Tracing will be available independent of the log level that is set

#define ASDK_LOG_FLAG_TRACE   (1 << 4) // 0...10000

#define ASDK_LOG_ERROR   (activitiSDKLogLevel & ASDK_LOG_FLAG_ERROR)
#define ASDK_LOG_WARN    (activitiSDKLogLevel & ASDK_LOG_FLAG_WARN)
#define ASDK_LOG_INFO    (activitiSDKLogLevel & ASDK_LOG_FLAG_INFO)
#define ASDK_LOG_VERBOSE (activitiSDKLogLevel & ASDK_LOG_FLAG_VERBOSE)
#define ASDK_LOG_TRACE   (activitiSDKLogLevel & ASDK_LOG_FLAG_TRACE)

#define ASDK_LOG_ASYNC_ENABLED   YES

#define ASDK_LOG_ASYNC_ERROR   ( NO && ASDK_LOG_ASYNC_ENABLED)
#define ASDK_LOG_ASYNC_WARN    (YES && ASDK_LOG_ASYNC_ENABLED)
#define ASDK_LOG_ASYNC_INFO    (YES && ASDK_LOG_ASYNC_ENABLED)
#define ASDK_LOG_ASYNC_VERBOSE (YES && ASDK_LOG_ASYNC_ENABLED)
#define ASDK_LOG_ASYNC_TRACE   (YES && ASDK_LOG_ASYNC_ENABLED)

// Define logging primitives

#define ASDKLogError(frmt, ...)    LOG_MAYBE(ASDK_LOG_ASYNC_ERROR,   activitiSDKLogLevel, ASDK_LOG_FLAG_ERROR,  \
ASDK_LOG_CONTEXT, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)

#define ASDKLogWarn(frmt, ...)     LOG_MAYBE(ASDK_LOG_ASYNC_WARN,    activitiSDKLogLevel, ASDK_LOG_FLAG_WARN,   \
ASDK_LOG_CONTEXT, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)

#define ASDKLogInfo(frmt, ...)     LOG_MAYBE(ASDK_LOG_ASYNC_INFO,    activitiSDKLogLevel, ASDK_LOG_FLAG_INFO,    \
ASDK_LOG_CONTEXT, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)

#define ASDKLogVerbose(frmt, ...)  LOG_MAYBE(ASDK_LOG_ASYNC_VERBOSE, activitiSDKLogLevel, ASDK_LOG_FLAG_VERBOSE, \
ASDK_LOG_CONTEXT, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)

#define ASDKLogTrace()             LOG_MAYBE(ASDK_LOG_ASYNC_TRACE,   activitiSDKLogLevel, ASDK_LOG_FLAG_TRACE, \
ASDK_LOG_CONTEXT, nil, __PRETTY_FUNCTION__, @"%@[%p]: %@", THIS_FILE, self, THIS_METHOD)

#define ASDKLogTrace2(frmt, ...)   LOG_MAYBE(ASDK_LOG_ASYNC_TRACE,   activitiSDKLogLevel, ASDK_LOG_FLAG_TRACE, \
ASDK_LOG_CONTEXT, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)

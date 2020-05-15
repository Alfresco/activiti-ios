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

@import Mantle;
#import "ASDKParserOperationManager.h"
#import "ASDKLogConfiguration.h"

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

static const int activitiSDKLogLevel = ASDK_LOG_LEVEL_VERBOSE; // | ASDK_LOG_FLAG_TRACE;

@interface ASDKParserOperationManager ()

@property (strong, nonatomic) NSMutableDictionary *workerServiceDict;

@end

@implementation ASDKParserOperationManager

#pragma mark -
#pragma Lifecycle

- (instancetype)init {
    self = [super init];
    
    if (self) {
        NSString *isolationQueueIdentifier = [NSString stringWithFormat:@"%@.%@", [[NSBundle bundleForClass:[self class]] bundleIdentifier], NSStringFromClass([self class])];
        self.completionQueue = dispatch_queue_create([isolationQueueIdentifier UTF8String], DISPATCH_QUEUE_CONCURRENT);
        self.workerServiceDict = [NSMutableDictionary dictionary];
    }
    
    return self;
}

#pragma mark -
#pragma mark Public interface

- (void)registerWorker:(id<ASDKParserOperationWorkerProtocol>)worker
           forServices:(NSArray *)services {
    self.workerServiceDict[services] = worker;
}

- (void)parseContentDictionary:(NSDictionary *)contentDictionary
                        ofType:(NSString *)contentType
           withCompletionBlock:(ASDKParserCompletionBlock)completionBlock {
    NSParameterAssert(contentDictionary);
    NSParameterAssert(contentType);
    NSParameterAssert(completionBlock);
    
    BOOL isWorkerRegisteredForJob = NO;
    
    for (NSArray *services in self.workerServiceDict.allKeys) {
        if ([services indexOfObjectIdenticalTo:contentType] != NSNotFound) {
            isWorkerRegisteredForJob = YES;
            
            id <ASDKParserOperationWorkerProtocol> worker = self.workerServiceDict[services];
            [worker parseContentDictionary:contentDictionary
                                    ofType:contentType
                       withCompletionBlock:completionBlock
                                     queue:self.completionQueue];
        }
    }
    
    if (!isWorkerRegisteredForJob) {
        ASDKLogError(@"Could not parse content for contentType:%@, because a registered worker to handle it was not found.", contentType);
    }
}

@end

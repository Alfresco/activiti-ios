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

#import "ASDKDataAccessorOperation.h"
#import "ASDKDataAccessor.h"

@implementation ASDKDataAccessorOperation

- (nonnull instancetype)initWithDataAccessor:(id<ASDKServiceDataAccessorProtocol>)dataAccessor
                                    delegate:(id<ASDKDataAccessorOperationProtocol>)delegate {
    self = [super init];
    if (self) {
        _dataAccessor = dataAccessor;
        _delegate = delegate;
    }
    return self;
}

- (void)start {
    [self willChangeValueForKey:@"isExecuting"];
    self.isExecuting = YES;
    [self didChangeValueForKey:@"isExecuting"];
    
    [self main];
}

- (void)main {
    if (self.isCancelled) {
        [self complete];
    }
    
    if (!self.dataAccessor) {
        [self complete];
    }
}

- (void)complete {
    [self willChangeValueForKey:@"isExecuting"];
    [self willChangeValueForKey:@"isFinished"];
    self.isExecuting = NO;
    self.isFinished = YES;
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}


#pragma mark -
#pragma mark ASDKDataAccessorDelegate

- (void)dataAccessor:(id<ASDKServiceDataAccessorProtocol>)dataAccessor
 didLoadDataResponse:(ASDKDataAccessorResponseBase *)response {
    if (self.delegate) {
        [self.delegate dataAccessorOperation:self
                            withDataAccessor:dataAccessor
                         didLoadDataResponse:response];
    }
}

- (void)dataAccessorDidFinishedLoadingDataResponse:(id<ASDKServiceDataAccessorProtocol>)dataAccessor {
    if (self.delegate) {
        [self.delegate dataAccessorOperation:self
              didFinishedLoadingDataResponse:dataAccessor];
    }
    [self complete];
}

@end

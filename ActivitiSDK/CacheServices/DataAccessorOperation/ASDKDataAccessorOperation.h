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

#import <Foundation/Foundation.h>
#import "ASDKServiceDataAccessorProtocol.h"

@class ASDKDataAccessor;
@protocol ASDKDataAccessorOperationProtocol;

@interface ASDKDataAccessorOperation : NSOperation <ASDKDataAccessorDelegate>

@property (assign, nonatomic) BOOL                                          isExecuting;
@property (assign, nonatomic) BOOL                                          isFinished;
@property (strong, nonatomic) NSDictionary                                  * _Nullable userInfo;
@property (strong, nonatomic, nullable) id<ASDKServiceDataAccessorProtocol> dataAccessor;
@property (weak, nonatomic) id<ASDKDataAccessorOperationProtocol>           _Nullable delegate;

- (nonnull instancetype)initWithDataAccessor:(id<ASDKServiceDataAccessorProtocol>_Nonnull)dataAccessor
                                    delegate:(id<ASDKDataAccessorOperationProtocol>_Nullable)delegate;

@end

@protocol ASDKDataAccessorOperationProtocol <NSObject>

/**
 * Signals that a data accessor operation finished loading a response from cache or remote and delivers
 * an encapsulated response.
 *
 * @param operation     Reference to the operation encapsulating the data accessor
 * @param dataAccessor  Reference to the data accessor that is delivering the response
 * @param response      Response object that's encapsulating the actual data, whether the response
 *                      is being delivered from the cache or remote
 */
- (void)dataAccessorOperation:(ASDKDataAccessorOperation *_Nonnull)operation
             withDataAccessor:(id<ASDKServiceDataAccessorProtocol>_Nonnull)dataAccessor
          didLoadDataResponse:(ASDKDataAccessorResponseBase *_Nullable)response;

/**
 * Signals that all data fetching operations from the cache or remote have finished
 *
 * @param operation    Reference to the operation encapsulating the data accessor
 * @param dataAccessor Reference to the data accessor that is delivering the response
 */
- (void)dataAccessorOperation:(ASDKDataAccessorOperation *_Nonnull)operation
didFinishedLoadingDataResponse:(id<ASDKServiceDataAccessorProtocol>_Nonnull)dataAccessor;

@end


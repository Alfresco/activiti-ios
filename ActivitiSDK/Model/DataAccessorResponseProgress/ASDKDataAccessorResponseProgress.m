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

#import "ASDKDataAccessorResponseProgress.h"

@implementation ASDKDataAccessorResponseProgress

- (instancetype)initWithProgress:(NSUInteger)progress
                           error:(NSError *)error {
    self = [super initWithError:error
                   isCachedData:NO];
    if (self) {
        _progress = progress;
    }
    
    return self;
}

- (instancetype)initWithFormattedProgressString:(NSString *)formattedProgressString
                                          error:(NSError *)error {
    self = [super initWithError:error
                   isCachedData:NO];
    if (self) {
        _formattedProgressString = formattedProgressString;
    }
    
    return self;
}

@end

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

#import "ASDKFormEngineActionHandler.h"

@implementation ASDKFormEngineActionHandler


#pragma mark -
#pragma mark Public interface

- (void)saveForm {
    if ([self.dataSourceActionDelegate respondsToSelector:@selector(isSaveFormAvailable)]) {
        if ([self.dataSourceActionDelegate isSaveFormAvailable]) {
            if ([self.formControllerActionDelegate respondsToSelector:@selector(saveForm)]) {
                [self.formControllerActionDelegate saveForm];
            }
        }
    }
}

- (BOOL)isSaveFormActionAvailable {
    if ([self.dataSourceActionDelegate respondsToSelector:@selector(isSaveFormAvailable)]) {
        return [self.dataSourceActionDelegate isSaveFormAvailable];
    }
    
    return NO;
}

@end

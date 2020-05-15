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

#import <Mantle/Mantle.h>

/**
 *  Convenience specialization of Mantle JSON Adapter that is used to exclude
 *  nil and scalar 0 values from within the generated JSON. This is useful for
 *  filter requests representations where we need to exclude certain fields when
 *  converting the model to JSON dictionary.
 */
@interface ASDKMantleJSONAdapterExcludeZeroNil : MTLJSONAdapter

@end

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

#import <UIKit/UIKit.h>
#import "ASDKFormRenderEngineDataSourceProtocol.h"
#import "ASDKFormRenderEngineProtocol.h"
#import "ASDKFormControllerNavigationProtocol.h"
#import "ASDKModelFormConfiguration.h"

@interface ASDKFormCollectionViewController : UICollectionViewController <ASDKFormControllerNavigationProtocol,
                                                                          ASDKFormRenderEngineDataSourceDelegate>

@property (strong, nonatomic) ASDKModelFormConfiguration                *formConfiguration;
@property (weak, nonatomic)   id<ASDKFormControllerNavigationProtocol>  navigationDelegate;
@property (weak, nonatomic)   id<ASDKFormRenderEngineProtocol>          renderDelegate;
@property (strong, nonatomic) id<ASDKFormRenderEngineDataSourceProtocol>dataSource;

- (void)replaceExistingDataSource:(id<ASDKFormRenderEngineDataSourceProtocol>)dataSource;

@end

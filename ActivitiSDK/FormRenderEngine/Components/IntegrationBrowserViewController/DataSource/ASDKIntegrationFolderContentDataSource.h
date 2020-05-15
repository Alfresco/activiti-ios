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

#import <Foundation/Foundation.h>
#import "ASDKIntegrationDataSourceDelegate.h"
#import "ASDKIntegrationDataSourceProtocol.h"

@class ASDKModelNetwork,
ASDKModelIntegrationContent,
ASDKModelSite;

@interface ASDKIntegrationFolderContentDataSource : NSObject <ASDKIntegrationDataSourceProtocol>

@property (weak, nonatomic) id<ASDKIntegrationDataSourceDelegate> delegate;
@property (strong, nonatomic) ASDKModelIntegrationAccount         *integrationAccount;
@property (strong, nonatomic) ASDKModelNetwork                    *currentNetwork;
@property (strong, nonatomic) ASDKModelIntegrationContent         *currentNode;
@property (strong, nonatomic) ASDKModelSite                       *currentSite;

- (instancetype)initWithNetworkModel:(ASDKModelNetwork *)networkModel
                           siteModel:(ASDKModelSite *)siteModel
                         contentNode:(ASDKModelIntegrationContent *)contentNode;

@end

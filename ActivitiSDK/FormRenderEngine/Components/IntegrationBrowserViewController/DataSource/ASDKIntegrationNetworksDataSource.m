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

#import "ASDKIntegrationNetworksDataSource.h"

// Constants
#import "ASDKFormRenderEngineConstants.h"

// Models
#import "ASDKModelNetwork.h"
#import "ASDKModelIntegrationAccount.h"

// Categories
#import "NSString+ASDKFontGlyphicons.h"
#import "UIFont+ASDKGlyphicons.h"

// Cells
#import "ASDKIntegrationBrowsingTableViewCell.h"

// Managers
#import "ASDKBootstrap.h"
#import "ASDKServiceLocator.h"
#import "ASDKIntegrationNetworkServices.h"

@interface ASDKIntegrationNetworksDataSource ()

@property (strong, nonatomic) NSArray *networkArr;

@end

@implementation ASDKIntegrationNetworksDataSource

- (instancetype)initWithIntegrationAccount:(ASDKModelIntegrationAccount *)integrationAccount {
    self = [super init];
    
    if (self) {
        _integrationAccount = integrationAccount;
    }
    
    return self;
}


#pragma mark -
#pragma mark ASDKIntegrationDataSourceProtocol

- (void)refreshDataSourceInformation {
    ASDKBootstrap *sdkBootstrap = [ASDKBootstrap sharedInstance];
    ASDKIntegrationNetworkServices *integrationNetworkService = [sdkBootstrap.serviceLocator serviceConformingToProtocol:@protocol(ASDKIntegrationNetworkServiceProtocol)];
    
    if ([self.delegate respondsToSelector:@selector(dataSourceIsFetchingContent)]) {
        [self.delegate dataSourceIsFetchingContent];
    }
    
    __weak typeof(self) weakSelf = self;
    [integrationNetworkService fetchIntegrationNetworksForSourceID:self.integrationAccount.integrationServiceID
                                                   completionBlock:^(NSArray *networks, NSError *error, ASDKModelPaging *paging) {
        __strong typeof(self) strongSelf = weakSelf;
        if (!error) {
            strongSelf.networkArr = networks;
            if ([strongSelf.delegate respondsToSelector:@selector(dataSourceFinishedFetchingContent:)]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [strongSelf.delegate dataSourceFinishedFetchingContent:networks.count ? YES : NO];
                });
            }
        } else {
            if ([strongSelf.delegate respondsToSelector:@selector(dataSourceEncounteredAnErrorWhileLoadingContent:)]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [strongSelf.delegate dataSourceEncounteredAnErrorWhileLoadingContent:error];
                });
            }
        }
    }];
}

- (id)itemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row > self.networkArr.count - 1) {
        return nil;
    }
    
    return self.networkArr[indexPath.row];
}


#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    return self.networkArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ASDKIntegrationBrowsingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kASDKCellIDIntegrationBrowsing
                                                                                 forIndexPath:indexPath];
    ASDKModelNetwork *network = self.networkArr[indexPath.row];
    cell.sourceTitleLabel.text = network.modelID;
    cell.sourceIconLabel.font = [UIFont glyphiconFontWithSize:24];
    cell.sourceIconLabel.text = [NSString iconStringForIconType:ASDKGlyphIconTypeFolderClosed];
    
    return cell;
}

@end

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
#import "ASDKDynamicTableFormFieldDetailsViewController.h"
#import "ASDKDynamicTableRowHeaderNavigationProtocol.h"

@interface ASDKDynamicTableRowHeaderTableViewCell : UITableViewCell

@property (assign, nonatomic) id<ASDKDynamicTableRowHeaderNavigationProtocol>   navigationDelegate;
@property (assign, nonatomic) NSInteger                                         selectedSection;
@property (weak, nonatomic) IBOutlet UILabel                                    *rowHeaderLabel;
@property (weak, nonatomic) IBOutlet UIButton                                   *rowEditButton;

- (IBAction)editRow:(id)sender;
- (void)setupCellWithSelectionSection:(NSInteger)section
                           headerText:(NSString *)headerText
                            isReadOnly:(BOOL)isReadOnly
                    navgationDelegate:(id<ASDKDynamicTableRowHeaderNavigationProtocol>)navigationDelegate;
@end

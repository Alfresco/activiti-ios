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

#import "ASDKDynamicTableRowHeaderTableViewCell.h"

// Categories
#import "UIFont+ASDKGlyphicons.h"
#import "NSString+ASDKFontGlyphicons.h"

@implementation ASDKDynamicTableRowHeaderTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setupCellWithSelectionSection:(NSInteger)section
                           headerText:(NSString *)headerText
                           isReadOnly:(BOOL)isReadOnly
                    navgationDelegate:(id<ASDKDynamicTableRowHeaderNavigationProtocol>)navigationDelegate {
    self.selectedSection = section;
    self.navigationDelegate = navigationDelegate;
    self.rowHeaderLabel.text = headerText;

    if (isReadOnly) {
        NSAttributedString *rowEditButtonTitle = [[NSAttributedString alloc] initWithString:[NSString iconStringForIconType:ASDKGlyphIconTypeEyeOpen]
                                                                                 attributes:@{NSFontAttributeName          : [UIFont glyphiconFontWithSize:14],
                                                                                              NSForegroundColorAttributeName: [UIColor lightGrayColor]}];
        
        [self.rowEditButton setAttributedTitle:rowEditButtonTitle forState:UIControlStateNormal];
    } else {
        NSAttributedString *rowEditButtonTitle = [[NSAttributedString alloc] initWithString:[NSString iconStringForIconType:ASDKGlyphIconTypeEdit]
                                                                                 attributes:@{NSFontAttributeName           : [UIFont glyphiconFontWithSize:14],
                                                                                              NSForegroundColorAttributeName: [UIColor lightGrayColor]}];
        
        [self.rowEditButton setAttributedTitle:rowEditButtonTitle forState:UIControlStateNormal];
    }
}

- (IBAction)editRow:(id)sender {
    [self.navigationDelegate didEditRow:self.selectedSection];
}

@end

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

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, AFACredentialTextFieldCellType) {
    AFACredentialTextFieldCellTypeUnsecured,
    AFACredentialTextFieldCellTypeSecured
};

@protocol AFACredentialTextFieldTableViewCellDelegate <NSObject>

- (void)inputTextFieldWillBeginEditting:(UITextField *)inputTextField
                                 inCell:(UITableViewCell *)cell;
- (void)inputTextFieldWillEndEditting:(UITextField *)inputTextField
                               inCell:(UITableViewCell *)cell;
- (void)inputTextFieldShouldReturn:(UITextField *)inputTextField
                            inCell:(UITableViewCell *)cell;

@end

@interface AFACredentialTextFieldTableViewCell : UITableViewCell <UITextFieldDelegate>

@property (weak, nonatomic)   IBOutlet UITextField              *inputTextField;
@property (weak, nonatomic)   IBOutlet UIView                   *hairlineView;
@property (weak, nonatomic)   IBOutlet UIButton                 *clearButton;
@property (weak, nonatomic)   IBOutlet UIButton                 *passwordButton;
@property (assign, nonatomic) AFACredentialTextFieldCellType    cellType;
@property (weak, nonatomic)   id<AFACredentialTextFieldTableViewCellDelegate> delegate;
@property (strong, nonatomic) NSString                          *inputText;

@end

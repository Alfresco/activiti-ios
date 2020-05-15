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

#import "AFALoginCredentialsViewControllerDataSource.h"
@import ActivitiSDK;

// Constants
#import "AFALocalizationConstants.h"
#import "AFAUIConstants.h"
#import "AFABusinessConstants.h"

// Cells
#import "AFACredentialTextFieldTableViewCell.h"
#import "AFASignInTableViewCell.h"
#import "AFARememberCredentialsTableViewCell.h"
#import "AFASecurityLayerTableViewCell.h"

@interface AFALoginCredentialsViewControllerDataSource () <AFACredentialTextFieldTableViewCellDelegate,
                                                           AFASignInButtonDelegate>

@property (assign, nonatomic) AFALoginCredentialEditing     credentialEditing;

// KVO
@property (strong, nonatomic) ASDKKVOManager                *kvoManager;

@end

@implementation AFALoginCredentialsViewControllerDataSource

- (instancetype)initWithLoginModel:(AFALoginViewModel *)loginModel {
    self = [super init];
    
    if (self) {
        _loginModel = loginModel;
        _loginModel.authState = AFALoginAuthenticationStatePreparing;
        _kvoManager = [ASDKKVOManager managerWithObserver:self];
    }
    
    return self;
}


#pragma mark -
#pragma mark AFACredentialTextFieldTableViewCellDelegate

- (void)inputTextFieldWillBeginEditting:(UITextField *)inputTextField
                                 inCell:(UITableViewCell *)cell{
    // First field is already being edited
    if (self.credentialEditing & AFALoginCredentialEditingFirstField) {
        self.credentialEditing |= AFALoginCredentialEditingSecondField;
    } else if (self.credentialEditing & AFALoginCredentialEditingSecondField) { // Second field is already being edited
        self.credentialEditing |= AFALoginCredentialEditingFirstField;
    } else {
        self.credentialEditing |= AFALoginCredentialEditingFirstField;
    }
    
    self.loginModel.isCredentialInputInProgress = YES;
}

- (void)inputTextFieldWillEndEditting:(UITextField *)inputTextField
                               inCell:(UITableViewCell *)cell{
    // Stop editing first field
    if (self.credentialEditing & AFALoginCredentialEditingFirstField) {
        self.credentialEditing &= ~AFALoginCredentialEditingFirstField;
    } else if (self.credentialEditing & AFALoginCredentialEditingSecondField) { // Stop editing the second field
        self.credentialEditing &= ~AFALoginCredentialEditingSecondField;
    }
    
    // Check and update final state - no other fields being edited
    if (!(self.credentialEditing & AFALoginCredentialEditingFirstField) &&
        !(self.credentialEditing & AFALoginCredentialEditingSecondField)) {
        self.loginModel.isCredentialInputInProgress = NO;
    }
}

- (void)inputTextFieldShouldReturn:(UITextField *)inputTextField
                            inCell:(UITableViewCell *)cell {
    NSInteger nextTag = inputTextField.tag + 1;
    
    if ([self.delegate respondsToSelector:@selector(jumpFromTextField:toNextTextFieldWithTag:)]) {
        [self.delegate jumpFromTextField:inputTextField
                  toNextTextFieldWithTag:nextTag];
    }
}


#pragma mark -
#pragma mark AFASignInButton Delegate

- (void)onSignIn:(id)sender
        fromCell:(UITableViewCell *)cell {
    self.loginModel.isCredentialInputInProgress = NO;
    
    // If the login type is of cloud type then update the model with
    // the default host name and security layer
    if (AFALoginAuthenticationTypeCloud == self.loginModel.authentificationType) {
        [self.loginModel updateHostNameEntry:kASDKAPICloudHostnamePath];
        [self.loginModel updateCommunicationOverSecureLayer:YES];
        [self.loginModel updatePortEntry:nil];
    }
    
    // Do all mandatory fields have informations needed in order to login
    if ([self.loginModel canUserSignIn]) {
        if ([self.delegate respondsToSelector:@selector(lockInterface:)]) {
            [self.delegate lockInterface:YES];
        }
        
        __weak typeof(self) weakSelf = self;
        [self.loginModel requestLoginWithCompletionBlock:^(BOOL isLoggedIn, NSError *error) {
            __strong typeof(self) strongSelf = weakSelf;
            if ([strongSelf.delegate respondsToSelector:@selector(lockInterface:)]) {
                [strongSelf.delegate lockInterface:NO];
            }
            
            // Notify the user about the error
            if (error) {
                NSInteger responseCode = 0;
                BOOL disregardError = NO;
                
                // Handle internal generated errors
                if (AFALoginViewModelErrorDomain == error.domain) {
                    // If reachability exists but the error is triggered by a cached data value mismatch disregard
                    // the error and fall back to the server response
                    if (kAFALoginViewModelInvalidCredentialErrorCode == error.code &&
                        !strongSelf.delegate.isNetworkReachable) {
                        responseCode = ASDKHTTPCode401Unauthorised;
                    } else {
                        disregardError = YES;
                    }
                } else { // Handle network generated errors
                    NSError *underlayingError = error.userInfo[NSUnderlyingErrorKey];
                    if (underlayingError) {
                        responseCode = [[underlayingError.userInfo objectForKey:AFNetworkingOperationFailingURLResponseErrorKey] statusCode];
                        if (!responseCode) {
                            responseCode = underlayingError.code;
                        }
                    } else {
                        NSHTTPURLResponse *urlResponse = error.userInfo[AFNetworkingOperationFailingURLResponseErrorKey];
                        responseCode = urlResponse.statusCode;
                    }
                }
                
                if (!disregardError) {
                    NSString *networkErrorMessage = nil;
                    switch (responseCode) {
                        case ASDKHTTPCode401Unauthorised:
                        case ASDKHTTPCode403Forbidden: {
                            networkErrorMessage = NSLocalizedString(kLocalizationLoginInvalidCredentialsText, @"Invalid credentials text");
                        }
                            break;
                            
                        case NSURLErrorCannotConnectToHost: {
                            networkErrorMessage = NSLocalizedString(kLocalizationLoginUnreachableHostText, @"Unreachable host text");
                        }
                            break;
                            
                        case NSURLErrorTimedOut: {
                            networkErrorMessage = NSLocalizedString(kLocalizationLoginTimedOutText, @"Login timed out text");
                        }
                            break;
                            
                        default: break;
                    }
                    
                    if ([strongSelf.delegate respondsToSelector:@selector(handleNetworkErrorWithMessage:)]) {
                        [strongSelf.delegate handleNetworkErrorWithMessage:networkErrorMessage];
                    }
                    
                    [(AFASignInTableViewCell *)cell shakeSignInButton];
                }
            }
        }];
    } else {
        // Notify the user that something is wrong
        [(AFASignInTableViewCell *)cell shakeSignInButton];
    }
}


#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // For the cloud login we just have 2 sections, a simple username / password pair of fields
    // and the sign in section
    return (AFALoginAuthenticationTypePremise == self.loginModel.authentificationType) ? AFAPremiseLoginSectionTypeEnumCount : 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rowCount = 0;
    
    switch (self.loginModel.authentificationType) {
        case AFALoginAuthenticationTypeCloud: {
            if (AFACloudLoginSectionTypeAccountDetails == section) {
                rowCount = AFACloudLoginCredentialsCellTypeEnumCount;
            } else {
                rowCount = AFASignInSectionCellTypeEnumCount;
            }
        }
            break;
            
        case AFALoginAuthenticationTypePremise: {
            if (AFAPremiseLoginSectionTypeAccountDetails == section) {
                rowCount = AFAPremiseLoginCredentialsCellTypeEnumCount;
            } else if (AFAPremiseLoginSectionTypeAdvanced == section) {
                rowCount = AFAPremiseLoginAdvancedCredentialsCellTypeEnumCount;
            } else {
                rowCount = AFASignInSectionCellTypeEnumCount;
            }
        }
            break;
            
        default:
            break;
    }
    
    return rowCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    
    // Check if we're presenting a premise or cloud screen
    if (AFALoginAuthenticationTypePremise == self.loginModel.authentificationType) {
        
        // Handle the dequeuing of each section that make up the premise login
        if (AFAPremiseLoginSectionTypeAccountDetails == indexPath.section) {
            switch (indexPath.row) {
                case AFAPremiseLoginCredentialsCellTypeHostname: {
                    cell = [self dequeueHostNameCellForTableView:tableView
                                                       indexPath:indexPath];
                }
                    break;
                    
                case AFAPremiseLoginCredentialsCellTypeEmail: {
                    cell = [self dequeueEmailCellForTableView:tableView
                                                    indexPath:indexPath];
                }
                    break;
                    
                case AFAPremiseLoginCredentialsCellTypePassword: {
                    cell = [self dequeuePasswordCellForTableView:tableView
                                                       indexPath:indexPath];
                }
                    break;
                    
                default:
                    break;
            }
        } else if (AFAPremiseLoginSectionTypeAdvanced == indexPath.section) {
            switch (indexPath.row) {
                case AFAPremiseLoginAdvancedCredentialsCellTypeSecurityLayer: {
                    cell = [self dequeueSecurityLayerCellForTableView:tableView
                                                            indexPath:indexPath];
                }
                    break;
                    
                case AFAPremiseLoginAdvancedCredentialsCellTypePort: {
                    cell = [self dequeuePortCellForTableView:tableView
                                                   indexPath:indexPath];
                }
                    break;
                    
                case AFAPremiseLoginAdvancedCredentialsCellTypeServiceDocument: {
                    cell = [self dequeueServiceDocumentCellForTableView:tableView
                                                              indexPath:indexPath];
                }
                    break;
                    
                default:
                    break;
            }
        } else {
            switch (indexPath.row) {
                case AFASignInSectionCellTypeRememberCredentials: {
                    cell = [self dequeueRememberCredentialsCellForTableView:tableView
                                                                  indexPath:indexPath];
                }
                    break;
                    
                case AFASignInSectionCellTypeSignIn: {
                    cell = [self dequeueSignInCellForTableView:tableView];
                }
                    break;
                    
                default:
                    break;
            }
        }
    } else {
        // Handle the dequeuing of each section that make up the cloud login
        if (AFACloudLoginSectionTypeAccountDetails == indexPath.section) {
            switch (indexPath.row) {
                case AFACloudLoginCredentialsCellTypeEmail: {
                    cell = [self dequeueEmailCellForTableView:tableView
                                                    indexPath:indexPath];
                }
                    break;
                    
                case AFACloudLoginCredentialsCellTypePassword: {
                    cell = [self dequeuePasswordCellForTableView:tableView
                                                       indexPath:indexPath];
                }
                    break;
                    
                default:
                    break;
            }
        } else {
            switch (indexPath.row) {
                case AFASignInSectionCellTypeRememberCredentials: {
                    cell = [self dequeueRememberCredentialsCellForTableView:tableView
                                                                  indexPath:indexPath];
                }
                    break;
                    
                case AFASignInSectionCellTypeSignIn: {
                    cell = [self dequeueSignInCellForTableView:tableView];
                }
                    break;
                    
                default:
                    break;
            }
        }
    }
    
    cell.backgroundColor = [UIColor clearColor];
    
    if (!cell) {
        cell = [UITableViewCell new];
    }
    
    return cell;
}


#pragma mark -
#pragma mark Cell builders

- (void)registerStateHandlerForCredentialCell:(AFACredentialTextFieldTableViewCell *)credentialCell {
    __weak typeof(self) weakSelf = self;
    [self.kvoManager observeObject:credentialCell
                        forKeyPath:NSStringFromSelector(@selector(inputText))
                           options:NSKeyValueObservingOptionNew
                             block:^(id observer, id object, NSDictionary *change) {
                                 __strong typeof(self) strongSelf = weakSelf;
                                 
                                 switch (credentialCell.inputTextField.tag) {
                                     case AFALoginCredentialsFocusFieldOrderUsername: {
                                         [strongSelf.loginModel updateUserNameEntry:change[NSKeyValueChangeNewKey]];
                                     }
                                         break;
                                         
                                     case AFALoginCredentialsFocusFieldOrderPassword: {
                                         [strongSelf.loginModel updatePasswordEntry:change[NSKeyValueChangeNewKey]];
                                     }
                                         break;
                                         
                                     case AFALoginCredentialsFocusFieldOrderHostname: {
                                         [strongSelf.loginModel updateHostNameEntry:change[NSKeyValueChangeNewKey]];
                                     }
                                         break;
                                         
                                     case AFALoginCredentialsFocusFieldOrderPort: {
                                         [strongSelf.loginModel updatePortEntry:change[NSKeyValueChangeNewKey]];
                                     }
                                         break;
                                         
                                     case AFALoginCredentialsFocusFieldOrderServiceDocument: {
                                         [strongSelf.loginModel updateServiceDocument:change[NSKeyValueChangeNewKey]];
                                     }
                                         break;
                                         
                                     default:
                                         break;
                                 }
                             }];
}

- (AFASecurityLayerTableViewCell *)dequeueSecurityLayerCellForTableView:(UITableView *)tableView
                                                              indexPath:(NSIndexPath *)indexPath {
    AFASecurityLayerTableViewCell *securityLayerCell = [tableView dequeueReusableCellWithIdentifier:kCellIDSecurityLayer
                                                                                       forIndexPath:indexPath];
    securityLayerCell.switchViewButton.isOn = self.loginModel.isSecureLayer;
    
    __weak typeof(self) weakSelf = self;
    [self.kvoManager observeObject:securityLayerCell.switchViewButton
                        forKeyPath:NSStringFromSelector(@selector(isOn))
                           options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                             block:^(id observer, id object, NSDictionary *change) {
                                 __strong typeof(self) strongSelf = weakSelf;
                                 
                                 // Avoid updating the login model for the same key values
                                 if ([change[NSKeyValueChangeNewKey] boolValue] != [change[NSKeyValueChangeOldKey] boolValue]) {
                                     BOOL isHTTPS = [change[NSKeyValueChangeNewKey] boolValue];
                                     
                                     [strongSelf.loginModel updateCommunicationOverSecureLayer:isHTTPS];
                                     [strongSelf.loginModel updatePortEntry:isHTTPS ? [@(kDefaultLoginSecuredPort) stringValue] : [@(kDefaultLoginUnsecuredPort) stringValue]];
                                     
                                     [tableView reloadRowsAtIndexPaths:
                                      @[[NSIndexPath indexPathForRow:AFAPremiseLoginAdvancedCredentialsCellTypePort
                                                           inSection:AFAPremiseLoginSectionTypeAdvanced]]
                                                      withRowAnimation:UITableViewRowAnimationFade];
                                 }
                             }];
    
    return securityLayerCell;
}

- (AFACredentialTextFieldTableViewCell *)dequeueHostNameCellForTableView:(UITableView *)tableView
                                                               indexPath:(NSIndexPath *)indexPath {
    AFACredentialTextFieldTableViewCell *credentialCell = [tableView dequeueReusableCellWithIdentifier:kCellIDCredentialTextField
                                                                                          forIndexPath:indexPath];
    credentialCell.delegate = self;
    credentialCell.inputTextField.attributedPlaceholder = self.loginModel.hostnameAttributedPlaceholderText;
    credentialCell.inputTextField.text = self.loginModel.hostName;
    credentialCell.inputTextField.tag = AFALoginCredentialsFocusFieldOrderHostname;
    [self registerStateHandlerForCredentialCell:credentialCell];
    
    return credentialCell;
}

- (AFACredentialTextFieldTableViewCell *)dequeueEmailCellForTableView:(UITableView *)tableView
                                                            indexPath:(NSIndexPath *)indexPath {
    AFACredentialTextFieldTableViewCell *credentialCell = [tableView dequeueReusableCellWithIdentifier:kCellIDCredentialTextField
                                                                                          forIndexPath:indexPath];
    credentialCell.delegate = self;
    
    credentialCell.inputTextField.attributedPlaceholder = self.loginModel.usernameAttributedPlaceholderText;
    credentialCell.inputTextField.text = self.loginModel.username;
    credentialCell.inputTextField.keyboardType = UIKeyboardTypeEmailAddress;
    credentialCell.inputTextField.tag = AFALoginCredentialsFocusFieldOrderUsername;
    [self registerStateHandlerForCredentialCell:credentialCell];
    
    return credentialCell;
}

- (AFACredentialTextFieldTableViewCell *)dequeuePasswordCellForTableView:(UITableView *)tableView
                                                               indexPath:(NSIndexPath *)indexPath {
    AFACredentialTextFieldTableViewCell *credentialCell = [tableView dequeueReusableCellWithIdentifier:kCellIDCredentialTextField
                                                                                          forIndexPath:indexPath];
    credentialCell.delegate = self;
    
    credentialCell.inputTextField.attributedPlaceholder = self.loginModel.passwordAttributedPlaceholderText;
    credentialCell.inputTextField.text = self.loginModel.password;
    credentialCell.inputTextField.secureTextEntry = YES;
    credentialCell.inputTextField.tag = AFALoginCredentialsFocusFieldOrderPassword;
    credentialCell.inputTextField.returnKeyType = (AFALoginAuthenticationTypeCloud == self.loginModel.authentificationType) ? UIReturnKeyDone : UIReturnKeyNext;
    credentialCell.cellType = AFACredentialTextFieldCellTypeSecured;
    [self registerStateHandlerForCredentialCell:credentialCell];
    
    return credentialCell;
}

- (AFACredentialTextFieldTableViewCell *)dequeuePortCellForTableView:(UITableView *)tableView
                                                           indexPath:(NSIndexPath *)indexPath {
    AFACredentialTextFieldTableViewCell *credentialCell = [tableView dequeueReusableCellWithIdentifier:kCellIDCredentialTextField
                                                                                          forIndexPath:indexPath];
    credentialCell.delegate = self;
    
    credentialCell.inputTextField.attributedPlaceholder = self.loginModel.portAttributedPlaceholderText;
    credentialCell.inputTextField.text = self.loginModel.port;
    credentialCell.inputTextField.keyboardType = UIKeyboardTypeNumberPad;
    credentialCell.inputTextField.tag = AFALoginCredentialsFocusFieldOrderPort;
    credentialCell.cellType = AFACredentialTextFieldCellTypeUnsecured;
    [self registerStateHandlerForCredentialCell:credentialCell];
    
    return credentialCell;
}

- (AFACredentialTextFieldTableViewCell *)dequeueServiceDocumentCellForTableView:(UITableView *)tableView
                                                                      indexPath:(NSIndexPath *)indexPath {
    AFACredentialTextFieldTableViewCell *credentialCell = [tableView dequeueReusableCellWithIdentifier:kCellIDCredentialTextField
                                                                                          forIndexPath:indexPath];
    credentialCell.delegate = self;
    
    credentialCell.inputTextField.attributedPlaceholder = self.loginModel.serviceDocumentAttributedPlaceholderText;
    credentialCell.inputTextField.text =self.loginModel.serviceDocument;
    credentialCell.inputTextField.tag = AFALoginCredentialsFocusFieldOrderServiceDocument;
    credentialCell.inputTextField.returnKeyType = UIReturnKeyDone;
    [self registerStateHandlerForCredentialCell:credentialCell];
    
    return credentialCell;
}

- (AFARememberCredentialsTableViewCell *)dequeueRememberCredentialsCellForTableView:(UITableView *)tableView
                                                                          indexPath:(NSIndexPath *)indexPath {
    AFARememberCredentialsTableViewCell *rememberCredentialsCell = [tableView dequeueReusableCellWithIdentifier:kCellIDRememberCredentials
                                                                                                   forIndexPath:indexPath];
    rememberCredentialsCell.checkBox.selected = self.loginModel.rememberCredentials;
    
    __weak typeof(self) weakSelf = self;
    [self.kvoManager observeObject:rememberCredentialsCell.checkBox
                        forKeyPath:@"selected"
                           options:NSKeyValueObservingOptionNew
                             block:^(id observer, id object, NSDictionary *change) {
                                 __strong typeof(self) strongSelf = weakSelf;
                                 [strongSelf.loginModel updateRememberCredentials:[change[NSKeyValueChangeNewKey] boolValue]];
                             }];
    
    return rememberCredentialsCell;
}

- (AFASignInTableViewCell *)dequeueSignInCellForTableView:(UITableView *)tableView {
    AFASignInTableViewCell *signInCell = [tableView dequeueReusableCellWithIdentifier:kCellIDSignInButton];
    signInCell.delegate = self;
    
    return signInCell;
}



@end

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

@import UIKit;
@import ActivitiSDK;

typedef NS_ENUM(NSInteger, AFAProfileControllerSectionType) {
    AFAProfileControllerSectionTypeContactInformation = 0,
    AFAProfileControllerSectionTypeGroups,
    AFAProfileControllerSectionTypeChangePassord,
    AFAProfileControllerSectionTypeEnumCount
};

typedef NS_ENUM(NSInteger, AFAProfileControllerContactInformationType) {
    AFAProfileControllerContactInformationTypeEmail = 0,
    AFAProfileControllerContactInformationTypeCompany,
    AFAProfileControllerContactInformationTypeEnumCount
};

@protocol AFAProfileViewControllerDataSourceDelegate <NSObject>

- (void)handleNetworkErrorWithMessage:(NSString *)errorMessage;
- (void)updateProfilePasswordWithNewPassword:(NSString *)updatedPassword
                                 oldPassword:(NSString *)oldPassword;
- (void)presentAlertController:(UIAlertController *)alertController;
- (void)showProfileSaveButton:(BOOL)isSaveButtonEnabled;
- (void)updateProfileInformation;

@end

@protocol AFAProfileViewControllerDataSource <NSObject, UITableViewDataSource>

- (instancetype)initWithProfile:(ASDKModelProfile *)profile;
- (void)rollbackProfileChanges;
- (BOOL)isProfileUpdated;
- (void)challengeUserCredentialsForProfileUpdate;

@property (weak, nonatomic) id<AFAProfileViewControllerDataSourceDelegate> delegate;
@property (strong, nonatomic, readonly) ASDKModelProfile *currentProfile;

@end

@interface AFAProfileViewControllerDataSource : NSObject <AFAProfileViewControllerDataSource>

@property (weak, nonatomic) id<AFAProfileViewControllerDataSourceDelegate> delegate;
@property (strong, nonatomic, readonly) ASDKModelProfile    *currentProfile;
@property (assign, nonatomic) BOOL                          isInputEnabled;

@end

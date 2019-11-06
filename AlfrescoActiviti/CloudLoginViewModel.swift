/*******************************************************************************
* Copyright (C) 2005-2018 Alfresco Software Limited.
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

import Foundation

class CloudLoginViewModel {
    let processServicessAppText = NSLocalizedString(kLocalizationLoginScreenProcessServicesAppText, comment: "App name")
    let infoText = NSLocalizedString(kLocalizationCloudLoginInfoText, comment: "Info")
    let usernamaPlaceholderText = NSLocalizedString(kLocalizationCloudLoginUsernamePlaceholderText, comment: "Username")
    let passwordPlaceholderText = NSLocalizedString(kLocalizationCloudLoginPasswordPlaceholderText, comment: "Password")
    let signInButtonText = NSLocalizedString(kLocalizationCloudLoginSignInButtonText, comment: "SIGN IN")
    let closeText = NSLocalizedString(kLocalizationAdvancedSettingsScreenCloseText, comment: "Close")
    let helpButtonText = NSLocalizedString(kLocalizationAdvancedSettingsScreenHelpButtonText, comment: "Need Help")
    let helpText = NSLocalizedString(kLocalizationAdvancedSettingsScreenHelpText, comment: "Help")
    let helpHintText = NSLocalizedString(kLocalizationAdvancedSettingsScreenHelpHintText, comment: "Help")
    var copyrightText: String {
        get {
            let calendar = Calendar.current
            let year = calendar.component(.year, from: Date())
            return String(format: NSLocalizedString(kLocalizationLoginScreenCopyrightFormat, comment: "Copyright text"), year)
        }
    }

    func signIn(username: String, password: String) {
        let credentialModel = AFACredentialModel()
        let aimsParameters = AdvancedSettingsParameters.parameters()
        credentialModel.hostname = aimsParameters.hostname
        credentialModel.isCommunicationOverSecureLayer = aimsParameters.https
        credentialModel.port = aimsParameters.port
        credentialModel.serviceDocument = aimsParameters.serviceDocument
        credentialModel.username = username
        credentialModel.password = password
    }
}

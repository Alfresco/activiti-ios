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
import AlfrescoAuth

class AIMSLoginViewModel {
    // Localization
    let processServicessAppText = NSLocalizedString(kLocalizationLoginScreenProcessServicesAppText, comment: "App name")
    let alfrescoURLPlaceholderText = NSLocalizedString(kLocalizationLoginScreenAlfrescoURLPlaceholderText, comment: "Alfresco URL")
    let connectButtonText = NSLocalizedString(kLocalizationLoginScreenConnectButtonText, comment: "Connect button")
    let cloudSignInButtonText = NSLocalizedString(kLocalizationLoginScreenCloudSignInButtonText, comment: "Cloud sign in button")
    let advancedSettingsButtonText = NSLocalizedString(kLocalizationLoginScreenAdvancedSettingsButtonText, comment: "Advanced settings button")
    let helpButtonText = NSLocalizedString(kLocalizationAdvancedSettingsScreenHelpButtonText, comment: "Need Help")
    let closeText = NSLocalizedString(kLocalizationAdvancedSettingsScreenCloseText, comment: "Close")
    let helpText = NSLocalizedString(kLocalizationAdvancedSettingsScreenHelpText, comment: "Help")
    let helpHintText = NSLocalizedString(kLocalizationLoginScreenIdentityServiceURLHintText, comment: "Hint text")
    var copyrightText: String {
        get {
            let calendar = Calendar.current
            let year = calendar.component(.year, from: Date())
            return String(format: NSLocalizedString(kLocalizationLoginScreenCopyrightFormat, comment: "Copyright text"), year)
        }
    }
    
    // Authentication service
    var authenticationService: AIMSLoginService?
    
    // Authentication parameters
    var authenticationParameters = AIMSAdvancedSettingsViewModel()

    func updateIdentityServiceParameters(with url: String, isSecureConnection: Bool) {
        let fullFormatURL = serviceURL(url: url, isSecureConnection: isSecureConnection)
        authenticationService?.authenticationParameters.identityServiceURL = fullFormatURL
    }
    
    func updateProcessParameters(with url: String, isSecureConnection: Bool) {
        let fullFormatURL = serviceURL(url: url, isSecureConnection: isSecureConnection)
        authenticationService?.authenticationParameters.processURL = fullFormatURL
    }
    
    func login(onViewController viewController: UIViewController) {
        authenticationService?.login(onViewController: viewController, delegate: self)
    }
    
    // MARK: Private
    
    func serviceURL(url: String, isSecureConnection: Bool) -> String {
        let fullFormatURL = String(format:"%@://%@", isSecureConnection ? "https" : "http", url)
        return fullFormatURL
    }
}

//MARK: - AlfrescoAuth Delegate
extension AIMSLoginViewModel: AlfrescoAuthDelegate {
    func didReceive(result: Result<AlfrescoCredential, APIError>) {
//        switch result {
//        case .success(let alfrescoCredential):
//
//
//        case .failure(let error):
//
//        }
    }
}

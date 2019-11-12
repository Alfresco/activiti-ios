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

class AIMSSSOViewModel {
    let processServicessAppText = NSLocalizedString(kLocalizationLoginScreenProcessServicesAppText, comment: "App name")
    let subtitle1Text = NSLocalizedString(kLocalizationSSOLoginSubtitle1Text, comment: "Info")
    let subtitle2Text = NSLocalizedString(kLocalizationSSOLoginSubtitle2Text, comment: "Info")
    let repositoryPlaceholderText = NSLocalizedString(kLocalizationSSOLoginRepositoryPlaceholderText, comment: "Repository")
    let signInSSOButtonText = NSLocalizedString(kLocalizationSSOLoginSignInSSOButtonText, comment: "SIGN IN WITH SSO")
    let closeText = NSLocalizedString(kLocalizationAdvancedSettingsScreenCloseText, comment: "Close")
    let helpButtonText = NSLocalizedString(kLocalizationAdvancedSettingsScreenHelpButtonText, comment: "Need Help")
    let helpText = NSLocalizedString(kLocalizationAdvancedSettingsScreenHelpText, comment: "Help")
    let helpHintText = NSLocalizedString(kLocalizationLoginScreenSSOHelpHintText, comment: "SSO Hint text")
    var copyrightText: String {
        get {
            let calendar = Calendar.current
            let year = calendar.component(.year, from: Date())
            return String(format: NSLocalizedString(kLocalizationLoginScreenCopyrightFormat, comment: "Copyright text"), year)
        }
    }
    
    var serverURLText: String {
        get {
            if let params = authParameters {
                return params.hostname
            }
            
            return ""
        }
    }
    
    
    // Authentication service
    var authParameters: AIMSAuthenticationParameters?
    var authenticationService: AIMSLoginService?
    
    func login(onViewController viewController: UIViewController) {
        if let authParameters = self.authParameters {
            authenticationService = AIMSLoginService(with: authParameters)
            authenticationService?.login(onViewController: viewController, delegate: self)
        }
    }
}

//MARK: - AlfrescoAuth Delegate
extension AIMSSSOViewModel: AlfrescoAuthDelegate {
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

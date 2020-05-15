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

import Foundation
import AlfrescoAuth

protocol AIMSLoginViewModelDelegate: class {
    func authenticationServiceAvailable(for authType:AvailableAuthType)
    func authenticationServiceUnavailable(with error:APIError)
}

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
    weak var delegate: AIMSLoginViewModelDelegate?
    
    func availableAuthType(for url: String) {
        let authParameters = AIMSAuthenticationParameters.parameters()
        authParameters.hostname = url
        
        authenticationService = AIMSLoginService(with: authParameters)
        AFAServiceRepository.shared()?.registerServiceObject(authenticationService, forPurpose: .aimsLogin)
        
        authenticationService?.availableAuthType(handler: { [weak self] (result) in
            guard let sSelf = self else { return }
            
            switch result {
            case .success(let authType):
                if AIMSAuthenticationParameters.parameters().hostname != authParameters.hostname {
                    authParameters.processURL = ""
                }
                authParameters.save()
                sSelf.delegate?.authenticationServiceAvailable(for: authType)
            case .failure(let error):
                AFALog.logError(error.localizedDescription)
                sSelf.delegate?.authenticationServiceUnavailable(with: error)
            }
        })
    }
    
    func prepareViewModel(for viewController: UIViewController, authenticationType: AvailableAuthType, isCloud: Bool = false) {
        switch authenticationType {
        case .aimsAuth:
            if let destinationVC = viewController as? AIMSSSOViewController {
                destinationVC.model.authParameters = authenticationService?.authenticationParameters
            }
        case .basicAuth:
            if let destinationVC = viewController as? BaseAuthLoginViewController {
                destinationVC.model.loginStrategy = isCloud ? CloudLoginStrategy() : PremiseLoginStrategy()
            }
        }
    }
}

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
        
        authenticationService?.availableAuthType(for: authParameters.fullFormatURL, handler: { [weak self] (result) in
            guard let sSelf = self else { return }
            
            switch result {
            case .success(let authType):
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
    
    func buildURL(_ string: String?) -> String {
        if let alfrescoURL = string {
            if alfrescoURL.isEmpty == false {
                var validateURL = validateHttp(alfrescoURL)
                validateURL = validatePort(validateURL)
                return validateURL
            }
        }
        return ""
    }
    
    func urlHasHttp(_ string: String) -> Bool {
        if string.contains("https://") || string.contains("http://") {
            return true
        }
        return false
    }
    
    func validatePort(_ string: String) -> String {
        let parameters = AIMSAuthenticationParameters.parameters()
        let splitPort = string.components(separatedBy: ":")
        var stringValidate = string
        if splitPort.count > 1 {
            if urlHasHttp(stringValidate) && splitPort.count == 2 {
                return stringValidate
            }
            if let port = splitPort.last {
                if port.count <= 4 && port.isNumeric {
                    parameters.port = port
                    stringValidate = string.replacingOccurrences(of: ":\(port)", with: "")
                }
            }
        }
        parameters.save()
        return stringValidate
    }
    
    func validateHttp(_ string: String) -> String {
        let splitHttp = string.components(separatedBy: "://")
        let parameters = AIMSAuthenticationParameters.parameters()
        var stringValidate = string
        if splitHttp.count > 1 {
            if splitHttp[0] == "http" {
                parameters.https = false
                stringValidate = string.replacingOccurrences(of: "http://", with: "")
            } else if splitHttp[0] == "https" {
                parameters.https = true
                stringValidate = string.replacingOccurrences(of: "https://", with: "")
            }
        }
        parameters.save()
        return stringValidate
    }
}

extension String {
    var isNumeric: Bool {
        guard self.count > 0 else { return false }
        let nums: Set<Character> = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
        return Set(self).isSubset(of: nums)
    }
}

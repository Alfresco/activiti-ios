/*******************************************************************************
 * Copyright (C) 2005-2018 Alfresco Software Limited.
 *
 * This file is part of the Alfresco Activiti iOS App.
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

protocol BaseAuthLoginStrategyProtocol {
    var infoText: String { get }
    var helpText: String { get }
    var processServicessAppText: String { get }
    var usernamaPlaceholderText: String { get }
    var passwordPlaceholderText: String { get }
    var signInButtonText: String { get }
    var closeText: String { get }
    var helpButtonText: String { get }
    var helpHintText: String { get }
    var copyrightText: String { get }
    var serverConfiguration: ASDKModelServerConfiguration? { get set }
    
    func serverConfiguration(for username: String, _ password: String) -> Result<ASDKModelServerConfiguration, NSError>
    func syncToUserDefaultsServerConfiguration()
}

class BaseLoginStrategy {
    let processServicessAppText = NSLocalizedString(kLocalizationLoginScreenProcessServicesAppText, comment: "App name")
    let usernamaPlaceholderText = NSLocalizedString(kLocalizationCloudLoginUsernamePlaceholderText, comment: "Username")
    let passwordPlaceholderText = NSLocalizedString(kLocalizationCloudLoginPasswordPlaceholderText, comment: "Password")
    let signInButtonText = NSLocalizedString(kLocalizationCloudLoginSignInButtonText, comment: "SIGN IN")
    let closeText = NSLocalizedString(kLocalizationAdvancedSettingsScreenCloseText, comment: "Close")
    let helpButtonText = NSLocalizedString(kLocalizationAdvancedSettingsScreenHelpButtonText, comment: "Need Help")
    let helpHintText = NSLocalizedString(kLocalizationAdvancedSettingsScreenHelpHintText, comment: "Help")
    var copyrightText: String {
        get {
            let calendar = Calendar.current
            let year = calendar.component(.year, from: Date())
            return String(format: NSLocalizedString(kLocalizationLoginScreenCopyrightFormat, comment: "Copyright text"), year)
        }
    }
}

class CloudLoginStrategy:BaseLoginStrategy, BaseAuthLoginStrategyProtocol {
    let infoText = NSLocalizedString(kLocalizationCloudLoginInfoText, comment: "Login info")
    let helpText = NSLocalizedString(kLocalizationAdvancedSettingsScreenHelpText, comment: "Help")
    var serverConfiguration: ASDKModelServerConfiguration?
    
    func serverConfiguration(for username: String, _ password: String) -> Result<ASDKModelServerConfiguration, NSError> {
        let serverConfiguration = ASDKModelServerConfiguration()
        serverConfiguration.hostAddressString = kASDKAPICloudHostnamePath
        serverConfiguration.isCommunicationOverSecureLayer = true
        serverConfiguration.serviceDocument = kASDKAPIApplicationPath
        serverConfiguration.username = username
        serverConfiguration.password = password
        self.serverConfiguration = serverConfiguration
        return .success(serverConfiguration)
    }
    
    func syncToUserDefaultsServerConfiguration() {
        let sud = UserDefaults.standard
        sud.set(kCloudAuthetificationCredentialIdentifier, forKey: kAuthentificationTypeCredentialIdentifier)
        
        if let serverConfiguration = self.serverConfiguration {
            sud.set(serverConfiguration.hostAddressString, forKey: kCloudHostNameCredentialIdentifier)
            sud.set(serverConfiguration.isCommunicationOverSecureLayer, forKey: kCloudSecureLayerCredentialIdentifier)
            sud.set(serverConfiguration.username, forKey: kCloudUsernameCredentialIdentifier)
        }
        
        sud.synchronize()
    }
}

class PremiseLoginStrategy:BaseLoginStrategy, BaseAuthLoginStrategyProtocol {
    var infoText: String {
        get {
            let aimsParameters = AIMSAuthenticationParameters.parameters()
            return String(format: NSLocalizedString(kLocalizationLoginScreenOnPremiseSigningInToHintFormat, comment: "Info"), aimsParameters.hostname)
        }
    }
    let helpText = NSLocalizedString(kLocalizationAdvancedSettingsScreenHelpText, comment: "Help")
    var serverConfiguration: ASDKModelServerConfiguration?
    
    func serverConfiguration(for username: String, _ password: String) -> Result<ASDKModelServerConfiguration, NSError> {
        let aimsParameters = AIMSAuthenticationParameters.parameters()
        switch aimsParameters.checkAvailable(authentication: .baseAuthOnPremise) {
        case .success(_):
            let serverConfiguration = ASDKModelServerConfiguration()
            serverConfiguration.hostAddressString = aimsParameters.hostname
            serverConfiguration.isCommunicationOverSecureLayer = aimsParameters.https
            serverConfiguration.serviceDocument = aimsParameters.serviceDocument
            serverConfiguration.username = username
            serverConfiguration.password = password
            self.serverConfiguration = serverConfiguration
            return .success(serverConfiguration)
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func syncToUserDefaultsServerConfiguration() {
        let sud = UserDefaults.standard
        sud.set(kPremiseAuthentificationCredentialIdentifier, forKey: kAuthentificationTypeCredentialIdentifier)
        
        if let serverConfiguration = self.serverConfiguration {
            sud.set(serverConfiguration.hostAddressString, forKey: kPremiseHostNameCredentialIdentifier)
            sud.set(serverConfiguration.isCommunicationOverSecureLayer, forKey: kPremiseSecureLayerCredentialIdentifier)
            sud.set(serverConfiguration.username, forKey: kPremiseUsernameCredentialIdentifier)
        }
        
        sud.synchronize()
    }
}

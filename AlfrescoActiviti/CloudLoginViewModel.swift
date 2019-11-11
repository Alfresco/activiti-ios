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
    let requestProfileService = AFAProfileServices()
    var serverConfiguration: ASDKModelServerConfiguration!

    func signIn(username: String, password: String, completion: @escaping (Result<ASDKModelProfile, Error>) -> Void) {
        serverConfiguration = setServerConfiguration(with: username, password)
        let persistenceStackModelName = self.persistenceStackModelName()
        let sdkBootstrap = ASDKBootstrap.sharedInstance()
        sdkBootstrap?.setupServices(with: serverConfiguration)
        
        requestProfileService.requestProfile { [weak self] (profile, error) in
            guard let sSelf = self else { return }
            if let profile = profile {
                sSelf.syncToUserDefaultsServerConfiguration()
                if (AFAKeychainWrapper.keychainStringFrom(matchingIdentifier: persistenceStackModelName) != nil) {
                    AFAKeychainWrapper.updateKeychainValue(sSelf.serverConfiguration.password,
                                                           forIdentifier: persistenceStackModelName)
                } else {
                    AFAKeychainWrapper.createKeychainValue(sSelf.serverConfiguration.password,
                                                           forIdentifier: persistenceStackModelName)
                }

                completion(.success(profile))
            } else {
                if let error = error {
                    completion(.failure(error))
                }
            }
        }
    }
    
    func syncToUserDefaultsServerConfiguration() {
        let sud = UserDefaults.standard
        sud.set(kCloudAuthetificationCredentialIdentifier, forKey: kAuthentificationTypeCredentialIdentifier)
        sud.set(serverConfiguration.hostAddressString, forKey: kCloudHostNameCredentialIdentifier)
        sud.set(serverConfiguration.isCommunicationOverSecureLayer, forKey: kCloudSecureLayerCredentialIdentifier)
        sud.set(serverConfiguration.username, forKey: kCloudUsernameCredentialIdentifier)
        sud.synchronize()
    }
    
    func setServerConfiguration(with username: String, _ password: String) -> ASDKModelServerConfiguration {
        let aimsParameters = AdvancedSettingsParameters.parameters()
        let serverConfiguration = ASDKModelServerConfiguration()
        serverConfiguration.hostAddressString = aimsParameters.hostname
        serverConfiguration.isCommunicationOverSecureLayer = aimsParameters.https
        serverConfiguration.serviceDocument = aimsParameters.serviceDocument
        serverConfiguration.username = username
        serverConfiguration.password = password
        return serverConfiguration
    }
    
    func persistenceStackModelName() -> String {
        return ASDKPersistenceStack.persistenceStackModelName(for: serverConfiguration)
    }
}

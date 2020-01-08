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

protocol AIMSSSOViewModelDelegate: class {
    func logInFailed(with error: APIError)
    func logInSuccessful()
    func logInWarning(with message: String)
}

class AIMSSSOViewModel: AIMSLoginViewModelProtocol {
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
    
    fileprivate var alfrescoCredential: AlfrescoCredential?
    weak var delegate: AIMSSSOViewModelDelegate?
    
    // Authentication service
    var authParameters: AIMSAuthenticationParameters?
    var authenticationService: AIMSLoginService?
    
    func login(onViewController viewController: UIViewController) {
        if let authParameters = self.authParameters {
            switch authParameters.checkAvailable(authentication: .sso) {
            case .failure(let error):
                delegate?.logInWarning(with: error.localizedDescription)
            case .success(_):
                authenticationService = AIMSLoginService(with: authParameters)
                authenticationService?.login(onViewController: viewController, delegate: self)
            }
        }
    }
}

//MARK: - AlfrescoAuth Delegate
extension AIMSSSOViewModel: AlfrescoAuthDelegate {
    func didLogOut(result: Result<Int, APIError>) {}
    
    var serverConfiguration: ASDKModelServerConfiguration {
        get {
            let serverConfiguration = ASDKModelServerConfiguration()
            
            if let authParameters = self.authParameters {
                serverConfiguration.hostAddressString = authParameters.hostname
                serverConfiguration.isCommunicationOverSecureLayer = authParameters.https
                serverConfiguration.serviceDocument = authParameters.serviceDocument.encoding()
                serverConfiguration.port = authParameters.port
                
                if let aimsCredential = alfrescoCredential?.toASDKModelCredentialType() {
                    serverConfiguration.credential = aimsCredential
                }
            }
        
            return serverConfiguration
        }
    }
    
    func didReceive(result: Result<AlfrescoCredential, APIError>, session: AlfrescoAuthSession?) {
        switch result {
        case .success(let alfrescoCredential):
            // Persist the login type identifier
            let sud = UserDefaults.standard
            sud.set(kAIMSAuthenticationCredentialIdentifier, forKey: kAuthentificationTypeCredentialIdentifier)
            
            if let payload = alfrescoCredential.toASDKModelCredentialType().decodedJWTPayloadToken()[kASDKAIMSJwtTokenPayload] as? [String : Any] {
                sud.set(payload[kASDKAPIEmailParameter], forKey: kAIMSUsernameCredentialIdentifier)
            }
            sud.synchronize()
            
            // Save Alfresco credentials and server connection parameters
            self.alfrescoCredential = alfrescoCredential
            authParameters?.save()
            
            let persistenceStackModelName = self.persistenceStackModelName()
            
            let encoder = JSONEncoder()
            var credentialData: Data?
            var sessionData: Data?
           
            do {
                credentialData = try encoder.encode(alfrescoCredential)
                
                if let authSession = session {
                    sessionData = try NSKeyedArchiver.archivedData(withRootObject: authSession, requiringSecureCoding: true)
                }
            } catch {
                AFALog.logError("Unable to persist credentials to Keychain.")
            }
            
            if let cData = credentialData, let sData = sessionData {
                AFAKeychainWrapper.createKeychainData(cData, forIdentifier: persistenceStackModelName)
                AFAKeychainWrapper.createKeychainData(sData, forIdentifier: String(format: "%@-%@", persistenceStackModelName, kPersistenceStackSessionParameter))
            }
            
            // Initialize ActivitiSDK
            let sdkBootstrap = ASDKBootstrap.sharedInstance()
            sdkBootstrap?.setupServices(with: serverConfiguration)
            
            self.delegate?.logInSuccessful()
        case .failure(let error):
            self.delegate?.logInFailed(with: error)
        }
    }
    
    func persistenceStackModelName() -> String {
        return ASDKPersistenceStack.persistenceStackModelName(for: self.serverConfiguration)
    }
}

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

class AIMSSplashscreenViewModel: AIMSLoginViewModelProtocol {
    var serverConfiguration = ASDKModelServerConfiguration()
    
    func restoreLastSuccessfullSession() -> Bool {
        // Retrieve the last login type identifier
        let sud = UserDefaults.standard
        let lastLoginType = sud.string(forKey: kAuthentificationTypeCredentialIdentifier)
        
        // Recreate server configuration object
        let authParameters = AIMSAuthenticationParameters.parameters()
        serverConfiguration.hostAddressString = authParameters.processURL
        serverConfiguration.isCommunicationOverSecureLayer = authParameters.https
        serverConfiguration.serviceDocument = authParameters.serviceDocument.encoding()
        serverConfiguration.port = authParameters.port
        
        // Register login service
        let loginService = AIMSLoginService.init(with: authParameters)
        AFAServiceRepository.shared()?.registerServiceObject(loginService, forPurpose: .aimsLogin)
        
        switch lastLoginType {
        case kAIMSAuthenticationCredentialIdentifier:
            // Check for AIMS sessions
            let aimsUsername = sud.string(forKey: kAIMSUsernameCredentialIdentifier)
            if let username = aimsUsername {
                let normalizedHostName = NSString(string: serverConfiguration.hostAddressString).normalizedPersistenceStackName()
                let normalizedServiceDocument = NSString(string: serverConfiguration.serviceDocument).normalizedPersistenceStackName()
                let normalizedUsername = NSString(string: username).normalizedPersistenceStackName()
                let normalizedPersistenceStackName = String(format: "%@@%@@%@", normalizedHostName, normalizedServiceDocument, normalizedUsername)
                
                guard let retrievedData = AFAKeychainWrapper.dataFor(matchingIdentifier: normalizedPersistenceStackName) else { return false }
                let decoder = JSONDecoder()
                do {
                    let alfrescoCredential = try decoder.decode(AlfrescoCredential.self, from: retrievedData)
                    serverConfiguration.credential = alfrescoCredential.toASDKModelCredentialType()
                } catch {
                    AFALog.logError("Cannot decode credential information from the keychain")
                    return false
                }
            }
        case kPremiseAuthentificationCredentialIdentifier:
            if let premiseHostAdress = sud.string(forKey: kPremiseHostNameCredentialIdentifier) {
                serverConfiguration.hostAddressString = premiseHostAdress
            }
            serverConfiguration.isCommunicationOverSecureLayer = sud.bool(forKey: kPremiseSecureLayerCredentialIdentifier)
            
            var premiseUsername, premisePassword: String?
            premiseUsername = sud.string(forKey: kPremiseUsernameCredentialIdentifier)
            
            let baseAuthCredential = ASDKModelCredentialBaseAuth(username: premiseUsername ?? "", password: "")
            serverConfiguration.credential = baseAuthCredential
            
            premisePassword = AFAKeychainWrapper.keychainStringFrom(matchingIdentifier: persistenceStackModelName())
            
            if let username = premiseUsername, let password = premisePassword {
                let baseAuthCredential = ASDKModelCredentialBaseAuth.init(username: username, password: password)
                serverConfiguration.credential = baseAuthCredential
            } else {
                return false
            }
        case kCloudAuthetificationCredentialIdentifier:
            if let cloudHostAddress = sud.string(forKey: kCloudHostNameCredentialIdentifier) {
                serverConfiguration.hostAddressString = cloudHostAddress
            }
            
            var cloudUsername, cloudPassword : String?
            cloudUsername = sud.string(forKey: kCloudUsernameCredentialIdentifier)
            cloudPassword = AFAKeychainWrapper.keychainStringFrom(matchingIdentifier: persistenceStackModelName())
            
            if let username = cloudUsername, let password = cloudPassword {
                let baseAuthCredential = ASDKModelCredentialBaseAuth.init(username: username, password: password)
                serverConfiguration.credential = baseAuthCredential
            } else {
                return false
            }
        default:
            AFALog.logWarning("Restoring last session information failed or user has not logged in yet.")
            return false
        }
        
        // Initialize ActivitiSDK
        let sdkBootstrap = ASDKBootstrap.sharedInstance()
        sdkBootstrap?.setupServices(with: serverConfiguration)
        
        return true
    }
    
    
    func persistenceStackModelName() -> String {
        ASDKPersistenceStack.persistenceStackModelName(for: serverConfiguration)
    }
}

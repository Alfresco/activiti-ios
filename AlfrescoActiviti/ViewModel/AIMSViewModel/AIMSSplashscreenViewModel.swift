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
        serverConfiguration.hostAddressString = authParameters.hostname
        serverConfiguration.isCommunicationOverSecureLayer = authParameters.https
        serverConfiguration.serviceDocument = authParameters.serviceDocument
        serverConfiguration.port = authParameters.port
        
        switch lastLoginType {
        case kAIMSAuthenticationCredentialIdentifier:
            // Check for AIMS sessions
            guard let retrievedData = AFAKeychainWrapper.dataFor(matchingIdentifier: persistenceStackModelName()) else { return false }
            let decoder = JSONDecoder()
            do {
                let alfrescoCredential = try decoder.decode(AlfrescoCredential.self, from: retrievedData)
                serverConfiguration.acessToken = alfrescoCredential.accessToken
            } catch {
                AFALog.logError("Cannot decode credential information from the keychain")
                return false
            }
        case kPremiseAuthentificationCredentialIdentifier:
            if let premiseHostAdress = sud.string(forKey: kPremiseHostNameCredentialIdentifier) {
                serverConfiguration.hostAddressString = premiseHostAdress
            }
            if let premiseUsername = sud.string(forKey: kPremiseUsernameCredentialIdentifier) {
                serverConfiguration.username = premiseUsername
            }
            serverConfiguration.isCommunicationOverSecureLayer = sud.bool(forKey: kPremiseSecureLayerCredentialIdentifier)
            serverConfiguration.password = AFAKeychainWrapper.keychainStringFrom(matchingIdentifier: persistenceStackModelName())
        case kCloudAuthetificationCredentialIdentifier:
            if let cloudHostAddress = sud.string(forKey: kCloudHostNameCredentialIdentifier) {
                serverConfiguration.hostAddressString = cloudHostAddress
            }
            if let cloudUsername = sud.string(forKey: kCloudUsernameCredentialIdentifier) {
                serverConfiguration.username = cloudUsername
            }
            serverConfiguration.password = AFAKeychainWrapper.keychainStringFrom(matchingIdentifier: persistenceStackModelName())
        default:
            AFALog.logWarning("Restoring last session information failed or user has not logged in yet.")
            return false
        }
        
        if serverConfiguration.acessToken == nil && serverConfiguration.password == nil {
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

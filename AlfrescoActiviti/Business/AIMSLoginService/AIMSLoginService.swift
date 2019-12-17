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
import AlfrescoAuth

class AIMSLoginService: NSObject, AIMSLoginServiceProtocol {
    private (set) var authenticationParameters: AIMSAuthenticationParameters
    private (set) var alfrescoAuth: AlfrescoAuth?
    var session: AlfrescoAuthSession?
    
    init(with authenticationParameters: AIMSAuthenticationParameters) {
        self.authenticationParameters = authenticationParameters
    }
    
    //MARK: - AIMSLoginServiceProtocol
    func login(onViewController: UIViewController, delegate: AlfrescoAuthDelegate) {
        alfrescoAuth = authServiceForCurrentConfiguration()
        alfrescoAuth?.pkceAuth(onViewController: onViewController, delegate: delegate)
    }
    
    func availableAuthType(for url: String, handler: @escaping AvailableAuthTypeCallback<AvailableAuthType>) {
        alfrescoAuth = authServiceForCurrentConfiguration()
        alfrescoAuth?.availableAuthType(for: url, handler: handler)
    }
    
    func refreshSession(keychainIdentifier: String, delegate: AlfrescoAuthDelegate) {
        alfrescoAuth = authServiceForCurrentConfiguration()
        if let session = self.session {
            alfrescoAuth?.pkceRefresh(session: session, delegate: delegate)
        } else {
            // Restore last valid session from Keychain
            let errorDomain = Bundle.main.bundleName ?? AFAAIMSLoginErrorDomain
            let errorMessage = "Unable to refresh session"
            
            guard let data = AFAKeychainWrapper.dataFor(matchingIdentifier: keychainIdentifier) else {
                delegate.didReceive(result: .failure(APIError(domain: errorDomain, message: errorMessage)), session: nil)
                
                return
            }
            
            do {
                if let session = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? AlfrescoAuthSession {
                    self.session = session
                    alfrescoAuth?.pkceRefresh(session: session, delegate: delegate)
                } else {
                    delegate.didReceive(result: .failure(APIError(domain: errorDomain, message: errorMessage)), session: nil)
                }
            } catch {
                AFALog.logError("Unable to restore last valid session.")
                delegate.didReceive(result: .failure(APIError(domain: errorDomain, message: errorMessage)), session: nil)
            }
        }
    }
    
    func logout(onViewController viewController: UIViewController, delegate: AlfrescoAuthDelegate, forCredential credential: AlfrescoCredential) {
        session = nil
        alfrescoAuth?.logout(onViewController: viewController, delegate: delegate, forCredential: credential)
    }
    
    func updateAuthParameters(with parameters: AIMSAuthenticationParameters) {
        self.authenticationParameters = parameters
    }
    
    @objc func resumeExternalUserAgentFlow(with url: URL) -> Bool {
        if session == nil {
            session = AlfrescoAuthSession()
        }
        guard let authSession = session else { return false}
        return authSession.resumeExternalUserAgentFlow(with: url)
    }
    
    
    // MARK: - Private
    
    private func authConfiguration() -> AuthConfiguration {
        let authConfig = AuthConfiguration(baseUrl: authenticationParameters.fullFormatURL,
        clientID: authenticationParameters.clientID,
        realm: authenticationParameters.realm,
        redirectURI: authenticationParameters.redirectURI.encoding())
        
        return authConfig
    }
    
    private func authServiceForCurrentConfiguration() -> AlfrescoAuth {
        let authConfig = authConfiguration()
        return AlfrescoAuth.init(configuration: authConfig)
    }
}

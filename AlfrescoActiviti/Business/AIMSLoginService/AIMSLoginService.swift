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
    private (set) var session: AlfrescoAuthSession?
    private (set) var credential: AlfrescoCredential?
    private (set) var alfrescoAuth: AlfrescoAuth?
    
    @objc init(with authenticationParameters: AIMSAuthenticationParameters) {
        self.authenticationParameters = authenticationParameters
    }
    
    //MARK: - AIMSLoginServiceProtocol
    func login(onViewController: UIViewController, delegate: AlfrescoAuthDelegate) {
        let authConfig = AuthConfiguration(baseUrl: authenticationParameters.identityServiceURL,
                                           clientID: authenticationParameters.clientID,
                                           realm: authenticationParameters.realm,
                                           redirectURI: authenticationParameters.redirectURI)
        alfrescoAuth = AlfrescoAuth.init(configuration: authConfig)
        session = alfrescoAuth?.pkceAuth(onViewController: onViewController, delegate: delegate)
    }
    
    func refreshSession(delegate: AlfrescoAuthDelegate) {
        alfrescoAuth?.pkceRefreshSession(delegate: delegate)
    }
    
    func logout() {
    }
    
    func updateAuthParameters(with parameters: AIMSAuthenticationParameters) {
        self.authenticationParameters = parameters
    }
    
    @objc func resumeExternalUserAgentFlow(with url: URL) -> Bool {
        if var authSession = session {
            return authSession.resumeExternalUserAgentFlow(with: url)
        }
        
        return false
    }
}

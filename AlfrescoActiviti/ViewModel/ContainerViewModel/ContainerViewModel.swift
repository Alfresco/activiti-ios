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

class ContainerViewModel: NSObject {
    @objc weak var delegate: AFAContainerViewModelDelegate?
    @objc var isLogoutRequestInProgress: Bool
    private (set) var persistenceStackModelName: String?
    
    @objc init(with persistenceStackModelName: String) {
        isLogoutRequestInProgress = false
        self.persistenceStackModelName = persistenceStackModelName
    }
    
    @objc func requestLogout() {
        let sud = UserDefaults.standard
        sud.removeObject(forKey: kAuthentificationTypeCredentialIdentifier)
        
        AFAKeychainWrapper.deleteItemFromKeychain(withIdentifier: persistenceStackModelName)
        if let persistenceStackModelName = self.persistenceStackModelName {
            AFAKeychainWrapper.deleteItemFromKeychain(withIdentifier: String(format: "%@-%@", persistenceStackModelName, kPersistenceStackSessionParameter))
        }
        
        let cookieJar = HTTPCookieStorage.shared
        
        for cookie in cookieJar.cookies! {
            cookieJar.deleteCookie(cookie)
        }
    }
    
    @objc func handleUnAuthorizedRequest() {
        if let aimsLoginService = AFAServiceRepository.shared()?.serviceObject(forPurpose: .aimsLogin) as? AIMSLoginService {
            AFALog.logVerbose("Preparing to refreshing AIMS session")
            
            refreshAIMSSession(with: aimsLoginService)
        } else {
            // Login service not available, default to last successfull login identifier
            let sud = UserDefaults.standard
            let authIdentifier = sud.string(forKey: kAuthentificationTypeCredentialIdentifier)
            
            if authIdentifier == kAIMSAuthenticationCredentialIdentifier {
                let aimsAuthParams = AIMSAuthenticationParameters.parameters()
                let loginService = AIMSLoginService.init(with: aimsAuthParams)
                
                AFAServiceRepository.shared()?.registerServiceObject(loginService, forPurpose: .aimsLogin)
                
                refreshAIMSSession(with: loginService)
            }
        }
    }
    
    fileprivate func refreshAIMSSession(with loginService:AIMSLoginService) {
        if let persistenceStackModelName = self.persistenceStackModelName {
            loginService.refreshSession(keychainIdentifier: String(format: "%@-%@", persistenceStackModelName, kPersistenceStackSessionParameter), delegate: self)
        }
    }
}

extension ContainerViewModel: AlfrescoAuthDelegate {
    func didLogOut(result: Result<Int, APIError>) {
        
    }
    
    func didReceive(result: Result<AlfrescoCredential, APIError>, session: AlfrescoAuthSession?) {
        switch result {
        case .success(let credential):
            // Update the access token for future requests
            let sdkBootstrap = ASDKBootstrap.sharedInstance()
            sdkBootstrap?.updateServerConfiguration(forAccessToken: credential.accessToken)
            
        case .failure:
            // Refresh token ex pired, log out the user
            AFALog.logWarning("Refresh token expired, logging out user.")
            requestLogout()
            delegate?.redirectToLoginViewController()
        }
    }
}

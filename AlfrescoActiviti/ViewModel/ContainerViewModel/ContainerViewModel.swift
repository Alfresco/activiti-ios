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
    @objc var logoutViewController: UIViewController
    
    private (set) var persistenceStackModelName: String?
    
    // Refresh session related properties
    private var refreshTokenDispatchGroup = DispatchGroup()
    private var refreshTokenBlocks: [DispatchWorkItem] = []
    private var credentialError: APIError?
    private var credential: AlfrescoCredential?
    
    //MARK: - Public interface
    @objc init(with persistenceStackModelName: String, logoutViewController: UIViewController) {
        isLogoutRequestInProgress = false
        self.persistenceStackModelName = persistenceStackModelName
        self.logoutViewController = logoutViewController
        
        super.init()
        
        let sdkBootstrap = ASDKBootstrap.sharedInstance()
        sdkBootstrap?.sessionDelegate = self
    }
    
    @objc func requestLogout() {
        // Retrieve the last login type identifier
        let sud = UserDefaults.standard
        let lastLoginType = sud.string(forKey: kAuthentificationTypeCredentialIdentifier)
        
        switch lastLoginType {
        case kAIMSAuthenticationCredentialIdentifier:
            performLogout(withPKCERequest: true)
        default:
            performLogout(withPKCERequest: false)
        }
    }
    
    @objc func performLogout(withPKCERequest: Bool) {
        if withPKCERequest {
            // 1. Retrieve credentials from Keychain
            var alfrescoCredential: AlfrescoCredential?
            let decoder = JSONDecoder()
            guard let credentialData = AFAKeychainWrapper.dataFor(matchingIdentifier: persistenceStackModelName) else { return }
            
            do {
                alfrescoCredential = try decoder.decode(AlfrescoCredential.self, from: credentialData)
                
            } catch {
                AFALog.logError("Unable to retrieve credential from Keychain")
            }
            
            // 2. If it's an AIMS session, perform a logout call to terminate the session
            if let aimsLoginService = AFAServiceRepository.shared()?.serviceObject(forPurpose: .aimsLogin) as? AIMSLoginService,
                let credential = alfrescoCredential {
                AFALog.logVerbose("Logging out from AIMS session")
                
                aimsLoginService.logout(onViewController: logoutViewController, delegate: self, forCredential: credential)
            }
        } else {
            removeLocalCredentials()
            delegate?.redirectToLoginViewController()
        }
    }
    
    fileprivate func refreshAIMSSession(with loginService:AIMSLoginService) {
        if let persistenceStackModelName = self.persistenceStackModelName {
            loginService.refreshSession(keychainIdentifier: String(format: "%@-%@", persistenceStackModelName, kPersistenceStackSessionParameter), delegate: self)
        }
    }
    
    // MARK: - Private interface
    fileprivate func authenticationIdentifier() -> String? {
        let sud = UserDefaults.standard
        let authIdentifier = sud.string(forKey: kAuthentificationTypeCredentialIdentifier)
        
        return authIdentifier
    }
    
    fileprivate func removeLocalCredentials() {
        // 2. Remove credentials from Keychain
        AFAKeychainWrapper.deleteItemFromKeychain(withIdentifier: persistenceStackModelName)
        if let persistenceStackModelName = self.persistenceStackModelName {
            AFAKeychainWrapper.deleteItemFromKeychain(withIdentifier: String(format: "%@-%@", persistenceStackModelName, kPersistenceStackSessionParameter))
        }
        
        // 3. Clear the cookies
        let cookieJar = HTTPCookieStorage.shared
        for cookie in cookieJar.cookies! {
            cookieJar.deleteCookie(cookie)
        }
    }
}

extension ContainerViewModel: AlfrescoAuthDelegate {
    func didReceive(result: Result<AlfrescoCredential, APIError>, session: AlfrescoAuthSession?) {
        switch result {
        case .success(let credential):
            // Update the access token for future requests
            self.credential = credential
            let sdkBootstrap = ASDKBootstrap.sharedInstance()
            sdkBootstrap?.updateServerConfiguration(withCredential: credential.toASDKModelCredentialType())
        case .failure(let error):
            credentialError = error
            credential = nil
        }
        
        refreshTokenDispatchGroup.leave()
    }
    
    func didLogOut(result: Result<Int, APIError>) {
        var hasLogoutBeenCancelled = false
        
        switch result {
        case .success(_):
            AFALog.logVerbose("AIMS session terminated successfully.")
        case .failure(let error):
            if error.responseCode == kAFALoginSSOViewModelCancelErrorCode {
                hasLogoutBeenCancelled = true
            } else {
                let errorMessage = String(format: "AIMS session failed to be terminated succesfully. Reason:%@", error.localizedDescription)
                AFALog.logError(errorMessage)
            }
        }
        
        if !hasLogoutBeenCancelled {
            removeLocalCredentials()
            
            let sud = UserDefaults.standard
            sud.removeObject(forKey: kAuthentificationTypeCredentialIdentifier)
            
            delegate?.redirectToLoginViewController()
        }
    }
}

// MARK: - ASDKNetworkSession Delegate
extension ContainerViewModel: ASDKNetworkSessionProtocol {
    func refreshNetworkSession(completionBlock: @escaping ASDKNetworkSessionRefreshCompletionBlock) {
        if let aimsLoginService = AFAServiceRepository.shared()?.serviceObject(forPurpose: .aimsLogin) as? AIMSLoginService {
            for block in refreshTokenBlocks {
                block.cancel()
                refreshTokenDispatchGroup.leave()
            }
            
            AFALog.logVerbose("Preparing to refresh AIMS session")
            
            // Wait for a token refresh operation to finish then return the result via the completion block
            refreshTokenDispatchGroup.enter()
            
            let refreshBlock = DispatchWorkItem { [weak self] in
                guard let sSelf = self else { return }
                sSelf.refreshAIMSSession(with: aimsLoginService)
            }
            refreshTokenBlocks.append(refreshBlock)
            
            DispatchQueue.global().async(execute: refreshBlock)
            
            refreshTokenDispatchGroup.notify(queue: .global()) {[weak self] in
                guard let sSelf = self else { return }
                
                sSelf.refreshTokenBlocks.removeAll()
                
                if (sSelf.credential != nil || sSelf.credentialError != nil) {
                    completionBlock(sSelf.credentialError)
                }
            }
        }
    }
}

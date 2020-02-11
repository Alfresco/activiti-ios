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

class BaseAuthLoginViewModel: AIMSLoginViewModelProtocol {
    var loginStrategy: BaseAuthLoginStrategyProtocol?
    let requestProfileService = AFAProfileServices()

    func signIn(username: String, password: String, completion: @escaping (Result<ASDKModelProfile, Error>) -> Void) {
        switch loginStrategy?.serverConfiguration(for: username, password) {
        case .failure(let error):
            completion(.failure(error))
        case .success(let serverConfiguration):
            let persistenceStackModelName = self.persistenceStackModelName()
            let sdkBootstrap = ASDKBootstrap.sharedInstance()
            sdkBootstrap?.setupServices(with: serverConfiguration)
            requestProfileService.requestProfile { [weak self] (profile, error) in
                guard let sSelf = self else { return }
                if let profile = profile {
                    sSelf.loginStrategy?.syncToUserDefaultsServerConfiguration()
                    
                    if let serverConfiguration = sSelf.loginStrategy?.serverConfiguration {
                        guard let baseAuthCredential = serverConfiguration.credential as? ASDKModelCredentialBaseAuth else { return }

                        if (AFAKeychainWrapper.keychainStringFrom(matchingIdentifier: persistenceStackModelName) != nil) {
                            AFAKeychainWrapper.updateKeychainValue(baseAuthCredential.password,
                                                                   forIdentifier: persistenceStackModelName)
                        } else {
                            AFAKeychainWrapper.createKeychainValue(baseAuthCredential.password,
                                                                   forIdentifier: persistenceStackModelName)
                        }
                    }

                    completion(.success(profile))
                } else {
                    if let error = error {
                        completion(.failure(error))
                    }
                }
            }
        default: break
        }
    }
    
    func persistenceStackModelName() -> String {
        if let persistenceStackModelName = ASDKPersistenceStack.persistenceStackModelName(for: self.loginStrategy?.serverConfiguration) {
            return persistenceStackModelName
        }
        return ""
    }
}

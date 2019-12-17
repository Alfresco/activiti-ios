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

public typealias AvailableAuthTypeCallback<AuthType> = (Result<AuthType, APIError>) -> Void

protocol AIMSLoginServiceProtocol {
    
    // Login related methods
    func availableAuthType(for serviceDocument: String, handler:@escaping AvailableAuthTypeCallback<AvailableAuthType>)
    func login(onViewController: UIViewController, delegate: AlfrescoAuthDelegate)
    func refreshSession(keychainIdentifier: String, delegate: AlfrescoAuthDelegate)
    func logout(onViewController viewController: UIViewController,
                delegate: AlfrescoAuthDelegate,
                forCredential credential: AlfrescoCredential)
    
    // Parameter related methods
    func updateAuthParameters(with parameters: AIMSAuthenticationParameters)
    
    // URL redirect
    func resumeExternalUserAgentFlow(with url: URL) -> Bool 
}

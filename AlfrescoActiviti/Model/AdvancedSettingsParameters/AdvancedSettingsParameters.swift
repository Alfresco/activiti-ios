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

struct AdvancedSettingsParameters: Codable {
    
    var https: Bool?
    var port: String?
    var serviceDocument: String?
    var realm: String?
    var clientID: String?
    var redirectURL: String?
    
    init() {
        self.https = false
    }
    
    init(https: Bool, port: String, serviceDocument: String, realm: String, clientID: String, redirectURL: String) {
        self.realm = realm
        self.clientID = clientID
        self.port = port
        self.serviceDocument = serviceDocument
        self.redirectURL = redirectURL
        self.https = https
    }
    
    func empty() -> Bool {
        if https == nil {
            return true
        }
        if port == nil || port == "" {
            return true
        }
        if clientID == nil || clientID == "" {
            return true
        }
        if serviceDocument == nil || serviceDocument == "" {
            return true
        }
        if redirectURL == nil || redirectURL == "" {
            return true
        }
        if realm == nil || realm == "" {
            return true
        }
        return false
    }
}

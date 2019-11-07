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

class AIMSAuthenticationParameters: NSObject {
    var identityServiceURL: String
    var contentURL: String
    var processURL: String
    let realm: String
    let clientID: String
    let redirectURI: String
    
    init(identityServiceURL:String,
         contentURL:String,
         processURL:String,
         realm:String,
         clientID:String,
         redirectURI:String) {
        self.identityServiceURL = identityServiceURL
        self.contentURL = contentURL
        self.processURL = processURL
        self.realm = realm
        self.clientID = clientID
        self.redirectURI = redirectURI
    }
}
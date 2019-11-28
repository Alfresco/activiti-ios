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

enum AuthenticationType {
    case connect
    case baseAuthOnPremise
    case baseAuthCloud
    case sso
}

class AIMSAuthenticationParameters: Codable {
    var https: Bool = true
    var port: String = "80"
    var serviceDocument: String = "activiti-app"
    var realm: String = "alfresco"
    var clientID: String = "alfresco"
    var redirectURI: String = "iosapp://fake.url.here/auth"
    var hostname: String = ""
    var processURL: String = ""
    var fullFormatURL: String {
        get {
            var fullFormatURL = String(format:"%@://%@", https ? "https" : "http", hostname)
            if port.count != 0 {
                fullFormatURL.append(contentsOf: String(format:":%@", port))
            }
            return fullFormatURL
        }
    }
    
    func empty() -> Bool {
        if port == "" || clientID == "" || serviceDocument == "" || redirectURI == "" || realm == "" {
            return true
        }
        return false
    }
    
    static func parameters() -> AIMSAuthenticationParameters {
        let defaults = UserDefaults.standard
        if let data = defaults.value(forKey: kAdvancedSettingsParameters) as? Data {
            if let params = try? PropertyListDecoder().decode(AIMSAuthenticationParameters.self, from: data) {
                return params
            }
        }
        return AIMSAuthenticationParameters()
    }
    
    func save() {
        let defaults = UserDefaults.standard
        UserDefaults.standard.set(try? PropertyListEncoder().encode(self),
                                  forKey: kAdvancedSettingsParameters)
        defaults.synchronize()
    }
    
    func checkAvailable(authentication: AuthenticationType) -> Result<Any, NSError> {
        var available = true
        var warningText = ""
        switch authentication {
        case .connect:
            warningText = NSLocalizedString("", comment: "Warning Text")
            available = !hostname.isEmpty
        case .baseAuthOnPremise:
            warningText = NSLocalizedString(kLocalizationCloudLoginWarningText, comment: "Warning Text")
            available = !serviceDocument.isEmpty
        case .sso:
            warningText = NSLocalizedString(kLocalizationSSOLoginWarningLoginRedirectURL, comment: "Warning Text")
            available = !redirectURI.isEmpty
        default: break
        }
        return (available) ? .success(true) : .failure(generateError(with: warningText))
    }
    
    func generateError(with message: String) -> NSError {
        return NSError(domain: AFALoginViewModelWarningDomain, code: 0, userInfo: [NSLocalizedDescriptionKey : message])
    }
}

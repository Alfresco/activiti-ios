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

class AdvancedSettingsParameters: Codable {

    var https: Bool = true
    var port: String = "80"
    var serviceDocument: String = "activi-app"
    var realm: String = "alfresco"
    var clientID: String = "alfresco"
    var redirectURL: String = "fakeurl.com"
    var hostname: String = "activiti.alfresco.com"
    
    func empty() -> Bool {
        if port == "" || clientID == "" || serviceDocument == "" || redirectURL == "" || realm == "" {
            return true
        }
        return false
    }
    
    static func parameters() -> AdvancedSettingsParameters {
        let defaults = UserDefaults.standard
        if let data = defaults.value(forKey: kAdvancedSettingsParameters) as? Data {
            if let params = try? PropertyListDecoder().decode(AdvancedSettingsParameters.self, from: data) {
                return params
            }
        }
        return AdvancedSettingsParameters()
    }
    
    func save() {
        let defaults = UserDefaults.standard
        UserDefaults.standard.set(try? PropertyListEncoder().encode(self),
                                  forKey: kAdvancedSettingsParameters)
        defaults.synchronize()
    }
}

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

class AIMSAdvancedSettingsViewModel {
    // Localization
    let transportProtocolText = NSLocalizedString(kLocalizationAdvancedSettingsScreenTransportProtocolText, comment: "Transport Protocol")
    let httpsText = NSLocalizedString(kLocalizationAdvancedSettingsScreenHttpsText, comment: "HTTPS")
    let portPlaceholderText = NSLocalizedString(kLocalizationAdvancedSettingsScreenPortPlaceholderText, comment: "Port")
    let processServicessAppText = NSLocalizedString(kLocalizationLoginScreenProcessServicesAppText, comment: "App name")
    let serviceDocumentPlaceholderText = NSLocalizedString(kLocalizationAdvancedSettingsScreenServiceDocumentPlaceholderText, comment: "Service Document")
    let authenticationText = NSLocalizedString(kLocalizationAdvancedSettingsScreenAuthenticationText, comment: "Authentication")
    let realmPlaceholderText = NSLocalizedString(kLocalizationAdvancedSettingsScreenRealmPlaceholderText, comment: "Realm")
    let cliendIDPlaceholderText = NSLocalizedString(kLocalizationAdvancedSettingsScreenCliendIDPlaceholderText, comment: "Client ID")
    let redirectURLPlaceholderText = NSLocalizedString(kLocalizationAdvancedSettingsScreenRedirectURLPlaceholderText, comment: "Redirect URL")
    let saveButtonText = NSLocalizedString(kLocalizationAdvancedSettingsScreenSaveButtonText, comment: "Save")
    let helpButtonText = NSLocalizedString(kLocalizationAdvancedSettingsScreenHelpButtonText, comment: "Need Help")
    let helpText = NSLocalizedString(kLocalizationAdvancedSettingsScreenHelpText, comment: "Help")
    let helpHintText = NSLocalizedString(kLocalizationAdvancedSettingsScreenHelpHintText, comment: "Hint Help")
    let closeText = NSLocalizedString(kLocalizationAdvancedSettingsScreenCloseText, comment: "Close")
    var copyrightText: String {
        get {
            let calendar = Calendar.current
            let year = calendar.component(.year, from: Date())
            return String(format: NSLocalizedString(kLocalizationLoginScreenCopyrightFormat, comment: "Copyright text"), year)
        }
    }
    
    func saveParameters(_ advancedSettingsParameters: AIMSAdvancedSettingsParameters) {
        advancedSettingsParameters.save()
    }
    
    func getParameters() -> AIMSAdvancedSettingsParameters {
        return AIMSAdvancedSettingsParameters.parameters()
    }
    
    func datasource() -> [[AIMSAdvancedSettingsAction]] {
        let transportProtocolSection = [AIMSAdvancedSettingsAction(type: .sectionTitle, title: transportProtocolText),
                                        AIMSAdvancedSettingsAction(type: .https, title: httpsText),
                                        AIMSAdvancedSettingsAction(type: .port, title: portPlaceholderText)]
        
        let settingsSection = [AIMSAdvancedSettingsAction(type: .sectionTitle, title: processServicessAppText),
                               AIMSAdvancedSettingsAction(type: .serviceDocuments, title: serviceDocumentPlaceholderText)]
        
        let authSection = [AIMSAdvancedSettingsAction(type: .sectionTitle, title: authenticationText),
                           AIMSAdvancedSettingsAction(type: .realm, title: realmPlaceholderText),
                           AIMSAdvancedSettingsAction(type: .clientID, title: cliendIDPlaceholderText),
                           AIMSAdvancedSettingsAction(type: .redirectURL, title: redirectURLPlaceholderText)]
        
        let helpSection = [AIMSAdvancedSettingsAction(type: .help, title: helpButtonText, info: helpHintText)]
        
        return [transportProtocolSection, settingsSection, authSection, helpSection]
    }
    
    func getIndexPathForSaveButton() -> IndexPath {
        return IndexPath(row: 0, section: 3)
    }
}

enum AIMSAdvancedSettingsActionTypes {
    case https
    case port
    case serviceDocuments
    case realm
    case clientID
    case redirectURL
    case help
    case sectionTitle
    case copyright
    case save
}
class AIMSAdvancedSettingsAction {
    let type: AIMSAdvancedSettingsActionTypes
    let title: String
    let info: String?
    
    init(type: AIMSAdvancedSettingsActionTypes, title: String, info: String = "") {
        self.type = type
        self.title = title
        self.info = info
    }
}

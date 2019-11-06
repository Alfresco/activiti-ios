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
    
    func saveParameters(_ advancedSettingsParameters: AdvancedSettingsParameters) {
        let defaults = UserDefaults.standard
        UserDefaults.standard.set(try? PropertyListEncoder().encode(advancedSettingsParameters),
                                  forKey: kAdvancedSettingsParameters)
        defaults.synchronize()
    }
    
    func getParameters() -> AdvancedSettingsParameters {
        let defaults = UserDefaults.standard
        if let data = defaults.value(forKey: kAdvancedSettingsParameters) as? Data {
            if let params = try? PropertyListDecoder().decode(AdvancedSettingsParameters.self, from: data) {
                return params
            }
        }
        return AdvancedSettingsParameters()
    }
    
    func datasource() -> [ASModelSection] {
        let transportProtocolSection = ASModelSection(type: .transportProtocol,
                                                     numberOfRow: 3,
                                                     title: transportProtocolText,
                                                     rows: [ASModelRow(type: .sectionTitle, title: transportProtocolText),
                                                            ASModelRow(type: .https, title: httpsText),
                                                            ASModelRow(type: .port, title: portPlaceholderText)])
        
        let settingsSection = ASModelSection(type: .settings,
                                            numberOfRow: 2,
                                            title: processServicessAppText,
                                            rows: [ASModelRow(type: .sectionTitle, title: processServicessAppText),
                                                   ASModelRow(type: .serviceDocuments, title: serviceDocumentPlaceholderText)])
        
        let authSection = ASModelSection(type: .authentication,
                                        numberOfRow: 4,
                                        title: authenticationText,
                                        rows: [ASModelRow(type: .sectionTitle, title: authenticationText),
                                               ASModelRow(type: .realm, title: realmPlaceholderText),
                                               ASModelRow(type: .clientID, title: cliendIDPlaceholderText),
                                               ASModelRow(type: .redirectURL, title: redirectURLPlaceholderText)])
        
        let saveSection = ASModelSection(type: .save,
                                        numberOfRow: 1,
                                        title: saveButtonText,
                                        rows: [ASModelRow(type: .save, title: saveButtonText)])
        
        let helpSection = ASModelSection(type: .help,
                                        numberOfRow: 1,
                                        title: helpButtonText,
                                        rows: [ASModelRow(type: .help, title: helpButtonText, info: helpHintText)])
        
        let copyRightSection = ASModelSection(type: .copyright,
                                             numberOfRow: 1,
                                             title: copyrightText,
                                             rows: [ASModelRow(type: .copyright, title: copyrightText)])
        
        return [transportProtocolSection, settingsSection, authSection, saveSection, helpSection, copyRightSection]
    }
    
    func getIndexPathForSaveButton() -> IndexPath {
        return IndexPath(row: 0, section: 3)
    }
}

enum ASSections {
    case transportProtocol
    case settings
    case authentication
    case save
    case help
    case copyright
}

enum ASRows {
    case https
    case port
    case serviceDocuments
    case realm
    case clientID
    case redirectURL
    case save
    case help
    case sectionTitle
    case copyright
}

class ASModelSection {
    let type: ASSections
    let numberOfRow: NSInteger
    let title: String
    let arrayRows: [ASModelRow]
    
    init(type: ASSections, numberOfRow: NSInteger, title: String, rows: [ASModelRow]) {
        self.type = type
        self.numberOfRow = numberOfRow
        self.title = title
        self.arrayRows = rows
    }
}

class ASModelRow {
    let type: ASRows
    let title: String
    let info: String?
    
    init(type: ASRows, title: String, info: String = "") {
        self.type = type
        self.title = title
        self.info = info
    }
}

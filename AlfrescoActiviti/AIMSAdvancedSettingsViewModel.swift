//
//  AIMSAdvancedSettingsViewModel.swift
//  AlfrescoActiviti
//
//  Created by Florin Baincescu on 29/10/2019.
//  Copyright © 2019 Emanuel Lupu-Marinei. All rights reserved.
//

import Foundation

class AIMSAdvancedSettingsViewModel {
    // Localization
    let realmPlaceholderText = NSLocalizedString(kLocalizationAdvancedSettingsScreenRealmPlaceholderText, comment: "Realm")
    let cliendIDPlaceholderText = NSLocalizedString(kLocalizationAdvancedSettingsScreenCliendIDPlaceholderText, comment: "Client ID")
    let portPlaceholderText = NSLocalizedString(kLocalizationAdvancedSettingsScreenPortPlaceholderText, comment: "Port")
    let serviceDocumentPlaceholderText = NSLocalizedString(kLocalizationAdvancedSettingsScreenServiceDocumentPlaceholderText, comment: "Service Document")
    let saveButtonText = NSLocalizedString(kLocalizationAdvancedSettingsScreenSaveButtonText, comment: "Save")
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
    
    func getParameters() -> AdvancedSettingsParameters? {
        let defaults = UserDefaults.standard
        if let data = defaults.value(forKey: kAdvancedSettingsParameters) as? Data {
            if let params = try? PropertyListDecoder().decode(AdvancedSettingsParameters.self, from: data) {
                return params
            }
        }
        return nil
    }
}

//
//  AdvancedSettingsModel.swift
//  AlfrescoActiviti
//
//  Created by Florin Baincescu on 29/10/2019.
//  Copyright © 2019 Emanuel Lupu-Marinei. All rights reserved.
//

import Foundation

struct AdvancedSettingsParameters: Codable {
    
    var realm: String
    var clientID: String
    var port: String
    var serviceDocument: String
    
    init(realm: String, clientID: String, port: String, serviceDocument: String) {
        self.realm = realm
        self.clientID = clientID
        self.port = port
        self.serviceDocument = serviceDocument
    }

}

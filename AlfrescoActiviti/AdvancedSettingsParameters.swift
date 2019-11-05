//
//  AdvancedSettingsModel.swift
//  AlfrescoActiviti
//
//  Created by Florin Baincescu on 29/10/2019.
//  Copyright © 2019 Emanuel Lupu-Marinei. All rights reserved.
//

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

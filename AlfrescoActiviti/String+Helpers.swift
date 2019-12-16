//
//  String+Helpers.swift
//  AlfrescoActiviti
//
//  Created by Florin Baincescu on 16/12/2019.
//  Copyright © 2019 Emanuel Lupu-Marinei. All rights reserved.
//

import Foundation

extension String {
    func encoding() -> String {
        if let escapedString = addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed) {
            return escapedString
        }
        return self
    }
}

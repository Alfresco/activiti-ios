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

extension NSAttributedString {

    convenience init?(withLocalizedHTMLString: String, font: UIFont) {
        let modifiedFont = NSString(format:"<span style=\"font-family: \(font.fontName); font-size: \(font.pointSize)\">%@</span>" as NSString, withLocalizedHTMLString)

        
        guard let stringData = modifiedFont.data(using: String.Encoding.unicode.rawValue, allowLossyConversion: true) else {
            return nil
        }

        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html as Any,
            NSAttributedString.DocumentReadingOptionKey.characterEncoding: String.Encoding.utf8.rawValue
        ]

        try? self.init(data: stringData, options: options, documentAttributes: nil)
    }
}

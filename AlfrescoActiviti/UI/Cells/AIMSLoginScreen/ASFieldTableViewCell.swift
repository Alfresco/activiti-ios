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
import MaterialComponents.MDCTextField

class ASFieldTableViewCell: UITableViewCell, ASCell {
    
    @IBOutlet weak var textField: MDCTextField!
    
    var textFieldController: MDCTextInputControllerUnderline?
    
    var delegate: ASCellsProtocol!
    var model: ASModelRow! 
    var parameters: AdvancedSettingsParameters!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textField.text = ""
        textField.delegate = self
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configureCell() {
        guard let colorSchemeManager = self.colorSchemeManager else {
            AFALog.logError("Color scheme manager could not be initiated")
            return
        }
        
        textFieldController = MDCTextInputControllerUnderline(textInput: textField)
        textFieldController?.inlinePlaceholderFont = colorSchemeManager.textFieldTypographyScheme.subtitle1
        textField.font = colorSchemeManager.textFieldTypographyScheme.headline1
        
        if let textFieldController = self.textFieldController {
            textFieldController.placeholderText = model.title
            MDCTextFieldColorThemer.applySemanticColorScheme(colorSchemeManager.advancedSettingsTextFieldColorScheme, to: textFieldController )
        }
        
        switch model.type {
        case .port:
            textField.text = parameters.port
            break
        case .serviceDocuments:
            textField.text = parameters.serviceDocument
            break
        case .realm:
            textField.text = parameters.realm
            break
        case .clientID:
            textField.text = parameters.clientID
            break
        case .redirectURL:
            textField.text = parameters.redirectURL
            break
        default:
            break
        }
    }
}

extension ASFieldTableViewCell: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch model.type {
        case .port:
            parameters.port = textField.text ?? ""
            break
        case .serviceDocuments:
            parameters.serviceDocument = textField.text ?? ""
            break
        case .realm:
            parameters.realm = textField.text ?? ""
            break
        case .clientID:
            parameters.clientID = textField.text ?? ""
            break
        case .redirectURL:
            parameters.redirectURL = textField.text ?? ""
            break
        default:
            break
        }
        delegate.result(cell: self, type: model.type, response: parameters)
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        delegate.willBeginEditing(type: model.type)
        return true;
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        delegate.result(cell: self, type: model.type, response: parameters)
        return true
    }
}

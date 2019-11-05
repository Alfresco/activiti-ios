//
//  ASFieldTableViewCell.swift
//  AlfrescoActiviti
//
//  Created by Florin Baincescu on 04/11/2019.
//  Copyright © 2019 Emanuel Lupu-Marinei. All rights reserved.
//

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

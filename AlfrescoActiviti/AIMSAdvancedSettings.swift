//
//  AIMSAdvanedSettings.swift
//  AlfrescoActiviti
//
//  Created by Florin Baincescu on 29/10/2019.
//  Copyright © 2019 Emanuel Lupu-Marinei. All rights reserved.
//

import UIKit
import MaterialComponents.MDCButton
import MaterialComponents.MDCTextField

class AIMSAdvancedSettings: UIViewController {
    let model: AIMSAdvancedSettingsViewModel = AIMSAdvancedSettingsViewModel()
    
    @IBOutlet weak var realmTextField: MDCTextField!
    @IBOutlet weak var cliendIDTextField: MDCTextField!
    @IBOutlet weak var portTextField: MDCTextField!
    @IBOutlet weak var serviceDocumentTextField: MDCTextField!
    @IBOutlet weak var saveButton: MDCButton!
    
    @IBOutlet weak var realmInfoButton: UIButton!
    @IBOutlet weak var clientIDInfoButton: UIButton!
    @IBOutlet weak var portInfoButton: UIButton!
    @IBOutlet weak var serviceDocumentInfoButton: UIButton!
    
    var realmTextFieldController: MDCTextInputController?
    var clientIDTextFieldController: MDCTextInputController?
    var portTextFieldController: MDCTextInputController?
    var serviceDocumentTextFieldController: MDCTextInputController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.populateForm()
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        guard let colorSchemeManager = self.colorSchemeManager else {
            AFALog.logError("Color scheme manager could not be initiated")
            return
        }
        
        // Realm set up
        realmTextFieldController = MDCTextInputControllerOutlined(textInput: realmTextField)
        realmTextFieldController?.placeholderText = model.realmPlaceholderText
        if let realmTextFieldController = self.realmTextFieldController {
            MDCTextFieldColorThemer.applySemanticColorScheme(colorSchemeManager.defaultColorScheme, to: realmTextFieldController)
        }
        
        // Client ID set up
        clientIDTextFieldController = MDCTextInputControllerOutlined(textInput: cliendIDTextField)
        clientIDTextFieldController?.placeholderText = model.cliendIDPlaceholderText
        if let clientIDTextFieldController = self.clientIDTextFieldController {
            MDCTextFieldColorThemer.applySemanticColorScheme(colorSchemeManager.defaultColorScheme, to: clientIDTextFieldController)
        }
        
        // Port ID set up
        portTextFieldController = MDCTextInputControllerOutlined(textInput: portTextField)
        portTextFieldController?.placeholderText = model.portPlaceholderText
        if let portTextFieldController = self.portTextFieldController {
            MDCTextFieldColorThemer.applySemanticColorScheme(colorSchemeManager.defaultColorScheme, to: portTextFieldController)
        }
        
        // Service Document ID set up
        serviceDocumentTextFieldController = MDCTextInputControllerOutlined(textInput: serviceDocumentTextField)
        serviceDocumentTextFieldController?.placeholderText = model.serviceDocumentPlaceholderText
        if let serviceDocumentTextFieldController = self.serviceDocumentTextFieldController {
            MDCTextFieldColorThemer.applySemanticColorScheme(colorSchemeManager.defaultColorScheme, to: serviceDocumentTextFieldController)
        }

        // Button section
        saveButton.setTitle(model.saveButtonText, for: .normal)
        saveButton.applyContainedTheme(withScheme: colorSchemeManager.flatButtonWithBackgroundScheme)
        saveButton.setElevation(.none, for: .normal)
        saveButton.setElevation(.none, for: .highlighted)
        saveButton.setTitleFont(colorSchemeManager.defaultTypographyScheme.headline4, for: .normal)
    }
    
    // MARK - IBActions
    
    @IBAction func saveButtonPressed(_ sender: MDCButton) {
        self.view.endEditing(true)
        let params = AdvancedSettingsParameters(realm: realmTextField.text ?? "",
                                                clientID: cliendIDTextField.text ?? "",
                                                port: portTextField.text ?? "",
                                                serviceDocument: serviceDocumentTextField.text ?? "")
        model.saveParameters(params)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func viewBackgroundPressed(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    @IBAction func intoButtonPressed(_ sender: UIButton) {
        var message = ""
        var title = ""
        
        switch sender.tag {
        case 0:
            title = model.realmPlaceholderText
            message = model.realmHintText
            break
        case 1:
            title = model.cliendIDPlaceholderText
            message = model.cliendIDHintText
            break
        case 2:
            title = model.portPlaceholderText
            message = model.portHintText
            break
        case 3:
            title = model.serviceDocumentPlaceholderText
            message = model.serviceDocumentHintText
            break
        default:
            break
        }
        
        let alertController = MDCAlertController(title: title, message: message)
        let action = MDCAlertAction(title: NSLocalizedString(kLocalizationAlertDialogOkButtonText, comment: "OK")) { (action) in
        }
        alertController.addAction(action)
        present(alertController, animated: true, completion: nil)
    }
    
    // MARK - Helpers
    
    func populateForm() {
        if let params = model.getParameters() {
            realmTextField.text = params.realm
            cliendIDTextField.text = params.clientID
            portTextField.text = params.port
            serviceDocumentTextField.text = params.serviceDocument
        }
    }
}

extension AIMSAdvancedSettings: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        switch textField {
        case realmTextField:
            realmInfoButton.isHidden = true
            break
        case cliendIDTextField:
            clientIDInfoButton.isHidden = true
            break
        case portTextField:
            portInfoButton.isHidden = true
            break
        case serviceDocumentTextField:
            serviceDocumentInfoButton.isHidden = true
            break
        default:
            break
        }
        return true;
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField {
        case realmTextField:
            realmInfoButton.isHidden = false
            break
        case cliendIDTextField:
            clientIDInfoButton.isHidden = false
            break
        case portTextField:
            portInfoButton.isHidden = false
            break
        case serviceDocumentTextField:
            serviceDocumentInfoButton.isHidden = false
            break
        default:
            break
        }
    }
}

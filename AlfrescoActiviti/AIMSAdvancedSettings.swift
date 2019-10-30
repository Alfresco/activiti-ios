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


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

import UIKit
import MaterialComponents.MDCButton
import MaterialComponents.MDCTextField

class CloudLoginViewController: UIViewController {

    @IBOutlet weak var processServicesAppLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var copyrightLabel: UILabel!
    
    @IBOutlet weak var usernameTextfield: MDCTextField!
    @IBOutlet weak var passwordTextfield: MDCTextField!
    
    @IBOutlet weak var signInButton: MDCButton!
    @IBOutlet weak var helpButton: MDCButton!
    
    var usernameTextFieldController: MDCTextInputController?
    var passwordTextFieldController: MDCTextInputController?
    let model: CloudLoginViewModel = CloudLoginViewModel()
    
    var enableSignInButton: Bool = false
    var showPasswordButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        guard let colorSchemeManager = self.colorSchemeManager else {
            AFALog.logError("Color scheme manager could not be initiated")
            return
        }
        
        processServicesAppLabel.text = model.processServicessAppText
        infoLabel.text = model.infoText
        
        // Username textfield
        usernameTextfield.rightViewMode = .unlessEditing
        usernameTextfield.rightView = UIImageView(image: UIImage(named: "username-icon"))
        usernameTextfield.rightView?.tintColor = #colorLiteral(red: 0.568627451, green: 0.568627451, blue: 0.568627451, alpha: 1)
        usernameTextfield.font = colorSchemeManager.textFieldTypographyScheme.headline1
        usernameTextFieldController = MDCTextInputControllerUnderline(textInput: usernameTextfield)
        usernameTextFieldController?.placeholderText = model.usernamaPlaceholderText
        usernameTextFieldController?.inlinePlaceholderFont = colorSchemeManager.textFieldTypographyScheme.subtitle1
        if let usernameTextFieldController = self.usernameTextFieldController {
            MDCTextFieldColorThemer.applySemanticColorScheme(colorSchemeManager.textfieldDefaultColorScheme, to: usernameTextFieldController)
        }
        
        // Password Textfield
        showPasswordButton.setImage(UIImage(named: "show-password-icon"), for: .normal)
        showPasswordButton.setImage(UIImage(named: "hide-password-icon"), for: .selected)
        showPasswordButton.addTarget(self, action: #selector(showPasswordButtonPressed(_:)), for: .touchUpInside)
        passwordTextfield.rightViewMode = .always
        passwordTextfield.rightView = showPasswordButton
        passwordTextfield.rightView?.tintColor = #colorLiteral(red: 0.568627451, green: 0.568627451, blue: 0.568627451, alpha: 1)
        passwordTextfield.font = colorSchemeManager.textFieldTypographyScheme.headline1
        passwordTextFieldController = MDCTextInputControllerUnderline(textInput: passwordTextfield)
        passwordTextFieldController?.placeholderText = model.passwordPlaceholderText
        passwordTextFieldController?.inlinePlaceholderFont = colorSchemeManager.textFieldTypographyScheme.subtitle1
        if let passwordTextFieldController = self.passwordTextFieldController {
            MDCTextFieldColorThemer.applySemanticColorScheme(colorSchemeManager.textfieldDefaultColorScheme, to: passwordTextFieldController)
        }
        
        // Help button
        helpButton.setTitle(model.helpButtonText, for: .normal)
        helpButton.applyTextTheme(withScheme: colorSchemeManager.blueFlatButtonWithoutBackgroundScheme)
        helpButton.setTitleFont(colorSchemeManager.defaultTypographyScheme.headline3, for: .normal)
        
        // Copyright section
        copyrightLabel.text = model.copyrightText
        copyrightLabel.font = colorSchemeManager.defaultTypographyScheme.subtitle1
        copyrightLabel.textColor = colorSchemeManager.grayColorScheme.primaryColor
        
        shouldEnableSignInButton()
    }
    
    //MARK: - IBActions
    
    @objc func showPasswordButtonPressed(_ sender: UIButton) {
        passwordTextfield.isSecureTextEntry = showPasswordButton.isSelected
        showPasswordButton.isSelected = !showPasswordButton.isSelected
    }
    
    @IBAction func signInButtonPressed(_ sender: MDCButton) {
        self.view.endEditing(true)
        if let username = usernameTextfield.text, let password = passwordTextfield.text {
            model.signIn(username: username, password: password)
        }
    }
    
    @IBAction func helpButtonPressed(_ sender: MDCButton) {
        self.view.endEditing(true)
        let helpVC = storyboard?.instantiateViewController(withIdentifier: kStoryboardIDAIMSHelpViewController) as! AIMSHelpViewController
        helpVC.hintText = model.helpHintText
        helpVC.titleText = model.helpText
        helpVC.closeText = model.closeText
        helpVC.modalPresentationStyle = .overCurrentContext
        self.navigationController?.present(helpVC, animated: false, completion: nil)
    }
    
    @IBAction func backgroundViewPressed(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    //MARK: - Helpers
    
    func shouldEnableSignInButton() {
        guard let colorSchemeManager = self.colorSchemeManager else {
            AFALog.logError("Color scheme manager could not be initiated")
            return
        }
        signInButton.setTitle(model.signInButtonText, for: .normal)
        signInButton.isEnabled = enableSignInButton
        if enableSignInButton {
            signInButton.applyContainedTheme(withScheme: colorSchemeManager.flatButtonWithBackgroundScheme)
        } else {
            signInButton.applyContainedTheme(withScheme: colorSchemeManager.grayFlatButtonWithoutBackgroundScheme)
        }
        signInButton.setElevation(.none, for: .normal)
        signInButton.setElevation(.none, for: .highlighted)
        signInButton.setTitleFont(colorSchemeManager.defaultTypographyScheme.headline6, for: .normal)
    }
    
}

extension CloudLoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textField.rightView?.tintColor = #colorLiteral(red: 0.07236295193, green: 0.6188754439, blue: 0.2596520483, alpha: 1)
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        textField.rightView?.tintColor = #colorLiteral(red: 0.568627451, green: 0.568627451, blue: 0.568627451, alpha: 1)
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if usernameTextfield.text != ""  && passwordTextfield.text != "" {
            enableSignInButton = true
        } else {
            enableSignInButton = false
        }
        shouldEnableSignInButton()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if usernameTextfield.text != ""  && passwordTextfield.text != "" {
            enableSignInButton = true
        } else {
            enableSignInButton = false
        }
        shouldEnableSignInButton()
        return true
    }
}

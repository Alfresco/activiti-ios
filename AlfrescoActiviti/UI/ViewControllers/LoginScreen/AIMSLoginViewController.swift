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
import MaterialComponents.MaterialButtons


class AIMSLoginViewController: UIViewController {
    let loginViewModel: AIMSLoginViewModel = AIMSLoginViewModel()
    
    // App name section
    @IBOutlet weak var processServicesAppLabel: UILabel!
    
    // URLs section
    @IBOutlet weak var alfrescoURLTextField: MDCTextField!
    @IBOutlet weak var alfrescoURLInfoButton: UIButton!
    @IBOutlet weak var processURLTextField: MDCTextField!
    @IBOutlet weak var processURLInfoButton: UIButton!
    @IBOutlet weak var processURLTextFieldHeightConstraint: NSLayoutConstraint!
    var alfrescoURLTextFieldController: MDCTextInputController?
    var processURLTextFieldController: MDCTextInputController?
    
    // HTTPS section
    @IBOutlet weak var httpsLabel: UILabel!
    @IBOutlet weak var httpsSwitch: UISwitch!
    
    // Buttons section
    @IBOutlet weak var loginButton: MDCButton!
    @IBOutlet weak var cloudSignInButton: MDCButton!
    @IBOutlet weak var advancedSettingsButton: MDCButton!
    
    // Copyright section
    @IBOutlet weak var copyrightLabel: UILabel!
    
    // Gesture recognizer
    var tapGestureRecognizer: UITapGestureRecognizer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let colorSchemeManager = self.colorSchemeManager else {
            AFALog.logError("Color scheme manager could not be initiated")
            return
        }
        
        // Title section
        processServicesAppLabel.text = NSLocalizedString(kLocalizationLoginProcessServicesAppText, comment: "App name")
        processServicesAppLabel.font = colorSchemeManager.defaultTypographyScheme.headline5
        
        // Alfresco URL section
        alfrescoURLTextFieldController = MDCTextInputControllerOutlined(textInput: alfrescoURLTextField)
        alfrescoURLTextFieldController?.placeholderText = loginViewModel.alfrescoURLPlaceholderText
        if let alfrescoURLTextFieldController = self.alfrescoURLTextFieldController {
            MDCTextFieldColorThemer.applySemanticColorScheme(colorSchemeManager.defaultColorScheme, to: alfrescoURLTextFieldController)
        }
        
        // Process URL section
        processURLTextFieldController = MDCTextInputControllerOutlined(textInput: processURLTextField)
        processURLTextFieldController?.placeholderText = loginViewModel.processURLPlaceholderText
        processURLTextField.isHidden = true
        processURLInfoButton.isHidden = true
        
        // HTTPS section
        httpsLabel.text = loginViewModel.useHTTPSText
        httpsLabel.font = colorSchemeManager.defaultTypographyScheme.subtitle1
        httpsLabel.textColor = colorSchemeManager.defaultColorScheme.onBackgroundColor
        httpsSwitch.onTintColor = colorSchemeManager.defaultColorScheme.primaryColor
        
        // Button section section
        loginButton.setTitle(loginViewModel.connectButtonText, for: .normal)
        loginButton.applyContainedTheme(withScheme: colorSchemeManager.flatButtonWithBackgroundScheme)
        loginButton.setElevation(.none, for: .normal)
        loginButton.setElevation(.none, for: .highlighted)
        loginButton.setTitleFont(colorSchemeManager.defaultTypographyScheme.headline4, for: .normal)
        
        advancedSettingsButton.setTitle(loginViewModel.advancedSettingsButtonText, for: .normal)
        advancedSettingsButton.applyTextTheme(withScheme: colorSchemeManager.grayFlatButtonWithoutBackgroundScheme)
        
        cloudSignInButton.setTitle(loginViewModel.cloudSignInButtonText, for: .normal)
        cloudSignInButton.applyTextTheme(withScheme: colorSchemeManager.highlighterFlatButtonWithBackgroundScheme)
        
        // Copyright section
        copyrightLabel.text = loginViewModel.copyrightText
        copyrightLabel.font = colorSchemeManager.defaultTypographyScheme.subtitle1
        copyrightLabel.textColor = colorSchemeManager.grayColorScheme.primaryColor
        
        // Dismiss keyboard on taps outside text fields
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        if let gestureRecognizer = tapGestureRecognizer {
            self.view .addGestureRecognizer(gestureRecognizer)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
           super.viewWillAppear(animated)
           
           self.navigationController?.setNavigationBarHidden(true, animated: true)
       }
    
    // MARK: Actions
    
    @IBAction func loginButtonTapped(_ sender: Any) {
    }
    
    @IBAction func alfrescoURLInfoButtonTapped(_ sender: Any) {
        let alertController = MDCAlertController(title:NSLocalizedString(kLocalizationLoginScreenIndentityServiceURLHintTitleText, comment: "Title"), message: NSLocalizedString(kLocalizationLoginScreenIdentityServiceURLHintText, comment: "Hint message"))
        let action = MDCAlertAction(title: NSLocalizedString(kLocalizationAlertDialogOkButtonText, comment: "OK")) { (action) in
            
        }
        alertController.addAction(action)
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func processURLInfoButtonTapped(_ sender: Any) {
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension AIMSLoginViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if alfrescoURLTextField == textField {
            alfrescoURLInfoButton.isHidden = true
        } else {
            processURLInfoButton.isHidden = true;
        }
        
        return true;
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if alfrescoURLTextField == textField {
            alfrescoURLInfoButton.isHidden = false
        } else {
            processURLInfoButton.isHidden = false
        }
    }
}

extension MDCTextField {
    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 40))
    }
}

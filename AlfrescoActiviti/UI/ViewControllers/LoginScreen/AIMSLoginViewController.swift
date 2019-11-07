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

enum ControllerState {
    case isLoading
    case isIdle
}

class AIMSLoginViewController: UIViewController {
    
    let loginViewModel: AIMSLoginViewModel = AIMSLoginViewModel()
    
    // App name section
    @IBOutlet weak var processServicesAppLabel: UILabel!
    
    // URLs section
    @IBOutlet weak var alfrescoURLTextField: MDCTextField!
    var alfrescoURLTextFieldController: MDCTextInputController?
    
    // Buttons section
    @IBOutlet weak var connectToButton: MDCButton!
    @IBOutlet weak var cloudSignInButton: MDCButton!
    @IBOutlet weak var advancedSettingsButton: MDCButton!
    @IBOutlet weak var needHelpButton: MDCButton!
    
    // Copyright section
    @IBOutlet weak var copyrightLabel: UILabel!
    
    // Loading view
    var overlayView: AIMSActivityView?
    
    // Gesture recognizer
    var tapGestureRecognizer: UITapGestureRecognizer?
    var controllerState: ControllerState? {
        didSet {
            switch controllerState {
            case .isLoading:
                if let loadingView = overlayView {
                    self.view.isUserInteractionEnabled = false
                    self.view.addSubview(loadingView)
                }
            case .isIdle, .none:
                overlayView?.removeFromSuperview()
            }
        }
    }
    
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
        alfrescoURLTextField.font = colorSchemeManager.defaultTypographyScheme.subtitle2
        alfrescoURLTextFieldController = MDCTextInputControllerUnderline(textInput: alfrescoURLTextField)
        alfrescoURLTextFieldController?.placeholderText = loginViewModel.alfrescoURLPlaceholderText
        if let alfrescoURLTextFieldController = self.alfrescoURLTextFieldController {
            MDCTextFieldColorThemer.applySemanticColorScheme(colorSchemeManager.textfieldDefaultColorScheme, to: alfrescoURLTextFieldController)
        }
        
        // Button section section
        connectToButton.setTitle(loginViewModel.connectButtonText, for: .normal)
        connectToButton.applyContainedTheme(withScheme: colorSchemeManager.flatButtonWithBackgroundScheme)
        connectToButton.setElevation(.none, for: .normal)
        connectToButton.setElevation(.none, for: .highlighted)
        connectToButton.setTitleFont(colorSchemeManager.defaultTypographyScheme.headline6, for: .normal)
    
        advancedSettingsButton.setTitle(loginViewModel.advancedSettingsButtonText, for: .normal)
        advancedSettingsButton.applyTextTheme(withScheme: colorSchemeManager.highlightedFlatButtonWithBackgroundScheme)
        advancedSettingsButton.setTitleFont(colorSchemeManager.defaultTypographyScheme.headline3, for: .normal)
        
        cloudSignInButton.setTitle(loginViewModel.cloudSignInButtonText, for: .normal)
        cloudSignInButton.applyOutlinedTheme(withScheme: colorSchemeManager.flatButtonWithoutBackgroundScheme)
        cloudSignInButton.setElevation(.none, for: .normal)
        cloudSignInButton.setElevation(.none, for: .highlighted)
        cloudSignInButton.setTitleFont(colorSchemeManager.defaultTypographyScheme.headline6, for: .normal)
        
        needHelpButton.setTitle(loginViewModel.helpButtonText, for: .normal)
        needHelpButton.applyTextTheme(withScheme: colorSchemeManager.blueFlatButtonWithoutBackgroundScheme)
        needHelpButton.setTitleFont(colorSchemeManager.defaultTypographyScheme.headline3, for: .normal)
        
        // Copyright section
        copyrightLabel.text = loginViewModel.copyrightText
        copyrightLabel.font = colorSchemeManager.defaultTypographyScheme.subtitle1
        copyrightLabel.textColor = colorSchemeManager.grayColorScheme.primaryColor
        
        // Loading view
        overlayView = AIMSActivityView(frame: self.view.frame)
        overlayView?.applySemanticColorScheme(colorScheme: colorSchemeManager.grayColorScheme, typographyScheme: colorSchemeManager.defaultTypographyScheme)
        overlayView?.label.text = NSLocalizedString(kLocalizationOfflineConnectivityRetryText, comment: "Connecting")
        
        // Dismiss keyboard on taps outside text fields
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        if let gestureRecognizer = tapGestureRecognizer {
            self.view .addGestureRecognizer(gestureRecognizer)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.navigationController?.setNavigationBarHidden(true, animated: true)
        updateConnectButtonState()
    }
    
    // MARK: Actions
    
    @IBAction func connectButtonTapped(_ sender: Any) {
//        controllerState = .isLoading
        var identifier = ssoViewControllerIdentifier
        let viewController = storyboard?.instantiateViewController(withIdentifier: identifier)
        if let viewController = viewController {
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    @IBAction func cloudSignInButtonTapped(_ sender: Any) {
    }
    
    @IBAction func advancedButtonTapped(_ sender: Any) {
    }
    
    @IBAction func needHelpButtonTapped(_ sender: Any) {
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: Validations
    
    fileprivate func updateConnectButtonState() {
        if let urlValue = alfrescoURLTextField.text {
            connectToButton.isEnabled = !urlValue.isEmpty
        }
    }
}

extension AIMSLoginViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        if alfrescoURLTextField == textField {
            updateConnectButtonState()
        }
    }
}

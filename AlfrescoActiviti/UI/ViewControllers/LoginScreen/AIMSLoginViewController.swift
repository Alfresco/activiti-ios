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
import enum AlfrescoAuth.AvailableAuthType
import struct AlfrescoCore.APIError

enum ControllerState {
    case isLoading
    case isIdle
}

class AIMSLoginViewController: AFABaseThemedViewController, SplashScreenProtocol {
    
    let loginViewModel: AIMSLoginViewModel = AIMSLoginViewModel()
    weak var delegate: SplashScreenDelegate?
    
    // App name section
    @IBOutlet weak var processServicesAppLabel: UILabel!
    
    // URLs section
    @IBOutlet weak var alfrescoURLTextField: MDCTextField!
    var alfrescoURLTextFieldController: MDCTextInputController?
    
    // Buttons section
    @IBOutlet weak var connectToButton: MDCButton!
    var enableConnectButton: Bool = false
    @IBOutlet weak var cloudSignInButton: MDCButton!
    @IBOutlet weak var advancedSettingsButton: MDCButton!
    @IBOutlet weak var needHelpButton: MDCButton!
    
    // Copyright section
    @IBOutlet weak var copyrightLabel: UILabel!
    
    // Constraints
    var rateConstraintsOnce: Bool = true
    @IBOutlet weak var constraintSeparator1: NSLayoutConstraint!
    @IBOutlet weak var constraintSeparator2: NSLayoutConstraint!
    @IBOutlet weak var constraintSeparator3: NSLayoutConstraint!
    
    // Gesture recognizer
    var tapGestureRecognizer: UITapGestureRecognizer?
    
    // Loading view
    var overlayView: AIMSActivityView?
    var controllerState: ControllerState? {
        didSet {
            switch controllerState {
            case .isLoading:
                if let loadingView = overlayView {
                    self.view.isUserInteractionEnabled = false
                    self.navigationController?.navigationBar.isUserInteractionEnabled = false
                    self.navigationController?.view.addSubview(loadingView)
                }
            case .isIdle, .none:
                self.view.isUserInteractionEnabled = true
                self.navigationController?.navigationBar.isUserInteractionEnabled = true
                overlayView?.removeFromSuperview()
            }
        }
    }
    
    //MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let colorSchemeManager = self.colorSchemeManager else {
            AFALog.logError("Color scheme manager could not be initiated")
            return
        }
        
        loginViewModel.delegate = self
        
        // Title section
        processServicesAppLabel.text = NSLocalizedString(kLocalizationLoginProcessServicesAppText, comment: "App name")
        processServicesAppLabel.font = colorSchemeManager.labelsTypographyScheme.headline1
        
        // Alfresco URL section
        alfrescoURLTextField.font = colorSchemeManager.textFieldTypographyScheme.headline1
        alfrescoURLTextFieldController = MDCTextInputControllerUnderline(textInput: alfrescoURLTextField)
        alfrescoURLTextFieldController?.placeholderText = loginViewModel.alfrescoURLPlaceholderText
        alfrescoURLTextFieldController?.inlinePlaceholderFont = colorSchemeManager.textFieldTypographyScheme.subtitle1
        alfrescoURLTextFieldController?.inlinePlaceholderColor = colorSchemeManager.textfieldDefaultColorScheme.onSurfaceColor
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
        
        // Dismiss keyboard on taps outside text fields
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        if let gestureRecognizer = tapGestureRecognizer {
            self.view .addGestureRecognizer(gestureRecognizer)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.navigationController?.navigationBar.backItem?.title = ""
        
        controllerState = .isIdle
        updateConnectButtonState()
        
        if rateConstraintsOnce {
            rateConstraintsOnce = false
            let rate: CGFloat = 0.4
            constraintSeparator1.scale(in: view, rate: rate)
            constraintSeparator2.scale(in: view)
            if self.view.bounds.size.height <= 568 && UIDevice.current.userInterfaceIdiom == .phone {
                constraintSeparator3.constant = 10
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard let colorSchemeManager = self.colorSchemeManager else {
            AFALog.logError("Color scheme manager could not be initiated")
            return
        }
        
        // Loading view
        overlayView = AIMSActivityView(frame: self.view.bounds)
        overlayView?.applySemanticColorScheme(colorScheme: colorSchemeManager.activityViewColorScheme,
                                              typographyScheme: colorSchemeManager.defaultTypographyScheme)
        overlayView?.label.text = NSLocalizedString(kLocalizationOfflineConnectivityRetryText, comment: "Connecting")
    }
    
   
    
    // MARK: - Actions
    
    @IBAction func connectButtonTapped(_ sender: Any) {
        self.view.endEditing(true)
        if let alfrescoURL = alfrescoURLTextField.text {
            controllerState = .isLoading
            loginViewModel.availableAuthType(for: alfrescoURL)
        }
    }
    
    @IBAction func advancedButtonTapped(_ sender: Any) {
    }
    
    @IBAction func needHelpButtonTapped(_ sender: Any) {
        self.view.endEditing(true)
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let helpVC = storyboard.instantiateViewController(withIdentifier: kStoryboardIDAIMSHelpViewController) as! AIMSHelpViewController
        helpVC.hintText = loginViewModel.helpHintText
        helpVC.titleText = loginViewModel.helpText
        helpVC.closeText = loginViewModel.closeText
        helpVC.modalPresentationStyle = .overCurrentContext
        self.present(helpVC, animated: false, completion: nil)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Helpers
     
    fileprivate func updateConnectButtonState() {
        connectToButton.isEnabled = enableConnectButton
    }

    // MARK: - Navigation
    
    @IBAction func unwindToAIMSLoginViewController(_ sender: UIStoryboardSegue) {
        alfrescoURLTextField.text = nil
        alfrescoURLTextFieldController?.setErrorText(nil, errorAccessibilityValue: "")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if kSegueIDBaseAuthLoginSegueID == segue.identifier {
            if let destinationVC = segue.destination as? BaseAuthLoginViewController {
                destinationVC.delegate = self.delegate
                loginViewModel.prepareViewModel(for: destinationVC, authenticationType: .basicAuth, isCloud: true)
            }
        }
    }
}

// MARK: - UITextField Delegate

extension AIMSLoginViewController: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if alfrescoURLTextField == textField {
            enableConnectButton = (textField.text != "")
            updateConnectButtonState()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var shouldEnable = false
        if alfrescoURLTextField == textField {
            if let text = textField.text {
                if  let textRange = Range(range, in: text) {
                    let updatedText = text.replacingCharacters(in: textRange, with: string)
                    shouldEnable = (updatedText != "")
                }
            }
            enableConnectButton = shouldEnable
            updateConnectButtonState()
        }
        return true
    }
}

// MARK: - AIMSLoginViewModel Delegate

extension AIMSLoginViewController: AIMSLoginViewModelDelegate {
    func authenticationServiceUnavailable(with error: APIError) {
        DispatchQueue.main.async { [weak self] in
            guard let sSelf = self else { return }
            
            sSelf.controllerState = .isIdle
            
            sSelf.alfrescoURLTextFieldController?.setErrorText("", errorAccessibilityValue: "")
            
            if UIDevice.current.userInterfaceIdiom == .pad {
                sSelf.delegate?.showError(message: error.localizedDescription)
            } else {
                sSelf.showErrorMessage(error.localizedDescription)
            }
        }
    }
    
    func authenticationServiceAvailable(for authType: AvailableAuthType) {
        var identifier: String?
        
        switch authType {
        case .basicAuth:
            AFALog.logVerbose("Available authentication type is: on premise")
            identifier = kStoryboardIDBaseAuthLoginViewController
        case .aimsAuth:
            AFALog.logVerbose("Available authentication type is: aims")
            identifier = kStoryboardIDAIMSSSOViewController
        }
        
        if let authenticationControllerIdentifier = identifier {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                guard let sSelf = self else { return }
                
                sSelf.controllerState = .isIdle
                sSelf.alfrescoURLTextFieldController?.setErrorText(nil, errorAccessibilityValue: "")
                
                let viewController = sSelf.storyboard?.instantiateViewController(withIdentifier: authenticationControllerIdentifier)
                if let viewController = viewController {
                    if viewController is SplashScreenProtocol {
                        (viewController as! SplashScreenProtocol).delegate = sSelf.delegate
                    }
                    sSelf.loginViewModel.prepareViewModel(for: viewController, authenticationType: authType)
                    sSelf.navigationController?.pushViewController(viewController, animated: true)
                }
            }
        }
    }
}

extension MDCTextField {

    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: UIEdgeInsets(top: 0, left: 6, bottom: 0, right: 12))
    }
    open override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: UIEdgeInsets(top: 0, left: 6, bottom: 0, right: 12))
    }

    open override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: UIEdgeInsets(top: 0, left: 6, bottom: 0, right: 12))
    }
}

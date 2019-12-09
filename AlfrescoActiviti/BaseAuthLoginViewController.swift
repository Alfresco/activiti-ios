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

class BaseAuthLoginViewController: AFABaseThemedViewController {

    let model: BaseAuthLoginViewModel = BaseAuthLoginViewModel()
    
    // App name section
    @IBOutlet weak var processServicesAppLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var hostNameLabel: UILabel!
    
    // Copyrigh section
    @IBOutlet weak var copyrightLabel: UILabel!
    
    
    // Fields section
    @IBOutlet weak var usernameTextfield: MDCTextField!
    @IBOutlet weak var passwordTextfield: MDCTextField!
    var usernameTextFieldController: MDCTextInputController?
    var passwordTextFieldController: MDCTextInputController?
    
    // Buttons section
    @IBOutlet weak var signInButton: MDCButton!
    @IBOutlet weak var helpButton: MDCButton!
    var enableSignInButton: Bool = false
    var showPasswordButton = UIButton()
    
    // Constraints
    
    @IBOutlet weak var constraintSeparator1: NSLayoutConstraint!
    @IBOutlet weak var constraintSeparator2: NSLayoutConstraint!
    var rateConstraintsOnce: Bool = true

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
    
    // Keyboard handling
    var keyboardHandling = KeyboardHandling()
    
    //MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        guard let colorSchemeManager = self.colorSchemeManager else {
            AFALog.logError("Color scheme manager could not be initiated")
            return
        }
        
        processServicesAppLabel.text = NSLocalizedString(kLocalizationLoginProcessServicesAppText, comment: "App name")
        processServicesAppLabel.font = colorSchemeManager.labelsTypographyScheme.headline1
        
        infoLabel.text = model.loginStrategy?.infoText
        infoLabel.font = colorSchemeManager.labelsTypographyScheme.subtitle2
        hostNameLabel.text = ""
        
        
        if (model.loginStrategy as? PremiseLoginStrategy) != nil {
            infoLabel.textColor = colorSchemeManager.grayColorScheme.primaryColor
            infoLabel.font = colorSchemeManager.labelsTypographyScheme.subtitle1
            hostNameLabel.text = AIMSAuthenticationParameters.parameters().hostname
            hostNameLabel.textColor = colorSchemeManager.grayColorScheme.primaryColor
            hostNameLabel.font = colorSchemeManager.labelsTypographyScheme.subtitle2
        } 
        
        // Username textfield
        usernameTextfield.rightViewMode = .unlessEditing
        usernameTextfield.rightView = UIImageView(image: UIImage(named: "username-icon"))
        usernameTextfield.rightView?.tintColor = #colorLiteral(red: 0.7254338861, green: 0.7255221009, blue: 0.7254036665, alpha: 1)
        usernameTextfield.font = colorSchemeManager.textFieldTypographyScheme.headline1
        usernameTextFieldController = MDCTextInputControllerUnderline(textInput: usernameTextfield)
        usernameTextFieldController?.placeholderText = model.loginStrategy?.usernamaPlaceholderText
        usernameTextFieldController?.inlinePlaceholderFont = colorSchemeManager.textFieldTypographyScheme.subtitle1
        if let usernameTextFieldController = self.usernameTextFieldController {
            MDCTextFieldColorThemer.applySemanticColorScheme(colorSchemeManager.textfieldDefaultColorScheme, to: usernameTextFieldController)
        }
        
        // Password Textfield
        showPasswordButton.setImage(UIImage(named: "hide-password-icon"), for: .normal)
        showPasswordButton.setImage(UIImage(named: "show-password-icon"), for: .selected)
        showPasswordButton.addTarget(self, action: #selector(showPasswordButtonPressed(_:)), for: .touchUpInside)
        
        if #available(iOS 13, *) {
            
        } else {
            showPasswordButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -22.5)
            showPasswordButton.frame = CGRect(x: 0, y: 0, width: 45, height: 45)
        }
        
        passwordTextfield.rightViewMode = .always
        passwordTextfield.rightView = showPasswordButton
        passwordTextfield.rightView?.tintColor = #colorLiteral(red: 0.7254338861, green: 0.7255221009, blue: 0.7254036665, alpha: 1)
        passwordTextfield.font = colorSchemeManager.textFieldTypographyScheme.headline1
        passwordTextFieldController = MDCTextInputControllerUnderline(textInput: passwordTextfield)
        passwordTextFieldController?.placeholderText = model.loginStrategy?.passwordPlaceholderText
        passwordTextFieldController?.inlinePlaceholderFont = colorSchemeManager.textFieldTypographyScheme.subtitle1
        if let passwordTextFieldController = self.passwordTextFieldController {
            MDCTextFieldColorThemer.applySemanticColorScheme(colorSchemeManager.textfieldDefaultColorScheme, to: passwordTextFieldController)
        }
        
        // Help button
        helpButton.setTitle(model.loginStrategy?.helpButtonText, for: .normal)
        helpButton.applyTextTheme(withScheme: colorSchemeManager.blueFlatButtonWithoutBackgroundScheme)
        helpButton.setTitleFont(colorSchemeManager.defaultTypographyScheme.headline3, for: .normal)
        
        // Copyright section
        copyrightLabel.text = model.loginStrategy?.copyrightText
        copyrightLabel.font = colorSchemeManager.defaultTypographyScheme.subtitle1
        copyrightLabel.textColor = colorSchemeManager.grayColorScheme.primaryColor
        
        shouldEnableSignInButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.backItem?.title = ""
        
        if rateConstraintsOnce {
            rateConstraintsOnce = false
            let rate: CGFloat = 0.4
            let heightNavigationBar = self.navigationController?.navigationBar.bounds.size.height ?? 0
            constraintSeparator1.scale(in: view, heightNavigationBar: heightNavigationBar , rate: rate)
            constraintSeparator2.scale(in: view)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard let colorSchemeManager = self.colorSchemeManager else {
            AFALog.logError("Color scheme manager could not be initiated")
            return
        }
        
        // Loading view
        overlayView = AIMSActivityView(frame: self.view.frame)
        overlayView?.applySemanticColorScheme(colorScheme: colorSchemeManager.activityViewColorScheme,
                                              typographyScheme: colorSchemeManager.defaultTypographyScheme)
        overlayView?.label.text = NSLocalizedString(kLocalizationOfflineConnectivityRetryText, comment: "Connecting")
    }
    
    override func didRestoredNetworkConnectivity() {
        // Don't display network connectivity alerts on this screen
    }
    
    //MARK: - IBActions
    
    @objc func showPasswordButtonPressed(_ sender: UIButton) {
        passwordTextfield.isSecureTextEntry = showPasswordButton.isSelected
        showPasswordButton.isSelected = !showPasswordButton.isSelected
    }
    
    @IBAction func signInButtonPressed(_ sender: MDCButton) {
        self.view.endEditing(true)
        if let username = usernameTextfield.text, let password = passwordTextfield.text {
            controllerState = .isLoading
            model.signIn(username: username, password: password) { [weak self] (result) in
                guard let sSelf = self else { return }
                sSelf.controllerState = .isIdle
                switch result {
                case .failure(let error):
                    AFALog.logError(error.localizedDescription)
                    sSelf.usernameTextFieldController?.setErrorText("", errorAccessibilityValue: "")
                    sSelf.passwordTextFieldController?.setErrorText("", errorAccessibilityValue: "")
                    if (error as NSError).domain == AFALoginViewModelWarningDomain {
                        sSelf.showWarningMessage(error.localizedDescription)
                    } else {
                        sSelf.showErrorMessage(error.localizedDescription)
                    }
                    
                    break
                case .success(_):
                    sSelf.performSegue(withIdentifier: kSegueIDLoginAuthorized, sender: nil)
                    break
                }
            }
        }
    }
    
    @IBAction func helpButtonPressed(_ sender: MDCButton) {
        self.view.endEditing(true)
        let helpVC = storyboard?.instantiateViewController(withIdentifier: kStoryboardIDAIMSHelpViewController) as! AIMSHelpViewController
        
        if let loginStrategyModel = model.loginStrategy {
            helpVC.hintText = loginStrategyModel.helpHintText
            helpVC.titleText = loginStrategyModel.helpText
            helpVC.closeText = loginStrategyModel.closeText
        }

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
        
        signInButton.setTitle(model.loginStrategy?.signInButtonText, for: .normal)
        signInButton.isEnabled = enableSignInButton
        if enableSignInButton {
            signInButton.applyContainedTheme(withScheme: colorSchemeManager.flatButtonWithBackgroundScheme)
        } else {
            signInButton.applyContainedTheme(withScheme: colorSchemeManager.grayFlatButtonWithoutBackgroundScheme)
        }
        signInButton.setElevation(.none, for: .normal)
        signInButton.setElevation(.none, for: .highlighted)
        signInButton.setTitleFont(colorSchemeManager.defaultTypographyScheme.headline6, for: .normal)
        signInButton.semanticContentAttribute = .forceRightToLeft
    }
    
    //MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == kSegueIDLoginAuthorized {
            let cvc = segue.destination as! AFAContainerViewController
            cvc.transitioningDelegate = self
            cvc.viewModel = ContainerViewModel.init(with: model.persistenceStackModelName())
        }
    }
}

// MARK: - UIViewControllerTransitioning Delegate

extension BaseAuthLoginViewController: UIViewControllerTransitioningDelegate {
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return AFAModalDismissAnimator()
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return AFAModalDismissAnimator()
    }
}

// MARK: - UITextField Delegate

extension BaseAuthLoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textField.rightView?.tintColor = #colorLiteral(red: 0.07236295193, green: 0.6188754439, blue: 0.2596520483, alpha: 1)
        
        let textFieldRect = textField.frame
        let frameInSuperview =  self.view.convert(textFieldRect, to: UIApplication.shared.keyWindow)
        let heightTextFieldOpened = textFieldRect.size.height + view.safeAreaInsets.bottom
        
        keyboardHandling.add(positionObjectInSuperview: frameInSuperview.origin.y + heightTextFieldOpened,
                             positionObjectInView: textFieldRect.origin.y + heightTextFieldOpened,
                             heightObject: 0,
                             in: self.view)

        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        textField.rightView?.tintColor = #colorLiteral(red: 0.7254338861, green: 0.7255221009, blue: 0.7254036665, alpha: 1)
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        enableSignInButton = (usernameTextfield.text != ""  && passwordTextfield.text != "")
        shouldEnableSignInButton()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        enableSignInButton = (usernameTextfield.text != ""  && passwordTextfield.text != "")
        shouldEnableSignInButton()
        return true
    }
}

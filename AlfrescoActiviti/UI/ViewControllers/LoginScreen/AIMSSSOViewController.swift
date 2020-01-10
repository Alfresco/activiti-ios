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
import AlfrescoCore

class AIMSSSOViewController: AFABaseThemedViewController, SplashScreenProtocol {
    
    let model: AIMSSSOViewModel = AIMSSSOViewModel()
    weak var delegate: SplashScreenDelegate?
    
    // App name section
    @IBOutlet weak var processServiceAppLabel: UILabel!
    @IBOutlet weak var subtitle1Label: UILabel!
    
    // URLs section
    @IBOutlet weak var serverURLLabel: UILabel!
    @IBOutlet weak var subtitle2Label: UILabel!
    @IBOutlet weak var repositoryTextField: MDCTextField!
    var repositoryTextFieldController: MDCTextInputController?
    
    // Buttons section
    @IBOutlet weak var signInButton: MDCButton!
    @IBOutlet weak var helpButton: MDCButton!
    
    // Copyright section
    @IBOutlet weak var copyrightLabel: UILabel!
    
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
                    self.navigationController?.setNavigationBarHidden(true, animated: false)
                    self.view.addSubview(loadingView)
                }
            case .isIdle, .none:
                self.view.isUserInteractionEnabled = true
                self.navigationController?.navigationBar.isUserInteractionEnabled = true
                self.navigationController?.setNavigationBarHidden(false, animated: false)
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
        self.navigationController?.navigationBar.backItem?.title = ""
        
        guard let colorSchemeManager = self.colorSchemeManager else {
            AFALog.logError("Color scheme manager could not be initiated")
            return
        }
        
        self.model.delegate = self
        
        processServiceAppLabel.text = NSLocalizedString(kLocalizationLoginProcessServicesAppText, comment: "App name")
        processServiceAppLabel.font = colorSchemeManager.labelsTypographyScheme.headline1
        processServiceAppLabel.add(spacing: -1.0)
        
        subtitle1Label.text = model.subtitle1Text
        subtitle1Label.textColor = colorSchemeManager.grayColorScheme.primaryColor
        subtitle1Label.font = colorSchemeManager.labelsTypographyScheme.subtitle1
        
        serverURLLabel.text = model.serverURLText
        serverURLLabel.textColor = colorSchemeManager.grayColorScheme.primaryColor
        serverURLLabel.font = colorSchemeManager.labelsTypographyScheme.subtitle2
        
        subtitle2Label.text = model.subtitle2Text
        subtitle2Label.font = colorSchemeManager.labelsTypographyScheme.subtitle2
        
        // Repository textfield
        repositoryTextField.font = colorSchemeManager.textFieldTypographyScheme.headline1
        repositoryTextFieldController = MDCTextInputControllerUnderline(textInput: repositoryTextField)
        repositoryTextFieldController?.placeholderText = model.repositoryPlaceholderText
        repositoryTextFieldController?.inlinePlaceholderFont = colorSchemeManager.textFieldTypographyScheme.subtitle1
        repositoryTextFieldController?.inlinePlaceholderColor = colorSchemeManager.textfieldDefaultColorScheme.onSurfaceColor
        if let repositoryTextFieldController = self.repositoryTextFieldController {
            MDCTextFieldColorThemer.applySemanticColorScheme(colorSchemeManager.textfieldDefaultColorScheme, to: repositoryTextFieldController)
        }
        
        // Help button
        helpButton.setTitle(model.helpButtonText, for: .normal)
        helpButton.applyTextTheme(withScheme: colorSchemeManager.blueFlatButtonWithoutBackgroundScheme)
        helpButton.setTitleFont(colorSchemeManager.defaultTypographyScheme.headline3, for: .normal)
        
        // Copyright section
        copyrightLabel.text = model.copyrightText
        copyrightLabel.font = colorSchemeManager.defaultTypographyScheme.subtitle1
        copyrightLabel.textColor = colorSchemeManager.grayColorScheme.primaryColor
        
        repositoryTextField.text = AIMSAuthenticationParameters.parameters().processURL
        shouldEnableSignInButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
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
        overlayView?.label.text = NSLocalizedString(kLocalizationSSOLoginScreenSigningInText, comment: "Signing In")
        overlayView?.overlayView?.alpha = 1
        if (self.view.traitCollection.horizontalSizeClass == .compact) {
            overlayView?.imageView?.image = UIImage(named: "splash-wallpaper")
        }
    }

    override func didRestoredNetworkConnectivity() {
        // Don't display network connectivity alerts on this screen
    }
    
    //MARK: - IBActions
    
    @IBAction func signInButtonPressed(_ sender: MDCButton) {
        self.view.endEditing(true)
        self.controllerState = .isLoading
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            self.delegate?.dismiss(animated: true)
        } else {
            self.dismissMessage(true)
        }
        
        if let apsURL = repositoryTextField.text {
            model.authParameters?.processURL = apsURL
            model.login(onViewController: self)
        }
    }
    
    @IBAction func helpButtonPressed(_ sender: Any) {
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
    
    //MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == kSegueIDLoginAuthorized {
            let cvc = segue.destination as! AFAContainerViewController
            cvc.transitioningDelegate = self
            cvc.viewModel = ContainerViewModel.init(with: model.persistenceStackModelName(), logoutViewController: cvc)
        }
    }
    
    //MARK: - Helpers
    
    func shouldEnableSignInButton() {
        guard let colorSchemeManager = self.colorSchemeManager else {
            AFALog.logError("Color scheme manager could not be initiated")
            return
        }
        signInButton.setTitle(model.signInSSOButtonText, for: .normal)
        signInButton.isEnabled = (repositoryTextField.text != "")
        if signInButton.isEnabled {
            signInButton.applyContainedTheme(withScheme: colorSchemeManager.flatButtonWithBackgroundScheme)
        } else {
            signInButton.applyContainedTheme(withScheme: colorSchemeManager.grayFlatButtonWithoutBackgroundScheme)
        }
        signInButton.setElevation(.none, for: .normal)
        signInButton.setElevation(.none, for: .highlighted)
        signInButton.setTitleFont(colorSchemeManager.defaultTypographyScheme.headline6, for: .normal)
        signInButton.semanticContentAttribute = .forceRightToLeft
    }
}

// MARK: - UITextField Delegate

extension AIMSSSOViewController: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        shouldEnableSignInButton()
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        let textFieldRect = textField.frame
        let frameInSuperview =  self.view.convert(textFieldRect, to: UIApplication.shared.keyWindow)
        let heightTextFieldOpened = textFieldRect.size.height + view.safeAreaInsets.bottom
        
        keyboardHandling.add(positionObjectInSuperview: frameInSuperview.origin.y + heightTextFieldOpened,
                             positionObjectInView: textFieldRect.origin.y + heightTextFieldOpened,
                             heightObject: 0,
                             in: self.view)
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        shouldEnableSignInButton()
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - AIMSSSOViewModel Delegate

extension AIMSSSOViewController: AIMSSSOViewModelDelegate {
    func logInWarning(with message: String) {
        DispatchQueue.main.async { [weak self] in
            guard let sSelf = self else { return }
        
            sSelf.controllerState = .isIdle
            
            AFALog.logWarning(message)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + kOverlayAlphaChangeTime) { [weak self] in
                guard let sSelf = self else { return }
            
                if UIDevice.current.userInterfaceIdiom == .pad {
                    sSelf.delegate?.showWarning(message: message)
                } else {
                    sSelf.showWarningMessage(message)
                }
            }
        }
    }
    
    func logInSuccessful() {
        DispatchQueue.main.asyncAfter(deadline: .now() + kDefaultAnimationTime) { [weak self] in
            guard let sSelf = self else { return }

            sSelf.controllerState = .isIdle
            sSelf.performSegue(withIdentifier: kSegueIDLoginAuthorized, sender: nil)
        }
    }
    
    func logInFailed(with error: APIError) {
        DispatchQueue.main.async { [weak self] in
            guard let sSelf = self else { return }

            sSelf.controllerState = .isIdle
            
            AFALog.logError(error.localizedDescription)
            if error.responseCode != kAFALoginSSOViewModelCancelErrorCode {
                DispatchQueue.main.asyncAfter(deadline: .now() + kDefaultAnimationTime) { [weak self] in
                    guard let sSelf = self else { return }
                    
                    sSelf.repositoryTextFieldController?.setErrorText("", errorAccessibilityValue: "")
                    if UIDevice.current.userInterfaceIdiom == .pad {
                        sSelf.delegate?.showError(message: error.localizedDescription)
                    } else {
                        sSelf.showErrorMessage(error.localizedDescription)
                    }
                }
            }
        }
    }
}

//MARK: - UIViewControllerTransitioning Delegate

extension AIMSSSOViewController: UIViewControllerTransitioningDelegate {
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return AFAModalDismissAnimator()
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return AFAModalReplaceAnimator()
    }
}

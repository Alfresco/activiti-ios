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

class AIMSSSOViewController: AFABaseThemedViewController {
    
    let model: AIMSSSOViewModel = AIMSSSOViewModel()
    
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
    var enableSignInButton: Bool = false
    
    // Copyright section
    @IBOutlet weak var copyrightLabel: UILabel!
    
    // Constraints
    @IBOutlet weak var separatorSpace1HeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var separatorSpace2HeightConstraint: NSLayoutConstraint!

    // Loading view
    var overlayView: AIMSActivityView?
    var controllerState: ControllerState? {
        didSet {
            switch controllerState {
            case .isLoading:
                if let loadingView = overlayView {
                    self.view.isUserInteractionEnabled = false
                    self.view.addSubview(loadingView)
                }
            case .isIdle, .none:
                self.view.isUserInteractionEnabled = true
                overlayView?.removeFromSuperview()
            }
        }
    }
    
    var rateConstraintsOnce: Bool = true
    
    //MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        guard let colorSchemeManager = self.colorSchemeManager else {
            AFALog.logError("Color scheme manager could not be initiated")
            return
        }
        
        self.model.delegate = self
        
        processServiceAppLabel.text = model.processServicessAppText
        subtitle1Label.text = model.subtitle1Text
        serverURLLabel.text = model.serverURLText
        subtitle2Label.text = model.subtitle2Text
        
        // Repository textfield
        repositoryTextField.font = colorSchemeManager.textFieldTypographyScheme.headline1
        repositoryTextFieldController = MDCTextInputControllerUnderline(textInput: repositoryTextField)
        repositoryTextFieldController?.placeholderText = model.repositoryPlaceholderText
        repositoryTextFieldController?.inlinePlaceholderFont = colorSchemeManager.textFieldTypographyScheme.subtitle1
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
        
        shouldEnableSignInButton()
        
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Constraints scale
        if rateConstraintsOnce {
            rateConstraintsOnce = false
            self.view.layoutIfNeeded()
            separatorSpace1HeightConstraint.rate(in: self.view, heightNavigationBar: self.navigationController?.navigationBar.bounds.size.height ?? 0)
            separatorSpace2HeightConstraint.rate(in: self.view)
        }
    }
    
    //MARK: - IBActions
    
    @IBAction func signInButtonPressed(_ sender: MDCButton) {
        self.view.endEditing(true)
        self.controllerState = .isLoading
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
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
            cvc.viewModel = ContainerViewModel.init(with: model.persistenceStackModelName())
        }
    }
    
    //MARK: - Helpers
    
    func shouldEnableSignInButton() {
        guard let colorSchemeManager = self.colorSchemeManager else {
            AFALog.logError("Color scheme manager could not be initiated")
            return
        }
        signInButton.setTitle(model.signInSSOButtonText, for: .normal)
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
}

// MARK: - UITextField Delegate

extension AIMSSSOViewController: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        enableSignInButton = (textField.text != "")
        shouldEnableSignInButton()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        enableSignInButton = (textField.text != "")
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
            
            sSelf.navigationController?.setNavigationBarHidden(false, animated: true)
            sSelf.controllerState = .isIdle
            
            AFALog.logWarning(message)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + kOverlayAlphaChangeTime) { [weak self] in
                guard let sSelf = self else { return }
                sSelf.showWarningMessage(message)
            }
        }
    }
    
    func logInSuccessful() {
        DispatchQueue.main.async { [weak self] in
            guard let sSelf = self else { return }
            
            sSelf.navigationController?.setNavigationBarHidden(false, animated: false)
            sSelf.controllerState = .isIdle
            sSelf.performSegue(withIdentifier: kSegueIDLoginAuthorized, sender: nil)
        }
    }
    
    func logInFailed(with error: APIError) {
        DispatchQueue.main.async { [weak self] in
            guard let sSelf = self else { return }
            
            sSelf.navigationController?.setNavigationBarHidden(false, animated: true)
            sSelf.controllerState = .isIdle
            
            AFALog.logError(error.localizedDescription)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + kOverlayAlphaChangeTime) { [weak self] in
                guard let sSelf = self else { return }
                
                sSelf.repositoryTextFieldController?.setErrorText("", errorAccessibilityValue: "")
                sSelf.showErrorMessage(error.localizedDescription)
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
        return AFAModalDismissAnimator()
    }
}

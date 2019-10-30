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
    @IBOutlet weak var processURLTextField: MDCTextField!
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let colorSchemeManager = self.colorSchemeManager else {
            AFALog.logError("Color scheme manager could not be initiated")
            return
        }
        
        // Localization
        processServicesAppLabel.text = NSLocalizedString(kLocalizationLoginProcessServicesAppText, comment: "App name")
        
        // Alfresco URL set up
        alfrescoURLTextFieldController = MDCTextInputControllerOutlined(textInput: alfrescoURLTextField)
        alfrescoURLTextFieldController?.placeholderText = loginViewModel.alfrescoURLPlaceholderText
        if let alfrescoURLTextFieldController = self.alfrescoURLTextFieldController{
            MDCTextFieldColorThemer.applySemanticColorScheme(colorSchemeManager.defaultColorScheme, to: alfrescoURLTextFieldController)
        }
        
        // Process URL set up
        processURLTextFieldController = MDCTextInputControllerOutlined(textInput: processURLTextField)
        processURLTextFieldController?.placeholderText = loginViewModel.processURLPlaceholderText
        
        // HTTPS set up
        httpsLabel.text = loginViewModel.useHTTPSText
        httpsLabel.font = colorSchemeManager.defaultTypographyScheme.subtitle1
        httpsLabel.textColor = colorSchemeManager.defaultColorScheme.onBackgroundColor
        httpsSwitch.onTintColor = colorSchemeManager.defaultColorScheme.primaryColor
        
        // Button section
        loginButton.applyContainedTheme(withScheme: colorSchemeManager.flatButtonWithBackgroundScheme)
        loginButton.setElevation(.none, for: .normal)
        loginButton.setElevation(.none, for: .highlighted)
        advancedSettingsButton.applyTextTheme(withScheme: colorSchemeManager.flatButtonWithoutBackgroundScheme)
        cloudSignInButton.applyTextTheme(withScheme: colorSchemeManager.highlighterFlatButtonWithBackgroundScheme)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
       
}

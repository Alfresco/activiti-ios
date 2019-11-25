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

import Foundation
import MaterialComponents.MDCButton

class AIMSHelpViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var xButton: UIButton!
    @IBOutlet weak var closeButton: MDCButton!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet var constraintsToScale: [NSLayoutConstraint]!
    
    var hintText = ""
    var titleText = ""
    var closeText = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let colorSchemeManager = self.colorSchemeManager else {
            AFALog.logError("Color scheme manager could not be initiated")
            return
        }
        
        textView.attributedText = NSAttributedString(withLocalizedHTMLString: hintText,
                                                     font: colorSchemeManager.defaultTypographyScheme.button)
        
        titleLabel.text = titleText
        titleLabel.font = colorSchemeManager.defaultTypographyScheme.headline5
        
        closeButton.applyOutlinedTheme(withScheme: colorSchemeManager.flatButtonWithoutBackgroundScheme)
        closeButton.setTitle(closeText, for: .normal)
        closeButton.setTitleFont(colorSchemeManager.defaultTypographyScheme.headline6, for: .normal)
        
        bgView.alpha = 1.0
        bgView.backgroundColor = .clear
        
        //Constraints scale
        self.view.layoutIfNeeded()
        if (self.view.traitCollection.horizontalSizeClass == .compact) {
            for constraint in constraintsToScale {
                constraint.rate(in: self.view)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        
        self.view.bounds.origin.y = self.view.bounds.size.height
        UIView.animate(withDuration: 0.4, animations: {
            self.view.bounds.origin.y = 0
        }) { (bool) in
            self.bgView.alpha = 0.4
            self.bgView.backgroundColor = .black
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textView.scrollRangeToVisible(NSRange(location: 0, length: 0))
    }
    
    //MARK: - IBActions
    
    @IBAction func closeButtonPressed(_ sender: Any) {
        self.bgView.alpha = 0.0
        UIView.animate(withDuration: 0.4) {
            self.view.bounds.origin.y = self.view.bounds.height
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            self.dismiss(animated: false, completion: nil)
        })
    }
    
}

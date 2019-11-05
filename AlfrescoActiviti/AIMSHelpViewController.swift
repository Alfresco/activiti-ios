//
//  AIMSHelpViewController.swift
//  AlfrescoActiviti
//
//  Created by Florin Baincescu on 05/11/2019.
//  Copyright © 2019 Emanuel Lupu-Marinei. All rights reserved.
//

import Foundation
import MaterialComponents.MDCButton

class AIMSHelpViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var xButton: UIButton!
    @IBOutlet weak var closeButton: MDCButton!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var bgView: UIView!
    
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    var hintText: String!
    var titleText: String!
    var closeText: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let colorSchemeManager = self.colorSchemeManager else {
            AFALog.logError("Color scheme manager could not be initiated")
            return
        }
        textView.text = hintText
        titleLabel.text = titleText
        
        closeButton.applyContainedTheme(withScheme: colorSchemeManager.flatButtonWithoutBackgroundScheme)
        closeButton.setTitle(closeText, for: .normal)
        closeButton.setTitleFont(colorSchemeManager.defaultTypographyScheme.headline4, for: .normal)
        
        topConstraint.constant = self.view.bounds.height
        bottomConstraint.constant = -1 * self.view.bounds.height
        bgView.alpha = 1.0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        UIView.animate(withDuration: 0.4) {
            self.view.layoutIfNeeded()
            self.bottomConstraint.constant = 100
            self.topConstraint.constant = 0
            self.bgView.alpha = 0.4
            self.bgView.backgroundColor = .black
        }
    }
    
    //MARK: - IBActions
    
    @IBAction func closeButtonPressed(_ sender: Any) {
        self.bottomConstraint.constant = self.view.bounds.height
        self.topConstraint.constant = -1 * self.view.bounds.height
        UIView.animate(withDuration: 0.4) {
            self.view.layoutIfNeeded()
            self.bgView.alpha = 0.0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            self.dismiss(animated: false, completion: nil)
        })
    }
    
}

//
//  SplashScreenViewController.swift
//  AlfrescoActiviti
//
//  Created by Florin Baincescu on 12/11/2019.
//  Copyright © 2019 Emanuel Lupu-Marinei. All rights reserved.
//

import UIKit

class SplashScreenViewController: UIViewController {

    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var logoHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var logoWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var copyrightLabel: UILabel!
    
    var copyrightText: String {
        get {
            let calendar = Calendar.current
            let year = calendar.component(.year, from: Date())
            return String(format: NSLocalizedString(kLocalizationLoginScreenCopyrightFormat, comment: "Copyright text"), year)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let colorSchemeManager = self.colorSchemeManager else {
            AFALog.logError("Color scheme manager could not be initiated")
            return
        }
        
        // Copyright section
        copyrightLabel.text = copyrightText
        copyrightLabel.font = colorSchemeManager.defaultTypographyScheme.subtitle1
        copyrightLabel.textColor = colorSchemeManager.grayColorScheme.primaryColor
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.logoWidthConstraint.constant = self.logoWidthConstraint.constant + 50
        UIView.animate(withDuration: kSplashScreenAnimationTime) {
            self.view.layoutIfNeeded()
            
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + kSplashScreenAnimationTime + 0.2, execute: {
            self.performSegue(withIdentifier: kSegueIDSplashScreen, sender: nil)
        })
    }
}

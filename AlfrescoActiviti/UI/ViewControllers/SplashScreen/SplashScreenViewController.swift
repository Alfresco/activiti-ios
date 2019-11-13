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
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var iceEffectView: UIVisualEffectView!
    
    
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

//        containerView.layer.cornerRadius = 20

        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.7
        containerView.layer.shadowOffset = .zero
        containerView.layer.shadowRadius = 50
        containerView.layer.shadowPath = UIBezierPath(rect: containerView.bounds).cgPath
        containerView.layer.shouldRasterize = true
        containerView.layer.rasterizationScale = UIScreen.main.scale
        

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.logoWidthConstraint.constant = self.logoWidthConstraint.constant + 50
        UIView.animate(withDuration: kSplashScreenAnimationTime) {
            self.view.layoutIfNeeded()
            
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + kSplashScreenAnimationTime + 0.2, execute: {
            self.view.bringSubviewToFront(self.iceEffectView)
            self.view.bringSubviewToFront(self.containerView)
        })
    }
}

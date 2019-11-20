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
        copyrightLabel.isHidden = true

        applyShadow(to: containerView)
    }
    
    func applyShadow(to view: UIView) {
        view.layer.cornerRadius = 20
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.2
        view.layer.shadowOffset = .zero
        view.layer.shadowRadius = 50
        view.layer.shadowPath = UIBezierPath(rect: view.bounds).cgPath
        view.layer.shouldRasterize = true
        view.layer.rasterizationScale = UIScreen.main.scale
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.containerView.alpha = 0.0
        self.logoWidthConstraint.constant = self.logoWidthConstraint.constant + 50
        UIView.animate(withDuration: kSplashScreenAnimationTime) {
            self.view.layoutIfNeeded()
            
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + kSplashScreenAnimationTime + 0.2, execute: {
            self.view.bringSubviewToFront(self.iceEffectView)
            self.view.bringSubviewToFront(self.containerView)
            UIView.animate(withDuration: 0.5) {
                self.containerView.alpha = 1.0
            }
            self.copyrightLabel.isHidden = false
            self.logoImageView.isHidden = true
        })
    }
}

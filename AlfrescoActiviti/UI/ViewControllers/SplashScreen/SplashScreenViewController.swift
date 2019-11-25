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

class SplashScreenViewController: UIViewController {
    
    private static let model = AIMSSplashscreenViewModel()
    private static let isAuthSessionRestored: Bool = {
        return model.restoreLastSuccessfullSession()
    }()
    private var performedRestoreOperation = false
    
    // Logo section
    @IBOutlet weak var logoImageView: UIImageView!
    
    // Container section
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var iceEffectView: UIVisualEffectView!
    
    
    // Constraints section
    @IBOutlet weak var logoWidthConstraint: NSLayoutConstraint!
    
    // Copyright section
    @IBOutlet weak var copyrightLabel: UILabel!
    var copyrightText: String {
        get {
            let calendar = Calendar.current
            let year = calendar.component(.year, from: Date())
            return String(format: NSLocalizedString(kLocalizationLoginScreenCopyrightFormat, comment: "Copyright text"), year)
        }
    }
    
    //MARK: - View Life Cycle
    
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
        copyrightLabel.alpha = 0.0
        
        self.view.layoutIfNeeded()
        applyShadow(to: containerView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if performedRestoreOperation {
            showContainerView()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !performedRestoreOperation {
            self.logoWidthConstraint.constant = self.logoWidthConstraint.constant + 30
            UIView.animate(withDuration: kSplashScreenAnimationTime) {}
            UIView.animate(withDuration: kSplashScreenAnimationTime, animations: {
                self.view.layoutIfNeeded()
            }) { (completed) in
                if(SplashScreenViewController.isAuthSessionRestored) {
                    self.performSegue(withIdentifier: kSegueIDLoginAuthorized, sender: nil)
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: { [weak self] in
                        guard let sSelf = self else { return }
                        
                        sSelf.showContainerView()
                    })
                }
            }
            
            performedRestoreOperation = true
        }
    }
    
    //MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == kSegueIDLoginAuthorized {
            let cvc = segue.destination as! AFAContainerViewController
            cvc.transitioningDelegate = self
            cvc.viewModel = AFAContainerViewModel.init(persistenceStackModelName: SplashScreenViewController.model.persistenceStackModelName())
        }
    }
    
    //MARK: - Helpers
    
    func showContainerView() {
        self.logoImageView.isHidden = true
        containerView.alpha = 0.0
        self.view.bringSubviewToFront(self.iceEffectView)
        self.view.bringSubviewToFront(self.containerView)
        UIView.animate(withDuration: 1.5) {
            self.containerView.alpha = 1.0
            self.copyrightLabel.alpha = 1.0
        }
    }
    
    func applyShadow(to baseView: UIView) {
        baseView.layer.shadowColor = UIColor.black.cgColor
        baseView.layer.shadowOpacity = 0.4
        baseView.layer.shadowOffset = .zero
        baseView.layer.shadowRadius = 10
        baseView.layer.shadowPath = UIBezierPath(rect: baseView.bounds).cgPath
        baseView.layer.shouldRasterize = true
        baseView.layer.rasterizationScale = UIScreen.main.scale
    }
}

extension SplashScreenViewController: UIViewControllerTransitioningDelegate {
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return AFAModalDismissAnimator()
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return AFAModalDismissAnimator()
    }
}
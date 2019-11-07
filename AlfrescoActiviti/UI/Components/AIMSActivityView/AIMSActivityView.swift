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
import MaterialComponents.MaterialActivityIndicator
import MaterialComponents.MaterialActivityIndicator_ColorThemer

fileprivate let activityViewLabelTopPadding = 56

class AIMSActivityView: UIView {
    var activityIndicator = MDCActivityIndicator()
    var overlayView: UIView?
    var label: UILabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func applySemanticColorScheme(colorScheme: MDCSemanticColorScheme, typographyScheme: MDCTypographyScheme) {
        activityIndicator.cycleColors = [colorScheme.primaryColor]
        label.textColor = colorScheme.secondaryColor
        label.font = typographyScheme.subtitle2
    }
    
    private func commonInit() {
        self.isUserInteractionEnabled = false
        
        overlayView = UIView(frame: frame)
        
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        activityIndicator.sizeToFit()
        activityIndicator.radius = 40
        activityIndicator.strokeWidth = 7
        activityIndicator.center = CGPoint(x: self.center.x, y: self.center.y - self.frame.height / 7)
        
        if let overlayView = overlayView {
            overlayView.backgroundColor = .white
            overlayView.alpha = 0.87
            
            self.addSubview(overlayView)
            self.addSubview(activityIndicator)
            self.addSubview(label)
            
            activityIndicator.startAnimating()
            
            NSLayoutConstraint.activate([
                label.widthAnchor.constraint(equalToConstant: 250),
                label.heightAnchor.constraint(equalToConstant: 20),
                label.centerXAnchor.constraint(equalTo: activityIndicator.centerXAnchor),
                label.centerYAnchor.constraint(equalTo: activityIndicator.bottomAnchor, constant:CGFloat(activityViewLabelTopPadding))
            ])
        }
    }
}

//
//  NSLayoutConstraint+Rate.swift
//  AlfrescoActiviti
//
//  Created by Florin Baincescu on 21/11/2019.
//  Copyright © 2019 Emanuel Lupu-Marinei. All rights reserved.
//

import Foundation
import UIKit

extension NSLayoutConstraint {
    func scale(in view: UIView, heightNavigationBar: CGFloat = 0, rate: CGFloat = 0.2) {
        let spaceMax: CGFloat = self.constant
        let spaceMin: CGFloat = self.constant * rate
        let heightMax: CGFloat = 896.0
        let heightMin: CGFloat = 568.0
        let height = view.bounds.size.height
        let rate: CGFloat = (heightMax - heightMin) / (spaceMax - spaceMin)
        self.constant = (height - heightMin) / rate + spaceMin - heightNavigationBar
    }
}

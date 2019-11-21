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
    func rate(in view: UIView) {
        let spaceMax: CGFloat = self.constant
        let spaceMin: CGFloat = self.constant * 0.2
        let heightMax: CGFloat = 896.0
        let heightMin: CGFloat = 568.0
        let height = view.bounds.size.height
        let rate: CGFloat = (heightMax - heightMin) / (spaceMax - spaceMin)
        self.constant = (height - heightMin) / rate + spaceMin
    }
}

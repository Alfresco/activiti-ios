/*******************************************************************************
 * Copyright (C) 2005-2018 Alfresco Software Limited.
 *
 * This file is part of the Alfresco Activiti iOS App.
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

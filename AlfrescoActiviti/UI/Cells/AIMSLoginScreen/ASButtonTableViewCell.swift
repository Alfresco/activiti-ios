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
import MaterialComponents.MDCTextField

class ASButtonTableViewCell: UITableViewCell, ASCell {
    
    @IBOutlet weak var button: MDCButton!
    var delegate: ASCellsProtocol!
    var model: ASModelRow!
    var parameters: AdvancedSettingsParameters!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configureCell() {
        guard let colorSchemeManager = self.colorSchemeManager else {
            AFALog.logError("Color scheme manager could not be initiated")
            return
        }
        button.setTitle(model.title, for: .normal)
        if model.type == .save {
            if !parameters.empty() {
                button.applyContainedTheme(withScheme: colorSchemeManager.flatButtonWithBackgroundScheme)
            } else {
                button.applyContainedTheme(withScheme: colorSchemeManager.grayFlatButtonWithoutBackgroundScheme)
            }
            button.setElevation(.none, for: .normal)
            button.setElevation(.none, for: .highlighted)
            button.setTitleFont(colorSchemeManager.defaultTypographyScheme.headline4, for: .normal)
        } else if model.type == .help {
            button.applyTextTheme(withScheme: colorSchemeManager.blueFlatButtonWithoutBackgroundScheme)
        }
    }
    
    @IBAction func buttonPressed(_ sender: MDCButton) {
        if model.type == .help {
            delegate.needHelpButtonPressed()
        } else if model.type == .save {
            if !parameters.empty() {
                delegate.saveButtonPressed()
            }
        }
    }
}

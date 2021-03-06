/*******************************************************************************
 * Copyright (C) 2005-2020 Alfresco Software Limited.
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

class AIMSAdvancedSettingsButtonCell: UITableViewCell, AIMSAdvancedSettingsCellProtocol {
    
    @IBOutlet weak var button: MDCButton!
    var delegate: AIMSAdvancedSettingsCellDelegate!
    var model: AIMSAdvancedSettingsAction!
    var parameters: AIMSAuthenticationParameters!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configureCell() {
        guard let colorSchemeManager = self.colorSchemeManager else {
            AFALog.logError("Color scheme manager could not be initiated")
            return
        }
        button.setTitle(model.title, for: .normal)
        switch model.type {
        case .resetDefault:
            button.applyTextTheme(withScheme: colorSchemeManager.greenFlatButtonWithoutBackgroundScheme)
        default:
            button.applyTextTheme(withScheme: colorSchemeManager.blueFlatButtonWithoutBackgroundScheme)
        }
    }
    
    @IBAction func buttonPressed(_ sender: MDCButton) {
        delegate.buttonPressed(cell: self, type: model.type)
    }
}

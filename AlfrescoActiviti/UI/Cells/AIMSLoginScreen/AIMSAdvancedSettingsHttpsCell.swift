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

class AIMSAdvancedSettingsHttpsCell: UITableViewCell, AIMSAdvancedSettingsCellProtocol {
    
    @IBOutlet weak var httpsLabel: UILabel!
    @IBOutlet weak var httpsSwitch: UISwitch!
    
    var delegate: AIMSAdvancedSettingsCellDelegate!
    var model: AIMSAdvancedSettingsAction!
    var parameters: AIMSAdvancedSettingsParameters!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        httpsSwitch.isOn = false
    }
    
    func configureCell() {
        httpsLabel.text = model.title
        httpsSwitch.isOn = parameters.https
    }
    
    @IBAction func httpsSwitchPressed(_ sender: UISwitch) {
        parameters.https = sender.isOn
        delegate.result(cell: self, type: model.type, response: parameters)
    }
}

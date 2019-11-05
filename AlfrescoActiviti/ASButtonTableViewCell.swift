//
//  ASButtonTableViewCell.swift
//  AlfrescoActiviti
//
//  Created by Florin Baincescu on 04/11/2019.
//  Copyright © 2019 Emanuel Lupu-Marinei. All rights reserved.
//

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

//
//  ASCopyrightTableViewCell.swift
//  AlfrescoActiviti
//
//  Created by Florin Baincescu on 04/11/2019.
//  Copyright © 2019 Emanuel Lupu-Marinei. All rights reserved.
//

import Foundation
import MaterialComponents.MaterialButtons

class ASCopyrightTableViewCell: UITableViewCell, ASCell {
    
    @IBOutlet weak var label: UILabel!
    var model: ASModelRow!
    var delegate: ASCellsProtocol!
    var parameters: AdvancedSettingsParameters!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        label.text = ""
    }
    
    func configureCell() {
        guard let colorSchemeManager = self.colorSchemeManager else {
            AFALog.logError("Color scheme manager could not be initiated")
            return
        }
        label.text = model.title
        label.font = colorSchemeManager.defaultTypographyScheme.subtitle1
        label.textColor = colorSchemeManager.grayColorScheme.primaryColor
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

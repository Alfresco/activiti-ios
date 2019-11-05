//
//  ASSectionTableViewCell.swift
//  AlfrescoActiviti
//
//  Created by Florin Baincescu on 04/11/2019.
//  Copyright © 2019 Emanuel Lupu-Marinei. All rights reserved.
//

import Foundation
class ASSectionTableViewCell: UITableViewCell, ASCell {
    
    @IBOutlet weak var label: UILabel!
    var model: ASModelRow!
    var delegate: ASCellsProtocol!
    var parameters: AdvancedSettingsParameters!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        label.text = ""
    }
    
    func configureCell() {
        label.text = model.title
    }
}

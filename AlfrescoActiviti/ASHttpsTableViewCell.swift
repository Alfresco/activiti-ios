//
//  ASHttpsTableViewCell.swift
//  AlfrescoActiviti
//
//  Created by Florin Baincescu on 04/11/2019.
//  Copyright © 2019 Emanuel Lupu-Marinei. All rights reserved.
//

import Foundation

class ASHttpsTableViewCell: UITableViewCell, ASCell {
    
    @IBOutlet weak var httpsLabel: UILabel!
    @IBOutlet weak var httpsSwitch: UISwitch!
    
    var delegate: ASCellsProtocol!
    var model: ASModelRow!
    var parameters: AdvancedSettingsParameters!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        httpsSwitch.isOn = false
    }
    
    func configureCell() {
        httpsLabel.text = model.title
        httpsSwitch.isOn = parameters.https ?? false
    }
    
    @IBAction func httpsSwitchPressed(_ sender: UISwitch) {
        parameters.https = sender.isOn
        delegate.result(cell: self, type: model.type, response: parameters)
    }
}

//
//  ASCellsProtocol.swift
//  AlfrescoActiviti
//
//  Created by Florin Baincescu on 04/11/2019.
//  Copyright © 2019 Emanuel Lupu-Marinei. All rights reserved.
//

import Foundation

protocol ASCellsProtocol {
    func result(cell: UITableViewCell, type: ASRows, response: AdvancedSettingsParameters)
    func willBeginEditing(type: ASRows)
    func needHelpButtonPressed()
    func saveButtonPressed()
}

protocol ASCell: UITableViewCell {
    var delegate: ASCellsProtocol! { get set }
    var model: ASModelRow! { get set }
    var parameters: AdvancedSettingsParameters! { get set }
    func configureCell()
}

//
//  AIMSAdvanedSettings.swift
//  AlfrescoActiviti
//
//  Created by Florin Baincescu on 29/10/2019.
//  Copyright © 2019 Emanuel Lupu-Marinei. All rights reserved.
//

import UIKit

class AIMSAdvancedSettings: UIViewController {
    let helpVCIIdentifier = "AIMSHelpViewController"
    let httpsCellIdentifier = "AShttpsCell"
    let fieldCellIdentifier = "ASfieldCell"
    let buttonCellIdentifier = "ASbuttonCell"
    let copyrightCellIdentifier = "AScopyrightCell"
    let sectionCellIdentifier = "ASsectionCell"
    
    let model: AIMSAdvancedSettingsViewModel = AIMSAdvancedSettingsViewModel()
    var dataSource: [ASModelSection]!
    var parameters: AdvancedSettingsParameters!
    
    var adjustViewForKeyboard: Bool = false
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.dataSource = model.datasource()
        parameters = model.getParameters()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @IBAction func viewPressed(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    //MARK: - Keyboard Notification
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if ((notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
    }
}

extension AIMSAdvancedSettings: ASCellsProtocol {
    func willBeginEditing(type: ASRows) {
        if type == .redirectURL {
            adjustViewForKeyboard = true
        } else {
            adjustViewForKeyboard = false
        }
    }
    
    func result(cell: UITableViewCell, type: ASRows, response: AdvancedSettingsParameters) {
        switch type {
        case .https:
            parameters.https = response.https
        case .port:
            parameters.port = response.port
        case .serviceDocuments:
            parameters.serviceDocument = response.serviceDocument
        case .realm:
            parameters.realm = response.realm
        case .clientID:
            parameters.clientID = response.clientID
        case .redirectURL:
            parameters.redirectURL = response.redirectURL
        default:
            break
        }
        tableView.reloadRows(at: [model.getIndexPathForSaveButton()], with: .none)
    }
    
    func needHelpButtonPressed() {
        self.view.endEditing(true)
        let helpVC = storyboard?.instantiateViewController(withIdentifier: helpVCIIdentifier) as! AIMSHelpViewController
        helpVC.hintText = model.helpHintText
        helpVC.titleText = model.helpText
        helpVC.closeText = model.closeText
        helpVC.modalPresentationStyle = .overCurrentContext
        self.navigationController?.present(helpVC, animated: false, completion: nil)
    }
    
    func saveButtonPressed() {
        self.view.endEditing(true)
        model.saveParameters(parameters!)
        self.navigationController?.popViewController(animated: true)
    }
}
extension AIMSAdvancedSettings: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return model.datasource().count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.datasource()[section].numberOfRow
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = model.datasource()[indexPath.section].arrayRows[indexPath.row]
        var cell: ASCell
        switch item.type {
        case .clientID, .port, .realm, .redirectURL, .serviceDocuments:
            cell = tableView.dequeueReusableCell(withIdentifier: fieldCellIdentifier, for: indexPath) as! ASFieldTableViewCell
        case .save, .help:
            cell = tableView.dequeueReusableCell(withIdentifier: buttonCellIdentifier, for: indexPath) as! ASButtonTableViewCell
        case .https:
            cell = tableView.dequeueReusableCell(withIdentifier: httpsCellIdentifier, for: indexPath) as! ASHttpsTableViewCell
        case .copyright:
            cell = tableView.dequeueReusableCell(withIdentifier: copyrightCellIdentifier, for: indexPath) as! ASCopyrightTableViewCell
        case .sectionTitle:
            cell = tableView.dequeueReusableCell(withIdentifier: sectionCellIdentifier, for: indexPath) as! ASSectionTableViewCell
        }
        cell.delegate = self
        cell.parameters = self.parameters
        cell.model = item
        cell.configureCell()
        return cell
    }
}

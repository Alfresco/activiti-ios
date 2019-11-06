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

import UIKit
import MaterialComponents.MDCButton
import MaterialComponents.MDCTextField

class AIMSAdvancedSettingsViewController: UIViewController {
    let helpVCIIdentifier = "AIMSHelpViewController"
    let httpsCellIdentifier = "AShttpsCell"
    let fieldCellIdentifier = "ASfieldCell"
    let buttonCellIdentifier = "ASbuttonCell"
    let copyrightCellIdentifier = "AScopyrightCell"
    let sectionCellIdentifier = "ASsectionCell"
    
    var model: AIMSAdvancedSettingsViewModel?
    var dataSource: [ASModelSection]?
    var parameters: AdvancedSettingsParameters?
    
    var adjustViewForKeyboard: Bool = false
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.dataSource = model?.datasource()
        parameters = model?.getParameters()
        
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

extension AIMSAdvancedSettingsViewController: ASCellsProtocol {
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
            parameters?.https = response.https
        case .port:
            parameters?.port = response.port
        case .serviceDocuments:
            parameters?.serviceDocument = response.serviceDocument
        case .realm:
            parameters?.realm = response.realm
        case .clientID:
            parameters?.clientID = response.clientID
        case .redirectURL:
            parameters?.redirectURL = response.redirectURL
        default:
            break
        }
        
        if let model = self.model {
            tableView.reloadRows(at: [model.getIndexPathForSaveButton()], with: .none)
        }
    }
    
    func needHelpButtonPressed() {
        self.view.endEditing(true)
        let helpVC = storyboard?.instantiateViewController(withIdentifier: helpVCIIdentifier) as! AIMSHelpViewController
        helpVC.hintText = model?.helpHintText
        helpVC.titleText = model?.helpText
        helpVC.closeText = model?.closeText
        helpVC.modalPresentationStyle = .overCurrentContext
        self.navigationController?.present(helpVC, animated: false, completion: nil)
    }
    
    func saveButtonPressed() {
        self.view.endEditing(true)
        model?.saveParameters(parameters!)
        self.navigationController?.popViewController(animated: true)
    }
}
extension AIMSAdvancedSettingsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return model?.datasource().count ?? 0
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model?.datasource()[section].numberOfRow ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = model?.datasource()[indexPath.section].arrayRows[indexPath.row]
        var cell: ASCell
        switch item?.type {
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
        case .none:
            cell = tableView.dequeueReusableCell(withIdentifier: fieldCellIdentifier, for: indexPath) as! ASFieldTableViewCell
        }
        cell.delegate = self
        cell.parameters = self.parameters
        cell.model = item
        cell.configureCell()
        
        return cell
    }
}

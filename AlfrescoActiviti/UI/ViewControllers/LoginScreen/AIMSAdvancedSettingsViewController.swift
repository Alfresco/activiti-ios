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

class AIMSAdvancedSettingsViewController: UIViewController {
    
    var model = AIMSAdvancedSettingsViewModel()
    var dataSource: [[AIMSAdvancedSettingsAction]]?
    var parameters: AIMSAuthenticationParameters?
    
    var adjustViewForKeyboard: Bool = false
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "SAVE", style: .done, target: self, action: #selector(saveButtonPressed))
        
        self.dataSource = model.datasource()
        parameters = model.getParameters()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil) 
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (self.view.traitCollection.horizontalSizeClass == .compact) {
            tableView.tableFooterView = footerView()
        }
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
    
    //MARK: - Helpers
    
    func footerView() -> UIView {
        guard let colorSchemeManager = self.colorSchemeManager else {
            AFALog.logError("Color scheme manager could not be initiated")
            return UIView()
        }
        
        let copyrightLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: 10))
        copyrightLabel.textAlignment = .center
        copyrightLabel.text = model.copyrightText
        copyrightLabel.font = colorSchemeManager.defaultTypographyScheme.subtitle1
        copyrightLabel.textColor = colorSchemeManager.grayColorScheme.primaryColor
        
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: 15))
        footerView.backgroundColor = .clear
        footerView.addSubview(copyrightLabel)
        
        return footerView
    }
}

extension AIMSAdvancedSettingsViewController: AIMSAdvancedSettingsCellDelegate {
    
    func willBeginEditing(type: AIMSAdvancedSettingsActionTypes) {
        adjustViewForKeyboard = (type == .redirectURL)
    }
    
    func result(cell: UITableViewCell, type: AIMSAdvancedSettingsActionTypes, response: AIMSAuthenticationParameters) {
        tableView.reloadRows(at: [model.getIndexPathForSaveButton()], with: .none)
    }
    
    func needHelpButtonPressed() {
        self.view.endEditing(true)
        let helpVC = storyboard?.instantiateViewController(withIdentifier: kStoryboardIDAIMSHelpViewController) as! AIMSHelpViewController
        helpVC.hintText = model.helpHintText
        helpVC.titleText = model.helpText
        helpVC.closeText = model.closeText
        helpVC.modalPresentationStyle = .overCurrentContext
        self.navigationController?.present(helpVC, animated: false, completion: nil)
    }
    
    @objc func saveButtonPressed() {
        self.view.endEditing(true)
        model.saveParameters(parameters!)
        self.navigationController?.popViewController(animated: true)
    }
}

extension AIMSAdvancedSettingsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return model.datasource().count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.datasource()[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = model.datasource()[indexPath.section][indexPath.row]
        var cell: AIMSAdvancedSettingsCellProtocol
        
        switch item.type {
        case .clientID, .port, .realm, .redirectURL, .serviceDocuments:
            cell = tableView.dequeueReusableCell(withIdentifier: kCellIDAdvancedSettingsField, for: indexPath) as! AIMSAdvancedSettingsFieldCell
        case .help:
            cell = tableView.dequeueReusableCell(withIdentifier: kCellIDAdvancedSettingsButton, for: indexPath) as! AIMSAdvancedSettingsButtonCell
        case .https:
            cell = tableView.dequeueReusableCell(withIdentifier: kCellIDAdvancedSettingsHttps, for: indexPath) as! AIMSAdvancedSettingsHttpsCell
        case .sectionTitle:
            cell = tableView.dequeueReusableCell(withIdentifier: kCellIDAdvancedSettingsSection, for: indexPath) as! AIMSAdvancedSettingsSectionCell
        default:
            return UITableViewCell()
        }
        
        cell.delegate = self
        cell.parameters = self.parameters
        cell.model = item
        cell.configureCell()
        
        return cell
    }
}

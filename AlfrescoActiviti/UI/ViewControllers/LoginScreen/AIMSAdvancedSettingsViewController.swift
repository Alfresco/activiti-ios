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
    
    // Keyboard handling
    var positionEndTextFieldOpenedInSuperview: CGFloat = 0.0
    var positionEndTextFieldOpenedInView: CGFloat = 0.0
    var heightTextFieldOpened: CGFloat = 0.0
    
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: - View Life Cycle
    
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
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: - IBActions
    
    @IBAction func viewPressed(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    //MARK: - Keyboard Notification
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
            let window = UIApplication.shared.keyWindow {
            let superviewHeight = window.frame.size.height
            let viewHeight = view.frame.size.height
            let keyboardHeight =  keyboardFrame.cgRectValue.height
            let marginInSuperView = superviewHeight - positionEndTextFieldOpenedInSuperview
            let marginInView = viewHeight - positionEndTextFieldOpenedInView

            if self.view.frame.origin.y == 0 &&
                UIDevice.current.userInterfaceIdiom == .pad &&
                marginInSuperView < keyboardHeight {
                self.view.frame.origin.y -= (keyboardHeight - marginInSuperView)
            }
            
            if self.view.frame.origin.y == 0 &&
                UIDevice.current.userInterfaceIdiom == .phone &&
                marginInView < keyboardHeight {
                self.view.frame.origin.y -= (keyboardHeight - marginInView)
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    //MARK: - Helpers
    
    func footerView() -> UIView {
        guard let colorSchemeManager = self.colorSchemeManager else {
            AFALog.logError("Color scheme manager could not be initiated")
            return UIView()
        }
        
        let copyrightLabel = UILabel(frame: CGRect(x: 30, y: 0, width: self.view.bounds.size.width - 60, height: 15))
        copyrightLabel.textAlignment = .center
        copyrightLabel.text = model.copyrightText
        copyrightLabel.font = colorSchemeManager.defaultTypographyScheme.subtitle1
        copyrightLabel.textColor = colorSchemeManager.grayColorScheme.primaryColor
        copyrightLabel.adjustsFontSizeToFitWidth = true;
        
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: 15))
        footerView.backgroundColor = .clear
        footerView.addSubview(copyrightLabel)
        
        return footerView
    }
}

// MARK: - AIMSAdvancedSettingsCell Delegate

extension AIMSAdvancedSettingsViewController: AIMSAdvancedSettingsCellDelegate {
    
    func willBeginEditing(cell: UITableViewCell, type: AIMSAdvancedSettingsActionTypes) {
        let cellRect = tableView.rectForRow(at: tableView.indexPath(for: cell)!)
        let cellRectInTableView = self.tableView.convert(cellRect, to: tableView.superview)
        heightTextFieldOpened = cell.frame.size.height + view.safeAreaInsets.bottom
        positionEndTextFieldOpenedInView = cellRectInTableView.origin.y + heightTextFieldOpened
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            let frameInSuperview =  self.view.convert(cellRectInTableView, to: UIApplication.shared.keyWindow)
            positionEndTextFieldOpenedInSuperview = frameInSuperview.origin.y + heightTextFieldOpened
        }
    }
    
    func result(cell: UITableViewCell, type: AIMSAdvancedSettingsActionTypes, response: AIMSAuthenticationParameters) {
        if type == .https {
            self.view.endEditing(true)
            response.port = (response.https) ? String(kDefaultLoginSecuredPort) : String(kDefaultLoginUnsecuredPort)
            tableView.reloadRows(at: [model.getIndexPathForPortField()], with: .none)
        }
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

// MARK: - UITableView DataSource

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

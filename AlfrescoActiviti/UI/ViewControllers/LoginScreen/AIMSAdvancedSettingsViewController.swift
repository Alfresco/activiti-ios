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
    
    var keyboardHandling = KeyboardHandling()
    
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.navigationBar.backItem?.title = ""
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "SAVE",
                                                                 style: .done,
                                                                 target: self,
                                                                 action: #selector(saveButtonPressed))
        self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.7565980554, green: 0.7567081451, blue: 0.7565739751, alpha: 1)], for: .disabled)
        
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        
        self.title = model.screenTitleText
        self.dataSource = model.datasource()
        
        parameters = model.getParameters()
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
        let frameInSuperview =  self.view.convert(cellRectInTableView, to: UIApplication.shared.keyWindow)
        let heightTextFieldOpened = cell.frame.size.height + view.safeAreaInsets.bottom

        keyboardHandling.add(positionObjectInSuperview: frameInSuperview.origin.y + heightTextFieldOpened,
                             positionObjectInView: cellRectInTableView.origin.y + heightTextFieldOpened,
                             heightObject: heightTextFieldOpened,
                             in: self.view)
        self.navigationItem.rightBarButtonItem?.isEnabled = true
    }
    
    func result(cell: UITableViewCell, type: AIMSAdvancedSettingsActionTypes, response: AIMSAuthenticationParameters) {
        if type == .https {
            self.view.endEditing(true)
            response.port = (response.https) ? String(kDefaultLoginSecuredPort) : String(kDefaultLoginUnsecuredPort)
            tableView.reloadRows(at: [model.getIndexPathForPortField()], with: .none)
        }
        self.navigationItem.rightBarButtonItem?.isEnabled = true
    }
    
    func buttonPressed(cell: UITableViewCell, type: AIMSAdvancedSettingsActionTypes) {
        self.view.endEditing(true)
        
        if type == .help {
            let helpVC = storyboard?.instantiateViewController(withIdentifier: kStoryboardIDAIMSHelpViewController) as! AIMSHelpViewController
            helpVC.hintText = model.helpHintText
            helpVC.titleText = model.helpText
            helpVC.closeText = model.closeText
            helpVC.modalPresentationStyle = .overCurrentContext
            self.navigationController?.present(helpVC, animated: false, completion: nil)
        } else if type == .resetDefault {
            parameters = AIMSAuthenticationParameters.resetToDefault()
            tableView.reloadData()
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        }
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
        case .help, .resetDefault:
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

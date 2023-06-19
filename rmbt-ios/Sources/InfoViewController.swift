/*****************************************************************************************************
 * Copyright 2013 appscape gmbh
 * Copyright 2014-2016 SPECURE GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *****************************************************************************************************/

import Foundation
import MessageUI
import GoogleMaps
import RMBTClient

///
class InfoViewController: TopLevelTableViewController {

    ///
    private enum InfoViewControllerSection: Int {
        case links = 0
        case clientInfo = 1
        case devInfo = 2
    }

    ///
    @IBOutlet private var logoImageView: UIImageView?

    ///
    @IBOutlet private var uuidCell: UITableViewCell?

    ///
    @IBOutlet private var privacyCell: UITableViewCell?

    ///
    @IBOutlet private var uuidLabel: UILabel?

    ///
    @IBOutlet private var buildDetailsLabel: UILabel?

    ///
    @IBOutlet private var controlServerVersionLabel: UILabel?
    
    ///
    @IBOutlet weak var emailTitleLabel: UILabel!
    @IBOutlet private var emailLabel: UILabel?
    
    @IBOutlet weak var openDataSourcesLabel: UILabel?
    ///
    @IBOutlet private var siteLabel: UILabel?
    @IBOutlet weak var siteTitleLabel: UILabel!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return RMBTColorManager.statusBarStyle
    }
    //
    ///
    override func viewDidLoad() {
        super.viewDidLoad()

        if RMBT_IS_USE_DARK_MODE {
            if RMBTSettings.sharedSettings.isDarkMode {
                logoImageView?.image = UIImage(named: "logo_dark")
            } else {
                logoImageView?.image = UIImage(named: "logo_light")
            }
        } else {
            logoImageView?.image = UIImage(named: "info-logo-en")
        }

       self.openDataSourcesLabel?.text = L("info.title.open_data_sources_notice")
        
        buildDetailsLabel?.lineBreakMode = .byCharWrapping

        buildDetailsLabel?.text = RMBTVersionString()

        uuidLabel?.lineBreakMode = .byCharWrapping
        uuidLabel?.numberOfLines = 0

        controlServerVersionLabel?.text = RMBTClient.controlServerVersion

        if let uuid = RMBTClient.uuid {
            uuidLabel?.text = "U\(uuid)"
        }
        //
        emailLabel?.text = RMBT_PROJECT_EMAIL
        siteLabel?.text = RMBT_ABOUT_URL
        
        self.navigationItem.formatInfoPageTitle()
        
        if self.navigationController?.viewControllers.count ?? 0 > 1 {
            self.addStandardBackButton()
        }
        self.applyColorScheme()
        self.updateColorForNavigationBarAndTabBar()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        guard UIApplication.shared.applicationState == .inactive else {
            return
        }
        
        self.applyColorScheme()
        self.updateColorForNavigationBarAndTabBar()
        self.tableView.reloadData()
    }
    
    func applyColorScheme() {
        tableView.backgroundColor = RMBTColorManager.tableViewBackground
        tableView.separatorColor = RMBTColorManager.tableViewBackground
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func applyColorScheme(for cell: UITableViewCell) {
        cell.textLabel?.textColor = RMBTColorManager.tintColor
        cell.detailTextLabel?.textColor = RMBTColorManager.textColor
        cell.backgroundColor = RMBTColorManager.cellBackground
        cell.tintColor = RMBTColorManager.tintColor
    }

// MARK: tableView
    ///
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let section = InfoViewControllerSection(rawValue: indexPath.section)
        
        if section == .clientInfo && indexPath.row == 2 { // UUID
            return 62//uuidCell?.rmbtApproximateOptimalHeight() ?? 0
        } else if section == .links && indexPath.row == 2 { // Privacy
            return privacyCell?.rmbtApproximateOptimalHeight() ?? 0
        } else if section == .clientInfo && indexPath.row == 1 { // Version
            return 62
        } else {
            return 44
        }
    }

    ///
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = InfoViewControllerSection(rawValue: indexPath.section)
        
        if section == .links {
            switch indexPath.row {
            case 0: break //NT-1221 presentModalBrowserWithURLString(RMBT_PROJECT_URL)
            case 1:
                if MFMailComposeViewController.canSendMail() {
                    let mailVC = MFMailComposeViewController()
                    mailVC.setToRecipients([RMBT_PROJECT_EMAIL])
                    mailVC.mailComposeDelegate = self

                    mailVC.navigationBar.isTranslucent = false

                    present(mailVC, animated: true, completion: nil)
                }
            default: return
//                case 2:
//
//                    if let doc = Bundle.main.url(forResource: "terms_conditions_long", withExtension: "html") {
//                        presentModalBrowserWithURL(doc)
//                    }
//                    presentModalBrowserWithURLString(RMBT_PRIVACY_TOS_URL)
//                default: assert(false, "Invalid row")
            }
        } else if section == .devInfo {
            switch indexPath.row {
            case 0: self.presentModalBrowserWithURLString(RMBT_DEVELOPER_URL)
            //
            case 1: self.presentModalBrowserWithURLString(RMBT_REPO_URL)
            case 2: break // Do nothing
            case 3: break // Do nothing
            default: assert(false, "Invalid row")
            }
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }

    ///
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let configuration = RMBTConfigFabric.config(with: RMBTConfigurationIdentifier)
        if segue.identifier == "show_google_maps_notice" {
            if let textVC = segue.destination as? InfoTextViewController {
                textVC.text = GMSServices.openSourceLicenseInfo()
                textVC.title = L("info.google-maps.legal-notice")
            }
        }
        
        if segue.identifier == "show_terms_and_conditions" {
            if let webVC = segue.destination as? WebViewController,
                let url = URL(string: RMBTLocalizeURLString(configuration.RMBT_TERMS_TOS_URL)) {
                webVC.url = url
                webVC.onlyOpen = true
                webVC.title = String.formatStringTermAndConditions()//L("RMBT-INFO-PRIVACYPOLICY")
            }
        }
        if segue.identifier == "show_privacy_policy" {
            if let webVC = segue.destination as? WebViewController,
                let url = URL(string: RMBTLocalizeURLString(configuration.RMBT_PRIVACY_TOS_URL)) {
                webVC.url = url
                webVC.onlyOpen = true
                webVC.title = String.formatStringOnlyPrivacyAndPolicy()//L("RMBT-INFO-PRIVACYPOLICY")
            }
        }
        if segue.identifier == "show_open_data_sources_notice" {
            if let webVC = segue.destination as? WebViewController,
                let doc = Bundle.main.path(forResource: "open_data_sources", ofType: "html") {
                let url = URL(fileURLWithPath: doc)
                if let stringFormat = try? String(contentsOf: url, encoding: .utf8) {
                    let string = String(format: stringFormat, RMBT_URL_SITE_FOR_DATA_SOURCES, RMBT_TITLE_URL_SITE_FOR_DATA_SOURCES, RMBTAppTitle(), RMBT_COUNTRY_FOR_DATA_SOURCES)
                    webVC.string = string
                    webVC.title = L("info.title.open_data_sources_notice")
                }
            }
        }
        
    }

// MARK: Tableview actions (copying UUID)

    /// Show "Copy" action for cell showing client UUID
    override func tableView(_ tableView: UITableView, shouldShowMenuForRowAt indexPath: IndexPath) -> Bool {
        let section = InfoViewControllerSection(rawValue: indexPath.section)
        
        return (section == .clientInfo && indexPath.row == 0 && RMBTClient.uuid != nil)
    }

    /// As client UUID is the only cell we can perform action for, we allow "copy" here
    override func tableView(_ tableView: UITableView, canPerformAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return action == #selector(copy(_:))
    }

    ///
    override func tableView(_ tableView: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any!) {
        if action == #selector(copy(_:)) {
            // Copy UUID to pasteboard
            UIPasteboard.general.string = RMBTClient.uuid
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 2 {
            if INFO_SHOW_OPEN_DATA_SOURCES == false || RMBT_MAP_TYPE == .MapBox {
                return super.tableView(tableView, numberOfRowsInSection: section) - 2 //hide open data sources
            }
            if INFO_SHOW_OPEN_DATA_SOURCES == false {
                return super.tableView(tableView, numberOfRowsInSection: section) - 1 //hide open data sources
            }
            if RMBT_MAP_TYPE == .MapBox {
                return super.tableView(tableView, numberOfRowsInSection: section) - 1 //hide open data sources
            }
        }
        
        return super.tableView(tableView, numberOfRowsInSection: section)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 2 {
            var row = indexPath.row
            if indexPath.row > 1 && (INFO_SHOW_OPEN_DATA_SOURCES == false) {
                row += 1
            }
            let currentIndexPath = IndexPath(row: row, section: indexPath.section)
            let cell = super.tableView(tableView, cellForRowAt: currentIndexPath)
            cell.textLabel?.formatStringsInfo(cell.tag)
            self.applyColorScheme(for: cell)
            return cell
        }
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.textLabel?.formatStringsInfo(cell.tag)
        self.applyColorScheme(for: cell)
        return cell
    }
}

// MARK: MFMailComposeViewControllerDelegate

///
extension InfoViewController: MFMailComposeViewControllerDelegate {
    
    ///
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        self.dismiss(animated: true, completion: nil)
    }
}

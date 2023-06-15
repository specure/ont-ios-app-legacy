//
//  RMBTSettingsViewController.swift
//  RMBT
//
//  Created by Benjamin Pucher on 21.09.15.
//  Copyright © 2015 SPECURE GmbH. All rights reserved.
//

import Foundation
import StoreKit
import SVProgressHUD
import AdSupport
import RMBTClient
import MessageUI

///
class RMBTSettingsViewController: TopLevelTableViewController {

    enum Identifier: String {
        case darkMode = "isDarkMode"
        case ipv4Only = "nerdModeForceIPv4"
        case enableQos = "nerdModeQosEnabled"
        case language = "language"
        case publishPersonalData = "publishPublicData"
        case submitZeroTesting = "submitZeroTesting"
        case ipv6Only = "nerdModeForceIPv6"
        case inAppPurchases = "inAppPurchases"
        case enableLoopMode = "debugLoopMode"
        case maxTests = "debugLoopModeMaxTests"
        case minDelay = "debugLoopModeMinDelay"
        case isStartImmedatelly = "debugLoopModeIsStartImmedatelly"
        case distance = "debugLoopModeDistance"
        case skipQoSTests = "debugLoopModeSkipQOS"
        case enableCustomControlServer = "debugControlServerCustomizationEnabled"
        case customControlServer = "debugControlServerHostname"
        case customControlPort = "debugControlServerPort"
        case customControlSSL = "debugControlServerUseSSL"
        case enableCustomMapServer = "debugMapServerCustomizationEnabled"
        case customMapServer = "debugMapServerHostname"
        case customMapPort = "debugMapServerPort"
        case customMapSSL = "debugMapServerUseSSL"
        case enableLogging = "debugLoggingEnabled"
        
        case locationButton = "locationButton"
        case adsPersonalisation = "adsPersonalisation"
        case isClientPersistent = "isClientPersistent"
        case isAnalyticsEnabled = "isAnalyticsEnabled"
        
        case about = "about"
        case privacyPolicy = "privacyPolicy"
        case termAndConditions = "termAndConditions"
        case clientUUID = "clientUUID"
        case version = "version"
        case sendLog = "sendLog"
    }
    
    private let showPrivacyPolicySegue = "show_privacy_policy"
    private let showTermsAndConditionsSegue = "show_terms_and_conditions"
    private let showQosOptionsSegue = "showQosOptionsSegue"
    private let showAboutSegue = "showAboutSegue"
    private let showAboutWebSegue = "show_about_web_segue"
    
    var customInputView: RMBTInputView?

    var hud: SVProgressHUD?
    
    let qosOptions = [
        [L("RMBT-SETTINGS-QOSMANUALLY"): RMBTSettings.NerdModeQosMode.manually.rawValue],
        [L("RMBT-SETTINGS-QOSNETWORK"): RMBTSettings.NerdModeQosMode.newNetwork.rawValue],
        [L("RMBT-SETTINGS-QOSALWAYS"): RMBTSettings.NerdModeQosMode.always.rawValue]
    ]
    
    let languagesOptions: [[String: Any]] = [
        [L("RMBT-SETTINGS-LANGUAGE-SYSTEM-DEFAULT"): "Base"],
        ["English": "en"],
        ["Česky": "cs-CZ"],
        ["Deutsch": "de"],
        ["Español": "es"],
        ["Français": "fr"],
        ["Hrvatski": "hr"],
        ["Íslenska": "is"],
        ["日本語": "ja"],
        ["Norsk (bokmål)": "nb"],
        ["Polski": "pl"],
        ["Русский": "ru"],
        ["Slovenčina": "sk"],
        ["Slovenščina": "sl"],
        ["Српски": "sr"],
        ["Srpski": "sr-Latn"],
        ["Svenska": "sv"],
        ["中文": "zh-Hans"]
    ]

    override var preferredStatusBarStyle: UIStatusBarStyle { return RMBTColorManager.statusBarStyle }
    var sections: [RMBTSettingsSection] = []
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.tabBarItem.title = L("tabbar.title.settings")
        self.tabBarItem.image = UIImage(named: "ic_settings_25pt")
        self.navigationController?.tabBarItem = self.tabBarItem
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        guard UIApplication.shared.applicationState == .inactive else {
            return
        }
        
        self.applyColorScheme()
        self.updateColorForNavigationBarAndTabBar()
    }
    ///
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(reloadData(_:)), name: UIApplication.willEnterForegroundNotification, object: nil)
        
        self.applyColorScheme()
        self.updateColorForNavigationBarAndTabBar()
        StoreKitHelper.sharedManager.delegate = self
    
        //
        self.navigationItem.title?.formatStringSettings()

        let configuration = RMBTConfigFabric.config(with: RMBTConfigurationIdentifier)
        if configuration.RMBT_VERSION == 3 {
            self.navigationItem.leftBarButtonItem = nil
        }
        self.customInputView = RMBTInputView.view()
        self.customInputView?.doneButton.addTarget(self, action: #selector(textFieldDoneButtonClick(_ :)), for: .touchUpInside)
        self.prepareSections()
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapHandler(_:)))
        tapGestureRecognizer.numberOfTapsRequired = 10
        self.navigationController?.navigationBar.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func sendLogFile() {
        if !MFMailComposeViewController.canSendMail() {
            print("Mail services are not available")
            return
        }
        
        let composeVC = MFMailComposeViewController()
        composeVC.mailComposeDelegate = self
        // Configure the fields of the interface.
        composeVC.setToRecipients([])
        composeVC.setSubject("Logs!")
        composeVC.setMessageBody("Log", isHTML: false)
        
        let contents = try? FileManager.default.contentsOfDirectory(atPath: LogConfig.getLogFolderPath()).filter({ (string) -> Bool in
            return string.hasSuffix(".log")
        })
        for file in contents ?? [] {
            let url = URL(fileURLWithPath: LogConfig.getLogFolderPath())
            if let data = try? Data(contentsOf: url.appendingPathComponent(file, isDirectory: false)) {
                composeVC.addAttachmentData(data, mimeType: "text", fileName: file)
            }
        }
        // Present the view controller modally.
        self.present(composeVC, animated: true, completion: nil)
    }

    @objc func tapHandler(_ sender: UIGestureRecognizer) {
        _ = UIAlertController.presentAlertDevCode(nil, codeAction: { (textField) in
            if textField.text == DEV_CODE {
                RMBTSettings.sharedSettings.isDevModeEnabled = true
                self.prepareSections()
                self.tableView.reloadData()
            }
        }, textFieldConfiguration: nil)
    }
    
    func applyColorScheme() {
        self.view.backgroundColor = RMBTColorManager.tableViewBackground
        
        self.tableView.separatorColor = RMBTColorManager.tableViewSeparator
        self.tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        self.tableView.reloadData()

        (UIApplication.shared.delegate as? RMBTAppDelegate)?.applyAppearance()
        
        self.customInputView?.applyColorScheme()
    }
    
    ///
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.applyColorScheme()
        self.updateColorForNavigationBarAndTabBar()
        self.prepareSections()
        tableView.reloadData()
    }

    /// !!!
    override func viewWillDisappear(_ animated: Bool) {
       // ControlServer.sharedControlServer.updateWithCurrentSettings()
    }
    
    @objc func reloadData(_ sender: Any) {
        self.tableView.reloadData()
    }
    
    @objc func textFieldDoneButtonClick(_ sender: Any) {
        self.view.endEditing(true)
    }
    
    @IBAction func removeAdsButtonClick(_ sender: Any) {
        if RMBTSettings.sharedSettings.isAdsRemoved == true {
            let error = NSError(domain: "localhost", code: -1, userInfo: [NSLocalizedDescriptionKey: "You already have removed ads"])
            _ = UIAlertController.presentErrorAlert(error, dismissAction: { (_) in
            })
            return
        }
        SVProgressHUD.show()
        StoreKitHelper.sharedManager.buyProduct(identifier: StoreKitHelper.PurchaseIdentifier.RemoveAds, object: nil) { (_, _, error) in
            SVProgressHUD.dismiss()
            if let error = error {
                _ = UIAlertController.presentErrorAlert(error, dismissAction: { (_) in
                })
            }
        }
    }
    
    @IBAction func restoreButtonClick(_ sender: Any) {
        SVProgressHUD.show()
        StoreKitHelper.sharedManager.restoreAllProducts()
    }
    // MARK: Table view

    func prepareSections() {
        self.sections = []
        
        let configuration = RMBTConfigFabric.config(with: RMBTConfigurationIdentifier)
        if configuration.RMBT_VERSION == 3 {
            let aboutSection = RMBTSettingsSection()
            aboutSection.title = NSLocalizedString("RMBT-SETTINGS-INFORMATION", comment: "Information")
            self.sections.append(aboutSection)
            
            let about = RMBTSettingsItem()
            about.mode = .disclosureIndicator
            about.value = nil
            let format = NSLocalizedString("RMBT-SETTINGS-ABOUT", comment: "About NettestX")
            about.title = String(format: format, configuration.appName)
            about.identifier = .about
            
            aboutSection.items.append(about)
            
            let privacy = RMBTSettingsItem()
            privacy.mode = .disclosureIndicator
            privacy.value = nil
            privacy.title = NSLocalizedString("RMBT-INFO-PRIVACYPOLICY", comment: "Privacy Policy")
            privacy.identifier = .privacyPolicy
            
            aboutSection.items.append(privacy)
            
            let terms = RMBTSettingsItem()
            terms.mode = .disclosureIndicator
            terms.value = nil
            terms.title = NSLocalizedString("RMBT-INFO-TERMS-AND-CONDITIONS", comment: "Term of Service Policy")
            terms.identifier = .termAndConditions
            aboutSection.items.append(terms)
            
            let clientUUID = RMBTSettingsItem()
            clientUUID.mode = .button
            if let uuid = RMBTClient.uuid {
                clientUUID.value = "U\(uuid)"
                clientUUID.subtitle = "U\(uuid)"
            }
            clientUUID.title = NSLocalizedString("RMBT-INFO-CLINETUUID", comment: "Client UUID")
            clientUUID.identifier = .clientUUID
            aboutSection.items.append(clientUUID)
            
            let version = RMBTSettingsItem()
            version.mode = .subtitle
            version.value = RMBTVersionString()
            version.title = NSLocalizedString("RMBT-INFO-VERSION", comment: "Version")
            version.identifier = .version
            aboutSection.items.append(version)
        }
        
        let generalSection = RMBTSettingsSection()
        generalSection.title = NSLocalizedString("RMBT-SETTINGS-GENERAL", comment: "General")
        self.sections.append(generalSection)
        
        if #available(iOS 13.0, *) {
        } else {
            if RMBT_IS_USE_DARK_MODE {
                let colorMode = RMBTSettingsItem()
                colorMode.title = NSLocalizedString("RMBT-SETTINGS-DARKMODE", comment: "Dark Mode")
                colorMode.value = RMBTSettings.sharedSettings.isDarkMode
                colorMode.identifier = .darkMode
                generalSection.items.append(colorMode)
            }
        }
        
        let ipv4Only = RMBTSettingsItem()
        ipv4Only.title = NSLocalizedString("RMBT-SETTINGS-IPV4ONLY", comment: "IPv4 Only")
        ipv4Only.value = RMBTSettings.sharedSettings.nerdModeForceIPv4
        ipv4Only.identifier = .ipv4Only
        generalSection.items.append(ipv4Only)
        
//        let language = RMBTSettingsItem()
//        language.title = NSLocalizedString("RMBT-SETTINGS-LANGUAGE", comment: "Language")
//        language.value = self.selectedLanguageOption()
//        language.mode = .options
//        language.identifier = .language
//        generalSection.items.append(language)
        
        let enableQos = RMBTSettingsItem()
        enableQos.title = NSLocalizedString("RMBT-SETTINGS-ENABLEQOSMEASUMENTS", comment: "Enable QoS")
        enableQos.value = self.selectedQosOption()
        enableQos.mode = .options
        enableQos.identifier = .enableQos
        generalSection.items.append(enableQos)
        
        if TEST_USE_PERSONAL_DATA_FUZZING {
            let publishPersonalData = RMBTSettingsItem()
            publishPersonalData.title = NSLocalizedString("RMBT-SETTINGS-ENABLEPUBLISHPERSONALDATA", comment: "Publish Personal Data")
            publishPersonalData.value = RMBTSettings.sharedSettings.publishPublicData
            publishPersonalData.identifier = .publishPersonalData
            generalSection.items.append(publishPersonalData)
        }
        if TEST_STORE_ZERO_MEASUREMENT {
            let storeZeroMeasurement = RMBTSettingsItem()
            storeZeroMeasurement.title = NSLocalizedString("RMBT-SETTINGS-ENABLESUBMITZEROTESTING", comment: "Submit Zero testing")
            storeZeroMeasurement.value = RMBTSettings.sharedSettings.submitZeroTesting
            storeZeroMeasurement.identifier = .submitZeroTesting
            generalSection.items.append(storeZeroMeasurement)
        }
        if TEST_IPV6_ONLY {
            let ipv6Only = RMBTSettingsItem()
            ipv6Only.title = NSLocalizedString("RMBT-SETTINGS-IPV6ONLY", comment: "IPv6 Only")
            ipv6Only.value = RMBTSettings.sharedSettings.nerdModeForceIPv6
            ipv6Only.identifier = .ipv6Only
            generalSection.items.append(ipv6Only)
        }
        
        if (IS_SHOW_ADVERTISING) && (RMBTClient.advertisingIsActive) {
            let inappPurchasesSection = RMBTSettingsSection()
            inappPurchasesSection.title = NSLocalizedString("In-App Purchases", comment: "In-App Purchases")
            self.sections.append(inappPurchasesSection)
            let inappPurchasesItem = RMBTSettingsItem()
            inappPurchasesItem.mode = .purchases
            inappPurchasesItem.identifier = .inAppPurchases
            inappPurchasesSection.items.append(inappPurchasesItem)
        }
    
        if RMBT_TEST_LOOPMODE_ENABLE {
            let loopModeSection = RMBTSettingsSection()
            loopModeSection.title = NSLocalizedString("RMBT-DEVSETTINGS-LOOPMODE", comment: "Loop mode")
            loopModeSection.isExpanded = RMBTSettings.sharedSettings.debugLoopMode
            let loopMode = RMBTSettingsItem()
            loopMode.title = NSLocalizedString("RMBT-DEVSETTINGS-LOOPMODE", comment: "Loop mode")
            loopMode.value = RMBTSettings.sharedSettings.debugLoopMode
            loopMode.identifier = .enableLoopMode
            loopModeSection.items.append(loopMode)
            
            let maxTests = RMBTSettingsItem()
            maxTests.title = NSLocalizedString("RMBT-DEVSETTINGS-MAXTESTS", comment: "Test count")
            maxTests.value = RMBTSettings.sharedSettings.debugLoopModeMaxTests
            maxTests.mode = .numberTextField
            maxTests.placeholder = "100"
            maxTests.identifier = .maxTests
            loopModeSection.items.append(maxTests)
            
            let switchLimits = RMBTSettingsItem()
            switchLimits.title = L("settings.start_next_test_immediatelly")
            switchLimits.value = RMBTSettings.sharedSettings.debugLoopModeIsStartImmedatelly
            switchLimits.mode = .switcher
            switchLimits.identifier = .isStartImmedatelly
            loopModeSection.items.append(switchLimits)
            
            if RMBTSettings.sharedSettings.debugLoopModeIsStartImmedatelly == false {
                let minDelay = RMBTSettingsItem()
                minDelay.title = NSLocalizedString("RMBT-DEVSETTINGS-MINDELAY", comment: "Interval (mins)")
                minDelay.value = RMBTSettings.sharedSettings.debugLoopModeMinDelay
                minDelay.mode = .numberTextField
                minDelay.placeholder = "5"
                minDelay.identifier = .minDelay
                loopModeSection.items.append(minDelay)
                
                let distance = RMBTSettingsItem()
                distance.title = NSLocalizedString("RMBT-DEVSETTINGS-DISTANCE", comment: "Interval (mins)")
                distance.value = RMBTSettings.sharedSettings.debugLoopModeDistance
                distance.mode = .numberTextField
                distance.placeholder = "10"
                distance.identifier = .distance
                loopModeSection.items.append(distance)
            }
            
            let skipQos = RMBTSettingsItem()
            skipQos.title = NSLocalizedString("RMBT-DEVSETTINGS-SKIPQOSTESTS", comment: "Skip QoS tests")
            skipQos.value = RMBTSettings.sharedSettings.debugLoopModeSkipQOS
            skipQos.identifier = .skipQoSTests
            loopModeSection.items.append(skipQos)
            
            self.sections.append(loopModeSection)
        }
        
        if RMBT_SHOW_PRIVACY_IN_SETTINGS {
            let privacySection = RMBTSettingsSection()
            privacySection.title = L("RMBT-SETTINGS-PRIVACY")
            let location = RMBTSettingsItem()
            location.title = L("RMBT-SETTINGS-LOCATION")
            location.subtitle = L("RMBT-SETTINGS-LOCATION-DESCRIPTION")
            location.identifier = .locationButton
            location.mode = .switcher
            privacySection.items.append(location)
            
            let adsPersonalisation = RMBTSettingsItem()
            adsPersonalisation.title = L("RMBT-SETTINGS-ADS-PERSONALISATION")
            adsPersonalisation.subtitle = L("RMBT-SETTINGS-ADS-PERSONALISATION-DESCRIPTION")
            adsPersonalisation.identifier = .adsPersonalisation
            adsPersonalisation.mode = .switcher
            privacySection.items.append(adsPersonalisation)
            
            let persistendUUID = RMBTSettingsItem()
            persistendUUID.title = L("RMBT-SETTINGS-PERSISTENT-UUID")
            persistendUUID.subtitle = L("RMBT-SETTINGS-PERSISTENT-UUID-DESCRIPTION")
            persistendUUID.identifier = .isClientPersistent
            persistendUUID.mode = .switcher
            privacySection.items.append(persistendUUID)
            
            let analytics = RMBTSettingsItem()
            analytics.title = L("RMBT-SETTINGS-CRASH-ANALYTICS")
            analytics.subtitle = L("RMBT-SETTINGS-CRASH-ANALYTICS-DESCRIPTION")
            analytics.identifier = .isAnalyticsEnabled
            analytics.mode = .switcher
            privacySection.items.append(analytics)
            
            self.sections.append(privacySection)
        }
        
        if RMBTSettings.sharedSettings.isDevModeEnabled {
            let devSection = RMBTSettingsSection()
            devSection.title = L("RMBT-SETTINGS-DEV")
            let sendLog = RMBTSettingsItem()
            sendLog.title = L("RMBT-SETTINGS-SEND-LOG")
            sendLog.identifier = .sendLog
            sendLog.mode = .button
            devSection.items.append(sendLog)
            
            self.sections.append(devSection)
        }
    }
    
    func valueForIdentifier(_ identifier: RMBTSettingsViewController.Identifier) -> Any? {
        for section in sections {
            if let item = section.items.first(where: { (item) -> Bool in
                return item.identifier == identifier
            }) {
                return item
            }
        }
        
        return nil
    }
    ///
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.sections.count

//        if RMBTSettings.sharedSettings.debugUnlocked {
//            section = 5
//        }
//        return section
    }
    ///
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section < self.sections.count {
            let currentSection = self.sections[section]
            if currentSection.isExpanded {
                return currentSection.items.count
            } else {
                return 1
            }
        } else {
            return super.tableView(tableView, numberOfRowsInSection: section)
        }

        //        } else if section == 3 && !RMBTSettings.sharedSettings.debugControlServerCustomizationEnabled {
//            // If control server customization is disabled, hide hostname/port/ssl cells
//            return 1
//        } else if section == 4 && !RMBTSettings.sharedSettings.debugMapServerCustomizationEnabled {
//            return 1
//        } else {
//            return super.tableView(tableView, numberOfRowsInSection: section)
//        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var title: String?
        if section < self.sections.count {
            let currentSection = self.sections[section]
            title = currentSection.title
        } else {
            title =  UITableViewHeaderFooterView.formatNMSettingsHeader(section).textLabel?.text
        }
        let header = RMBTSettingsTableViewHeader.view()
        header?.titleLabel.text = title
        header?.applyColorScheme()
        return header
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section < self.sections.count {
            let section = self.sections[indexPath.section]
            let item = section.items[indexPath.row]
            if let text = item.subtitle {
                let width = UIScreen.main.bounds.size.width - 30
                let font = UIFont.systemFont(ofSize: 12, weight: .regular)
                let height = text.height(withConstrainedWidth: width, font: font)
                return height + (11.5 + 11.5) + 21 + 5
            }
        }
        
        return super.tableView(tableView, heightForRowAt: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section < self.sections.count {
            let section = self.sections[indexPath.section]
            let item = section.items[indexPath.row]
            switch item.mode {
            case .button:
                let cell = tableView.dequeueReusableCell(withIdentifier: "ButtonCell", for: indexPath) as! RMBTButtonCell
                cell.titleLabel.text = item.title
                cell.valueLabel.text = item.value as? String
                cell.accessoryType = .none
                cell.applyColorScheme()
                return cell
            case .disclosureIndicator:
                let cell = tableView.dequeueReusableCell(withIdentifier: "AboutCell", for: indexPath) as! RMBTAboutCell
                cell.titleLabel.text = item.title
                cell.accessoryType = .disclosureIndicator
                cell.applyColorScheme()
                return cell
            case .subtitle:
                let cell = tableView.dequeueReusableCell(withIdentifier: "SubtitleCell", for: indexPath) as! RMBTOptionsCell
                cell.titleLabel.text = item.title
                cell.valueLabel.text = item.value as? String
                cell.accessoryType = .none
                cell.applyColorScheme()
                return cell
            case .switcher:
                let cell = tableView.dequeueReusableCell(withIdentifier: "SwitcherCell", for: indexPath) as! RMBTSwitcherCell
                cell.titleLabel.text = item.title
                cell.subtitleLabel.text = item.subtitle
                cell.valueSwitch.isOn = (item.value as? Bool) ?? false
                cell.valueSwitch.isEnabled = true

                cell.applyColorScheme()
                
                if item.identifier == .locationButton {
                    cell.valueSwitch.isEnabled = false
                    cell.valueSwitch.isOn = RMBTLocationTracker.sharedTracker.isLocationManagerEnabled()
                    return cell
                }
                if item.identifier == .adsPersonalisation {
                    cell.valueSwitch.isEnabled = false
                    cell.valueSwitch.isOn = !ASIdentifierManager.shared().isAdvertisingTrackingEnabled
                    return cell
                }
                bindSwitch(cell.valueSwitch, toSettingsKeyPath: item.identifier.rawValue) { [weak self] (value) in
                    let settings = RMBTSettings.sharedSettings
                    if item.identifier == .publishPersonalData {
                        if value && TEST_USE_PERSONAL_DATA_FUZZING {
                            //                     if is set to on -> show terms and conditions again
                            settings.publishPublicData = false
                            self?.performSegue(withIdentifier: "show_tos_from_settings", sender: self)
                        }
                    }
                    if item.identifier == .isAnalyticsEnabled {
                        
                    }
                    if item.identifier == .enableLoopMode {
                        if value == true {
                            if let vc = UIStoryboard.loopModeAlert() {
                                self?.present(vc, animated: true, completion: nil)
                            }
                        }
                    }
                    if item.identifier == .submitZeroTesting {
                        let ipv6Value = self?.valueForIdentifier(.ipv6Only) as? Bool ?? false
                        if value && (ipv6Value == true) {
                            settings.submitZeroTesting = false
                        }
                    }
                    if item.identifier == .darkMode {
                        self?.applyColorScheme()
                        self?.updateColorForNavigationBarAndTabBar()
                    }
                    if item.identifier == .ipv4Only {
                        let ipv6Value = self?.valueForIdentifier(.ipv6Only) as? Bool ?? false
                        if value && (ipv6Value == true) {
                            settings.nerdModeForceIPv6 = false
                        }
                    }
                    if item.identifier == .ipv6Only {
                        let ipv4Value = self?.valueForIdentifier(.ipv4Only) as? Bool ?? false
                        if value && (ipv4Value == true) {
                            settings.nerdModeForceIPv4 = false
                        }
                    }
                    if item.identifier == .isStartImmedatelly {
                        settings.debugLoopModeIsStartImmedatelly = value
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
                        RMBTConfig.updateSettings(success: {
                            
                        }, error: { error in
                            
                        })
                        self?.prepareSections()
                        self?.tableView.reloadData()
                    })
                }
                return cell
            case .textField:
                let cell = tableView.dequeueReusableCell(withIdentifier: "TextFieldCell", for: indexPath) as! RMBTTextfieldCell
                cell.titleLabel.text = item.title
                cell.valueTextField.text = item.value as? String
                cell.valueTextField.placeholder = item.placeholder
                cell.valueTextField.inputAccessoryView = nil
                
                cell.applyColorScheme()
                
                bindTextField(cell.valueTextField, toSettingsKeyPath: item.identifier.rawValue, numeric: false)
                return cell
            case .numberTextField:
                let cell = tableView.dequeueReusableCell(withIdentifier: "TextFieldCell", for: indexPath) as! RMBTTextfieldCell
                cell.titleLabel.text = item.title
                cell.valueTextField.text = item.value as? String
                cell.valueTextField.placeholder = item.placeholder
                cell.valueTextField.inputAccessoryView = self.customInputView
                
                cell.applyColorScheme()
                
                bindTextField(cell.valueTextField, toSettingsKeyPath: item.identifier.rawValue, numeric: true, onToggle: { [weak self] (_, value) in
                    if item.identifier == .minDelay,
                        let mins = value as? NSNumber,
                        mins.intValue < 5 {
                        let settings = RMBTSettings.sharedSettings
                        settings.debugLoopModeMinDelay = 5
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
                            self?.prepareSections()
                            self?.tableView.reloadData()
                        })
                    }
                })
                return cell
            case .options:
                let cell = tableView.dequeueReusableCell(withIdentifier: "OptionsCell", for: indexPath) as! RMBTOptionsCell
                cell.titleLabel.text = item.title
                cell.valueLabel.text = item.value as? String
                cell.applyColorScheme()
                return cell
            case .purchases:
                let cell = tableView.dequeueReusableCell(withIdentifier: "InAppPurchasesCell", for: indexPath) as! RMBTInAppPurchasesCell
                cell.restoreButton.layer.borderColor = RMBT_RESULT_TEXT_COLOR.cgColor
                cell.restoreButton.layer.cornerRadius = cell.restoreButton.bounds.size.height / 2
                cell.restoreButton.layer.borderWidth = 1
                cell.restoreButton.setTitleColor(RMBT_RESULT_TEXT_COLOR, for: .normal)
                
                cell.removeAdsButton.layer.borderColor = RMBT_RESULT_TEXT_COLOR.cgColor
                cell.removeAdsButton.layer.cornerRadius = cell.restoreButton.bounds.size.height / 2
                cell.removeAdsButton.layer.borderWidth = 1
                cell.removeAdsButton.setTitleColor(RMBT_RESULT_TEXT_COLOR, for: .normal)
                cell.removeAdsButton.isEnabled = !RMBTSettings.sharedSettings.isAdsRemoved
                
                cell.applyColorScheme()
                
                return cell
            }
        } else {
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section < self.sections.count {
            let section = self.sections[indexPath.section]
            let item = section.items[indexPath.row]
            
            if item.identifier == .about {
                self.performSegue(withIdentifier: showAboutWebSegue, sender: self)
            }
            if item.identifier == .privacyPolicy {
                self.performSegue(withIdentifier: showPrivacyPolicySegue, sender: self)
            }
            if item.identifier == .termAndConditions {
                self.performSegue(withIdentifier: showTermsAndConditionsSegue, sender: self)
            }
            if item.identifier == .locationButton {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(URL(string: UIApplication.openSettingsURLString)!)
                }
            }
            if item.identifier == .adsPersonalisation {
                let title = L("RMBT-SETTINGS-ADS-PERSONALISATION-POPUP-TITLE")
                let msg = L("RMBT-SETTINGS-ADS-PERSONALISATION-POPUP-TEXT")
                _ = UIAlertController.presentAlert(title, msg) { (_) in }
            }
            if item.identifier == .sendLog {
                self.sendLogFile()
            }
            tableView.deselectRow(at: indexPath, animated: true)
            return
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }

// MARK: Textfield delegate

    ///
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

// MARK: SWRevealViewControllerDelegate

    ///
    override func revealControllerPanGestureBegan(_ revealController: SWRevealViewController!) {
        self.tableView.isScrollEnabled = false
    }

    ///
    override func revealController(_ revealController: SWRevealViewController!, didMoveTo position: FrontViewPosition) {
        self.tableView.isScrollEnabled = position == .left
    }

    ///
    func revealController(revealController: SWRevealViewController!, didMoveToPosition position: FrontViewPosition) {
        let posLeft = (position == .left)

        tableView.isScrollEnabled = posLeft
        tableView.allowsSelection = posLeft
    }
    
//    func selectedLanguageOption() -> String {
//        var currentValue = Locale.userPreferred.languageCode ?? Locale.userPreferred.identifier
//        if LocaleManager.isUseSystemLanguage {
//            currentValue = "Base"
//        }
//        for language in self.languagesOptions {
//            if let value = language.values.first as? String,
//                currentValue == value {
//                return language.keys.first ?? ""
//            }
//        }
//        return ""
//    }
    
    func selectedQosOption() -> String {
        var currentValue = RMBTSettings.sharedSettings.value(forKey: "nerdModeQosEnabled")
        if currentValue == nil {
            currentValue = 1
            RMBTSettings.sharedSettings.setValue(currentValue, forKey: "nerdModeQosEnabled")
        }
        if let currentValue = RMBTSettings.sharedSettings.value(forKey: "nerdModeQosEnabled") as? Int {
            for option in qosOptions {
                if let value = option.values.first,
                    currentValue == value {
                    return option.keys.first ?? ""
                }
            }
        }
        return ""
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let configuration = RMBTConfigFabric.config(with: RMBTConfigurationIdentifier)
        if segue.identifier == showTermsAndConditionsSegue {
            if let webVC = segue.destination as? RMBTStaticPageViewController {
                webVC.route = configuration.RMBT_CMS_TERMS_URL
            }
        }
        if segue.identifier == showPrivacyPolicySegue {
            if let webVC = segue.destination as? RMBTStaticPageViewController {
                webVC.route = configuration.RMBT_CMS_PRIVACY_URL
            }
        }
        if segue.identifier == showAboutWebSegue {
            if let webVC = segue.destination as? RMBTStaticPageViewController {
                webVC.route = configuration.RMBT_CMS_ABOUT_URL
            }
        }
        if segue.identifier == showQosOptionsSegue,
            let vc = segue.destination as? RMBTSelectListItemsViewController {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let section = self.sections[indexPath.section]
                let item = section.items[indexPath.row]
//                if item.identifier == .language {
//                    vc.title = L("RMBT-SETTINGS-LANGUAGE")
//                    vc.items = self.languagesOptions
//                    if LocaleManager.isUseSystemLanguage {
//                        vc.selectedItem = "Base"
//                    } else {
//                        vc.selectedItem = Locale.userPreferred.languageCode ?? Locale.userPreferred.identifier
//                    }
//
//                    vc.onDidSelectHandler = { [weak self] value in
//                        if let value = value as? String,
//                            value != "Base" {
//                            LocaleManager.apply(identifier: value)
//                        } else {
//                            LocaleManager.apply(identifier: nil)
////                            let identifier = PREFFERED_LANGUAGE
////                            LocaleManager.apply(identifier: identifier)
//                        }
//                        self?.prepareSections()
//                        self?.tableView.reloadData()
//                    }
//                } else
                if item.identifier == .enableQos {
                    vc.title = L("RMBT-SETTINGS-ENABLEQOSMEASUMENTS")
                    vc.items = qosOptions
                    let currentValue = RMBTSettings.sharedSettings.value(forKey: "nerdModeQosEnabled")
                    vc.selectedItem = currentValue as? NSObject
                    vc.onDidSelectHandler = { [weak self] value in
                        if let currentValue = value as? Int {
                            RMBTSettings.sharedSettings.setValue(NSNumber(value: currentValue), forKey: "nerdModeQosEnabled")
                            self?.prepareSections()
                            self?.tableView.reloadData()
                        }
                    }
                }
            }
            
        }
    }
}

extension RMBTSettingsViewController: StoreKitHelperDelegate {
    func cancelTransaction(_ identifier: String, error: NSError) {
        SVProgressHUD.dismiss()
        print("canceled")
        _ = UIAlertController.presentErrorAlert(error) { (_) in
            
        }
    }
    
    func failedTransaction(_ identifier: String, error: NSError) {
        SVProgressHUD.dismiss()
        print("failed")
        let result = StoreKitHelper.sharedManager.price(for: identifier)
        AnalyticsHelper.logPurchase(withPrice: result.price?.doubleValue, currency: result.currency, success: false, itemName: "Remove Ads", itemType: nil, itemId: identifier)
        AnalyticsHelper.logCustomEvent(withName: "settings.remove_ads", attributes: ["status": "FAILURE"])
        let title = L("general.alertview.error")
        let text = L("RMBT-SETTINGS-PURCHASE-FAILED")
        _ = UIAlertController.presentAlert(title, text) { (_) in
            
        }
    }
    
    func restoreTransaction(_ identifier: String) {
        SVProgressHUD.dismiss()
        
        if identifier == StoreKitHelper.PurchaseIdentifier.RemoveAds.rawValue {
            RMBTSettings.sharedSettings.isAdsRemoved = true
            AnalyticsHelper.logCustomEvent(withName: "settings.restore_purchases", attributes: ["status": "SUCCESS"])
        }

        _ = UIAlertController.presentAlert("We restored all purchases") { (_) in
            
        }
        print("restore")
    }
    
    func completeTransaction(_ identifier: String, response: NSDictionary?) {
        if identifier == StoreKitHelper.PurchaseIdentifier.RemoveAds.rawValue {
            RMBTSettings.sharedSettings.isAdsRemoved = true
            
            let result = StoreKitHelper.sharedManager.price(for: identifier)
            AnalyticsHelper.logPurchase(withPrice: result.price?.doubleValue, currency: result.currency, success: true, itemName: "Remove Ads", itemType: nil, itemId: identifier)
            AnalyticsHelper.logCustomEvent(withName: "settings.remove_ads", attributes: ["status": "SUCCESS"])
            
            let title = L("general.alertview.confirmation")
            let text = L("RMBT-SETTINGS-PURCHASE-COMPLETED")
            _ = UIAlertController.presentAlert(title, text) { (_) in
                
            }
        }
        SVProgressHUD.dismiss()
        
    }
    
    func productsDidLoad(_ products: [SKProduct]?) {
        print("productsDidLoad")
    }
}

extension RMBTSettingsViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        if result == .sent {
            let fileName = LogConfig.getCurrentLogFileName()
            let contents = try? FileManager.default.contentsOfDirectory(atPath: LogConfig.getLogFolderPath()).filter({ (string) -> Bool in
                return string.hasSuffix(".log") && string != fileName
            })
            for file in contents ?? [] {
                let url = URL(fileURLWithPath: LogConfig.getLogFolderPath())
                let path = url.appendingPathComponent(file, isDirectory: false)
                try? FileManager.default.removeItem(at: path)
            }
        }
        controller.dismiss(animated: true, completion: nil)
    }
}

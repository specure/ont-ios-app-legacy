//
//  RMBTHistoryResultViewController.swift
//  RMBT
//
//  Created by Benjamin Pucher on 23.09.14.
//  Copyright © 2014 SPECURE GmbH. All rights reserved.
//

import Foundation
import CoreLocation
import TUSafariActivity

///
class RMBTHistoryResultViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    ///
    @IBOutlet var tableView: UITableView!

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return RMBTColorManager.statusBarStyle
    }
    
    ///
    var historyResult: RMBTHistoryResult? {
        didSet {
            if self.isViewLoaded {
                self.reloadData()
            }
        }
    }

    ///
    var isModal = false

    ///
    var showMapOption = false

    ///
    var qosResults: QosMeasurementResultResponse?

    ///
    var statusMessage: String!

    //

    @IBAction func share(_ sender: Any) {
        var activities = [UIActivity]()
        var items = [AnyObject]()

        if let shareText = historyResult?.shareText {
            items.append(shareText as AnyObject)
        }

        if let shareURL = historyResult?.shareURL {
            items.append(shareURL as AnyObject)
            activities.append(TUSafariActivity())
        }

        let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: activities)
        activityViewController.setValue(RMBTAppTitle(), forKey: "subject")

        if let popover = activityViewController.popoverPresentationController {
            if let shareView = sender as? UIView {
                popover.sourceView = shareView
                popover.sourceRect = shareView.bounds
            } else if let shareView = sender as? UIBarButtonItem {
                popover.barButtonItem = shareView
            }
        }
        present(activityViewController, animated: true, completion: nil)
    }

// MARK: - Object Life Cycle

    ///
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.formatHistoryResultPageTitle()
        self.reloadData()
        
        self.applyColorScheme()
        self.updateColorForNavigationBarAndTabBar()
        
        if UIDevice.isDeviceTablet() {
            self.addStandardBackButton()
        }
    }
    
    func reloadData() {
        if let historyResult = self.historyResult {
            let uuid = historyResult.uuid
            historyResult.ensureBasicDetails {
                assert(historyResult.dataState != .index, "Result not filled with basic data")
                if CLLocationCoordinate2DIsValid(historyResult.coordinate) {
                    self.showMapOption = true
                }
                self.tableView.reloadData()
                self.reloadQOSHistory(for: uuid)
            }
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        guard UIApplication.shared.applicationState == .inactive else {
            return
        }
        
        self.applyColorScheme()
        self.updateColorForNavigationBarAndTabBar()
    }
    
    func applyColorScheme() {
        self.view.backgroundColor = RMBTColorManager.background
        self.tableView.backgroundColor = RMBTColorManager.tableViewBackground
        self.tableView.separatorColor = RMBTColorManager.tableViewSeparator
        self.tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func reloadQOSHistory(for uuid: String?) {
        guard let uuid = uuid else { return }
        MeasurementHistory.sharedMeasurementHistory.getQOSHistoryOld(uuid: uuid, success: { response in
            self.qosResults = response
            self.statusMessage = self.calculateQosSuccessPercentage()
            self.tableView.reloadData()
        }, error: { error in
            self.statusMessage = String(format: "%i", error.localizedDescription)
            self.tableView.reloadData()
        })
    }
    
    /// calculate success/failure percentage
    private func calculateQosSuccessPercentage() -> String? {
        return self.qosResults?.calculateQosSuccessPercentage()
    }
    
    ///
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(false, animated: false)
        //
        if isModal { addStandardDoneButton() }

        // NSNotificationCenter.defaultCenter().addObserver(self, selector: "trafficLightTapped", name: "RMBTTrafficLightTappedNotification", object: nil)
    }

    ///
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func mapResultCell(with indexPath: IndexPath) -> UITableViewCell {
        let cell = RMBTHistoryItemCell(style: .default, reuseIdentifier: "map_test_cell")
        cell.applyTintColor()
        cell.applyColorScheme()
        cell.textLabel?.minimumScaleFactor = 0.7
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        
        if indexPath.row == 0 {
            let title = (self.showMapOption) ?
                L("history.result.map.latitude") :
                L("history.result.map.result")

            let latText: String = self.historyResult?.latitude() ?? ""
            cell.set(title: title, subtitle: latText)
        }
        if indexPath.row == 1 {
            let title = L("history.result.map.longitude")
            let longText: String =  self.historyResult?.longitude() ?? ""
            cell.set(title: title, subtitle: longText)
        }
        if indexPath.row == 2 {
            let title = L("history.result.map.accuracy")
            cell.set(title: title, subtitle: "-")
            if let locationString = historyResult?.locationString {
                if let index = locationString.firstIndex(of: "(") { // ????
                    let startIndex = locationString.index(after: index)
                    if let endIndex = locationString.firstIndex(of: ")") {
                        cell.set(title: title,
                                 subtitle: String(locationString[startIndex..<endIndex]))
                    }
                }
            }
        }
        if indexPath.row == 3 {
            cell.set(title: L("history.result.map.show"),
                     subtitle: "",
                     type: .disclosureIndicator)
        }
        
        if self.historyResult?.coordinate != nil {
            if self.showMapOption {
                cell.isUserInteractionEnabled = (indexPath.row == 3)
            } else {
                cell.isUserInteractionEnabled = false
                cell.set(title: L("history.result.map.show"),
                         subtitle: L("history.result.map.invalid-coordinates"),
                         type: .disclosureIndicator)
                cell.detailLabel.textAlignment = .right
                cell.detailLabel.minimumScaleFactor = 0.7
                cell.detailLabel.adjustsFontSizeToFitWidth = true
            }
        }
        
        return cell
    }
    
    func qosResultCell(with indexPath: IndexPath) -> UITableViewCell {
        let cell = RMBTHistoryItemCell(style: .default, reuseIdentifier: "qos_test_cell")
        cell.applyTintColor()
        cell.applyColorScheme()
        if let error = self.qosResults?.error {
            if indexPath.row == 0 {
                cell.isUserInteractionEnabled = false
                if error.count == 0 {
                    cell.set(title: L("history.result.qos.results"),
                             subtitle: self.statusMessage)
                } else {
                    cell.set(title: L("history.result.qos.results"),
                             subtitle: "")
                }
                
            } else {
                if error.count > 0 {
                    self.statusMessage = error[0]
                }
                if self.qosResults == nil || (error.count) > 0 {
                    cell.set(title: self.statusMessage,
                             subtitle: "",
                             type: .none)
                    cell.isUserInteractionEnabled = false
                    cell.textLabel?.adjustsFontSizeToFitWidth = true
                    cell.textLabel?.minimumScaleFactor = 0.6
                    cell.textLabel?.numberOfLines = 2
                    cell.accessoryType = .none
                    logger.debug("QOS RESULTS MISSING")
                    
                } else {
                    cell.isUserInteractionEnabled = true
                    cell.set(title: L("history.result.qos.results-detail"),
                             subtitle: "",
                             type: .disclosureIndicator)
                }
            }
        }
        
        return cell
    }
    
    func historyResultTimeCell(with indexPath: IndexPath) -> UITableViewCell {
        let cell = RMBTHistoryItemCell(style: .default, reuseIdentifier: "detail_test_cell")
        cell.applyColorScheme()
        if indexPath.row == 0 {
            cell.isUserInteractionEnabled = false
            if let time = self.historyResult?.timeString {
                cell.set(title: L("history.result.time"),
                         subtitle: time)
            } else {
                cell.set(title: L("history.result.time"),
                         subtitle: "")
            }
        } else {
            cell.isUserInteractionEnabled = true
            cell.set(title: L("history.result.more-details"),
                     subtitle: "",
                     type: .disclosureIndicator)
        }
        
        return cell
    }

    @objc override func popAction() {
        if let tabBarController = UIApplication.shared.delegate?.tabBarController() {
            tabBarController.pop()
        } else {
            super.popAction()
        }
    }
// MARK: - UITableViewDataSource/UITableViewDelegate

    //
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let historyResult = historyResult else { return 0 }
        return historyResult.dataState == RMBTHistoryResultDataState.index ? 0 : 5
    }
    
    //
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
    
    ///
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 2 {
            return self.historyResultTimeCell(with: indexPath)
        } else if indexPath.section == 3 {
            return self.qosResultCell(with: indexPath)
        } else if indexPath.section == 4 {
            return self.mapResultCell(with: indexPath)
        } else {
            if let item = self.itemsForSection(sectionIndex: indexPath.section)[indexPath.row] as? RMBTHistoryResultItem {
                let cell = RMBTHistoryItemCell(style: .default, reuseIdentifier: "history_result")
                cell.applyColorScheme()
                cell.textLabel?.applyResultColor()
                cell.setItem(item: item)
                
                return cell
            }

            return UITableViewCell()
        }
    }

    ///
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return self.itemsForSection(sectionIndex: section).count
        case 1: return self.itemsForSection(sectionIndex: section).count
        case 2: return 2
        case 3: return 2
        case 4: return (self.showMapOption) ? 4 : 1
        default: return 0
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var title: String? = nil
        switch section {
        case 0: title = L("history.result.headline.measurement")
        case 1: title = L("history.result.headline.network")
        case 2: title = L("history.result.headline.details")
        case 3: title = L("history.result.headline.qos")
        case 4: title = L("history.result.headline.map")
        default: title = "-unknown section-"
        }
        let header = RMBTSettingsTableViewHeader.view()
        header?.titleLabel.text = title
        header?.applyColorScheme()
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }

    ///
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath as IndexPath, animated: false)

        switch indexPath.section {
        case 2: showResultDetails()
        case 3: showQosResults()
        case 4: showMap()
        default: break
        }
    }

// MARK: - Class Methods

    func showQosResults() {
        let qtView = UIStoryboard.qosResultsScreen() as! QosMeasurementIndexTableViewController
        //qtView.qosTestResults = self.qosResults
        qtView.qosMeasurementResult = self.qosResults
        if UIDevice.isDeviceTablet(),
            let tabBarController = UIApplication.shared.delegate?.tabBarController() {
            tabBarController.push(vc: qtView, from: self)
        } else {
            self.navigationController?.pushViewController(qtView, animated: true)
        }
    }
    
    func showMap() {
        if let historyResult = self.historyResult {
            let coordinateIsValid: Bool = CLLocationCoordinate2DIsValid(historyResult.coordinate)
            
            assert(coordinateIsValid, "Invalid coordinate but map button was enabled")
            
            if coordinateIsValid {
                // Set map options
                let selection: RMBTMapOptionsSelection = RMBTMapOptionsSelection()

                if let netType = historyResult.networkType {
                    selection.subtypeIdentifier = RMBTNetworkTypeIdentifier(netType)
                }

                if let mapNC = UIStoryboard.mapScreen() as? UINavigationController {
                    if let mvc: RMBTMapViewController = mapNC.topViewController as? RMBTMapViewController {
                        mvc.isModal = true
                        mvc.hidesBottomBarWhenPushed = true
                        mvc.initialLocation = CLLocation(latitude: historyResult.coordinate.latitude, longitude: historyResult.coordinate.longitude) // !
                        self.present(mapNC, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    func showResultDetails() {
        let rdvc = UIStoryboard.resultDetailsScreen() as! RMBTHistoryResultDetailsViewController
        rdvc.historyResult = self.historyResult
        if UIDevice.isDeviceTablet(),
            let tabBarController = UIApplication.shared.delegate?.tabBarController() {
            tabBarController.push(vc: rdvc, from: self)
        } else {
            self.navigationController?.pushViewController(rdvc, animated: true)
        }
    }
    ///
    private func trafficLightTapped(n: NSNotification) {
        let configuration = RMBTConfigFabric.config(with: RMBTConfigurationIdentifier)
        self.presentModalBrowserWithURLString(configuration.RMBT_HELP_RESULT_URL)
    }

    ///
    private func itemsForSection(sectionIndex: Int) -> [AnyObject] {
        assert(sectionIndex <= 5, "Invalid section")
        guard let historyResult = historyResult else { return [] }
        return (sectionIndex == 0) ? historyResult.measurementItems : historyResult.netItems // !
    }

}

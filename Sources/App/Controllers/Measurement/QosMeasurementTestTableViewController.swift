/*****************************************************************************************************
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
import RMBTClient

///
struct QosMeasurementTestItem {

    ///
    var title: String

    ///
    var summary: String

    ///
    var testDescription: String

    ///
    var objectiveId: Int

    ///
    var oldUid: Int

    ///
    var success: Bool
}

///
class QosMeasurementTestTableViewController: UITableViewController {

    ///
    var qosMeasurementResult: QosMeasurementResultResponse?

    ///
    var qosMeasurementItem: QosMeasurementItem?

    ///
    var testItems = [QosMeasurementTestItem]()

    ///
    let testStr = L("history.qos.detail.test")

    ///
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = qosMeasurementItem?.type.description
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

        if let testResultDetail = qosMeasurementResult?.testResultDetail {
            var cnt = 0

            testItems.append( // TODO: should be done by rmbt-ios-client library
                contentsOf: testResultDetail.filter({ measurementQosResult in
                    return measurementQosResult.type == qosMeasurementItem?.type
                }).map({ measurementQosResult in
                    cnt += 1

                    if let summary = measurementQosResult.summary,
                        let testDescription = measurementQosResult.testDesc,
                        // let objectiveId = measurementQosResult.objectiveId,
                        let oldUid = measurementQosResult.oldUid {
                        //
                        let objectiveId = measurementQosResult.objectiveId
                        //
                        return QosMeasurementTestItem(
                            title: "\(testStr) #\(cnt)",
                            summary: summary,
                            testDescription: testDescription,
                            objectiveId: objectiveId,
                            oldUid: oldUid,
                            success: measurementQosResult.failureCount == 0)
                    }

                    assert(false, "this should never happen")
                    return QosMeasurementTestItem(
                        title: "-",
                        summary: "-",
                        testDescription: "-",
                        objectiveId: -1,
                        oldUid: -1,
                        success: false)
                })
            )
        }

        self.applyColorScheme()
        self.updateColorForNavigationBarAndTabBar()
        tableView.reloadData()
        
        if UIDevice.isDeviceTablet() {
            self.addStandardBackButton()
        }
    }
    
    @objc override func popAction() {
        if let tabBarController = UIApplication.shared.delegate?.tabBarController() {
            tabBarController.pop()
        } else {
            super.popAction()
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

    ///
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }
    
    func showQosTestDetails(at index: Int) {
        if let qosMeasurementTestDetailTableViewController = UIStoryboard.qosTestDetailsScreen() as? QosMeasurementTestDetailTableViewController {
            qosMeasurementTestDetailTableViewController.qosMeasurementResult = qosMeasurementResult
            qosMeasurementTestDetailTableViewController.qosMeasurementTestItem = testItems[index]
            
            if UIDevice.isDeviceTablet() {
                let tabBarController = UIApplication.shared.delegate?.tabBarController()
                tabBarController?.push(vc: qosMeasurementTestDetailTableViewController, from: self)
            } else {
                self.navigationController?.pushViewController(qosMeasurementTestDetailTableViewController, animated: true)
            }
        }
    }
}

// MARK: UITableViewDataSource

extension QosMeasurementTestTableViewController {

    ///
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var title: String? = nil
        switch section {
        case 0: title = L("history.qos.headline.details")
        case 1: title = L("history.qos.headline.tests")
        default: title = "-"
        }
        let header = RMBTSettingsTableViewHeader.view()
        header?.titleLabel.text = title
        header?.applyColorScheme()
        return header
    }
    
    ///
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return testItems.count
        }
    }

    ///
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 { // description section

            let cell = tableView.dequeueReusableCell(withIdentifier: "qos_test_description_cell") as! QosMeasurementResultStatusTableViewCell
            cell.applyColorScheme()
            
            if let item = qosMeasurementItem {
                cell.titleLabel?.text = item.descriptionText
            }

            return cell

        } else { // test list section

            let cell = tableView.dequeueReusableCell(withIdentifier: "qos_test_cell") as! QosMeasurementResultStatusTableViewCell
            cell.applyColorScheme()

            let item = testItems[indexPath.row]

            cell.titleLabel?.text = item.title
            cell.resultLabel?.text = item.summary
            
            cell.statusView?.status = item.success ? .success : .failure

            return cell
        }
    }
}

// MARK: UITableViewDelegate

///
extension QosMeasurementTestTableViewController {

    ///
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35
    }

    ///
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 80
        } else {
            return 60
        }
    }

    ///
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            self.showQosTestDetails(at: indexPath.row)
        }
    }
}

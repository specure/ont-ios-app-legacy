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
struct QosMeasurementItem {

    ///
    var type: QosMeasurementType

    ///
    var count: Int

    ///
    var successCount: Int

    ///
    var descriptionText: String

    ///
    var success: Bool {
        return successCount == count
    }
}

///
class QosMeasurementIndexTableViewController: UITableViewController {

    ///
    var qosMeasurementResult: QosMeasurementResultResponse?

    ///
    var qosMeasurementItems = [QosMeasurementItem]()

    ///
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

        if UIDevice.isDeviceTablet() {
            self.addStandardBackButton()
        }
        parseQosResultForIndexView()
        
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
    }
    
    func applyColorScheme() {
        self.view.backgroundColor = RMBTColorManager.background
        self.tableView.backgroundColor = RMBTColorManager.tableViewBackground
        self.tableView.separatorColor = RMBTColorManager.tableViewSeparator
        self.tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }

    @objc override func popAction() {
        if let tabBarController = UIApplication.shared.delegate?.tabBarController() {
            tabBarController.pop()
        } else {
            super.popAction()
        }
    }
    ///
    private func parseQosResultForIndexView() { // TODO: should be done by rmbt-ios-client library
        if let resultDetail = qosMeasurementResult?.testResultDetail {

            var successCountDict = [QosMeasurementType: Int]()
            var countDict = [QosMeasurementType: Int]()
            
            for i in resultDetail {

                if let type = i.type, let failureCount = i.failureCount {
                    // success count
                    if failureCount == 0 {
                        if let current = successCountDict[type] {
                            successCountDict[type] = current + 1
                        } else {
                            successCountDict[type] = 1
                        }
                    }

                    // overall count
                    if let current = countDict[type] {
                        countDict[type] = current + 1
                    } else {
                        countDict[type] = 1
                    }
                }
            }

            for (type, count) in countDict {
                if let descriptionText = qosMeasurementResult?.testResultDetailTestDescription?.filter({ desc in // TODO: improve this, "for in" the array only once!
                        return desc.type == type
                    }).first?.description {

                    let item = QosMeasurementItem(type: type, count: count, successCount: successCountDict[type] ?? 0, descriptionText: descriptionText)
                    qosMeasurementItems.append(item)
                }
               
            }
        }

        tableView.reloadData()
    }

    ///
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }
    
    func showQosMeasurementTest(at index: Int) {
        if let qosTestTableViewController = UIStoryboard.qosMeasurementTestScreen() as? QosMeasurementTestTableViewController {
            qosTestTableViewController.qosMeasurementResult = qosMeasurementResult
            qosTestTableViewController.qosMeasurementItem = qosMeasurementItems[index]
            
            if UIDevice.isDeviceTablet() {
                let tabBarController = UIApplication.shared.delegate?.tabBarController()
                tabBarController?.push(vc: qosTestTableViewController, from: self)
            } else {
                self.navigationController?.pushViewController(qosTestTableViewController, animated: true)
            }
        }
    }
}

// MARK: UITableViewDataSource

extension QosMeasurementIndexTableViewController {

    ///
    override func numberOfSections(in tableView: UITableView) -> Int {
        return qosMeasurementItems.count 
    }

    ///
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    ///
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "qos_result_cell") as? QosMeasurementResultStatusTableViewCell {
        
            let item = qosMeasurementItems[indexPath.section]
            
            cell.titleLabel?.text = item.type.description
            cell.resultLabel?.text = "\(item.successCount)/\(item.count)"
            
            cell.statusView?.status = item.success ? .success : .failure
            
            cell.applyColorScheme()
            return cell
        }
        return UITableViewCell()
    }
}

// MARK: UITableViewDelegate

///
extension QosMeasurementIndexTableViewController {

    ///
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        }

        return 5
    }

    ///
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.showQosMeasurementTest(at: indexPath.section)
//        performSegue(withIdentifier: "show_qos_test", sender: indexPath.section)
    }
}

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
class GeneralSettingsViewController: UITableViewController {
    
    ///
    @IBOutlet private var sideBarButton: UIBarButtonItem?

    ///
    //@IBOutlet private var publishPublicDataSwitch: UISwitch?

    ///
    @IBOutlet private var anonymousModeSwitch: UISwitch?

    ///
    @IBOutlet private var nerdModeSwitch: UISwitch?

    ///
    @IBOutlet private var nerdModeQosEnabledLabel: UILabel?

    ///
    //@IBOutlet private var publishPersonalDataTableViewCell: UITableViewCell?

    // TODO: dismiss number input fields!

    ///
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title?.formatStringSettings()

        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

        sideBarButton?.target = revealViewController()
        sideBarButton?.action = #selector(SWRevealViewController.revealToggle(_:))

        // Set the gesture
        view.addGestureRecognizer(revealViewController().edgeGestureRecognizer())
        view.addGestureRecognizer(revealViewController().tapGestureRecognizer())

        revealViewController().delegate = self

        //////////////////
        // General
        //////////////////

        /*if (TEST_USE_PERSONAL_DATA_FUZZING) {
            // publishPublicDataSwitch
            bindSwitch(publishPublicDataSwitch, toSettingsKeyPath: "publishPublicData") { value in
                if (value && TEST_USE_PERSONAL_DATA_FUZZING) {
                    // if is set to on -> show terms and conditions again
                    self.performSegueWithIdentifier("show_tos_from_settings", sender: self)
                }
            }
        } else {
            publishPersonalDataTableViewCell?.hidden = true
        }*/

        // anonymous mode
        bindSwitch(anonymousModeSwitch, toSettingsKeyPath: "anonymousModeEnabled", onToggle: nil)

        // nerd mode
        bindSwitch(nerdModeSwitch, toSettingsKeyPath: "nerdModeEnabled") { on in
            if on {
                self.updateNerdModeQosLabel()
            }

            //self.tableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: .None)
            self.tableView.reloadData()
        }
    }

    ///
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
        
        updateNerdModeQosLabel()
        
    }

    ///
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        RMBTClient.refreshSettings()
    }

// MARK: Support

    ///
    private func updateNerdModeQosLabel() {
        guard let label = self.nerdModeQosEnabledLabel else { return }
        if RMBTSettings.sharedSettings.nerdModeQosEnabled == RMBTSettings.NerdModeQosMode.manually.rawValue {
            label.text = L("RMBT-SETTINGS-QOSDISABLED")
        } else {
            label.text = L("RMBT-SETTINGS-QOSENABLED")
        }
    }

// MARK: Table view

    ///
    override func numberOfSections(in tableView: UITableView) -> Int {
        return RMBTSettings.sharedSettings.debugUnlocked ? 3 : 2
    }

    ///
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 1: return RMBTSettings.sharedSettings.nerdModeEnabled ? 2 : 1
        default: return super.tableView(tableView, numberOfRowsInSection: section)
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return UITableViewHeaderFooterView.formatSettingsFooter(section).textLabel?.text
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return UITableViewHeaderFooterView.formatSettingsHeader(section).textLabel?.text
    }
}

// MARK: SWRevealViewControllerDelegate

///
extension GeneralSettingsViewController: SWRevealViewControllerDelegate {

    ///
    func revealControllerPanGestureBegan(_ revealController: SWRevealViewController!) {
        self.tableView.isScrollEnabled = false
    }

    ///
    func revealController(_ revealController: SWRevealViewController!, willMoveTo position: FrontViewPosition) {
        self.tableView.isScrollEnabled = false
    }

    ///
    func revealController(_ revealController: SWRevealViewController!, didMoveTo position: FrontViewPosition) {
        let posLeft = (position == .left)

        tableView.isScrollEnabled = posLeft
        tableView.allowsSelection = posLeft

        if posLeft {
            view.removeGestureRecognizer(revealViewController().panGestureRecognizer())
            view.addGestureRecognizer(revealViewController().edgeGestureRecognizer())
        } else {
            view.removeGestureRecognizer(revealViewController().edgeGestureRecognizer())
            view.addGestureRecognizer(revealViewController().panGestureRecognizer())
        }
    }

}

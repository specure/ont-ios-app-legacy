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

import UIKit

///
class RMBTSideMenuController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            return .darkContent
        } else {
            return .default
        }
    }
    ///
    @IBOutlet private var menuTable: UITableView!
    
    ///
    @IBOutlet private var bottomView: UIView?
    
    ///
    @IBOutlet private var infoButton: UIButton?
    
    ///
    @IBOutlet private var settingsButton: UIButton?
    
    ///
    private var menuItems: [String] {
        
        var items = ["home", "history", "map", "help"]
        
        if USE_OPENDATA {
            items.insert("statistics", at: 3)
        }
        
        if RMBTClient.surveyIsActiveService == true {
            items.insert("survey", at: items.count - 1)
        }
        
        return items
    }
    
    private var titleItems: [String] {
        var localizationTitleItems = [L("RMBT-NI-HOME"), L("RMBT-NI-HISTORY"), L("RMBT-NI-MAPS"), L("RMBT-NI-HELP")]
        
        if USE_OPENDATA {
            localizationTitleItems.insert(L("RMBT-NI-STATISTICS"), at: 3)
        }
        
        if RMBTClient.surveyIsActiveService == true {
            localizationTitleItems.insert(L("Survey"), at: localizationTitleItems.count - 1)
        }
        
        return localizationTitleItems
    }
    
    ///
    private var prevSelectedRow: Int = 0
    
    //
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // add NSLocalized string as following item header
        if let indexPath = menuTable.indexPathForSelectedRow,
            let cell = menuTable.cellForRow(at: indexPath) {
            let title = String.formatStringsMenu(cell.tag)
            if let nc = segue.destination as? UINavigationController {
                if let controller = nc.topViewController {
                    controller.navigationItem.title = title
                }
            }
        }
    }
    
    ///
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.applyFancyBackground()
        
        view.backgroundColor = NAVIGATION_BACKGROUND_COLOR
        menuTable.backgroundColor = NAVIGATION_BACKGROUND_COLOR
        bottomView?.backgroundColor = NAVIGATION_BACKGROUND_COLOR
        
        menuTable.separatorStyle = .none
        // makes it too much, tha last item not visible
        //        menuTable.estimatedRowHeight = 44
        //        menuTable.rowHeight = UITableViewAutomaticDimension
        
        // select home
        menuTable.selectRow(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .top)
        
        if NAVIGATION_USE_TINT_COLOR {
            infoButton?.buttonWithColor(.white)
            settingsButton?.buttonWithColor(.white)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.menuTable.reloadData()
    }
    
    func openSurvey() {
        if let urlString = RMBTClient.surveyUrl,
            let uuid = RMBTClient.uuid,
            let url = URL(string: urlString + "?client_uuid=" + uuid) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            AnalyticsHelper.logCustomEvent(withName: "Survey Menu: Open Clicked", attributes: nil)
        } else {
            var parameters = ["Reason": "Bad Url"]
            parameters["url"] = RMBTClient.surveyUrl ?? "Empty"
            parameters["uuid"] = RMBTClient.uuid ?? "Empty"
            AnalyticsHelper.logCustomEvent(withName: "Survey Menu: Don't showed", attributes: parameters)
        }
    }
    
    ///
    // MARK: UITableViewDataSource / UITableViewDelegate
    
    ///
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    ///
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    ///
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let localizationItem = self.titleItems[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: menuItems[indexPath.row]) as! RMBTMenuTVCell
        cell.menuItemLabel.text = localizationItem
        return cell
    }
    
    ///
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if self.menuItems[indexPath.row] == "survey" {
            self.openSurvey()
            return nil
        }
        prevSelectedRow = menuTable.indexPathForSelectedRow?.row ?? -1 // is only -1 if info or settings are active
        return indexPath
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.menuItems[indexPath.row] == "home" {
            let configuration = RMBTConfigFabric.config(with: RMBTConfigurationIdentifier)
            if configuration.RMBT_VERSION >= 3 {
                self.performSegue(withIdentifier: "pushLoopModeViewController", sender: self)
            } else {
                self.performSegue(withIdentifier: "pushHomeViewController", sender: self)
            }
            revealViewController().revealToggle(animated: true)
        }
    }
    
    // MARK: Methods
    
    ///
    @IBAction func deselectCellInTable() {
        if let index = menuTable.indexPathForSelectedRow {
            menuTable.deselectRow(at: index, animated: true)
        }
        
        prevSelectedRow = -1 // is only -1 if info or settings are active
    }
    
    // MARK: Segue methods
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        
        if (identifier == "pushHomeViewController" || identifier == "pushLoopModeViewController")   && prevSelectedRow == menuItems.firstIndex(of: "home")    ||
            identifier == "pushHistoryViewController"    && prevSelectedRow == menuItems.firstIndex(of: "history")    ||
            identifier == "pushMapViewController"        && prevSelectedRow == menuItems.firstIndex(of: "map")        ||
            identifier == "pushStatisticsViewController" && prevSelectedRow == menuItems.firstIndex(of: "statistics") ||
            identifier == "pushHelpViewController"       && prevSelectedRow == menuItems.firstIndex(of: "help") {
            
            revealViewController().revealToggle(animated: true)
            return false
        }
        
        return true
    }
}

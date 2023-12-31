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
import RMBTClient

///
protocol RMBTMapSubViewControllerDelegate: AnyObject {

    ///
    func mapSubViewController(_ viewController: RMBTMapSubViewController, willDisappearWithChange change: Bool)
}

///
class RMBTMapSubViewController: UITableViewController {

    ///
    weak var delegate: RMBTMapSubViewControllerDelegate?

    ///
    var mapOptions: RMBTMapOptions!

    //

    ///
    override func viewDidLoad() {
        super.viewDidLoad()

        assert(mapOptions != nil)
        assert(delegate != nil)
        
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
        tableView.backgroundColor = RMBTColorManager.tableViewBackground
        tableView.separatorColor = RMBTColorManager.tableViewSeparator
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func applyColorScheme(for cell: UITableViewCell) {
        cell.textLabel?.textColor = RMBTColorManager.tintColor
        cell.detailTextLabel?.textColor = RMBTColorManager.textColor
        cell.backgroundColor = RMBTColorManager.cellBackground
        cell.tintColor = RMBTColorManager.tintColor
    }
}

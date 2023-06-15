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

class RMBTMapOptionsViewController: RMBTMapSubViewController {
    @IBOutlet internal var mapViewTypeSegmentedControl: UISegmentedControl!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return RMBTColorManager.statusBarStyle
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title?.formatStringSettings()
        
        assert(mapOptions != nil) // TODO: is this line doubled?

        let configuration = RMBTConfigFabric.config(with: RMBTConfigurationIdentifier)
        mapViewTypeSegmentedControl.isHidden = configuration.RMBT_VERSION != 2
        
        mapViewTypeSegmentedControl.formatStringsMapOptions()
        
        mapViewTypeSegmentedControl.selectedSegmentIndex = mapOptions.mapViewType.rawValue
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
    
    override func applyColorScheme() {
        super.applyColorScheme()
        self.mapViewTypeSegmentedControl.tintColor = RMBTColorManager.tintColor
    }

    ///
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        delegate?.mapSubViewController(self, willDisappearWithChange: true)
    }

// MARK: UITableViewDelegate methods

    ///
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let type = mapOptions.types[section]
        let subtypes = mapOptions.subTypes(for: type)
        return subtypes.count
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let type = mapOptions.types[section]
        let header = RMBTSettingsTableViewHeader.view()
        header?.titleLabel.text = type.title
        header?.applyColorScheme()
        return header
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }

    ///
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "map_subtype_cell"

        let type = mapOptions.types[indexPath.section]
        let subtypes = mapOptions.subTypes(for: type)
        let subtype = subtypes[indexPath.row]

        var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
        }

        cell.textLabel?.text = subtype.title

        if subtype === mapOptions.activeSubtype && mapOptions.activeType === type {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        self.applyColorScheme(for: cell)

        return cell
    }

    ///
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let type = mapOptions.types[indexPath.section]
        let subtypes = mapOptions.subTypes(for: type)
        let subtype = subtypes[indexPath.row]

        if subtype === mapOptions.activeSubtype && type === mapOptions.activeType {
            // No change, do nothing
        } else {
            var indexPathes: [IndexPath] = [indexPath]
            if let options = mapOptions,
                let type = options.activeType,
                let previousSection = options.types.firstIndex(of: type) {
                let previousSubTypes = options.subTypes(for: type)
                if let previousSubType = options.activeSubtype,
                    let previousRow = previousSubTypes.firstIndex(of: previousSubType) {
                    let oldIndex = IndexPath(row: previousRow, section: previousSection)
                    indexPathes.append(oldIndex)
                }
            }
            
            mapOptions.activeSubtype = subtype
            mapOptions.activeType = type

            tableView.reloadRows(
                at: indexPathes,
                with: .automatic
            )
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }

    ///
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.mapOptions.types.count
    }

// MARK: other methods

    ///
    @IBAction func mapViewTypeSegmentedControlIndexDidChange(_ sender: AnyObject) {
        mapOptions.mapViewType = RMBTMapOptionsMapViewType(rawValue: mapViewTypeSegmentedControl.selectedSegmentIndex)!
    }
}

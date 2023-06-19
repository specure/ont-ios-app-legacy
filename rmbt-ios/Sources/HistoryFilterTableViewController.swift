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
import UIKit
import RMBTClient

///
protocol HistoryFilterTableViewControllerDelegate: class {
    func didAssignFilters(_ theFilters: HistoryFilterType)
}
///
let HISTORY_FILTERS_STORE_ID = "HistoryFilterType"

///
class HistoryFilterTableViewController: UITableViewController {

    /// http://stackoverflow.com/questions/24556893/immutable-value-of-type-any-only-has-mutating-members-named-append-in-swif
    var filterData = [[String: AnyObject]]()
    
    ///
    var filters = HistoryFilterType()
    
    /// Constants
    let FILTER_NAME = "name"
    let FILTER_ITEM = "items"
    let FILTER_CELL_ID = "historyFilterCell"
    ///
    weak var delegate: HistoryFilterTableViewControllerDelegate?
    
    ///
    override func viewDidLoad() {
        super.viewDidLoad()

        // not sure why is this here, so I disabled it
        //navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        
        filterData = MeasurementHistory.sharedMeasurementHistory.getHistoryFilterModel()
        
        tableView.reloadData()
    }
    
    ///
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        delegate?.didAssignFilters(filters)
    }
    
    ///
    @IBAction func resetFilterSetting () {
        UserDefaults.standard.deleteHistoryFilters()
        filters = HistoryFilterType()
        tableView.reloadData()
    }
    
// MARK: Utils
    ///
    func retrieveFilterNames() -> [String] {
        var items = [String]()
        
        for item in filters {
            items.append(item.0)
        }
        
        return items
    }
    ///
    func retrieveFiltersName(_ index: NSInteger) -> String {
        guard let filterName = filterData [index][FILTER_NAME] as? String else {
            return ""
        }
        
        return filterName
    }
    ///
    func retrieveFiltersItems(_ index: NSInteger) -> [String] {
        guard let filterElements = filterData [index][FILTER_ITEM] as? [String] else {
            return []
        }
        
        return filterElements
    }
    
    /// nasty
    func consolidateEntries(_ index: NSInteger) -> String {
        var filterName = retrieveFiltersName(index)
        
        // nasty workaround
        if filterName == "network_type" {
            filterName = "networkType"
        }
        
        return filterName
    }
}

// MARK: UITableViewDataSource

extension HistoryFilterTableViewController {
    
    ///
    override func numberOfSections(in tableView: UITableView) -> Int {
        return filterData.count 
    }
    
    ///
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return retrieveFiltersName(section)
    }
    
    ///
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  retrieveFiltersItems(section).count 
    }
    
    ///
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FILTER_CELL_ID) else {
            return UITableViewCell()
        }
        
        let filterName = consolidateEntries(indexPath.section)
        let filterContent = retrieveFiltersItems(indexPath.section)[indexPath.row]

        logger.debug("\(filterData)")
        logger.debug("\(filters)")
        logger.debug("\(filterName), \(filterContent)")
        
        cell.textLabel?.text = filterContent
        
        if let filterSet = filters[filterName]?.contains(filterContent) {
            logger.debug("FILTER SET \(filterSet)")
            
            cell.accessoryType = filterSet ? .checkmark : .none
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
}

// MARK: UITableViewDelegate

///
extension HistoryFilterTableViewController {
    
    ///
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35
    }
    
    ///
    /*override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {

    }*/
    
    ///
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let filterName = consolidateEntries(indexPath.section)
        let filterContent = retrieveFiltersItems(indexPath.section)[indexPath.row]
        
        //
        if filters.count > 0 {
            // if a filter already exists, update with new item or remove
            for filter in filters {
                
                var theFilter = filter
                
                if filter.0 == filterName {
                    for filterItem in filter.1 {
                        if filterItem == filterContent {
                            // remove item in filter if already exists
                            theFilter.1.remove(at: filter.1.firstIndex(of: filterItem)!)
                            
                        } else {
                            // update filter
                            if !((filters[filterName]?.contains(filterContent))!) {
                                theFilter.1.append(filterContent)
                            }
                        }
                        
                        if theFilter.1.count > 0 {
                            filters.updateValue(theFilter.1, forKey: filterName)
                        } else {
                            filters.removeValue(forKey: theFilter.0)
                        }
                        
                        break
                    }
                } else {
                    
                    if !self.retrieveFilterNames().contains(filterName) {
                        filters.updateValue([filterContent], forKey: filterName)
                        
                        break
                    }
                }
            }
        } else {
            // if no filters then add new one
            filters = [filterName: [filterContent]]
        }
        
        UserDefaults.standard.storeHistoryFilters(filters)
        
        tableView.reloadData()
    }
}

// MARK: History filters persistancy methods

extension UserDefaults {
    
    ///
    func storeHistoryFilters(_ filters: HistoryFilterType) {
        set(filters, forKey: HISTORY_FILTERS_STORE_ID)
    }
    
    ///
    func retrieveHistoryFilters() -> HistoryFilterType {
        guard let filters = dictionary(forKey: HISTORY_FILTERS_STORE_ID) as? HistoryFilterType else {
            return HistoryFilterType()
        }
        
        return filters
    }
    
    ///
    func deleteHistoryFilters() {
        removeObject(forKey: HISTORY_FILTERS_STORE_ID)
    }
}

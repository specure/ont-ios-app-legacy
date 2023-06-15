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
class RMBTMapOptionsFilterViewController: RMBTMapSubViewController {
    enum SectionType {
        case country
        case `operator`
        case overlay
        case period
        case technologies
    }
    
    class Item: NSObject {
        var title: String?
        var subtitle: String?
        var value: String?
        var isActive: Bool = false
    }
    
    class ItemSection: NSObject {
        var title: String?
        var items: [Item] = []
        var type: SectionType = .technologies
    }
    
    private let showCountriesSegue = "showCountriesSegue"

    var sections: [ItemSection] = []
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return RMBTColorManager.statusBarStyle
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    ///
    override func viewDidLoad() {
        super.viewDidLoad()
        self.reloadSections()
    }

    ///
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        delegate?.mapSubViewController(self, willDisappearWithChange: true)
    }

    func reloadSections(with isReloadOperators: Bool = true) {
        self.sections = []
        
        if RMBT_MAP_SKIP_RESPONSE_OPERATORS == true {
            let countrySection = ItemSection()
            countrySection.title = L("map.options.filter.country")
            countrySection.type = .country
            let item = Item()
            item.title = self.mapOptions.activeCountry?.name
            item.value = self.mapOptions.activeCountry?.code
            countrySection.items = [item]
            
            let operatorsSection = ItemSection()
            operatorsSection.title = L("map.options.filter.operators")
            operatorsSection.type = .operator
            
            operatorsSection.items = self.mapOptions.operatorsForCountry.map({ (op) -> Item in
                let item = Item()
                item.title = op.title
                item.subtitle = op.subtitle
                item.value = op.title
                if let activeOperator = self.mapOptions.activeOperator {
                    item.isActive = (op == activeOperator)
                } else if let devaultOperator = self.mapOptions.defaultOperator {
                    item.isActive = (op == devaultOperator)
                }
                return item
            })
            
            self.sections.append(countrySection)
            self.sections.append(operatorsSection)
        }
        
        let overlaySection = ItemSection()
        overlaySection.title = L("map.options.filter.overlay")
        overlaySection.type = .overlay
        overlaySection.items = self.mapOptions.overlays.map({ (overlay) -> Item in
            let item = Item()
            item.title = overlay.title
            item.isActive = (mapOptions.activeOverlay == overlay)
            return item
        })
        
        self.sections.append(overlaySection)
        
        let periodSection = ItemSection()
        periodSection.title = L("map.options.filter.period")
        periodSection.type = .period
        periodSection.items = self.mapOptions.periodFilters.map({ (period) -> Item in
            let item = Item()
            item.title = period.title
            item.value = String(period.period)
            item.isActive = (mapOptions.activePeriodFilter == period)
            return item
        })
        
        self.sections.append(periodSection)
        
        if self.mapOptions?.activeType?.id == .cell {
            let technologiesSection = ItemSection()
            technologiesSection.title = L("map.options.filter.technologies")
            technologiesSection.type = .technologies
            technologiesSection.items = self.mapOptions.mapCellularTypes.map({ (type) -> Item in
                let item = Item()
                item.title = type.title
                item.value = String(type.id ?? 0)
                item.isActive = mapOptions.activeCellularTypes.contains(type)
                return item
            })
            
            self.sections.append(technologiesSection)
        }
        
        self.tableView.reloadData()
        
        if self.mapOptions.operatorsForCountry.count == 0 {
            self.reloadOperators()
        }
    }
    
    func reloadOperators() {
        if RMBT_MAP_SKIP_RESPONSE_OPERATORS == true {
            if let countryCode = self.mapOptions.activeCountry?.code {
                var type: OperatorsRequest.ProviderType = .all
                if let currentType = self.mapOptions?.activeType?.toProviderType() {
                    type = currentType
                }
                MapServer.sharedMapServer.getMapFilterOperators(for: countryCode, type: type, success: { (options) in
                    self.mapOptions.operatorsForCountry = options.operators ?? []
                    self.mapOptions.activeOperator = self.mapOptions.operatorsForCountry.first
                    self.reloadSections()
                }, error: { (error) in
                    logger.error("Error getting operators of country")
                })
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == self.showCountriesSegue,
            let vc = segue.destination as? RMBTSelectListItemsViewController {
            vc.items = self.mapOptions.countries.map({ (country) -> [String: Any] in
                return [country.name ?? "": country]
            })
            vc.title = L("map.options.filter.countries")
            vc.selectedItem = self.mapOptions.activeCountry
            vc.onDidSelectHandler = { [weak self] value in
                if let value = value as? RMBTMapOptionCountry {
                    if self?.mapOptions.activeCountry != value {
                        self?.mapOptions.operatorsForCountry = []
                        self?.mapOptions.activeCountry = value
                        self?.mapOptions.activeOperator = nil
                        self?.reloadSections()
                    }
                }
            }
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        guard UIApplication.shared.applicationState == .inactive else {
            return
        }
        
        self.tableView.reloadData()
    }
// MARK: Table view data source

    ///
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.sections.count
    }

    ///
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sections[section].items.count
    }

    ///
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "map_filter_cell"

        var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
        }
        
        let section = self.sections[indexPath.section]
        let item = section.items[indexPath.row]
        cell.accessoryType = item.isActive ? .checkmark : .none
        cell.textLabel?.text = item.title
        cell.detailTextLabel?.text = item.subtitle
        
        self.applyColorScheme(for: cell)
        return cell
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let section = self.sections[section]
        let header = RMBTSettingsTableViewHeader.view()
        header?.titleLabel.text = section.title
        header?.applyColorScheme()
        return header
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }

// MARK: Table view delegate

    ///
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = self.sections[indexPath.section]
        if section.type == .country {
            self.performSegue(withIdentifier: self.showCountriesSegue, sender: self)
        } else if section.type == .operator {
            let item = section.items[indexPath.row]
            if !item.isActive {
                var previousIndexPath: IndexPath?
                if let previousRow: Int = section.items.firstIndex(where: { (item) -> Bool in
                    return item.isActive
                }) {
                    previousIndexPath = IndexPath(row: previousRow, section: indexPath.section)
                    let prevItem = section.items[previousRow]
                    prevItem.isActive = false
                }
                
                let value = self.mapOptions.operatorsForCountry[indexPath.row]
                self.mapOptions.activeOperator = value

                item.isActive = true
                
                var indexPathes = [indexPath]
                if let indexPath = previousIndexPath {
                    indexPathes.append(indexPath)
                }
                tableView.reloadRows(at: indexPathes, with: .automatic)
            }
        } else if section.type == .overlay {
            let overlay = mapOptions.overlays[indexPath.row] as MapOptionResponse.MapOverlays
            if overlay == mapOptions.activeOverlay {
                // do nothing
            } else {
                self.mapOptions.activeOverlay = overlay
                let item = section.items[indexPath.row]
                section.items.forEach { (item) in
                    item.isActive = false
                }
                item.isActive = true
                tableView.reloadSections(IndexSet(arrayLiteral: indexPath.section), with: .automatic)
            }
        } else if section.type == .period {
            let period = mapOptions.periodFilters[indexPath.row] as MapOptionResponse.MapPeriodFilters
            if period == mapOptions.activePeriodFilter {
                // do nothing
            } else {
                var indexPathes: [IndexPath] = [indexPath]
                var prevItem: Item?
                if let activePeriod = mapOptions.activePeriodFilter,
                    let index = mapOptions.periodFilters.firstIndex(of: activePeriod) {
                    indexPathes.append(IndexPath(row: index, section: indexPath.section))
                    prevItem = section.items[index]
                }
                self.mapOptions.activePeriodFilter = period
                let item = section.items[indexPath.row]
                item.isActive = true
                prevItem?.isActive = false
                tableView.reloadRows(at: indexPathes, with: .automatic)
            }
        } else if section.type == .technologies {
            let item = section.items[indexPath.row]
            let type = mapOptions.mapCellularTypes[indexPath.row]
            if mapOptions.activeCellularTypes.contains(type) {
                if let index = mapOptions.activeCellularTypes.firstIndex(of: type) {
                    mapOptions.activeCellularTypes.remove(at: index)
                    item.isActive = false
                }
            } else {
                mapOptions.activeCellularTypes.append(type)
                item.isActive = true
            }
            
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }
}

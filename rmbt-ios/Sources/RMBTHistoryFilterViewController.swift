//
//  RMBTHistoryFilterViewController.swift
//  RMBT
//
//  Created by Benjamin Pucher on 25.09.14.
//  Copyright © 2014 SPECURE GmbH. All rights reserved.
//

import Foundation

protocol RMBTHistoryFilterViewControllerDelegate: AnyObject {
    func updateFilters(vc: RMBTHistoryFilterViewController)
}
///
class RMBTHistoryFilterViewController: UITableViewController {

    ///
    var allFilters: HistoryFilterType!

    ///
    var activeFilters: HistoryFilterType!

    weak var delegate: RMBTHistoryFilterViewControllerDelegate?
    ///
    private var keys: [String]!

    ///
    private var activeIndexPaths = Set<IndexPath>()

    ///
    private var allIndexPaths = Set<IndexPath>()

    //
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return RMBTColorManager.statusBarStyle
    }

    ///
    override func viewDidLoad() {
        super.viewDidLoad()

        // Add long tap gesture recognizer to table view. On long tap, select tapped filter, while deselecting
        // all other filters from that group.
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(tableViewDidReceiveLongPress(gestureRecognizer:)))
        longPressGestureRecognizer.minimumPressDuration = 0.8 // seconds

        tableView?.addGestureRecognizer(longPressGestureRecognizer)

        assert(allFilters != nil)

        keys = [String](allFilters.keys)

        for (i, key) in keys.enumerated() {
            if let values = allFilters[key] {
                for j in values.indices {
                    let ip = IndexPath(row: j, section: i)
                    //allIndexPaths.addObject(ip)
                    allIndexPaths.insert(ip)
                    if activeFilters != nil {
                        if let activeKeyValues = activeFilters[key] {
                            if activeKeyValues.firstIndex(of: values[j]) != nil {
                                //activeIndexPaths.addObject(ip)
                                activeIndexPaths.insert(ip)
                            }
                        }
                    } else {
                        //activeIndexPaths.addObject(ip)
                        activeIndexPaths.insert(ip)
                    }
                }
            }
        }
        
        self.applyColorScheme()
        self.updateColorForNavigationBarAndTabBar()
        
        self.addStandardDoneButton()
    }
    
    override func backAction() {
        self.storeFilters()
        if UIDevice.isDeviceTablet(),
            let tabBarController = UIApplication.shared.delegate?.tabBarController() {
            self.delegate?.updateFilters(vc: self)
        } else {
            self.delegate?.updateFilters(vc: self)
            if self.navigationController?.viewControllers.count ?? 0 > 1 {
                super.popAction()
            } else {
                super.backAction()
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
        self.tableView.reloadData()
    }
    
    func applyColorScheme() {
        tableView.backgroundColor = RMBTColorManager.tableViewBackground
        tableView.separatorColor = RMBTColorManager.tableViewSeparator
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func applyColorScheme(for cell: UITableViewCell) {
        cell.textLabel?.textColor = RMBTColorManager.tintColor
        cell.backgroundColor = RMBTColorManager.cellBackground
        cell.tintColor = RMBTColorManager.tintColor
    }
    
    func storeFilters() {
        if activeIndexPaths == allIndexPaths || activeIndexPaths.count == 0 {
            // Everything/nothing was selected, set nil
            activeFilters = nil
        } else {
            // Re-calculate active filters
            var result = HistoryFilterType()
            
            for ip in activeIndexPaths {
                let key = keys[ip.section]
                let value = allFilters[key]![ip.row] // !
                
                var entries = result[key] ?? [String]()
                
                entries.append(value)
                
                result[key] = entries
            }
            
            activeFilters = result
        }
    }

// MARK: Table view data source
    
    ///
    override func numberOfSections(in tableView: UITableView) -> Int {
        return keys.count
    }

    ///
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let key = keys[section]
        return allFilters[key]!.count // !
    }

    ///
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: "filter_cell", for: indexPath)

        if cell != nil {
            let key = keys[indexPath.section]
            let filters = allFilters[key]! // !
            let filter = filters[indexPath.row]

            cell.textLabel?.text = filter

            let active: Bool = activeIndexPaths.contains(indexPath)
            cell.accessoryType = active ? .checkmark : .none

            self.applyColorScheme(for: cell)
            //cell.accessoryView?.tintColor = UIColor.blueColor()
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var title: String? = nil
        let key = keys[section]
        
        if key == "networks" {
            title = L("history.filter.networktype")
        } else if key == "devices" {
            title = L("history.filter.device")
        } else {
            title = key
        }
        let header = RMBTSettingsTableViewHeader.view()
        header?.titleLabel.text = title
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if activeIndexPaths.contains(indexPath) {
            let count = activeIndexPaths.filter({ $0.section == indexPath.section }).count
            //If in section last active item then we can't remove it
            if count > 1 {
                activeIndexPaths.remove(indexPath)
            }
        } else {
            activeIndexPaths.insert(indexPath)
        }
        
        tableView.reloadData()
    }

// MARK: Long press handler

    ///
    @objc func tableViewDidReceiveLongPress(gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            let p: CGPoint = gestureRecognizer.location(in: tableView)

            if let tappedIndexPath = self.tableView.indexPathForRow(at: p) {

                // Deactivate all entries in this section, exception long-tapped row
                for i in allIndexPaths where i.section == tappedIndexPath.section {
                    activeIndexPaths.remove(i)
                }

                activeIndexPaths.insert(tappedIndexPath)
                tableView?.reloadData()
            }
        }
    }

// MARK: IBActions

    ///
    @IBAction func clear() {
        activeIndexPaths = activeIndexPaths.union(allIndexPaths)
        //activeIndexPaths.setSet(allIndexPaths)

        tableView?.reloadData()
    }
}

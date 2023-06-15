//
//  RMBTHistoryResultDetailsViewController.swift
//  RMBT
//
//  Created by Benjamin Pucher on 18.09.14.
//  Copyright © 2014 SPECURE GmbH. All rights reserved.
//

import Foundation

///
class RMBTHistoryResultDetailsViewController: UITableViewController {

    ///
    private class HistoryResultDetailTableViewCell: UITableViewCell {

        ///
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: .value1, reuseIdentifier: reuseIdentifier)
        }

        ///
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        }
    }

    ///
    private class HistoryResultDetailSubtitleTableViewCell: UITableViewCell {

        ///
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        }

        ///
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        }
    }

    //

    ///
    var historyResult: RMBTHistoryResult?

    //

    ///
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.formatHistoryResultPageDetailTitle()

        tableView.register(HistoryResultDetailTableViewCell.self, forCellReuseIdentifier: "history_result_detail") // style value1
        tableView.register(HistoryResultDetailSubtitleTableViewCell.self, forCellReuseIdentifier: "history_result_detail_subtitle") // style subtitle

        //NSParameterAssert(self.historyResult)
        if let historyResult = self.historyResult {
            historyResult.ensureFullDetails {
                self.tableView.reloadData()
            }
        }

        tableView.accessibilityLabel = "Test Result Detail Table View"
        self.applyColorScheme()
        self.updateColorForNavigationBarAndTabBar()
        if UIDevice.isDeviceTablet() {
            self.addStandardBackButton()
        }
    }
    
    @objc override func popAction() {
        if UIDevice.isDeviceTablet(),
            let tabBarController = UIApplication.shared.delegate?.tabBarController() {
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
        self.tableView.reloadData()
    }
    
    func applyColorScheme() {
        self.tableView.backgroundColor = RMBTColorManager.tableViewBackground
        self.tableView.separatorColor = RMBTColorManager.tableViewSeparator
        self.tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func applyColorScheme(for cell: UITableViewCell) {
        cell.textLabel?.textColor = RMBTColorManager.tintColor
        cell.detailTextLabel?.textColor = RMBTColorManager.textColor
        cell.backgroundColor = RMBTColorManager.cellBackground
        cell.tintColor = RMBTColorManager.tintColor
    }
    ///
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.historyResult?.dataState != .full ? 0 : 1 // TODO: historyResult!
    }
    
    ///
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.historyResult?.fullDetailsItems.count ?? 0 // TODO: historyResult!
    }
    
    ///
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell!

        if let historyResult = self.historyResult {
            let item = historyResult.fullDetailsItems[indexPath.row] as RMBTHistoryResultItem

            if let t = item.title, item.value != nil {
                if t.count > 25 || item.convertValueToString().count > 25 {
                    cell = tableView.dequeueReusableCell(withIdentifier: "history_result_detail_subtitle", for: indexPath)
                    
                    //cell.detailTextLabel?.textColor = UIColor.gray
                    cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 16)
                } else {
                    cell = tableView.dequeueReusableCell(withIdentifier: "history_result_detail", for: indexPath)
                }
                
                cell.textLabel?.text = item.title
                cell.textLabel?.numberOfLines = 3
                cell.textLabel?.minimumScaleFactor = 0.7
                cell.textLabel?.adjustsFontSizeToFitWidth = true
                cell.applyTintColor()
                // cell.textLabel?.lineBreakMode = NSLineBreakMode.ByTruncatingMiddle
                
                cell.detailTextLabel?.text = item.convertValueToString()
                cell.detailTextLabel?.numberOfLines = 3
                cell.detailTextLabel?.adjustsFontSizeToFitWidth = true
                cell.detailTextLabel?.minimumScaleFactor = 0.7
                cell.applyResultColor()
                // cell.detailTextLabel?.lineBreakMode = NSLineBreakMode.ByCharWrapping
            } else {
            
                // shold not happen
                cell = UITableViewCell()
            }

        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "history_result_detail", for: indexPath) // needed?
        }

        self.applyColorScheme(for: cell)
        cell.selectionStyle = .none
        return cell
    }

    ///
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let historyResult = self.historyResult {
            let item: RMBTHistoryResultItem = historyResult.fullDetailsItems[indexPath.row] as RMBTHistoryResultItem

            return UITableViewCell.rmbtApproximateOptimalHeightForText(item.title, detailText: item.convertValueToString())
        }

        return 0
    }

}

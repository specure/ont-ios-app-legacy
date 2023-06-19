//
//  RMBTPopupContentView.swift
//  RMBT
//
//  Created by Tomáš Baculák on 21/01/15.
//  Copyright © 2015 SPECURE GmbH. All rights reserved.
//

import UIKit

@objc protocol RMBTPopupContentViewDelegate {
    
    func indexHasBeenPicked(_ index: IndexPath)
}

///
class RMBTPopupContentView: UIView, UITableViewDataSource, UITableViewDelegate {

    ///
    var title = UILabel()

    ///
    var itemsTable = UITableView()

    ///
    var itemsNames = [String]()

    ///
    var itemsValues = [String?]()

    ///
    let contentViewAlpha: CGFloat = 0.9
    
    //
    var selectedCell = IndexPath(row: 0, section: 0)
    
    //
    weak var delegate: RMBTPopupContentViewDelegate?

    //

    ///
    required init? (coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    ///
    override init (frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    ///
    func commonInit() {
        backgroundColor = RMBT_TINT_COLOR
        alpha = contentViewAlpha

        let theTitleLabelHeight: CGFloat = 30.0
        
        itemsTable.backgroundColor = RMBT_TINT_COLOR
        itemsTable.frame = CGRect(x: 0, y: theTitleLabelHeight, width: boundsWidth, height: boundsHeight - 2 * theTitleLabelHeight)
        //
        itemsTable.delegate = self
        itemsTable.dataSource = self
        itemsTable.allowsSelection = true
        itemsTable.allowsMultipleSelection = false
        itemsTable.resignFirstResponder()
        //
        addSubview(itemsTable)

        title.frame = CGRect(x: 0, y: 0, width: boundsWidth, height: theTitleLabelHeight)
        title.textColor = .white
        title.textAlignment = .center

        addSubview(title)
        
        // strangly does ony the first half of the pop up
        // self.layer.cornerRadius = 14
        
        let configuration = RMBTConfigFabric.config(with: RMBTConfigurationIdentifier)
        if configuration.RMBT_VERSION == 3 {
            self.applyColorScheme()
        }
        
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        guard UIApplication.shared.applicationState == .inactive else {
            return
        }
        
        self.applyColorScheme()
    }
    
    func applyColorScheme() {
        self.backgroundColor = RMBTColorManager.navigationBarBackground
        self.title.textColor = RMBTColorManager.navigationBarTitleColor
        self.itemsTable.backgroundColor = RMBTColorManager.background
    }

// MARK: - Navigation UITableViewDataSource / UITableViewDelegate

    ///
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    ///
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemsNames.count
    }

    ///
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = RMBTPUTableViewCell(style: .default, reuseIdentifier: "aCell")

        let configuration = RMBTConfigFabric.config(with: RMBTConfigurationIdentifier)
        if configuration.RMBT_VERSION == 3 {
            cell.applyColorScheme()
        }
        cell.nameLabel.text = itemsNames[indexPath.row]
        cell.valueLabel?.text = itemsValues[indexPath.row]

        cell.valueLabel?.adjustsFontSizeToFitWidth = true
        cell.valueLabel?.minimumScaleFactor = 0.5
        
        cell.isCurrent = (selectedCell.row == indexPath.row)
        cell.selectionStyle = .default
        
        return cell
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
    }
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return indexPath
    }
    /// ???
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.indexHasBeenPicked(indexPath)
    }
}

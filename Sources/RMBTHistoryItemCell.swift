//
//  RMBTHistoryItemCell.swift
//  RMBT
//
//  Created by Tomáš Baculák on 27/01/15.
//  Copyright © 2015 SPECURE GmbH. All rights reserved.
//

import UIKit

///
class RMBTHistoryItemCell: UITableViewCell {

    ///
    @IBOutlet var titleLabel: UILabel!

    ///
    @IBOutlet var detailLabel: UILabel!
    
    ///
    @IBOutlet var statusView: UIView!

    //

    ///
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        self.commonInit()
    }

    ///
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }

    ///
    private func commonInit() {
        // Load xib file
        if let nibView = Bundle.main.loadNibNamed("RMBTHistoryItemCell", owner: self, options: nil)?[0] as? UITableViewCell {
            
            nibView.frame = self.bounds
            addSubview(nibView)
            self.selectionStyle = .none
        }
        
    }

    ///
    func setItem(item: RMBTHistoryResultItem) {
        titleLabel.text = item.title
        detailLabel.text = item.convertValueToString()

        var statusColor = UIColor.clear

        if let cl = item.classification {
            switch cl {
            case 1: statusColor = RMBT_CHECK_INCORRECT_COLOR
            case 2: statusColor = RMBT_CHECK_MEDIOCRE_COLOR
            case 3: statusColor = RMBT_CHECK_CORRECT_COLOR
            default: break
            }
        }
        
        statusView.backgroundColor = statusColor
    }
    
    func set(title: String, subtitle: String, type: UITableViewCell.AccessoryType = .none) {
        self.accessoryType = type
        self.titleLabel.text = title
        self.detailLabel.text = subtitle
        statusView.backgroundColor = UIColor.clear
    }

    /// Set to YES when displayed in map annotation
    func setEmbedded(embedded: Bool) {
        if embedded {
            let font: UIFont = UIFont.systemFont(ofSize: 15)

            self.textLabel?.font = font
            self.detailTextLabel?.font = font
            self.detailTextLabel?.numberOfLines = 2
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
        self.backgroundColor = self.isHighlighted ? RMBTColorManager.highlightHistoryCellColor : RMBTColorManager.cellBackground
        self.titleLabel.textColor = self.isHighlighted ? RMBTColorManager.historyTextColor : RMBTColorManager.tintColor
        self.detailTextLabel?.textColor = RMBTColorManager.textColor
        self.detailLabel?.textColor = RMBTColorManager.textColor
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.setHighlighted(selected, animated: animated)
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        let duration = highlighted ? 0.0 : 0.3
        UIView.animate(withDuration: duration) {
            self.applyColorScheme()
        }
    }
}

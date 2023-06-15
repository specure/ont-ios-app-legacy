//
//  RMBTPUTableViewCell.swift
//  RMBT
//
//  Created by Tomáš Baculák on 22/01/15.
//  Copyright © 2015 SPECURE GmbH. All rights reserved.
//

import UIKit

///
class RMBTPUTableViewCell: UITableViewCell {

    static let ID = "RMBTPUTableViewCell"

    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var valueLabel: UILabel!
    @IBOutlet weak var selectedView: UIView!

    var isCurrent: Bool = false {
        didSet {
            selectedView.isHidden = !isCurrent
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        nameLabel?.textColor = RMBT_TINT_COLOR
        valueLabel?.applyResultColor()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        guard UIApplication.shared.applicationState == .inactive else {
            return
        }
        
        self.applyColorScheme()
    }
    
    func applyColorScheme() {
        self.nameLabel.textColor = RMBTColorManager.tintColor
        self.valueLabel.textColor = RMBTColorManager.textColor
        self.backgroundColor = RMBTColorManager.cellBackground
        self.contentView.backgroundColor = RMBTColorManager.cellBackground
        self.selectedView.backgroundColor = RMBTColorManager.cellBackground
    }
}

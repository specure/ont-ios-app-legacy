//
//  RMBTSwitcherCell.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 7/16/18.
//  Copyright © 2018 SPECURE GmbH. All rights reserved.
//

import UIKit

class RMBTSwitcherCell: UITableViewCell {

    @IBOutlet weak var valueSwitch: UISwitch!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        guard UIApplication.shared.applicationState == .inactive else {
            return
        }
        
        self.applyColorScheme()
    }
    
    func applyColorScheme() {
        self.titleLabel.textColor = RMBTColorManager.textColor
        self.subtitleLabel.textColor = RMBTColorManager.tintColor
        self.backgroundColor = RMBTColorManager.cellBackground
        self.valueSwitch.tintColor = RMBTColorManager.switchBackgroundColor
        self.valueSwitch.onTintColor = RMBTColorManager.tintColor
        self.valueSwitch.thumbTintColor = RMBTColorManager.thumbTintColor
        self.valueSwitch.backgroundColor = RMBTColorManager.switchBackgroundColor
        self.valueSwitch.layer.cornerRadius = self.valueSwitch.frame.size.height / 2
    }
    
}

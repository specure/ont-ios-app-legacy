//
//  RMBTLoopModeAlertCell.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 11/17/18.
//  Copyright © 2018 SPECURE GmbH. All rights reserved.
//

import UIKit

class RMBTLoopModeAlertCell: UITableViewCell {

    static let ID = "RMBTLoopModeAlertCell"
    
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    
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
        self.titleLabel.textColor = RMBTColorManager.tintColor
        self.separatorView.backgroundColor = RMBTColorManager.tableViewSeparator
    }
    
}

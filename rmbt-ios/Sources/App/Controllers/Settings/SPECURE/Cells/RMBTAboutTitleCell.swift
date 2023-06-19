//
//  RMBTAboutTitleCell.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 11/6/18.
//  Copyright © 2018 SPECURE GmbH. All rights reserved.
//

import UIKit

class RMBTAboutTitleCell: UICollectionViewCell {

    static let ID = "RMBTAboutTitleCell"
    
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
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
    }
}

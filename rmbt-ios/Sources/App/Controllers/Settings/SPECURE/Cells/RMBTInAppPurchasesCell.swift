//
//  RMBTInAppPurchasesCell.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 7/16/18.
//  Copyright © 2018 SPECURE GmbH. All rights reserved.
//

import UIKit

class RMBTInAppPurchasesCell: UITableViewCell {

    @IBOutlet weak var removeAdsButton: UIButton!
    @IBOutlet weak var restoreButton: UIButton!
    
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
        self.backgroundColor = RMBTColorManager.cellBackground
        self.removeAdsButton.layer.borderColor = RMBTColorManager.tintColor.cgColor
        self.removeAdsButton.setTitleColor(RMBTColorManager.tintColor, for: .normal)
        self.removeAdsButton.setTitleColor(RMBTColorManager.tintColor.withAlphaComponent(0.3), for: .disabled)
        
        self.restoreButton.layer.borderColor = RMBTColorManager.tintColor.cgColor
        self.restoreButton.setTitleColor(RMBTColorManager.tintColor, for: .normal)
    }
    
}

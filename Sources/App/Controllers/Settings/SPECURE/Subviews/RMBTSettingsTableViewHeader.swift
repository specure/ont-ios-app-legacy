//
//  RMBTSettingsTableViewHeader.swift
//  RMBT_ONT
//
//  Created by Sergey Glushchenko on 8/26/18.
//  Copyright © 2018 SPECURE GmbH. All rights reserved.
//

import UIKit

class RMBTSettingsTableViewHeader: UIView {

    @IBOutlet weak var titleLabel: UILabel!
    
    class func view() -> RMBTSettingsTableViewHeader? {
        let nib = UINib(nibName: "RMBTSettingsTableViewHeader", bundle: nil)
        return nib.instantiate(withOwner: self, options: nil).first as? RMBTSettingsTableViewHeader
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        guard UIApplication.shared.applicationState == .inactive else {
            return
        }
        
        self.applyColorScheme()
    }
    
    func applyColorScheme() {
        self.titleLabel.textColor = RMBTColorManager.settingsHeaderColor
    }

}

//
//  RMBTTextfieldCell.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 7/16/18.
//  Copyright © 2018 SPECURE GmbH. All rights reserved.
//

import UIKit

class RMBTTextfieldCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueTextField: UITextField!
    
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
        self.valueTextField.textColor = RMBTColorManager.tintColor
        self.valueTextField.attributedPlaceholder = self.valueTextField.placeholder?.attributedPlaceholder(RMBTColorManager.tintColor.withAlphaComponent(0.3))
        self.backgroundColor = RMBTColorManager.cellBackground
    }
    
}

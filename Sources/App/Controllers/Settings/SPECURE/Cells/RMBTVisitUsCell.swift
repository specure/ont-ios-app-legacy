//
//  RMBTVisitUsCell.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 11/6/18.
//  Copyright © 2018 SPECURE GmbH. All rights reserved.
//

import UIKit

class RMBTVisitUsCell: UICollectionViewCell {

    static let ID = "RMBTVisitUsCell"
    
    @IBOutlet weak var arrowRightImageView: UIImageView!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var button: UIButton!
    
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
        self.arrowRightImageView.image = self.arrowRightImageView.image?.withRenderingMode(.alwaysTemplate)
        self.arrowRightImageView.tintColor = RMBTColorManager.navigationBarTitleColor
        self.button.backgroundColor = RMBTColorManager.tintColor
        self.button.setTitleColor(RMBTColorManager.navigationBarTitleColor, for: .normal)
        self.subtitleLabel.textColor = RMBTColorManager.textColor
    }

}

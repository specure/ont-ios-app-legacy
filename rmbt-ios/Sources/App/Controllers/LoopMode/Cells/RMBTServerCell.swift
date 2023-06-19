//
//  RMBTServerCell.swift
//  RMBT_ONT
//
//  Created by Sergey Glushchenko on 7/22/18.
//  Copyright © 2018 SPECURE GmbH. All rights reserved.
//

import UIKit

class RMBTServerCell: UITableViewCell {

    static let ID = "RMBTServerCell"
    
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var serverNameLabel: UILabel!
    
    private var selectedColor: UIColor = RMBTColorManager.tintColor
    private var normalColor: UIColor = UIColor.black
    
    var isCurrent: Bool = false {
        didSet {
            self.serverNameLabel.textColor = isCurrent ? self.selectedColor : self.normalColor
            self.distanceLabel.textColor = isCurrent ? self.selectedColor : self.normalColor
        }
    }
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
        self.tintColor = RMBTColorManager.tintColor
        self.backgroundColor = RMBTColorManager.cellBackground
        self.selectedColor = RMBTColorManager.tintColor
        self.normalColor = RMBTColorManager.loopModeValueColor
    }
    
}

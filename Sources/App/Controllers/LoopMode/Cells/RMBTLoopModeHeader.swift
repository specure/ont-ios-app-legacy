//
//  RMBTLoopModeHeader.swift
//  RMBT_ONT
//
//  Created by Sergey Glushchenko on 8/2/18.
//  Copyright © 2018 SPECURE GmbH. All rights reserved.
//

import UIKit

class RMBTLoopModeHeader: UIView {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var currentLabel: UILabel!
    @IBOutlet weak var medianLabel: UILabel!
    
    class func view() -> RMBTLoopModeHeader? {
        let nib = UINib(nibName: "RMBTLoopModeHeader", bundle: nil)
        return nib.instantiate(withOwner: self, options: nil).first as? RMBTLoopModeHeader
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.titleLabel.text = L("loopmode.test.header.measurement")
        self.currentLabel.text = L("loopmode.test.header.current")
        self.medianLabel.text = L("loopmode.test.header.median")
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        guard UIApplication.shared.applicationState == .inactive else {
            return
        }
        
        self.applyColorScheme()
    }

    func applyColorScheme() {
        backgroundColor = RMBTColorManager.cellBackground
        titleLabel.textColor = RMBTColorManager.testValuesTitleColor
        currentLabel.textColor = RMBTColorManager.testValuesValueColor
        medianLabel.textColor = RMBTColorManager.testValuesValueColor
    }
}

//
//  RMBTLoopModeHeader.swift
//  RMBT_ONT
//
//  Created by Sergey Glushchenko on 8/2/18.
//  Copyright © 2018 SPECURE GmbH. All rights reserved.
//

import UIKit

class RMBTTestHeader: UIView {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var currentLabel: UILabel!
    
    class func view() -> RMBTTestHeader? {
        let nib = UINib(nibName: "RMBTTestHeader", bundle: nil)
        return nib.instantiate(withOwner: self, options: nil).first as? RMBTTestHeader
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.titleLabel.text = L("loopmode.test.header.measurement")
        self.currentLabel.text = L("loopmode.test.header.current")
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
        titleLabel.textColor = RMBTColorManager.testHeaderValuesColor
        currentLabel.textColor = RMBTColorManager.testHeaderValuesColor
    }
}

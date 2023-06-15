//
//  RMBTInputView.swift
//  RMBT_SPECURE
//
//  Created by Sergey Glushchenko on 7/15/18.
//  Copyright © 2018 SPECURE GmbH. All rights reserved.
//

import UIKit

class RMBTInputView: UIView {

    @IBOutlet weak var doneButton: UIButton!

    class func view() -> RMBTInputView? {
        let nib = UINib(nibName: "RMBTInputView", bundle: nil)
        return nib.instantiate(withOwner: self, options: nil).first as? RMBTInputView
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.doneButton.setTitleColor(RMBT_TINT_COLOR, for: .normal)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        guard UIApplication.shared.applicationState == .inactive else {
            return
        }
        
        self.applyColorScheme()
    }
    
    func applyColorScheme() {
        self.backgroundColor = RMBTColorManager.background
        self.doneButton.setTitleColor(RMBTColorManager.tintColor, for: .normal)
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}

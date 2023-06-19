//
//  RMBTButton.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 12/1/17.
//  Copyright © 2017 SPECURE GmbH. All rights reserved.
//

import UIKit

class RMBTButton: UIButton {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    override func awakeFromNib() {
        super.awakeFromNib()
        self.titleLabel?.numberOfLines = 0
        self.titleLabel?.textAlignment = .center
    }
}

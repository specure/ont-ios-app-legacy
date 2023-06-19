//
//  RMBTCirculeImageView.swift
//  RMBT_ONT
//
//  Created by Sergey Glushchenko on 12/20/17.
//  Copyright © 2017 SPECURE GmbH. All rights reserved.
//

import UIKit

class RMBTCirculeImageView: UIImageView {

    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.clipsToBounds = true
        self.layer.cornerRadius = self.bounds.width / 2.0
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}

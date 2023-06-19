//
//  RMBTCircleButton.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 10/21/18.
//  Copyright © 2018 SPECURE GmbH. All rights reserved.
//

import UIKit

class RMBTCircleButton: UIButton {

    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.clipsToBounds = true
        self.layer.cornerRadius = self.bounds.height / 2.0
    }

}

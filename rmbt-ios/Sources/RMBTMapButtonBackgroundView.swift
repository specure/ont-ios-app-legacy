//
//  RMBTMapButtonBackgroundView.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 10.03.2020.
//  Copyright © 2020 SPECURE GmbH. All rights reserved.
//

import UIKit

class RMBTMapButtonBackgroundView: UIView {

    override func layoutSubviews() {
        super.layoutSubviews()
        self.makeFancyCircles(clockWise: false)
    }
}

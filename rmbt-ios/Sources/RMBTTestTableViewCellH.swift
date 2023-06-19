//
//  RMBTTableViewCell_H.swift
//  RMBT
//
//  Created by Tomáš Baculák on 29/01/15.
//  Copyright © 2015 SPECURE GmbH. All rights reserved.
//

import UIKit

///
class RMBTTestTableViewCellH: UITableViewCell {

    ///
    @IBOutlet var titleLabel: UILabel!

    ///
    @IBOutlet var valueLabel: UILabel!

    ///
    override func awakeFromNib() {
        super.awakeFromNib()

        titleLabel.textColor = INITIAL_SCREEN_TEXT_COLOR
        valueLabel.textColor = INITIAL_SCREEN_TEXT_COLOR
    }
}

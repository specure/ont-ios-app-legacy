//
//  RMBTTestResultBackView.swift
//  RMBT
//
//  Created by Tomas Baculák on 09/08/2017.
//  Copyright © 2017 SPECURE GmbH. All rights reserved.
//

import UIKit

class RMBTTestResultBackView: UIView {
    
    //
    @IBOutlet var graphView: RMBTSpeedGraphView?
    //
    @IBOutlet var titleLabel: UILabel?
    //
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        graphView?.isMeasuresIncluded = false
        titleLabel?.textColor = RMBT_TINT_COLOR
        
    }
}

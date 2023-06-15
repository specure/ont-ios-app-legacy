//
//  RMBTInfoTVCell.swift
//  RMBT
//
//  Created by Tomas Baculák on 19/12/2016.
//  Copyright © 2016 SPECURE GmbH. All rights reserved.
//

import UIKit

class RMBTInfoTVCell: UITableViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.textLabel?.formatStringsInfo(self.tag)
        
        // ONT
        if !RMBT_VERSION_NEW {
        
            applyTintColor()
            applyResultColor()
            
        }
    }
    
}

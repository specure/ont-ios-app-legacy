//
//  RMBTMenuTVCell.swift
//  RMBT
//
//  Created by Tomas Baculák on 19/12/2016.
//  Copyright © 2016 SPECURE GmbH. All rights reserved.
//

import UIKit

class RMBTMenuTVCell: UITableViewCell {
    
    @IBOutlet var menuItemLabel: UILabel!
    
    @IBOutlet var menuItemIcon: UIImageView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        menuItemLabel?.textColor = NAVIGATION_TEXT_COLOR
        menuItemLabel?.highlightedTextColor = NAVIGATION_TEXT_COLOR
        menuItemLabel.formatStringsMenu(self.tag)
        
        if NAVIGATION_USE_TINT_COLOR {
            menuItemIcon?.image = menuItemIcon?.image?.tintedImageUsingColor(tintColor: NAVIGATION_TEXT_COLOR)
        }
        
        backgroundColor = NAVIGATION_BACKGROUND_COLOR
        
        if let selectedBackgroundColor = NAVIGATION_SELECTED_BACKGROUND_VIEW_COLOR {
            selectedBackgroundView = UIView()
            selectedBackgroundView?.backgroundColor = selectedBackgroundColor
        }
    }
}

//
//  RMBTHorizontalButton.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 12/11/17.
//  Copyright © 2017 SPECURE GmbH. All rights reserved.
//

import UIKit

class RMBTHorizontalButton: UIButton {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    override var intrinsicContentSize: CGSize {
        if let text = self.title(for: .normal),
            let font = self.titleLabel?.font {
            let size = CGSize(width: CGFloat(MAXFLOAT), height: self.bounds.size.height)
            let attributedString = NSMutableAttributedString(string: text)
            
            attributedString.addAttribute(.font, value: font, range: NSRange(location: 0, length: text.count))
            
            var rect = attributedString.boundingRect(with: size, options: .usesLineFragmentOrigin, context: nil)
            rect.size.height = self.bounds.height
            rect.size.width += 25
            return CGSize(width: rect.size.width, height: UIView.noIntrinsicMetric)
        }
        
        return super.intrinsicContentSize
    }
}

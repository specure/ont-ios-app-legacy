//
//  RMBTGradientButton.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 12/5/18.
//  Copyright © 2018 SPECURE GmbH. All rights reserved.
//

import UIKit

class RMBTGradientButton: UIButton {
    
    private let gradient: CAGradientLayer = CAGradientLayer()
    var colors: [UIColor] = []
    var locations: [NSNumber] = [0.0, 1.0]
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradient.removeAllAnimations()
        
        gradient.frame = self.bounds
        gradient.colors = colors.map { $0.cgColor }
        gradient.locations = locations
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
        
        let sublayers = self.layer.sublayers ?? []
        if sublayers.contains(gradient) == false {
            self.layer.insertSublayer(gradient, at: 0)
        }
        
        gradient.setNeedsDisplay()
    }
}

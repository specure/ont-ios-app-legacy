//
//  RMBTGradientView.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 12/5/18.
//  Copyright © 2018 SPECURE GmbH. All rights reserved.
//

import UIKit

class RMBTGradientView: UIView {

    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    
    var colors: [UIColor] = [] {
        didSet {
            guard let gradient = self.layer as? CAGradientLayer else {
                return
            }
            gradient.colors = colors.map{ $0.cgColor }
        }
    }
    var locations: [NSNumber] = [0.0, 1.0] {
        didSet {
            guard let gradient = self.layer as? CAGradientLayer else {
                return
            }
            gradient.locations = locations
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.initGradient()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.initGradient()
    }
    
    func initGradient() {
        guard let gradient = self.layer as? CAGradientLayer else {
            return
        }
        gradient.locations = locations
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
    }
}

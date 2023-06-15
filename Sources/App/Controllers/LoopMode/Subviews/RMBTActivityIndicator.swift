//
//  RMBTActivityIndicator.swift
//  RMBT_ONT
//
//  Created by Sergey Glushchenko on 8/18/18.
//  Copyright © 2018 SPECURE GmbH. All rights reserved.
//

import UIKit

class RMBTActivityIndicator: UIView {

    let imageView: UIImageView = UIImageView(image: UIImage(named: "loading")?.withRenderingMode(.alwaysTemplate))
    var displayLink: CADisplayLink!
    
    var currentValue: CGFloat = 0.0 {
        didSet {
            self.imageView.transform = CGAffineTransform(rotationAngle: 0)
            self.imageView.transform = CGAffineTransform(rotationAngle: currentValue)
        }
    }
    
    var speed: CGFloat = CGFloat.pi * 2.0
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initialize()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initialize()
    }
    
    func initialize() {
        self.addSubview(self.imageView)
        self.imageView.frame = self.bounds
        self.imageView.tintColor = RMBTColorManager.tintColor
        self.displayLink = CADisplayLink(target: self, selector: #selector(RMBTActivityIndicator.updateTick(_:)))
        self.displayLink.add(to: RunLoop.main, forMode: RunLoop.Mode.default)
    }
    
    @objc func updateTick(_ sender: CADisplayLink) {
        currentValue += speed * CGFloat(sender.duration)
        
        if currentValue >= CGFloat.pi * 2 {
            currentValue = 0.0
        }
    }
    
    func stopAnimation() {
        self.displayLink.remove(from: RunLoop.main, forMode: RunLoop.Mode.default)
        self.displayLink.invalidate()
        self.displayLink = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
//        self.imageView.frame = self.bounds
    }
}

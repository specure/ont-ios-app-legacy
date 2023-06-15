//
//  RMBTGaugeProgressBackgroundView.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 11/10/17.
//  Copyright © 2017 SPECURE GmbH. All rights reserved.
//

import UIKit

class RMBTGaugeSpeedBackgroundView: UIView {
    var color = TEST_GAUGE_TINT_COLOR
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    
    var viewScale: CGFloat { return self.bounds.width / 160.0 }
    
    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }

        let color = self.color
        let lineWidth: CGFloat = 9 * viewScale
        let center = CGPoint(x: self.bounds.width / 2, y: self.bounds.height / 2)
        let radius = self.bounds.width / 2 - lineWidth / 2
        
        let startAngle = (1 * CGFloat(Double.pi)) / 180.0
        let endAngle = (305 * CGFloat(Double.pi)) / 180.0

        self.drawArc(at: ctx, center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, lineWidth: lineWidth, color: color)
    }
 
    func drawArc(at context: CGContext, center: CGPoint, radius: CGFloat, startAngle: CGFloat, endAngle: CGFloat, lineWidth: CGFloat,  color: UIColor?) {
        let path = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        
        path.lineWidth = lineWidth
        color?.set()
        path.stroke()
    }
}

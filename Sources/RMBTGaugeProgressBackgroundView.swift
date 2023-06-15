//
//  RMBTGaugeProgressBackgroundView.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 11/10/17.
//  Copyright © 2017 SPECURE GmbH. All rights reserved.
//

import UIKit

class RMBTGaugeProgressBackgroundView: UIView {

    let initString = NSLocalizedString("Init", comment: "InitPingDownload")
    let pingString = NSLocalizedString("Ping", comment: "Ping")
    let downloadString = NSLocalizedString("Download", comment: "Download")
    let uploadString = NSLocalizedString("Upload", comment: "Upload")
    
    var font = UIFont(name: MAIN_FONT, size: 9.0) ?? UIFont.systemFont(ofSize: 9)
    var color = TEST_GAUGE_TINT_COLOR
    
    var viewScale: CGFloat { return self.bounds.width / 160.0 }
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        
        self.font = UIFont(name: MAIN_FONT, size: 9.0 * viewScale) ?? UIFont.systemFont(ofSize: 9 * viewScale)
        let color = self.color
        let lineWidth: CGFloat = 9 * viewScale
        let center = CGPoint(x: self.bounds.width / 2, y: self.bounds.height / 2)
        let radius = self.bounds.width / 2 - lineWidth / 2
        
        let startTextAngle = (155 * CGFloat(Double.pi)) / 180.0
        let startAngle = (-155 * CGFloat(Double.pi)) / 180.0
        let endAngle = (-118 * CGFloat(Double.pi)) / 180.0
        
        self.centreArcPerpendicular(initString, startAngle: startTextAngle)
        self.drawArc(at: ctx, center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, lineWidth: lineWidth, color: color)
        
        let startTextAngle2 = (114 * CGFloat(Double.pi)) / 180.0
        let startAngle2 = (-114 * CGFloat(Double.pi)) / 180.0
        let endAngle2 = (-84 * CGFloat(Double.pi)) / 180.0

        self.centreArcPerpendicular(pingString, startAngle: startTextAngle2)
        self.drawArc(at: ctx, center: center, radius: radius, startAngle: startAngle2, endAngle: endAngle2, lineWidth: lineWidth, color: color)

        let startTextAngle3 = (80 * CGFloat(Double.pi)) / 180.0
        let startAngle3 = (-80 * CGFloat(Double.pi)) / 180.0
        let endAngle3 = (20 * CGFloat(Double.pi)) / 180.0

        self.centreArcPerpendicular(downloadString, startAngle: startTextAngle3)
        self.drawArc(at: ctx, center: center, radius: radius, startAngle: startAngle3, endAngle: endAngle3, lineWidth: lineWidth, color: color)

        let startTextAngle4 = (-24 * CGFloat(Double.pi)) / 180.0
        let startAngle4 = (24 * CGFloat(Double.pi)) / 180.0
        let endAngle4 = (125 * CGFloat(Double.pi)) / 180.0

        self.centreArcPerpendicular(uploadString, startAngle: startTextAngle4, clockwise: false, textAlignment: .right)
        self.drawArc(at: ctx, center: center, radius: radius, startAngle: startAngle4, endAngle: endAngle4, lineWidth: lineWidth, color: color)
    }
 
    func drawArc(at context: CGContext, center: CGPoint, radius: CGFloat, startAngle: CGFloat, endAngle: CGFloat, lineWidth: CGFloat,  color: UIColor?) {
        let path = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        
        path.lineWidth = lineWidth
        color?.set()
        path.stroke()
    }
    
    /**
     This draws the self.text around an arc of radius r,
     with the text centred at polar angle theta
     */
    func centreArcPerpendicular(_ text: String = "", startAngle: CGFloat, clockwise: Bool = true, textAlignment: NSTextAlignment = .left) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.saveGState()
        let str = text
        let size = self.bounds.size
        let angle = startAngle
        let textOffset: CGFloat = 2.0 * viewScale
        context.translateBy(x: size.width / 2, y: size.height / 2)

        let radius = getRadiusForLabel(text) - textOffset
        let l = str.count
        
        let attributes: [NSAttributedString.Key: AnyObject] = [NSAttributedString.Key.font: font]
        
        let characters: [String] = str.map { String($0) } // An array of single character strings, each character in str
        var arcs: [CGFloat] = [] // This will be the arcs subtended by each character
        var totalArc: CGFloat = 0 // ... and the total arc subtended by the string
        
        // Calculate the arc subtended by each letter and their total
        for i in 0 ..< l {
            arcs += [chordToArc(characters[i].size(withAttributes: attributes).width, radius: radius)]
            totalArc += arcs[i]
        }
        
        // Are we writing clockwise (right way up at 12 o'clock, upside down at 6 o'clock)
        // or anti-clockwise (right way up at 6 o'clock)?
        let direction: CGFloat = clockwise ? -1 : 1
        let slantCorrection = clockwise ? -(CGFloat.pi / 2) : (CGFloat.pi / 2)
        
        // The centre of the first character will then be at
        // thetaI = theta - totalArc / 2 + arcs[0] / 2
        // But we add the last term inside the loop
        let align = textAlignment
        var thetaI = angle
        if align == NSTextAlignment.center {
            thetaI = angle - direction * totalArc / 2
        }
        if align == NSTextAlignment.right {
            thetaI = angle - direction * totalArc
        }
        
        for i in 0 ..< l {
            thetaI += direction * arcs[i] / 2
            // Call centre with each character in turn.
            // Remember to add +/-90º to the slantAngle otherwise
            // the characters will "stack" round the arc rather than "text flow"
            centre(text: characters[i], context: context, radius: radius, angle: thetaI, slantAngle: thetaI + slantCorrection)
            // The centre of the next character will then be at
            // thetaI = thetaI + arcs[i] / 2 + arcs[i + 1] / 2
            // but again we leave the last term to the start of the next loop...
            thetaI += direction * arcs[i] / 2
        }
        context.restoreGState()
    }
    
    func chordToArc(_ chord: CGFloat, radius: CGFloat) -> CGFloat {
        // *******************************************************
        // Simple geometry
        // *******************************************************
        return 2 * asin(chord / (2 * radius))
    }
    
    /**
     This draws the String str centred at the position
     specified by the polar coordinates (r, theta)
     i.e. the x= r * cos(theta) y= r * sin(theta)
     and rotated by the angle slantAngle
     */
    func centre(text str: String, context: CGContext, radius r: CGFloat, angle theta: CGFloat, slantAngle: CGFloat) {
        // Set the text attributes
        let color = self.color
        let attributes = [NSAttributedString.Key.foregroundColor: color ?? UIColor.black,
                          NSAttributedString.Key.font: self.font] as [NSAttributedString.Key: AnyObject]
        // Save the context
        context.saveGState()
        // Move the origin to the centre of the text (negating the y-axis manually)
        context.translateBy(x: r * cos(theta), y: -(r * sin(theta)))
        // Rotate the coordinate system
        context.rotate(by: -slantAngle)
        
        // Calculate the width of the text
        let offset: CGSize = str.size(withAttributes: attributes)
        // Move the origin by half the size of the text
        context.translateBy(x: -offset.width / 2, y: -offset.height / 2)
        
        // Draw the text
        let txtStr = NSString(string: str)
        txtStr.draw(at: CGPoint(x: 0, y: 0), withAttributes: attributes)
        
        // Restore the context
        context.restoreGState()
    }
    
    func getRadiusForLabel(_ text: String = "") -> CGFloat {
        // Imagine the bounds of this label will have a circle inside it.
        // The circle will be as big as the smallest width or height of this label.
        // But we need to fit the size of the font on the circle so make the circle a little
        // smaller so the text does not get drawn outside the bounds of the circle.
        let smallestWidthOrHeight = min(self.bounds.size.height, self.bounds.size.width)
        let heightOfFont = text.size(withAttributes: [NSAttributedString.Key.font: self.font]).height
        
        // Dividing the smallestWidthOrHeight by 2 gives us the radius for the circle.
        return (smallestWidthOrHeight/2) - heightOfFont
    }
}

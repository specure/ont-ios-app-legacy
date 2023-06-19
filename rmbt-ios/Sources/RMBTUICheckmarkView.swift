//
//  RMBTUICheckmarkView.swift
//  RMBT
//
//  Created by Benjamin Pucher on 27.03.15.
//  Copyright © 2015 SPECURE GmbH. All rights reserved.
//

import UIKit

///
public class RMBTUICheckmarkView: UIView {

    ///
    public var lineColor: UIColor = RMBT_RESULT_TEXT_COLOR {
        didSet {
            setNeedsDisplay()
        }
    }

    ///
    public var lineWidth: CGFloat?

    //

    ///
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    ///
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    ///
    private func commonInit() {
        backgroundColor = UIColor.clear
    }

    ///
    public override func draw(_ rect: CGRect) {
        //super.drawRect(rect)

        // Subframes
        let group = CGRect(x: bounds.minX - 1, y: bounds.minY - 1, width: bounds.width , height: bounds.height)

        // Bezier Drawing
        let bezierPath = UIBezierPath()

        bezierPath.move(to: CGPoint(x: group.minX + 0.27083 * group.width, y: group.minY + 0.54167 * group.height))
        bezierPath.addLine(to: CGPoint(x: group.minX + 0.41667 * group.width, y: group.minY + 0.68750 * group.height))
        bezierPath.addLine(to: CGPoint(x: group.minX + 0.75000 * group.width, y: group.minY + 0.35417 * group.height))

        bezierPath.lineCapStyle = .square

        lineColor.setStroke()
        bezierPath.lineWidth = lineWidth ?? bounds.size.width / 10
        bezierPath.stroke()
    }
}

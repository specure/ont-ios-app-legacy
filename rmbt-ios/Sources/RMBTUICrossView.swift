//
//  RMBTUICrossView.swift
//  RMBT
//
//  Created by Benjamin Pucher on 27.03.15.
//  Copyright © 2015 SPECURE GmbH. All rights reserved.
//

import UIKit

///
public class RMBTUICrossView: UIView {

    ///
    public var color: UIColor = RMBT_CHECK_INCORRECT_COLOR {
        didSet {
            setNeedsDisplay()
        }
    }

    ///
    public var viewSpacing: CGFloat = 6.5

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
        let bezierPath = UIBezierPath()

        let widthMinusViewSpacing = frame.size.width - viewSpacing
        let heighthMinusViewSpacing = frame.size.height - viewSpacing

        bezierPath.move(to: CGPoint(x: viewSpacing, y: viewSpacing))
        bezierPath.addLine(to: CGPoint(x: widthMinusViewSpacing, y: heighthMinusViewSpacing))

        bezierPath.move(to: CGPoint(x: viewSpacing, y: heighthMinusViewSpacing))
        bezierPath.addLine(to: CGPoint(x: widthMinusViewSpacing, y: viewSpacing))

        bezierPath.lineCapStyle = .square

        color.setStroke()
        bezierPath.lineWidth = lineWidth ?? bounds.size.width / 10
        bezierPath.stroke()
    }
}

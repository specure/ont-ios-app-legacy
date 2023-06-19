//
//  RMBTUITrafficView.swift
//  RMBT
//
//  Created by Benjamin Pucher on 27.03.15.
//  Copyright © 2015 SPECURE GmbH. All rights reserved.
//

import UIKit

///
public class RMBTUITrafficView: UIView {

    ///
    let DEFAULT_COLOR = INITIAL_VIEW_TRAFFIC_LOW_COLOR

    ///
    let SPEED_COLOR = INITIAL_VIEW_TRAFFIC_HIGH_COLOR

    ///
    private var lowSignal = false

    ///
    private var midSignal = false

    ///
    private var highSignal = false

    ///
    private var lineColor: UIColor!
    
    ///
    public var itemCount = 3 {
    
        didSet {
        
            setNeedsDisplay()
        }
    }

    ///
    public var viewOrientation: Bool = false {
        didSet {
            if viewOrientation {
                let transform: CGAffineTransform = CGAffineTransform(rotationAngle: deg2rad(x: 180))
                self.transform = transform
            }
        }
    }

    ///
    public var signalStrength: TrafficClassification = .NONE {
        didSet {
            if signalStrength == .LOW {
                lowSignal = true
                midSignal = false
                highSignal = false
            } else if signalStrength == .MID {
                lowSignal = true
                midSignal = true
                highSignal = false
            } else if signalStrength == .HIGH {
                lowSignal = true
                midSignal = true
                highSignal = true
            } else {
                lowSignal = false
                midSignal = false
                highSignal = false
            }

            setNeedsDisplay()
        }
    }

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
        self.backgroundColor = UIColor.clear
    }

    ///
    public func setLineColor(lineColor: UIColor) { // TODO: rewrite to property
        self.lineColor = lineColor
        setNeedsDisplay()
    }

    ///
    private func deg2rad(x: Double) -> CGFloat {
        return CGFloat(Double.pi * (x) / 180)
    }

    ///
    public override func draw(_ rect: CGRect) {

        // Frames
        let frame = self.bounds

        // Subframes
        let group = CGRect(x: frame.minX + 8, y: frame.minY + 5, width: frame.width - 6, height: frame.height - 6)

        // Bezier Drawing
        let bezierPath = UIBezierPath()

        bezierPath.move(to: CGPoint(x: group.minX + 0.14083 * group.width, y: group.minY + 0.35417 * group.height))
        bezierPath.addLine(to: CGPoint(x: group.minX + 0.43667 * group.width, y: group.minY + 0.58750 * group.height))
        bezierPath.addLine(to: CGPoint(x: group.minX + 0.75000 * group.width, y: group.minY + 0.35417 * group.height))
        bezierPath.lineCapStyle = .square

        let bezierPath1 = UIBezierPath(cgPath: bezierPath.cgPath)

        bezierPath1.move(to: CGPoint(x: group.minX + 0.14083 * group.width, y: group.minY + 0.05417 * group.height))
        bezierPath1.addLine(to: CGPoint(x: group.minX + 0.43667 * group.width, y: group.minY + 0.28750 * group.height))
        bezierPath1.addLine(to: CGPoint(x: group.minX + 0.75000 * group.width, y: group.minY + 0.05417 * group.height))
        bezierPath1.lineCapStyle = .square

        let bezierPath2 = UIBezierPath(cgPath: bezierPath.cgPath)

        bezierPath2.move(to: CGPoint(x: group.minX + 0.14083 * group.width, y: group.minY + 0.65417 * group.height))
        bezierPath2.addLine(to: CGPoint(x: group.minX + 0.43667 * group.width, y: group.minY + 0.88750 * group.height))
        bezierPath2.addLine(to: CGPoint(x: group.minX + 0.75000 * group.width, y: group.minY + 0.65417 * group.height))
        bezierPath2.lineCapStyle = .square

        let lineWidth = CGFloat(frame.size.width) / 10

        bezierPath2.lineWidth = lineWidth
        bezierPath1.lineWidth = lineWidth
        bezierPath.lineWidth = lineWidth

        if lowSignal {
            SPEED_COLOR.setStroke()
        } else {
            DEFAULT_COLOR.setStroke()
        }

        bezierPath1.stroke()

        if highSignal {
            SPEED_COLOR.setStroke()
        } else {
            DEFAULT_COLOR.setStroke()
        }

        if itemCount == 3 {
            bezierPath2.stroke()
        }
        
        if midSignal {
            SPEED_COLOR.setStroke()
        } else {
            DEFAULT_COLOR.setStroke()
        }
        
        bezierPath.stroke()
    }
}

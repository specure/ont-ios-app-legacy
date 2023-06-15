//
//  RMBTSpeedGraphView.swift
//  RMBT
//
//  Created by Benjamin Pucher on 20.04.15.
//  Copyright (c) 2015 Specure GmbH. All rights reserved.
//

import Foundation

///
class RMBTSpeedGraphView: UIView {
    
    var RMBTSpeedGraphViewContentFrame = CGRect()
    var RMBTSpeedGraphViewBackgroundFrame = CGRect()
    let RMBTSpeedGraphViewSeconds: TimeInterval = 8.0

    ///
    var maxTimeInterval: TimeInterval = 0

    //
    var isMeasuresIncluded = true

    private var backgroundImage = UIImage(named: "speed_graph_bg")
    private var path = UIBezierPath()
    private var firstPoint: CGPoint!

    private var widthPerSecond: CGFloat?

    private var valueCount: UInt = 0

    private var backgroundLayer = CALayer()

    private var linesLayer = CAShapeLayer()
    private var fillLayer = CAShapeLayer()

    //
    var graphColor = RMBT_RESULT_TEXT_COLOR

    //

    ///
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    ///
    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    ///
    override func awakeFromNib() {
        super.awakeFromNib()
        //
        setup()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.setup()
    }
    ///
    func setup() {
        let imageWidth = self.backgroundImage?.size.width ?? 0.1
        let offset = Int(self.frame.size.width / imageWidth * 34.0)
        let xPosition = isMeasuresIncluded ? offset : 6
        let yPosition = isMeasuresIncluded ? 9 : 2
        let theHeight = isMeasuresIncluded ? 66 : 32

        RMBTSpeedGraphViewContentFrame = CGRect(x: xPosition,
                                                y: yPosition,
                                                width: Int(boundsWidth-boundsWidth/10),
                                                height: theHeight)

        RMBTSpeedGraphViewBackgroundFrame = CGRect(x: 0, y: 0, width: boundsWidth, height: 94)

        widthPerSecond = RMBTSpeedGraphViewContentFrame.size.width / CGFloat(RMBTSpeedGraphViewSeconds)

        backgroundColor = UIColor.clear

        if isMeasuresIncluded {
            backgroundImage = backgroundImage?.tintedImageUsingColor(tintColor: RMBT_TINT_COLOR)

            backgroundLayer.frame = RMBTSpeedGraphViewBackgroundFrame //self.bounds
            backgroundLayer.contents = backgroundImage?.cgImage

            layer.addSublayer(backgroundLayer)
        }

        linesLayer.lineWidth = 1.0
        linesLayer.strokeColor = RMBT_TINT_COLOR.cgColor
        linesLayer.lineCap = CAShapeLayerLineCap.round
        linesLayer.fillColor = nil
        linesLayer.frame = RMBTSpeedGraphViewContentFrame

        layer.addSublayer(linesLayer)

        fillLayer.lineWidth = 0.0
        fillLayer.fillColor = graphColor.withAlphaComponent(0.3).cgColor //UIColor(rgb: 0x52d301, alpha: 0.4).cgColor

        fillLayer.frame = RMBTSpeedGraphViewContentFrame
        layer.insertSublayer(fillLayer, below: linesLayer)
    }

    ///
    func addValue(_ value: Double, atTimeInterval interval: TimeInterval) {
        logger.debug("ADDING VALUE: \(value) atTimeInterval: \(interval)")

        let maxY: CGFloat = RMBTSpeedGraphViewContentFrame.size.height
        let y = maxY * CGFloat(1.0 - value)

        // Ignore values that come in after max seconds
        if interval > RMBTSpeedGraphViewSeconds {
            return
        }

        let p: CGPoint = CGPoint(x: CGFloat(interval) * widthPerSecond!, y: y + RMBTSpeedGraphViewContentFrame.origin.y)

        if valueCount == 0 {
            var previousPoint = p
            previousPoint.x = 0
            firstPoint = previousPoint
            path.move(to: previousPoint)
        }
        path.addLine(to: p)

        valueCount += 1

        linesLayer.path = path.cgPath

        // Fill path

        let fillPath = UIBezierPath()
        fillPath.append(path)
        fillPath.addLine(to: CGPoint(x: p.x, y: maxY + RMBTSpeedGraphViewContentFrame.origin.y))
        fillPath.addLine(to: CGPoint(x: 0, y: maxY + RMBTSpeedGraphViewContentFrame.origin.y)) //x: RMBTSpeedGraphViewBackgroundFrame.origin.x
        fillPath.addLine(to: firstPoint)
        fillPath.close()

        fillLayer.path = fillPath.cgPath
    }

    ///
    func clear() {
        maxTimeInterval = 0
        valueCount = 0
        path.removeAllPoints()
        linesLayer.path = path.cgPath
        fillLayer.path = nil
    }
}

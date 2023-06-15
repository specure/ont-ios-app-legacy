//
//  RMBTGaugeView.swift
//  RMBT
//
//  Created by Benjamin Pucher on 19.09.14.
//  Copyright © 2014 SPECURE GmbH. All rights reserved.
//

import UIKit

///
public class RMBTGaugeView: UIView {

    ///
    private var startAngle: CGFloat!

    ///
    private var endAngle: CGFloat!

    ///
    private var foregroundImage: UIImage!
    private var foregroundLayer: CALayer?

    ///
    private var backgroundImage: UIImage!
    private var backgroundLayer: CALayer?

    ///
    private var maskForegroundLayer: CAShapeLayer!

    ///
    private var ovalRect: CGRect!

    ///
    public var clockWiseOrientation = true

    private var backgroundView: UIView?
    
    ///
    private var _value: Float = 0
    public var value: Float {
        get {
            return self._value
        }
        set {
            if self._value == newValue {
                return
            }

            self._value = newValue

            if clockWiseOrientation == false {
                _value = fabsf(1 - newValue)

                // hot fix
                if newValue == 1 {
                    _value = 0.0001
                }
            }

            let fromEndToStartAngle = endAngle - startAngle
            let angle: CGFloat = startAngle + (fromEndToStartAngle * CGFloat(_value))

            let arcCenter = CGPoint(x: ovalRect.midX, y: ovalRect.midY)
            let halfOvalRectWidth = ovalRect.size.width / 2.0
            let path = UIBezierPath(
                arcCenter: arcCenter,
                radius: halfOvalRectWidth,
                startAngle: startAngle,
                endAngle: angle,
                clockwise: clockWiseOrientation
            )

            let backEndAngle = startAngle - (2.0 * CGFloat(Double.pi))
            let backStartAngle = angle - (2.0 * CGFloat(Double.pi))

            path.addArc(withCenter: arcCenter,
                                radius: halfOvalRectWidth - 50,
                                startAngle: backStartAngle,
                                endAngle: backEndAngle,
                                clockwise: !clockWiseOrientation)

            path.close()

            maskForegroundLayer.path = path.cgPath
        }
    }

    //

    override public func layoutSubviews() {
        super.layoutSubviews()
        self.ovalRect = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        self.foregroundLayer?.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        self.backgroundLayer?.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        self.maskForegroundLayer.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        
        self.backgroundView?.frame = self.bounds
    }
    ///
    public required init(frame: CGRect, name: String, startAngle: CGFloat, endAngle: CGFloat, ovalRect: CGRect) {
        super.init(frame: frame)

        self.startAngle = (startAngle * CGFloat(Double.pi)) / 180.0
        self.endAngle = (endAngle * CGFloat(Double.pi)) / 180.0
        self.ovalRect = ovalRect

        isOpaque = false
        backgroundColor = UIColor.clear

        foregroundImage = UIImage(named: "gauge_\(name)_active_new")
        backgroundImage = UIImage(named: "gauge_\(name)_bg_new")

        assert(foregroundImage != nil, "Couldn't load image")
        assert(backgroundImage != nil, "Couldn't load image")
        
        if let tintColor = TEST_GAUGE_TINT_COLOR_PROGRESS, name == "progress" {
            foregroundImage = foregroundImage.tintedImageUsingColor(tintColor: tintColor)
        }
        /////////////////////
        if let tintColor = TEST_GAUGE_TINT_COLOR {
            backgroundImage = backgroundImage.tintedImageUsingColor(tintColor: tintColor)
        }
        /////////////////////
        if let tintColor = TEST_GAUGE_TINT_COLOR_PROGRESS, name == "speed" || name == "test"{
            foregroundImage = foregroundImage.tintedImageUsingColor(tintColor: tintColor)
        }

        //

        let foregroundLayer = CALayer()
        foregroundLayer.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        foregroundLayer.contents = foregroundImage.cgImage
        self.foregroundLayer = foregroundLayer
        
        let backgroundLayer = CALayer()
        backgroundLayer.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)

        if (name == "progress") && (RMBTAppCustomerName().uppercased() == "SPECURE") {
            let backgroundView = RMBTGaugeProgressBackgroundView(frame: frame)
            backgroundView.backgroundColor = UIColor.clear
            self.addSubview(backgroundView)
            self.backgroundView = backgroundView
            self.backgroundLayer?.addSublayer(backgroundView.layer)
        } else if (name == "speed") && (RMBTAppCustomerName().uppercased() == "SPECURE") {
            let backgroundView = RMBTGaugeSpeedBackgroundView(frame: frame)
            backgroundView.backgroundColor = UIColor.clear
            self.addSubview(backgroundView)
            self.backgroundView = backgroundView
            self.backgroundLayer?.addSublayer(backgroundView.layer)
            backgroundLayer.contents = backgroundImage.cgImage
        } else {
            backgroundLayer.contents = backgroundImage.cgImage
        }
        
        self.backgroundLayer = backgroundLayer

        self.layer.addSublayer(backgroundLayer)
        self.layer.addSublayer(foregroundLayer)

        self.maskForegroundLayer = CAShapeLayer()
        foregroundLayer.mask = maskForegroundLayer
    }

    ///
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        assert(false, "init(code:) should never be used on class RMBTGaugeView")
    }

}

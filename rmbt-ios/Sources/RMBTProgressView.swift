//
//  RMBT_ProgressView.swift
//  RMBT
//
//  Created by Tomas Baculak on 27/02/15.
//  Copyright © 2015 SPECURE GmbH. All rights reserved.
//
// Initial color is White, when a color change is needed use setStrokeColor function

import UIKit

///
class RMBTProgressView: UIView {

    ///
    var strokeThickness: CGFloat = 0.1

    ///
    var radius: CGFloat = 0

    ///
    var strokeColor = INITIAL_SCREEN_TEXT_COLOR {
        didSet {
            for layer in self.layer.sublayers! {
                layer.removeFromSuperlayer()
            }

            layoutAnimatedLayer()
        }
    }

    //

    ///
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    ///
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    ///
    func commonInit() {
        strokeThickness = frame.size.width / 12.0
        radius = frame.size.width / 2 - strokeThickness*2

        backgroundColor = .clear
        layoutAnimatedLayer()
    }

    ///
    private func layoutAnimatedLayer() {
        let layer: CALayer = getIndefiniteAnimatedLayer()
        self.layer.addSublayer(layer)
        layer.position = CGPoint(x: self.bounds.width - layer.bounds.width / 2,
                                 y: self.bounds.height - layer.bounds.height / 2)

    }

    ///
    private func getIndefiniteAnimatedLayer() -> CAShapeLayer {
        let arcCenter = CGPoint(x: radius + strokeThickness / 2 + 2, y: radius + strokeThickness / 2 + 2)
        let rect = CGRect(x: 0.0, y: 0.0, width: arcCenter.x * 2, height: arcCenter.y * 2)

        let smoothedPath = UIBezierPath(
            arcCenter: arcCenter,
            radius: radius,
            startAngle: CGFloat(Double.pi * 3 / 2),
            endAngle: CGFloat(Double.pi / 2 + Double.pi * 5),
            clockwise: true
        )

        let indefiniteAnimatedLayer = CAShapeLayer()
        indefiniteAnimatedLayer.contentsScale = UIScreen.main.scale
        indefiniteAnimatedLayer.frame = rect
        indefiniteAnimatedLayer.fillColor = UIColor.clear.cgColor
        indefiniteAnimatedLayer.strokeColor = strokeColor.cgColor
        indefiniteAnimatedLayer.lineWidth = strokeThickness
        indefiniteAnimatedLayer.lineCap = CAShapeLayerLineCap.round
        indefiniteAnimatedLayer.lineJoin = CAShapeLayerLineJoin.bevel
        indefiniteAnimatedLayer.path = smoothedPath.cgPath

        let maskLayer = CALayer()
        let image = UIImage(named: "SVProgressHUD.bundle/angle-mask")

        maskLayer.contents = image?.cgImage
        maskLayer.frame = indefiniteAnimatedLayer.bounds

        indefiniteAnimatedLayer.mask = maskLayer

        let animationDuration: TimeInterval = 1
        let linearCurve = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)

        let animation = CABasicAnimation(keyPath: "transform.rotation")
        animation.fromValue = 0
        animation.toValue = Double.pi * 2
        animation.duration = animationDuration
        animation.timingFunction = linearCurve
        animation.isRemovedOnCompletion = false
        animation.repeatCount = Float.infinity
        animation.fillMode = CAMediaTimingFillMode.forwards
        animation.autoreverses = false

        indefiniteAnimatedLayer.add(animation, forKey: "rotate")

        let animationGroup = CAAnimationGroup()
        animationGroup.duration = animationDuration
        animationGroup.repeatCount = Float.infinity
        animationGroup.isRemovedOnCompletion = false
        animationGroup.timingFunction = linearCurve

        let strokeStartAnimation = CABasicAnimation(keyPath: "strokeStart")
        strokeStartAnimation.fromValue = 0.015
        strokeStartAnimation.toValue = 0.515

        let strokeEndAnimation  = CABasicAnimation(keyPath: "strokeEnd")
        strokeEndAnimation.fromValue = 0.885
        strokeEndAnimation.toValue = 0.985

        animationGroup.animations = [strokeStartAnimation, strokeEndAnimation]
        indefiniteAnimatedLayer.add(animationGroup, forKey: "progress")

        return indefiniteAnimatedLayer
    }

}

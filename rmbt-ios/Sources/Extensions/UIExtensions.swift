//
//  UIExtensions.swift
//  RMBT
//
//  Created by Tomas Baculák on 22/11/2016.
//  Copyright © 2016 SPECURE GmbH. All rights reserved.
//

import UIKit

///
extension UITableViewCell {
    //
    func applyTintColor() { self.textLabel?.textColor = RMBT_TINT_COLOR }
    //
    func applyResultColor() { self.detailTextLabel?.applyResultColor() }
}

///
extension UIViewController {
    
    //
    func addProjectBackground() { view.applyFancyBackground() }
    
    // modal view back done button
    func addStandardDoneButton() {
        
        let backButton = UIBarButtonItem(image: UIImage(named: "back_arrow"), style: .done, target: self, action: #selector(self.backAction))
        
        navigationItem.leftBarButtonItem = backButton
    }
    //
    
    // modal view back done button
    func addStandardBackButton(action: Selector? = #selector(popAction)) {
        let backButton = UIBarButtonItem(image: UIImage(named: "back_arrow"), style: .done, target: self, action: action)
        
        navigationItem.leftBarButtonItem = backButton
    }
    //
    @objc internal func backAction() { self.dismiss(animated: true, completion: nil) }
    @objc internal func popAction() { self.navigationController?.popViewController(animated: true) }
    
    func updateColorForNavigationBarAndTabBar() {
        self.navigationController?.navigationBar.tintColor = RMBTColorManager.navigationBarTitleColor
        self.navigationController?.navigationBar.barTintColor = RMBTColorManager.navigationBarBackground
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: RMBTColorManager.navigationBarTitleColor]
        
        self.tabBarController?.tabBar.barTintColor = RMBTColorManager.tabBarBackgroundColor
        self.tabBarController?.tabBar.tintColor = RMBTColorManager.tabBarSelectedColor
        if #available(iOS 10.0, *) {
            self.tabBarController?.tabBar.unselectedItemTintColor = RMBTColorManager.tabBarUnselectedColor
        } else {
            // Fallback on earlier versions
        }
        
        if let vc = UIApplication.shared.delegate?.tabBarController() {
            vc.applyColorScheme()
            vc.setNeedsStatusBarAppearanceUpdate()
        }
        self.setNeedsStatusBarAppearanceUpdate()
    }
}

///
extension UIView {
    
    //
    func colorSubLabels(_ color: UIColor) {
        
        for subview in (self.subviews.first?.subviews ?? []) {
            if subview.isKind(of: UILabel.self) {
                (subview as! UILabel).textColor = color
            }
        }
    }
    
    //
    func applyGradient() {
    
        if INITIAL_VIEW_USE_GRADIENT {
            let gradiantLayer = CAGradientLayer()
            
            gradiantLayer.frame = bounds
            
            gradiantLayer.colors = [
                INITIAL_VIEW_GRADIENT_TOP_COLOR.cgColor,
                INITIAL_VIEW_GRADIENT_BOTTOM_COLOR.cgColor
            ]
            
            layer.insertSublayer(gradiantLayer, at: 0)
        }
    }
    //
    func applyFancyBackground() {
        if RMBT_IS_NEED_BACKGROUND == true {
            UIGraphicsBeginImageContext(self.frame.size)
            RMBTColorManager.backgroundImage?.draw(in: self.bounds)
            if let image: UIImage = UIGraphicsGetImageFromCurrentImageContext() {
                UIGraphicsEndImageContext()
                backgroundColor = UIColor(patternImage: image)
            }
        }
    }
    
    //
    func makeFancyCircles(clockWise: Bool, isDrawProgress: Bool = true) {
        
        var startAngle: CGFloat
        var endAngle: CGFloat
        
        if clockWise {
            startAngle = CGFloat(Double.pi + Double.pi/7.3)
            endAngle = CGFloat(Double.pi - Double.pi/3.3)
            
        } else {
            startAngle = CGFloat(Double.pi + Double.pi/1.44)
            endAngle = CGFloat(Double.pi * 2 + 0.01)
        }
        
        let lineWidth = bounds.width/40
        /////////////////////////////////////////////////////////////////////////////////////////////
        //
        func createLayerWithColor(_ color: UIColor, position: CGFloat, lineW: CGFloat) {
            
            ///////////
            let circlePath = UIBezierPath(arcCenter: CGPoint(x: bounds.width/2 ,y: bounds.height/2),
                                          radius: CGFloat(bounds.width/2)-position,
                                          startAngle: startAngle,
                                          endAngle: endAngle,
                                          clockwise: clockWise)
            
            let shapeLayer = CAShapeLayer()
            shapeLayer.path = circlePath.cgPath
            
            //change the fill color
            shapeLayer.fillColor = UIColor.clear.cgColor
            //you can change the stroke color
            shapeLayer.strokeColor = color.cgColor
            //you can change the line width
            shapeLayer.lineWidth = lineW
            
            self.layer.insertSublayer(shapeLayer, at: 0)
            
        }
        //
        cleanLayers()
        
        createLayerWithColor(UIColor(rgb: 0xC8CBD6), position: bounds.width/12, lineW: lineWidth)
        if isDrawProgress {
            createLayerWithColor(RMBT_TINT_COLOR, position: bounds.width/9, lineW: lineWidth*2)
        }
        createLayerWithColor(UIColor(rgb: 0xF4F3F1), position: bounds.width/17, lineW: lineWidth*3)
    }
    
    //
    func makeGradientWithColors(startColor: UIColor, centerColor: UIColor, endColor: UIColor) {
        
        cleanLayers()
        
        let aGradient = CAGradientLayer()
        
        aGradient.frame = self.bounds
        aGradient.colors = [endColor.cgColor, centerColor.cgColor, startColor.cgColor]
        
        //aGradient.locations = [0.0,1.0]
        
        //aGradient.cornerRadius = 8
        
        ///////////
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: bounds.width/2 ,y: bounds.height/2),
                                      radius: CGFloat(bounds.width/2)-bounds.width/15,
                                      startAngle: CGFloat(0),
                                      endAngle: CGFloat(Double.pi * 2),
                                      clockwise: true)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = circlePath.cgPath
        
        //change the fill color
        shapeLayer.fillColor = UIColor.clear.cgColor
        //you can change the stroke color
        shapeLayer.strokeColor = UIColor.black.cgColor
        //you can change the line width
        shapeLayer.lineWidth = 4.0
        
        self.layer.insertSublayer(aGradient, at: 0)
        self.layer.insertSublayer(shapeLayer, above: aGradient)
    }
    
    private func cleanLayers () {
        
        self.backgroundColor = UIColor.clear
        
        if let sublayers = self.layer.sublayers {
            for layer in sublayers {
                if layer.isKind(of: CAGradientLayer.self) {
                    layer.removeFromSuperlayer()
                }
                if layer.isKind(of: CAShapeLayer.self) {
                    layer.removeFromSuperlayer()
                }
            }
        }
    }

}

extension CGRect {
    init(_ x: CGFloat, _ y: CGFloat, _ w: CGFloat, _ h: CGFloat) {
        self.init(x: x, y: y, width: w, height: h)
    }
}

/*
extension Double {
    
    func makeString() -> String {
        return String(format:"%.2f", self)+" %"
    }
    
    func makeMiliseconds() -> String {
        return String(format:"%.0f", self)+" ms"
    }
    
    func makeMBitPerSecond() -> String {
        return String(format:"%.2f", self)+" MBit/s"
    }
    
    func roundTo(places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
 */

extension UINavigationController {
    
    func hideSelf() {
        // hide shadow image of navigation bar
        self.navigationBar.shadowImage = UIImage()
        self.navigationBar.setBackgroundImage(UIImage(), for: .default)
    }
}

extension UINavigationItem {
    
    ///
    func showNavigationItems() {
        leftBarButtonItem?.isEnabled = true
        leftBarButtonItem?.tintColor = RMBT_TINT_COLOR
        
        rightBarButtonItem?.isEnabled = true
        rightBarButtonItem?.tintColor = RMBT_TINT_COLOR
    }
    
    func hideNavigationItems() {
        leftBarButtonItem?.isEnabled = false
        leftBarButtonItem?.tintColor = .clear
        
        rightBarButtonItem?.isEnabled = false
        rightBarButtonItem?.tintColor = .clear
    }
}

//
extension UIButton {
    
    ///
    func formatONTStartButton() {
    
        let startColor = UIColor(rgb: 0x091E4C)
        let centerColor = UIColor(rgb: 0x183285)
        let endColor = RMBT_TINT_COLOR

        setTitle(LC("RMBT-HOME-START"), for: .normal)
        titleLabel?.numberOfLines = 2
        titleLabel?.textAlignment = .center
        
        makeGradientWithColors(startColor: startColor, centerColor: centerColor, endColor: endColor)
    }
    
    func updateGradientONTStartButton() {
        let startColor = UIColor(rgb: 0x091E4C)
        let centerColor = UIColor(rgb: 0x183285)
        let endColor = RMBT_TINT_COLOR
        
        makeGradientWithColors(startColor: startColor, centerColor: centerColor, endColor: endColor)
    }
    
    ///
    func formatRMBTMapButton() {
    
        backgroundColor = TEST_START_BUTTON_BACKGROUND_COLOR
        setTitleColor(TEST_START_BUTTON_TEXT_COLOR, for: .normal)
        setTitle(L("main-view-button-map"), for: .normal)
    }
    
    ///
    func formatRMBTStartButton() {
        
        for state in [UIControl.State.normal, .highlighted, .selected, .disabled, .focused] {
            
            setTitleColor(TEST_START_BUTTON_TEXT_COLOR, for: state)
            
            var colorToTint: UIColor?
            
            // cannot use switch? no
            
            if state == .normal {
                colorToTint = RMBT_RESULT_TEXT_COLOR
            } else if state == .disabled {
                colorToTint = TEST_START_BUTTON_DISABLED_BACKGROUND_COLOR
            } else {
                colorToTint = TEST_START_BUTTON_HIGHLIGHTED_BACKGROUND_COLOR
            }
            
            if let color = colorToTint {
                setBackgroundImage(UIImage.imageWithColor(color: color), for: state)
            }
        }
        
        backgroundColor = TEST_START_BUTTON_BACKGROUND_COLOR
    }
    
    ///
    func formatNKOMStartButton() {
        
        for state in [UIControl.State.normal, .highlighted, .selected, .disabled] {
            setTitleColor(TEST_START_BUTTON_TEXT_COLOR, for: state)
        }
        
        layer.makeRoundedObject()
        layer.shadowOffset = CGSize(width: 0, height: 6)
        layer.shadowRadius = 10
        layer.shadowOpacity = 0.75
        layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.75).cgColor
        layer.masksToBounds = false
        
        self.titleLabel?.textAlignment = .center
        self.titleLabel?.baselineAdjustment = .alignCenters
        
        tintByColor(color: INITIAL_VIEW_BACKGROUND_COLOR)
        showsTouchWhenHighlighted = true
        
        localizedTitleForNormal = "RMBT-HOME-START"
//        localizedTitleForSelected = "RMBT-HOME-RUNAGAIN"
        
        self.backgroundColor = TEST_START_BUTTON_BACKGROUND_COLOR
    }
    
    //
    func buttonWithColor(_ color: UIColor) {
        if let theImage = self.imageView?.image {
            self.setImage(theImage.tintedImageUsingColor(tintColor: color), for: .normal)
        }
    }
        
    //
    private func tintByColor(color: UIColor) {
        
        tintColor = color
        
        if let iv = imageView, let image = iv.image {
            setImage(image.withRenderingMode(.alwaysTemplate), for: .normal)
        }
    }
    
    //
    private var localizedTitleForNormal: String {
        set (key) {
            setTitle(L(key), for: .normal)
        }
        get {
            return title(for: .normal)!
        }
    }
    
    //
    private var localizedTitleForSelected: String {
        set (key) {
            setTitle(L(key), for: .selected)
        }
        get {
            return title(for: .selected)!
        }
    }
}

//
extension UILabel {
    
    ///
    func applyResultColor() {
        self.textColor = RMBT_RESULT_TEXT_COLOR
    }
    ///
    func makeLabelResizableWith(numOfLines: Int) {
        adjustsFontSizeToFitWidth = true
        minimumScaleFactor = 0.2
        baselineAdjustment = .none
        numberOfLines = numOfLines
        textColor = INITIAL_VIEW_BACKGROUND_COLOR
    }
    
    ///
    func formatMainStartLabel() {
        textColor = TEST_START_BUTTON_TEXT_COLOR
    }
    
    ///
    func formatDynamicType(style: UIFont.TextStyle?) {
        
        // let type = style != nil ? style:UIFontTextStyle.headline
        
        //        let pointSize = UIFont.preferredFontForTextStyle(type as! String).pointSize
        //        font = UIFont(name: MAIN_FONT, size: pointSize)
        
        // font = UIFont(descriptor: UIFontDescriptor.preferredDescriptor(textStyle: NSString(type!.rawValue)), size: 0)
    }
}

//
extension UIImage {
    
    ///
    class func emptyMarkerImage() -> UIImage { // TODO: dispatch_once
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 1, height: 1), false, 0.0)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
    
    ///
    class func imageWithColor(color: UIColor) -> UIImage {
        let rect: CGRect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        
        UIGraphicsBeginImageContext(rect.size)
        let context: CGContext = UIGraphicsGetCurrentContext()!
        
        context.setFillColor(color.cgColor)
        context.fill(rect)
        
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return image
    }
    
    ///
    func tintedImageUsingColor(tintColor: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, UIScreen.main.scale)
        
        let context: CGContext = UIGraphicsGetCurrentContext()!
        let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        
        // draw original image
        self.draw(in: rect, blendMode: .normal, alpha: 1.0)
        
        // tint image (loosing alpha)
        context.setBlendMode(.normal)
        tintColor.setFill()
        context.fill(rect)
        
        // mask by alpha values of original image
        self.draw(in: rect, blendMode: .destinationIn, alpha: 1.0)
        
        let tintedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return tintedImage!
    }
    
}

//
extension DateFormatter {
    
    class func formatHistoryView () -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        
        return formatter
    }
}

extension CALayer {
    ///
    func makeRoundedObject() {
        cornerRadius = bounds.size.height / 2
        masksToBounds = true
    }
}

//extension UIFontDescriptor {
//
//    private struct SubStruct {
//        static var preferredFontName: String = MAIN_FONT
//    }
//
//    class func preferredDescriptor(textStyle: NSString) -> UIFontDescriptor {
//        struct Static {
//            static var onceToken : dispatch_once_t = 0
//            static var fontSizeTable : NSDictionary = NSDictionary()
//        }
//
//        dispatch_once(&Static.onceToken) {
//            Static.fontSizeTable = [
//                UIFontTextStyleHeadline: [
//                    UIContentSizeCategoryAccessibilityExtraExtraExtraLarge: 23,
//                    UIContentSizeCategoryAccessibilityExtraExtraLarge: 23,
//                    UIContentSizeCategoryAccessibilityExtraLarge: 23,
//                    UIContentSizeCategoryAccessibilityLarge: 23,
//                    UIContentSizeCategoryAccessibilityMedium: 23,
//                    UIContentSizeCategoryExtraExtraExtraLarge: 23,
//                    UIContentSizeCategoryExtraExtraLarge: 21,
//                    UIContentSizeCategoryExtraLarge: 19,
//                    UIContentSizeCategoryLarge: 17,
//                    UIContentSizeCategoryMedium: 16,
//                    UIContentSizeCategorySmall: 15,
//                    UIContentSizeCategoryExtraSmall: 14
//                ],
//                UIFontTextStyleSubheadline: [
//                    UIContentSizeCategoryAccessibilityExtraExtraExtraLarge: 21,
//                    UIContentSizeCategoryAccessibilityExtraExtraLarge: 21,
//                    UIContentSizeCategoryAccessibilityExtraLarge: 21,
//                    UIContentSizeCategoryAccessibilityLarge: 21,
//                    UIContentSizeCategoryAccessibilityMedium: 21,
//                    UIContentSizeCategoryExtraExtraExtraLarge: 21,
//                    UIContentSizeCategoryExtraExtraLarge: 19,
//                    UIContentSizeCategoryExtraLarge: 17,
//                    UIContentSizeCategoryLarge: 15,
//                    UIContentSizeCategoryMedium: 14,
//                    UIContentSizeCategorySmall: 13,
//                    UIContentSizeCategoryExtraSmall: 12
//                ],
//                UIFontTextStyleBody: [
//                    UIContentSizeCategoryAccessibilityExtraExtraExtraLarge: 50, //53,
//                    UIContentSizeCategoryAccessibilityExtraExtraLarge: 44, //47,
//                    UIContentSizeCategoryAccessibilityExtraLarge: 38, //40,
//                    UIContentSizeCategoryAccessibilityLarge: 32, //33,
//                    UIContentSizeCategoryAccessibilityMedium: 30, //28,
//                    UIContentSizeCategoryExtraExtraExtraLarge: 28, //23,
//                    UIContentSizeCategoryExtraExtraLarge: 26, //21,
//                    UIContentSizeCategoryExtraLarge: 24, //19,
//                    UIContentSizeCategoryLarge: 22, //17,
//                    UIContentSizeCategoryMedium: 20, //16,
//                    UIContentSizeCategorySmall: 18, //15,
//                    UIContentSizeCategoryExtraSmall: 16 //14
//                ],
//                UIFontTextStyleCaption1: [
//                    UIContentSizeCategoryAccessibilityExtraExtraExtraLarge: 18,
//                    UIContentSizeCategoryAccessibilityExtraExtraLarge: 18,
//                    UIContentSizeCategoryAccessibilityExtraLarge: 18,
//                    UIContentSizeCategoryAccessibilityLarge: 18,
//                    UIContentSizeCategoryAccessibilityMedium: 18,
//                    UIContentSizeCategoryExtraExtraExtraLarge: 18,
//                    UIContentSizeCategoryExtraExtraLarge: 16,
//                    UIContentSizeCategoryExtraLarge: 14,
//                    UIContentSizeCategoryLarge: 12,
//                    UIContentSizeCategoryMedium: 11,
//                    UIContentSizeCategorySmall: 11,
//                    UIContentSizeCategoryExtraSmall: 11
//                ],
//                UIFontTextStyleCaption2: [
//                    UIContentSizeCategoryAccessibilityExtraExtraExtraLarge: 17,
//                    UIContentSizeCategoryAccessibilityExtraExtraLarge: 17,
//                    UIContentSizeCategoryAccessibilityExtraLarge: 17,
//                    UIContentSizeCategoryAccessibilityLarge: 17,
//                    UIContentSizeCategoryAccessibilityMedium: 17,
//                    UIContentSizeCategoryExtraExtraExtraLarge: 17,
//                    UIContentSizeCategoryExtraExtraLarge: 15,
//                    UIContentSizeCategoryExtraLarge: 13,
//                    UIContentSizeCategoryLarge: 11,
//                    UIContentSizeCategoryMedium: 11,
//                    UIContentSizeCategorySmall: 11,
//                    UIContentSizeCategoryExtraSmall: 11
//                ],
//                UIFontTextStyleFootnote: [
//                    UIContentSizeCategoryAccessibilityExtraExtraExtraLarge: 19,
//                    UIContentSizeCategoryAccessibilityExtraExtraLarge: 19,
//                    UIContentSizeCategoryAccessibilityExtraLarge: 19,
//                    UIContentSizeCategoryAccessibilityLarge: 19,
//                    UIContentSizeCategoryAccessibilityMedium: 19,
//                    UIContentSizeCategoryExtraExtraExtraLarge: 19,
//                    UIContentSizeCategoryExtraExtraLarge: 17,
//                    UIContentSizeCategoryExtraLarge: 15,
//                    UIContentSizeCategoryLarge: 13,
//                    UIContentSizeCategoryMedium: 12,
//                    UIContentSizeCategorySmall: 12,
//                    UIContentSizeCategoryExtraSmall: 12
//                ],
//            ]
//        }
//
//        let contentSize = UIApplication.sharedApplication().preferredContentSizeCategory
//        let style = Static.fontSizeTable[textStyle] as! NSDictionary
//        return UIFontDescriptor(name: SubStruct.preferredFontName, size: CGFloat((style[contentSize] as! NSNumber).floatValue))
//    }
//}

extension UIDevice {
    class func isDeviceTablet() -> Bool {
        return UIDevice.current.userInterfaceIdiom == .pad ? true:false
    }
}

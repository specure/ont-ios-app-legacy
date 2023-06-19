//
//  UINavigationController+Orientation.swift
//
//  Created by Sergey Glushchenko on 9/30/17.
//  Copyright © 2017 SPECURE GmbH. All rights reserved.
//

extension UINavigationController {
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
//    open override var preferredStatusBarStyle: UIStatusBarStyle {
//        if let presentedViewController = self.presentedViewController as? UINavigationController, presentedViewController.isBeingDismissed == false {
//            return presentedViewController.preferredStatusBarStyle
//        }
//        if let topViewController = self.topViewController {
//            return topViewController.preferredStatusBarStyle
//        }
//
//        return .default
//    }
    
    override open var shouldAutorotate: Bool {
        if let presentedViewController = self.presentedViewController as? UINavigationController, presentedViewController.isBeingDismissed == false {
            let orientations = presentedViewController.supportedInterfaceOrientations
            if orientations == .portrait {
                self.restoreOrientation()
                return true
            }
            return presentedViewController.shouldAutorotate
        }
        if let topViewController = self.topViewController {
            let orientations = topViewController.supportedInterfaceOrientations
            if orientations == .portrait {
                self.restoreOrientation()
                return true
            }
            return topViewController.shouldAutorotate
        }
        return false
    }
    
    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if let presentedViewController = self.presentedViewController as? UINavigationController, presentedViewController.isBeingDismissed == false {
            let orientations = presentedViewController.supportedInterfaceOrientations
            if orientations == .portrait {
                self.restoreOrientation()
            }
            return presentedViewController.supportedInterfaceOrientations
        }
        if let topViewController = self.topViewController {
            let orientations = topViewController.supportedInterfaceOrientations
            if orientations == .portrait {
                self.restoreOrientation()
            }
            return topViewController.supportedInterfaceOrientations
        }
        return .all
    }
    
    override open var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        if let presentedViewController = self.presentedViewController as? UINavigationController, presentedViewController.isBeingDismissed == false {
            return presentedViewController.preferredInterfaceOrientationForPresentation
        }
        if let topViewController = self.topViewController {
            return topViewController.preferredInterfaceOrientationForPresentation
        }
        return .portrait
    }
    
    //It's need if previous view controller in landscape and current view controller in portrait. It's fix bug return orientation
    func restoreOrientation() {
        let orientation = UIApplication.shared.statusBarOrientation
        if orientation != .portrait {
            UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue as Any, forKey: "orientation")
        }
    }
    open override var childForStatusBarStyle: UIViewController? {
        return self.topViewController
    }
    
    open override var childForStatusBarHidden: UIViewController? {
        return self.topViewController
    }
    
}

extension SWRevealViewController {
    override open var preferredStatusBarStyle: UIStatusBarStyle {
        if let topViewController = self.frontViewController {
            return topViewController.preferredStatusBarStyle
        }
        
        return .default
    }
    
    override open var shouldAutorotate: Bool {
        return self.frontViewController?.shouldAutorotate ?? true
    }
    
    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return self.frontViewController?.supportedInterfaceOrientations ?? .all
    }
    
    override open var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return self.frontViewController?.preferredInterfaceOrientationForPresentation ?? .portrait
    }
}

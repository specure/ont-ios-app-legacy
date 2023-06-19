//
//  RMBTTabBarViewController.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 11/2/18.
//  Copyright © 2018 SPECURE GmbH. All rights reserved.
//

import UIKit

class RMBTTabBarViewController: UITabBarController, RMBTTabBarViewControllerProtocol {

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return self.selectedViewController?.preferredStatusBarStyle ?? RMBTColorManager.statusBarStyle
    }
    
    open override var childForStatusBarStyle: UIViewController? {
        return self.selectedViewController
    }
    
    open override var childForStatusBarHidden: UIViewController? {
        return self.selectedViewController
    }
    
    var historyViewController: RMBTHistoryIndexViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        var viewControllers: [UIViewController] = []
        if let homeScreen = UIStoryboard.testScreen() {
            viewControllers.append(homeScreen)
        }
        if let historyScreen = UIStoryboard.historyScreen() {
            viewControllers.append(historyScreen)
            if let navigationController = historyScreen as? UINavigationController,
                let vc = navigationController.viewControllers.first as? RMBTHistoryIndexViewController {
                historyViewController = vc
            }
        }
        if let mapScreen = UIStoryboard.mapScreen() {
            viewControllers.append(mapScreen)
        }
        if let settingsScreen = UIStoryboard.settingsScreen() {
            viewControllers.append(settingsScreen)
        }
        self.viewControllers = viewControllers
        
        self.applyColorScheme()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        guard UIApplication.shared.applicationState == .inactive else {
            return
        }
        
        self.applyColorScheme()
    }
    
    func applyColorScheme() {
        self.tabBar.barTintColor = RMBTColorManager.tabBarBackgroundColor
        self.tabBar.tintColor = RMBTColorManager.tabBarSelectedColor
        self.tabBar.unselectedItemTintColor = RMBTColorManager.tabBarUnselectedColor
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    func updateHistory() {
        self.historyViewController?.reloadHistory()
    }
    
    func resetTest(animated: Bool = false) {
        let vc = viewControllers?.first(where: { (vc) -> Bool in
            if let navController = vc as? UINavigationController {
                return navController.viewControllers.first is RMBTLoopModeInitViewController
            }
            return vc is RMBTLoopModeInitViewController
        })
        
        if let vc = vc as? UINavigationController {
            vc.popToRootViewController(animated: animated)
        }
    }
    
    func openSettings() {
        let vc = viewControllers?.first(where: { (vc) -> Bool in
            if let navController = vc as? UINavigationController {
                return navController.viewControllers.first is RMBTSettingsViewController
            }
            return vc is RMBTSettingsViewController
        })
        
        if let vc = vc {
            self.selectedViewController = vc
        }
    }
    
    func openTest() {
        let vc = viewControllers?.first(where: { (vc) -> Bool in
            if let navController = vc as? UINavigationController {
                return navController.viewControllers.first is RMBTLoopModeInitViewController
            }
            return vc is RMBTLoopModeInitViewController
        })
        
        if let vc = vc {
            self.selectedViewController = vc
        }
    }
    
    override var selectedIndex: Int {
        get {
            return super.selectedIndex
        }
        set {
            super.selectedIndex = newValue
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    override var selectedViewController: UIViewController? {
        get {
            return super.selectedViewController
        }
        set {
            super.selectedViewController = newValue
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

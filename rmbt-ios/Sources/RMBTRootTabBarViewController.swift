//
//  RMBTRootTabBarViewController.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 1/29/19.
//  Copyright © 2019 SPECURE GmbH. All rights reserved.
//

import UIKit

class RMBTRootTabBarViewController: UIViewController {

    enum Direction {
        case left
        case right
    }
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var tabbar: UITabBar!
    
    var currentViewController: UIViewController? = nil {
        didSet {
            self.bindNavigationBar()
            self.updateNavigationBar()
        }
    }
    
    func bindNavigationBar() {
        var vc = self.currentViewController
        if let navController = vc as? UINavigationController {
            vc = navController.topViewController
        }
        let _ = vc?.view // Hack for load view
//        vc?.navigationController?.navigationBar.delegate = self
//        vc?.navigationController?.delegate = self
    }
    
    func updateNavigationBar() {
        UIView.transition(with: self.navigationController!.navigationBar, duration: 0.2, options: [.beginFromCurrentState, .transitionCrossDissolve], animations: {
            var vc = self.currentViewController
            if let navController = vc as? UINavigationController {
                vc = navController.topViewController
                let _ = vc?.view // Hack for load view
            }
            self.navigationItem.backBarButtonItem = vc?.navigationItem.backBarButtonItem
            self.navigationItem.leftBarButtonItems = vc?.navigationItem.leftBarButtonItems
            self.navigationItem.rightBarButtonItems = vc?.navigationItem.rightBarButtonItems
            self.navigationItem.title = vc?.navigationItem.title
            self.navigationItem.titleView = vc?.navigationItem.titleView
        }, completion: { _ in
            
        })
    }
    
    var viewControllers: [UIViewController] = [] {
        didSet {
            let tabBarItems = viewControllers.map({ (vc) -> UITabBarItem in
                return vc.tabBarItem
            })
            
            self.tabbar.setItems(tabBarItems, animated: false)
            self.selectedIndex = 0
        }
    }
    
    var selectedViewController: UIViewController? {
        didSet {
            
        }
    }
    
    var selectedIndex: Int = -1 {
        didSet {
            guard selectedIndex != oldValue else { return }
            self.tabbar.selectedItem = self.tabbar.items?[selectedIndex]
            self.selectedViewController = self.viewControllers[selectedIndex]
            if oldValue > selectedIndex {
                self.selectRootVC(direction: .left)
            } else {
                self.selectRootVC(direction: .right)
            }
        }
    }
    
    var primaryClasses = [RMBTLoopModeInitViewController.self]
    var fullScreenClasses: [AnyClass] {
        return RMBTSettings.sharedSettings.countMeasurements == 0 ?
            [RMBTMapViewController.self, RMBTHistoryIndexViewController.self, RMBTSettingsViewController.self, RMBTLoopModeInitViewController.self] :
            [RMBTMapViewController.self, RMBTSettingsViewController.self]
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    var historyViewController: RMBTHistoryIndexViewController?
    var mainViewController: RMBTLoopModeInitViewController?
    
    var stackViewControllers: [UIViewController] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tabbar.delegate = self
        
        // Do any additional setup after loading the view.
        self.applyColorScheme()
        
        UIView.performWithoutAnimation {
            self.prepareViewControllers()
        }

        self.prepareGestures()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        var frame = self.view.bounds
        var bottomInset: CGFloat = 0.0
        if #available(iOS 11.0, *) {
            bottomInset = self.view.safeAreaInsets.bottom
        }
        frame.size.height -= self.tabbar.bounds.height + bottomInset
        self.containerView.frame = frame
        self.updateViewControllers()
    }
    
    func prepareGestures() {
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGesture(gesture:)))
        swipeRight.direction = .right
        view.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGesture(gesture:)))
        swipeLeft.direction = .left
        view.addGestureRecognizer(swipeLeft)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        guard UIApplication.shared.applicationState == .inactive else {
            return
        }
        
        self.applyColorScheme()
    }
    
    func applyColorScheme() {
        self.containerView.backgroundColor = UIColor.clear
        self.tabbar.barTintColor = RMBTColorManager.tintColor
        self.tabbar.tintColor = RMBTColorManager.navigationBarTitleColor
        self.navigationController?.navigationBar.isTranslucent = false
        self.tabbar.isTranslucent = false
        self.view.backgroundColor = RMBTColorManager.background
        if #available(iOS 10.0, *) {
            self.tabbar.unselectedItemTintColor = RMBTColorManager.tabBarUnselectedColor
        } else {
            // Fallback on earlier versions
        }
        
        self.navigationController?.navigationBar.tintColor = RMBTColorManager.navigationBarTitleColor
        self.navigationController?.navigationBar.barTintColor = RMBTColorManager.navigationBarBackground
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: RMBTColorManager.navigationBarTitleColor]
        
        for vc in self.navigationController?.viewControllers ?? [] {
            if let currentVC = vc as? RMBTColorManagerProtocol {
                if vc.isViewLoaded {
                    currentVC.applyColorScheme()
                }
            }
        }
    }
    
    func prepareViewControllers() {
        var viewControllers: [UIViewController] = []
        if let homeScreen = UIStoryboard.testScreen() {
            viewControllers.append(homeScreen)
            if let navController = homeScreen as? UINavigationController {
                mainViewController = navController.topViewController as? RMBTLoopModeInitViewController
            } else {
                mainViewController = homeScreen as? RMBTLoopModeInitViewController
            }
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
        self.viewControllers = viewControllers.map({ (navController) -> UIViewController in
            if let navController = navController as? UINavigationController,
                let vc = navController.topViewController {
                return vc
            }
            
            return navController
        })
    }
    
    func updateHistory() {
        self.historyViewController?.reloadHistory()
    }
    
    func openSettings() {
        let index = viewControllers.firstIndex(where: { (vc) -> Bool in
            if let navController = vc as? UINavigationController {
                return navController.viewControllers.first is RMBTSettingsViewController
            }
            return vc is RMBTSettingsViewController
        })
        
        if let index = index {
            self.selectedIndex = index
        }
    }
    
    func openTest() {
        let index = viewControllers.firstIndex(where: { (vc) -> Bool in
            if let navController = vc as? UINavigationController {
                return navController.viewControllers.first is RMBTLoopModeInitViewController
            }
            return vc is RMBTLoopModeInitViewController
        })
        
        if let index = index {
            self.selectedIndex = index
        }
    }
    
    @objc func handleSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case .right:
                guard (selectedIndex - 1) >= 0 else { return }
                select(at: selectedIndex - 1)
                break
            case .left:
                guard (selectedIndex + 1) < viewControllers.count else { return }
                select(at: selectedIndex + 1)
                break
            default:
                break
            }
        }
    }

    private func select(at index: Int) {
        guard index >= 0 && index < self.viewControllers.count else { return }
        self.selectedIndex = index
    }
    
    func selectRootVC(direction: Direction = .left) {
        guard let rootVC = self.selectedViewController else { return }
        let viewControllers = self.viewControllers(for: rootVC)
        self.show(vcs: viewControllers, currentVC: viewControllers[0], direction: direction)
    }
    
    func viewControllers(for rootVC: UIViewController) -> [UIViewController] {
        var viewControllers: [UIViewController] = []
        viewControllers.append(rootVC)
        if rootVC == mainViewController {
            viewControllers.append(self.viewControllers[1])
        }
        if rootVC == historyViewController,
            let vc = UIStoryboard.resultsScreen() as? RMBTHistoryResultViewController {
            historyViewController?.latestOrSelectedTest(with: { [weak vc] (result) in
                if let result = result {
                    vc?.historyResult = result
                }
            })
            viewControllers.append(vc)
        }
        
        return viewControllers
    }
    
    func pop() {
//        self.stackViewControllers.removeLast()
        if self.stackViewControllers.count > 1 {
            let vcs = Array(self.stackViewControllers[self.stackViewControllers.count - 2..<self.stackViewControllers.count - 1])
            show(vcs: vcs, currentVC: vcs.last!, direction: .left, isPoped: true)
        }
    }
    
    func push(vc: UIViewController, from parentVC: UIViewController) {
        guard let index = self.stackViewControllers.firstIndex(of: parentVC) else {
            print("parentVC should be in stackViewControllers")
            return
        }
        
        var vcs: [UIViewController] = []
        vcs.append(self.stackViewControllers[index])
        vcs.append(vc)
        self.show(vcs: vcs, currentVC: vc, direction: .right, isPushed: true)
    }
    
    func show(vcs: [UIViewController], currentVC: UIViewController, direction: Direction, isPushed: Bool = false, isPoped: Bool = false) {
        if vcs.contains(currentVC) == false {
            print("currentVC must be in vcs")
            return
        }
        
        var needHideViewControllers: [UIViewController] = []
        for vc in self.stackViewControllers {
            if vc.view.frame.intersects(self.containerView.bounds) == true &&
                vcs.contains(vc) == false {
                needHideViewControllers.append(vc)
            }
        }
        
        var needShowViewControllers: [UIViewController] = []
        for vc in vcs {
            if vc.view.frame.intersects(self.containerView.bounds) == false || vc.view.superview == nil {
                needShowViewControllers.append(vc)
            }
        }
    
        //TODO: Maybe need fix frame for fullscreen viewcontrollers and portrait mode
        var frame = self.containerView.bounds
        for (index, vc) in needShowViewControllers.enumerated() {
            if direction == .right {
                frame.origin.x = self.containerView.bounds.size.width + (self.containerView.bounds.size.width / 2 * CGFloat(index))
                frame.size.width = self.containerView.bounds.size.width / 2
                vc.view.frame = frame
            } else {
                frame.origin.x = -(self.containerView.bounds.size.width / 2 + self.containerView.bounds.size.width / 2 * CGFloat((needShowViewControllers.count - 1) - index))
                frame.size.width = self.containerView.bounds.size.width / 2
                vc.view.frame = frame
            }
            vc.view.clipsToBounds = true
        }
        
        if isPoped {
            self.stackViewControllers.removeLast()
        } else if isPushed {
            self.stackViewControllers.removeLast()
            if let index = self.stackViewControllers.firstIndex(of: vcs[0]) {
                self.stackViewControllers = Array(self.stackViewControllers[0..<index])
            }
            self.stackViewControllers.append(contentsOf: vcs)
        } else {
            self.stackViewControllers = vcs
        }
        self.currentViewController = currentVC
        
        UIView.animate(withDuration: 0.3, animations: {
            for (index, vc) in needHideViewControllers.enumerated() {
                var frame = vc.view.frame
                if direction == .left {
                    frame.origin.x = self.containerView.bounds.size.width + (self.containerView.bounds.size.width / 2 * CGFloat(index))
                    vc.view.frame = frame
                } else {
                    frame.origin.x = -(self.containerView.bounds.size.width / 2 + self.containerView.bounds.size.width / 2 * CGFloat((needShowViewControllers.count) - index))
                    vc.view.frame = frame
                }
            }
        }) { (_) in
            for vc in needHideViewControllers {
                vc.willMove(toParent: nil)
                vc.view.removeFromSuperview()
                vc.removeFromParent()
            }
        }
        
        UIView.animate(withDuration: 0.3) {
            self.updateViewControllers()
        }
        
    }
    
    func currentViewControllers() -> [UIViewController] {
        var viewControllers: [UIViewController] = []
        for vc in stackViewControllers {
            if vc.view.frame.intersects(self.containerView.bounds) {
                viewControllers.append(vc)
            }
        }
        
        return viewControllers
    }
    
    func updateViewControllers() {
        if UIApplication.shared.statusBarOrientation.isPortrait ||
            UIScreen.main.bounds.size.width != self.view.boundsWidth,
            let vc = self.currentViewController {
            self.addChild(vc)
            self.containerView.addSubview(vc.view)
            vc.view.frame = self.containerView.bounds
            vc.didMove(toParent: self)
            //TODO: Hide other view controllers
        } else {
            if self.stackViewControllers.count == 1 {
                guard let vc = self.currentViewController else { return }
                self.addChild(vc)
                self.containerView.addSubview(vc.view)
                vc.view.frame = self.containerView.bounds
                vc.didMove(toParent: self)
            } else {
                if let vc = self.currentViewController,
                    let index = self.stackViewControllers.firstIndex(of: vc) {
                    if self.isFullScreen(vc) {
                        self.addChild(vc)
                        self.containerView.addSubview(vc.view)
                        vc.view.frame = self.containerView.bounds
                        vc.didMove(toParent: self)
                    } else {
                        var firstViewController = vc
                        var secondViewController = vc
                        if index < self.stackViewControllers.count - 1 {
                            secondViewController = self.stackViewControllers[index + 1]
                            //from right
                        } else {
                            firstViewController = self.stackViewControllers[index - 1]
                            //from left
                        }
                        self.addChild(firstViewController)
                        self.addChild(secondViewController)
                        //Set frame for first viewcontroller
                        var frame = self.containerView.bounds
                        self.containerView.addSubview(firstViewController.view)
                        frame = self.containerView.bounds
                        frame.origin.x = 0
                        frame.size.width = self.containerView.boundsWidth / 2
                        firstViewController.view.frame = frame

                        //Set frame for second viewcontroller
                        frame = self.containerView.bounds
                        self.containerView.addSubview(secondViewController.view)
                        frame.origin.x = self.containerView.boundsWidth / 2
                        frame.size.width = self.containerView.boundsWidth / 2
                        secondViewController.view.frame = frame
                        
                        firstViewController.didMove(toParent: self)
                        secondViewController.didMove(toParent: self)
                    }
                }
            }
        }
    }
    
    func isFullScreen(_ vc: UIViewController?) -> Bool {
        if UIApplication.shared.statusBarOrientation.isPortrait {
            return true
        }
        
        guard let vc = vc else { return false }

        for fullScreenClass in fullScreenClasses {
            if vc.isKind(of: fullScreenClass) {
                return true
            }
        }
        return false
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

extension RMBTRootTabBarViewController: UITabBarDelegate {
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if let index = tabBar.items?.firstIndex(of: item) {
            self.selectedIndex = index
        }
    }
}

extension RMBTRootTabBarViewController: UINavigationBarDelegate {
    public func navigationBar(_ navigationBar: UINavigationBar, didPush item: UINavigationItem) {
        self.updateNavigationBar()
    }
    
    public func navigationBar(_ navigationBar: UINavigationBar, didPop item: UINavigationItem) {
        self.updateNavigationBar()
    }
}

extension RMBTRootTabBarViewController: UINavigationControllerDelegate {
    public func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        self.updateNavigationBar()
    }
}

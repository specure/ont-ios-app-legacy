//
//  RMBTSettingsViewController.swift
//  RMBT
//
//  Created by Benjamin Pucher on 12.10.18.
//  Copyright © 2018 SPECURE GmbH. All rights reserved.
//

import UIKit
import CoreLocation
import AdSupport

protocol WelcomeWizardViewController {
    var isUploading: Bool { get }
}

class WelcomeWizardPageViewController: UIPageViewController {
    
    class PageInfo {
        var identifier: Step = .welcome
        var identifierVC: String = ""
        var buttons: [String] = []
        var icon: UIImage?
        var title: String?
        var subtitle: String?
    }
    
    enum Step {
        case welcome
        case location
        case adsPersonalization
        case persistentClient
        case analytics
        case finish
        case finishWithDarkMode
    }
    
    private(set) lazy var orderedViewControllers: [UIViewController] = {
        return self.pageInfos.map({ (pageInfo) -> UIViewController in
            self.controller(with: pageInfo.identifierVC)
        })
//        return [self.controller(with: "FirstStepWizardID"),
//                self.controller(with: "FirstStepWizardID"),
//                self.controller(with: "FirstStepWizardID"),
////                self.controller(with: "ThirdStepWizardID"),
////                self.controller(with: "FourthStepWizardID"),
////                self.controller(with: "FivethStepWizardID"),
////                self.controller(with: "SixStepWizardID")
//        ]
    }()
    
    var pageInfos: [PageInfo] = []
    
    var nextButton: UIButton!
    var prevButton: UIButton!
    var pageControl: UIPageControl!
    
    let locationManager = CLLocationManager() // Need only for authorization request permission
    
    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override open var shouldAutorotate: Bool { return true }
    
    override open var prefersStatusBarHidden: Bool { return false }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.preparePageInfos()
        
        delegate = self
        dataSource = self
        
        if let firstViewController = orderedViewControllers.first as? RMBTWizardPageController {
            configure(viewController: firstViewController, index: 0)
            setViewControllers([firstViewController],
                               direction: .forward,
                               animated: true,
                               completion: nil)
        }
    }
    
    func preparePageInfos() {
        var pageInfos: [PageInfo] = []
        
        let welcomePage = PageInfo()
        welcomePage.title = String.localizedStringWithFormat(L("wizard.step1.title"), RMBTAppTitle())
        welcomePage.subtitle = L("wizard.step1.subtitle")
        welcomePage.identifierVC = "FirstStepWizardID"
        welcomePage.identifier = .welcome
        welcomePage.buttons = [L("wizard.button.next")]
        welcomePage.icon = UIImage(named: "step_1")
        
        pageInfos.append(welcomePage)
        
        let locationPage = PageInfo()
        locationPage.title = String.localizedStringWithFormat(L("wizard.step2.title"), RMBTAppTitle())
        locationPage.identifier = .location
        locationPage.subtitle = L("wizard.step2.subtitle")
        locationPage.identifierVC = "FirstStepWizardID"
        locationPage.buttons = [L("wizard.button.next")]
        locationPage.icon = nil
        
        pageInfos.append(locationPage)
        
        let adsPersonalisation = PageInfo()
        adsPersonalisation.title = String.localizedStringWithFormat(L("wizard.step3.title"), RMBTAppTitle())
        adsPersonalisation.identifier = .adsPersonalization
        adsPersonalisation.subtitle = L("wizard.step3.subtitle")
        adsPersonalisation.identifierVC = "FirstStepWizardID"
        adsPersonalisation.buttons = [L("wizard.button.next")]
        adsPersonalisation.icon = UIImage(named: "step_3")
        
        pageInfos.append(adsPersonalisation)
        
        let persistentClient = PageInfo()
        persistentClient.title = String.localizedStringWithFormat(L("wizard.step4.title"), RMBTAppTitle())
        persistentClient.identifier = .persistentClient
        persistentClient.subtitle = L("wizard.step4.subtitle")
        persistentClient.identifierVC = "FirstStepWizardID"
        persistentClient.buttons = [L("wizard.button.no_thank_you"), L("wizard.button.allow_pesistent_client")]
        persistentClient.icon = UIImage(named: "step_4")
        
        pageInfos.append(persistentClient)
        
        let analytics = PageInfo()
        analytics.title = String.localizedStringWithFormat(L("wizard.step5.title"), RMBTAppTitle())
        analytics.identifier = .analytics
        analytics.subtitle = L("wizard.step5.subtitle")
        analytics.identifierVC = "FirstStepWizardID"
        analytics.buttons = [L("wizard.button.no_thank_you"), L("wizard.button.allow_analytics")]
        analytics.icon = UIImage(named: "step_5")
        
        pageInfos.append(analytics)
        
        if RMBT_IS_USE_DARK_MODE {
            let finish = PageInfo()
            finish.title = String.localizedStringWithFormat(L("wizard.step6.title"), RMBTAppTitle())
            finish.identifier = .finish
            finish.subtitle = L("wizard.step6.subtitle")
            finish.identifierVC = "FirstStepWizardID"
            finish.buttons = [L("wizard.button.light_mode"), L("wizard.button.dark_mode")]
            finish.icon = UIImage(named: "step_6")
            
            pageInfos.append(finish)
        } else {
            let finish = PageInfo()
            finish.title = String.localizedStringWithFormat(L("wizard.step7.title"), RMBTAppTitle())
            finish.identifier = .finishWithDarkMode
            finish.subtitle = L("wizard.step7.subtitle")
            finish.identifierVC = "FirstStepWizardID"
            finish.buttons = [L("wizard.button.continue_use_the_app")]
            finish.icon = UIImage(named: "step_7")
            
            pageInfos.append(finish)
        }
        
        self.pageInfos = pageInfos
    }
    
    @objc func nextButtonClick(_ sender: Any?) {
        if let vc = self.viewControllers?.first,
            let index = self.orderedViewControllers.firstIndex(of: vc),
            index == self.orderedViewControllers.count - 1 {
            RMBTApplicationController.wizardDone()
            let delegate = UIApplication.shared.delegate as? RMBTAppDelegate
            delegate?.showMainScreen()
        }

        guard let vc = self.viewControllers?.first else { return }
        if let nextVC = self.pageViewController(self, viewControllerAfter: vc) {
            self.setViewControllers([nextVC], direction: .forward, animated: true)
        }
    }

    @objc func prevButtonClick(_ sender: Any?) {
        guard let vc = self.viewControllers?.first else { return }
        if let prevVC = self.pageViewController(self, viewControllerBefore: vc) {
            self.setViewControllers([prevVC], direction: .reverse, animated: true)
        }
    }
    
    func configure(viewController: RMBTWizardPageController, index: Int) {
        let pageInfo = self.pageInfos[index]
        viewController.titleText = pageInfo.title ?? ""
        viewController.subtitle = pageInfo.subtitle?.htmlAttributedString()
        viewController.icon = pageInfo.icon
        if pageInfo.identifier == .adsPersonalization {
            viewController.isShowStatus = true
            viewController.statusTitle = L("RMBT-SETTINGS-ADS-PERSONALISATION")
            viewController.status = !ASIdentifierManager.shared().isAdvertisingTrackingEnabled
        }
        viewController.setButtons(titles: pageInfo.buttons) { [weak self] (vc, index) in
            if let indexVC = self?.orderedViewControllers.firstIndex(of: vc) {
                let pageInfo = self?.pageInfos[indexVC]
                if pageInfo?.identifier == .welcome {
                }
                if pageInfo?.identifier == .location {
                    if CLLocationManager.authorizationStatus() == .notDetermined {
                        self?.locationManager.requestWhenInUseAuthorization()
                    }
                }
                if pageInfo?.identifier == .persistentClient {
                    RMBTSettings.sharedSettings.isClientPersistent = (index == 1)
                }
                if pageInfo?.identifier == .analytics {
                    RMBTSettings.sharedSettings.isAnalyticsEnabled = (index == 1)
                }
                if pageInfo?.identifier == .finishWithDarkMode {
                    RMBTSettings.sharedSettings.isDarkMode = (index == 1)
                    (UIApplication.shared.delegate as? RMBTAppDelegate)?.applyAppearance()
                }
            }
            
            self?.nextButtonClick(self)
        }
    }
}

extension WelcomeWizardPageViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.firstIndex(of: viewController) else { return nil }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else { return nil }
        
        guard orderedViewControllers.count > previousIndex else { return nil }
        
        if let viewController = orderedViewControllers[previousIndex] as? RMBTWizardPageController {
            configure(viewController: viewController, index: previousIndex)
            return viewController
        }
        
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.firstIndex(of: viewController) else { return nil }
        
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count
        
        guard orderedViewControllersCount != nextIndex else { return nil }
        
        guard orderedViewControllersCount > nextIndex else { return nil }
        
        if let viewController = orderedViewControllers[nextIndex] as? RMBTWizardPageController {
            configure(viewController: viewController, index: nextIndex)
            return viewController
        }
        
        return nil
    }
    
    func controller(with identifier: String) -> UIViewController {
        return UIStoryboard.wizardStoryboard().instantiateViewController(withIdentifier: identifier)
    }
}

//
//  UIStoryboard+Additions.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 10/13/18.
//  Copyright © 2018 SPECURE GmbH. All rights reserved.
//

import UIKit

extension UIStoryboard {
    class func main() -> UIStoryboard {
        return UIStoryboard(name: "ONT_iPhone", bundle: nil)
    }
    
    class func history() -> UIStoryboard {
        return UIStoryboard(name: "RMBTGenericHistory", bundle: nil)
    }
    
    class func historyResults() -> UIStoryboard {
        return UIStoryboard(name: "RMBTHistoryDetail", bundle: nil)
    }
    
    class func map() -> UIStoryboard {
        return UIStoryboard(name: "RMBTGenericMap", bundle: nil)
    }
    
    class func loopMode() -> UIStoryboard {
        return UIStoryboard(name: "RMBTLoopMode", bundle: nil)
    }

    class func wizardStoryboard() -> UIStoryboard {
        return UIStoryboard(name: "Wizard", bundle: nil)
    }
    
    class func privacyStoryboard() -> UIStoryboard {
        return UIStoryboard(name: "RMBTGenericPrivacy", bundle: nil)
    }
    
    class func settingsStoryboard() -> UIStoryboard {
        return UIStoryboard(name: "RMBTGenericSettings", bundle: nil)
    }
    
    class func infoStoryboard() -> UIStoryboard {
        return UIStoryboard(name: "RMBTGenericInfo", bundle: nil)
    }
    
    class func onboardWizzard() -> UIViewController {
        return UIStoryboard.wizardStoryboard().instantiateViewController(withIdentifier: "kWizardNavigationControllerID")
    }
    
    class func onePageOnboardWizard() -> UIViewController {
        return UIStoryboard.wizardStoryboard().instantiateViewController(withIdentifier: "kOnePageWizardNavigationControllerID")
    }
    
    class func tabBarController() -> UIViewController? {
        if UIDevice.isDeviceTablet() {
            return UIStoryboard.main().instantiateViewController(withIdentifier: "kTabBarControllerIPadID")
        } else {
            return UIStoryboard.main().instantiateViewController(withIdentifier: "kTabBarControllerID")
        }
    }
    
    class func homeScreen() -> UIViewController? {
        return UIStoryboard.main().instantiateInitialViewController()
    }
    
    class func testScreen() -> UIViewController? {
        return UIStoryboard.loopMode().instantiateInitialViewController()
    }
    
    class func historyScreen() -> UIViewController? {
        return UIStoryboard.history().instantiateInitialViewController()
    }
    
    class func resultsScreen() -> UIViewController? { // Return just view controller
        let vc = UIStoryboard.historyResults().instantiateViewController(withIdentifier: "result_vc")
        return vc
    }
    
    class func resultDetailsScreen() -> UIViewController? {
        let vc = UIStoryboard.historyResults().instantiateViewController(withIdentifier: "kRMBTHistoryResultDetailsViewControllerID")
        return vc
    }
    
    class func historyFilterScreen() -> UIViewController? {
        let vc = UIStoryboard.history().instantiateViewController(withIdentifier: "kRMBTHistoryFilterViewControllerID")
        return vc
    }
    
    class func qosResultsScreen() -> UIViewController? {
        let vc = UIStoryboard.historyResults().instantiateViewController(withIdentifier: "kQosMeasurementIndexTableViewControllerID")
        return vc
    }
    
    class func qosMeasurementTestScreen() -> UIViewController? {
        let vc = UIStoryboard.historyResults().instantiateViewController(withIdentifier: "kQosMeasurementTestTableViewControllerID")
        return vc
    }
    
    class func qosTestDetailsScreen() -> UIViewController? {
        let vc = UIStoryboard.historyResults().instantiateViewController(withIdentifier: "kQosMeasurementTestDetailTableViewControllerID")
        return vc
    }
    
    class func mapScreen() -> UIViewController? {
        return UIStoryboard.map().instantiateInitialViewController()
    }
    
    class func settingsScreen() -> UIViewController? {
        return UIStoryboard.settingsStoryboard().instantiateInitialViewController()
    }
    
    class func tos() -> UIViewController? {
        return UIStoryboard.privacyStoryboard().instantiateInitialViewController()
    }
    
    class func info() -> UIViewController? {
        return UIStoryboard.infoStoryboard().instantiateViewController(withIdentifier: "kInfoViewController")
    }
    
    class func loopModeAlert() -> UIViewController? {
        return UIStoryboard.loopMode().instantiateViewController(withIdentifier: "kLoopModeAlertViewControllerID")
    }
}

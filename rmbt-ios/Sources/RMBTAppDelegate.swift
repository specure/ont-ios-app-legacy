/*****************************************************************************************************
 * Copyright 2013 appscape gmbh
 * Copyright 2014-2016 SPECURE GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *****************************************************************************************************/

import Foundation
import GoogleMaps
import RMBTClient
import Firebase
import RealmSwift
//import FacebookCore
import FBSDKCoreKit
import GoogleMobileAds

//1/9dd6ddfbc5417f23cbb6576769c23c040caebecd
///
final class RMBTAppDelegate: UIResponder, UIApplicationDelegate {

    ///
    var window: UIWindow?
    let zeroMeasurementSynchronizer = RMBTZeroMeasurementSynchronizer.shared

    var mapOptions: RMBTMapOptions?
    
    ///
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        if RMBTSettings.sharedSettings.isAnalyticsEnabled {
            GADMobileAds.sharedInstance().start(completionHandler: nil)
            FirebaseApp.configure()

            let configuration = RMBTConfigFabric.config(with: RMBTConfigurationIdentifier)
            GMSServices.provideAPIKey(configuration.RMBT_GMAPS_API_KEY)
            LogConfig.initLoggingFramework()
        }
        
        self.initialize()
        window?.makeKeyAndVisible()
        return true
    }

    func initialize() {
//        LocaleManager.setup()
        
        if RMBTSettings.sharedSettings.isClientPersistent == false {
            RMBTConfig.clearStoredUUID()
        }
        UserDefaults.storeRequestUserAgent()
        _ = UserDefaults.checkFirstLaunch()
        
        logger.debug("START APP \(RMBTAppTitle()) (customer: \(RMBTAppCustomerName()))")
        
        // Supply Google Maps API Key only once during whole app lifecycle
        
        let configuration = RMBTConfigFabric.config(with: RMBTConfigurationIdentifier)
        // Override control servers configuration
        RMBTConfig.sharedInstance.configNewCS(server: configuration.RMBT_CONTROL_SERVER_URL)
        RMBTConfig.sharedInstance.configNewMeasurementCS(server: configuration.RMBT_CONTROL_MEASUREMENT_SERVER_URL)
        RMBTConfig.sharedInstance.configNewCS_IPv4(server: configuration.RMBT_CONTROL_SERVER_IPV4_URL)
        RMBTConfig.sharedInstance.configNewCS_IPv6(server: configuration.RMBT_CONTROL_SERVER_IPV6_URL)
        // Map server
        RMBTConfig.sharedInstance.configNewSuffixMapServer(server: configuration.RMBT_MAP_SERVER_PATH)
        RMBTConfig.sharedInstance.configNewMapServer(server: configuration.RMBT_MAP_SERVER_URL)
        RMBTConfig.sharedInstance.configNewCS_checkIPv4(server: configuration.RMBT_CHECK_IPV4_URL)
        RMBTConfig.sharedInstance.RMBT_DEFAULT_IS_CURRENT_COUNTRY = configuration.RMBT_DEFAULT_IS_CURRENT_COUNTRY
        //
        RMBTConfig.sharedInstance.RMBT_VERSION_NEW = configuration.RMBT_VERSION_NEW
        RMBTConfig.sharedInstance.settingsMode = configuration.RMBT_SETTINGS_MODE
        
        RMBTConfig.sharedInstance.RMBT_USE_MAIN_LANGUAGE = configuration.RMBT_USE_MAIN_LANGUAGE
        RMBTConfig.sharedInstance.RMBT_MAIN_LANGUAGE = configuration.RMBT_MAIN_LANGUAGE
        
        RMBTConfig.updateSettings(success: {
            self.zeroMeasurementSynchronizer.startSynchronization()
        }, error: { error in
            _ = UIAlertController.presentErrorAlert(error as NSError, dismissAction: nil)
        })
        
        self.configurationRateSystem()
        
        applyAppearance()
        onStart(true)
        /////////
        
        if let language = Locale.preferredLanguages.first {
            let attributes = ["Language": language]
            AnalyticsHelper.logCustomEvent(withName: "AppStartLocale", attributes: attributes)
        }
        
        self.realmMigration()

        if let window = self.window {
            if RMBTApplicationController.isNeedWizard && configuration.RMBT_IS_NEED_WIZARD {
                let wizard = UIStoryboard.onePageOnboardWizard()
                window.rootViewController = wizard
            } else if configuration.RMBT_VERSION == 3 {
                window.rootViewController = UIStoryboard.tabBarController()
            }
        }
        
        updateAndConfigureAdvertisingManager()
    }
    ///
    func applicationDidEnterBackground(_ application: UIApplication) {
        RMBTLocationTracker.sharedTracker.stop()
    }

    ///
    func applicationWillEnterForeground(_ application: UIApplication) {
        if RMBTSettings.sharedSettings.isClientPersistent == false {
            RMBTConfig.clearStoredUUID()
        }
        onStart(false)
        
        updateAndConfigureAdvertisingManager()
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        applyAppearance()
        AppEvents.activateApp()
    }

    func updateAndConfigureAdvertisingManager() {
        AnalyticsHelper.logCustomEvent(withName: "init.remove_ads_purchased", attributes: ["is_removed": RMBTSettings.sharedSettings.isAdsRemoved])
        
        let configuration = RMBTConfigFabric.config(with: RMBTConfigurationIdentifier)
        logger.debug("IS_SHOW_ADVERTISING=\(configuration.IS_SHOW_ADVERTISING)")
        logger.debug("RMBTSettings.sharedSettings.isAdsRemoved=\(RMBTSettings.sharedSettings.isAdsRemoved)")
        if configuration.IS_SHOW_ADVERTISING,
            RMBTSettings.sharedSettings.isAdsRemoved == false {
            RMBTConfig.updateAdvertisingSettings(success: {
                AnalyticsHelper.logCustomEvent(withName: "init.show_ads", attributes: ["is_show": RMBTClient.advertisingIsActive])
                if RMBTClient.advertisingIsActive == true,
                    RMBTClient.advertisingSettings?.adProvider == "AdMob",
                    let appId = RMBTClient.advertisingSettings?.appId,
                    let bannerId = RMBTClient.advertisingSettings?.bannerId {
                    GADMobileAds.sharedInstance().start(completionHandler: nil)
                    RMBTAdvertisingManager.shared.configureAdMobBanner(bannerId, appId: appId, rootViewController: self.window?.rootViewController)
                    RMBTAdvertisingManager.shared.reloadingAdMobBanner()
                }
            }, error: { (error) in
                logger.debug("advertising error:\(error.localizedDescription)")
            })
        }
        
//        #if DEBUG
//        GADMobileAds.configure(withApplicationID: "")
//        RMBTAdvertisingManager.shared.configureAdMobBanner("ca-app-pub-3940256099942544/6300978111", appId: "", rootViewController: self.window?.rootViewController)
//        RMBTAdvertisingManager.shared.reloadingAdMobBanner()
//        #endif
    }
    ///
    func onStart(_ isNewlyLaunched: Bool) {
        // checkDevMode()
        let configuration = RMBTConfigFabric.config(with: RMBTConfigurationIdentifier)
        if configuration.RMBT_IS_SHOW_TOS_ON_START {
            logger.info("App started")

            let tos = RMBTTOS.sharedTOS

            if tos.isCurrentVersionAccepted() {
                // init control server here if terms are accepted
                RMBTClient.refreshSettings()
            } else if isNewlyLaunched {
                // Re-check after TOS gets accepted, but don't re-add listener on every foreground
                tos.addObserver(self, forKeyPath: "lastAcceptedVersion", options: .new, context: nil)
            }
        }
    }

    ///
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        logger.debug("TOS accepted")
        RMBTClient.refreshSettings() // init control server here if terms recently got accepted
    }
    
    public func showMainScreen() {
        let mainViewController: UIViewController?
        let configuration = RMBTConfigFabric.config(with: RMBTConfigurationIdentifier)
        if configuration.RMBT_VERSION == 3 {
            mainViewController = UIStoryboard.tabBarController()
        } else {
            mainViewController = UIStoryboard.homeScreen()
        }
        if let window = self.window {
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
                self.window?.rootViewController?.dismiss(animated: false, completion: nil)
                self.window?.rootViewController = mainViewController
            }, completion: nil)
        }
    }
    
    public func showSettingsScreen() {
        let configuration = RMBTConfigFabric.config(with: RMBTConfigurationIdentifier)
        if configuration.RMBT_VERSION == 2 {
            let mainViewController = UIStoryboard.homeScreen() as? RMBTRootViewController
            mainViewController?.showViewController = .settings
            if let window = self.window {
                UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
                    self.window?.rootViewController?.dismiss(animated: false, completion: nil)
                    self.window?.rootViewController = mainViewController
                }, completion: nil)
            }
        } else {
            let mainViewController = UIStoryboard.tabBarController()
            if let window = self.window {
                UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
                    self.window?.rootViewController?.dismiss(animated: false, completion: nil)
                    self.window?.rootViewController = mainViewController
                    if let vc = mainViewController as? RMBTTabBarViewControllerProtocol {
                        vc.openSettings()
                    }
                }, completion: nil)
            }
        }
    }
    
    ///
    private func checkDevMode() {
        let RMBT_DEV_MODE_ENABLED_KEY = "RMBT_DEV_MODE_ENABLED"
        if let enabled = SharedKeychain.getBool(RMBT_DEV_MODE_ENABLED_KEY) {
            RMBTSettings.sharedSettings.debugUnlocked = enabled
        }

        logger.info("DEBUG UNLOCKED: \(RMBTSettings.sharedSettings.debugUnlocked)")
    }

    ///
    func applyAppearance() {
        // Background color
        UINavigationBar.appearance().barTintColor = RMBTColorManager.navigationBarBackground
        // Tint color
        UINavigationBar.appearance().tintColor = RMBTColorManager.navigationBarTitleColor
        
        UITabBar.appearance().tintColor = RMBTColorManager.tabBarSelectedColor
        UITabBar.appearance().barTintColor = RMBTColorManager.tabBarBackgroundColor
        if #available(iOS 10.0, *) {
            UITabBar.appearance().unselectedItemTintColor = RMBTColorManager.tabBarUnselectedColor
        } else {
            // Fallback on earlier versions
        }
        
        let textAttributes = [NSAttributedString.Key.foregroundColor: RMBTColorManager.navigationBarTitleColor,
                              NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .medium)]
        // Text color
        UINavigationBar.appearance().titleTextAttributes = textAttributes
        
        UIBarButtonItem.appearance().setTitleTextAttributes(textAttributes, for: .normal)
        
        UIBarButtonItem.appearance().setTitleTextAttributes(textAttributes, for: .highlighted)
        
//        UIApplication.shared.statusBarStyle = RMBTColorManager.statusBarStyle
        self.window?.rootViewController?.setNeedsStatusBarAppearanceUpdate()
    }
    
    func configurationRateSystem() {
        RMBTRateManager.manager.message = L("RMBT-RATE-MESSAGE")
        RMBTRateManager.manager.title = L("RMBT-RATE-TITLE")
        RMBTRateManager.manager.rateLabel = L("RMBT-RATE-RATE_LABEL")
        RMBTRateManager.manager.cancelLabel = L("RMBT-RATE-CANCEL_LABEL")
        RMBTRateManager.manager.remindLabel = L("RMBT-RATE-REMIND_LABEL")
        RMBTRateManager.manager.applicationId = Bundle.main.infoDictionary?["applicationID"] as? String
        RMBTRateManager.manager.completionHandler = { identifier, action in
        }
        
        RMBTRateManager.manager.isDisabled = false
    }

    func realmMigration() {
        Realm.Configuration.defaultConfiguration = Realm.Configuration(
            schemaVersion: 5,
            migrationBlock: { migration, oldSchemaVersion in
            }
        )
    }
    
    func application(_ application: UIApplication, shouldAllowExtensionPointIdentifier extensionPointIdentifier: UIApplication.ExtensionPointIdentifier) -> Bool {
        if extensionPointIdentifier == UIApplication.ExtensionPointIdentifier.keyboard {
            return false
        }
        
        return true
    }
}

extension UIApplicationDelegate {
    func tabBarController() -> RMBTRootTabBarViewController? {
        let navController = self.window??.rootViewController as? UINavigationController
        for vc in navController?.viewControllers ?? [] {
            if let tabBarController = vc as? RMBTRootTabBarViewController {
                return tabBarController
            }
        }
        return nil
    }
}

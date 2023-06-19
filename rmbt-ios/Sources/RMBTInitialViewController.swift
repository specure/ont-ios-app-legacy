//
//  RMBTInitialViewController.swift
//  RMBT
//
//  Created by Tomáš Baculák on 14/01/15.
//  Copyright © 2015 SPECURE GmbH. All rights reserved.
//

import UIKit
import CoreLocation
import GoogleMobileAds

protocol RMBTManageMainView: ManageHardware, WallGarden, ManageConnectivity {
    
}

///
 class RMBTInitialViewController: TopLevelViewController, RMBTManageMainView, MeasurementViewMapButton {
    func connectivityNetworkTypeDidChange(connectivity: RMBTConnectivity) {
        
    }
    
    ///
    func connectivityTrackerDidDetectNoConnectivity(_ tracker: RMBTConnectivityTracker) {
        
        manageViewInactiveConnect()
        resetAddressStatistics()
        //
        DispatchQueue.main.async {
            self.networkTypeImageView?.image = UIImage(named: "intro_none")
        }
        
        self.protocolView?.connectivityDidChange()
    }
    
    func connectivityTracker(_ tracker: RMBTConnectivityTracker, didStopAndDetectIncompatibleConnectivity connectivity: RMBTConnectivity) {
        
    }
    ///
    func connectivityTracker(_ tracker: RMBTConnectivityTracker, didDetectConnectivity connectivity: RMBTConnectivity) {
        
        manageViewAfterDidConnect(connectivity: connectivity)
        resetAddressStatistics()
        
        //
        self.currentConnectivityNetworkType = connectivity.networkType
        
        DispatchQueue.main.async {
            
            if connectivity.networkType == .wiFi {
                self.networkTypeImageView?.image = UIImage(named: "wifi")?.tintedImageUsingColor(tintColor: RMBT_TINT_COLOR)
            } else if connectivity.networkType == .cellular {
                self.networkTypeImageView?.image = UIImage(named: "mobil4")?.tintedImageUsingColor(tintColor: RMBT_TINT_COLOR)
            }
            
            self.protocolView?.connectivityDidChange()
        }
        
        // check walled garden !!!!
        self.checkWalledGarden()
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { return .portrait }
    
    override var shouldAutorotate: Bool {
        if UIApplication.shared.statusBarOrientation != .portrait {
            return true
        }
        return false
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation { return .portrait }
    
    override open var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            return .darkContent
        } else {
            return .default
        }
    }
    
    let locationManager = CLLocationManager() // Need only for authorization request permission
    
    /// ONT
    //
    @IBOutlet var startBackgroundView: UIView?
    //
    @IBOutlet var mapBackgroundView: UIView?

    @IBOutlet weak var backgroundImage: UIImageView?
    //
    ///
    internal var ipAddressUpdateCount = 0
    ///
    internal var ipAddressLastUpdated: UInt64 = 0
    //
    ///
    internal var connectivityTracker: RMBTConnectivityTracker?
    ///
    internal var currentConnectivityNetworkType: RMBTNetworkType? = RMBTNetworkType.none
    ///
    internal var simpleTimer: Timer?
    ///
    internal var simpleTimerFireInterval: TimeInterval = 1
    //
    ///
    @IBOutlet internal var networkTypeLabel: UILabel?
    ///
    @IBOutlet internal var networkNameLabel: UILabel?
    ///
    @IBOutlet internal var networkTypeImageView: UIImageView?
    ///
    @IBOutlet internal var startTestButton: UIButton?
    /// MeasurementViewMapButton
    @IBOutlet internal var mapButton: UIButton?
    //
    ///
    @IBOutlet internal var walledGardenImageView: UIImageView?
    //
    ///
    @IBOutlet internal var hardwareView: RMBTPUHardwareView?
    ///
    @IBOutlet internal var protocolView: RMBTPUProtocolView?
    ///
    @IBOutlet internal var locationView: RMBTPULocationView?
    ///
    @IBOutlet internal var trafficView: RMBTPUTrafficView?
    ///
    @IBOutlet internal var serversView: RMBTPUServersViews?
    ///
    @IBOutlet internal var bottomView: UIView?
    ///
    @IBOutlet internal var consumptionButton: UIButton?
    //
    @IBOutlet internal var consumptionLabel: UILabel?
    //
    @IBOutlet internal var networkTitleLable: UILabel?
    //
    @IBOutlet internal weak var consumptionWarningLabel: UILabel!
    
    @IBOutlet internal weak var contentScrollView: UIScrollView!

    @IBOutlet weak var mapBackgroundViewCenterYConstraint: NSLayoutConstraint!
    @IBOutlet internal weak var consumptionLabelRightConstraint: NSLayoutConstraint!
    @IBOutlet internal weak var consumptionLabelLeftConstraint: NSLayoutConstraint!
    @IBOutlet internal weak var consumptionLabelBottomConstraint: NSLayoutConstraint!
    @IBOutlet internal weak var consumptionButtonCenterConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var rightMarginButtonsViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var leftMarginButtonsViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var buttonsViewWidthConstraint: NSLayoutConstraint?
    @IBOutlet weak var centerXButtonsViewConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var serverTopConstraint: NSLayoutConstraint?
    @IBOutlet weak var startDefaultConstraint: NSLayoutConstraint!
    ///
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.backgroundImage?.image = INITIAL_BACKGROUND_IMAGE
        ///
        // Start tracking if possible
        _ = RMBTLocationTracker.sharedTracker.startIfAuthorized()
        
        //
        // self.navigationController?.delegate = self
        let configuration = RMBTConfigFabric.config(with: RMBTConfigurationIdentifier)
        if configuration.RMBT_IS_SHOW_TOS_ON_START {
            let tos = RMBTTOS.sharedTOS

            // If user hasn't agreed to new TOS version, show TOS modally
            if !tos.isCurrentVersionAccepted() {
                //RMBTLog("Current TOS version %d > last accepted version %d, showing dialog", tos.currentVersion, tos.lastAcceptedVersion)
                self.performSegue(withIdentifier: "show_tos", sender: self)
            }
        }
        
        // UI init
//        initViewObjets()
        if UIScreen.main.bounds.size.height > 500 {
            let scale = UIScreen.main.bounds.size.height / 560.0
            let offsetNetwork = 480 - 480 * scale
            
            self.serverTopConstraint?.constant -= offsetNetwork * 0.8
        }
        
        self.leftMarginButtonsViewConstraint.priority = .defaultHigh
        self.rightMarginButtonsViewConstraint.priority = .defaultHigh
        self.centerXButtonsViewConstraint.priority = .defaultLow
        self.buttonsViewWidthConstraint?.priority = .defaultLow
        //Move down lower circle for iPhone X, XS, XS Max
        if UIDevice.isDeviceTablet() {
//            self.mapBackgroundViewCenterYConstraint.constant = 0
            self.leftMarginButtonsViewConstraint.priority = .defaultLow
            self.rightMarginButtonsViewConstraint.priority = .defaultLow
            self.centerXButtonsViewConstraint.priority = .defaultHigh
            self.buttonsViewWidthConstraint?.priority = .defaultHigh
            self.buttonsViewWidthConstraint?.constant = min(UIScreen.main.bounds.width, UIScreen.main.bounds.height) - 50
            self.startDefaultConstraint.constant = 0
            self.mapBackgroundViewCenterYConstraint.constant = 70
        } else if UIScreen.main.bounds.size.height >= 812 {
            self.mapBackgroundViewCenterYConstraint.constant = 70
        }
        //Increase fonts for iPhone XS Max
        if UIScreen.main.bounds.size.height >= 868 {
            let boldFont = UIFont.systemFont(ofSize: 12, weight: .bold)
            self.trafficView?.titleLabel?.font = boldFont
            self.hardwareView?.cpuTitleLabel?.font = boldFont
            self.hardwareView?.ramTitleLabel?.font = boldFont
            self.hardwareView?.cpuValueLabel?.font = boldFont
            self.hardwareView?.ramValueLabel?.font = boldFont
            self.serversView?.titleLabel?.font = boldFont
            self.serversView?.measurementServerLabel?.font = boldFont
            self.networkTitleLable?.font = boldFont
            self.networkNameLabel?.font = boldFont
            self.locationView?.locationTitleLabel?.font = boldFont
            self.locationView?.locationValueLabel?.font = boldFont
            self.protocolView?.statusView4Label?.font = boldFont
            self.protocolView?.statusView6Label?.font = boldFont
            
            let regularFont = UIFont.systemFont(ofSize: 16, weight: .regular)
            self.consumptionLabel?.font = regularFont
            self.consumptionWarningLabel.font = regularFont
        }
        
        self.updateColorForNavigationBarAndTabBar()
        self.applyColorScheme()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        guard UIApplication.shared.applicationState == .inactive else {
            return
        }
        
        self.updateColorForNavigationBarAndTabBar()
        self.applyColorScheme()
    }
    
    override func applyColorScheme() {
        self.navigationController?.navigationBar.barTintColor = RMBT_DARK_COLOR
        self.navigationController?.navigationBar.tintColor = RMBT_TINT_COLOR
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: RMBT_TINT_COLOR]
        self.locationView?.backgroundColor = UIColor.clear
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        RMBTAdvertisingManager.shared.reloadingAdMobBanner()
        let configuration = RMBTConfigFabric.config(with: RMBTConfigurationIdentifier)
        if RMBTTOS.sharedTOS.isCurrentVersionAccepted() || configuration.RMBT_IS_SHOW_TOS_ON_START == false {
            if CLLocationManager.authorizationStatus() == .notDetermined {
                locationManager.requestWhenInUseAuthorization()
            }
        }
        
        setNeedsStatusBarAppearanceUpdate()
    }
    ///
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        initViewObjets()
        startConnectivityTracker()
        initUpdateTimer()
        self.updateColorForNavigationBarAndTabBar()
        self.applyColorScheme()
    }

    ///
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        stopConnectivityTracker()
        discartUpdateTimer()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if UIDevice.isDeviceTablet() {
            self.buttonsViewWidthConstraint?.constant = min(UIScreen.main.bounds.width, UIScreen.main.bounds.height) - 50
        }
    }
    
    //
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "pushTestResultsView" {
            if let trController = segue.destination as? RMBTHistoryResultViewController {
                trController.historyResult = sender as? RMBTHistoryResult
            }
        }
        
        if segue.identifier == "pushMapViewFromMainView" {
            if let nc = segue.destination as? UINavigationController {
                if let trController = nc.topViewController as? RMBTMapViewController {
                    trController.isModal = true
                }
            }
        }
        
        if segue.identifier == "pushMeasurement" {
            if let trController = segue.destination as? RMBTTesterViewController {
                if let netName = networkNameLabel?.text {
                    trController.networkNameString = netName
                }
            }
        }
        
        if segue.identifier == "show_map" {
            if let navController = segue.destination as? UINavigationController,
                let trController = navController.topViewController as? RMBTMapViewController {
                trController.initialLocation = RMBTLocationTracker.sharedTracker.location
                trController.revealControllerEnabled = false
                trController.isModal = true
            }
        }
    }

    ///
    @IBAction func showConsumptionAlert() {
        if self.contentScrollView.contentOffset.y > 0 {
            self.contentScrollView.setContentOffset(CGPoint(), animated: true)
        } else {
            var frame = self.consumptionWarningLabel.frame
            frame.size.height += 20
            self.contentScrollView.scrollRectToVisible(frame, animated: true)
        }
    }
    //
    @IBAction func startTest(sender: AnyObject) {
        startTestNow()
    }

    private func startTestNow() {
        UIApplication.shared.isIdleTimerDisabled = true // Disallow turning off the screen

        RMBTLocationTracker.sharedTracker.startAfterDeterminingAuthorizationStatus {
            self.performSegue(withIdentifier: "pushMeasurement", sender: nil)
        }
    }
    
// MARK: Segues and actions

    ///
    @IBAction func showHelp(sender: AnyObject) {
        let configuration = RMBTConfigFabric.config(with: RMBTConfigurationIdentifier)
        presentModalBrowserWithURLString(configuration.RMBT_HELP_URL)
    }
    
    ///
// Helpers
    //
    private func initViewObjets() {
        //
        getMeasurementServerInfo(success: { response in
            self.serversView?.items = response.servers
        }, error: { _ in
        
        })
        
        // color - subviews
        self.trafficView?.titleLabel?.textColor = INITIAL_SCREEN_TEXT_COLOR
        self.hardwareView?.cpuTitleLabel?.textColor = INITIAL_SCREEN_TEXT_COLOR
        self.hardwareView?.ramTitleLabel?.textColor = INITIAL_SCREEN_TEXT_COLOR
        self.locationView?.locationTitleLabel?.textColor = INITIAL_SCREEN_TEXT_COLOR
//        self.networkNameLabel?.textColor = INITIAL_SCREEN_TEXT_COLOR
        self.networkTypeLabel?.textColor = INITIAL_SCREEN_TEXT_COLOR
        self.networkTitleLable?.textColor = INITIAL_SCREEN_TEXT_COLOR
        self.serversView?.titleLabel?.textColor = INITIAL_SCREEN_TEXT_COLOR
        self.serversView?.iconImageView?.image = self.serversView?.iconImageView?.image?.tintedImageUsingColor(tintColor: RMBT_TINT_COLOR)
        
        self.consumptionButton?.buttonWithColor(RMBT_TINT_COLOR)
            
        //
        consumptionLabel?.text = L("RBMT-CONSUMPTION")
        consumptionWarningLabel?.text = String.localizedStringWithFormat(L("test.intro-message"), RMBTAppTitle(), RMBTAppCustomerName())
        //
        networkTitleLable?.text = LC("history.result.headline.network")
        
        //
        formatConnectivityLabels()
        
        // hardware views
        initInteractiveSubviews()
        
        // hide shadow image of navigation bar
        self.navigationController?.hideSelf()
        
        self.cleanConnectivityLabels()
        self.cleanNetworkImageView()
        // ??
        // view.applyGradient()
        
        // 4S UI hack
        if self.view.frameHeight < 500 {
            self.consumptionLabelBottomConstraint.constant -= 50
            self.consumptionLabelLeftConstraint.constant += 20
            self.consumptionLabelRightConstraint.constant -= 20
            self.consumptionButtonCenterConstraint.constant -= 120
            
            self.serverTopConstraint?.constant = 102
            self.startDefaultConstraint.constant = 37
        }
        
//        mapBackgroundView?.makeFancyCircles(clockWise: false)
//        startBackgroundView?.makeFancyCircles(clockWise: true)
//        startTestButton?.formatONTStartButton()
        
        view.backgroundColor = INITIAL_VIEW_BACKGROUND_COLOR
        bottomView?.backgroundColor = INITIAL_BOTTOM_VIEW_BACKGROUND_COLOR
    }
}
 
 ///
 // MARK: - Update view Delegate
 extension RMBTInitialViewController {
    
    func updateTimerFired() {
        updateSubviews()
    }
 }
 
 //
 // MARK: - SWRevealViewController Delegate
 extension RMBTInitialViewController {
    ///
    override func revealController(_ revealController: SWRevealViewController!, didMoveTo position: FrontViewPosition) {
        
        let enableAction: Bool = position == .left ? true : false
        
        enableHardwareView(enableAction)
        startTestButton?.isUserInteractionEnabled = enableAction
    }
 }
 
// // MARK: Animation delegate
// extension RMBTInitialViewController: UINavigationControllerDelegate {
//
//    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//
//        if operation == .push { return pushAnimator() }
//        if operation == .pop { return popAnimator() }
//
//        return nil
//    }
// }
 

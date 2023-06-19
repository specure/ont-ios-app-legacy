//
//  RMBTLoopModeInitViewController.swift
//  RMBT_ONT
//
//  Created by Sergey Glushchenko on 7/22/18.
//  Copyright © 2018 SPECURE GmbH. All rights reserved.
//

import UIKit
import CoreLocation
import CoreTelephony

class RMBTLoopModeInitViewController: TopLevelViewController, ManageConnectivity, RMBTManageMainView {
    
    private let changeServerSegue = "changeServerSegue"
    private let startLoopModeSegue = "startLoopModeSegue"
    private let startTestSegue = "startTestSegue"
    
    @IBOutlet var networkTypeImageView: UIImageView?
    
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var systemInfoView: UIView!
    @IBOutlet weak var heightTestButtonConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var testButtonAreaRightConstraint: NSLayoutConstraint!
    @IBOutlet weak var testButtonAreaWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var systemInfoPortraitTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var systemInfoRightConstraint: NSLayoutConstraint!
    @IBOutlet weak var systemInfoLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var systemInfoWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var systemInfoTopConstraint: NSLayoutConstraint!
    
    @IBOutlet var loopModeBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var networkTitleLabel: UILabel!
    @IBOutlet var networkTypeLabel: UILabel?
    
    @IBOutlet weak var networkNameTitleLabel: UILabel!
    @IBOutlet var networkNameLabel: UILabel?
    
    @IBOutlet var startTestButton: UIButton?
 
    @IBOutlet weak var changeServerButton: UIButton!
    @IBOutlet weak var changeServerBackgroundView: UIView!
    @IBOutlet weak var arrowRightImageView: UIImageView!
    
    @IBOutlet internal var locationView: RMBTPULocationView?
    
    lazy var loopModeOnBarButtonItem: UIBarButtonItem = {
        let title = L("loopmode.init.btn.loop.on")
        let barButtonItem = UIBarButtonItem(title: title, style: loopModeBarButtonItem.style, target: loopModeBarButtonItem.target, action: loopModeBarButtonItem.action)
        barButtonItem.setTitleTextAttributes([.foregroundColor: RMBTColorManager.navigationBarTitleColor], for: .normal)
        return barButtonItem
    }()
    
    lazy var loopModeOffBarButtonItem: UIBarButtonItem = {
        let title = L("loopmode.init.btn.loop.off")
        let barButtonItem = UIBarButtonItem(title: title, style: loopModeBarButtonItem.style, target: loopModeBarButtonItem.target, action: loopModeBarButtonItem.action)
        barButtonItem.setTitleTextAttributes([.foregroundColor: RMBTColorManager.navigationBarTitleColor], for: .normal)
        return barButtonItem
    }()
    
    let locationManager = CLLocationManager() // Need only for authorization request permission
    
    var mapButton: UIButton?
    
    var hardwareView: RMBTPUHardwareView?
    
    var protocolView: RMBTPUProtocolView?
    
    var trafficView: RMBTPUTrafficView?
    
    var walledGardenImageView: UIImageView?
    
    var simpleTimer: Timer?
    
    var simpleTimerFireInterval: TimeInterval = 1.0
    
    var ipAddressUpdateCount: Int = 0
    
    var ipAddressLastUpdated: UInt64 = 0
    
    var connectivityTracker: RMBTConnectivityTracker?
    
    internal var currentConnectivityNetworkType: RMBTNetworkType? = .none
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return RMBTColorManager.statusBarStyle
    }
    
    var servers: [MeasurementServerInfoResponse.Servers] = [] {
        didSet {
//            tableView.reloadData()
        }
    }
    
    var currentServer: MeasurementServerInfoResponse.Servers?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.tabBarItem.title = L("tabbar.title.test")
        self.tabBarItem.image = UIImage(named: "navbar_test_dark")
        self.navigationController?.tabBarItem = self.tabBarItem
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.locationManager.delegate = self
        
        self.title = L("test.init.title")
        
        RMBTAdvertisingManager.shared.reloadingAdMobBanner()
        if RMBT_TEST_LOOPMODE_ENABLE == false {
            self.navigationItem.rightBarButtonItem = nil
            RMBTSettings.sharedSettings.debugLoopMode = false
        }
        self.networkNameTitleLabel.text = LC("test.network")
        self.networkTitleLabel.text = LC("history.filter.networktype")
        self.startTestButton?.setTitle(L("loopmode.init.btn.test"), for: .normal)
        self.startTestButton?.titleLabel?.numberOfLines = 0
        self.startTestButton?.titleLabel?.textAlignment = .center

        self.setDefaultServer()
        
        self.updateLoopModeSwitcher()
        
        self.applyColorScheme()
        self.updateColorForNavigationBarAndTabBar()
        self.updateUIComponents()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        guard UIApplication.shared.applicationState == .inactive else {
            return
        }
        
        self.applyColorScheme()
        self.updateColorForNavigationBarAndTabBar()
    }
    
    override func applyColorScheme() {
        self.view.backgroundColor = RMBTColorManager.background

        let image = arrowRightImageView.image?.withRenderingMode(.alwaysTemplate)
        arrowRightImageView.image = image
        arrowRightImageView.tintColor = RMBTColorManager.currentServerTitleColor
        
        changeServerButton.setTitleColor(RMBTColorManager.currentServerTitleColor, for: .normal)
        separatorView.backgroundColor = RMBTColorManager.tableViewSeparator
        startTestButton?.backgroundColor = RMBTColorManager.tintColor
        startTestButton?.setTitleColor(RMBTColorManager.buttonTitleColor, for: .normal)
        startTestButton?.setTitleColor(RMBTColorManager.buttonTitleColor, for: .highlighted)
        startTestButton?.tintColor = RMBTColorManager.tintColor
        
        if let button = startTestButton as? RMBTGradientButton {
            button.colors = [
                RMBTColorManager.tintPrimaryColor,
                RMBTColorManager.tintSecondaryColor
            ]
        }
        
        networkTitleLabel.textColor = RMBTColorManager.networkInfoTitleColor
        networkNameTitleLabel.textColor = RMBTColorManager.networkInfoTitleColor
        locationView?.locationTitleLabel?.textColor = RMBTColorManager.networkInfoTitleColor
        
        networkNameLabel?.textColor = RMBTColorManager.networkInfoValueColor
        networkTypeLabel?.textColor = RMBTColorManager.networkInfoValueColor
        locationView?.locationValueLabel?.textColor = RMBTColorManager.networkInfoValueColor
        locationView?.locationPositionLabel?.textColor = RMBTColorManager.networkInfoValueColor

        self.updateLoopModeBarItem()
    }
    
    func updateLoopModeBarItem() {
        if let loopModeBarButtonItem = self.loopModeBarButtonItem {
            self.navigationItem.rightBarButtonItem = RMBTSettings.sharedSettings.debugLoopMode ? self.loopModeOnBarButtonItem : self.loopModeOffBarButtonItem
            
            self.parent?.navigationItem.rightBarButtonItem = RMBTSettings.sharedSettings.debugLoopMode ? self.loopModeOnBarButtonItem : self.loopModeOffBarButtonItem
            
            self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([.foregroundColor: RMBTColorManager.navigationBarTitleColor], for: .normal)
            self.parent?.navigationItem.rightBarButtonItem?.setTitleTextAttributes([.foregroundColor: RMBTColorManager.navigationBarTitleColor], for: .normal)
            
            self.navigationItem.rightBarButtonItem?.tintColor = RMBTColorManager.navigationBarTitleColor
            
            self.parent?.navigationItem.rightBarButtonItem?.tintColor = RMBTColorManager.navigationBarTitleColor
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.updateLoopModeSwitcher()
        self.applyColorScheme()
        self.updateColorForNavigationBarAndTabBar()
        self.updateHeightMainContainer()
        
        let configuration = RMBTConfigFabric.config(with: RMBTConfigurationIdentifier)
        if RMBTTOS.sharedTOS.isCurrentVersionAccepted() || configuration.RMBT_IS_SHOW_TOS_ON_START == false {
            if CLLocationManager.authorizationStatus() == .notDetermined {
                locationManager.requestWhenInUseAuthorization()
            }
        }
        
        self.reloadServers()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if UIApplication.shared.statusBarOrientation.isLandscape && UIDevice.isDeviceTablet() == false {
            self.testButtonAreaWidthConstraint.priority = .defaultHigh
            self.testButtonAreaRightConstraint.priority = .defaultLow
            self.systemInfoTopConstraint.priority = .defaultHigh
            self.systemInfoLeftConstraint.priority = .defaultLow
            self.systemInfoWidthConstraint.priority = .defaultHigh
            self.systemInfoPortraitTopConstraint.priority = .defaultLow
        } else {
            self.testButtonAreaWidthConstraint.priority = .defaultLow
            self.testButtonAreaRightConstraint.priority = .defaultHigh
            self.systemInfoTopConstraint.priority = .defaultLow
            self.systemInfoLeftConstraint.priority = .defaultHigh
            self.systemInfoWidthConstraint.priority = .defaultLow
            self.systemInfoPortraitTopConstraint.priority = .defaultHigh
        }
        
        self.updateHeightMainContainer()
    }
    
    func updateUIComponents() {
        let width = self.startTestButton?.constraint(with: UIView.ConstraintIdentifier.width.rawValue)
        let height = self.startTestButton?.constraint(with: UIView.ConstraintIdentifier.height.rawValue)
        
        if UIDevice.isDeviceTablet() {
            width?.constant = 310
            height?.constant = 310
            let font = UIFont.systemFont(ofSize: 48, weight: .light)
            self.startTestButton?.titleLabel?.font = font
        }
    }
    
    func updateHeightMainContainer() {
        if UIDevice.isDeviceTablet() {
            let startTestButtonWidth = self.startTestButton?.frameWidth ?? 0.0
            self.systemInfoLeftConstraint.constant = (self.view.frameWidth - startTestButtonWidth - 80) / 2
            self.systemInfoRightConstraint.constant = self.systemInfoLeftConstraint.constant
            
            heightTestButtonConstraint.constant = self.view.frameHeight / 2
            
            let startButtonHeight = self.startTestButton?.frameHeight ?? 0.0
            let halfScreenHeight = self.view.frameHeight / 2
            let testButtonPadding = (halfScreenHeight - startButtonHeight) / 2
            let maxYTestButton = testButtonPadding + startButtonHeight
            let systemInfoHeightArea = self.view.frameHeight - maxYTestButton
            let systemInfoEmptySpace = systemInfoHeightArea - self.systemInfoView.frameHeight
            let systemInfoPaddings = systemInfoEmptySpace / 2
            let padding = systemInfoPaddings - testButtonPadding - 20
            self.systemInfoPortraitTopConstraint.constant = padding
        } else {
            if UIApplication.shared.statusBarOrientation.isPortrait {
                let height = (self.view.frameHeight - self.changeServerBackgroundView.frameHeight) / 2

                if self.systemInfoView.frame.maxY >= self.view.frameHeight - 10 {
                    heightTestButtonConstraint.constant = height - (self.systemInfoView.frame.maxY - (self.view.frameHeight - 10))
                } else {
                    heightTestButtonConstraint.constant = height
                }
            } else {
                var height = self.view?.frameHeight ?? 0.0
                height -= self.changeServerBackgroundView.frameHeight + 20
                heightTestButtonConstraint.constant = height
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        startConnectivityTracker()
        initUpdateTimer()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        stopConnectivityTracker()
        discartUpdateTimer()
        
        super.viewWillDisappear(animated)
    }
    
    func reloadServers() {
        getMeasurementServerInfo(success: { [weak self] response in
            self?.servers = response.servers ?? []
            self?.setDefaultServer()
            }, error: { _ in
                
        })
    }
    
    func setDefaultServer() {
        let ms = self.servers.filter({ item in
            if let server = RMBTConfig.sharedInstance.measurementServer {
                return item.id?.intValue == server.id?.intValue
            } else if let serverId = RMBTApplicationController.measurementServerId {
                return item.id?.intValue == serverId
            } else {
                return false
            }
        })
        
        if ms.count > 0 {
            if let server = ms.first {
                self.assignNewServer(theServer: server)
            }
        } else {
            if let server = self.servers.first {
                self.assignNewServer(theServer: server)
            }
        }
    }
    
    func isQOSEnabled() -> Bool {
        if RMBTSettings.sharedSettings.nerdModeQosEnabled == RMBTSettings.NerdModeQosMode.always.rawValue {
            return true
        } else if RMBTSettings.sharedSettings.nerdModeQosEnabled == RMBTSettings.NerdModeQosMode.newNetwork.rawValue {
            if self.networkNameLabel?.text != RMBTSettings.sharedSettings.previousNetworkName {
                return true
            }
        }
        
        return false
    }
    
    private func assignNewServer(theServer: MeasurementServerInfoResponse.Servers) {
        RMBTConfig.sharedInstance.measurementServer = theServer
        self.currentServer = theServer
        changeServerButton.setTitle(theServer.fullNameWithDistanceAndSponsor, for: .normal)
    }
    
    @IBAction func loopModeSwitched(_ sender: Any) {
        if RMBTSettings.sharedSettings.debugLoopMode == false {
            if let navController = UIStoryboard.loopModeAlert() as? UINavigationController,
                let vc = navController.viewControllers.first as? RMBTLoopModeAlertViewController {
                vc.onComplete = { [weak self] in
                    self?.updateLoopModeSwitcher()
                }
                self.present(navController, animated: true, completion: nil)
            }
        } else {
            RMBTSettings.sharedSettings.debugLoopMode = false
        }
        self.updateLoopModeSwitcher()
    }
    
    func updateLoopModeSwitcher() {
        let startButtonTitle = RMBTSettings.sharedSettings.debugLoopMode ? L("loopmode.init.btn.loop-test") : L("loopmode.init.btn.test")
        self.startTestButton?.setTitle(startButtonTitle, for: .normal)
        self.updateLoopModeBarItem()
    }
    
    @IBAction func startTestButtonClick(_ sender: Any) {
        if self.servers.count > 0 {
            if RMBT_TEST_LOOPMODE_ENABLE && RMBTSettings.sharedSettings.debugLoopMode {
                self.performSegue(withIdentifier: self.startLoopModeSegue, sender: self)
            } else {
                self.performSegue(withIdentifier: self.startTestSegue, sender: self)
            }
        } else {
            _ = UIAlertController.presentAlert(L("history.error.server_not_available")) { (_) in
            }
        }
    }
    
    @IBAction func changeServerButtonClick(_ sender: Any) {
        self.performSegue(withIdentifier: self.changeServerSegue, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == self.changeServerSegue,
            let vc = segue.destination as? RMBTChangeServerViewController {
            vc.servers = servers
            vc.currentServer = currentServer
            vc.onServerSelected = { [weak self] server in
                if let server = server {
                    self?.assignNewServer(theServer: server)
                }
            }
        }
        if segue.identifier == self.startTestSegue,
            let vc = segue.destination as? RMBTTestViewController {
            vc.isQosEnabled = self.isQOSEnabled()
            vc.networkInfo = RMBTNetworkInfo(
                 location: self.locationView?.locationValueLabel?.text,
                 networkType: self.networkTypeLabel?.text,
                 networkName: self.networkNameLabel?.text,
                 networkLocation: self.locationView?.locationPositionLabel?.text)
            vc.heightForMainArea = self.heightTestButtonConstraint.constant
        }
        if segue.identifier == self.startLoopModeSegue,
            let vc = segue.destination as? RMBTLoopModeViewController {
            vc.networkInfo = RMBTNetworkInfo(
                location: self.locationView?.locationValueLabel?.text,
                networkType: self.networkTypeLabel?.text,
                networkName: self.networkNameLabel?.text,
                networkLocation: self.locationView?.locationPositionLabel?.text)
            vc.heightForMainArea = self.heightTestButtonConstraint.constant
        }
    }
    
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
    
    func connectivityNetworkTypeDidChange(connectivity: RMBTConnectivity) {
        
    }
    
    func connectivityTracker(_ tracker: RMBTConnectivityTracker, didStopAndDetectIncompatibleConnectivity connectivity: RMBTConnectivity) {
        
    }
    
    func connectivityTrackerDidDetectNoConnectivity(_ tracker: RMBTConnectivityTracker) {
        manageViewInactiveConnect()
        resetAddressStatistics()
        //
        DispatchQueue.main.async {
            self.networkTypeImageView?.image = UIImage(named: "intro_none")
        }
        
        self.protocolView?.connectivityDidChange()
    }
}

extension RMBTLoopModeInitViewController {
    
    func updateTimerFired() {
        updateSubviews()
    }
}

extension RMBTLoopModeInitViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.reloadServers()
    }
}

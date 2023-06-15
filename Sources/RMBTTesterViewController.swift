//
//  RMBTTesterViewController.swift
//  RMBT
//
//  Created by Tomáš Baculák on 03/02/15.
//  Copyright © 2015 SPECURE GmbH. All rights reserved.
//

import UIKit

///
struct QosTestStatus {
    var testType: QosMeasurementType
    var status: Bool
}

///
struct MTestStatus {
    var testName: String
    var status: Bool
    var value: String
}

///
class RMBTTesterViewController: TopLevelViewController, ManageMeasurement, ManageConnectivity {
    func manageViewControllerAbort() {
        //Nothing we already make it in manageViewsAbort
    }
    
    func connectivityTrackerDidDetectNoConnectivity(_ tracker: RMBTConnectivityTracker) {
        manageViewInactiveConnect()
    }
    
    func connectivityNetworkTypeDidChange(connectivity: RMBTConnectivity) {
        if self.rmbtClient.running {
            self.rmbtClient.stopMeasurement()
            _ = UIAlertController.presentDidFailAlert(.mixedConnectivity,
                                                  dismissAction: ({ [weak self] _ in self?.manageViewsAbort() }),
                                                  startAction: ({ [weak self] _ in self?.startMeasurementAction() })
            )
        }
    }
    
    @IBOutlet var startTestButton: UIButton?
    @IBOutlet var networkTypeLabel: UILabel?
    @IBOutlet var networkNameLabel: UILabel?
    
    var connectivityTracker: RMBTConnectivityTracker?
    var currentConnectivityNetworkType: RMBTNetworkType?
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { return .portrait }
    
    override var shouldAutorotate: Bool {
        if UIApplication.shared.statusBarOrientation != .portrait {
            return true
        }
        return false
    }
    ///
    var networkNameString = "n/a"
    
    ///
    internal var wasTestExecuted: Bool = false
    ///
    internal var isQosAvailable: Bool = false
    ///
    internal var measurementResultUuid: String?
    /// action defined in the folowing view to trigger automaticcaly
    internal var runAgain: Bool = false
    ///
    internal var rmbtClient = RMBTClient(withClient: .standard) {
        didSet {
            rmbtClient.isStoreZeroMeasurement = RMBTSettings.sharedSettings.submitZeroTesting && TEST_STORE_ZERO_MEASUREMENT
            rmbtClient.isQOSEnabled = self.isQOSEnabled()
        }
    }

    override open var preferredStatusBarStyle: UIStatusBarStyle {
        if TEST_BACKGROUND_STYLE_LIGHT {
            return .default
        }
        return .lightContent
    }
    
    var previousSpeed: Double = 0.0
    var targetSpeed: Double = 0.0
    
    var previousBackStartAngle = CGFloat.pi
    var targetStartAngle = CGFloat.pi
    
    var displayLink: CADisplayLink?
    
    ///
    var finishedPercentage = 0

    ///
    private var loopCounter = 1

    ///
    var loopMode = false

    ///
    private var loopMaxTests = RMBT_TEST_LOOPMODE_LIMIT

    ///
    var loopMinDelay = RMBT_TEST_LOOPMODE_WAIT_BETWEEN_RETRIES_S

    ///
    var loopSkipQOS = false
    
    var textAnimator = RMBTTextAnimator()

    /// is quality test running
    internal var qtMode = false

// MARK: Views
    ///
    var progressGaugeView: RMBTGaugeView!

    var speedGaugeView: RMBTGaugeView!

    var qualityGaugeView: RMBTGaugeView!

    //
    @IBOutlet weak var sideButton: UIButton?
    @IBOutlet weak var mapButton: UIButton!
//    @IBOutlet internal var startTestButton: UIButton!
    @IBOutlet weak var resultsButton: UIButton?
    @IBOutlet weak var startBackgroundView: UIView!
    @IBOutlet weak var mapBackgroundView: UIView!
    @IBOutlet internal var networkTypeImageView: UIImageView?
    @IBOutlet weak var qosStartButton: RMBTButton!
    @IBOutlet weak var qosBackgroundView: UIView!
    ///
    var serverValues: [String] = []

    ///
    var processValues: [String] = []

    ///
    var h_tableTitles = ["Server", "IP"]

    ///
    var m_tableTitles: [MTestStatus] = []

    ///
    var q_tableTitles: [QosTestStatus] = []

// MARK: Network name and type

    /// not use for ONT
//    @IBOutlet var networkTypeLabel: UILabel!

    @IBOutlet weak var testDescriptionLabel: UILabel!
    @IBOutlet weak var testLabel: UILabel?
    ///
//    @IBOutlet var networkNameLabel: UILabel!

    @IBOutlet weak var startDefaultView: UIView?
    @IBOutlet weak var networkTitleLabel: UILabel?
    @IBOutlet weak var locationView: RMBTPULocationView?
    @IBOutlet weak var serversView: RMBTPUServersViews!
    // MARK: Progress

    ///
    @IBOutlet internal var progressLabel: UILabel!

    ///
    @IBOutlet internal var progressGaugePlaceholderView: UIImageView!

// MARK: Results ONT

    ///
    @IBOutlet internal var pingResultLabel: UILabel?

    ///
    @IBOutlet internal var downResultLabel: UILabel?

    @IBOutlet weak var upMbpsLabel: UILabel!
    @IBOutlet weak var downMbpsLabel: UILabel!
    ///
    @IBOutlet internal var upResultLabel: UILabel?
    
    ///
    @IBOutlet internal var jitterLabel: UILabel?
    
    ///
    @IBOutlet internal var packetLossLabel: UILabel?

// MARK: Speed chart

    ///
    @IBOutlet private var speedGaugePlaceholderView: UIImageView!

    ///
    @IBOutlet internal var arrowImageView: UIImageView!

    @IBOutlet internal var speedLabel: UILabel?
    
    ///
    @IBOutlet internal var qosLabel: UILabel!
    
    ///
    @IBOutlet weak var uploadSpeedGraphView: RMBTSpeedGraphView?
    @IBOutlet internal var speedGraphView: RMBTSpeedGraphView?
    // ONT
    //
    @IBOutlet internal var downloadBackgrounView: RMBTTestResultBackView?
    
    //
    @IBOutlet internal var uploadBackgrounView: RMBTTestResultBackView?

    @IBOutlet weak var startDefaultTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var mapBackgroundViewCenterYConstraint: NSLayoutConstraint!
    @IBOutlet weak var progressLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var arrowImageTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var qosLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var serversTopConstraint: NSLayoutConstraint?
    @IBOutlet weak var pingAreaTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var speedGaugePlaceholderConstraint: NSLayoutConstraint!
    @IBOutlet weak var progressGaugeTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var performedLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var passedLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var failedLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var qosValueLabel: UILabel!
    @IBOutlet weak var qosTitleLabel: UILabel?
    @IBOutlet weak var performedIconView: UIImageView?
    @IBOutlet weak var performedValueLabel: UILabel!
    @IBOutlet weak var performedTitleLabel: UILabel?
    @IBOutlet weak var passedIconView: UIImageView?
    @IBOutlet weak var passedValueLabel: UILabel!
    @IBOutlet weak var passedTitleLabel: UILabel?
    @IBOutlet weak var failedIconView: UIImageView?
    @IBOutlet weak var failedValueLabel: UILabel!
    @IBOutlet weak var failedTitleLabel: UILabel?
    @IBOutlet weak var qosView: UIView?
    @IBOutlet weak var performedView: UIView?
    @IBOutlet weak var passedView: UIView?
    @IBOutlet weak var failedView: UIView?
    @IBOutlet weak var topPerformedViewConstraint: NSLayoutConstraint!
    //
    @IBOutlet internal var resultsTable: UITableView!
    //
    
    @IBOutlet internal var pingNameLabel: UILabel?
    //
    @IBOutlet internal var jitterNameLabel: UILabel?
    //
    @IBOutlet internal var packetLossNameLabel: UILabel?
    
    @IBOutlet weak var rightMarginButtonsViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var leftMarginButtonsViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var buttonsViewWidthConstraint: NSLayoutConstraint?
    @IBOutlet weak var centerXButtonsViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var backgroundImage: UIImageView!
    
    var isNeedReloadBanner = false {
        didSet {
            if IS_SHOW_ADVERTISING {
                if isNeedReloadBanner == false {
                    if bannerTimer?.isValid == true {
                        bannerTimer?.invalidate()
                    }
                    bannerTimer = nil
                } else {
                    bannerTimer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(updateBannerTimer(_:)), userInfo: nil, repeats: true)
                    updateBannerTimer(bannerTimer)
                }
            }
        }
    }
    
    internal var resultsTableSpeedtestFrame: CGRect!
    internal var resultsTableQOSFrame: CGRect!
    
    var countTests = 1
    
    var bannerTimer: Timer?
    var unusedTimer: Timer?
    var isManualQosLaunched: Bool = false
    
    weak var abortAlert: UIAlertController?
    
    @objc func updateBannerTimer(_ timer: Timer?) {
        RMBTAdvertisingManager.shared.reloadingAdMobBanner()
    }
    
    @objc func tickDisplay(sender: CADisplayLink?) {
        guard let duration = sender?.duration else { return }
        
        let angle = (self.targetStartAngle - self.previousBackStartAngle) * CGFloat(duration) * 10
        
        self.arrowImageView.transform = CGAffineTransform(rotationAngle: self.previousBackStartAngle + angle)
        
        self.previousBackStartAngle += angle
        
        let speed = (self.targetSpeed - self.previousSpeed) * duration * 10
        
        speedGaugeView.value = Float(self.previousSpeed + speed)
        
        self.previousSpeed += speed
    }
    
    @objc func unusedTimerHandler(timer: Timer) {
        self.testUI(isHidden: true)
        self.qosBackgroundView.isHidden = true
        self.mapBackgroundView.isHidden = false
        self.serversView.isShouldUserInterectionEnabled = true
    }
    
    deinit {
        defer {
            if self.bannerTimer?.isValid == true {
                self.bannerTimer?.invalidate()
                self.bannerTimer = nil
            }
            if self.unusedTimer?.isValid == true {
                self.unusedTimer?.invalidate()
                self.unusedTimer = nil
            }
            self.displayLink?.invalidate()
            self.displayLink = nil
        }
    }
    
    func connectivityTracker(_ tracker: RMBTConnectivityTracker, didStopAndDetectIncompatibleConnectivity connectivity: RMBTConnectivity) {
        
    }
    
    func connectivityTracker(_ tracker: RMBTConnectivityTracker, didDetectConnectivity connectivity: RMBTConnectivity) {
        manageViewAfterDidConnect(connectivity: connectivity)
        //
        self.currentConnectivityNetworkType = connectivity.networkType
        
        DispatchQueue.main.async {
            self.rmbtClient.isQOSEnabled = self.isQOSEnabled()
        }
    }
    
    ///
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ///////////////////////////////////////////////
        // 4S UI hack
        if self.view.frameHeight < 500 {
            self.uploadSpeedGraphView?.isHidden = true
            self.speedGraphView?.isHidden = true
            self.downloadBackgrounView?.graphView?.isHidden = true
            self.uploadBackgrounView?.graphView?.isHidden = true
            self.topPerformedViewConstraint.constant = -25
            self.pingAreaTopConstraint.constant = 65
        }
        if UIScreen.main.bounds.size.width < 360 {
            self.performedIconView?.isHidden = true
            self.passedIconView?.isHidden = true
            self.failedIconView?.isHidden = true
        } else {
            self.performedLeftConstraint.constant = 50
            self.failedLeftConstraint.constant = 50
            self.passedLeftConstraint.constant = 50
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
            self.startDefaultTopConstraint.constant = 0
            self.mapBackgroundViewCenterYConstraint.constant = 70
        } else if UIScreen.main.bounds.size.height >= 812 {
            self.mapBackgroundViewCenterYConstraint.constant = 70
        }
        //Increase fonts for iPhone XS Max
        if UIScreen.main.bounds.size.height >= 868 {
            let lightLargeFont = UIFont.systemFont(ofSize: 30, weight: .light)
            let boldFont = UIFont.systemFont(ofSize: 12, weight: .bold)
            let bold13Font = UIFont.systemFont(ofSize: 13, weight: .bold)
            let regular13Font = UIFont.systemFont(ofSize: 13, weight: .regular)
            let bold16Font = UIFont.systemFont(ofSize: 16, weight: .bold)
            self.downloadBackgrounView?.titleLabel?.font = boldFont
            self.downResultLabel?.font = lightLargeFont
            self.uploadBackgrounView?.titleLabel?.font = boldFont
            self.upResultLabel?.font = lightLargeFont
            self.downMbpsLabel?.font = boldFont
            self.upMbpsLabel?.font = boldFont
            
            self.pingNameLabel?.font = bold13Font
            self.pingResultLabel?.font = bold16Font
            self.jitterNameLabel?.font = bold13Font
            self.jitterLabel?.font = bold16Font
            self.packetLossNameLabel?.font = bold13Font
            self.packetLossLabel?.font = bold16Font

            self.serversView?.titleLabel?.font = boldFont
            self.serversView?.measurementServerLabel?.font = boldFont
            self.networkTitleLabel?.font = boldFont
            self.networkNameLabel?.font = boldFont
            self.locationView?.locationTitleLabel?.font = boldFont
            self.locationView?.locationValueLabel?.font = boldFont
            
            self.performedTitleLabel?.font = bold13Font
            self.failedTitleLabel?.font = bold13Font
            self.passedTitleLabel?.font = bold13Font
            self.performedValueLabel?.font = bold16Font
            self.failedValueLabel?.font = bold16Font
            self.passedValueLabel?.font = bold16Font
            
            let bold35Font = UIFont.systemFont(ofSize: 35, weight: .bold)
            self.qosTitleLabel?.font = bold35Font
            self.qosValueLabel?.font = bold35Font
            
            self.resultsButton?.titleLabel?.font = bold16Font
            self.testLabel?.font = bold13Font
            self.testDescriptionLabel?.font = regular13Font
        }
        
        initUI()
        setupAnimator()
        
        self.rmbtClient.isStoreZeroMeasurement = RMBTSettings.sharedSettings.submitZeroTesting && TEST_STORE_ZERO_MEASUREMENT
        self.rmbtClient.isQOSEnabled = self.isQOSEnabled()
        
        loopMode = RMBTSettings.sharedSettings.debugUnlocked && RMBTSettings.sharedSettings.debugLoopMode // TODO: show loop mode text in view
        
        // disable user interaction on table (table is self scrolling)
        resultsTable.isUserInteractionEnabled = false
        
        resultsTableSpeedtestFrame = resultsTable.frame
        resultsTableQOSFrame = resultsTable.frame
        
        if self.rmbtClient.isQOSEnabled == true {
            self.countTests = 2
        } else {
            self.countTests = 1
        }
        finishedPercentage = 0
        displayPercentage(finishedPercentage)
        startTest()
        
        if IS_SHOW_ADVERTISING {
            showAdvertising()
        }
        
        backgroundImage.image = nil
        if !RMBTConfig.sharedInstance.RMBT_VERSION_NEW {
            if RMBT_IS_NEED_BACKGROUND == true {
                backgroundImage.image = INITIAL_BACKGROUND_IMAGE
            }
        }
    }
    
    ///
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startConnectivityTracker()
        //        UIApplication.sharedApplication.bk_performBlock({ sender in
        UIApplication.shared.isIdleTimerDisabled = true
        //        }, afterDelay: 5.0)
        
        self.navigationController?.isNavigationBarHidden = true
        
        self.displayLink = CADisplayLink(target: self, selector: #selector(tickDisplay(sender:)))
        displayLink?.add(to: RunLoop.main, forMode: RunLoop.Mode.default)
    }
    
    ///
    override func viewDidDisappear(_ animated: Bool) {
        stopConnectivityTracker()
        self.displayLink?.invalidate()
        self.displayLink = nil
        
        UIApplication.shared.isIdleTimerDisabled = false
    }
    ///
    
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
    
    @IBAction func respondToTap() {
        self.abortAlert = abortMeasurementAction()
    }
    
    @IBAction func startQosTestButtonClick(_ sender: Any) {
        if self.unusedTimer?.isValid == true {
           self.unusedTimer?.invalidate()
        }
        self.serversView.isShouldUserInterectionEnabled = false
        self.isManualQosLaunched = true
        self.qosBackgroundView.isHidden = true
        self.testUI(isHidden: false)
        self.speedGaugeView.isHidden = true
        self.arrowImageView.isHidden = true
        self.performedView?.isHidden = true
        self.passedView?.isHidden = true
        self.failedView?.isHidden = true
        self.qosView?.isHidden = true
        self.progressGaugeView.value = 0.0
        finishedPercentage = 100
        self.countTests = 2
        displayPercentage(finishedPercentage)
        startQosMeasurementAction()
    }
    
    fileprivate func showAdvertising() {
        if RMBTSettings.sharedSettings.isAdsRemoved == true || RMBTClient.advertisingIsActive == false {
            return
        }
        if RMBTAdvertisingManager.shared.state == .loaded {
            AnalyticsHelper.logCustomEvent(withName: "home.test.ad_loaded", attributes: ["is_loaded": true])
            var rect = self.view.bounds
            var bottomInset: CGFloat = 0.0
            if #available(iOS 11.0, *) {
                bottomInset = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0.0
            }
            rect.origin.y = rect.size.height - 50 - bottomInset
            rect.origin.x = (rect.size.width - 320) / 2
            rect.size.height = 50
            rect.size.width = 320
            RMBTAdvertisingManager.shared.showAdMobBanner(with: rect, in: self.view)
        } else {
            AnalyticsHelper.logCustomEvent(withName: "home.test.ad_loaded", attributes: ["is_loaded": true])
            RMBTAdvertisingManager.shared.onLoadedAdMobHandler = { error in
                if error != nil {
                    return
                }
                var rect = self.view.bounds
                var bottomInset: CGFloat = 0.0
                if #available(iOS 11.0, *) {
                    bottomInset = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0.0
                }
                rect.origin.y = rect.size.height - 50 - bottomInset
                rect.origin.x = (rect.size.width - 320) / 2
                rect.size.height = 50
                rect.size.width = 320
                RMBTAdvertisingManager.shared.showAdMobBanner(with: rect, in: self.view)
            }
            if RMBTAdvertisingManager.shared.state == .error {
                RMBTAdvertisingManager.shared.reloadingAdMobBanner()
            }
        }
    }
    
    @IBAction func startTestButtonClick(_ sender: Any) {
        if self.unusedTimer?.isValid == true {
            self.unusedTimer?.invalidate()
        }

        self.isManualQosLaunched = false
        self.serversView.isShouldUserInterectionEnabled = false
        self.qosBackgroundView.isHidden = true
        self.speedGraphView?.clear()
        self.uploadSpeedGraphView?.clear()
        self.uploadBackgrounView?.graphView?.clear()
        self.downloadBackgrounView?.graphView?.clear()
        self.performedView?.isHidden = true
        self.passedView?.isHidden = true
        self.failedView?.isHidden = true
        self.qosView?.isHidden = true
        self.arrowImageView.isHidden = true
        self.arrowImageView.layer.removeAllAnimations()
        self.targetSpeed = 0.0
        self.rotationArrow(to: CGFloat.pi)
        self.rmbtClient.isQOSEnabled = self.isQOSEnabled()
        if self.rmbtClient.isQOSEnabled == true {
            self.countTests = 2
        } else {
            self.countTests = 1
        }
        finishedPercentage = 0
        displayPercentage(finishedPercentage)
        self.startTest()
    }
    
    @IBAction func resultsButtonClick(_ sender: Any) {
        // Load from DB the fresh record !!!
        MeasurementHistory.sharedMeasurementHistory.getHistoryWithFilters(filters: nil, length: 1, offset: 0, success: { [weak self] response in
            var results = [RMBTHistoryResult]()
            
            for r in response.records {
                results.append(RMBTHistoryResult(response: r as HistoryItem))
            }
            
            self?.performSegue(withIdentifier: "pushTestResultsView", sender: results.first)
//            self.manageViewsAbort()
        }, error: { error in
            _ = UIAlertController.presentErrorAlert(error as NSError, dismissAction: nil)
        })
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        let settings = RMBTSettings.sharedSettings

        // check if loop mode is enabled and prepare values
        if settings.debugUnlocked && settings.debugLoopMode {

            if settings.debugLoopModeMaxTests > 0 {
                loopMaxTests = Int(settings.debugLoopModeMaxTests)
            }

            if settings.debugLoopModeMinDelay > 0 {
                loopMinDelay = Int(settings.debugLoopModeMinDelay)
            }

            // loopSkipQOS = settings.debugLoopModeSkipQOS
        }
    }
    
    //
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.isNavigationBarHidden = false
    }
    
    func testUI(isHidden: Bool) {
        self.progressGaugeView.isHidden = isHidden
        self.speedGaugeView.isHidden = isHidden
        self.qualityGaugeView?.isHidden = isHidden
        self.arrowImageView.isHidden = isHidden
        self.qosLabel.isHidden = isHidden
        self.progressLabel.isHidden = isHidden
        self.resultsTable.isHidden = true
        
        self.sideButton?.isHidden = !isHidden
        self.resultsButton?.isHidden = !isHidden
        self.startDefaultView?.isHidden = !isHidden
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        speedGaugePlaceholderView.image = nil
        progressGaugePlaceholderView.image = nil
        
        let configuration = RMBTConfigFabric.config(with: RMBTConfigurationIdentifier)
        if configuration.RMBT_VERSION > 1 {
            startTestButton?.layer.cornerRadius = ((startTestButton?.frame.size.height ?? 1) / 2.0)
            mapButton?.layer.cornerRadius = ((mapButton?.frame.size.height ?? 1) / 2.0)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                self.qosStartButton.layer.cornerRadius = ((self.qosStartButton?.frame.size.height ?? 1) / 2.0)
                self.startTestButton?.updateGradientONTStartButton()
                self.qosStartButton.updateGradientONTStartButton()
                
                self.speedGaugePlaceholderView?.makeFancyCircles(clockWise: false, isDrawProgress: false)
                self.progressGaugePlaceholderView?.makeFancyCircles(clockWise: true, isDrawProgress: false)
                
                self.mapBackgroundView?.makeFancyCircles(clockWise: false)
                self.qosBackgroundView?.makeFancyCircles(clockWise: false)
                self.startBackgroundView?.makeFancyCircles(clockWise: true)
            }

            if UIDevice.isDeviceTablet() {
                self.buttonsViewWidthConstraint?.constant = min(UIScreen.main.bounds.width, UIScreen.main.bounds.height) - 50
            }
        }
    }
    
    internal func initUI () {
        self.qosBackgroundView.isHidden = true
        self.networkTypeImageView?.image = self.networkTypeImageView?.image?.tintedImageUsingColor(tintColor: RMBT_TINT_COLOR)
        self.uploadBackgrounView?.graphView?.graphColor = RMBT_CHECK_UPLOAD_MEDIOCRE_COLOR
        self.downloadBackgrounView?.graphView?.graphColor = RMBT_CHECK_DOWNLOAD_MEDIOCRE_COLOR
        self.arrowImageView.layer.removeAllAnimations()
        self.targetSpeed = 0.0
        self.rotationArrow(to: CGFloat.pi)
        self.arrowImageView.isHidden = true
        self.arrowImageView.image = self.arrowImageView.image?.tintedImageUsingColor(tintColor: INITIAL_SCREEN_TEXT_COLOR)
        self.resultsButton?.setTitle(L("test.show-detailed-results"), for: .normal)
        self.resultsButton?.setTitleColor(TEST_RESULTS_BUTTON_TEXT_COLOR, for: .normal)
        self.resultsButton?.backgroundColor = INITIAL_SCREEN_TEXT_COLOR
        if let sideButton = self.sideButton {
            sideButton.addTarget(revealViewController(), action: #selector(SWRevealViewController.revealToggle(_:)), for: .touchUpInside)
            let image = sideButton.image(for: .normal)?.withRenderingMode(.alwaysTemplate)
            sideButton.setImage(image, for: .normal)
            sideButton.tintColor = RMBT_TINT_COLOR
        }
        //
        getMeasurementServerInfo(success: { [weak self] response in
            self?.serversView?.items = response.servers
        }, error: { _ in
            
        })
        
        self.qosLabel.text = L("test.title.qos")
        
        resultsTable.backgroundColor = TEST_TABLE_BACKGROUND_COLOR
        view.backgroundColor = TEST_BACKGROUND_COLOR
        addProjectBackground()
        
        let configuration = RMBTConfigFabric.config(with: RMBTConfigurationIdentifier)
        /// ONT VERSION
        if configuration.RMBT_VERSION > 1 {
            //
            mapBackgroundView?.makeFancyCircles(clockWise: false)
            startBackgroundView?.makeFancyCircles(clockWise: true)
            startTestButton?.formatONTStartButton()
            startTestButton?.layer.cornerRadius = ((startTestButton?.frame.size.height ?? 1) / 2.0)
            mapButton?.layer.cornerRadius = ((mapButton?.frame.size.height ?? 1) / 2.0)
            qosStartButton.formatONTStartButton()
            qosStartButton.setTitle(L("RMBT-TEST-START_QOS_BUTTON"), for: .normal)
            qosStartButton.layer.cornerRadius = ((qosStartButton?.frame.size.height ?? 1) / 2.0)
        } else {
            // only RU
            mapButton?.formatRMBTMapButton()
            //// old solutios
            startTestButton?.formatRMBTStartButton()
        }
        
        progressLabel.textColor = INITIAL_SCREEN_TEXT_COLOR
        speedLabel?.textColor = INITIAL_SCREEN_TEXT_COLOR
        qosLabel.textColor = INITIAL_SCREEN_TEXT_COLOR
        self.locationView?.locationTitleLabel?.textColor = INITIAL_SCREEN_TEXT_COLOR
//        self.networkNameLabel?.textColor = INITIAL_SCREEN_TEXT_COLOR
        self.networkTypeLabel?.textColor = INITIAL_SCREEN_TEXT_COLOR
        self.networkTitleLabel?.textColor = INITIAL_SCREEN_TEXT_COLOR
        self.serversView?.titleLabel?.textColor = INITIAL_SCREEN_TEXT_COLOR
        self.serversView?.iconImageView?.image = self.serversView?.iconImageView?.image?.tintedImageUsingColor(tintColor: RMBT_TINT_COLOR)
        
        self.qosTitleLabel?.textColor = INITIAL_SCREEN_TEXT_COLOR
        self.qosTitleLabel?.text = L("test.title.qos")
        self.performedTitleLabel?.textColor = INITIAL_SCREEN_TEXT_COLOR
        self.performedTitleLabel?.text = L("test.title.performed")
        self.passedTitleLabel?.textColor = INITIAL_SCREEN_TEXT_COLOR
        self.passedTitleLabel?.text = L("test.title.passed")
        self.failedTitleLabel?.textColor = INITIAL_SCREEN_TEXT_COLOR
        self.failedTitleLabel?.text = L("test.title.failed")
        self.networkTitleLabel?.text = L("test.network")
        self.downloadBackgrounView?.titleLabel?.text = L("test.phase.download").uppercased()
        self.uploadBackgrounView?.titleLabel?.text = L("test.phase.upload").uppercased()

        self.qosView?.isHidden = true
        self.performedView?.isHidden = true
        self.passedView?.isHidden = true
        self.failedView?.isHidden = true

        // Init
        var initStruct = MTestStatus(testName: "", status: false, value: "")
        
        for name in [L("test.phase.init"), L("test.phase.ping"), L("test.phase.download"), L("test.phase.upload")] {
            initStruct.testName = name
            self.m_tableTitles.append(initStruct)
        }
        
        //////////
        
        //NSParameterAssert(self.progressGaugePlaceholderView);
        progressGaugeView = RMBTGaugeView(frame: progressGaugePlaceholderView.frame,
                                          name: "progress",
                                          startAngle: 204,
                                          endAngle: 485,
                                          ovalRect: progressGaugePlaceholderView.bounds)

        view.addSubview(progressGaugeView)
        if let startTestButton = self.startTestButton {
        progressGaugeView.translatesAutoresizingMaskIntoConstraints = false
            self.view.addConstraint(NSLayoutConstraint(item: progressGaugeView, attribute: .centerX, relatedBy: .equal, toItem: startTestButton, attribute: .centerX, multiplier: 1, constant: 0))

            self.view.addConstraint(NSLayoutConstraint(item: progressGaugeView, attribute: .centerY, relatedBy: .equal, toItem: startTestButton, attribute: .centerY, multiplier: 1, constant: 0))
        
        self.view.addConstraint(NSLayoutConstraint(item: startTestButton, attribute: .width, relatedBy: .equal, toItem: self.progressGaugeView, attribute: .width, multiplier: 1, constant: -30))
        self.view.addConstraint(NSLayoutConstraint(item: startTestButton, attribute: .height, relatedBy: .equal, toItem: self.progressGaugeView, attribute: .height, multiplier: 1, constant: -30))
        }

//        progressGaugePlaceholderView.removeFromSuperview()
//        progressGaugePlaceholderView = nil // release the placeholder view
        //NSParameterAssert(self.speedGaugePlaceholderView);

        speedGaugeView = RMBTGaugeView(frame: speedGaugePlaceholderView.frame,
                                       name: "speed",
                                       startAngle: 1,
                                       endAngle: 299,
                                       ovalRect: CGRect(x: 0, y: 0, width: speedGaugePlaceholderView.frame.width,
                                                        height: speedGaugePlaceholderView.frame.height))
        view.addSubview(speedGaugeView)
        if let mapButton = self.mapButton {
            speedGaugeView.translatesAutoresizingMaskIntoConstraints = false
            self.view.addConstraint(NSLayoutConstraint(item: speedGaugeView, attribute: .centerX, relatedBy: .equal, toItem: mapButton, attribute: .centerX, multiplier: 1, constant: 0))

            self.view.addConstraint(NSLayoutConstraint(item: speedGaugeView, attribute: .centerY, relatedBy: .equal, toItem: mapButton, attribute: .centerY, multiplier: 1, constant: 0))
            self.view.addConstraint(NSLayoutConstraint(item: mapButton, attribute: .width, relatedBy: .equal, toItem: self.speedGaugeView, attribute: .width, multiplier: 1, constant: -30))
            self.view.addConstraint(NSLayoutConstraint(item: mapButton, attribute: .height, relatedBy: .equal, toItem: self.speedGaugeView, attribute: .height, multiplier: 1, constant: -30))
        
        }
//        speedGaugePlaceholderView.removeFromSuperview()
//        speedGaugePlaceholderView = nil // release the placeholder view

        // Only clear connectivity and location labels once at start to avoid blinking during test restart
        networkNameLabel?.text = networkNameString
        
        // Localisation
        self.jitterNameLabel?.text = L("RBMT-BASE-JITTER").uppercased()
        self.packetLossNameLabel?.text = L("RBMT-BASE-PACKETLOSS").uppercased()
        self.pingNameLabel?.text = L("test.phase.ping").uppercased()
        
        // colorize subviews
//        self.networkNameLabel.textColor = RMBT_TINT_COLOR
        self.qosLabel.textColor = RMBT_TINT_COLOR
        self.jitterNameLabel?.textColor = RMBT_TINT_COLOR
        self.pingNameLabel?.textColor = RMBT_TINT_COLOR
        self.packetLossNameLabel?.textColor = RMBT_TINT_COLOR
        
        self.testUI(isHidden: false)
    }
    
    //
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "pushTestResultsView" {
            if let nc = segue.destination as? UINavigationController {
                if let trController = nc.topViewController  as? RMBTHistoryResultViewController {
                    trController.historyResult = sender as? RMBTHistoryResult
                    trController.isModal = true
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

    func setupAnimator() {
        let titles = [
            L("test.qos.titles.web-page"),
            L("test.qos.titles.TCP-ports"),
            L("test.qos.titles.UDP-ports"),
            L("test.qos.titles.voice-over-IP"),
            L("test.qos.titles.traceroute"),
            L("test.qos.titles.unmodified-content"),
            L("test.qos.titles.transparent-connection"),
            L("test.qos.titles.DNS")
        ]
        let title = L("test.title.test")
        let descriptions = [
            L("test.qos.descriptions.web-page"),
            L("test.qos.descriptions.TCP-ports"),
            L("test.qos.descriptions.UDP-ports"),
            L("test.qos.descriptions.voice-over-IP"),
            L("test.qos.descriptions.traceroute"),
            L("test.qos.descriptions.unmodified-content"),
            L("test.qos.descriptions.transparent-connection"),
            L("test.qos.descriptions.DNS")
        ]
        self.textAnimator.title = title
        self.textAnimator.descriptions = descriptions
        self.textAnimator.values = titles
        self.textAnimator.descriptionLabel = self.testDescriptionLabel
        self.textAnimator.titleLabel = self.testLabel
        
        self.testLabel?.textColor = INITIAL_SCREEN_TEXT_COLOR
    }
// MARK: - UITable Methods

    ///
    internal func updateStatusWithValue(text: String, phase: SpeedMeasurementPhase, final: Bool) {
        var myIP: IndexPath!

        switch phase {
        case .Init:     myIP = IndexPath(item: 0, section: 1)
        case .latency:  myIP = IndexPath(item: 1, section: 1)
        case .down:     myIP = IndexPath(item: 2, section: 1)
        case .up:       myIP = IndexPath(item: 3, section: 1)
        default:  return
        }

        m_tableTitles[myIP.row].value = text
        m_tableTitles[myIP.row].status = final
        
        if let cell = resultsTable.cellForRow(at: myIP as IndexPath) as? RMBTTestTableViewCellM {
            cell.assignResultValue(value: text, final: final)
            
            resultsTable.scrollToRow(at: myIP, at: .top, animated: true)
            self.resultsTable.reloadData()
        }

    }
    
// MARK: - Methods

    ///
    func restartTestAfterCountdown(interval: Int) {
        loopCounter += 1
        if loopCounter <= loopMaxTests {
            // Restart test
            logger.debug("Loop mode active, starting new test (\(loopCounter)/\(loopMaxTests)) after \(interval) seconds")

//            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC) * Int64(interval))
//
//            dispatch_after(delayTime, dispatch_get_main_queue()) {
//                self.startNextLoop()
//            }
        } else {
            logger.debug("Loop mode limit reached (\(loopMaxTests)), stopping")
            dismiss(animated: true, completion: nil)
        }
    }

    ///
    func startNextLoop() {
        // TODO: reset view
        qtMode = false
        swapViews()
        startTest()
    }

    /// Can be called multiple times if run in loop mode
    func startTest() {
        if RMBTSettings.sharedSettings.isAdsRemoved == false && RMBTClient.advertisingIsActive {
            self.isNeedReloadBanner = false
        }
        assert(loopMode || loopCounter == 1, "Called test twice w/o being in loop mode")
        if let serverName = RMBTConfig.sharedInstance.measurementServer?.name {
            AnalyticsHelper.setObject(value: serverName, for: "Server_Name")
        }
        if let uuid = RMBTClient.uuid {
            AnalyticsHelper.setObject(value: uuid, for: "UUID")
        }
        
        self.serversView.isShouldUserInterectionEnabled = false
        startMeasurementAction()
    }
    
    ///
    func displayPercentage(_ percentage: Int) {
        var calculatedPercentage = percentage
        
        calculatedPercentage /= self.countTests
        
        progressLabel.text = String(format: "%lu%%", calculatedPercentage)
        progressGaugeView.value = Float(percentage) / 100
    }
}

extension RMBTTesterViewController: UITableViewDelegate, UITableViewDataSource {
    // MARK: - UITableViewDataSource/UITableViewDelegate
    
    ///
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.qtMode ? 1 : 2
    }
    
    ///
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.qtMode ? self.q_tableTitles.count : (section == 0 ? 2 : m_tableTitles.count)
    }
    
    ///
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 30
    }
    
    ///
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.qtMode {
            let item = self.q_tableTitles[indexPath.row] as QosTestStatus
            
            let cell = RMBTTestTableViewCellQ(style: .default, reuseIdentifier: "QOS_Cell_New")
            cell.titleLabel.text = item.testType.description
            
            if item.status {
                cell.aTestDidFinish()
            }
            
            cell.backgroundColor = TEST_TABLE_BACKGROUND_COLOR
            
            return cell
        } else {
            if indexPath.section == 0 {
                let cell = self.resultsTable.dequeueReusableCell(withIdentifier: "H_Cell") as! RMBTTestTableViewCellH
                cell.titleLabel.text = self.h_tableTitles[indexPath.row]
                
                if !self.serverValues.isEmpty {
                    cell.valueLabel.text = self.serverValues[indexPath.row]
                }
                
                cell.backgroundColor = TEST_TABLE_BACKGROUND_COLOR
                
                return cell
            } else {
                
                let cell = self.resultsTable.dequeueReusableCell(withIdentifier: "M_Cell") as! RMBTTestTableViewCellM
                cell.titleLabel.text = self.m_tableTitles[indexPath.row].testName
                cell.assignResultValue(value: self.m_tableTitles[indexPath.row].value,
                                       final: self.m_tableTitles[indexPath.row].status)
                
                cell.backgroundColor = TEST_TABLE_BACKGROUND_COLOR
                
                return cell
            }
        }
    }
    
    ///
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
    }
    
    ///
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
}

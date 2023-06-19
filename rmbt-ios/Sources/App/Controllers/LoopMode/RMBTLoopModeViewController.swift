//
//  RMBTLoopModeViewController.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 6/28/18.
//  Copyright © 2018 SPECURE GmbH. All rights reserved.
//

import UIKit
import CoreLocation

class RMBTLoopModeViewController: TopLevelViewController {
    enum State: String {
        case Init = "init"
        case ping = "ping"
        case download = "download"
        case upload = "upload"
        case qos = "qos"
        case packetLose = "packet_lose"
        case jitter = "jitter"
        
        var shortTitle: String? {
            switch self {
            case .ping:
                return L("loopmode.test.state.ping")
            case .download:
                return L("loopmode.test.state.download")
            case .upload:
                return L("loopmode.test.state.upload")
            case .qos:
                return L("loopmode.test.state.qos")
            case .packetLose:
                return L("loopmode.test.state.packet-loss")
            case .jitter:
                return L("loopmode.test.state.jitter")
            case .Init:
                return L("loopmode.test.state.init")
            }
        }
        
        var subtitle: String? {
            switch self {
            case .ping:
                return "ms"
            case .download:
                return L("test.speed.unit")
            case .upload:
                return L("test.speed.unit")
            case .qos:
                return nil
            case .packetLose:
                return "%"
            case .jitter:
                return "ms"
            case .Init:
                return nil
            }
        }
    }
    
    class RMBTLoopModeState {
        var identifier: String?
        var title: String?
        var currentValue: String? // value without ms mbps etc
        var medianValue: String? // value without ms mbps etc
        var progress: Float = 0.0
    }
    
    private let showResultsSegue = "showResultsSegue"
    
    var measurementResultUuid: String?
    
    var isQosAvailable = false
    
    var wasTestExecuted = false
    
    var finishedPercentage = 0
    
    var networkInfo: RMBTNetworkInfo?

    @IBOutlet weak var testAreaRightConstraint: NSLayoutConstraint!
    @IBOutlet weak var testAreaWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var timeAreaTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var timeAreaLeftLandscapeConstraint: NSLayoutConstraint!
    @IBOutlet weak var timeAreaLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var timeAreaTopPortraitConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var timeAreaRightConstraint: NSLayoutConstraint!
    @IBOutlet weak var systemInfoRightConstraint: NSLayoutConstraint!
    @IBOutlet weak var systemInfoLeftLandscapeConstraint: NSLayoutConstraint!
    @IBOutlet weak var systemInfoLeftConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var advertisingContainer: UIView!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var changeServerBackgroundShadowView: UIView!
    @IBOutlet weak var changeServerBackgroundView: UIView!
    @IBOutlet weak var changeServerButton: UIButton!
    @IBOutlet weak var medianResultView: RMBTLoopModeResultView!
    @IBOutlet weak var currentResultView: RMBTLoopModeResultView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var progressTrailingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var progressColorView: RMBTGradientView!
    
    @IBOutlet weak var timeToNextBackgroundView: UIView!
    @IBOutlet weak var movementLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var movementTitleLabel: UILabel!
    @IBOutlet weak var timeToNextTitleLabel: UILabel!
    
    private var currentLoopTest = -1 {
        didSet {
            self.updateProgressLabel()
        }
    }
    
    private var loopMaxTests = RMBT_TEST_LOOPMODE_LIMIT
    private var loopMinDelay = RMBT_TEST_LOOPMODE_WAIT_BETWEEN_RETRIES_S
    private var loopDistance = RMBT_TEST_LOOPMODE_WAIT_DISTANCE_RETRIES_S
    
    private var isResultsDownloaded: Bool = false
    private var isQosResultsDownloaded: Bool = false
    private var testFinished: Bool = false
    
    private var loopModeUUID = UUID().uuidString.lowercased()
    
    weak var abortAlert: UIAlertController?
    
    var heightForMainArea: CGFloat = 342
    
    private var isLoopAborted = false
    
    private var isStarted = false {
        didSet {
            UIApplication.shared.isIdleTimerDisabled = isStarted
        }
    }
    
    private var isTestStarted = false
    
    private var loopResults: [RMBTLoopModeResult] = [] {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    internal var rmbtClient = RMBTClient(withClient: .standard) {
        didSet {
            rmbtClient.isStoreZeroMeasurement = RMBTSettings.sharedSettings.submitZeroTesting && TEST_STORE_ZERO_MEASUREMENT
            rmbtClient.isQOSEnabled = true
            rmbtClient.loopModeUUID = loopModeUUID
        }
    }
    
    var items: [RMBTLoopModeState] = []
    
    var isShowResult: Bool = false
    
    var currentState: State = .Init {
        didSet {
            if isShowResult == false {
                self.updateCurrentStateView(with: self.currentState)
            }
        }
    }
    
    func showStateResult() {
        self.isShowResult = true
        self.currentResultView.isEmpty = false
        self.updateCurrentStateView(with: self.currentState)
        if let item = self.item(with: self.currentState.rawValue),
            let currentValue = item.currentValue {
            if item.identifier == "ping" {
                self.currentResultView.valueLabel?.text = RMBTMillisecondsString(UInt64((currentValue as NSString).longLongValue))
                if let medianValue = item.medianValue,
                    medianValue != "-" {
                    self.medianResultView.valueLabel?.text = RMBTMillisecondsString(UInt64((medianValue as NSString).longLongValue))
                }
            } else if item.identifier == "jitter" {
                self.currentResultView.valueLabel?.text = RMBTMillisecondsString(UInt64((currentValue as NSString).longLongValue))
                if let medianValue = item.medianValue,
                    medianValue != "-" {
                    self.medianResultView.valueLabel?.text = RMBTMillisecondsString(UInt64((medianValue as NSString).longLongValue))
                }
            } else if item.identifier == "download" || item.identifier == "upload" {
                self.currentResultView.valueLabel?.text = RMBTSpeedMbpsString(Double(currentValue) ?? 0.0, withMbps: false)
                if let medianValue = item.medianValue,
                    medianValue != "-" {
                    self.medianResultView.valueLabel?.text = RMBTSpeedMbpsString(Double(medianValue) ?? 0.0, withMbps: false)
                }
            } else if item.identifier == "qos" {
                let result = self.loopResults[self.currentLoopTest]
                if let qosPerformed = result.qosPerformed,
                    let qosPassed = result.qosPassed {
                    self.currentResultView.valueLabel?.text = String(format: "%d/%d", qosPassed, qosPerformed)
                    self.medianResultView.valueLabel?.text = self.median(for: State.qos.rawValue)
                } else {
                    self.currentResultView.valueLabel?.text = "-"
                }
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.isShowResult = false
            if self.testFinished == true {
                self.showResults()
            } else {
                self.currentResultView.isEmpty = true
                self.updateCurrentStateView(with: self.currentState)
            }
        }
    }
    
    func updateCurrentStateView(with state: State) {
        switch state {
        case .ping:
            self.currentResultView.titleLabel?.text = L("loopmode.test.state.ping")
            self.currentResultView.valueLabel?.text = "-"
            self.currentResultView.subtitleLabel?.text = "ms"
            self.medianResultView.subtitleLabel?.text = "ms"
            if let medianValue = self.median(for: state.rawValue) {
                self.medianResultView.valueLabel?.text = RMBTMillisecondsString(UInt64((medianValue as NSString).longLongValue))
            } else {
                self.medianResultView.valueLabel?.text = "-"
            }
        case .jitter:
            self.currentResultView.titleLabel?.text = L("loopmode.test.state.jitter")
            self.currentResultView.valueLabel?.text = "-"
            self.currentResultView.subtitleLabel?.text = "ms"
            self.medianResultView.subtitleLabel?.text = "ms"
            if let medianValue = self.median(for: state.rawValue) {
                self.medianResultView.valueLabel?.text = RMBTMillisecondsString(UInt64((medianValue as NSString).longLongValue))
            } else {
                self.medianResultView.valueLabel?.text = "-"
            }
        case .download:
            self.currentResultView.titleLabel?.text = L("loopmode.test.state.download")
            self.currentResultView.valueLabel?.text = "-"
            self.currentResultView.subtitleLabel?.text = L("test.speed.unit")
            self.medianResultView.subtitleLabel?.text = L("test.speed.unit")
            if let medianValue = self.median(for: state.rawValue) {
                self.medianResultView.valueLabel?.text = RMBTSpeedMbpsString(Double(medianValue) ?? 0.0, withMbps: false)
            } else {
                self.medianResultView.valueLabel?.text = "-"
            }
        case .upload:
            self.currentResultView.titleLabel?.text = L("loopmode.test.state.upload")
            self.currentResultView.valueLabel?.text = "-"
            self.currentResultView.subtitleLabel?.text = L("test.speed.unit")
            self.medianResultView.subtitleLabel?.text = L("test.speed.unit")
            if let medianValue = self.median(for: state.rawValue) {
                self.medianResultView.valueLabel?.text = RMBTSpeedMbpsString(Double(medianValue) ?? 0.0, withMbps: false)
            } else {
                self.medianResultView.valueLabel?.text = "-"
            }
        case .qos:
            self.currentResultView.titleLabel?.text = L("loopmode.test.state.qos")
            self.currentResultView.subtitleLabel?.text = ""
            self.currentResultView.valueLabel?.text = "1%"
            self.medianResultView.subtitleLabel?.text = ""
            self.medianResultView.valueLabel?.text = self.median(for: State.qos.rawValue)
        default:
            break
        }
    }
    
    @objc func locationDidChange(_ locations: [CLLocation]) {
        if RMBTSettings.sharedSettings.debugLoopModeIsStartImmedatelly {
            return
        }
        
        if loopDistance > 0 {
            self.updateNextTestLabel()
            if isStartImmediately == false,
                let beginTestLocation = beginTestLocation,
                let currentLocation = RMBTLocationTracker.sharedTracker.location {
                let distance = beginTestLocation.distance(from: currentLocation)
                if distance > Double(loopDistance) {
                    self.isStartImmediately = true
                    if nextTestTimer?.isValid == true {
                        nextTestTimer?.invalidate()
                        nextTestTimer = nil
                    }
                    self.startNextLoopIfCan(true)
                }
            }
        }
    }
    
    var beginTestTime: TimeInterval?
    var beginTestLocation: CLLocation?
    var isStartImmediately: Bool = false
    
    deinit {
        if nextTestTimer?.isValid == true {
            nextTestTimer?.invalidate()
            nextTestTimer = nil
        }
        NotificationCenter.default.removeObserver(self)
        RMBTDisplayLinker.shared.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        RMBTDisplayLinker.shared.addObserver(self)
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "btn_close"), style: .plain, target: self, action: #selector(closeButtonClick(_:)))
        NotificationCenter.default.addObserver(self,
                selector: #selector(RMBTLoopModeViewController.locationDidChange(_:)),
                name: NSNotification.Name(rawValue: "RMBTLocationTrackerNotification"),
                object: nil)
        
        self.timeToNextTitleLabel.text = L("loopmode.test.time_to_next_test.title")
        self.movementTitleLabel.text = L("loopmode.test.movement.title")
        
        self.medianResultView.titleLabel?.text = L("loopmode.test.header.median")
        let theServer = RMBTConfig.sharedInstance.measurementServer
        self.changeServerButton.setTitle(theServer?.fullName, for: .normal)
        
        self.rmbtClient.isStoreZeroMeasurement = RMBTSettings.sharedSettings.submitZeroTesting && TEST_STORE_ZERO_MEASUREMENT
        self.rmbtClient.isQOSEnabled = !RMBTSettings.sharedSettings.debugLoopModeSkipQOS
        rmbtClient.loopModeUUID = loopModeUUID
        
        let nib = UINib(nibName: RMBTLoopModeTableViewCell.ID, bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: RMBTLoopModeTableViewCell.ID)
        
        let settings = RMBTSettings.sharedSettings
        
        // check if loop mode is enabled and prepare values
        if settings.debugLoopMode {
            if settings.debugLoopModeMaxTests > 0 {
                loopMaxTests = Int(settings.debugLoopModeMaxTests)
            }
            if settings.debugLoopModeMinDelay > 0 {
                loopMinDelay = Int(settings.debugLoopModeMinDelay)
            }
            if settings.debugLoopModeDistance > 0 {
                loopDistance = Double(settings.debugLoopModeDistance)
            }
        }
        
        self.updateProgressLabel()
        self.prepareItems()
        self.startTest()
        
        self.applyColorScheme()
        self.updateColorForNavigationBarAndTabBar()
        
        self.updateNextTestLabel()
        
        if IS_SHOW_ADVERTISING {
            showAdvertising()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if UIDevice.isDeviceTablet() {
            self.updateUI()
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if UIApplication.shared.statusBarOrientation.isLandscape && UIDevice.isDeviceTablet() == false {
            self.testAreaRightConstraint.priority = .defaultLow
            self.testAreaWidthConstraint.priority = .defaultHigh
            if UIDevice.isDeviceTablet() {
                //currentStateView width + medianStateView width + paddings divide 2, because testAreaWidthConstraint has multiplay 1:2
                self.testAreaWidthConstraint.constant = 175
            }
            self.timeAreaLeftLandscapeConstraint.priority = .defaultHigh
            self.timeAreaTopConstraint.priority = .defaultHigh
            self.timeAreaLeftConstraint.priority = .defaultLow
            if self.view.frameWidth < 570 {
                self.timeAreaLeftLandscapeConstraint.constant = 15
                self.timeAreaRightConstraint.constant = 15
                self.systemInfoRightConstraint.constant = 15
                self.systemInfoLeftLandscapeConstraint.constant = 15
            }
            self.timeAreaTopPortraitConstraint.priority = .defaultLow
            self.systemInfoLeftConstraint.priority = .defaultLow
            self.systemInfoLeftLandscapeConstraint.priority = .defaultHigh
            if UIDevice.isDeviceTablet() == false {
                self.currentResultView.superview?.superview?.constraint(with: "top")?.priority = .defaultHigh
                self.currentResultView.superview?.superview?.constraint(with: "centerY")?.priority = .defaultLow
            }
            
            self.advertisingContainer.superview?.constraint(with: "topAdvertising")?.priority = .defaultHigh
            self.advertisingContainer.superview?.constraint(with: "bottomAdvertising")?.priority = .defaultLow
        } else {
            self.systemInfoRightConstraint.constant = 30
            self.testAreaRightConstraint.priority = .defaultHigh
            self.testAreaWidthConstraint.priority = .defaultLow
            self.timeAreaLeftLandscapeConstraint.priority = .defaultLow
            self.timeAreaTopConstraint.priority = .defaultLow
            self.timeAreaLeftConstraint.priority = .defaultHigh
            self.timeAreaTopPortraitConstraint.priority = .defaultHigh
            self.systemInfoLeftConstraint.priority = .defaultHigh
            self.systemInfoLeftLandscapeConstraint.priority = .defaultLow
            if UIDevice.isDeviceTablet() == false {
                self.currentResultView.superview?.superview?.constraint(with: "top")?.priority = .defaultLow
                self.currentResultView.superview?.superview?.constraint(with: "centerY")?.priority = .defaultHigh
            }
            self.advertisingContainer.superview?.constraint(with: "topAdvertising")?.priority = .defaultLow
            self.advertisingContainer.superview?.constraint(with: "bottomAdvertising")?.priority = .defaultHigh
        }
        
        self.updateHeightMainContainer()
        if UIDevice.isDeviceTablet() {
            self.updateUI()
        }
    }
    
    func updateHeightMainContainer() {
        if UIDevice.isDeviceTablet() {
            var height = self.view.frameHeight
            height -= self.changeServerBackgroundView.frameHeight + 20
            heightConstraint.constant = height / 2
        } else {
            if UIApplication.shared.statusBarOrientation.isPortrait {
                if self.infoView.frame.maxY > self.view.frameHeight - 10 {
                    let height = self.infoView.frame.maxY - (self.view.frameHeight - 10)
                    heightConstraint.constant = 292 - height
                }
            } else {
                var height = self.view.frameHeight
                height -= self.changeServerBackgroundView.frameHeight + 20
                heightConstraint.constant = height
            }
        }
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

        changeServerButton.setTitleColor(RMBTColorManager.currentServerTitleColor, for: .normal)
        
        currentResultView.emptyBackgroundColor = RMBTColorManager.background
        currentResultView.notEmptyBackgroundColor = RMBTColorManager.tintColor
        currentResultView.emptyTextColor = RMBTColorManager.tintColor
        currentResultView.notEmptyTextColor = RMBTColorManager.currentValueTitleColor
        currentResultView.emptyValueTextColor = RMBTColorManager.tintColor
        currentResultView.notEmptyValueTextColor = RMBTColorManager.currentValueValueColor
        currentResultView.isEmpty = true
        
        medianResultView.backgroundColor = RMBTColorManager.medianBackgroundColor
        medianResultView.titleLabel?.textColor = RMBTColorManager.medianTextColor
        medianResultView.valueLabel?.textColor = RMBTColorManager.medianTextColor
        medianResultView.subtitleLabel?.textColor = RMBTColorManager.medianTextColor
        
        changeServerBackgroundShadowView.backgroundColor = RMBTColorManager.tableViewSeparator
        progressColorView.backgroundColor = RMBTColorManager.tintColor
        progressColorView.colors = [
            RMBTColorManager.tintPrimaryColor,
            RMBTColorManager.tintSecondaryColor
        ]
        
        timeToNextBackgroundView.backgroundColor = RMBTColorManager.loopModeServiceInfoBackgroundColor
        movementLabel.textColor = RMBTColorManager.loopModeServiceInfoTextColor
        timeLabel.textColor = RMBTColorManager.loopModeServiceInfoTextColor
        movementTitleLabel.textColor = RMBTColorManager.loopModeServiceInfoTitleColor
        timeToNextTitleLabel.textColor = RMBTColorManager.loopModeServiceInfoTitleColor
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func closeButtonClick(_ sender: Any) {
        self.showAbortAlert()
    }
    
    fileprivate func showAdvertising() {
        if RMBTSettings.sharedSettings.isAdsRemoved == true || RMBTClient.advertisingIsActive == false {
            return
        }
        
        let onLoadedAdMobHandler: (_ error: Error?) -> Void  = { [weak self] error in
            if error != nil {
                return
            }
            AnalyticsHelper.logCustomEvent(withName: "home.test.ad_loaded", attributes: ["is_loaded": true])
            
            guard let container = self?.advertisingContainer else { return }
            
            let rect = CGRect(0, 0, 320, 50)
            RMBTAdvertisingManager.shared.showAdMobBanner(with: rect, in: container)
        }
        
        RMBTAdvertisingManager.shared.onLoadedAdMobHandler = onLoadedAdMobHandler
        
        if RMBTAdvertisingManager.shared.state == .loaded {
            onLoadedAdMobHandler(nil)
        } else {
            if RMBTAdvertisingManager.shared.state == .error {
                RMBTAdvertisingManager.shared.reloadingAdMobBanner()
            }
        }
    }
    
    func showAbortAlert() {
        self.abortAlert = abortLoopModeMeasurementAction(abortAction: { [weak self] _ in
            self?.isLoopAborted = true
            self?.navigationController?.popViewController(animated: true)
        }, keepAction: { [weak self] _ in
            self?.isLoopAborted = true
            self?.loopResults.last?.finishedStatus = .cancelled
            self?.showResults()
        })
    }
    
    func showResults() {
        if self.isShowResult == false {
            self.performSegue(withIdentifier: self.showResultsSegue, sender: self)
        } else {
            self.testFinished = true
        }
    }
    
    func startTest() {
        self.isStarted = true
        self.startNextLoop(isFirst: true)
    }
    
    func prepareItems() {
        let pingItem = RMBTLoopModeState()
        pingItem.identifier = State.ping.rawValue
        pingItem.title = L("RMBT-HOME-PING")
        pingItem.medianValue = self.median(for: State.ping.rawValue)
        
        let packetLoseItem = RMBTLoopModeState()
        packetLoseItem.identifier = State.packetLose.rawValue
        packetLoseItem.title = L("RBMT-BASE-PACKETLOSS")
        packetLoseItem.medianValue = self.median(for: State.packetLose.rawValue)
        
        let jitterItem = RMBTLoopModeState()
        jitterItem.identifier = State.jitter.rawValue
        jitterItem.title = L("RBMT-BASE-JITTER")
        jitterItem.medianValue = self.median(for: State.jitter.rawValue)
        
        let downloadItem = RMBTLoopModeState()
        downloadItem.identifier = State.download.rawValue
        downloadItem.title = L("RMBT-HOME-DOWNLOADMBPS")
        downloadItem.medianValue = self.median(for: State.download.rawValue)
        
        let uploadItem = RMBTLoopModeState()
        uploadItem.identifier = State.upload.rawValue
        uploadItem.title = L("RMBT-HOME-UPLOADMBPS")
        uploadItem.medianValue = self.median(for: State.upload.rawValue)
        
        let qosItem = RMBTLoopModeState()
        qosItem.identifier = State.qos.rawValue
        qosItem.title = L("test.title.qos")
        qosItem.medianValue = self.median(for: State.qos.rawValue)
        
        var items = [pingItem, packetLoseItem, jitterItem, downloadItem, uploadItem]
        if self.rmbtClient.isQOSEnabled {
            items.append(qosItem)
        }
        self.items = items
        
        if UIDevice.isDeviceTablet() {
            self.updateUI()
        }
    }
    
    func updateUI() {
        let titleFont = UIFont.systemFont(ofSize: 28, weight: .semibold)
        let subtitleFont = UIFont.systemFont(ofSize: 24, weight: .semibold)
        let textFont = UIFont.systemFont(ofSize: 88, weight: .ultraLight)
        self.currentResultView.titleLabel?.font = titleFont
        self.currentResultView.subtitleLabel?.font = subtitleFont
        self.currentResultView.valueLabel?.font = textFont
        
        self.medianResultView.titleLabel?.font = titleFont
        self.medianResultView.subtitleLabel?.font = subtitleFont
        self.medianResultView.valueLabel?.font = textFont
        
        let width = self.currentResultView.constraint(with: UIView.ConstraintIdentifier.width.rawValue)
        let height = self.currentResultView.constraint(with: UIView.ConstraintIdentifier.height.rawValue)
        var size: CGFloat = 310
        if self.view.frameWidth < size * 2 + 15 {
            size = (self.view.frameWidth - 15) / 2
        }
        let screenHeight = (self.view.frameHeight - self.changeServerBackgroundView.frameHeight) / 2
        if screenHeight < size + 20 {
            size = screenHeight - 20
        }
        width?.constant = size
        height?.constant = size
        
        let widthMedian = self.medianResultView.constraint(with: UIView.ConstraintIdentifier.width.rawValue)
        let heightMedian = self.medianResultView.constraint(with: UIView.ConstraintIdentifier.height.rawValue)
        widthMedian?.constant = size
        heightMedian?.constant = size
        
        let padding = (self.view.bounds.width - (size * 2 + 10)) / 2
        self.systemInfoLeftConstraint.constant = padding
        self.systemInfoRightConstraint.constant = padding
        self.timeAreaLeftConstraint.constant = padding
        self.timeAreaRightConstraint.constant = padding
    }
    
    func updateNextTestLabel() {
        if self.isStartImmediately == false && RMBTSettings.sharedSettings.debugLoopModeIsStartImmedatelly == false {
            self.movementLabel.text = "-/-"
            self.timeLabel.text = "-"

            if loopDistance > 0 {
                if let beginTestLocation = beginTestLocation,
                    let currentLocation = RMBTLocationTracker.sharedTracker.location {
                    let distance = beginTestLocation.distance(from: currentLocation)
                    self.movementLabel.text = String(format: "%0.2f/%0.2f m", distance, loopDistance)
                    if distance > loopDistance {
                        self.movementLabel.text = L("loopmode.test.immediately")
                        self.timeLabel.text = L("loopmode.test.immediately")
                    }
                }
            }
            
            if let beginTestTime = self.beginTestTime {
                let minDelay = Double(loopMinDelay * 60)
                if minDelay > 0 {
                    let delay = minDelay - (Date().timeIntervalSince1970 - beginTestTime)
                    if delay > 0 {
                        let minutes = Int(delay / 60)
                        let seconds = Int(delay - Double(minutes * 60))
                        self.timeLabel.text = String(format: "%d:%02d min", minutes, seconds)
                    } else {
                        self.movementLabel.text = L("loopmode.test.immediately")
                        self.timeLabel.text = L("loopmode.test.immediately")
                    }
                }
            }
        } else {
            self.movementLabel.text = L("loopmode.test.immediately")
            self.timeLabel.text = L("loopmode.test.immediately")
        }
    }
    
    func updateProgressLabel() {
        let text = String(format: L("loopmode.test.progress.format"), currentLoopTest + 1, loopMaxTests)
        self.title = text
    }
    
    func startNextLoopIfCan(_ isImmediatelly: Bool = false) {
        if isResultsDownloaded == true && isQosResultsDownloaded == true {
            let result = self.loopResults[self.currentLoopTest]
            result.isFinished = true
            if self.currentLoopTest < self.loopMaxTests - 1 {
                self.startNextLoop(isFirst: isImmediatelly)
            } else {
                self.abortAlert?.dismiss(animated: true, completion: nil)
                self.isStarted = false
                self.showResults()
            }
        }
    }
    
    var nextTestTimer: Timer?
    
    @objc func nextTestTimerHandle(_ timer: Timer?) {
        if self.rmbtClient.running == false {
            self.isResultsDownloaded = false
            self.isQosResultsDownloaded = false
            self.isStartImmediately = false
            self.prepareItems()
            let result = RMBTLoopModeResult()
            result.isFinished = false
            self.loopResults.append(result)
            self.currentLoopTest += 1
            self.currentResultView.valueLabel?.text = "-"
            self.currentResultView.titleLabel?.text = L("loopmode.test.state.init")
            self.medianResultView.valueLabel?.text = "-"
            self.tableView.reloadData()
            self.startMeasurementAction()
            self.beginTestLocation = RMBTLocationTracker.sharedTracker.location
            self.beginTestTime = Date().timeIntervalSince1970
        }
    }
    
    func startNextLoop(isFirst: Bool = false) {
        isTestStarted = true
        finishedPercentage = 0
        if isFirst {
            self.isResultsDownloaded = false
            self.isQosResultsDownloaded = false
            self.isStartImmediately = false
            self.prepareItems()
            let result = RMBTLoopModeResult()
            result.isFinished = false
            self.loopResults.append(result)
            self.currentLoopTest += 1
            self.tableView.reloadData()
            self.startMeasurementAction()
            RMBTAdvertisingManager.shared.reloadingAdMobBanner()
            self.beginTestLocation = RMBTLocationTracker.sharedTracker.location
            self.beginTestTime = Date().timeIntervalSince1970
        } else {
            var delay = RMBTSettings.sharedSettings.debugLoopModeIsStartImmedatelly ? 0.0 : Double(loopMinDelay * 60)
            if self.isStartImmediately {
                self.isStartImmediately = false
                delay = 1.5
            } else {
                let duration = abs(Date().timeIntervalSince1970 - (self.beginTestTime ?? Date().timeIntervalSince1970))
                if duration < delay {
                    delay -= duration
                }
                if delay < 1.5 {
                    delay = 1.5
                }
            }
            if nextTestTimer?.isValid == true {
                nextTestTimer?.invalidate()
                nextTestTimer = nil
            }
            nextTestTimer = Timer.scheduledTimer(timeInterval: delay, target: self, selector: #selector(nextTestTimerHandle(_:)), userInfo: nil, repeats: false)
        }
    }
    
    func item(with identifier: String) -> RMBTLoopModeState? {
        return self.items.first(where: { (item) -> Bool in
            return item.identifier == identifier
        })
    }
    
    func median(for identifier: String) -> String? {
        var value: Double = 0.0
        var total: Double = 0.0
        var count = 0
        for result in loopResults {
            if identifier == State.ping.rawValue,
                let ping = result.ping {
                value += Double(ping) ?? 0.0
                count += 1
            }
            if identifier == State.jitter.rawValue,
                let jitter = result.jitter {
                value += Double(jitter) ?? 0.0
                count += 1
            }
            if identifier == State.packetLose.rawValue,
                let packetLose = result.packetLoss {
                value += Double(packetLose) ?? 0.0
                count += 1
            }
            if identifier == State.download.rawValue,
                let download = result.down {
                value += RMBTMbps(download)
                count += 1
            }
            if identifier == State.upload.rawValue,
                let upload = result.up as NSString? {
                value += upload.doubleValue
                count += 1
            }
            if identifier == State.qos.rawValue,
                let passed = result.qosPassed,
                let performed = result.qosPerformed {
                total = Double(performed)
                value += Double(passed) / Double(performed)
                count += 1
            }
        }
        
        if identifier == State.qos.rawValue {
            if count > 0 {
                let percent = total * (value / Double(count))
                return String(format: "%d/%d", Int(percent), Int(total))
            }
        }
        
        if count > 0 {
            return String(format: "%0.1f", Float(value / Double(count)))
        }
        return nil
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == self.showResultsSegue,
            let vc = segue.destination as? RMBTLoopModeResultsViewController {
            vc.results = self.loopResults.filter { $0.isFinished }
            vc.items = vc.results.last?.convertToStates(for: self.items) ?? self.items
            vc.networkInfo = networkInfo
        }
    }
    
    private func percentageForPhase(_ phase: SpeedMeasurementPhase) -> Int {
        switch phase {
        case .Init:    return 10
        case .latency: return 10
        case .jitter:  return 10
        case .down:    return 34
        case .up:      return 36
        default:       return 0
        }
    }
    
    private func percentageAfterPhase(phase: SpeedMeasurementPhase) -> Int {
        switch phase {
        case .none:                 return 0
        //case .FetchingTestParams:
        case .wait:                 return 6
        case .Init:                 return 10
        case .latency:              return 20
        case .jitter:               return 30
        case .packLoss:             return 30
        case .down:                 return 64
        case .initUp:               return 62 // no visualization for init up
        case .up:                   return 100
        //
        case .submittingTestResult: return 100 // also no visualization for submission
        default:
            return 0
        }
    }
    
    func displayPercentage(_ percentage: Int) {
        
        var calculatedPercentage = percentage
        
        let countTests = self.rmbtClient.isQOSEnabled ? 2 : 1
        calculatedPercentage /= countTests
        
        print(calculatedPercentage)
        
        self.progressTrailingConstraint.constant = self.view.bounds.width * (CGFloat(100 - calculatedPercentage) / 100.0)
    }
}

extension RMBTLoopModeViewController: RMBTDisplayLinkerDelegate {
    func updateDisplay(with duration: CGFloat) {
        self.updateNextTestLabel()
    }
}

extension RMBTLoopModeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = RMBTLoopModeHeader.view()
        header?.applyColorScheme()
        header?.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 20)
        return header
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: RMBTLoopModeTableViewCell.ID, for: indexPath) as! RMBTLoopModeTableViewCell
        cell.applyColorScheme()
        let item = self.items[indexPath.row]
        cell.loopModeModelView = RMBTLoopModeTableViewCell.RMBTLoopModeModelView(item: item)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 24
    }
}

extension RMBTLoopModeViewController: ManageMeasurement {
    func manageViewControllerAbort() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func measurementDidStart(client: RMBTClient) { }
    
    func measurementDidCompleteVoip(_ client: RMBTClient, withResult: [String: Any]) {
        // compute mean jitter as outcome
        let loopResult: RMBTLoopModeResult = self.loopResults[self.currentLoopTest]
        if let inJiter = withResult["voip_result_out_mean_jitter"] as? NSNumber,
            let outJiter = withResult["voip_result_in_mean_jitter"] as? NSNumber {
            let j = String(format: "%.1f",(inJiter.doubleValue + outJiter.doubleValue) / 2_000_000)
            // assign value
            loopResult.jitter = j
            let item = self.item(with: State.jitter.rawValue)
            item?.currentValue = j
            item?.medianValue = self.median(for: State.jitter.rawValue)
        }

        // compute packet loss (both directions) as outcome
        if let inPL = withResult["voip_result_in_num_packets"] as? NSNumber,
            let outPL = withResult["voip_result_out_num_packets"] as? NSNumber,
            let objDelay = withResult["voip_objective_delay"] as? NSNumber,
            let objCallDuration = withResult["voip_objective_call_duration"] as? NSNumber,
            objDelay != 0,
            objCallDuration != 0 {

            let total = objCallDuration.doubleValue / objDelay.doubleValue

            let packetLossUp = (total - outPL.doubleValue) / total
            let packetLossDown = (total - inPL.doubleValue) / total

            let packetLoss = String(format: "%0.1f", ((packetLossUp + packetLossDown) / 2) * 100)

            loopResult.packetLoss = packetLoss
            let item = self.item(with: State.packetLose.rawValue)
            item?.currentValue = packetLoss
            item?.medianValue = self.median(for: State.packetLose.rawValue)
        }
    }
    
    func manageViewsAbort() {
        DispatchQueue.main.async {
            // modal solution
            // self.dismiss(animated: true, completion: nil)
            //
            self.isStarted = false
            self.isTestStarted = false
//            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func manageViewNewStart() {
        self.displayPercentage(0)
    }
    
    func manageViewProgress(phase: SpeedMeasurementPhase, title: String, value: Double) {
        
        let phasePercentage = Float(percentageForPhase(phase)) * Float(value)
        let totalPercentage = Float(finishedPercentage) + phasePercentage
        assert(totalPercentage <= 100, "Invalid percentage")
        
        displayPercentage(Int(totalPercentage))
        
        logger.debug(totalPercentage)
    }
    
    func manageViewProcess(_ phase: SpeedMeasurementPhase) {
        switch phase {
        case .latency:
            self.currentState = .ping
            let item = self.item(with: State.ping.rawValue)
            item?.progress = 0.01
            item?.medianValue = self.median(for: State.ping.rawValue)
            if let medianValue = item?.medianValue,
                medianValue != "-" {
                self.medianResultView.valueLabel?.text = RMBTMillisecondsString(UInt64((medianValue as NSString).longLongValue))
            }
        case .jitter, .packLoss :
            self.currentState = .jitter
            let item = self.item(with: State.jitter.rawValue)
            item?.progress = 0.01
            if let medianValue = item?.medianValue,
                medianValue != "-" {
                self.medianResultView.valueLabel?.text = RMBTMillisecondsString(UInt64((medianValue as NSString).longLongValue))
            }
        case .down:
            self.currentState = .download
            let item = self.item(with: State.download.rawValue)
            item?.progress = 0.01
            item?.medianValue = self.median(for: State.download.rawValue)
        case .up, .initUp:
            self.currentState = .upload
            let item = self.item(with: State.upload.rawValue)
            item?.progress = 0.01
            item?.medianValue = self.median(for: State.upload.rawValue)
        default:
            break
        }
        
        self.tableView.reloadData()
    }
    
    func manageViewFinishPhase(_ phase: SpeedMeasurementPhase, withResult result: Double) {
        print("manageViewFinishPhase")
        print(result)
        let loopResult = self.loopResults[self.currentLoopTest]
        switch phase {
        case .Init, .fetchingTestParams:
            let item = self.item(with: State.ping.rawValue)
            item?.progress = 0.01
            self.currentResultView.valueLabel?.text = "-"
            self.currentResultView.titleLabel?.text = L("loopmode.test.state.init")
            self.medianResultView.valueLabel?.text = "-"
        case .wait:
            let item = self.item(with: State.ping.rawValue)
            item?.progress = 1.0
            item?.currentValue = String(result)
        case .latency:
            let item = self.item(with: State.ping.rawValue)
            item?.progress = 1.0
            item?.currentValue = String(result)
            loopResult.ping = String(result)
            item?.medianValue = self.median(for: State.ping.rawValue)
            self.showStateResult()
        case .jitter:
            let item = self.item(with: State.jitter.rawValue)
            item?.progress = 1.0
            item?.currentValue = String(result)
            loopResult.jitter = String(result)
            item?.medianValue = self.median(for: State.jitter.rawValue)
            self.showStateResult()
        case .down:
            let item = self.item(with: State.download.rawValue)
            item?.progress = 1.0
            item?.currentValue = String(result)
            loopResult.down = String(result)
            item?.medianValue = self.median(for: State.download.rawValue)
            self.showStateResult()
        case .up:
            let item = self.item(with: State.upload.rawValue)
            item?.progress = 1.0
            item?.currentValue = String(result)
            loopResult.up = String(result)
            item?.medianValue = self.median(for: State.upload.rawValue)
            self.showStateResult()
        default:
            break
        }
        
        finishedPercentage = percentageAfterPhase(phase: phase)
        displayPercentage(finishedPercentage)
        self.tableView.reloadData()
    }
    
    internal func speedMeasurementDidUpdateWith(progress: Float, inPhase phase: SpeedMeasurementPhase) {
        let phasePercentage = Float(percentageForPhase(phase)) * progress
        let totalPercentage = Float(finishedPercentage) + phasePercentage
        assert(totalPercentage <= 100, "Invalid percentage")
        
        displayPercentage(Int(totalPercentage))
        
        logger.debug(totalPercentage)
    }
    
    func manageViewFinishMeasurement(uuid: String) {
        RMBTSettings.sharedSettings.countMeasurements += 1
        isTestStarted = false
        let item = self.item(with: State.qos.rawValue)
        item?.progress = 1.0
        item?.medianValue = self.median(for: State.qos.rawValue)
        self.tableView.reloadData()
        
        let loopResult: RMBTLoopModeResult = self.loopResults[self.currentLoopTest]
        
        self.isResultsDownloaded = false
        self.isQosResultsDownloaded = false
        
        MeasurementHistory.sharedMeasurementHistory.getHistoryWithFilters(filters: nil, length: 1, offset: 0, success: { [weak self] response in
            var results = [RMBTHistoryResult]()

            for r in response.records {
                results.append(RMBTHistoryResult(response: r as HistoryItem))
            }

            let defaultValue = "-"

            if results.first?.jitterMsString != defaultValue {
                if let value = Double(results.first?.jitterMsString ?? "0.0") {
                    let currentValue = value * 1_000_000
                    loopResult.jitter = String(currentValue)
                    let item = self?.item(with: State.jitter.rawValue)
                    item?.currentValue = String(currentValue)
                    item?.medianValue = self?.median(for: State.jitter.rawValue)
                } else {
                    loopResult.jitter = defaultValue
                    let item = self?.item(with: State.jitter.rawValue)
                    item?.currentValue = defaultValue
                    item?.medianValue = self?.median(for: State.jitter.rawValue)
                }
                
                if results.first?.packetLossPercentageString != defaultValue {
                    loopResult.packetLoss = results.first?.packetLossPercentageString ?? defaultValue
                    let item = self?.item(with: State.packetLose.rawValue)
                    item?.currentValue = results.first?.packetLossPercentageString
                    item?.medianValue = self?.median(for: State.packetLose.rawValue)
                } else {
                    loopResult.packetLoss = defaultValue
                }
            } else {
                loopResult.jitter = defaultValue
                loopResult.packetLoss = defaultValue
            }
            
            let up = ((results.first?.uploadSpeedMbpsString as NSString?)?.doubleValue ?? 0.0) * 1000.0
            loopResult.up = String(up)
            let down = ((results.first?.downloadSpeedMbpsString as NSString?)?.doubleValue ?? 0.0) * 1000.0
            loopResult.down = String(down)
            let ping = ((results.first?.shortestPingMillisString as NSString?)?.doubleValue ?? 0.0) / 1.0e-6
            loopResult.ping = String(ping)

            self?.tableView.reloadData()
            self?.isResultsDownloaded = true
            self?.startNextLoopIfCan()
            
        }, error: { error in
            _ = UIAlertController.presentErrorAlert(error as NSError, dismissAction: nil)
        })
        
        if rmbtClient.isQOSEnabled {
            MeasurementHistory.sharedMeasurementHistory.getQOSHistoryOld(uuid: uuid, success: { [weak self]  (response) in
                let qosResults = response
                
                loopResult.qosFailed = qosResults.calculateQosFailed()
                loopResult.qosPassed = qosResults.calculateQosSuccess()
                loopResult.qosPerformed = qosResults.testResultDetail?.count ?? 0
                
                let item = self?.item(with: State.qos.rawValue)
                item?.currentValue = "\(loopResult.qosPassed ?? 0)/\(loopResult.qosPerformed ?? 0)"
                item?.medianValue = self?.median(for: State.qos.rawValue)
                self?.showStateResult()
                self?.currentState = .ping
                self?.tableView.reloadData()
                self?.isQosResultsDownloaded = true
                self?.startNextLoopIfCan()
            }, error: { _ in
            })
        } else {
            self.isQosResultsDownloaded = true
        }
        
        (self.tabBarController as? RMBTTabBarViewController)?.updateHistory()
    }
    
    func manageViewAfterQosStart() {
        self.currentState = .qos
        let item = self.item(with: State.qos.rawValue)
        item?.progress = 0.01
        self.tableView.reloadData()
    }
    
    func manageViewAfterQosUpdated(value: Int) {
        let item = self.item(with: State.qos.rawValue)
        item?.progress = Float(value) / 100.0
        item?.medianValue = self.median(for: State.qos.rawValue)
        if self.isShowResult == false {
            self.currentResultView.valueLabel?.text = String(format: "%d%%", value)
            self.medianResultView.valueLabel?.text = self.median(for: State.qos.rawValue)
        }
        displayPercentage(finishedPercentage + value)
        self.tableView.reloadData()
    }
    
    func manageViewAfterQosGetList(list: [QosMeasurementType]) {
        
    }
    
    func manageViewAfterQosFinishedTest(type: QosMeasurementType) {
        
    }
    
    internal func speedMeasurementDidMeasureSpeed(throughputs: [RMBTThroughput], inPhase phase: SpeedMeasurementPhase) {
//        let result = self.loopResults[self.currentLoopTest]
        var kbps: Double = 0
        for i in 0 ..< throughputs.count {
            let t = throughputs[i]
            kbps = t.kilobitsPerSecond()
            if i == 0 {
                switch phase {
                case .down:
//                    result.down = String(kbps)
                    let item = self.item(with: State.download.rawValue)
                    item?.currentValue = String(kbps)//RMBTSpeedMbpsString(kbps, withMbps: false)
                    if self.isShowResult == false {
                        self.currentResultView.valueLabel?.text = RMBTSpeedMbpsString(kbps, withMbps: false)
                    }
                    self.tableView.reloadData()
                case .up:
//                    result.up = String(kbps)
                    let item = self.item(with: State.upload.rawValue)
                    item?.currentValue = String(kbps)//RMBTSpeedMbpsString(kbps, withMbps: false)
                    if self.isShowResult == false {
                        self.currentResultView.valueLabel?.text = RMBTSpeedMbpsString(kbps, withMbps: false)
                    }
                    self.tableView.reloadData()
                default:
                    break
                }
            }
        }
    }
    
    ///
    func measurementDidFail(_ client: RMBTClient, withReason reason: RMBTClientCancelReason) {
        guard self.isLoopAborted == false else { return }
        //Need to start next loop
        isResultsDownloaded = true
        isQosResultsDownloaded = true
        self.startNextLoopIfCan()
    }
}

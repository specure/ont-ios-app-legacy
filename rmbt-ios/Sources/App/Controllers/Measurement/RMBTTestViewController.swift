//
//  RMBTTestViewController.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 6/28/18.
//  Copyright © 2018 SPECURE GmbH. All rights reserved.
//

import UIKit
import CoreLocation

class RMBTTestViewController: TopLevelViewController {
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
    
    class RMBTTestState {
        var identifier: String?
        var title: String?
        var currentValue: String? // value without ms mbps etc
        var progress: Float = 0.0
        var priority: Int = 0
    }
    
    private let showResultsSegue = "showResultsSegue"
    
    var measurementResultUuid: String?
    
    var isQosEnabled = false {
        didSet {
            self.isQosAvailable = self.isQosEnabled
            self.rmbtClient.isQOSEnabled = isQosEnabled
        }
    }
    
    var isQosAvailable: Bool = false
    
    var wasTestExecuted = false
    
    var finishedPercentage = 0
    
    var networkInfo: RMBTNetworkInfo?
    
    var isIncreaseTestsCounter: Bool = false

    @IBOutlet weak var statesView: UIView!
    @IBOutlet weak var advertisingContainer: UIView!
    @IBOutlet weak var qosButton: UIButton!
    @IBOutlet weak var detailedResultsButton: UIButton!
    @IBOutlet weak var detailedResultSeparatorView: UIView!
    @IBOutlet weak var detailedResultsView: UIView!
    @IBOutlet weak var changeServerBackgroundShadowView: UIView!
    @IBOutlet weak var changeServerBackgroundView: UIView!
    @IBOutlet weak var changeServerButton: UIButton!
    @IBOutlet weak var currentResultView: RMBTLoopModeResultView!
    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var detailedResultsWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var detailedResultsLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var detailedResultsRightConstraint: NSLayoutConstraint!
    @IBOutlet weak var systemInfoWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var systemInfoTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var systemInfoTopPortraitConstraint: NSLayoutConstraint!
    @IBOutlet weak var systemInfoLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var systemInfoRightConstraint: NSLayoutConstraint!
    @IBOutlet weak var heightForMainAreaConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomStatesConstraint: NSLayoutConstraint!
    @IBOutlet weak var progressTrailingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var progressColorView: RMBTGradientView!
    
    @IBOutlet weak var testButtonAreaWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var testButtonAreaRightConstraint: NSLayoutConstraint!
    private var isResultsDownloaded: Bool = false
    private var isQosResultsDownloaded: Bool = false
    private var testFinished: Bool = false
    
    weak var abortAlert: UIAlertController?
    
    var heightForMainArea: CGFloat = 342
    
    private var isStarted = false {
        didSet {
            UIApplication.shared.isIdleTimerDisabled = isStarted
        }
    }
    
    private var testResult: RMBTLoopModeResult = RMBTLoopModeResult() {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    internal var rmbtClient = RMBTClient(withClient: .standard) {
        didSet {
            rmbtClient.isStoreZeroMeasurement = RMBTSettings.sharedSettings.submitZeroTesting && TEST_STORE_ZERO_MEASUREMENT
            rmbtClient.isQOSEnabled = self.isQosEnabled
        }
    }
    
    var items: [RMBTTestState] = []
    
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
        if let item = self.item(with: self.currentState.rawValue) {
            if let currentValue = item.currentValue {
                if item.identifier == "ping" {
                    self.currentResultView.valueLabel?.text = RMBTMillisecondsString(UInt64((currentValue as NSString).longLongValue))
                } else if item.identifier == "jitter" {
                    self.currentResultView.valueLabel?.text = RMBTMillisecondsString(UInt64((currentValue as NSString).longLongValue))
                } else if item.identifier == "download" || item.identifier == "upload" {
                    self.currentResultView.valueLabel?.text = RMBTSpeedMbpsString(Double(currentValue) ?? 0.0, withMbps: false)
                } else if item.identifier == "qos" {
                    if let qosPerformed = self.testResult.qosPerformed,
                        let qosPassed = self.testResult.qosPassed {
                        self.currentResultView.valueLabel?.text = String(format: "%d/%d", qosPassed, qosPerformed)
                    } else {
                        self.currentResultView.valueLabel?.text = "-"
                    }
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
        case .jitter:
            self.currentResultView.titleLabel?.text = L("loopmode.test.state.jitter")
            self.currentResultView.valueLabel?.text = "-"
            self.currentResultView.subtitleLabel?.text = "ms"
        case .download:
            self.currentResultView.titleLabel?.text = L("loopmode.test.state.download")
            self.currentResultView.valueLabel?.text = "-"
            self.currentResultView.subtitleLabel?.text = L("test.speed.unit")
        case .upload:
            self.currentResultView.titleLabel?.text = L("loopmode.test.state.upload")
            self.currentResultView.valueLabel?.text = "-"
            self.currentResultView.subtitleLabel?.text = L("test.speed.unit")
        case .qos:
            self.currentResultView.titleLabel?.text = L("loopmode.test.state.qos")
            self.currentResultView.subtitleLabel?.text = ""
            self.currentResultView.valueLabel?.text = "1%"
        default:
            break
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        RMBTDisplayLinker.shared.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.heightForMainAreaConstraint.constant = self.heightForMainArea
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "btn_close"), style: .plain, target: self, action: #selector(closeButtonClick(_:)))
        
        let theServer = RMBTConfig.sharedInstance.measurementServer
        self.changeServerButton.setTitle(theServer?.fullNameWithDistance, for: .normal)
        
        self.rmbtClient.isStoreZeroMeasurement = RMBTSettings.sharedSettings.submitZeroTesting && TEST_STORE_ZERO_MEASUREMENT
        self.rmbtClient.isQOSEnabled = self.isQosEnabled
        
        self.qosButton.setTitle(L("RMBT-TEST-START_QOS_BUTTON"), for: .normal)
        self.qosButton.titleLabel?.numberOfLines = 0
        
        self.detailedResultsButton.setTitle(L("test.show-detailed-results"), for: .normal)
        
        self.qosButton.isHidden = true
        self.detailedResultsView.isHidden = true
        
        let nib = UINib(nibName: RMBTTestTableViewCell.ID, bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: RMBTTestTableViewCell.ID)
        
        self.updateProgressLabel()
        self.prepareItems()
        self.startTest()
        
        self.applyColorScheme()
        self.updateColorForNavigationBarAndTabBar()
        
        RMBTDisplayLinker.shared.addObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.applyColorScheme()
        self.updateColorForNavigationBarAndTabBar()
        self.tableView.reloadData()
        self.updateUIComponents()
        if IS_SHOW_ADVERTISING {
            showAdvertising()
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
//        self.currentResultView.superview?.constraint(with: "centerY")?.priority = .defaultHigh
        if UIApplication.shared.statusBarOrientation.isLandscape && UIDevice.isDeviceTablet() == false {
            self.testButtonAreaWidthConstraint.priority = .defaultHigh
            self.testButtonAreaRightConstraint.priority = .defaultLow
            self.systemInfoLeftConstraint.priority = .defaultLow
            self.systemInfoTopPortraitConstraint.priority = .defaultLow
            self.systemInfoTopConstraint.priority = .defaultHigh
            self.systemInfoWidthConstraint.priority = .defaultHigh
            self.detailedResultsLeftConstraint.priority = .defaultLow
            self.detailedResultsWidthConstraint.priority = .defaultHigh
            self.currentResultView.superview?.constraint(with: "top")?.priority = .defaultHigh
            self.currentResultView.superview?.constraint(with: "centerY")?.priority = .defaultLow
        } else {
            self.testButtonAreaWidthConstraint.priority = .defaultLow
            self.testButtonAreaRightConstraint.priority = .defaultHigh
            self.systemInfoLeftConstraint.priority = .defaultHigh
            self.systemInfoTopPortraitConstraint.priority = .defaultHigh
            self.systemInfoTopConstraint.priority = .defaultLow
            self.systemInfoWidthConstraint.priority = .defaultLow
            self.detailedResultsLeftConstraint.priority = .defaultHigh
            self.detailedResultsWidthConstraint.priority = .defaultLow
            self.currentResultView.superview?.constraint(with: "top")?.priority = .defaultLow
            self.currentResultView.superview?.constraint(with: "centerY")?.priority = .defaultHigh
        }
        
        self.updateUIComponents()
        self.updateHeightMainContainer()
    }
    
    func updateHeightMainContainer() {
        let screenHeight = self.view.frameHeight - self.changeServerBackgroundView.frameHeight
        if UIDevice.isDeviceTablet() {
            let startTestButtonWidth = self.currentResultView?.frameWidth ?? 0.0
            let sidePadding = (self.view.frameWidth - startTestButtonWidth) / 2
            self.systemInfoLeftConstraint.constant = sidePadding
            self.systemInfoRightConstraint.constant = sidePadding
            self.detailedResultsLeftConstraint.constant = sidePadding
            self.detailedResultsRightConstraint.constant = sidePadding
            
            heightForMainAreaConstraint.constant = screenHeight / 2
            
            let tableViewHeight: CGFloat = CGFloat(self.items.count * 24 + 20)
            var statesHeight = tableViewHeight + self.detailedResultsView.frameHeight
            if RMBTClient.advertisingIsActive {
                statesHeight += self.advertisingContainer.frameHeight
            }
            
            let padding = (screenHeight / 2 - statesHeight) / 2
            self.systemInfoTopPortraitConstraint.constant = padding
        } else {
            if UIApplication.shared.statusBarOrientation.isPortrait {
                let height = screenHeight / 2
                if self.detailedResultsView.frame.maxY > self.view.frameHeight - 10 {
                    heightForMainAreaConstraint.constant = height - (self.detailedResultsView.frame.maxY - (self.view.frameHeight - 10))
                } else {
                    heightForMainAreaConstraint.constant = height
                }
            } else {
                heightForMainAreaConstraint.constant = screenHeight + 20
            }
        }
    }
    
    func updateUIComponents() {
        if UIDevice.isDeviceTablet() {
            let width = self.currentResultView.constraint(with: UIView.ConstraintIdentifier.width.rawValue)
            let height = self.currentResultView.constraint(with: UIView.ConstraintIdentifier.height.rawValue)
            
            let screenHeight = self.view.frameHeight - self.changeServerBackgroundView.frameHeight
            var size: CGFloat = 310
            if size > screenHeight / 2 - 10 {
                size = screenHeight / 2 - 10
            }
            width?.constant = size
            height?.constant = size
            let titleFont = UIFont.systemFont(ofSize: 28, weight: .semibold)
            let subtitleFont = UIFont.systemFont(ofSize: 24, weight: .semibold)
            let textFont = UIFont.systemFont(ofSize: 88, weight: .ultraLight)
            self.currentResultView.titleLabel?.font = titleFont
            self.currentResultView.subtitleLabel?.font = subtitleFont
            self.currentResultView.valueLabel?.font = textFont
            self.qosButton.titleLabel?.font = textFont
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        guard UIApplication.shared.applicationState == .inactive else {
            return
        }
        
        self.applyColorScheme()
        self.updateColorForNavigationBarAndTabBar()
        self.tableView.reloadData()
    }
    
    override func applyColorScheme() {
        self.view.backgroundColor = RMBTColorManager.background
        
        changeServerButton.setTitleColor(RMBTColorManager.currentServerTitleColor, for: .normal)
        
        changeServerBackgroundShadowView.backgroundColor = RMBTColorManager.tableViewSeparator
        progressColorView.backgroundColor = RMBTColorManager.tintColor
        progressColorView.colors = [
            RMBTColorManager.tintPrimaryColor,
            RMBTColorManager.tintSecondaryColor
        ]
        
        currentResultView.emptyBackgroundColor = RMBTColorManager.background
        currentResultView.notEmptyBackgroundColor = RMBTColorManager.testTintColor
        currentResultView.emptyTextColor = RMBTColorManager.tintColor
        currentResultView.notEmptyTextColor = RMBTColorManager.currentValueTitleColor
        currentResultView.emptyValueTextColor = RMBTColorManager.tintColor
        currentResultView.notEmptyValueTextColor = RMBTColorManager.valueTextColor
        currentResultView.applyColorScheme()
        
        if let button = qosButton as? RMBTGradientButton {
            button.colors = [
                RMBTColorManager.tintPrimaryColor,
                RMBTColorManager.tintSecondaryColor
            ]
        }
        qosButton.setTitleColor(RMBTColorManager.currentValueTitleColor, for: .normal)
        qosButton.backgroundColor = RMBTColorManager.tintColor
        
        detailedResultSeparatorView.backgroundColor = RMBTColorManager.tintColor
        detailedResultsButton.setTitleColor(RMBTColorManager.tintColor, for: .normal)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var targetProgress: CGFloat = 0
    var previousProgress: CGFloat = 0
    
    func updateProgressBar(with duration: CGFloat) {
        let progress = (self.targetProgress - self.previousProgress) * duration * 10
        
        displayPercentage(self.previousProgress + progress)
//        self.progressTrailingConstraint.constant = self.previousProgress + progress
        if self.currentState == .ping && self.isShowResult == false {
            let percentage: CGFloat = CGFloat(self.percentageAfterPhase(phase: .Init))
            let phasePercent: CGFloat = CGFloat(self.percentageForPhase(.latency))
            var currentPercent = (self.previousProgress + progress) - percentage
            if currentPercent < 0 {
                currentPercent = 0.0
            }
            self.currentResultView.valueLabel?.text = String(format: "%0.0f%%", (currentPercent / phasePercent) * 100.0)
            self.currentResultView.subtitleLabel?.text = ""
        }
        
        if self.currentState == .jitter && self.isShowResult == false {
            let percentage: CGFloat = CGFloat(self.percentageAfterPhase(phase: .latency))
            let phasePercent: CGFloat = CGFloat(self.percentageForPhase(.jitter))
            var currentPercent = (self.previousProgress + progress) - percentage
            if currentPercent < 0 {
                currentPercent = 0.0
            }
            self.currentResultView.valueLabel?.text = String(format: "%0.0f%%", (currentPercent / phasePercent) * 100.0)
            self.currentResultView.subtitleLabel?.text = ""
        }
        self.previousProgress += progress
    }

    fileprivate func showAdvertising() {
        logger.debug("RMBTSettings.sharedSettings.isAdsRemoved \(RMBTSettings.sharedSettings.isAdsRemoved)")
        logger.debug("RMBTClient.advertisingIsActive \(RMBTClient.advertisingIsActive)")
        if RMBTSettings.sharedSettings.isAdsRemoved == true || RMBTClient.advertisingIsActive == false {
            return
        }
        
        let onLoadedAdMobHandler: (_ error: Error?) -> Void = { error in
            if error != nil {
                return
            }
            AnalyticsHelper.logCustomEvent(withName: "home.test.ad_loaded", attributes: ["is_loaded": true])
            let rect = CGRect(0, 0, 320, 50)
            RMBTAdvertisingManager.shared.showAdMobBanner(with: rect, in: self.advertisingContainer)
            logger.debug("onLoadedAdMobHandler \(self.advertisingContainer.frame)")
        }
        
        RMBTAdvertisingManager.shared.onLoadedAdMobHandler = onLoadedAdMobHandler
        if RMBTAdvertisingManager.shared.state == .loaded {
            onLoadedAdMobHandler(nil)
        } else {
            if RMBTAdvertisingManager.shared.state == .error {
                logger.debug("RMBTAdvertisingManager.shared.state error \(RMBTAdvertisingManager.shared.state)")
                logger.debug("start reloading advertising")
                RMBTAdvertisingManager.shared.reloadingAdMobBanner()
            }
        }
    }
    
    @IBAction func showDetailedResultsButtonClick(_ sender: Any) {
        self.performSegue(withIdentifier: self.showResultsSegue, sender: self)
    }
    
    @IBAction func startQosTestButtonClick(_ sender: Any) {
        self.isQosEnabled = true
        let qosItem = RMBTTestState()
        qosItem.identifier = State.qos.rawValue
        qosItem.title = L("test.title.qos")
        qosItem.priority = 1
        self.items.append(qosItem)
        self.tableView.reloadData()
        self.qosButton.isHidden = true
        self.detailedResultsView.isHidden = true
        self.displayPercentage(CGFloat(finishedPercentage))
        self.isStarted = true
        self.startQosMeasurementAction()
    }
    
    @IBAction func closeButtonClick(_ sender: Any) {
        if self.isStarted && self.rmbtClient.running {
            self.showAbortAlert()
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func showAbortAlert() {
        self.abortAlert = abortMeasurementAction()
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
        let pingItem = RMBTTestState()
        pingItem.identifier = State.ping.rawValue
        pingItem.title = L("RMBT-HOME-PING")
        pingItem.priority = 2
        
        let packetLoseItem = RMBTTestState()
        packetLoseItem.identifier = State.packetLose.rawValue
        packetLoseItem.title = L("RBMT-BASE-PACKETLOSS")
        packetLoseItem.priority = 6
        
        let jitterItem = RMBTTestState()
        jitterItem.identifier = State.jitter.rawValue
        jitterItem.title = L("RBMT-BASE-JITTER")
        jitterItem.priority = 5
        
        let downloadItem = RMBTTestState()
        downloadItem.identifier = State.download.rawValue
        downloadItem.title = L("RMBT-HOME-DOWNLOADMBPS")
        downloadItem.priority = 3
        
        let uploadItem = RMBTTestState()
        uploadItem.identifier = State.upload.rawValue
        uploadItem.title = L("RMBT-HOME-UPLOADMBPS")
        uploadItem.priority = 4
        
        let qosItem = RMBTTestState()
        qosItem.identifier = State.qos.rawValue
        qosItem.title = L("test.title.qos")
        qosItem.priority = 1
        
        var items = [pingItem, packetLoseItem, jitterItem, downloadItem, uploadItem]
        if self.rmbtClient.isQOSEnabled {
            items.append(qosItem)
        }
        self.items = items
    }
    
    func updateProgressLabel() {
        let text = L("loopmode.init.btn.test")
        self.title = text
    }
    
    func startNextLoopIfCan(_ isImmediatelly: Bool = false) {
        if isResultsDownloaded == true && isQosResultsDownloaded == true {
            let result = self.testResult
            result.isFinished = true
            
            self.abortAlert?.dismiss(animated: true, completion: nil)
            self.isStarted = false
            if self.isQosEnabled == true {
                self.showResults()
            } else {
                self.qosButton.isHidden = false
                self.detailedResultsView.isHidden = false
                RMBTAdvertisingManager.shared.reloadingAdMobBanner()
            }
        }
    }
    
    func startNextLoop(isFirst: Bool = false) {
        finishedPercentage = 0
        let result = RMBTLoopModeResult()
        result.isFinished = false
        self.testResult = result
        self.tableView.reloadData()
        self.startMeasurementAction()
    }
    
    func item(with identifier: String) -> RMBTTestState? {
        return self.items.first(where: { (item) -> Bool in
            return item.identifier == identifier
        })
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == self.showResultsSegue,
            let vc = segue.destination as? RMBTTestResultsViewController {
            vc.testResult = self.testResult
            vc.items = self.items
            vc.networkInfo = self.networkInfo
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
    
    func displayPercentage(_ percentage: CGFloat) {
        var calculatedPercentage = percentage
        
        let countTests: CGFloat = self.rmbtClient.isQOSEnabled ? 2 : 1
        calculatedPercentage /= countTests
        
        self.progressTrailingConstraint.constant = self.view.bounds.width * (CGFloat(100 - calculatedPercentage) / 100.0)
    }
}

extension RMBTTestViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = RMBTTestHeader.view()
        header?.applyColorScheme()
        header?.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 20)
        return header
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: RMBTTestTableViewCell.ID, for: indexPath) as! RMBTTestTableViewCell
        cell.applyColorScheme()
        let item = self.items[indexPath.row]
        cell.testModelView = RMBTTestTableViewCell.RMBTTestModelView(item: item)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 24
    }
}

extension RMBTTestViewController: ManageMeasurement {
    func manageViewControllerAbort() {
        //Nothing we already make it in manageViewsAbort
    }
    
    func measurementDidStart(client: RMBTClient) { }
    
    func measurementDidCompleteVoip(_ client: RMBTClient, withResult: [String: Any]) {
        // compute mean jitter as outcome
        let testResult: RMBTLoopModeResult = self.testResult
        if let inJiter = withResult["voip_result_out_mean_jitter"] as? NSNumber,
            let outJiter = withResult["voip_result_in_mean_jitter"] as? NSNumber {
            let j = String(format: "%.1f",(inJiter.doubleValue + outJiter.doubleValue) / 2_000_000)
            // assign value
            testResult.jitter = j
            let item = self.item(with: State.jitter.rawValue)
            item?.currentValue = j
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

            testResult.packetLoss = packetLoss
            let item = self.item(with: State.packetLose.rawValue)
            item?.currentValue = packetLoss
        }
    }
    
    func manageViewsAbort() {
        DispatchQueue.main.async {
            self.isStarted = false
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func manageViewNewStart() {
        self.isShowResult = true
        self.currentState = .Init
        self.prepareItems()
        self.updateCurrentStateView(with: self.currentState)
        self.isShowResult = false
        self.displayPercentage(0)
    }
    
    func manageViewProgress(phase: SpeedMeasurementPhase, title: String, value: Double) {
        
        let phasePercentage = Float(percentageForPhase(phase)) * Float(value)
        let totalPercentage = Float(finishedPercentage) + phasePercentage
        assert(totalPercentage <= 100, "Invalid percentage")
        
        self.targetProgress = CGFloat(totalPercentage)
//        displayPercentage(totalPercentage)
        
        logger.debug(totalPercentage)
    }
    
    func manageViewProcess(_ phase: SpeedMeasurementPhase) {
        switch phase {
        case .latency:
            self.currentState = .ping
            let item = self.item(with: State.ping.rawValue)
            item?.progress = 0.01
        case .jitter, .packLoss :
            self.currentState = .jitter
            let item = self.item(with: State.jitter.rawValue)
            item?.progress = 0.01
        case .down:
            self.currentState = .download
            let item = self.item(with: State.download.rawValue)
            item?.progress = 0.01
        case .up, .initUp:
            self.currentState = .upload
            let item = self.item(with: State.upload.rawValue)
            item?.progress = 0.01
        default:
            break
        }
        
        self.tableView.reloadData()
    }
    
    func manageViewFinishPhase(_ phase: SpeedMeasurementPhase, withResult result: Double) {
        switch phase {
        case .Init, .fetchingTestParams:
            let item = self.item(with: State.ping.rawValue)
            item?.progress = 0.01
            self.currentResultView.valueLabel?.text = "-"
            self.currentResultView.titleLabel?.text = L("loopmode.test.state.init")
        case .wait:
            let item = self.item(with: State.ping.rawValue)
            item?.progress = 1.0
            item?.currentValue = String(result)
        case .latency:
            let item = self.item(with: State.ping.rawValue)
            item?.progress = 1.0
            item?.currentValue = String(result)
            self.showStateResult()
        case .jitter:
            let item = self.item(with: State.jitter.rawValue)
            item?.progress = 1.0
            item?.currentValue = String(result)
            self.showStateResult()
        case .down:
            let item = self.item(with: State.download.rawValue)
            item?.progress = 1.0
            item?.currentValue = String(result)
            print("DOWNLOAD=================\(result)")
            self.showStateResult()
        case .up:
            let item = self.item(with: State.upload.rawValue)
            item?.progress = 1.0
            item?.currentValue = String(result)
            print("UPLOAD=================\(result)")
            self.showStateResult()
        default:
            break
        }
        
        finishedPercentage = percentageAfterPhase(phase: phase)
        self.targetProgress = CGFloat(finishedPercentage)
//        displayPercentage(finishedPercentage)
        self.tableView.reloadData()
    }
    
    internal func speedMeasurementDidUpdateWith(progress: Float, inPhase phase: SpeedMeasurementPhase) {
        let phasePercentage = Float(percentageForPhase(phase)) * progress
        let totalPercentage = Float(finishedPercentage) + phasePercentage
        assert(totalPercentage <= 100, "Invalid percentage")
        
        self.targetProgress = CGFloat(totalPercentage)
//        displayPercentage(Int(totalPercentage))
        
        logger.debug(totalPercentage)
    }
    
    func manageViewFinishMeasurement(uuid: String) {
        if isIncreaseTestsCounter == false {
            RMBTSettings.sharedSettings.countMeasurements += 1
            isIncreaseTestsCounter = true
        }
        let item = self.item(with: State.qos.rawValue)
        item?.progress = 1.0
        self.tableView.reloadData()
        
        let testResult: RMBTLoopModeResult = self.testResult
        
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
                    testResult.jitter = String(currentValue)
                    let item = self?.item(with: State.jitter.rawValue)
                    item?.currentValue = String(currentValue)
                } else {
                    testResult.jitter = defaultValue
                    let item = self?.item(with: State.jitter.rawValue)
                    item?.currentValue = defaultValue
                }
                
                if results.first?.packetLossPercentageString != defaultValue {
                    testResult.packetLoss = results.first?.packetLossPercentageString.addPercentageString() ?? defaultValue
                    let item = self?.item(with: State.packetLose.rawValue)
                    item?.currentValue = results.first?.packetLossPercentageString
                } else {
                    testResult.packetLoss = defaultValue
                }
            } else {
                testResult.jitter = defaultValue
                testResult.packetLoss = defaultValue
            }
            
            testResult.up = results.first?.uploadSpeedMbpsString
            testResult.down = results.first?.downloadSpeedMbpsString
            testResult.ping = results.first?.shortestPingMillisString
            
            self?.tableView.reloadData()
            self?.isResultsDownloaded = true
            self?.startNextLoopIfCan()
            
        }, error: { error in
            _ = UIAlertController.presentErrorAlert(error as NSError, dismissAction: nil)
        })
        
        if rmbtClient.isQOSEnabled {
            MeasurementHistory.sharedMeasurementHistory.getQOSHistoryOld(uuid: uuid, success: { [weak self]  (response) in
                let qosResults = response
                
                testResult.qosFailed = qosResults.calculateQosFailed()
                testResult.qosPassed = qosResults.calculateQosSuccess()
                testResult.qosPerformed = qosResults.testResultDetail?.count ?? 0
                
                self?.showStateResult()
                self?.tableView.reloadData()
                self?.isQosResultsDownloaded = true
                self?.startNextLoopIfCan()
            }, error: { _ in
            })
        } else {
            self.isQosResultsDownloaded = true
        }
        
        self.abortAlert?.dismiss(animated: true, completion: nil)
        RMBTSettings.sharedSettings.previousNetworkName = self.networkInfo?.networkName
        
        let duration: Double = 60 * 60 * 24 * 7 // 1 week
        RMBTRateManager.manager.tick(with: "count_successful_measurements", maxCount: 5, duration: duration)
        
        if RMBTClient.surveyIsActiveService == true {
            if RMBTSettings.sharedSettings.lastSurveyTimestamp < RMBTClient.surveyTimestamp ?? 0.0 {
                checkSurvey(success: { (response) in
                    if response.survey?.isFilledUp == false {
                        _ = UIAlertController.presentSurveyAlert({ (_) in
                            if let surveyUrl = response.survey?.surveyUrl,
                                let uuid = RMBTClient.uuid,
                                let url = URL(string: surveyUrl + "?client_uuid=" + uuid) {
                                UIApplication.shared.open(url, completionHandler: nil)
                                RMBTSettings.sharedSettings.lastSurveyTimestamp = RMBTClient.surveyTimestamp ?? 0.0
                                AnalyticsHelper.logCustomEvent(withName: "Survey: Open Clicked", attributes: nil)
                            } else {
                                var parameters = ["Reason": "Bad Url"]
                                parameters["url"] = response.survey?.surveyUrl ?? "Empty"
                                parameters["uuid"] = RMBTClient.uuid ?? "Empty"
                                AnalyticsHelper.logCustomEvent(withName: "Survey: Don't showed", attributes: parameters)
                            }
                        }, neverAction: { (_) in
                            RMBTSettings.sharedSettings.lastSurveyTimestamp = RMBTClient.surveyTimestamp ?? 0.0
                            AnalyticsHelper.logCustomEvent(withName: "Survey: Never Clicked", attributes: nil)
                        }, remindAction: { (_) in
                            AnalyticsHelper.logCustomEvent(withName: "Survey: Remind Clicked", attributes: nil)
                        })
                    } else if response.survey?.isFilledUp == true {
                        RMBTSettings.sharedSettings.lastSurveyTimestamp = RMBTClient.surveyTimestamp ?? 0.0
                    }
                }, error: { (_) in
                    
                })
            }
        }
        
        (self.tabBarController as? RMBTTabBarViewController)?.updateHistory()
        if let tabBarController = UIApplication.shared.delegate?.tabBarController() {
            tabBarController.updateHistory()
        }
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
        item?.currentValue = String(format: "%0.0f", item?.progress ?? 0)
        if self.isShowResult == false {
            self.currentResultView.valueLabel?.text = String(format: "%d%%", value)
        }
        self.targetProgress = CGFloat(finishedPercentage + value)
//        displayPercentage(finishedPercentage + value)
        self.tableView.reloadData()
    }
    
    func manageViewAfterQosGetList(list: [QosMeasurementType]) {
        
    }
    
    func manageViewAfterQosFinishedTest(type: QosMeasurementType) {
        
    }
    
    internal func speedMeasurementDidMeasureSpeed(throughputs: [RMBTThroughput], inPhase phase: SpeedMeasurementPhase) {
        let result = self.testResult
        var kbps: Double = 0
        for i in 0 ..< throughputs.count {
            let t = throughputs[i]
            kbps = t.kilobitsPerSecond()
            if i == 0 {
                switch phase {
                case .down:
                    result.down = String(kbps)
                    let item = self.item(with: State.download.rawValue)
                    item?.currentValue = String(kbps)//RMBTSpeedMbpsString(kbps, withMbps: false)
                    print("download results")
                    print(RMBTSpeedMbpsString(kbps, withMbps: false))
                    if self.isShowResult == false {
                        self.currentResultView.valueLabel?.text = RMBTSpeedMbpsString(kbps, withMbps: false)
                    }
                    self.tableView.reloadData()
                case .up:
                    result.up = String(kbps)
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
}

extension RMBTTestViewController: RMBTDisplayLinkerDelegate {
    func updateDisplay(with duration: CGFloat) {
        self.updateProgressBar(with: duration)
    }
}

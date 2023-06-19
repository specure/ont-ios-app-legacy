//
//  RMBTHistoryIndexViewController.swift
//  RMBT
//
//  Created by Benjamin Pucher on 26.09.14.
//  Copyright © 2014 SPECURE GmbH. All rights reserved.
//

import Foundation

//static NSUInteger const kBatchSize = 25;

///
let kBatchSize: Int = 25 // Entries to fetch from server

///
enum RMBTHistoryIndexViewControllerState: Int {
    case loading
    case empty
    case filteredEmpty
    case hasEntries
    case serverNotAvailable
}

///
class RMBTHistoryIndexViewController: TopLevelViewController, UITableViewDataSource, UITableViewDelegate {

    override var preferredStatusBarStyle: UIStatusBarStyle { return RMBTColorManager.statusBarStyle }
    
    override var shouldAutorotate: Bool {
        let configuration = RMBTConfigFabric.config(with: RMBTConfigurationIdentifier)
        if configuration.RMBT_VERSION == 3 {
            return super.shouldAutorotate
        }
        return true
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        let configuration = RMBTConfigFabric.config(with: RMBTConfigurationIdentifier)
        if configuration.RMBT_VERSION == 3 {
            return super.preferredInterfaceOrientationForPresentation
        }
        return .portrait
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        let configuration = RMBTConfigFabric.config(with: RMBTConfigurationIdentifier)
        if configuration.RMBT_VERSION == 3 {
            return super.supportedInterfaceOrientations
        }
        return .all
    }
    
    @IBOutlet weak var statusBarView: UIView!
    ///
    @IBOutlet private var tableView: UITableView!

    ///
    @IBOutlet private var loadingLabel: UILabel!

    ///
    @IBOutlet private var emptyLabel: UILabel!

    ///
    @IBOutlet private var emptyFilteredLabel: UILabel!

    ///
    @IBOutlet private var clearActiveFiltersButton: UIButton!

    ///
    @IBOutlet private var loadingActivityIndicatorView: UIActivityIndicatorView!
    
    @IBOutlet weak var backgroundView: UIImageView?
    
    @IBOutlet weak var arrowImageView: UIImageView!
    @IBOutlet weak var testButton: UIButton!
    ///
    private var filterButtonItem: UIBarButtonItem!

    ///
    private var syncButtonItem: UIBarButtonItem!

    ///
    private var enterCodeAlertView: UIAlertController!

    ///
    private var testResults: [RMBTHistoryResult] = []

    ///
    private var nextBatchIndex: Int = 0

    ///
    private var allFilters = HistoryFilterType()

    ///
    private var activeFilters: HistoryFilterType!

    ///
    private var loading = false

    ///
    private var tableViewController: UITableViewController!

    ///
    private var firstAppearance = false

    ///
    private var showingLastTestResult = false

    var latestTestHandler: (_ result: RMBTHistoryResult?) -> Void = { _ in }
    //

    ///
    private var state: RMBTHistoryIndexViewControllerState! {
        didSet {
            if self.isViewLoaded {
                self.emptyLabel.text = L("RBMT-HISTORY-NORECORDSYET")
                loadingLabel.isHidden = true
                loadingActivityIndicatorView.isHidden = true
                emptyLabel.isHidden = true
                emptyFilteredLabel.isHidden = true
                tableView.isHidden = true
                filterButtonItem.isEnabled = false
                clearActiveFiltersButton.isHidden = true

                self.arrowImageView.isHidden = true
                self.testButton.isHidden = true
                self.latestTestHandler(self.testResults.first)
                self.latestTestHandler = { _ in }
                if state == .empty {
                    emptyLabel.isHidden = false
                    self.testButton.isHidden = false
                    self.arrowImageView.isHidden = false
                } else if state == .filteredEmpty {
                    emptyFilteredLabel.isHidden = false
                    clearActiveFiltersButton.isHidden = false
                    filterButtonItem.isEnabled = true
                } else if state == .hasEntries {
                    tableView.isHidden = false
                    filterButtonItem.isEnabled = true
                } else if state == .loading {
                    loadingLabel.isHidden = false
                    loadingActivityIndicatorView.isHidden = false
                } else if state == .serverNotAvailable {
                    emptyLabel.isHidden = false
                    self.emptyLabel.text = L("history.error.server_not_available")
                }
            }
        }
    }

    deinit {
        defer {
            NotificationCenter.default.removeObserver(self)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.tabBarItem.title = L("tabbar.title.results")
        self.tabBarItem.image = UIImage(named: "ic_format_list_bulleted_white_25pt")
        self.navigationController?.tabBarItem = self.tabBarItem
    }
    ///
    override func viewDidLoad() {
        super.viewDidLoad()

        //
        refreshFilters()
        //
        self.emptyLabel.text = L("RBMT-HISTORY-NORECORDSYET")

        syncButtonItem = UIBarButtonItem(title: L("history.uibar.sync"),
                                         style: .plain,
                                         target: self,
                                         action: #selector(RMBTHistoryIndexViewController.sync))

        filterButtonItem = UIBarButtonItem(image: UIImage(named: "map_filter"),
                                           style: .plain,
                                           target: self,
                                           action: #selector(RMBTHistoryIndexViewController.getFilter))

//        automaticallyAdjustsScrollViewInsets = true
//        if #available(iOS 11.0, *) {
//            self.tableView.contentInsetAdjustmentBehavior = .always
//        } else {
//            // Fallback on earlier versions
//        }
        navigationItem.rightBarButtonItems = [filterButtonItem, syncButtonItem]

        //

        firstAppearance = true

        tableViewController = UITableViewController(style: .plain)
        tableViewController.tableView = self.tableView
        tableViewController.refreshControl = UIRefreshControl()

        tableViewController.didMove(toParent: self)
        tableViewController.refreshControl?.addTarget(self,
                                                      action: #selector(RMBTHistoryIndexViewController.refreshFromTableView),
                                                      for: .valueChanged)

        // for integration testing
        tableView.accessibilityLabel = "HistoryTable"
        tableView.backgroundColor = UIColor.clear
        
        NotificationCenter.default.addObserver(self, selector: #selector(orientationDidChange(notification:)), name: UIApplication.willChangeStatusBarOrientationNotification, object: nil)
        
        self.testButton.setTitle(L("history.empty.button.title"), for: .normal)
        self.applyColorScheme()
        self.updateColorForNavigationBarAndTabBar()
    }

    ///
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if firstAppearance {
            firstAppearance = false
            
            refresh()
            refreshFilters()
        } else {
            if let selectedIndexPath = tableView?.indexPathForSelectedRow {
                tableView?.deselectRow(at: selectedIndexPath, animated: true)
            } else if showingLastTestResult {
                // Note: This shouldn't be necessary once we have info required for index view in the
                // test result object. See -displayTestResult.
                
                showingLastTestResult = false
                
                refresh()
                refreshFilters()
            }
        }
        
        self.applyColorScheme()
        self.updateColorForNavigationBarAndTabBar()
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
        if self.view.backgroundColor != RMBTColorManager.background {
            self.tableView.reloadData()
        }
        self.statusBarView.backgroundColor = RMBTColorManager.navigationBarBackground
        self.view.backgroundColor = RMBTColorManager.background
        self.backgroundView?.backgroundColor = RMBTColorManager.cellBackground
        
        self.arrowImageView.image = self.arrowImageView.image?.withRenderingMode(.alwaysTemplate)
        self.arrowImageView.tintColor = RMBTColorManager.buttonTitleColor
        self.testButton.backgroundColor = RMBTColorManager.tintColor
        self.testButton.setTitleColor(RMBTColorManager.buttonTitleColor, for: .normal)
        
        self.syncButtonItem.setTitleTextAttributes([.foregroundColor: RMBTColorManager.navigationBarTitleColor], for: .normal)
    }
    
    @objc func orientationDidChange(notification: Notification) {
        DispatchQueue.main.async { // Need, because without it will detect wrong status bar orientation
            self.tableView.reloadData()
        }
    }
    
    func reloadHistory() {
        if self.isViewLoaded {
            refresh()
            refreshFilters()
        }
    }
    
    func latestOrSelectedTest(with completionHandler: @escaping (_ result: RMBTHistoryResult?) -> Void) {
        if self.state == .loading {
            self.latestTestHandler = completionHandler
        } else {
            if let indexPath = self.tableView?.indexPathForSelectedRow,
                self.testResults.count > indexPath.row {
                completionHandler(self.testResults[indexPath.row])
            } else {
                completionHandler(self.testResults.first)
            }
        }
    }
    ///
    func refreshFilters() {
        //
        RMBTConfig.updateSettings(success: {
            guard let filter = getHistoryFilter() else {
                return
            }
            self.allFilters = filter
        }, error: { _ in })
    }

    ///
    func refresh() {
        state = .loading
        testResults = [RMBTHistoryResult]()
        nextBatchIndex = 0

        getNextBatch()
    }

    /// Invoked by pull to refresh
    @objc func refreshFromTableView() {
        tableViewController.refreshControl?.beginRefreshing()

        self.state = .loading
        testResults = [RMBTHistoryResult]()
        nextBatchIndex = 0

        getNextBatch()
    }

    ///
    func getNextBatch() {
        assert(nextBatchIndex != NSNotFound, "Invalid batch")
        if loading == false && self.state != .serverNotAvailable {
            loading = true

            let firstBatch: Bool = (nextBatchIndex == 0)
            let offset: Int = nextBatchIndex * kBatchSize

            MeasurementHistory.sharedMeasurementHistory.getHistoryWithFilters(filters: activeFilters,
                                                                              length: UInt(kBatchSize),
                                                                              offset: UInt(offset),
                                                                              success: { [weak self] response in
                                                                                self?.handleResponse(response, firstBatch: firstBatch)
            }, error: { [weak self] _ in
                self?.hangleError(firstBatch: firstBatch)
            })
        }
    }
    
    func hangleError(firstBatch: Bool) {
        print("error")
        if firstBatch {
            self.state = .serverNotAvailable
            self.tableView?.reloadData()
        }
        self.loading = false
        self.tableViewController.refreshControl?.endRefreshing()
    }
    
    func handleResponse(_ response: HistoryWithFiltersResponse, firstBatch: Bool) {
        let oldCount = self.testResults.count
        
        var indexPaths = [NSIndexPath]()
        var results = [RMBTHistoryResult]()
        
        for r in response.records {
            results.append(RMBTHistoryResult(response: r as HistoryItem))
            indexPaths.append(NSIndexPath(row: oldCount - 1 + results.count, section: 0))
        }
        
        // We got less results than batch size, this means this was the last batch
        if results.count < kBatchSize {
            self.nextBatchIndex = NSNotFound
        } else {
            self.nextBatchIndex += 1
        }
        
        self.testResults.append(contentsOf: results)
        
        if firstBatch {
            self.state = (self.testResults.count == 0) ? ((self.activeFilters != nil) ? .filteredEmpty : .empty) : .hasEntries
            self.tableView?.reloadData()
        } else {
            self.tableView?.beginUpdates()
            
            if self.nextBatchIndex == NSNotFound {
                self.tableView.deleteRows(at: [IndexPath(row: oldCount, section: 0)], with: .fade)
            }
            
            if indexPaths.count > 0 {
                self.tableView?.insertRows(at: indexPaths as [IndexPath], with: .fade)
            }
            
            self.tableView?.endUpdates()
        }
        
        self.loading = false
        self.tableViewController.refreshControl?.endRefreshing()
    }

    ///
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row >= (testResults.count - 5) {
            if !loading && nextBatchIndex != NSNotFound {
                getNextBatch()
            }
        }
    }

    ///
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var result = testResults.count

        if nextBatchIndex != NSNotFound {
            result += 1
        }

        return result
    }

    ///
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row >= testResults.count {
            // Loading cell
            let cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: "RMBTHistoryLoadingCell")

            // We have to start animating manually, because after cell has been reused the activity indicator seems to stop
            (cell?.viewWithTag(100) as! UIActivityIndicatorView).startAnimating()

            return cell
        } else {
            var cell: RMBTHistoryIndexCell!
            if self.view.boundsWidth < 450 {
                cell = tableView.dequeueReusableCell(withIdentifier: "RMBTHistoryTestResultCell_V2") as? RMBTHistoryIndexCell
            } else {
                cell = tableView.dequeueReusableCell(withIdentifier: "RMBTHistoryTestResultCell_Full_V2") as? RMBTHistoryIndexCell
            }
            if cell == nil {
                cell = tableView.dequeueReusableCell(withIdentifier: "RMBTHistoryTestResultCell_New") as? RMBTHistoryIndexCell
            }
            if cell == nil {
                cell = UITableViewCell(style: .subtitle, reuseIdentifier: "RMBTHistoryTestResultCell") as? RMBTHistoryIndexCell
            }

            let testResult = testResults[indexPath.row]
            cell.selectionStyle = .none
            cell.networkNameLabel?.text    = testResult.networkName ?? L("intro.network.connection.name-unknown")
            cell.dateLabel?.text           = testResult.dateString()
            cell.timeLabel?.text           = testResult.timeString()
            cell.deviceModelLabel?.text    = testResult.deviceModel
            cell.downloadSpeedLabel?.text  = testResult.downloadSpeedMbpsString
            cell.uploadSpeedLabel?.text    = testResult.uploadSpeedMbpsString
            cell.pingLabel?.text           = testResult.shortestPingMillisString
            cell.qosResultsLabel.text      = testResult.qosResults ?? "-"
            //
            cell.jitterLabel?.text = testResult.jitterMsString
            cell.packetLossLabel?.text = testResult.packetLossPercentageString

            if let networkTypeServerDescription = testResult.networkTypeServerDescription {
                if networkTypeServerDescription == "WLAN" {
                    cell.typeImageView?.image = UIImage(named: "wifi")?.withRenderingMode(.alwaysTemplate)
                } else if networkTypeServerDescription == "LAN" || networkTypeServerDescription == "CLI" {
                    cell.typeImageView?.image = UIImage(named: "history-lan")?.withRenderingMode(.alwaysTemplate)
                } else {
                    cell.typeImageView?.image = UIImage(named: "history-mobile")?.withRenderingMode(.alwaysTemplate)
                }
            } else {
                cell.typeImageView?.image = nil
            }
            
            cell.commonInit()
            cell.applyColorScheme()

            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if self.view.boundsWidth < 450 {
            let view = RMBTHistoryIndexHeader.view()
            view.applyColorScheme()
            return view
        } else {
            let view = RMBTHistoryIndexFullHeader.view()
            view.applyColorScheme()
            return view
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.view.boundsWidth < 450 {
            return 100
        } else {
            return 100
        }
    }

    ///
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let result = testResults[indexPath.row] as RMBTHistoryResult
        let configuration = RMBTConfigFabric.config(with: RMBTConfigurationIdentifier)
        if UIDevice.isDeviceTablet() && configuration.RMBT_VERSION > 2 {
            if let tabBarController = UIApplication.shared.delegate?.tabBarController(),
                let resultsVC = UIStoryboard.resultsScreen() as? RMBTHistoryResultViewController {
                resultsVC.historyResult = result
                tabBarController.push(vc: resultsVC, from: self)
            }
        } else {
            performSegue(withIdentifier: "show_result", sender: result)
        }
    }

// MARK: filter

    ///
    @objc func getFilter() {
        if UIDevice.isDeviceTablet() {
            self.showFilters(self)
        } else {
            performSegue(withIdentifier: "show_filter", sender: nil)
        }
    }

// MARK: Sync

    ///
    @objc func sync(sender: Any) {
        
        _ = UIAlertController.presentActionSync(sender: sender, nil, requestAction: { _ in
                
                MeasurementHistory.sharedMeasurementHistory.getSyncCode(success: { response in
                    
                    if let code = response.codes?[0].code {
                        
                        _ = UIAlertController.presentSyncCode(code: code, dismissAction: nil, copyAction: { _ in
                            
                            UIPasteboard.general.string = code
                        })
                    }
                    
                }, error: { _ in
                
                })
            
        }, enterCodeAction: { _ in
        
            self.enterCodeAlertView = UIAlertController.presentAlertEnterCode( nil, syncAction: { _ in
            
                self.syncDevices()
            
            }, codeAlertAction: { _ in
            
            })
        })
    }
    
    func syncDevices() {
    
        if let codeField = enterCodeAlertView?.textFields?[0] {
            
            if let code = codeField.text, code != "" {
                
                MeasurementHistory.sharedMeasurementHistory.syncDevicesWith(code: code, success: { response in
                    if response.error?.count ?? 0 > 0,
                        let errorText = response.error?.first {
                        let error = NSError(domain: "localhost", code: -1, userInfo: [NSLocalizedDescriptionKey: errorText])
                        _ = UIAlertController.presentErrorAlert(error, dismissAction: { _ in})
                        
                        print(error)
                    } else {
                        _ = UIAlertController.presentSuccess(code: code, dismissAction: nil, reloadAction: { _ in
                            
                            self.refresh()
                            self.refreshFilters()
                        })
                    }
                }, error: { error in
                    _ = UIAlertController.presentErrorAlert(error as NSError, dismissAction: { _ in})
                    
                    print(error)
                })
            } else {

                self.enterCodeAlertView = UIAlertController.presentAlertEnterCode( nil, syncAction: { _ in
                    
                    self.syncDevices()
                    
                }, codeAlertAction: { _ in
                    
                })
            }
        } else {
        }
    }

//// MARK: SWRevealViewControllerDelegate
//
    ///
    func revealControllerPanGestureBegan(_ revealController: SWRevealViewController!) {
        tableView?.isScrollEnabled = false
    }

    ///
    func revealControllerPanGestureEnded(_ revealController: SWRevealViewController!) {
        tableView?.isScrollEnabled = true
    }

// MARK: Segues

    ///
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "show_result" {

            let rvc = segue.destination as! RMBTHistoryResultViewController
            
            if let s = sender as? RMBTHistoryResult {
                rvc.historyResult = s
            }
        } else if segue.identifier == "show_filter" {
            let filterVC = segue.destination as! RMBTHistoryFilterViewController
            filterVC.allFilters = allFilters
            filterVC.activeFilters = activeFilters
            filterVC.delegate = self
        }
    }

    func showFilters(_ sender: Any) {
        if let tabBarController = UIApplication.shared.delegate?.tabBarController(),
            let filterVC = UIStoryboard.historyFilterScreen() as? RMBTHistoryFilterViewController {
            filterVC.allFilters = allFilters
            filterVC.activeFilters = activeFilters
            filterVC.delegate = self
            tabBarController.push(vc: filterVC, from: self)
        }
    }
    
    func updateFilters(activeFilters: HistoryFilterType!) {
        showingLastTestResult = true
        self.activeFilters = activeFilters
        refresh()
    }

    ///
    @IBAction func clearActiveFilters(sender: AnyObject) {
        activeFilters = nil
        refresh()
    }
    
    @IBAction func startFirstTest(sender: AnyObject) {
        if let rootViewController = UIApplication.shared.delegate?.window??.rootViewController as? RMBTTabBarViewController {
            rootViewController.openTest()
        }
        if let tabBarController = UIApplication.shared.delegate?.tabBarController() {
            tabBarController.openTest()
        }
        
        let configuration = RMBTConfigFabric.config(with: RMBTConfigurationIdentifier)
        if configuration.RMBT_VERSION == 2,
            let delegate = UIApplication.shared.delegate as? RMBTAppDelegate {
            delegate.showMainScreen()
        }
    }
}

extension RMBTHistoryResult {
    func dateString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.YYYY"
        return dateFormatter.string(from: timestamp)
    }
    func timeString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH.mm"
        return dateFormatter.string(from: timestamp)
    }
}

extension RMBTHistoryIndexViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if UIDevice.isDeviceTablet() == false {
            let point = scrollView.panGestureRecognizer.translation(in: self.tableView)
            if point.y < -40 {
                if self.navigationController?.isNavigationBarHidden == false {
                    self.navigationController?.setNavigationBarHidden(true, animated: true)
                }
            } else if point.y > 40 {
                if self.navigationController?.isNavigationBarHidden == true {
                    self.navigationController?.setNavigationBarHidden(false, animated: true)
                }
            }
        }
    }
}

extension RMBTHistoryIndexViewController: RMBTHistoryFilterViewControllerDelegate {
    func updateFilters(vc: RMBTHistoryFilterViewController) {
        self.updateFilters(activeFilters: vc.activeFilters)
        if UIDevice.isDeviceTablet() {
            if let tabBarController = UIApplication.shared.delegate?.tabBarController(),
                let vc = UIStoryboard.resultsScreen() as? RMBTHistoryResultViewController {
                self.latestOrSelectedTest(with: { [weak vc] (result) in
                    if let result = result {
                        vc?.historyResult = result
                    }
                })
                tabBarController.push(vc: vc, from: self)
            }
        }
    }
}

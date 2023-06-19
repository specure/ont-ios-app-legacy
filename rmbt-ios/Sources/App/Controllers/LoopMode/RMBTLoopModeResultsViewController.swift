//
//  RMBTLoopModeResultsViewController.swift
//  RMBT_ONT
//
//  Created by Sergey Glushchenko on 8/18/18.
//  Copyright © 2018 SPECURE GmbH. All rights reserved.
//

import UIKit

class RMBTLoopModeResultsViewController: UIViewController {

    enum CellType {
        case result
        case smallAdvertising
        case networkInfo
        case bigAdvertising
    }
    
    class Item {
        let type: CellType
        var item: RMBTLoopModeViewController.RMBTLoopModeState?
        var results: [RMBTLoopModeResult]?
        
        init(type: CellType, _ item: RMBTLoopModeViewController.RMBTLoopModeState? = nil, _ results: [RMBTLoopModeResult]? = nil) {
            self.type = type
            self.item = item
            self.results = results
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return RMBTColorManager.statusBarStyle
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var secondTableView: UITableView!
    
    @IBOutlet weak var tableViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableViewRightConstraint: NSLayoutConstraint!
    
    var reloadAdvertisingTimer: Timer?
    
    var networkInfo: RMBTNetworkInfo?
    var results: [RMBTLoopModeResult] = []
    var items: [RMBTLoopModeViewController.RMBTLoopModeState] = []
    var cellItems: [Item] = [] {
        didSet {
            self.tableView.reloadData()
        }
    }
    var secondCellItems: [Item] = [] {
        didSet {
            self.secondTableView.reloadData()
        }
    }
    
    deinit {
        defer {
            self.deleteTimer()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "btn_close"), style: .plain, target: self, action: #selector(closeButtonClick(_:)))
        
        self.title = L("loopmode.test.results.title")
        
        self.tableView.register(cell: RMBTLoopModeResultsTableViewCell.ID)
        self.tableView.register(cell: RMBTAdvertisingTableViewCell.ID)
        self.tableView.register(cell: RMBTNetworkInfoTableViewCell.ID)
        self.secondTableView.register(cell: RMBTLoopModeResultsTableViewCell.ID)
        self.secondTableView.register(cell: RMBTAdvertisingTableViewCell.ID)
        self.secondTableView.register(cell: RMBTNetworkInfoTableViewCell.ID)
        
        var inset = self.tableView.contentInset
        inset.top = 15
        inset.bottom = 15
        self.tableView.contentInset = inset
        
        var secondInset = self.secondTableView.contentInset
        secondInset.top = 15
        secondInset.bottom = 15
        self.secondTableView.contentInset = secondInset
        
        self.applyColorScheme()
        self.updateColorForNavigationBarAndTabBar()
        self.reloadData()
    }
    
    func reloadData() {
        if UIDevice.isDeviceTablet() {
            self.prepareItems(false)
        } else {
            self.prepareItems(UIApplication.shared.statusBarOrientation.isLandscape)
        }
    }
    
    override func viewWillLayoutSubviews() {
        self.reloadData()
        super.viewWillLayoutSubviews()
        
        if UIApplication.shared.statusBarOrientation.isLandscape && UIDevice.isDeviceTablet() == false {
            self.tableViewWidthConstraint.priority = .defaultHigh
            self.tableViewRightConstraint.priority = .defaultLow
        } else {
            self.tableViewWidthConstraint.priority = .defaultLow
            self.tableViewRightConstraint.priority = .defaultHigh
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

    func applyColorScheme() {
        self.view.backgroundColor = RMBTColorManager.background
        self.tableView.backgroundColor = RMBTColorManager.background
        self.secondTableView.backgroundColor = RMBTColorManager.background
    }
    
    func prepareItems(_ isLandscape: Bool = false) {
        var secondCellItems: [Item] = []
        var cellItems = self.items.map { (state) -> Item in
            return Item(type: .result, state, self.results)
        }
        
        if IS_SHOW_ADVERTISING,
            RMBTSettings.sharedSettings.isAdsRemoved == false,
            RMBTClient.advertisingIsActive == true {
            if isLandscape == false {
                cellItems.append(Item(type: .smallAdvertising))
            }
            secondCellItems.append(Item(type: .smallAdvertising))
        }
    
        if isLandscape == false {
            cellItems.append(Item(type: .networkInfo))
        }
        secondCellItems.append(Item(type: .networkInfo))
        
        if IS_SHOW_ADVERTISING,
            RMBTSettings.sharedSettings.isAdsRemoved == false,
            RMBTClient.advertisingIsActive == true {
            if isLandscape == false {
                cellItems.append(Item(type: .bigAdvertising))
            }
            secondCellItems.append(Item(type: .bigAdvertising))
        }
    
        self.cellItems = cellItems
        self.secondCellItems = secondCellItems
    }
    
    @IBAction func closeButtonClick(_ sender: Any) {
        self.deleteTimer()
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func createTimer() {
        if self.reloadAdvertisingTimer == nil {
            self.reloadAdvertisingTimer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(reloadAdvertising(_:)), userInfo: nil, repeats: true)
        }
    }
    
    func deleteTimer() {
        if let timer = reloadAdvertisingTimer,
            timer.isValid {
            timer.invalidate()
            reloadAdvertisingTimer = nil
        }
    }
    
    @objc func reloadAdvertising(_ timer: Timer) {
        RMBTAdvertisingManager.shared.onLoadedAdMobHandler = { [weak self] _ in
            self?.reloadData()
            self?.tableView.reloadData()
            self?.secondTableView.reloadData()
        }
        RMBTAdvertisingManager.shared.reloadingAdMobBanner()
    }
}

extension RMBTLoopModeResultsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tableView {
            return self.cellItems.count
        } else {
            return self.secondCellItems.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cellItem: Item
        if tableView == self.tableView {
            cellItem = self.cellItems[indexPath.row]
        } else {
            cellItem = self.secondCellItems[indexPath.row]
        }
        
        switch cellItem.type {
        case .result:
            let cell = tableView.dequeueReusableCell(withIdentifier: RMBTLoopModeResultsTableViewCell.ID, for: indexPath) as! RMBTLoopModeResultsTableViewCell
            let item = self.items[indexPath.row]
            cell.modelView = RMBTLoopModeResultsTableViewCell.RMBTLoopModeResultsModelView(item: item, results: self.results)
            cell.applyColorScheme()
            if UIDevice.isDeviceTablet() {
                let titleFont = UIFont.systemFont(ofSize: 28, weight: .semibold)
                let subtitleFont = UIFont.systemFont(ofSize: 24, weight: .semibold)
                let textFont = UIFont.systemFont(ofSize: 88, weight: .ultraLight)
                let size: CGFloat = (470 - 5) / 2
                cell.currentResultView.titleLabel?.font = titleFont
                cell.currentResultView.valueLabel?.font = textFont
                cell.currentResultView.subtitleLabel?.font = subtitleFont
                cell.medianResultView.titleLabel?.font = titleFont
                cell.medianResultView.valueLabel?.font = textFont
                cell.medianResultView.subtitleLabel?.font = subtitleFont
                cell.currentResultView.constraint(with: "width")?.constant = size
                cell.currentResultView.constraint(with: "height")?.constant = size
                cell.medianResultView.constraint(with: "width")?.constant = size
                cell.medianResultView.constraint(with: "height")?.constant = size
            }
            return cell
        case .smallAdvertising:
            let cell = tableView.dequeueReusableCell(withIdentifier: RMBTAdvertisingTableViewCell.ID, for: indexPath) as! RMBTAdvertisingTableViewCell
            let middle = (cell.frame.size.width - 320) / 2
            let rect = CGRect(middle, 25, 320, 50)
            RMBTAdvertisingManager.shared.showAdMobBanner(with: rect, in: cell)
            self.createTimer()
            return cell
        case .networkInfo:
            let cell = tableView.dequeueReusableCell(withIdentifier: RMBTNetworkInfoTableViewCell.ID, for: indexPath) as! RMBTNetworkInfoTableViewCell
            cell.modelView = RMBTNetworkInfoTableViewCell.RMBTNetworkInfoModelView(with: self.networkInfo)
            cell.isLandscape = tableView == self.secondTableView
            if UIDevice.isDeviceTablet() {
                let screenWidth = tableView.frameWidth
                let padding = screenWidth - 470
                cell.constraint(with: "left")?.constant = padding / 2
                cell.constraint(with: "right")?.constant = padding / 2
            }
            cell.applyColorScheme()
            return cell
        case .bigAdvertising:
            let cell = tableView.dequeueReusableCell(withIdentifier: RMBTAdvertisingTableViewCell.ID, for: indexPath) as! RMBTAdvertisingTableViewCell
            let middle = (cell.frame.size.width - 300) / 2
            let rect = CGRect(middle, 25, 300, 250)
            RMBTAdvertisingManager.shared.showAdMobBigBanner(with: rect, in: cell)
            self.createTimer()
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var item: Item
        if tableView == self.tableView {
            item = self.cellItems[indexPath.row]
        } else {
            item = self.secondCellItems[indexPath.row]
        }
        switch item.type {
        case .result:
            if UIDevice.isDeviceTablet() {
                let height: CGFloat = (470 - 5) / 2
                return height + 5
            }
            return 160
        case .smallAdvertising:
            return 75
        case .networkInfo:
            return 165
        case .bigAdvertising:
            return 275
        }
    }
}

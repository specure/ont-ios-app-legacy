//
//  RMBTLoopModeResultsViewController.swift
//  RMBT_ONT
//
//  Created by Sergey Glushchenko on 8/18/18.
//  Copyright © 2018 SPECURE GmbH. All rights reserved.
//

import UIKit

class RMBTTestResultsViewController: UIViewController {

    enum CellType {
        case result
        case listResults
        case smallAdvertising
        case networkInfo
        case bigAdvertising
    }
    
    class Item {
        let type: CellType
        var item: RMBTTestViewController.RMBTTestState?
        var testResult: RMBTLoopModeResult?
        
        init(type: CellType, _ item: RMBTTestViewController.RMBTTestState? = nil, _ testResult: RMBTLoopModeResult? = nil) {
            self.type = type
            self.item = item
            self.testResult = testResult
        }
    }
    
    override open var preferredStatusBarStyle: UIStatusBarStyle {
        return RMBTColorManager.statusBarStyle
    }
    
    @IBOutlet weak var rightConstraint: NSLayoutConstraint!
    @IBOutlet weak var widthConstraint: NSLayoutConstraint!
    @IBOutlet weak var secondCollectionView: UICollectionView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var reloadAdvertisingTimer: Timer?
    
    var networkInfo: RMBTNetworkInfo?
    var testResult: RMBTLoopModeResult = RMBTLoopModeResult()
    var items: [RMBTTestViewController.RMBTTestState] = []
    
    var cellItems: [Item] = [] {
        didSet {
            self.collectionView.reloadData()
        }
    }
    
    var secondCellItems: [Item] = [] {
        didSet {
            self.secondCollectionView.reloadData()
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
        
        self.title = L("test.results.title")
        // Do any additional setup after loading the view.
        
        self.collectionView.register(cell: RMBTTestResultsCollectionViewCell.ID)
        self.collectionView.register(cell: RMBTAdvertisingCollectionViewCell.ID)
        self.collectionView.register(cell: RMBTNetworkInfoCollectionViewCell.ID)
        self.collectionView.register(cell: RMBTTestResultsListCollectionViewCell.ID)
        self.secondCollectionView.register(cell: RMBTTestResultsCollectionViewCell.ID)
        self.secondCollectionView.register(cell: RMBTAdvertisingCollectionViewCell.ID)
        self.secondCollectionView.register(cell: RMBTNetworkInfoCollectionViewCell.ID)
        self.secondCollectionView.register(cell: RMBTTestResultsListCollectionViewCell.ID)
        
        var inset = self.collectionView.contentInset
        inset.top = 15
        inset.bottom = 15
        self.collectionView.contentInset = inset
        
        var secondInset = self.secondCollectionView.contentInset
        secondInset.top = 15
        secondInset.bottom = 15
        self.secondCollectionView.contentInset = inset
        
        self.applyColorScheme()
        self.updateColorForNavigationBarAndTabBar()
        self.reloadData()
    }
    
    override func viewWillLayoutSubviews() {
        self.reloadData()
        super.viewWillLayoutSubviews()
        
        if UIApplication.shared.statusBarOrientation.isLandscape && UIDevice.isDeviceTablet() == false {
            self.widthConstraint.priority = .defaultHigh
            self.rightConstraint.priority = .defaultLow
        } else {
            self.widthConstraint.priority = .defaultLow
            self.rightConstraint.priority = .defaultHigh
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
        self.collectionView.backgroundColor = RMBTColorManager.background
        self.secondCollectionView.backgroundColor = RMBTColorManager.background
    }
    
    func reloadData() {
        if UIDevice.isDeviceTablet() {
            self.prepareItems(false)
        } else {
            self.prepareItems(UIApplication.shared.statusBarOrientation.isLandscape)
        }
    }
    
    func prepareItems(_ isLandscape: Bool = false) {
        var secondCellItems: [Item] = []
        
        var cellItems: [Item] = []

        if UIDevice.isDeviceTablet(),
            self.view.frameWidth > (155 * 3 + 10) {
            cellItems.append(Item(type: .listResults))
        } else {
            cellItems = self.items.sorted(by: { (state1, state2) -> Bool in
                return state1.priority < state2.priority
            }).map { (state) -> Item in
                return Item(type: .result, state, self.testResult)
            }
        }
        
        if UIDevice.isDeviceTablet() == false {
            if IS_SHOW_ADVERTISING,
                RMBTSettings.sharedSettings.isAdsRemoved == false,
                RMBTClient.advertisingIsActive == true {
                if isLandscape == false {
                    cellItems.append(Item(type: .smallAdvertising))
                }
                secondCellItems.append(Item(type: .smallAdvertising))
            }
        }
    
        if isLandscape == false {
            cellItems.append(Item(type: .networkInfo))
        }
        secondCellItems.append(Item(type: .networkInfo))
        
        if IS_SHOW_ADVERTISING,
            RMBTSettings.sharedSettings.isAdsRemoved == false,
            RMBTClient.advertisingIsActive == true {
            if UIDevice.isDeviceTablet() {
                cellItems.append(Item(type: .smallAdvertising))
            } else {
                if isLandscape == false {
                    cellItems.append(Item(type: .bigAdvertising))
                }
                secondCellItems.append(Item(type: .bigAdvertising))
            }
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
            self?.collectionView.reloadData()
            self?.secondCollectionView.reloadData()
        }
        RMBTAdvertisingManager.shared.reloadingAdMobBanner()
    }
}

extension RMBTTestResultsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == secondCollectionView {
            return self.secondCellItems.count
        } else {
            return self.cellItems.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var item: Item
        if collectionView == secondCollectionView {
            item = self.secondCellItems[indexPath.row]
        } else {
            item = self.cellItems[indexPath.row]
        }
        
        switch item.type {
        case .listResults:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RMBTTestResultsListCollectionViewCell.ID, for: indexPath) as! RMBTTestResultsListCollectionViewCell
            cell.items = self.items
            cell.testResult = self.testResult
            cell.applyColorScheme()
            cell.collectionView.reloadData()
            return cell
        case .result:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RMBTTestResultsCollectionViewCell.ID, for: indexPath) as! RMBTTestResultsCollectionViewCell
            let item = self.items[indexPath.row]
            var align: NSTextAlignment = (indexPath.row % 2 == 0) ? .right : .left
            
            if self.items.count % 2 != 0 {
                if indexPath.row == self.items.count - 1 {
                    align = .justified
                }
            }
            
            cell.modelView = RMBTTestResultsCollectionViewCell.RMBTTestResultsModelView(item: item, testResult: self.testResult, align: align)
            cell.applyColorScheme()
            return cell
        case .smallAdvertising:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RMBTAdvertisingCollectionViewCell.ID, for: indexPath) as! RMBTAdvertisingCollectionViewCell
            let middle = (cell.frame.size.width - 320) / 2
            let rect = CGRect(middle, 25, 320, 50)
            RMBTAdvertisingManager.shared.showAdMobBanner(with: rect, in: cell)
            self.createTimer()
            return cell
        case .networkInfo:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RMBTNetworkInfoCollectionViewCell.ID, for: indexPath) as! RMBTNetworkInfoCollectionViewCell
            cell.modelView = RMBTNetworkInfoCollectionViewCell.RMBTNetworkInfoModelView(with: self.networkInfo)
            if UIDevice.isDeviceTablet() {
                cell.isLandscape = false
                let screenHeight = self.view.frameHeight / 2 - 40
                let screenWidth = self.view.frameWidth
                var space = screenHeight - 120 //120 height of network info
                if IS_SHOW_ADVERTISING,
                    RMBTSettings.sharedSettings.isAdsRemoved == false,
                    RMBTClient.advertisingIsActive == true {
                    space -= 75 //75 height of advertising
                }
                cell.topConstraint.constant = space / 2
                
                var padding = screenWidth - 470
                if padding < 20 {
                    padding = 20
                }
                cell.rootView.superview?.constraint(with: "left")?.constant = padding / 2
                cell.rootView.superview?.constraint(with: "right")?.constant = padding / 2
            } else {
                cell.isLandscape = collectionView == self.secondCollectionView
            }
            
            cell.applyColorScheme()
            return cell
        case .bigAdvertising:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RMBTAdvertisingCollectionViewCell.ID, for: indexPath) as! RMBTAdvertisingCollectionViewCell
            let middle = (cell.frame.size.width - 300) / 2
            let rect = CGRect(middle, 25, 300, 250)
            RMBTAdvertisingManager.shared.showAdMobBigBanner(with: rect, in: cell)
            self.createTimer()
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var item: Item
        if collectionView == secondCollectionView {
            item = self.secondCellItems[indexPath.row]
        } else {
            item = self.cellItems[indexPath.row]
        }
        switch item.type {
        case .listResults:
            let screenHeight = self.view.frameHeight / 2
            return CGSize(width: collectionView.frameWidth, height: screenHeight)
        case .result:
            if self.items.count % 2 == 0 {
                return CGSize(width: collectionView.bounds.size.width / 2 - 2.5, height: 155)
            } else {
                if indexPath.row == self.items.count - 1 {
                    return CGSize(width: collectionView.bounds.size.width, height: 155)
                } else {
                    return CGSize(width: collectionView.bounds.size.width / 2 - 2.5, height: 155)
                }
            }
        case .smallAdvertising:
            return CGSize(width: collectionView.bounds.size.width, height: 75)
        case .networkInfo:
            if UIDevice.isDeviceTablet() {
                let screenHeight = self.view.frameHeight / 2 - 40
                var space = screenHeight - 120 //120 height of network info
                if IS_SHOW_ADVERTISING,
                    RMBTSettings.sharedSettings.isAdsRemoved == false,
                    RMBTClient.advertisingIsActive == true {
                    space -= 75 //50 height of advertising
                }
                return CGSize(width: collectionView.bounds.size.width, height: 120 + space)
            }
            
            return CGSize(width: collectionView.bounds.size.width, height: 165)
        case .bigAdvertising:
            return CGSize(width: collectionView.bounds.size.width, height: 275)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets()
    }
}

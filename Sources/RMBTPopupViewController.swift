//
//  RMBTPopupViewController.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 11/12/18.
//  Copyright © 2018 SPECURE GmbH. All rights reserved.
//

import UIKit

class RMBTPopupViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var rootView: UIView!
    @IBOutlet weak var dismissButton: UIButton!
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        let configuration = RMBTConfigFabric.config(with: RMBTConfigurationIdentifier)
        if configuration.RMBT_VERSION == 3 {
            return .all
        }
        return .portrait
    }
    
    override var shouldAutorotate: Bool {
        let configuration = RMBTConfigFabric.config(with: RMBTConfigurationIdentifier)
        if configuration.RMBT_VERSION == 3 {
            return true
        }
        if UIApplication.shared.statusBarOrientation != .portrait {
            return true
        }
        return false
    }
    
    override open var preferredStatusBarStyle: UIStatusBarStyle {
        return RMBTColorManager.statusBarStyle
    }
    
    var titleText: String? {
        didSet {
            if self.isViewLoaded {
                self.titleLabel.text = titleText
            }
        }
    }
    
    var itemsNames: [String] = [] {
        didSet {
            if self.isViewLoaded {
                self.tableView.reloadData()
            }
        }
    }
    var itemsValues: [String] = [] {
        didSet {
            if self.isViewLoaded {
                self.tableView.reloadData()
            }
        }
    }

    var selectedCell: IndexPath?

    weak var delegate: RMBTPopupContentViewDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.register(cell: RMBTPUTableViewCell.ID)
        self.titleLabel.text = self.titleText
        
        self.applyColorScheme()
        self.updateColorForNavigationBarAndTabBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateHeight()
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
        self.rootView.backgroundColor = RMBTColorManager.navigationBarBackground
        self.titleLabel.textColor = RMBTColorManager.navigationBarTitleColor
        self.tableView.backgroundColor = RMBTColorManager.background
    }
    
    func updateHeight() {
        let height = CGFloat(44 * self.itemsNames.count + 80)
        if height > self.view.boundsHeight - 120 {
            self.heightConstraint.constant = self.view.boundsHeight - 120
        } else {
            self.heightConstraint.constant = height
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.updateHeight()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.updateHeight()
    }
    
    @IBAction func dismissButtonClick(_ sender: UIView) {
        self.dismiss(animated: true, completion: nil)
    }

    class func present(in rootViewController: UIViewController) -> RMBTPopupViewController {
        let storyboard = UIStoryboard(name: "RMBTPopupViewController", bundle: nil)
        let navController = storyboard.instantiateInitialViewController() as! UINavigationController
        let vc = navController.topViewController as! RMBTPopupViewController
        
        rootViewController.present(navController, animated: true, completion: nil)
        
        return vc
    }
}

extension RMBTPopupViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemsNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: RMBTPUTableViewCell.ID, for: indexPath) as! RMBTPUTableViewCell
        
        let configuration = RMBTConfigFabric.config(with: RMBTConfigurationIdentifier)
        if configuration.RMBT_VERSION == 3 {
            cell.applyColorScheme()
        }
        cell.nameLabel.text = itemsNames[indexPath.row]
        cell.valueLabel?.text = itemsValues[indexPath.row]
        
        cell.valueLabel?.adjustsFontSizeToFitWidth = true
        cell.valueLabel?.minimumScaleFactor = 0.5
        
        cell.isCurrent = (selectedCell?.row == indexPath.row)
        cell.selectionStyle = .default
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.indexHasBeenPicked(indexPath)
    }
}

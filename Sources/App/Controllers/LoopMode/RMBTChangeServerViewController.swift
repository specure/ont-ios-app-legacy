//
//  RMBTChangeServerViewController.swift
//  RMBT_ONT
//
//  Created by Sergey Glushchenko on 7/22/18.
//  Copyright © 2018 SPECURE GmbH. All rights reserved.
//

import UIKit

class RMBTChangeServerViewController: TopLevelViewController {

    var servers: [MeasurementServerInfoResponse.Servers] = []
    
    var onServerSelected: (_ server: MeasurementServerInfoResponse.Servers?) -> Void = { _ in }
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var emptyLabel: UILabel!
    
    var currentServer: MeasurementServerInfoResponse.Servers? {
        didSet {
            self.onServerSelected(currentServer)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = L("loopmode.change_server.title")
        self.emptyLabel.text = L("history.error.server_not_available")
        self.emptyLabel.isHidden = (self.servers.count > 0)
        self.tableView.isHidden = (self.servers.count == 0)
        
        let cellNib = UINib(nibName: RMBTServerCell.ID, bundle: nil)
        self.tableView.register(cellNib, forCellReuseIdentifier: RMBTServerCell.ID)
        
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
        self.tableView.reloadData()
    }
    
    override func applyColorScheme() {
        self.view.backgroundColor = RMBTColorManager.background
        
        tableView.backgroundColor = RMBTColorManager.background
        tableView.separatorColor = RMBTColorManager.tableViewSeparator.withAlphaComponent(0.3)
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        self.emptyLabel.textColor = RMBTColorManager.tintColor
    }
    
    @IBAction func backButtonClick(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension RMBTChangeServerViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.servers.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let server = self.servers[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: RMBTServerCell.ID, for: indexPath) as! RMBTServerCell
        cell.applyColorScheme()
        cell.serverNameLabel.text = server.fullNameWithSponsor
        cell.distanceLabel.text = server.distance
        cell.isCurrent = (currentServer?.id == server.id)
        cell.accessoryType = currentServer?.id == server.id ? .checkmark : .none

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let server = self.servers[indexPath.row]
        currentServer = server
        self.tableView.reloadData()
    }
}

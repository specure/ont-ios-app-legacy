//
//  RMBTPUServersViews.swift
//  RMBT
//
//  Created by Tomas Baculák on 23/08/2017.
//  Copyright © 2017 SPECURE GmbH. All rights reserved.
//

import UIKit
import CoreLocation

//
class RMBTPUServersViews: RMBTPopupView, RMBTPopupViewProtocol, RMBTPopupContentViewDelegate {

    ///
    var items: [MeasurementServerInfoResponse.Servers]? {
        didSet {
            if let it = items?.count, it > 1 {
                //
                self.isUserInteractionEnabled = self.isShouldUserInterectionEnabled
                // default if no location
                if !RMBTLocationTracker.sharedTracker.startIfAuthorized() {
                    self.setDefaultServer()
                } else {
                    self.updateServer(with: RMBTLocationTracker.sharedTracker.location)
                }
            }
        }
    }
    
    ///
    @IBOutlet var titleLabel: UILabel?
    @IBOutlet var iconImageView: UIImageView?
    
    //
    @IBOutlet var measurementServerLabel: UILabel?

    ///
    override func awakeFromNib() {
        super.awakeFromNib()
        //
        self.isUserInteractionEnabled = false
        //
        titleLabel?.text = L("RBMT-BASE-TESTSERVER").uppercased()
        delegate = self
        // Register only for the first time for automatic server selection based on location
        if items == nil {
            // Register as observer for location tracker updates
            NotificationCenter.default.addObserver(self,
                selector: #selector(RMBTPUServersViews.locationsDidChange(_:)),
                name: NSNotification.Name(rawValue: "RMBTLocationTrackerNotification"),
                object: nil)
        }
    }
    
    deinit {
       NotificationCenter.default.removeObserver(self)
    }
    
    ///
    @objc private func locationsDidChange(_ notification: Notification) {
        var lastLocation: CLLocation?
        
        for l in notification.userInfo?["locations"] as! [CLLocation] { // !
            if CLLocationCoordinate2DIsValid(l.coordinate) {
                lastLocation = l
            }
        }
        
        self.updateServer(with: lastLocation)
    }
    
    func setDefaultServer() {
        let ms = self.items?.filter({ item in
            if let server = RMBTConfig.sharedInstance.measurementServer {
                return item.id?.intValue == server.id?.intValue
            } else if let serverId = RMBTApplicationController.measurementServerId {
                return item.id?.intValue == serverId
            } else {
                return false//item.id?.intValue == defaultMeasurementServerCode.rawValue
            }
        })
        
        if let ms = ms, ms.count > 0 {
            if let server = ms.first {
                self.assignNewServer(theServer: server)
            }
        } else {
            if let server = self.items?.first {
                self.assignNewServer(theServer: server)
            }
        }
    }
    
    func updateServer(with location: CLLocation?) {
        guard let location = location,
                let items = self.items,
                items.count > 0 else { return }
        
        location.fetchCountryAndCity(completion: ({ (_, _) in
            // Assign automatic location
            let servers = self.items?.filter({ result in
                if let server = RMBTConfig.sharedInstance.measurementServer {
                    return result.id?.intValue == server.id?.intValue
                } else if let serverId = RMBTApplicationController.measurementServerId {
                    return result.id?.intValue == serverId
                } else {
                    return false
                }
            })
            if let theServer = servers?.first {
                self.assignNewServer(theServer: theServer)
                // just once
                NotificationCenter.default.removeObserver(self)
            } else {
                self.setDefaultServer()
            }
        }))
    }
    
    // MARK: - RMBTPopupViewProtocol
    // TODO: Better to use UIPickerView most probably
    ///
    func viewWasTapped(_ superView: UIView!) {
        //
        if let items = self.items, items.count > 0 {
            var itemsValues: [String] = []
            var itemsNames: [String] = []
            
            for item in items {
                if RMBT_USE_OLD_SERVERS_RESPONSE {
                    if item.id != nil {
                        itemsValues.append(item.name ?? "")
                        itemsNames.append("")
                    }
                } else {
                    itemsValues.append("\(item.sponsor ?? ""), \(item.city ?? "") (\(item.distance ?? ""))")
                    itemsNames.append(item.country?.uppercased() ?? "")
                }
            }
            if let vc = UIApplication.shared.delegate?.window??.rootViewController {
                self.popupVC = RMBTPopupViewController.present(in: vc)
                self.popupVC?.titleText = L("RBMT-BASE-MEASUREMENTSERVERS")
                self.popupVC?.itemsNames = itemsNames
                self.popupVC?.itemsValues = itemsValues
                self.popupVC?.selectedCell = self.selectedIndexPath()
                self.popupVC?.delegate = self
            }
            updateView()
        }
        
    }

    // MARK: - RMBTPopupContentViewDelegate
    
    ///
    func indexHasBeenPicked(_ index: IndexPath) {
        if let theServer = items?[index.row] {
            RMBTApplicationController.measurementServerId = theServer.id?.intValue
            self.assignNewServer(theServer: theServer)
        }
        self.popupVC?.dismiss(animated: true, completion: nil)
    }
    
    func selectedIndexPath() -> IndexPath {
        let ms = self.items?.filter({ item in
            if let server = RMBTConfig.sharedInstance.measurementServer {
                return item.id?.intValue == server.id?.intValue
            } else {
                return false
            }
        })
        
        if let server = ms?.first,
            let index = self.items?.firstIndex(where: { (currentServer) -> Bool in
                return currentServer.id?.intValue == server.id?.intValue
            }) {
            return IndexPath(row: index, section: 0)
        } else {
            return IndexPath(row: 0, section: 0)
        }
        
    }
    // MARK: - Helpers
    //
    private func assignNewServer(theServer: MeasurementServerInfoResponse.Servers) {
        RMBTConfig.sharedInstance.measurementServer = theServer
        if RMBT_USE_OLD_SERVERS_RESPONSE {
            measurementServerLabel?.text = theServer.name
        } else {
            measurementServerLabel?.text = theServer.fullName
        }
    }
}

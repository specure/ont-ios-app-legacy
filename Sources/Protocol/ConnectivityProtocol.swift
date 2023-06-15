//
//  ManageConnectivityProtocol.swift
//  RMBT
//
//  Created by Tomas Baculák on 17/03/2017.
//  Copyright © 2017 SPECURE GmbH. All rights reserved.
//

import Foundation
import RMBTClient

@objc protocol ManageConnectivity: AnyObject, RMBTConnectivityTrackerDelegate, ConnectivityView {
    //
    var connectivityTracker: RMBTConnectivityTracker? { @objc(connectivityTracker)get @objc(setConnectivityTracker:)set }
    ///
    
    ///
//    func startConnectivityTracker()
    //
//    func stopConnectivityTracker()
    func connectivityTracker(_ tracker: RMBTConnectivityTracker, didDetectConnectivity connectivity: RMBTConnectivity)
}

extension ManageConnectivity {
    //
    func manageViewInactiveConnect() {
        logger.debug("connectivityTracker didDetectNoConnectivity")
        DispatchQueue.main.async {
            self.networkTypeImageView?.image = UIImage(named: "intro_none")
            self.startTestButton?.isEnabled = false
            self.manageLabelsInactiveConnect()
        }
    }

    //
    func manageViewAfterDidConnect(connectivity: RMBTConnectivity) {
        logger.debug("connectivityTracker didDetectConnectivity \(connectivity)")
        
        DispatchQueue.main.async {
            self.startTestButton?.isEnabled = true
            if connectivity.networkType == .wiFi {
                self.networkTypeImageView?.image = UIImage(named: "wifi")?.tintedImageUsingColor(tintColor: RMBT_TINT_COLOR)
            } else if connectivity.networkType == .cellular {
                self.networkTypeImageView?.image = UIImage(named: "mobil4")?.tintedImageUsingColor(tintColor: RMBT_TINT_COLOR)
            }
            self.manageLabelsDidConnect(connectivity: connectivity)
        }
    }
}

// Default implementation
extension ManageConnectivity {
    //
    func startConnectivityTracker() {
        if connectivityTracker == nil {
            connectivityTracker = RMBTConnectivityTracker(delegate: self, stopOnMixed: false)
            connectivityTracker?.start()
        } else {
            connectivityTracker?.forceUpdate()
        }
    }
    
    //
    func stopConnectivityTracker() {
        connectivityTracker?.stop() //
        connectivityTracker = nil
    }
}

//
// MARK: RMBTConnectivityTrackerDelegate
extension ManageConnectivity {
    //
//    func connectivityTrackerDidDetectNoConnectivity(_ tracker: RMBTConnectivityTracker) {
//        manageViewInactiveConnect()
//    }
    
    ///
//    func connectivityTracker(_ tracker: RMBTConnectivityTracker, didDetectConnectivity connectivity: RMBTConnectivity) {
//        manageViewAfterDidConnect(connectivity: connectivity)
//    }
    
    ///
//    func connectivityTracker(_ tracker: RMBTConnectivityTracker, didStopAndDetectIncompatibleConnectivity connectivity: RMBTConnectivity) {
//        // do nothing
//    }
}

// Not tested yet
protocol WallGarden: AnyObject, MeasurementStarter, MeasurementViewMapButton {

    var walledGardenImageView: UIImageView? { get set }
    
    func checkWalledGarden()
}

// Default implementation
extension WallGarden {
    //
    func checkWalledGarden() {
        DispatchQueue.global(qos: .userInitiated).async {
            WalledGardenTest.isWalledGardenConnection { isWalledGarden in
                logger.debug("!?!?!?! is walled garden: \(isWalledGarden)")
                self.makeObjectsActive(isWalledGarden)
            }
        }
    }
    ///
    //
    private func makeObjectsActive(_ active: Bool) {
    
        DispatchQueue.main.async {
            self.walledGardenImageView?.isHidden = active
            self.startTestButton?.isEnabled = active
            self.mapButton?.isEnabled = active
        }
    }
}

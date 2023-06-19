//
//  RMBTConnectivityHAndleView.swift
//  RMBT
//
//  Created by Tomas Baculák on 17/03/2017.
//  Copyright © 2017 SPECURE GmbH. All rights reserved.
//

import Foundation
import RMBTClient

extension RMBTManageMainView where Self: RMBTInitialViewController {
    
    ///
    func connectivityTrackerDidDetectNoConnectivity(_ tracker: RMBTConnectivityTracker) {

        manageViewInactiveConnect()
        resetAddressStatistics()
        //
        DispatchQueue.main.async {
            self.networkTypeImageView?.image = UIImage(named: "intro_none")
        }
        
        self.protocolView?.connectivityDidChange()
    }
    
    ///
    func connectivityTracker(_ tracker: RMBTConnectivityTracker, didDetectConnectivity connectivity: RMBTConnectivity) {
        
        manageViewAfterDidConnect(connectivity: connectivity)
        resetAddressStatistics()
        
        //
        self.currentConnectivityNetworkType = connectivity.networkType
        
        DispatchQueue.main.async {
        
            if connectivity.networkType == .wiFi {
                self.networkTypeImageView?.image = UIImage(named: "wifi")?.tintedImageUsingColor(tintColor: RMBT_TINT_COLOR)
            } else if connectivity.networkType == .cellular {
                self.networkTypeImageView?.image = UIImage(named: "mobil4")?.tintedImageUsingColor(tintColor: RMBT_TINT_COLOR)
            }
            
            self.protocolView?.connectivityDidChange()
        }
        
        // check walled garden !!!!
        self.checkWalledGarden()
    }
}

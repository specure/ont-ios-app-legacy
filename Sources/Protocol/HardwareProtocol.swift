//
//  HardwareProtocol.swift
//  Pentameter
//
//  Created by Tomas Baculák on 21/04/2017.
//  Copyright © 2017 Specure GmbH. All rights reserved.
//

import Foundation

protocol IPaddressStatistics: AnyObject {
    ///
    var ipAddressUpdateCount: Int { get set }
    ///
    var ipAddressLastUpdated: UInt64 { get set }
}

extension IPaddressStatistics {

    func resetAddressStatistics() {
    
        // reset timer values
        self.ipAddressUpdateCount = 0
        self.ipAddressLastUpdated = 0
    }
}

//
protocol ManageHardware: SimpleTimer, IPaddressStatistics {
    
    ///
    var hardwareView: RMBTPUHardwareView? { get }
    ///
    var protocolView: RMBTPUProtocolView? { get }
    ///
    var locationView: RMBTPULocationView? { get }
    ///
    var trafficView: RMBTPUTrafficView? { get }
    
    //
    func updateSubviews()
}

//
@objc protocol SimpleTimer {

    ///
    var simpleTimer: Timer? { get set }
    
    ///
    var simpleTimerFireInterval: TimeInterval { get }
    
    //
//    func initUpdateTimer()
//    func discartUpdateTimer()
    //
    func updateTimerFired()
}

// Default implementation for UIViewController
extension SimpleTimer {
    ///
    //
    func initUpdateTimer() {
        
        simpleTimer = Timer.scheduledTimer(timeInterval: simpleTimerFireInterval,
                                     target: self,
                                     selector: #selector(Self.updateTimerFired), // Selector("updateTimerFired"),//
                                     userInfo: nil,
                                     repeats: true)
    }
    
    //
    func discartUpdateTimer() {
        simpleTimer?.invalidate()
        simpleTimer = nil
    }
}

// Default implementation
extension ManageHardware {
    //
    func enableHardwareView(_ enable: Bool) {
        hardwareView?.isUserInteractionEnabled = enable
        protocolView?.isUserInteractionEnabled = enable
        locationView?.isUserInteractionEnabled = enable
        trafficView?.isUserInteractionEnabled = enable
    }
    
    //
    func initInteractiveSubviews() {
        hardwareView?.backgroundColor = INITIAL_VIEW_FEATURE_VIEWS_BACKGROUND_COLOR
        protocolView?.backgroundColor = INITIAL_VIEW_FEATURE_VIEWS_BACKGROUND_COLOR
        locationView?.backgroundColor = INITIAL_VIEW_FEATURE_VIEWS_BACKGROUND_COLOR
        trafficView?.backgroundColor = INITIAL_VIEW_FEATURE_VIEWS_BACKGROUND_COLOR
        
        hardwareView?.colorSubLabels(INITIAL_SCREEN_TEXT_COLOR)
        protocolView?.colorSubLabels( INITIAL_SCREEN_TEXT_COLOR)
        locationView?.colorSubLabels( INITIAL_SCREEN_TEXT_COLOR)
        trafficView?.colorSubLabels( INITIAL_SCREEN_TEXT_COLOR)
        
        //
        trafficView?.downloadView.viewOrientation = true
        //
        protocolView?.initUIItems()
        
        //
        protocolView?.setColorForStatusView(color: PROGRESS_INDICATOR_FILL_COLOR)
        
        trafficView?.downloadView.itemCount = 2
        trafficView?.uploadView.itemCount = 2
    }
    //
    func updateSubviews() {
        
        //logger.debug("updateTimerFired")
        
        // update hardware, traffic and location view every second
        hardwareView?.updateView()
        trafficView?.updateView()
        locationView?.updateView()
        
        // update ip addresses and walled garden every now, 2x every 5 sec, then every time after 30
        let curTimeMS = UInt64.currentTimeMillis()
        let durationTime = Int64(curTimeMS) - Int64(ipAddressLastUpdated)
        
        if ipAddressUpdateCount == 0 ||
            (ipAddressUpdateCount > 0 && ipAddressUpdateCount < 3) &&
            durationTime >= 5_000 || // every 5 sec
            ipAddressUpdateCount >= 3 && durationTime >= 30_000 {   // every 30 sec
            logger.debug("updating ip address after \(durationTime) ms")
            
            protocolView?.updateView()
            // tu
            self.ipAddressUpdateCount += 1
            self.ipAddressLastUpdated = curTimeMS
        }
    }
}

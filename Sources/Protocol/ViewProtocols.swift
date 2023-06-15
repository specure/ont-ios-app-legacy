//
//  ViewProtocols.swift
//  RMBT
//
//  Created by Tomas Baculák on 25/04/2017.
//  Copyright © 2017 SPECURE GmbH. All rights reserved.
//

import Foundation
import RMBTClient
import SystemConfiguration.CaptiveNetwork

//
@objc protocol MeasurementStarter {
    ///
    var startTestButton: UIButton? { @objc(startTestButton)get }
}

//
protocol MeasurementViewMapButton {
    ///
    var mapButton: UIButton? { get }
}

//
@objc protocol ConnectivityLabels {
    ///
    var networkTypeLabel: UILabel? { @objc(networkTypeLabel)get }
    ///
    var networkNameLabel: UILabel? { @objc(networkNameLabel)get }
}

// Default implementation
extension ConnectivityLabels {
    
    func cleanConnectivityLabels() {
        networkTypeLabel?.text = ""
        networkNameLabel?.text = ""
    }
    
    func formatConnectivityLabels() {
        networkTypeLabel?.textColor = INITIAL_SCREEN_TEXT_COLOR
        //networkNameLabel?.textColor = INITIAL_SCREEN_TEXT_COLOR
    }

    //
    func manageLabelsDidConnect(connectivity: RMBTConnectivity) {
        self.networkNameLabel?.text = connectivity.networkName ?? L("intro.network.connection.name-unknown")
        
        //
        if let cd = connectivity.telephonyNetworkSimOperator {
            self.networkTypeLabel?.text = "\(connectivity.networkTypeDescription), \(cd)"
        } else {
            self.networkTypeLabel?.text = connectivity.networkTypeDescription
        }
    }
    //
    func manageLabelsInactiveConnect() {
        self.networkNameLabel?.text = ""
        self.networkTypeLabel?.text = L("intro.network.connection.unavailable")
    }
}

//
@objc protocol ConnectivityView: ConnectivityLabels, MeasurementStarter {
    //
    var networkTypeImageView: UIImageView? { @objc(networkTypeImageView)get }
}

// default
extension ConnectivityView {
    func cleanNetworkImageView() {
        networkTypeImageView?.image = nil // Clear placeholder image
    }
}

// View actions to be implement
protocol ManageMeasurementView {
    //
    func manageViewControllerAbort()
    func manageViewsAbort()
    // correct view after start
    func manageViewNewStart()
    // Realtime values
    func manageViewProgress(phase: SpeedMeasurementPhase, title: String , value: Double)
    // Start phase
    func manageViewProcess(_ phase: SpeedMeasurementPhase)
    // Finish phase with results
    func manageViewFinishPhase(_ phase: SpeedMeasurementPhase, withResult result: Double)
    // Dead
    func manageViewFinishMeasurement(uuid: String)
    // QoS
    func manageViewAfterQosStart()
    func manageViewAfterQosUpdated(value: Int)
    func manageViewAfterQosGetList(list: [QosMeasurementType])
    func manageViewAfterQosFinishedTest(type: QosMeasurementType)
}

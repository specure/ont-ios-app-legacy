//
//  RMBTPUTrafficView.swift
//  RMBT
//
//  Created by Tomáš Baculák on 21/01/15.
//  Copyright © 2015 SPECURE GmbH. All rights reserved.
//

import UIKit

///
class RMBTPUTrafficView: RMBTPopupView, RMBTPopupViewProtocol {

    ///
    @IBOutlet var uploadView: RMBTUITrafficView!

    ///
    @IBOutlet var downloadView: RMBTUITrafficView!
    
    ///
    @IBOutlet var titleLabel: UILabel?

    //

    ///
    let itemNames = [
        L("intro.popup.traffic.upload"),
        L("intro.popup.traffic.download")
    ]

    ///
    let SPEED_FORMAT_M = "Mbps"

    ///
    let SPEED_FORMAT_K = "kbps"

    ///
    var netStats = RMBTTrafficCounter()

    ///
    var lastDict = [String: Int]()
    
    ///
    var numberOfItems = 3

    //

    ///
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    ///
    override init (frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    ///
    private func commonInit() {
        lastDict = netStats.getTrafficCount() as! [String: Int]
        
        delegate = self
    }
    
    ///
    override func awakeFromNib() {
        super.awakeFromNib()
        //
        titleLabel?.text = LC("RBMT-BASE-TRAFFIC")
    }

// MARK: - RMBTPopupViewProtocol
    ///
    func viewWasTapped(_ superView: UIView!) {
        if let vc = UIApplication.shared.delegate?.window??.rootViewController {
            self.popupVC = RMBTPopupViewController.present(in: vc)
            self.popupVC?.titleText = L("intro.popup.traffic.background")
        }
        updateView()
    }

    ///
    override func updateView() {
        if let newDict = netStats.getTrafficCount() as? [String: Int],
            let newWiFiSent = newDict["wifi_sent"],
            let lastWiFiSent = lastDict["wifi_sent"],
            let newWiFiReceived = newDict["wifi_received"],
            let lastWiFiReceived = lastDict["wifi_received"],
            let newWWANSent = newDict["wwan_sent"],
            let lastWWANSent = lastDict["wwan_sent"],
            let newWWANReceived = newDict["wwan_received"],
            let lastWWANReceived = lastDict["wwan_received"] {
        
            // calc difference
            let wifi_sent_difference: Int = newWiFiSent - lastWiFiSent
            let wifi_received_difference: Int = newWiFiReceived - lastWiFiReceived
            
            let wwan_sent_difference: Int = newWWANSent - lastWWANSent
            let wwan_received_difference: Int = newWWANReceived - lastWWANReceived
            
            let sent_difference = wifi_sent_difference + wwan_sent_difference
            let received_difference = wifi_received_difference + wwan_received_difference
            
            let sent_classification = TrafficClassification.classifyBytesPerSecond(Int64(sent_difference))
            let received_classification = TrafficClassification.classifyBytesPerSecond(Int64(received_difference))
            
            uploadView.signalStrength = sent_classification
            downloadView.signalStrength = received_classification
            
            let size: Float = 1024 * 1024
            let receivedTraffic = Float(received_difference * 8) / size
            let sentTraffic = Float(sent_difference * 8) / size
            let downtraffic = String(format: "%f %@", receivedTraffic, SPEED_FORMAT_M)
            let uptraffic = String(format: "%f %@", sentTraffic, SPEED_FORMAT_M)
            
            lastDict = newDict
            
            itemValues = [downtraffic, uptraffic]
            
            self.popupVC?.itemsValues = itemValues
            self.popupVC?.itemsNames = itemNames
        }
    }
}

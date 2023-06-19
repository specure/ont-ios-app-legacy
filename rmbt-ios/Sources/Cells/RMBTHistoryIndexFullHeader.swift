//
//  RMBTHistoryIndexFullHeader.swift
//
//  Created by Sergey Glushchenko on 9/30/17.
//  Copyright © 2017 SPECURE GmbH. All rights reserved.
//

import UIKit

class RMBTHistoryIndexFullHeader: UIView {

    @IBOutlet weak var qosResultsLabel: UILabel!
    @IBOutlet weak var uploadLabel: UILabel!
    @IBOutlet weak var downloadLabel: UILabel!
    @IBOutlet weak var pingLabel: UILabel!
    @IBOutlet weak var testLabel: UILabel!
    @IBOutlet weak var packetLossLabel: UILabel!
    @IBOutlet weak var jitterLabel: UILabel!
    
    class func view() -> RMBTHistoryIndexFullHeader {
        let nib = UINib(nibName: "RMBTHistoryIndexFullHeader", bundle: nil)
        return nib.instantiate(withOwner: self, options: nil).first as! RMBTHistoryIndexFullHeader
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

        qosResultsLabel.text = L("history.header.qos")
        uploadLabel.text = L("history.header.upload").uppercased()
        downloadLabel.text = L("history.header.download").uppercased()
        pingLabel.text = L("history.header.ping")
        testLabel.text = L("history.header.test")
        packetLossLabel.text = L("history.header.packet-loss")
        jitterLabel.text = L("history.header.jitter")
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        guard UIApplication.shared.applicationState == .inactive else {
            return
        }
        
        self.applyColorScheme()
    }
    
    func applyColorScheme() {
        backgroundColor = RMBTColorManager.historyHeaderColor
        qosResultsLabel.textColor = RMBTColorManager.tableViewHeaderColor
        uploadLabel.textColor = RMBTColorManager.tableViewHeaderColor
        downloadLabel.textColor = RMBTColorManager.tableViewHeaderColor
        pingLabel.textColor = RMBTColorManager.tableViewHeaderColor
        testLabel.textColor = RMBTColorManager.tableViewHeaderColor
        packetLossLabel.textColor = RMBTColorManager.tableViewHeaderColor
        jitterLabel.textColor = RMBTColorManager.tableViewHeaderColor
    }
}

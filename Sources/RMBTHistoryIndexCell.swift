//
//  RMBTHistoryIndexCell.swift
//  RMBT
//
//  Created by Benjamin Pucher on 24.09.14.
//  Copyright © 2014 SPECURE GmbH. All rights reserved.
//

import Foundation

///
class RMBTHistoryIndexCell: UITableViewCell {

    @IBOutlet weak var jitterBackgroundView: UIView?
    @IBOutlet weak var packetLossBackgroundView: UIView?
    @IBOutlet weak var uploadBackgroundView: UIView!
    @IBOutlet weak var downloadBackgroundView: UIView!
    @IBOutlet weak var pingBackgroundView: UIView!
    @IBOutlet weak var dateBackgroundView: UIView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var qosBackgroundView: UIView!
    ///
    @IBOutlet var networkNameLabel: UILabel?
    
    ///
    @IBOutlet var typeImageView: UIImageView!

    @IBOutlet weak var qosPercentLabel: UILabel!
    @IBOutlet weak var qosResultsLabel: UILabel!
    ///
    @IBOutlet var networkTypeLabel: UILabel?

    ///
    @IBOutlet var dateLabel: UILabel!
    
    ///
    @IBOutlet var timeLabel: UILabel!

    ///
    @IBOutlet var deviceModelLabel: UILabel!
    
    @IBOutlet var testTypeLabel: UILabel?
    @IBOutlet weak var carrierDeviceSeparatorView: UIView!
    @IBOutlet weak var headerSeparatorView: UIView?
    ///
    @IBOutlet var downloadSpeedLabel: UILabel!
    @IBOutlet weak var downloadMbpsLabel: UILabel!
    
    ///
    @IBOutlet var uploadSpeedLabel: UILabel!
    @IBOutlet weak var uploadMbpsLabel: UILabel!
    
    ///
    @IBOutlet var pingLabel: UILabel!
    @IBOutlet weak var pingMsLabel: UILabel!
    
    ///
    @IBOutlet var jitterLabel: UILabel?
    @IBOutlet weak var jitterMsLabel: UILabel!
    
    ///
    @IBOutlet var packetLossLabel: UILabel?
    @IBOutlet weak var packetLossPercentLabel: UILabel!
    
    ///
    @IBOutlet var jitterNameLabel: UILabel?
    
    ///
    @IBOutlet var packetLossNameLabel: UILabel?

    var isLoopTest: Bool = false {
        didSet {
            self.applyColorScheme()
        }
    }
    //

    ///
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    
    }

    ///
    func commonInit() {
        jitterNameLabel?.text = L("RBMT-BASE-JITTER")
        packetLossNameLabel?.text = L("RBMT-BASE-PACKETLOSS")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.setHighlighted(selected, animated: animated)
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        let duration = highlighted ? 0.0 : 0.3
        UIView.animate(withDuration: duration) {
            self.applyColorScheme()
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        guard UIApplication.shared.applicationState == .inactive else {
            return
        }
        
        self.applyColorScheme()
    }
    
    func applyColorScheme() {
        headerSeparatorView?.backgroundColor = RMBTColorManager.historyBorderColor
        headerView?.backgroundColor = self.isHighlighted ? RMBTColorManager.highlightHistoryCellColor : RMBTColorManager.cellBackground
        dateBackgroundView?.backgroundColor = self.isHighlighted ? RMBTColorManager.highlightHistoryCellColor : RMBTColorManager.normalHistoryCellColor
        
        typeImageView?.tintColor = self.isHighlighted ? RMBTColorManager.historyTextColor : RMBTColorManager.historyNetworkTitleColor
        
        qosBackgroundView?.backgroundColor = self.isHighlighted ? RMBTColorManager.highlightHistoryCellColor : RMBTColorManager.historyValueBackgroundColor
        pingBackgroundView?.backgroundColor = self.isHighlighted ? RMBTColorManager.highlightHistoryCellColor : RMBTColorManager.historyValueBackgroundColor
        downloadBackgroundView?.backgroundColor = self.isHighlighted ? RMBTColorManager.highlightHistoryCellColor : RMBTColorManager.historyValueBackgroundColor
        uploadBackgroundView?.backgroundColor = self.isHighlighted ? RMBTColorManager.highlightHistoryCellColor : RMBTColorManager.historyValueBackgroundColor
        jitterBackgroundView?.backgroundColor = self.isHighlighted ? RMBTColorManager.highlightHistoryCellColor : RMBTColorManager.historyValueBackgroundColor
        packetLossBackgroundView?.backgroundColor = self.isHighlighted ? RMBTColorManager.highlightHistoryCellColor : RMBTColorManager.historyValueBackgroundColor
        
        contentView.backgroundColor = self.isHighlighted ? UIColor.clear : RMBTColorManager.historyBorderColor
        
        carrierDeviceSeparatorView?.backgroundColor = self.isHighlighted ? RMBTColorManager.historyTextColor : RMBTColorManager.tintColor
        networkNameLabel?.textColor = self.isHighlighted ? RMBTColorManager.historyTextColor : RMBTColorManager.historyNetworkTitleColor
        networkTypeLabel?.textColor = self.isHighlighted ? RMBTColorManager.historyTextColor : RMBTColorManager.historyNetworkTitleColor
        deviceModelLabel?.textColor = self.isHighlighted ? RMBTColorManager.historyTextColor : RMBTColorManager.historyNetworkTitleColor
        
        qosResultsLabel?.textColor = RMBTColorManager.historyTextColor
        dateLabel?.textColor = RMBTColorManager.historyDateColor
        timeLabel?.textColor = RMBTColorManager.historyDateColor
        testTypeLabel?.textColor = RMBTColorManager.historyTextColor
        downloadSpeedLabel?.textColor = RMBTColorManager.historyTextColor
        uploadSpeedLabel?.textColor = RMBTColorManager.historyTextColor
        pingLabel?.textColor = RMBTColorManager.historyTextColor
        jitterLabel?.textColor = RMBTColorManager.historyTextColor
        packetLossLabel?.textColor = RMBTColorManager.historyTextColor
        jitterNameLabel?.textColor = RMBTColorManager.historyTextColor
        packetLossNameLabel?.textColor = RMBTColorManager.historyTextColor
                
        uploadMbpsLabel?.textColor = RMBTColorManager.historyTextColor
        downloadMbpsLabel?.textColor = RMBTColorManager.historyTextColor
        jitterMsLabel?.textColor = RMBTColorManager.historyTextColor
        packetLossPercentLabel?.textColor = RMBTColorManager.historyTextColor
        pingMsLabel?.textColor = RMBTColorManager.historyTextColor
        qosPercentLabel?.textColor = RMBTColorManager.historyTextColor
    }

}

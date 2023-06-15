//
//  RMBTPUHardwareView.swift
//  RMBT
//
//  Created by Tomáš Baculák on 20/01/15.
//  Copyright © 2015 SPECURE GmbH. All rights reserved.
//

import UIKit

///
class RMBTPUHardwareView: RMBTPopupView, RMBTPopupViewProtocol {

    ///
    @IBOutlet var cpuValueLabel: UILabel!

    ///
    @IBOutlet var ramValueLabel: UILabel!
    
    ///
    @IBOutlet var cpuTitleLabel: UILabel?
    
    ///
    @IBOutlet var ramTitleLabel: UILabel?

    //

    ///
    let cpuMonitor = RMBTCPUMonitor()

    ///
    let ramMonitor = RMBTRAMMonitor()

    ///
    let itemNames = [
        L("intro.popup.hardware.cpu"),
        L("intro.popup.hardware.system-ram"),
        L("intro.popup.hardware.app-ram")
    ]

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
        // Load xib file
        delegate = self
    }

// MARK: - RMBTPopupViewProtocol
    ///
    func viewWasTapped(_ superView: UIView!) {
        if let vc = UIApplication.shared.delegate?.window??.rootViewController {
            self.popupVC = RMBTPopupViewController.present(in: vc)
            self.popupVC?.titleText = L("intro.popup.hardware.usage")
        }
        updateView()
    }

    ///
    override func updateView() {
        var cpuUsage: Float = 0

        if let array = cpuMonitor.getCPUUsage() as? [NSNumber] {
            cpuUsage = array[0].floatValue
        }

        let cpuUsageString = String(format: "%0.1f%%", cpuUsage)
        
        let physicalMemory = NSNumber(value: ProcessInfo.processInfo.physicalMemory)
        let physicalMemoryMB = b2mb(bytes: physicalMemory.floatValue)

        let memArray = ramMonitor.getRAMUsage() as! [NSNumber] // Int64?
        let memPercentUsedF = getMemoryUsePercent(used: memArray[0], memArray[1], /*memArray[2]*/physicalMemory)

        let memPercentUsed = String(format: "%.1f%%", memPercentUsedF)
        let memPercentUsedPerApp = String(format: "%.1f%%", getMemoryUsePercent(used: memArray[3], memArray[1], /*memArray[2]*/physicalMemory))

        cpuValueLabel.textColor = colorForPercentUsage(cpuUsage)
        ramValueLabel.textColor = colorForPercentUsage(memPercentUsedF)

        cpuValueLabel.text = cpuUsageString
        ramValueLabel.text = memPercentUsed
        
        self.popupVC?.itemsNames = itemNames
        self.popupVC?.itemsValues = [
            cpuUsageString,
            "\(memPercentUsed) (\(b2mb(bytes: memArray[0].floatValue))/\(physicalMemoryMB) MB)",
            "\(memPercentUsedPerApp) (\(b2mb(bytes: memArray[3].floatValue))/\(physicalMemoryMB) MB)"
        ]
        
    }

    ///
    private func getMemoryUsePercent(used: NSNumber, _ free: NSNumber, _ total: NSNumber) -> Float {
        return (used.floatValue / total.floatValue) * 100.0 // TODO: is calculation correct? maybe use total physical ram?
    }

    ///
    private func b2mb(bytes: Float) -> Int {
        return Int(bytes / 1024 / 1024)
    }

    ///
    private func colorForPercentUsage(_ percentUsage: Float) -> UIColor {
        if percentUsage <= 50 {
            return RMBT_RESULT_TEXT_COLOR
        } else if percentUsage > 90 {
            return RMBT_CHECK_INCORRECT_COLOR
        }

        return RMBT_CHECK_MEDIOCRE_COLOR
    }
}

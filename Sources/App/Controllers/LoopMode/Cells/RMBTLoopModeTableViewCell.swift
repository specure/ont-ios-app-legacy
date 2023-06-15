//
//  RMBTLoopModeTableViewCell.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 6/29/18.
//  Copyright © 2018 SPECURE GmbH. All rights reserved.
//

import UIKit
import QuartzCore

class RMBTLoopModeTableViewCell: UITableViewCell {

    struct RMBTLoopModeModelView {
        let item: RMBTLoopModeViewController.RMBTLoopModeState
        
        var value: String? {
            if item.identifier == "qos",
                item.progress > 0 {
                return String(format: "%0.0f%%", item.progress * 100)
            }
            if let currentValue = item.currentValue,
                currentValue != "-" {
                if item.identifier == "ping" {
                    return RMBTMillisecondsString(UInt64((currentValue as NSString).longLongValue))
                } else if item.identifier == "jitter" {
                        return RMBTMillisecondsString(UInt64((currentValue as NSString).longLongValue))
                } else if item.identifier == "download" || item.identifier == "upload" {
                    return RMBTSpeedMbpsString(Double(currentValue) ?? 0.0, withMbps: false)
                } else if item.identifier == "packet_lose" {
                    return currentValue
                } else if item.identifier == "jitter" {
                    return currentValue
                }
                
            }
            return item.currentValue ?? "-"
        }
        
        var median: String? {
            if let medianValue = item.medianValue,
                medianValue != "-" {
                if item.identifier == "ping" {
                    return RMBTMillisecondsString(UInt64((medianValue as NSString).longLongValue))
                } else if item.identifier == "jitter" {
                    return RMBTMillisecondsString(UInt64((medianValue as NSString).longLongValue))
                } else if item.identifier == "download" || item.identifier == "upload" {
                    return RMBTSpeedMbpsString(Double(medianValue) ?? 0.0, withMbps: false)
                } else if item.identifier == "packet_lose" {
                    return medianValue
                } else if item.identifier == "jitter" {
                    return medianValue
                }
            }
            return item.medianValue ?? "-"
        }
        
        var title: String? {
            return item.title
        }
        
        var isLoading: Bool { return item.progress > 0.0 && item.progress < 1.0}
        
        init(item: RMBTLoopModeViewController.RMBTLoopModeState) {
            self.item = item
        }
    }
    
    static let ID = "RMBTLoopModeTableViewCell"
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var medianLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIView?
    @IBOutlet weak var checkMarkImageview: UIView?
    
    private var selectedColor: UIColor = UIColor(red: 0.12, green: 0.22, blue: 0.55, alpha: 1)
    private var normalColor: UIColor = UIColor.lightGray
    
    var loopModeModelView: RMBTLoopModeModelView? {
        didSet {
            self.titleLabel.text = loopModeModelView?.title
            self.valueLabel.text = loopModeModelView?.value
            self.medianLabel.text = loopModeModelView?.median
            
            self.titleLabel.textColor = loopModeModelView?.isLoading == false ? normalColor : selectedColor
            self.valueLabel.textColor = loopModeModelView?.isLoading == false ? normalColor : selectedColor
            self.medianLabel.textColor = loopModeModelView?.isLoading == false ? normalColor : selectedColor

            self.activityIndicator?.isHidden = loopModeModelView?.isLoading == false
            self.checkMarkImageview?.isHidden = loopModeModelView?.isLoading == true
        }
    }
    
    deinit {
        if let activityIndicator = self.activityIndicator as? RMBTActivityIndicator {
            activityIndicator.stopAnimation()
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        guard UIApplication.shared.applicationState == .inactive else {
            return
        }
        
        self.applyColorScheme()
    }
    
    func applyColorScheme() {
        self.selectedColor = RMBTColorManager.highlightCellColor
        self.normalColor = RMBTColorManager.testValuesTitleColor
    }
    
}

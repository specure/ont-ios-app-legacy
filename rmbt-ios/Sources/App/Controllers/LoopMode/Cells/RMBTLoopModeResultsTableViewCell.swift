//
//  RMBTLoopModeResultsTableViewCell.swift
//  RMBT_ONT
//
//  Created by Sergey Glushchenko on 8/19/18.
//  Copyright © 2018 SPECURE GmbH. All rights reserved.
//

import UIKit

class RMBTLoopModeResultsTableViewCell: UITableViewCell {
    
    class RMBTLoopModeResultsModelView {
        let item: RMBTLoopModeViewController.RMBTLoopModeState
        let results: [RMBTLoopModeResult]
        
        var title: String? {
            if let identifier = item.identifier,
                let state = RMBTLoopModeViewController.State(rawValue: identifier) {
                return state.shortTitle
            }
            
            return nil
        }
        
        var valueSubtitle: String? {
            if let identifier = item.identifier,
                let state = RMBTLoopModeViewController.State(rawValue: identifier) {
                return state.subtitle
            }
            
            return nil
        }
        
        var currentValue: String? {
            if let identifier = item.identifier,
                let state = RMBTLoopModeViewController.State(rawValue: identifier),
                let currentValue = item.currentValue {
                switch state {
                case .download, .upload:
                    if let value = Double(currentValue) {
                        return RMBTSpeedMbpsString(value, withMbps: false)
                    }
                case .ping:
                    if let value = Double(currentValue) {
                        return RMBTMillisecondsString(UInt64(value))
                    }
                case .jitter:
                    if let value = Double(currentValue) {
                        return RMBTMillisecondsString(UInt64(value))
                    }
                default:
                    break
                }
                
            }
            
            return item.currentValue ?? "-"
        }
        
        var medianValue: String? {
            if let identifier = item.identifier,
                let state = RMBTLoopModeViewController.State(rawValue: identifier),
                let currentValue = item.medianValue {
                switch state {
                case .download, .upload:
                    if let value = Double(currentValue) {
                        return RMBTSpeedMbpsString(value, withMbps: false)
                    }
                case .ping:
                    if let value = Double(currentValue) {
                        return RMBTMillisecondsString(UInt64(value))
                    }
                case .jitter:
                    if let value = Double(currentValue) {
                        return RMBTMillisecondsString(UInt64(value))
                    }
                default:
                    break
                }
                
            }
            
            return item.medianValue ?? "-"
        }
        
        init(item: RMBTLoopModeViewController.RMBTLoopModeState, results: [RMBTLoopModeResult]) {
            self.item = item
            self.results = results
        }
    }
    
    static let ID = "RMBTLoopModeResultsTableViewCell"

    @IBOutlet weak var medianResultView: RMBTLoopModeResultView!
    @IBOutlet weak var currentResultView: RMBTLoopModeResultView!
    
    var modelView: RMBTLoopModeResultsModelView? {
        didSet {
            self.currentResultView.titleLabel?.text = self.modelView?.title
            self.currentResultView.subtitleLabel?.text = self.modelView?.valueSubtitle
            self.medianResultView.subtitleLabel?.text = self.modelView?.valueSubtitle
            self.currentResultView.valueLabel?.text = self.modelView?.currentValue
            self.medianResultView.valueLabel?.text = self.modelView?.medianValue
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
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
        currentResultView.emptyBackgroundColor = RMBTColorManager.background
        currentResultView.notEmptyBackgroundColor = RMBTColorManager.tintColor
        currentResultView.emptyTextColor = RMBTColorManager.tintColor
        currentResultView.notEmptyTextColor = RMBTColorManager.currentValueTitleColor
        currentResultView.isEmpty = false
        
        medianResultView.backgroundColor = RMBTColorManager.medianBackgroundColor
        medianResultView.titleLabel?.textColor = RMBTColorManager.medianTextColor
        medianResultView.valueLabel?.textColor = RMBTColorManager.medianTextColor
        medianResultView.subtitleLabel?.textColor = RMBTColorManager.medianTextColor
    }
}

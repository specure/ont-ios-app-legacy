//
//  RMBTTestResultsCollectionViewCell.swift
//  RMBT_ONT
//
//  Created by Sergey Glushchenko on 9/9/18.
//  Copyright © 2018 SPECURE GmbH. All rights reserved.
//

import UIKit

class RMBTTestResultsCollectionViewCell: UICollectionViewCell {

    class RMBTTestResultsModelView {
        let item: RMBTTestViewController.RMBTTestState
        let testResult: RMBTLoopModeResult
        
        let align: NSTextAlignment
        
        var title: String? {
            if let identifier = item.identifier,
                let state = RMBTTestViewController.State(rawValue: identifier) {
                return state.shortTitle
            }
            
            return nil
        }
        
        var valueSubtitle: String? {
            if let identifier = item.identifier,
                let state = RMBTTestViewController.State(rawValue: identifier) {
                return state.subtitle
            }
            
            return nil
        }
        
        var currentValue: String? {
            if let identifier = item.identifier,
                let state = RMBTTestViewController.State(rawValue: identifier),
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
                case .qos:
                    if let qosPerformed = self.testResult.qosPerformed,
                        let qosPassed = self.testResult.qosPassed {
                        return String(format: "%d/%d", qosPassed, qosPerformed)
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
        
        init(item: RMBTTestViewController.RMBTTestState, testResult: RMBTLoopModeResult, align: NSTextAlignment) {
            self.item = item
            self.testResult = testResult
            self.align = align
        }
    }
    
    static let ID = "RMBTTestResultsCollectionViewCell"
    
    @IBOutlet weak var centerConstraint: NSLayoutConstraint!
    @IBOutlet weak var currentResultView: RMBTLoopModeResultView!
    
    var modelView: RMBTTestResultsModelView? {
        didSet {
            self.currentResultView.titleLabel?.text = self.modelView?.title
            self.currentResultView.subtitleLabel?.text = self.modelView?.valueSubtitle
            self.currentResultView.valueLabel?.text = self.modelView?.currentValue
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if self.modelView?.align == .left {
            self.centerConstraint.constant = -((self.frame.size.width - 155) / 2)
        } else if self.modelView?.align == .justified {
            self.centerConstraint.constant = 0//-(155 / 2 + 2.5)
        } else {
            self.centerConstraint.constant = (self.frame.size.width - 155) / 2
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
        currentResultView.backgroundColor = RMBTColorManager.tintColor
        currentResultView.titleLabel?.textColor = RMBTColorManager.currentValueTitleColor
        currentResultView.valueLabel?.textColor = RMBTColorManager.currentValueValueColor
        currentResultView.subtitleLabel?.textColor = RMBTColorManager.currentValueValueColor
        
        self.currentResultView.colors = [
            RMBTColorManager.resultsGradientPrimaryColor,
            RMBTColorManager.resultsGradientSecondaryColor
        ]
        
        if self.modelView?.align == .left {
            currentResultView.backgroundColor = RMBTColorManager.resultsLeftBackgroundColor
            currentResultView.rootView?.backgroundColor = RMBTColorManager.resultsLeftBackgroundColor
        } else if self.modelView?.align == .justified {
            currentResultView.backgroundColor = RMBTColorManager.resultsLeftBackgroundColor
            currentResultView.rootView?.backgroundColor = RMBTColorManager.resultsLeftBackgroundColor
        } else {
            currentResultView.backgroundColor = RMBTColorManager.resultsRightBackgroundColor
            currentResultView.rootView?.backgroundColor = RMBTColorManager.resultsRightBackgroundColor
        }
    }

}

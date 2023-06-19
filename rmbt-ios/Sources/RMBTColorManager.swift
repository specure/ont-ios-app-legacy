//
//  RMBTColorManager.swift
//  RMBT_ONT
//
//  Created by Sergey Glushchenko on 8/26/18.
//  Copyright © 2018 SPECURE GmbH. All rights reserved.
//

import UIKit

protocol RMBTColorManagerProtocol {
    func applyColorScheme()
}

class RMBTColorManager: NSObject {

    enum Mode {
        case light
        case dark
    }
    static let shared = RMBTColorManager()
    
    private let lightScheme = RMBTLightColorScheme()
    private let darkScheme = RMBTDarkColorScheme()
    
    private var scheme: RMBTColorScheme {
        if RMBT_IS_USE_DARK_MODE == false {
            return self.lightScheme
        }
        if #available(iOS 13.0, *) {
            if UIApplication.shared.delegate?.window??.traitCollection.userInterfaceStyle == .dark {
                return self.darkScheme
            } else {
                return self.lightScheme
            }
        } else {
            return RMBTSettings.sharedSettings.isDarkMode ? self.darkScheme : self.lightScheme
        }
    }
    
    static var background: UIColor {
        return RMBTColorManager.shared.scheme.backgroundColor
    }
    
    static var statusBarStyle: UIStatusBarStyle {
        return RMBTColorManager.shared.scheme.statusBarStyle
    }
    
    static var tableViewBackground: UIColor {
        return RMBTColorManager.shared.scheme.tableViewBackground
    }
    
    static var tableViewSeparator: UIColor {
        return RMBTColorManager.shared.scheme.tableViewSeparator
    }
    
    static var backgroundImage: UIImage? {
        return RMBTColorManager.shared.scheme.backgroundImage
    }
    
    static var testTintColor: UIColor {
        return RMBTColorManager.shared.scheme.testTintColor
    }
    
    static var testHeaderValuesColor: UIColor {
        return RMBTColorManager.shared.scheme.testHeaderValuesColor
    }
    
    static var testValuesTitleColor: UIColor {
        return RMBTColorManager.shared.scheme.testValuesTitleColor
    }
    
    static var testValuesValueColor: UIColor {
        return RMBTColorManager.shared.scheme.testValuesValueColor
    }
    
    static var medianBackgroundColor: UIColor {
        return RMBTColorManager.shared.scheme.medianBackgroundColor
    }
    
    static var medianTextColor: UIColor {
        return RMBTColorManager.shared.scheme.medianTextColor
    }
    
    static var valueTextColor: UIColor {
        return RMBTColorManager.shared.scheme.valueTextColor
    }
    
    static var cellBackground: UIColor {
        return RMBTColorManager.shared.scheme.cellBackgroundColor
    }
    
    static var textColor: UIColor {
        return RMBTColorManager.shared.scheme.textColor
    }
    
    static var historyTextColor: UIColor {
        return RMBTColorManager.shared.scheme.historyTextColor
    }
    
    static var historyNetworkTitleColor: UIColor {
        return RMBTColorManager.shared.scheme.historyNetworkTitleColor
    }
    
    static var historyDateColor: UIColor {
        return RMBTColorManager.shared.scheme.historyDateColor
    }
    
    static var historyHeaderColor: UIColor {
        return RMBTColorManager.shared.scheme.historyHeaderColor
    }
    
    static var historyValueBackgroundColor: UIColor {
        return RMBTColorManager.shared.scheme.historyValueBackgroundColor
    }
    
    static var historyBorderColor: UIColor {
        return RMBTColorManager.shared.scheme.historyBorderColor
    }
    
    static var tintColor: UIColor {
        return RMBTColorManager.shared.scheme.tintColor
    }
    
    static var tintPrimaryColor: UIColor {
        return RMBTColorManager.shared.scheme.tintPrimaryColor
    }
    
    static var tintSecondaryColor: UIColor {
        return RMBTColorManager.shared.scheme.tintSecondaryColor
    }
    
    static var resultsValueTextColor: UIColor {
        return RMBTColorManager.shared.scheme.resultsValueTextColor
    }
    
    static var resultsTitleTextColor: UIColor {
        return RMBTColorManager.shared.scheme.resultsTitleTextColor
    }
    
    static var resultsLeftBackgroundColor: UIColor {
        return RMBTColorManager.shared.scheme.resultsLeftBackgroundColor
    }
    
    static var resultsRightBackgroundColor: UIColor {
        return RMBTColorManager.shared.scheme.resultsRightBackgroundColor
    }
    
    static var resultsGradientPrimaryColor: UIColor {
        return RMBTColorManager.shared.scheme.resultsGradientPrimaryColor
    }
    
    static var resultsGradientSecondaryColor: UIColor {
        return RMBTColorManager.shared.scheme.resultsGradientSecondaryColor
    }
    
    static var loopModeServiceInfoBackgroundColor: UIColor {
        return RMBTColorManager.shared.scheme.loopModeServiceInfoBackgroundColor
    }
    
    static var loopModeServiceInfoTitleColor: UIColor {
        return RMBTColorManager.shared.scheme.loopModeServiceInfoTitleColor
    }
    
    static var loopModeServiceInfoTextColor: UIColor {
        return RMBTColorManager.shared.scheme.loopModeServiceInfoTextColor
    }
    
    static var buttonTitleColor: UIColor {
        return RMBTColorManager.shared.scheme.buttonTitleColor
    }
    
    static var highlightTintColor: UIColor {
        return RMBTColorManager.shared.scheme.highlightTintColor
    }
    
    static var thumbTintColor: UIColor {
        return RMBTColorManager.shared.scheme.thumbTintColor
    }
    
    static var switchBackgroundColor: UIColor? {
        return RMBTColorManager.shared.scheme.switchBackgroundColor
    }
    
    static var tableViewHeaderColor: UIColor {
        return RMBTColorManager.shared.scheme.tableViewHeaderColor
    }
    
    static var settingsHeaderColor: UIColor {
        return RMBTColorManager.shared.scheme.settingsHeaderColor
    }
    
    static var highlightHistoryCellColor: UIColor {
        return RMBTColorManager.shared.scheme.highlightHistoryCellColor
    }
    
    static var normalHistoryCellColor: UIColor {
        return RMBTColorManager.shared.scheme.normalHistoryCellColor
    }
    
    static var highlightCellColor: UIColor {
        return RMBTColorManager.shared.scheme.highlightCellColor
    }
    
    static var normalCellColor: UIColor {
        return RMBTColorManager.shared.scheme.normalCellColor
    }
    
    static var navigationBarBackground: UIColor {
        return RMBTColorManager.shared.scheme.navigationBarBackground
    }
    
    static var navigationBarTitleColor: UIColor {
        return RMBTColorManager.shared.scheme.navigationBarTitleColor
    }
    
    static var tabBarBackgroundColor: UIColor {
        return RMBTColorManager.shared.scheme.tabBarBackground
    }
    
    static var tabBarSelectedColor: UIColor {
        return RMBTColorManager.shared.scheme.tabBarSelectedColor
    }
    
    static var tabBarUnselectedColor: UIColor {
        return RMBTColorManager.shared.scheme.tabBarUnselectedColor
    }
    
    static var networkInfoTitleColor: UIColor {
        return RMBTColorManager.shared.scheme.networkInfoTitle
    }
    
    static var networkInfoValueColor: UIColor {
        return RMBTColorManager.shared.scheme.networkInfoValue
    }
    
    // We use it for title for current value during test
    static var currentValueTitleColor: UIColor {
        return RMBTColorManager.shared.scheme.currentValueTitleColor
    }
    
    // We use it for value for current value during test
    static var currentValueValueColor: UIColor {
        return RMBTColorManager.shared.scheme.currentValueValueColor
    }
    
    static var currentServerTitleColor: UIColor {
        return RMBTColorManager.shared.scheme.currentServerTitleColor
    }
    
    static var loopModeValueColor: UIColor {
        return RMBTColorManager.shared.scheme.loopModeValueColor
    }
    
    static var loopModeProgressColor: UIColor {
        return RMBTColorManager.shared.scheme.loopModeProgressColor
    }
    
}

//
//  RMBTColorScheme.swift
//  RMBT_ONT
//
//  Created by Sergey Glushchenko on 8/26/18.
//  Copyright © 2018 SPECURE GmbH. All rights reserved.
//

import UIKit

class RMBTColorScheme: NSObject {
    var backgroundColor: UIColor {
        return RMBTBackgroundColorLight
    }
    
    var statusBarStyle: UIStatusBarStyle {
        return RMBTStatusBarStyleLight
    }
    
    var tableViewBackground: UIColor {
        return RMBTTableViewBackgroundColorLight
    }
    
    var tableViewSeparator: UIColor {
        return RMBTTableViewSeparatorColorLight
    }
    
    var backgroundImage: UIImage? {
        return nil
    }
    
    var testTintColor: UIColor {
        return RMBTTestTintColorLight
    }
    
    var testHeaderValuesColor: UIColor {
        return RMBTTestHeaderValuesColorLight
    }
    
    var testValuesTitleColor: UIColor {
        return RMBTTestValuesTitleColorLight
    }
    
    var testValuesValueColor: UIColor {
        return RMBTTestValuesValueColorLight
    }
    
    var medianBackgroundColor: UIColor {
        return RMBTMedianBackgroundColorLight
    }
    
    var medianTextColor: UIColor {
        return RMBTMedianTextColorLight
    }
    
    var valueTextColor: UIColor {
        return RMBTValueTextColorLight
    }
    
    var cellBackgroundColor: UIColor {
        return RMBTTableViewCellColorLight
    }
    
    var highlightCellColor: UIColor {
        return RMBTHighlightCellColorLight
    }
    
    var normalCellColor: UIColor {
        return RMBTNormalCellColorLight
    }
    
    var highlightHistoryCellColor: UIColor {
        return RMBTHighlightHistoryCellColorLight
    }
    
    var normalHistoryCellColor: UIColor {
        return RMBTHistoryDateBackgroundColorLight
    }
    
    var textColor: UIColor {
        return RMBTTextColorLight
    }
    
    var historyTextColor: UIColor {
        return RMBTHistoryTextColorLight
    }
    
    var historyNetworkTitleColor: UIColor {
        return RMBTHistoryNetworkTitleColorLight
    }
    
    var historyHeaderColor: UIColor {
        return RMBTHistoryHeaderColorLight
    }
    
    var historyValueBackgroundColor: UIColor {
        return RMBTHistoryValueBackgroundColorLight
    }
    
    var historyBorderColor: UIColor {
        return RMBTHistoryBorderColorLight
    }
    
    var historyDateColor: UIColor {
        return RMBTHistoryDateColorLight
    }
    
    var tintColor: UIColor {
        return RMBTTintColorLight
    }
    
    var tintPrimaryColor: UIColor {
        return RMBTTintColorPrimaryLight
    }
    
    var tintSecondaryColor: UIColor {
        return RMBTTintColorSecondaryLight
    }
    
    var resultsValueTextColor: UIColor {
        return RMBTResultsValueTextColorLight
    }
    
    var resultsTitleTextColor: UIColor {
        return RMBTResultsTitleTextColorLight
    }
    
    var resultsLeftBackgroundColor: UIColor {
        return RMBTResultsLeftBackgroundColorLight
    }
    
    var resultsRightBackgroundColor: UIColor {
        return RMBTResultsRightBackgroundColorLight
    }
    
    var resultsGradientPrimaryColor: UIColor {
        return RMBTResultsGradientPrimaryColorLight
    }
    
    var resultsGradientSecondaryColor: UIColor {
        return RMBTResultsGradientSecondaryColorLight
    }
    
    var loopModeServiceInfoBackgroundColor: UIColor {
        return RMBTLoopModeServiceInfoBackgroundColorLight
    }
    
    var loopModeServiceInfoTitleColor: UIColor {
        return RMBTLoopModeServiceInfoTitleColorLight
    }
    
    var loopModeServiceInfoTextColor: UIColor {
        return RMBTLoopModeServiceInfoTextColorLight
    }
    
    var buttonTitleColor: UIColor {
        return RMBTButtonTitleColorLight
    }
    
    var highlightTintColor: UIColor {
        return RMBTHighlightTintColorLight
    }
    
    var thumbTintColor: UIColor {
        return RMBTSwitcherThumbTintColorLight
    }
    
    var switchBackgroundColor: UIColor? {
        return RMBTSwitcherBackgroundColorLight.withAlphaComponent(0.3)
    }
    
    var tableViewHeaderColor: UIColor {
        return RMBTTableViewHeaderTitleColorLight
    }
    
    var settingsHeaderColor: UIColor {
        return RMBTSettingsHeaderTitleColorLight
    }
    
    var navigationBarBackground: UIColor {
        return RMBTNavigationBarBackgroundLight
    }
    
    var navigationBarTitleColor: UIColor {
        return RMBTNavigationBarTitleColorLight
    }
    
    var tabBarBackground: UIColor {
        return RMBTTabBarBackgroundLight
    }
    
    var tabBarSelectedColor: UIColor {
        return RMBTTabBarSelectedColorLight
    }
    
    var tabBarUnselectedColor: UIColor {
        return RMBTTabBarUnselectedColorLight
    }
    
    var networkInfoTitle: UIColor {
        return RMBTNetworkInfoTitleLight
    }
    
    var networkInfoValue: UIColor {
        return RMBTNetworkInfoValueLight
    }
    
    // We use it for title for current value during test
    var currentValueTitleColor: UIColor {
        return RMBTCurrentValueTitleColorLight
    }
    
    // We use it for value for current value during test
    var currentValueValueColor: UIColor {
        return RMBTCurrentValueValueColorLight
    }
    
    var currentServerTitleColor: UIColor {
        return RMBTCurrentServerTitleLight
    }
    
    var loopModeValueColor: UIColor {
        return RMBTLoopModeValueColorLight
    }
    
    var loopModeProgressColor: UIColor {
        return RMBT_TINT_COLOR
    }
}

//
//  Answers+Additions.swift
//  UnitTests
//
//  Created by Sergey Glushchenko on 8/22/18.
//  Copyright © 2018 SPECURE GmbH. All rights reserved.
//

import FirebaseAnalytics

class AnalyticsHelper {
    class func logCustomEvent(withName name: String, attributes: [String: Any]?) {
        var customAttributes = attributes
        if let attributes = attributes {
            for (key, value) in attributes where !(value is String) {
                let resultKey = key.replacingOccurrences(of: " ", with: "_")
                customAttributes?[resultKey] = String(describing: value)
            }
        }
        
        Analytics.logEvent(name, parameters: customAttributes)
    }
    
    class func logContentView(withName name: String, contentId: String? = nil) {
        var parameters: [String: String] = [:]
        parameters[AnalyticsParameterItemID] = contentId
        Analytics.logEvent(AnalyticsEventSelectContent, parameters: parameters)
    }
    
    class func setObject(value: String, for key: String) {
        Analytics.setUserProperty(value, forName: key)
    }
    
    class func setUserId(value: String) {
        Analytics.setUserID(value)
    }
    
    class func logPurchase(withPrice: Double?, currency: String?, success: Bool, itemName: String, itemType: String? = nil, itemId: String) {
        var parameters: [String: Any] = [:]
        parameters[AnalyticsParameterValue] = withPrice
        parameters[AnalyticsParameterCurrency] = currency
        parameters["success"] = success
        parameters[AnalyticsParameterItems] = [
            AnalyticsParameterItemID: itemId,
            AnalyticsParameterItemName: itemName
        ]
        parameters[AnalyticsParameterItems] = [itemName]
        Analytics.logEvent(AnalyticsEventPurchase, parameters: parameters)
    }
}

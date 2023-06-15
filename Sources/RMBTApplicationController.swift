//
//  RMBTApplicationController.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 12/10/17.
//  Copyright © 2017 SPECURE GmbH. All rights reserved.
//

import UIKit

class RMBTApplicationController: NSObject {
    private static let kIsNeedWizardKey = "kIsNeedWizardKey"
    private static let kMeasurementServerIdKey = "measurementServerId"
    
    class var measurementServerId: Int? {
        set {
            UserDefaults.standard.set(newValue, forKey: kMeasurementServerIdKey)
            UserDefaults.standard.synchronize()
        }
        get {
            if let serverId = UserDefaults.standard.object(forKey: kMeasurementServerIdKey) {
                return serverId as? Int
            }
            return nil
        }
    }
    
    static var isNeedWizard: Bool {
        return !UserDefaults.standard.bool(forKey: RMBTApplicationController.kIsNeedWizardKey)
    }
    
    class func wizardDone() {
        UserDefaults.standard.set(true, forKey: kIsNeedWizardKey)
        UserDefaults.standard.synchronize()
    }
}

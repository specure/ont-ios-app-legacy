//
//  UIUtility.swift
//  RMBT
//
//  Created by Tomas Baculák on 08/08/2017.
//  Copyright © 2017 SPECURE GmbH. All rights reserved.
//

import Foundation
import ActionKit

///
func bindSwitch(_ aSwitch: UISwitch?, toSettingsKeyPath keyPath: String, onToggle: ((_ value: Bool) -> Void)?) {
    aSwitch?.isOn = (RMBTSettings.sharedSettings.value(forKey: keyPath) as! NSNumber).boolValue
    
    if let theSwitch = aSwitch {
        theSwitch.removeControlEvent(.valueChanged)
        theSwitch.addControlEvent(.valueChanged) {
            //logger.debug("SET VALUE FOR KEY: \(keyPath)")
            //logger.debug("GET VALUE FOR KEY: \(keyPath), \(self.settings.valueForKey(keyPath))")
            RMBTSettings.sharedSettings.setValue(NSNumber(value: theSwitch.isOn), forKey: keyPath)
            //logger.debug("GET VALUE FOR KEY: \(keyPath), \(self.settings.valueForKey(keyPath))")
            
            onToggle?(theSwitch.isOn)
        }
    }
}

///
func bindTextField(_ textField: UITextField?, toSettingsKeyPath keyPath: String, numeric: Bool, onToggle: @escaping (_ key: String, _ value: Any?) -> Void = { _,_ in }) {
    var stringValue = ""
    
    if let val = RMBTSettings.sharedSettings.value(forKey: keyPath) {
        if numeric {
            stringValue = (val as? NSNumber)?.stringValue ?? ""
        } else {
            stringValue = val as? String ?? ""
        }
    }
    
    if numeric && stringValue == "0" {
        stringValue = ""
    }
    
    textField?.text = stringValue
    
    if let theTextField = textField {
        theTextField.removeControlEvent(.editingDidEnd)
        theTextField.addControlEvent(.editingDidEnd) {
            var newValue: AnyObject? = theTextField.text as AnyObject?
            
            if numeric {
                if let text = theTextField.text, let num = Int(text) {
                    newValue = NSNumber(value: num)
                } else {
                    newValue = NSNumber(value: 0)
                }
            }
            
            //logger.debug("GET VALUE FOR KEY: \(keyPath), \(self.settings.valueForKey(keyPath))")
            RMBTSettings.sharedSettings.setValue(newValue, forKey: keyPath)
            //logger.debug("GET VALUE FOR KEY: \(keyPath), \(self.settings.valueForKey(keyPath))")
            onToggle(keyPath, newValue)
        }
    }
}

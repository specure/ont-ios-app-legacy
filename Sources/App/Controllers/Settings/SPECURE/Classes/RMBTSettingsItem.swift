//
//  RMBTSettingsItem.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 7/16/18.
//  Copyright © 2018 SPECURE GmbH. All rights reserved.
//

import UIKit

class RMBTSettingsItem: NSObject {
    enum Mode {
        case subtitle
        case disclosureIndicator
        case button
        case switcher
        case textField
        case numberTextField
        case options
        case purchases
    }
    
    var title: String?
    var subtitle: String?
    var placeholder: String?
    var value: Any?
    var mode: Mode = .switcher
    var identifier: RMBTSettingsViewController.Identifier = .enableQos
}

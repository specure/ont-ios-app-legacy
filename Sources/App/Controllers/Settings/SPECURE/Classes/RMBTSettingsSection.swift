//
//  RMBTSettingsSection.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 7/16/18.
//  Copyright © 2018 SPECURE GmbH. All rights reserved.
//

import UIKit

class RMBTSettingsSection: NSObject {
    var title: String?
    
    var items: [RMBTSettingsItem] = []
    var isExpanded: Bool = true
}

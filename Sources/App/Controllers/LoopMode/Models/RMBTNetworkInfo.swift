//
//  RMBTNetworkInfo.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 10/5/18.
//  Copyright © 2018 SPECURE GmbH. All rights reserved.
//

import UIKit

class RMBTNetworkInfo: NSObject {
    var location: String?
    var networkName: String?
    var networkType: String?
    var networkLocation: String?
    
    init(location: String?, networkType: String?, networkName: String?, networkLocation: String?) {
        self.location = location
        self.networkName = networkName
        self.networkType = networkType
        self.networkLocation = networkLocation
    }
}

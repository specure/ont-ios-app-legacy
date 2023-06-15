//
//  RMBTConfigurationFabric.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 12/26/18.
//  Copyright © 2018 SPECURE GmbH. All rights reserved.
//

import UIKit

class RMBTConfigFabric {
    enum Idenitifier {
        case ont
    }
    
    class func config(with identifier: Idenitifier) -> RMBTConfigurationProtocol {
        switch identifier {
        case .ont:
            return RMBTONTConfigurationV2()
        }
    }
}

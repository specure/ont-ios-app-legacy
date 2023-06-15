//
//  RMBTONTConfigurationV2.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 13.06.2020.
//  Copyright © 2020 SPECURE GmbH. All rights reserved.
//

import UIKit

class RMBTONTConfigurationV2: RMBTConfigurationProtocol {
    override var RMBT_CONTROL_SERVER_PATH: String { return "/ControlServer/V2" }
    override var RMBT_CONTROL_MEASUREMENT_SERVER_PATH: String { return "/ControlServer/V2" }
    override var RMBT_MAP_SERVER_PATH: String { return "/MapServer/V2" }
    
    override var RMBT_VERSION: Int { return 2 }
    
    #if DEBUG || TEST

    override var RMBT_URL_HOST: String { return "https://customers.example.org" }
    override var RMBT_IPV4_URL_HOST: String { return "https://customers.example.org" }
    override var RMBT_IPV6_URL_HOST: String { return "https://customers.example.org" }
    override var RMBT_MAP_SERVER_URL: String {
        return "https://customers.example.org\(RMBT_MAP_SERVER_PATH)"
    }
    #else
    override var RMBT_URL_HOST: String { return "https://customers.example.org" }
    override var RMBT_IPV4_URL_HOST: String { return "https://customers.example.org" }
    override var RMBT_IPV6_URL_HOST: String { return "https://customers.example.org" }
    override var RMBT_MAP_SERVER_URL: String {
        return "https://customers.example.org\(RMBT_MAP_SERVER_PATH)"
    }
    #endif
    
    override var RMBT_SETTINGS_MODE: RMBTConfig.SettingsMode {
        return .urlsLocally
    }
}

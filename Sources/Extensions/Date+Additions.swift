//
//  Date+Additions.swift
//  RMBT_ONT
//
//  Created by Sergey Glushchenko on 12/21/17.
//  Copyright © 2017 SPECURE GmbH. All rights reserved.
//

import Foundation

extension Date {
    func toLocalTime() -> Date {
        let tz = TimeZone.current
        let seconds = tz.secondsFromGMT(for: self)
        return Date(timeInterval: TimeInterval(seconds), since: self)
    }
}

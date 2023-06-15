//
//  RMBTSpeedTest.swift
//  RMBT
//
//  Created by Benjamin Pucher on 11.12.14.
//  Copyright © 2014 SPECURE GmbH. All rights reserved.
//

import XCTest

@testable import RMBTClient

///
class RMBTSpeedTest: XCTestCase {

    ///
    override func setUp() {
        super.setUp()
    }

    ///
    override func tearDown() {
        super.tearDown()
    }

    ///
    func testFormatting() {
        XCTAssertEqual(RMBTSpeedMbpsString(11221), "11.2 Mbps")
        XCTAssertEqual(RMBTSpeedMbpsString(11500), "11.5 Mbps") // bankers' rounding
        XCTAssertEqual(RMBTSpeedMbpsString(11490), "11.5 Mbps")

        XCTAssertEqual(RMBTSpeedMbpsString(11490), "11.5 Mbps")
        XCTAssertEqual(RMBTSpeedMbpsString(11490, withMbps: false), "11.5")

        XCTAssertEqual(RMBTSpeedMbpsString(154), "0.15 Mbps")
        XCTAssertEqual(RMBTSpeedMbpsString(155), "0.16 Mbps")
        XCTAssertEqual(RMBTSpeedMbpsString(155, withMbps: false), "0.16")

        XCTAssertEqual(RMBTSpeedMbpsString(123000), "123 Mbps")

        XCTAssertEqual(RMBTSpeedMbpsString(1250), "1.25 Mbps")
    }

}

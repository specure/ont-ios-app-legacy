//
//  QOSTracerouteTestTests.swift
//  UnitTests
//
//  Created by Benjamin Pucher on 11.12.14.
//  Copyright © 2014 SPECURE GmbH. All rights reserved.
//

import XCTest

@testable import RMBTClient

///
class QOSTracerouteTestTests: XCTestCase {

    ///
    override func setUp() {
        super.setUp()
    }

    ///
    override func tearDown() {
        super.tearDown()
    }

    // TODO: test with wrong, missing and malformed parameters

    ///
    func testWithCorrectParameters() {
        let paramHost = "specure.com"
        let paramMaxHops: UInt8 = 100

        let testParameters: QOSTestParameters = [
            "host": paramHost,
            "max_hops": "\(paramMaxHops)"
        ]

        let qosTracerouteTest = QOSTracerouteTest(testParameters: testParameters)

        XCTAssertEqual(qosTracerouteTest.host!, paramHost, "host not equal")
        XCTAssertEqual(qosTracerouteTest.maxHops, paramMaxHops, "max_hops not equal")

        // check if description contains these values (though not a good test)
        XCTAssert(
            qosTracerouteTest.description.contains(paramHost) &&
            qosTracerouteTest.description.contains("\(paramMaxHops)"),
            "description doesn't contain right values"
        )
    }

    ///
    func testReturnsCorrectTestType() {
        XCTAssertEqual(QOSTracerouteTest(testParameters: [:]).getType(), QosMeasurementType.TRACEROUTE)
    }
}

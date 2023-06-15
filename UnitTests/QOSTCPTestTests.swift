//
//  QOSTCPTestTests.swift
//  UnitTests
//
//  Created by Benjamin Pucher on 11.12.14.
//  Copyright © 2014 SPECURE GmbH. All rights reserved.
//

import XCTest

@testable import RMBTClient

///
class QOSTCPTestTests: XCTestCase {

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
        let paramPortOut: UInt16 = 8080
        let paramPortIn: UInt16 = 8081

        let testParameters: QOSTestParameters = [
            "out_port": "\(paramPortOut)",
            "in_port": "\(paramPortIn)"
        ]

        let qosTcpTest = QOSTCPTest(testParameters: testParameters)

        XCTAssertEqual(qosTcpTest.portOut!, paramPortOut, "out_port not equal")
        XCTAssertEqual(qosTcpTest.portIn!, paramPortIn, "in_port not equal")

        // check if description contains these values (though not a good test)
        XCTAssert(
            qosTcpTest.description.contains("\(paramPortOut)") &&
            qosTcpTest.description.contains("\(paramPortIn)"),
            "description doesn't contain right values"
        )
    }

    ///
    func testReturnsCorrectTestType() {
        XCTAssertEqual(QOSTCPTest(testParameters: [:]).getType(), QosMeasurementType.TCP)
    }
}

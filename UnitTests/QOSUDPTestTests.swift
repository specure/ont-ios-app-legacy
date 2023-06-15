//
//  QOSUDPTestTests.swift
//  UnitTests
//
//  Created by Benjamin Pucher on 11.12.14.
//  Copyright © 2014 SPECURE GmbH. All rights reserved.
//

import XCTest

@testable import RMBTClient

///
class QOSUDPTestTests: XCTestCase {

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
        let paramPacketCountOut: UInt16 = 2
        let paramPacketCountIn: UInt16 = 1
        let paramPortOut: UInt16 = 8080
        let paramPortIn: UInt16 = 8081
        let paramDelay: UInt64 = 100_000_000

        let testParameters: QOSTestParameters = [
            "out_num_packets": "\(paramPacketCountOut)",
            "in_num_packets": "\(paramPacketCountIn)",
            "out_port": "\(paramPortOut)",
            "in_port": "\(paramPortIn)",
            "delay": "\(paramDelay)"
        ]

        let qosUdpTest = QOSUDPTest(testParameters: testParameters)

        XCTAssertEqual(qosUdpTest.packetCountOutgoing!, paramPacketCountOut, "out_num_packets not equal")
        XCTAssertEqual(qosUdpTest.packetCountIncoming!, paramPacketCountIn, "in_num_packets not equal")
        XCTAssertEqual(qosUdpTest.portOut!, paramPortOut, "out_port not equal")
        XCTAssertEqual(qosUdpTest.portIn!, paramPortIn, "in_port not equal")
        XCTAssertEqual(qosUdpTest.delay, paramDelay, "delay not equal")

        // check if description contains these values (though not a good test)
        XCTAssert(
            qosUdpTest.description.contains("\(paramPacketCountOut)") &&
            qosUdpTest.description.contains("\(paramPacketCountIn)") &&
            qosUdpTest.description.contains("\(paramPortOut)") &&
            qosUdpTest.description.contains("\(paramPortIn)") &&
            qosUdpTest.description.contains("\(paramDelay)"),
            "description doesn't contain right values"
        )
    }

    ///
    func testReturnsCorrectTestType() {
        XCTAssertEqual(QOSUDPTest(testParameters: [:]).getType(), QosMeasurementType.UDP)
    }
}

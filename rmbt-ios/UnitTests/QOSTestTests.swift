//
//  QOSTestTests.swift
//  UnitTests
//
//  Created by Benjamin Pucher on 11.12.14.
//  Copyright © 2014 SPECURE GmbH. All rights reserved.
//

import XCTest

@testable import RMBTClient

///
class QOSTestTests: XCTestCase {

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
        let paramQosTestId: UInt = 1
        let paramConcurrencyGroup: UInt = 1
        let paramServerAddress = "127.0.0.1"
        let paramServerPort: UInt16 = 80
        let paramTimeout: UInt64 = 5_000_000_000

        let testParameters: QOSTestParameters = [
            "qos_test_uid": "\(paramQosTestId)",
            "concurrency_group": "\(paramConcurrencyGroup)",
            "server_addr": paramServerAddress,
            "server_port": "\(paramServerPort)",
            "timeout": "\(paramTimeout)"
        ]

        let qosTest = QOSTest(testParameters: testParameters)

        XCTAssertEqual(qosTest.qosTestId, paramQosTestId, "qos_test_uid not equal")
        XCTAssertEqual(qosTest.concurrencyGroup, paramConcurrencyGroup, "concurrency_group not equal")
        XCTAssertEqual(qosTest.serverAddress, paramServerAddress, "server_addr not equal")
        XCTAssertEqual(qosTest.serverPort, paramServerPort, "server_port not equal")
        XCTAssertEqual(qosTest.timeout, paramTimeout, "timeout not equal")

        // check if description contains these values (though not a good test)
        XCTAssert(
            qosTest.description.contains("\(paramQosTestId)") &&
            qosTest.description.contains("\(paramConcurrencyGroup)") &&
            qosTest.description.contains(paramServerAddress) &&
            qosTest.description.contains("\(paramServerPort)") &&
            qosTest.description.contains("\(paramTimeout)"),
            "description doesn't contain right values"
        )
    }

    ///
    func testReturnsCorrectTestType() {
        XCTAssertNil(QOSTest(testParameters: [:]).getType())
    }

}

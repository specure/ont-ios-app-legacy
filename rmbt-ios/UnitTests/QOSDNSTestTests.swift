//
//  QOSDNSTestTests.swift
//  UnitTests
//
//  Created by Benjamin Pucher on 11.12.14.
//  Copyright © 2014 SPECURE GmbH. All rights reserved.
//

import XCTest

@testable import RMBTClient

///
class QOSDNSTestTests: XCTestCase {

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
        let paramResolver = "8.8.8.8"
        let paramRecord = "A"

        let testParameters: QOSTestParameters = [
            "host": paramHost,
            "resolver": paramResolver,
            "record": paramRecord
        ]

        let qosDnsTest = QOSDNSTest(testParameters: testParameters)

        XCTAssertEqual(qosDnsTest.host!, paramHost, "host not equal")
        XCTAssertEqual(qosDnsTest.resolver!, paramResolver, "resolver not equal")
        XCTAssertEqual(qosDnsTest.record!, paramRecord, "record not equal")

        // check if description contains these values (though not a good test)
        XCTAssert(
            qosDnsTest.description.contains(paramHost) &&
            qosDnsTest.description.contains(paramResolver) &&
            qosDnsTest.description.contains(paramRecord),
            "description doesn't contain right values"
        )
    }

    ///
    func testReturnsCorrectTestType() {
        XCTAssertEqual(QOSDNSTest(testParameters: [:]).getType(), QosMeasurementType.DNS)
    }

    func testDNSClient() {
        let paramHost = "specure.com"
        let paramResolver = "8.8.8.8"
        let paramRecord = "A"
        
        let dnsClient = DNSClient()
    }
    
}

//
//  QOSNonTransparentProxyTestTests.swift
//  UnitTests
//
//  Created by Benjamin Pucher on 11.12.14.
//  Copyright © 2014 SPECURE GmbH. All rights reserved.
//

import XCTest

@testable import RMBTClient

///
class QOSNonTransparentProxyTestTests: XCTestCase {

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
        let paramRequest = "HTTR/1"
        let paramPort: UInt16 = 80

        let testParameters: QOSTestParameters = [
            "request": paramRequest,
            "port": "\(paramPort)"
        ]

        let qosNonTransparentProxyTest = QOSNonTransparentProxyTest(testParameters: testParameters)

        XCTAssertEqual(qosNonTransparentProxyTest.request!, paramRequest + "\n", "request not equal") // adds \n if not present
        XCTAssertEqual(qosNonTransparentProxyTest.port!, paramPort, "port not equal")

        // check if description contains these values (though not a good test)
        XCTAssert(
            qosNonTransparentProxyTest.description.contains("\(paramRequest)") &&
            qosNonTransparentProxyTest.description.contains("\(paramPort)"),
            "description doesn't contain right values"
        )
    }

    ///
    func testReturnsCorrectTestType() {
        XCTAssertEqual(QOSNonTransparentProxyTest(testParameters: [:]).getType(), QosMeasurementType.NonTransparentProxy)
    }

}

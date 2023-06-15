//
//  QOSHTTPProxyTestTests.swift
//  UnitTests
//
//  Created by Benjamin Pucher on 11.12.14.
//  Copyright © 2014 SPECURE GmbH. All rights reserved.
//

import XCTest

@testable import RMBTClient

///
class QOSHTTPProxyTestTests: XCTestCase {

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
        let paramUrl = "https://specure.com"
        let paramRange = "0-100"
        let paramDownloadTimeout: UInt64 = 5_000_000_000
        let paramConnTimeout: UInt64 = 3_000_000_000

        let testParameters: QOSTestParameters = [
            "url": paramUrl,
            "range": paramRange,
            "download_timeout": "\(paramDownloadTimeout)",
            "conn_timeout": "\(paramConnTimeout)"
        ]

        let qosHttpProxyTest = QOSHTTPProxyTest(testParameters: testParameters)

        XCTAssertEqual(qosHttpProxyTest.url!, paramUrl, "url not equal")
        XCTAssertEqual(qosHttpProxyTest.range!, paramRange, "range not equal")
        XCTAssertEqual(qosHttpProxyTest.downloadTimeout, paramDownloadTimeout, "download_timeout not equal")
        XCTAssertEqual(qosHttpProxyTest.connectionTimeout, paramConnTimeout, "conn_timeout not equal")

        // check if description contains these values (though not a good test)
        XCTAssert(
            qosHttpProxyTest.description.contains(paramUrl) &&
            qosHttpProxyTest.description.contains(paramRange) &&
            qosHttpProxyTest.description.contains("\(paramDownloadTimeout)") &&
            qosHttpProxyTest.description.contains("\(paramConnTimeout)"),
            "description doesn't contain right values"
        )
    }

    ///
    func testReturnsCorrectTestType() {
        XCTAssertEqual(QOSHTTPProxyTest(testParameters: [:]).getType(), QosMeasurementType.HttpProxy)
    }

}

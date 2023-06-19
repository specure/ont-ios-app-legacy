//
//  QOSWebsiteTestTests.swift
//  UnitTests
//
//  Created by Benjamin Pucher on 11.12.14.
//  Copyright © 2014 SPECURE GmbH. All rights reserved.
//

import XCTest

@testable import RMBTClient

///
class QOSWebsiteTestTests: XCTestCase {

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

        let testParameters: QOSTestParameters = [
            "url": paramUrl
        ]

        let qosWebsiteTest = QOSWebsiteTest(testParameters: testParameters)

        XCTAssertEqual(qosWebsiteTest.url!, paramUrl, "request not equal") // adds \n if not present

        // check if description contains these values (though not a good test)
        XCTAssert(
            qosWebsiteTest.description.contains("\(paramUrl)"),
            "description doesn't contain right values"
        )
    }

    ///
    func testReturnsCorrectTestType() {
        XCTAssertEqual(QOSWebsiteTest(testParameters: [:]).getType(), QosMeasurementType.WEBSITE)
    }

}

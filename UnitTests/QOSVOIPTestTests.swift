//
//  QOSVOIPTestTests.swift
//  UnitTests
//
//  Created by Benjamin Pucher on 11.12.14.
//  Copyright © 2014 SPECURE GmbH. All rights reserved.
//

import XCTest

@testable import RMBTClient

///
class QOSVOIPTestTests: XCTestCase {

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
        let paramDelay: UInt64 = 15_000_000
        let paramCallDuration: UInt64 = 2_000_000_000
        let paramSampleRate: UInt16 = 9000
        let paramBitsPerSample: UInt8 = 9
        let paramPayloadType: UInt8 = 9

        let testParameters: QOSTestParameters = [
            "out_port": "\(paramPortOut)",
            "in_port": "\(paramPortIn)",
            "delay": "\(paramDelay)",
            "call_duration": "\(paramCallDuration)",
            "sample_rate": "\(paramSampleRate)",
            "bits_per_sample": "\(paramBitsPerSample)",
            "payload": "\(paramPayloadType)"
        ]

        let qosVoipTest = QOSVOIPTest(testParameters: testParameters)

        XCTAssertEqual(qosVoipTest.portOut!, paramPortOut, "out_port not equal")
        XCTAssertEqual(qosVoipTest.portIn!, paramPortIn, "in_port not equal")
        XCTAssertEqual(qosVoipTest.delay, paramDelay, "delay not equal")
        XCTAssertEqual(qosVoipTest.callDuration, paramCallDuration, "call_duration not equal")
        XCTAssertEqual(qosVoipTest.sampleRate, paramSampleRate, "sample_rate not equal")
        XCTAssertEqual(qosVoipTest.bitsPerSample, paramBitsPerSample, "bits_per_sample not equal")
        XCTAssertEqual(qosVoipTest.payloadType, paramPayloadType, "payload not equal")

        // check if description contains these values (though not a good test)
        XCTAssert(
            qosVoipTest.description.contains("\(paramPortOut)") &&
            qosVoipTest.description.contains("\(paramPortIn)") &&
            qosVoipTest.description.contains("\(paramDelay)") &&
            qosVoipTest.description.contains("\(paramCallDuration)") &&
            qosVoipTest.description.contains("\(paramSampleRate)") &&
            qosVoipTest.description.contains("\(paramBitsPerSample)") &&
            qosVoipTest.description.contains("\(paramPayloadType)") &&
            qosVoipTest.description.contains("\(paramDelay)"),
            "description doesn't contain right values"
        )
    }

    ///
    func testReturnsCorrectTestType() {
        XCTAssertEqual(QOSVOIPTest(testParameters: [:]).getType(), QosMeasurementType.VOIP)
    }

}

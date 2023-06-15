//
//  RTPPacketTests.swift
//  RMBT
//
//  Created by Benjamin Pucher on 13.03.15.
//  Copyright (c) 2015 Specure GmbH. All rights reserved.
//

import XCTest

@testable import RMBTClient

///
class RTPPacketTests: XCTestCase {

    ///
    override func setUp() {
        super.setUp()
    }

    ///
    override func tearDown() {
        super.tearDown()
    }

    ///
    func testVersion() {

        var rtpPacket = RTPPacket()

        // getter

        // version = 0
        rtpPacket.header.flags = 0b0000_0000_0000_0000
        XCTAssertEqual(UInt8(0), rtpPacket.header.version, "00 -> wrong version \(rtpPacket.header.version)")

        // version = 1
        rtpPacket.header.flags = 0b0100_0000_0000_0000
        XCTAssertEqual(UInt8(1), rtpPacket.header.version, "01 -> wrong version \(rtpPacket.header.version)")

        // version = 2
        rtpPacket.header.flags = 0b1000_0000_0000_0000
        XCTAssertEqual(UInt8(2), rtpPacket.header.version, "10 -> wrong version \(rtpPacket.header.version)")

        // version = 3
        rtpPacket.header.flags = 0b1100_0000_0000_0000
        XCTAssertEqual(UInt8(3), rtpPacket.header.version, "11 -> wrong version \(rtpPacket.header.version)")

        // setter

        rtpPacket.header.version = 0
        // XCTAssertEqual(UInt8(0), rtpPacket.header.version, "00 -> false version \(rtpPacket.header.version)")
        XCTAssertEqual(UInt16(0b0000_0000_0000_0000), rtpPacket.header.flags, "")

        rtpPacket.header.version = 1
        // XCTAssertEqual(UInt8(1), rtpPacket.header.version, "01 -> false version \(rtpPacket.header.version)")
        XCTAssertEqual(UInt16(0b0100_0000_0000_0000), rtpPacket.header.flags, "")

        rtpPacket.header.version = 2
        // XCTAssertEqual(UInt8(2), rtpPacket.header.version, "10 -> false version \(rtpPacket.header.version)")
        XCTAssertEqual(UInt16(0b1000_0000_0000_0000), rtpPacket.header.flags, "")

        rtpPacket.header.version = 3
        // XCTAssertEqual(UInt8(3), rtpPacket.header.version, "11 -> false version \(rtpPacket.header.version)")
        XCTAssertEqual(UInt16(0b1100_0000_0000_0000), rtpPacket.header.flags, "")
    }

    ///
    func testPadding() {

        var rtpPacket = RTPPacket()

        // getter

        // padding = 0
        rtpPacket.header.flags = 0b0000_0000_0000_0000
        XCTAssertEqual(UInt8(0), rtpPacket.header.padding, "0 -> wrong padding \(rtpPacket.header.padding)")

        // padding = 1
        rtpPacket.header.flags = 0b0010_0000_0000_0000
        XCTAssertEqual(UInt8(1), rtpPacket.header.padding, "1 -> wrong padding \(rtpPacket.header.padding)")

        // setter

        rtpPacket.header.padding = 0
        XCTAssertEqual(UInt16(0b0000_0000_0000_0000), rtpPacket.header.flags, "")

        rtpPacket.header.padding = 1
        XCTAssertEqual(UInt16(0b0010_0000_0000_0000), rtpPacket.header.flags, "")
    }

    ///
    func testExt() {

        var rtpPacket = RTPPacket()

        // getter

        // ext = 0
        rtpPacket.header.flags = 0b0000_0000_0000_0000
        XCTAssertEqual(UInt8(0), rtpPacket.header.ext, "0 -> wrong ext \(rtpPacket.header.ext)")

        // ext = 1
        rtpPacket.header.flags = 0b0001_0000_0000_0000
        XCTAssertEqual(UInt8(1), rtpPacket.header.ext, "1 -> wrong ext \(rtpPacket.header.ext)")

        // setter

        rtpPacket.header.ext = 0
        XCTAssertEqual(UInt16(0b0000_0000_0000_0000), rtpPacket.header.flags, "")

        rtpPacket.header.ext = 1
        XCTAssertEqual(UInt16(0b0001_0000_0000_0000), rtpPacket.header.flags, "")
    }

    ///
    func testCsrcCount() {

        var rtpPacket = RTPPacket()

        // getter

        for i in 0...15 {
            // println("testing csrcCount: \(i)")

            // csrcCount = i
            rtpPacket.header.flags = UInt16(0b0000 << 12) + UInt16(i << 8)
            XCTAssertEqual(UInt8(i), rtpPacket.header.csrcCount, "\(i) -> wrong csrcCount \(rtpPacket.header.csrcCount)")
        }

        // setter

        for i in 0...15 {
            // println("testing csrcCount: \(i)")

            // csrcCount = i
            rtpPacket.header.csrcCount = UInt8(i)
            XCTAssertEqual(UInt16((0b0000 << 12) + (i << 8)), rtpPacket.header.flags, "")
        }
    }

    ///
    func testMarker() {

        var rtpPacket = RTPPacket()

        // getter

        // marker = 0
        rtpPacket.header.flags = 0b0000_0000_0000_0000
        XCTAssertEqual(UInt8(0), rtpPacket.header.marker, "0 -> wrong marker \(rtpPacket.header.marker)")

        // marker = 1
        rtpPacket.header.flags = 0b0000_0000_1000_0000
        XCTAssertEqual(UInt8(1), rtpPacket.header.marker, "1 -> wrong marker \(rtpPacket.header.marker)")

        // setter

        rtpPacket.header.marker = 0
        XCTAssertEqual(UInt16(0b0000_0000_0000_0000), rtpPacket.header.flags, "")

        rtpPacket.header.marker = 1
        XCTAssertEqual(UInt16(0b0000_0000_1000_0000), rtpPacket.header.flags, "")
    }

    ///
    func testPayloadType() {

        var rtpPacket = RTPPacket()

        // getter

        for i in 0...0x7F {
            // println("testing payloadType: \(i)")

            // payloadType = i
            rtpPacket.header.flags = UInt16(0b0000_0000_0001 << 8) + UInt16(i)
            XCTAssertEqual(UInt8(i), rtpPacket.header.payloadType, "\(i) -> wrong payloadType \(rtpPacket.header.payloadType)")
        }

        // setter

        for i in 0...0x7F { 0
            // println("testing payloadType: \(i)")

            // payloadType = i
            rtpPacket.header.payloadType = UInt8(i)
            XCTAssertEqual(UInt16((0b0000_0000_0001 << 8) + i), rtpPacket.header.flags, "")
        }
    }

}

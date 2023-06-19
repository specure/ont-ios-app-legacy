//
//  RMBTThroughputHistoryTest.swift
//  RMBT
//
//  Created by Benjamin Pucher on 11.12.14.
//  Copyright © 2014 SPECURE GmbH. All rights reserved.
//

import XCTest

@testable import RMBTClient

// #define T(msec) ((uint64_t)(msec * NSEC_PER_MSEC))
func T(_ msec: UInt64) -> UInt64 {
    return msec * NSEC_PER_MSEC
}

///
class RMBTThroughputHistoryTest: XCTestCase {

    ///
    override func setUp() {
        super.setUp()
    }

    ///
    override func tearDown() {
        super.tearDown()
    }

    ///
    func testSpread() {
        // One block = 250ms
        let h = RMBTThroughputHistory(resolutionNanos: T(250))

        XCTAssertEqual(h.totalThroughput.endNanos, T(0))

        // Transfer 10 kilobit in one second
        h.addLength(1250, atNanos: T(1000))

        // Assert correct total throughput
        XCTAssertEqual(h.totalThroughput.endNanos, T(1000))
        XCTAssertTrue(h.totalThroughput.kilobitsPerSecond() == 10)

        // Assert correct period division
        XCTAssertEqual(h.periods.count, 4)

        // ..and bytes per period (note that 1250 isn't divisible by 4)
        for i in 0..<3 {
            XCTAssertEqual(h.periods[i].length, UInt64(312))
        }

        XCTAssertEqual(h.periods[3].length, UInt64(314))
    }

    ///
    func testBoundaries() {
        let h = RMBTThroughputHistory(resolutionNanos: T(1000))
        XCTAssertEqual(h.lastFrozenPeriodIndex, -1)

        h.addLength(1050, atNanos: T(1050))
        XCTAssertEqual(h.lastFrozenPeriodIndex, 0)

        h.addLength(150, atNanos: T(1200))
        XCTAssertEqual(h.lastFrozenPeriodIndex, 0)
        XCTAssertEqual(h.periods.count, 2)
        XCTAssertEqual(h.totalThroughput.endNanos, T(1200))
        XCTAssertEqual(h.periods.last!.endNanos, T(1200))

        h.addLength(800, atNanos: T(2000))
        XCTAssertEqual(h.lastFrozenPeriodIndex, 0)
        XCTAssertEqual(h.periods.count, 2)

        XCTAssertEqual(h.periods[0].length, UInt64(1000))
        XCTAssertEqual(h.periods[1].length, UInt64(1000))

        h.addLength(1000, atNanos: T(3000))

        XCTAssertEqual(h.lastFrozenPeriodIndex, 1)
        XCTAssertEqual(h.periods.count, 3)

        XCTAssertEqual(h.periods.last!.startNanos, T(2000))
        XCTAssertEqual(h.periods.last!.endNanos, T(3000))
        XCTAssertEqual(h.periods[2].length, UInt64(1000))
    }

    ///
    func testFreeze() {
        let h = RMBTThroughputHistory(resolutionNanos: T(1000))
        h.addLength(1024, atNanos: T(500))
        XCTAssertEqual(h.lastFrozenPeriodIndex, -1)
        XCTAssertEqual(h.periods.last!.endNanos, T(500))
        h.freeze()
        XCTAssertEqual(h.lastFrozenPeriodIndex, 0)
        XCTAssertEqual(h.periods.last!.endNanos, T(500))
    }

    ///
    func testSquash1() {
        let h = RMBTThroughputHistory(resolutionNanos: T(1000))
        h.addLength(1000, atNanos: T(500))
        h.addLength(1000, atNanos: T(1000))

        h.addLength(1000, atNanos: T(1500))
        h.addLength(1000, atNanos: T(2000))

        h.addLength(1000, atNanos: T(2500))
        h.addLength(1000, atNanos: T(3000))

        h.freeze()

        XCTAssertEqual(h.periods.count, 3)
        h.squashLastPeriods(1)

        XCTAssertEqual(h.periods.count, 2)
        XCTAssertEqual(h.periods.last!.endNanos, T(3000))
        XCTAssertEqual(h.periods.last!.length, UInt64(4000))
    }

    ///
    func testSquash2() {
        let h = RMBTThroughputHistory(resolutionNanos: T(1000))
        h.addLength(1000, atNanos: T(500))
        h.addLength(1000, atNanos: T(1000))

        h.addLength(1000, atNanos: T(1500))
        h.addLength(1000, atNanos: T(2000))

        h.addLength(1000, atNanos: T(2500))
        h.addLength(1000, atNanos: T(3000))

        h.freeze()

        XCTAssertEqual(h.periods.count, 3)
        h.squashLastPeriods(2)

        XCTAssertEqual(h.periods.count, 1)
        XCTAssertEqual(h.periods.last!.endNanos, T(3000))
        XCTAssertEqual(h.periods.last!.length, UInt64(6000))
    }

}

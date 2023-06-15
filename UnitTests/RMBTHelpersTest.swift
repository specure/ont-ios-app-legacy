//
//  RMBTHelpersTest.swift
//  RMBT
//
//  Created by Benjamin Pucher on 11.12.14.
//  Copyright © 2014 SPECURE GmbH. All rights reserved.
//

import XCTest

@testable import RMBTClient

///
class RMBTHelpersTest: XCTestCase {

    ///
    override func setUp() {
        super.setUp()
    }

    ///
    override func tearDown() {
        super.tearDown()
    }

    ///
    func testBSSIDConversion() {
        XCTAssertEqual(RMBTReformatHexIdentifier("0:0:fb:1"), "00:00:fb:01")
        XCTAssertEqual(RMBTReformatHexIdentifier("hello"), "hello")
        XCTAssertEqual(RMBTReformatHexIdentifier("::FF:1"), "00:00:FF:01")
    }

}

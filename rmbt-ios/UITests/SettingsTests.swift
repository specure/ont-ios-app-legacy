//
//  SettingsTests.swift
//  RMBT
//
//  Created by Benjamin Pucher on 24.08.15.
//  Copyright © 2015 Specure GmbH. All rights reserved.
//

import XCTest

class SettingsTests: XCTestCase {

    override func setUp() {
        super.setUp()

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func test01OpenInfo() {
        let app = XCUIApplication()

        app.navigationBars["RMBT.RMBTInitialView"].buttons["reveal icon"].tap()
        app.buttons["ic action settings"].tap()

        // TODO: this test currently doesn't test anything, just checks if the app doesn't crash
    }

}

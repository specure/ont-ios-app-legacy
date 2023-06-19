//
//  SpeedtestTests.swift
//  RMBT
//
//  Created by Benjamin Pucher on 24.08.15.
//  Copyright © 2015 Specure GmbH. All rights reserved.
//

import XCTest

class SpeedtestTests: XCTestCase {

    override func setUp() {
        super.setUp()

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // tap allow on location permission popup
        addUIInterruptionMonitorWithDescription("Location Dialog") { (alert) -> Bool in
            if alert.label == "Location Prompt" {
                alert.buttons["Allow"].tap()
                return true
            }

            return false
        }
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func test01RunTest() {
        let app = XCUIApplication()

        app.buttons["START"].tap()

        ///
        let testPredicate = NSPredicate(format: "exists == 1")
        let object = app.navigationBars.elementMatchingType(.Any, identifier: "Test Result")

        expectationForPredicate(testPredicate, evaluatedWithObject: object, handler: nil)
        waitForExpectationsWithTimeout(60, handler: nil)
        ///

        app.navigationBars["Test Result"].childrenMatchingType(.Button).matchingIdentifier("Back").elementBoundByIndex(0).tap()
    }

    func test02AbortRunningTest() {
        let app = XCUIApplication()

        app.buttons["START"].tap()

        sleep(10) // not perfect but working...

        app.childrenMatchingType(.Window).elementBoundByIndex(0).childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.tap()
        app.alerts["NetTest"].collectionViews.buttons["Abort Test"].tap()

        // TODO: test for start screen visible again!
    }

    func test03AbortRunningTestMultipleTimes() {
        let app = XCUIApplication()

        app.buttons["START"].tap()

        sleep(10) // not perfect but working...

        app.childrenMatchingType(.Window).elementBoundByIndex(0).childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.tap()
        app.alerts["NetTest"].collectionViews.buttons["Continue"].tap() // continue

        sleep(10) // not perfect but working...

        app.childrenMatchingType(.Window).elementBoundByIndex(0).childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.tap()
        app.alerts["NetTest"].collectionViews.buttons["Abort Test"].tap() // abort

        // TODO: test for start screen visible again!
    }

    func test04DontAbortRunningTest() {
        let app = XCUIApplication()

        app.buttons["START"].tap()

        sleep(10) // not perfect but working...

        app.childrenMatchingType(.Window).elementBoundByIndex(0).childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.tap()
        app.alerts["NetTest"].collectionViews.buttons["Continue"].tap()

        ///
        let testPredicate = NSPredicate(format: "exists == 1")
        let object = app.navigationBars.elementMatchingType(.Any, identifier: "Test Result")

        expectationForPredicate(testPredicate, evaluatedWithObject: object, handler: nil)
        waitForExpectationsWithTimeout(60, handler: nil)
        ///

        app.navigationBars["Test Result"].childrenMatchingType(.Button).matchingIdentifier("Back").elementBoundByIndex(0).tap()
    }

    func test05DontAbortRunningTestMultipleTimes() {
        let app = XCUIApplication()

        app.buttons["START"].tap()

        sleep(10) // not perfect but working...

        app.childrenMatchingType(.Window).elementBoundByIndex(0).childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.tap()
        app.alerts["NetTest"].collectionViews.buttons["Continue"].tap()

        sleep(10) // not perfect but working...

        app.childrenMatchingType(.Window).elementBoundByIndex(0).childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.tap()
        app.alerts["NetTest"].collectionViews.buttons["Continue"].tap()

        ///
        let testPredicate = NSPredicate(format: "exists == 1")
        let object = app.navigationBars.elementMatchingType(.Any, identifier: "Test Result")

        expectationForPredicate(testPredicate, evaluatedWithObject: object, handler: nil)
        waitForExpectationsWithTimeout(60, handler: nil)
        ///

        app.navigationBars["Test Result"].childrenMatchingType(.Button).matchingIdentifier("Back").elementBoundByIndex(0).tap()
    }

/*    func test06HomeButtonPressDuringSpeedtest() {
        let app = XCUIApplication()

        app.buttons["START"].tap()

        sleep(10) // not perfect but working...

        XCUIDevice.sharedDevice().pressButton(XCUIDeviceButton.Home)
    }
*/
}

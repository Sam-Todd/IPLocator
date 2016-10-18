//
//  IPLocatorErrorUITests.swift
//  IPLocator
//
//  Created by Samantha Todd on 10/9/16.
//  Copyright © 2016 Samantha Todd. All rights reserved.
//

import XCTest

class IPLocatorErrorUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testRangeAndFormatErrors() {
        // Use recording to get started writing UI tests.
        // Basically try entering invalid IP addresses and a start address that is greater than an IP address. Verify that error alerts are shown.
        let app = XCUIApplication()
        app.launch()
        
        // Bad format
        let startIPTextField = app.textFields["startIPTextField"]
        startIPTextField.tap()
        startIPTextField.typeText("1.2.3.")
        
        let endIPTextField = app.textFields["endIPTextField"]
        endIPTextField.tap()
        endIPTextField.typeText("1.2.3.4")
        app.buttons["Locate"].tap()
        
        // error should pop up; if it doesn't this will fail because we can't tap it.
        app.alerts["Error"].buttons["OK"].tap()
        
        // Move on to range error.
        startIPTextField.tap()
        startIPTextField.typeText("5")
        app.buttons["Locate"].tap()
        app.alerts["Error"].buttons["OK"].tap()
    }
    
}

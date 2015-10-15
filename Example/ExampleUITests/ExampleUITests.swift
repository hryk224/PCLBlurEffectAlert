//
//  ExampleUITests.swift
//  ExampleUITests
//
//  Created by yoshida hiroyuki on 2015/10/15.
//  Copyright © 2015年 yoshida hiroyuki. All rights reserved.
//

import XCTest

class ExampleUITests: XCTestCase {
        
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
    
    func testExample() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let app = XCUIApplication()
        let tablesQuery = app.tables
        tablesQuery.childrenMatchingType(.Cell).elementBoundByIndex(0).staticTexts["sample1"].tap()
        app.buttons["yes"].tap()
        tablesQuery.childrenMatchingType(.Cell).elementBoundByIndex(1).staticTexts["sample2"].tap()
        
        let no1Button = app.buttons["No.1"]
        no1Button.tap()
        tablesQuery.childrenMatchingType(.Cell).elementBoundByIndex(2).staticTexts["sample3"].tap()
        
        let no2Button = app.buttons["No.2"]
        no2Button.tap()
        
        let sample4StaticText = tablesQuery.childrenMatchingType(.Cell).elementBoundByIndex(3).staticTexts["sample4"]
        sample4StaticText.tap()
        no1Button.tap()
        tablesQuery.childrenMatchingType(.Cell).elementBoundByIndex(4).staticTexts["sample5"].tap()
        no1Button.tap()
        sample4StaticText.tap()
        
    }
    
    func testExample2() {
        
        
        let app = XCUIApplication()
        let tablesQuery = app.tables
        tablesQuery.childrenMatchingType(.Cell).elementBoundByIndex(5).staticTexts["sample1"].tap()
        app.buttons["yes"].tap()
        tablesQuery.childrenMatchingType(.Cell).elementBoundByIndex(6).staticTexts["sample2"].tap()
        
        let no1Button = app.buttons["No.1"]
        no1Button.tap()
        tablesQuery.childrenMatchingType(.Cell).elementBoundByIndex(7).staticTexts["sample3"].tap()
        app.childrenMatchingType(.Window).elementBoundByIndex(0).childrenMatchingType(.Other).elementBoundByIndex(1).childrenMatchingType(.Other).element.tap()
        tablesQuery.childrenMatchingType(.Cell).elementBoundByIndex(8).staticTexts["sample4"].tap()
        no1Button.tap()
        tablesQuery.childrenMatchingType(.Cell).elementBoundByIndex(9).staticTexts["sample5"].tap()
        no1Button.tap()
        
        
    }
    
}

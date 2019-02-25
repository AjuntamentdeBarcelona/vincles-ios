//
//  AlphaButtonTests.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.



import XCTest
@testable import VinclesDev

class AlphaButtonTests: XCTestCase {
    
    var alphaButton = AlphaButton()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testButtonTransparentIfDisabled(){
        alphaButton.isEnabled = false
        XCTAssertEqual(alphaButton.alpha, 0.5)
    }
    
    func testButtonSolidIfEnabled(){
        alphaButton.isEnabled = true
        XCTAssertEqual(alphaButton.alpha, 1)
    }
}

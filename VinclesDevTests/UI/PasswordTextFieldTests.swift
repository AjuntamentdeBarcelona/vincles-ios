//
//  PasswordTextFieldTests.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.


import XCTest
@testable import VinclesDev

class PasswordTextFieldTests: XCTestCase {
    
    var textField = PasswordTextField()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testTextFieldIsNotValidIfEmpty(){
        textField.text = ""
        XCTAssert(!textField.isValid)
    }
    
    func testTextFieldIsNotValidIfShort(){
        textField.text = "test"
        XCTAssert(!textField.isValid)
    }
    
    func testTextFieldIValidIfGoodFormatted(){
        textField.text = "ValidPassword"
        XCTAssert(textField.isValid)
    }
}

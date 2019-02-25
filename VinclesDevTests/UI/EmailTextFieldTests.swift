//
//  EmailTextFieldTests.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.



import XCTest
@testable import VinclesDev


class EmailTextFieldTests: XCTestCase {
    
    var textField = EmailTextField()
    
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
  
    func testTextFieldIsNotValidIfBadFormatted(){
        textField.text = "testInvalidEmail"
        XCTAssert(!textField.isValid)
    }
    
    func testTextFieldIValidIfGoodFormatted(){
        textField.text = "test@validemail.com"
        XCTAssert(textField.isValid)
    }
    
}

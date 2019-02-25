//
//  RegisterValidateApiClientTests.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.



import XCTest
import OHHTTPStubs
@testable import VinclesDev

class RegisterValidateApiClientTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testValidateSuccess() {
        
        stub(condition: isHost(IP)) { _ in
            let stubPath = OHPathForFile("RegisterResponseSuccess.json", type(of: self))
            return fixture(filePath: stubPath!, status: 201, headers: ["Content-Type":"application/json"])
        }
        
        let expectation = self.expectation(description: "calls the callback with a resource object")
        
        ApiClient.validateRegister(username: "XXX", code: "XXX", onSuccess: { (responseDict) in
            XCTAssertNotNil(responseDict["id"])
            expectation.fulfill()
        }) { (error) in
        
        }
        self.waitForExpectations(timeout: 0.3, handler: .none)
        OHHTTPStubs.removeAllStubs()
        
    }
    
    
    func testReturnsError() {
        let errorSimulated = NSError(domain: "error", code: 404, userInfo: nil)
        
        stub(condition: isHost(IP)) { _ in
            return OHHTTPStubsResponse(error:errorSimulated)
        }
        
        let expectation = self.expectation(description: "calls the error callback")
        
        ApiClient.validateRegister(username: "XXX", code: "XXX", onSuccess: { (responseDict) in
           
        }) { (error) in
            XCTAssertNotNil(error)
            expectation.fulfill()
        }
    
        self.waitForExpectations(timeout: 0.3, handler: .none)
        OHHTTPStubs.removeAllStubs()
        
    }
    
}



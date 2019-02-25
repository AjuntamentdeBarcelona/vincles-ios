//
//  LogoutApiClientTests.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.


import XCTest
import OHHTTPStubs
@testable import VinclesDev

class LogoutApiClientTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testLogoutSuccess() {
        
        stub(condition: isHost(IP)) { _ in
            let stubData = "".data(using: String.Encoding.utf8)
            return OHHTTPStubsResponse(data: stubData!, statusCode:200, headers:nil)
        }
        
        let expectation = self.expectation(description: "calls the callback with a resource object")
        
        ApiClient.logoutWith(token: "CCC", onSuccess: {
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
        
        ApiClient.logoutWith(token: "CCC", onSuccess: {
        }) { (error) in
            XCTAssertNotNil(error)
            expectation.fulfill()
        }

        self.waitForExpectations(timeout: 0.3, handler: .none)
        OHHTTPStubs.removeAllStubs()
        
    }
    
}




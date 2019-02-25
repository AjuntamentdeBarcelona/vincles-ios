//
//  AuthResponseTests.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.


import XCTest
import SwiftyJSON
@testable import VinclesDev

class AuthResponseTests: XCTestCase {
    func testAddAuthResponseNotNil() {
        let bundle = Bundle.init(for: AuthResponseTests.self)
        
        let url = bundle.url(forResource: "AuthResponse", withExtension: "json")!
        let expectation = self.expectation(description: "calls the callback with a resource object")
        
        do {
            let jsonData = try Data(contentsOf: url)
            let json = try JSON(data: jsonData as Data)
            
            let authResponse = AuthResponse(json: json)
            XCTAssertNotNil(authResponse)
            expectation.fulfill()
            
        }
        catch {
            print(error)
        }
        
        self.waitForExpectations(timeout: 0.3, handler: .none)
        
    }
    
    func testAddAuthResponseHasId() {
        let bundle = Bundle.init(for: AuthResponseTests.self)
        
        let url = bundle.url(forResource: "AuthResponse", withExtension: "json")!
        
        let expectation = self.expectation(description: "calls the callback with a resource object")
        
        do {
            let jsonData = try Data(contentsOf: url)
            let json = try JSON(data: jsonData as Data)
            
            let authResponse = AuthResponse(json: json)

            XCTAssertNotEqual(authResponse.access_token, "")
            expectation.fulfill()
            
        }
        catch {
            print(error)
        }
        
        self.waitForExpectations(timeout: 0.3, handler: .none)
        
    }
    
    func testAddAuthResponseBadIdEquals0() {
        let bundle = Bundle.init(for: AuthResponseTests.self)
        
        let url = bundle.url(forResource: "AuthResponseBad", withExtension: "json")!
        
        let expectation = self.expectation(description: "calls the callback with a resource object")
        
        do {
            let jsonData = try Data(contentsOf: url)
            let json = try JSON(data: jsonData as Data)
            
            let authResponse = AuthResponse(json: json)
            
            XCTAssertEqual(authResponse.access_token, "")
            expectation.fulfill()
            
        }
        catch {
            print(error)
        }
        
        self.waitForExpectations(timeout: 0.3, handler: .none)
        
    }
    
}

//
//  CirclesManagerTests.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.


import XCTest
import SwiftyJSON
@testable import VinclesDev

class UserTests: XCTestCase {
   
    func testAddUserNotNil() {
        let bundle = Bundle.init(for: UserTests.self)

        let url = bundle.url(forResource: "User", withExtension: "json")!
        let expectation = self.expectation(description: "calls the callback with a resource object")

        do {
            let jsonData = try Data(contentsOf: url)
            let json = try JSON(data: jsonData as Data)

            let user = User(json: json)
            XCTAssertNotNil(user)
            expectation.fulfill()

        }
        catch {
            print(error)
        }
        
        self.waitForExpectations(timeout: 0.3, handler: .none)

    }

    func testAddUserHasId() {
        let bundle = Bundle.init(for: UserTests.self)
        
        let url = bundle.url(forResource: "User", withExtension: "json")!
        
        let expectation = self.expectation(description: "calls the callback with a resource object")

        do {
            let jsonData = try Data(contentsOf: url)
            let json = try JSON(data: jsonData as Data)
            
            let user = User(json: json)

            XCTAssertEqual(user.id, 100)
            expectation.fulfill()

        }
        catch {
            print(error)
        }
        
        self.waitForExpectations(timeout: 0.3, handler: .none)

    }
    
    func testAddUserBadIdEquals0() {
        let bundle = Bundle.init(for: UserTests.self)
        
        let url = bundle.url(forResource: "UserBad", withExtension: "json")!
        
        let expectation = self.expectation(description: "calls the callback with a resource object")
        
        do {
            let jsonData = try Data(contentsOf: url)
            let json = try JSON(data: jsonData as Data)
            
            let user = User(json: json)
            
            XCTAssertEqual(user.id, 0)
            expectation.fulfill()
            
        }
        catch {
            print(error)
        }
        
        self.waitForExpectations(timeout: 0.3, handler: .none)
        
    }
}

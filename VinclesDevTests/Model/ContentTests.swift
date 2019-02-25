//
//  ContentTests.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.


import XCTest
import SwiftyJSON
@testable import VinclesDev

class ContentTests: XCTestCase {
    
    func testAddContentNotNil() {
        let bundle = Bundle.init(for: UserTests.self)
        
        let url = bundle.url(forResource: "Content", withExtension: "json")!
        let expectation = self.expectation(description: "calls the callback with a resource object")
        
        do {
            let jsonData = try Data(contentsOf: url)
            let json = try JSON(data: jsonData as Data)
            
            let content = Content(json: json)
            XCTAssertNotNil(content)
            expectation.fulfill()
            
        }
        catch {
            print(error)
        }
        
        self.waitForExpectations(timeout: 0.3, handler: .none)
        
    }
    
    func testAddContentHasId() {
        let bundle = Bundle.init(for: UserTests.self)
        
        let url = bundle.url(forResource: "Content", withExtension: "json")!
        
        let expectation = self.expectation(description: "calls the callback with a resource object")
        
        do {
            let jsonData = try Data(contentsOf: url)
            let json = try JSON(data: jsonData as Data)
            
            let content = Content(json: json)

            XCTAssertEqual(content.id, 5196)
            expectation.fulfill()
            
        }
        catch {
            print(error)
        }
        
        self.waitForExpectations(timeout: 0.3, handler: .none)
        
    }
    
    func testAddContentBadIdEquals0() {
        let bundle = Bundle.init(for: UserTests.self)
        
        let url = bundle.url(forResource: "ContentBad", withExtension: "json")!
        
        let expectation = self.expectation(description: "calls the callback with a resource object")
        
        do {
            let jsonData = try Data(contentsOf: url)
            let json = try JSON(data: jsonData as Data)
            
            let content = Content(json: json)

            XCTAssertEqual(content.id, 0)
            expectation.fulfill()
            
        }
        catch {
            print(error)
        }
        
        self.waitForExpectations(timeout: 0.3, handler: .none)
        
    }
}


//
//  CirclesManagerTests.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.


import XCTest
import SwiftyJSON
@testable import VinclesDev

class GroupTests: XCTestCase {
   
    func testAddGroupNotNil() {
        let bundle = Bundle.init(for: UserTests.self)

        let url = bundle.url(forResource: "Group", withExtension: "json")!
        let expectation = self.expectation(description: "calls the callback with a resource object")

        do {
            let jsonData = try Data(contentsOf: url)
            let json = try JSON(data: jsonData as Data)

            let group = Group(json: json)
            XCTAssertNotNil(group)
            expectation.fulfill()

        }
        catch {
            print(error)
        }
        
        self.waitForExpectations(timeout: 0.3, handler: .none)

    }

    func testAddGroupHasId() {
        let bundle = Bundle.init(for: UserTests.self)
        
        let url = bundle.url(forResource: "Group", withExtension: "json")!
        
        let expectation = self.expectation(description: "calls the callback with a resource object")

        do {
            let jsonData = try Data(contentsOf: url)
            let json = try JSON(data: jsonData as Data)
             let dict = json.dictionaryObject
            if let groupDict = dict!["group"] as? [String:AnyObject], let idDynamizerChat = dict!["idDynamizerChat"] as? Int{
                    let group = Group(json: JSON(groupDict), idDynChat: idDynamizerChat)
                    XCTAssertEqual(group.id, 100)
                    expectation.fulfill()
                }
            
           
         

        }
        catch {
            print(error)
        }
        
        self.waitForExpectations(timeout: 0.3, handler: .none)

    }
    
    func testAddGroupHasDynamizer() {
        let bundle = Bundle.init(for: UserTests.self)
        
        let url = bundle.url(forResource: "Group", withExtension: "json")!
        
        let expectation = self.expectation(description: "calls the callback with a resource object")
        
        do {
            let jsonData = try Data(contentsOf: url)
            let json = try JSON(data: jsonData as Data)
            let dict = json.dictionaryObject
            if let groupDict = dict!["group"] as? [String:AnyObject], let idDynamizerChat = dict!["idDynamizerChat"] as? Int{
                let group = Group(json: JSON(groupDict), idDynChat: idDynamizerChat)
                XCTAssertEqual(group.dynamizer?.id, 84)
                expectation.fulfill()
            }
            
            
            
            
        }
        catch {
            print(error)
        }
        
        self.waitForExpectations(timeout: 0.3, handler: .none)
        
    }
    
    func testAddGroupBadIdEquals0() {
        let bundle = Bundle.init(for: UserTests.self)
        
        let url = bundle.url(forResource: "GroupBad", withExtension: "json")!
        
        let expectation = self.expectation(description: "calls the callback with a resource object")
        
        do {
            let jsonData = try Data(contentsOf: url)
            let json = try JSON(data: jsonData as Data)
            
            let group = Group(json: json)

            XCTAssertEqual(group.id, 0)
            expectation.fulfill()
            
        }
        catch {
            print(error)
        }
        
        self.waitForExpectations(timeout: 0.3, handler: .none)
        
    }
    
    func testAddGroupBadDynamizerIdEquals0() {
        let bundle = Bundle.init(for: UserTests.self)
        
        let url = bundle.url(forResource: "GroupBad", withExtension: "json")!
        
        let expectation = self.expectation(description: "calls the callback with a resource object")
        
        do {
            let jsonData = try Data(contentsOf: url)
            let json = try JSON(data: jsonData as Data)
            
            let group = Group(json: json)
            
            XCTAssertEqual(group.dynamizer?.id, 0)
            expectation.fulfill()
            
        }
        catch {
            print(error)
        }
        
        self.waitForExpectations(timeout: 0.3, handler: .none)
        
    }
}

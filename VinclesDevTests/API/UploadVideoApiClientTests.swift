//
//  UploadVideoApiClientTests.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.



import XCTest
import OHHTTPStubs
@testable import VinclesDev


class UploadVideoApiClientTests: XCTestCase {
    
    func testUploadVideoSuccess() {
        
        stub(condition: isHost(IP)) { _ in
            // Stub it with our "wsresponse.json" stub file (which is in same bundle as self)
            let stubPath = OHPathForFile("UploadVideoResponseSuccess.json", type(of: self))
            return fixture(filePath: stubPath!, headers: ["Content-Type":"application/json"])
        }
        
        let expectation = self.expectation(description: "calls the callback with a resource object")
        
        let bundle = Bundle.init(for: UploadVideoApiClientTests.self)
        let fileURL = bundle.url(forResource:"aurora", withExtension: "mp4")

        do {
            let data = try Data(contentsOf: fileURL!)
            ApiClient.uploadVideo(videoData: data, onSuccess: { (responseDict) in
                
                XCTAssertNotNil(responseDict["id"])
                expectation.fulfill()
                
                
            }) { (error) in
                
            }
        } catch  {
            
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
        
        let bundle = Bundle.init(for: UploadVideoApiClientTests.self)
        let fileURL = bundle.url(forResource:"aurora", withExtension: "mp4")
        
        do {
            let data = try Data(contentsOf: fileURL!)
            ApiClient.uploadVideo(videoData: data, onSuccess: { (responseDict) in
          
            }) { (error) in
                XCTAssertNotNil(error)
                expectation.fulfill()
            }
        } catch  {
            
        }
        
      
        
        self.waitForExpectations(timeout: 0.3, handler: .none)
        OHHTTPStubs.removeAllStubs()
        
    }
    
}

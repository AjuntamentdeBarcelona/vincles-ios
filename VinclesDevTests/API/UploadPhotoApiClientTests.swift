//
//  UploadPhotoApiClientTests.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.



import XCTest
import OHHTTPStubs
@testable import VinclesDev

class UploadPhotoApiClientTests: XCTestCase {
    
    func testUploadPhotoSuccess() {
        
        stub(condition: isHost(IP)) { _ in
            // Stub it with our "wsresponse.json" stub file (which is in same bundle as self)
            let stubPath = OHPathForFile("UploadPhotoResponseSuccess.json", type(of: self))
            return fixture(filePath: stubPath!, headers: ["Content-Type":"application/json"])
        }
        
        let expectation = self.expectation(description: "calls the callback with a resource object")
        
        let bundle = Bundle.init(for: UploadPhotoApiClientTests.self)
        let image = UIImage(named: "man.jpg", in: bundle, compatibleWith: nil)

        if let data = UIImageJPEGRepresentation(image!, 0.5){
            ApiClient.uploadImage(imageData: data, onSuccess: { (responseDict) in
                
                XCTAssertNotNil(responseDict["id"])
                expectation.fulfill()

              
            }) { (error) in
                
            }
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
                
        let bundle = Bundle.init(for: UploadPhotoApiClientTests.self)
        let image = UIImage(named: "man.jpg", in: bundle, compatibleWith: nil)
        
        if let data = UIImageJPEGRepresentation(image!, 0.5){
            ApiClient.uploadImage(imageData: data, onSuccess: { (responseDict) in
                

            }) { (error) in
                XCTAssertNotNil(error)
                expectation.fulfill()
            }
        }
        
        self.waitForExpectations(timeout: 0.3, handler: .none)
        OHHTTPStubs.removeAllStubs()
        
    }
}

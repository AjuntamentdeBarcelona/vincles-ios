//
//  ContactsGroupsDataSourceTests.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.


import XCTest
@testable import VinclesDev
import SwiftyJSON

class ContactsGroupsDataSourceTests: XCTestCase {
    
    var myDelegateDatasource: ContactsGroupsDataSource!
    var collectionView: UICollectionView!
    var circlesManagerTest: CirclesManagerTest!
    var profileManagerTest: ProfileManagerTest!
    var userVincles: User?
    var userVinculat: User?

    
    override func setUp() {
        super.setUp()
        myDelegateDatasource = ContactsGroupsDataSource()
        circlesManagerTest = CirclesManagerTest()
        profileManagerTest = ProfileManagerTest()

        myDelegateDatasource.circlesGroupsModelManager = circlesManagerTest
        myDelegateDatasource.profileModelManager = profileManagerTest

        collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout.init())
        collectionView.dataSource = myDelegateDatasource
        collectionView.delegate = myDelegateDatasource
        collectionView.register(ContactCollectionViewCell.self, forCellWithReuseIdentifier: "contactCell")
        
        collectionView.setCollectionViewLayout(UICollectionViewFlowLayout(), animated: false)
        
        let bundle = Bundle.init(for: UserTests.self)
        
        let urlUserVincles = bundle.url(forResource: "UserResponse", withExtension: "json")!
        
        do {
            let jsonData = try Data(contentsOf: urlUserVincles)
            let json = try JSON(data: jsonData as Data)
            userVincles = User(json: json)
        }
        catch {
            print(error)
        }
        
        let urlUserVinculat = bundle.url(forResource: "UserVinculatResponse", withExtension: "json")!
        
        do {
            let jsonData = try Data(contentsOf: urlUserVinculat)
            let json = try JSON(data: jsonData as Data)
            userVinculat = User(json: json)
        }
        catch {
            print(error)
        }
        
        let urlCircles = bundle.url(forResource: "CirclesResponse", withExtension: "json")!
        
        do {
            let jsonData = try Data(contentsOf: urlCircles)
            let json = try JSONSerialization.jsonObject(with: jsonData, options: [])
            if let object = json as? [[String: AnyObject]] {
                circlesManagerTest.addCircles(array: object)
            }
            
        }
        catch {
            print(error)
        }
        
        let urlGroups = bundle.url(forResource: "GroupsResponse", withExtension: "json")!
        
        do {
            let jsonData = try Data(contentsOf: urlGroups)
            let json = try JSONSerialization.jsonObject(with: jsonData, options: [])
            if let object = json as? [[String: AnyObject]] {
                circlesManagerTest.addGroups(array: object)
            }
            
        }
        catch {
            print(error)
        }
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testNumberOfRowsIsCirclesIfUserVinculat() {
        profileManagerTest.user = userVinculat
        XCTAssertEqual(collectionView.numberOfItems(inSection: 0),circlesManagerTest.circles.count)
    }
    
    func testNumberOfRowsIsCirclesGroupsDinamsIfUserVincles() {
        profileManagerTest.user = userVincles
        
        XCTAssertEqual(collectionView.numberOfItems(inSection: 0),circlesManagerTest.circles.count + circlesManagerTest.groups.count + circlesManagerTest.dinamitzadors.count )
    }
    
    
    func testNumberOfSectionsIs1() {
        XCTAssertEqual(collectionView.numberOfSections,1)
    }
    
    func testUserVinclesIsNotNil() {
       XCTAssertNotNil(userVincles)
    }
    
    func testUserVinclulatIsNotNil() {
        XCTAssertNotNil(userVinculat)
    }
    
    func testCiclesAreAdded() {
        XCTAssert(circlesManagerTest.circles.count > 0)
    }
    
    func testGroupsAreAdded() {
        XCTAssert(circlesManagerTest.groups.count > 0)
    }
    
    func testDinamitzadorsAreAdded() {
        XCTAssert(circlesManagerTest.dinamitzadors.count > 0)
    }
}


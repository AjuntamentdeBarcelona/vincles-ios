//
//  GalleryContactsCollectionViewDataSourceTests.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.



import XCTest
@testable import VinclesDev
import SwiftyJSON

class GalleryContactsCollectionViewDataSourceTests: XCTestCase {
    
    var myDelegateDatasource: GalleryContactsCollectionViewDataSource!
    var collectionView: UICollectionView!
    var circlesManagerTest: CirclesManagerTest!
    var profileManagerTest: ProfileManagerTest!
    var userVincles: User?
    var userVinculat: User?
    
    
    override func setUp() {
        super.setUp()
        myDelegateDatasource = GalleryContactsCollectionViewDataSource()
        circlesManagerTest = CirclesManagerTest()
        profileManagerTest = ProfileManagerTest()
        
        myDelegateDatasource.circlesGroupsModelManager = circlesManagerTest
        
        collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout.init())
        collectionView.dataSource = myDelegateDatasource
        collectionView.delegate = myDelegateDatasource
        collectionView.register(ContactCollectionViewCell.self, forCellWithReuseIdentifier: "contactCell")
        
        collectionView.setCollectionViewLayout(UICollectionViewFlowLayout(), animated: false)
        
        let bundle = Bundle.init(for: GalleryContactsCollectionViewDataSourceTests.self)
        
        
        let urlCircles = bundle.url(forResource: "CirclesResponse", withExtension: "json")!
        
        do {
            let jsonData = try Data(contentsOf: urlCircles)
            let json = try JSONSerialization.jsonObject(with: jsonData, options: [])
            if let object = json as? [[String: AnyObject]] {
                _ = circlesManagerTest.addCircles(array: object)
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
    
    func testNumberOfRowsIsCircles() {
        XCTAssertEqual(collectionView.numberOfItems(inSection: 0),circlesManagerTest.circles.count)
    }
    
  
    
    func testNumberOfSectionsIs1() {
        XCTAssertEqual(collectionView.numberOfSections,1)
    }
    
   
    
    func testCiclesAreAdded() {
        XCTAssert(circlesManagerTest.circles.count > 0)
    }
    
    
    
}

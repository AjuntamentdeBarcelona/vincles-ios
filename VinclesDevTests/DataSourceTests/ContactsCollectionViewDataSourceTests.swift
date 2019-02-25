//
//  ContactsCollectionViewDataSourceTests.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.



import XCTest
@testable import VinclesDev
import SwiftyJSON

class ContactsCollectionViewDataSourceTests: XCTestCase {
    
    var myDelegateDatasource: ContactsCollectionViewDataSource!
    var collectionView: UICollectionView!
    var circlesManagerTest: CirclesManagerTest!
   
    override func setUp() {
        super.setUp()
        myDelegateDatasource = ContactsCollectionViewDataSource()
        circlesManagerTest = CirclesManagerTest()
        myDelegateDatasource.circlesManager = circlesManagerTest
        myDelegateDatasource.rows = 2
        myDelegateDatasource.columns = 3
        collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout.init())
        collectionView.dataSource = myDelegateDatasource
        collectionView.delegate = myDelegateDatasource
        collectionView.register(ContactCollectionViewCell.self, forCellWithReuseIdentifier: "contactCell")

        collectionView.setCollectionViewLayout(UICollectionViewFlowLayout(), animated: false)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testNumberOfRowsIsRowPerColumns() {
        XCTAssertEqual(collectionView.numberOfItems(inSection: 0),6)
    }
    
    func testNumberOfSectionsIs1() {
        XCTAssertEqual(collectionView.numberOfSections,1)
    }
    
    
}

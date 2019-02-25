//
//  GalleryCollectionViewDataSourceTests.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.



import XCTest
@testable import VinclesDev
import SwiftyJSON

class GalleryCollectionViewDataSourceTests: XCTestCase {
    
    var myDelegateDatasource: GalleryCollectionViewDataSource!
    var collectionView: UICollectionView!
    var galleryModelManager: GalleryModelManagerTest!
    var galleryFilter: FilterGalleryType = .all

    
    override func setUp() {
        super.setUp()
        myDelegateDatasource = GalleryCollectionViewDataSource()
        galleryModelManager = GalleryModelManagerTest()
        
        myDelegateDatasource.galleryModelManager = galleryModelManager
        myDelegateDatasource.galleryFilter = galleryFilter
        collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout.init())
        collectionView.dataSource = myDelegateDatasource
        collectionView.delegate = myDelegateDatasource
        collectionView.register(ContactCollectionViewCell.self, forCellWithReuseIdentifier: "contactCell")
        
        collectionView.setCollectionViewLayout(UICollectionViewFlowLayout(), animated: false)
        
        let bundle = Bundle.init(for: GalleryContactsCollectionViewDataSourceTests.self)
        
        
        let urlCircles = bundle.url(forResource: "GalleryResponse", withExtension: "json")!
        
        do {
            let jsonData = try Data(contentsOf: urlCircles)
            let json = try JSONSerialization.jsonObject(with: jsonData, options: [])
            if let object = json as? [[String: AnyObject]] {
                _ = galleryModelManager.addContents(array: object)
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
        XCTAssertEqual(collectionView.numberOfItems(inSection: 0),galleryModelManager.contents.count)
    }
    
    
    func testNumberOfRowsIsMineCirclesWhenMineFilter() {
        myDelegateDatasource.galleryFilter = .mine

        XCTAssertEqual(collectionView.numberOfItems(inSection: 0),galleryModelManager.numberOfMineContents)
    }
    
    func testNumberOfRowsIsSharedCirclesWhenSharedFilter() {
        myDelegateDatasource.galleryFilter = .sent
        
        XCTAssertEqual(collectionView.numberOfItems(inSection: 0),galleryModelManager.numberOfSharedContents)
    }
    
    func testNumberOfSectionsIs1() {
        XCTAssertEqual(collectionView.numberOfSections,1)
    }
    
    
    
    func testCiclesAreAdded() {
        XCTAssert(galleryModelManager.contents.count > 0)
    }
    
    
}

//
//  GalleryModelManagerTest.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.


import UIKit
@testable import VinclesDev
import SwiftyJSON

class GalleryModelManagerTest: GalleryModelManagerProtocol {
    
    var userId = 0
    
    var contents = [Content]()
    
    var numberOfContents: Int{
        return contents.count
    }
    
    var numberOfMineContents: Int{
        return contents.filter { $0.userCreator!.id == userId }.count
    }
    
    var numberOfSharedContents: Int{
        return contents.filter { $0.userCreator!.id != userId }.count
    }
    
    func contentAt(index: Int) -> Content {
        return contents[index]
    }
    
    func mineContentAt(index: Int) -> Content {
        return contents.filter { $0.userCreator!.id == userId }[index]

    }
    
    func sharedContentAt(index: Int) -> Content {
        return contents.filter { $0.userCreator!.id != userId }[index]

    }
    
    func newestContentDate() -> Date? {
        return Date()
    }
    
    func removeUserContents() {
        
    }
    
    func addContents(array: [[String : Any]]) -> (Date?, Bool) {

        for dict in array{
            let content = Content(json: JSON(dict))
            contents.append(content)
        }
        
        return (Date(),true)
    }
    
    func removeUnexistingContentItems(from: Date, to: Date, apiItems: [Int]) -> Bool {
        return true
    }
    
    func removeContentItem(id: Int) {
        let content = contents.filter{ $0.id == id }.first
        contents.remove(at: contents.index(of: content!)!)
    }
    
    func createImageContent(id: Int) {
        
    }
    
    func createVideoContent(id: Int) {
        
    }
    

}

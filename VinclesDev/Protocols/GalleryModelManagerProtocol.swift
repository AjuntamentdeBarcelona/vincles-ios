//
//  GalleryModelManagerProtocol.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.



import UIKit

protocol GalleryModelManagerProtocol {
    var numberOfContents: Int {get}
    var numberOfMineContents: Int {get}
    var numberOfSharedContents: Int {get}
    func contentAt(index: Int) -> Content
    func mineContentAt(index: Int) -> Content
    func sharedContentAt(index: Int) -> Content
    func newestContentDate() -> Date?
    func removeUserContents()
    func addContents(array: [[String:Any]]) -> (Date?, Bool)
    func removeUnexistingContentItems(from: Date, to: Date, apiItems: [Int]) -> Bool
    func removeContentItem(id: Int)
    func createImageContent(id: Int, idContent: Int)
    func createVideoContent(id: Int, idContent: Int)
}

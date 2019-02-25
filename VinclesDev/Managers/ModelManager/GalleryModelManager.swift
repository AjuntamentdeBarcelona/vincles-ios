//
//  GalleryModelManager.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.


import UIKit
import RealmSwift
import SwiftyJSON

class GalleryModelManager: GalleryModelManagerProtocol {
    // MARK: contents
    var numberOfContents: Int{
        let realm = try! Realm()
       
        if let user = realm.objects(User.self).first{
            return user.contents.count
        }
        
        return 0
    }
    
    var numberOfMineContents: Int{
        let realm = try! Realm()
        
        if let user = realm.objects(User.self).first{
            return user.contents.filter("userCreator.id = %i", user.id).count
        }
        
        return 0
    }
    
    var numberOfSharedContents: Int{
        let realm = try! Realm()
        
        if let user = realm.objects(User.self).first{
            return user.contents.filter("userCreator.id != %i", user.id).count
        }
        
        return 0
    }
    
    var numberOfGalleryContents:Int{
        let realm = try! Realm()
        if let user = realm.objects(User.self).first{
            var count = 0
            for content in user.contents {
                
                if content.mimeType == "image/jpeg" || content.mimeType == "video/mp4" {
                    count = count+1
                }
                print(content.mimeType)
            }
            return count
        }
        return 0
    }
    var numberOfMineGalleryContents:Int{
        let realm = try! Realm()
        if let user = realm.objects(User.self).first{
            var count = 0
            for content in user.contents {
                print(content.mimeType)
            }
            return count
        }
        return 0
    }
    var numberOfSharedGalleryContents:Int{
        let realm = try! Realm()
        if let user = realm.objects(User.self).first{
            var count = 0
            for content in user.contents {
                print(content.mimeType)
            }
            return count
        }
        return 0
    }
    
    func contentAt(index: Int) -> Content{
        let realm = try! Realm()
        
        let user = realm.objects(User.self).first!
        return user.contents.sorted(by: { $0.inclusionTime > $1.inclusionTime })[index]
    }
    
    func contentWith(id: Int) -> Content?{
        let realm = try! Realm()
        
        let user = realm.objects(User.self).first!
        return user.contents.filter("id == %i", id).first
    }
    
    
    func mineContentAt(index: Int) -> Content{
        let realm = try! Realm()
        
        let user = realm.objects(User.self).first!
        return user.contents.filter("userCreator.id == %i", user.id).sorted(by: { $0.inclusionTime > $1.inclusionTime })[index]
    }
    
    func sharedContentAt(index: Int) -> Content{
        let realm = try! Realm()
        
        let user = realm.objects(User.self).first!
        return user.contents.filter("userCreator.id != %i", user.id).sorted(by: { $0.inclusionTime > $1.inclusionTime })[index]
    }
    
    func newestContentDate() -> Date?{
        let realm = try! Realm()
        
        let user = realm.objects(User.self).first!
        return user.contents.sorted(by: { $0.inclusionTime > $1.inclusionTime }).first?.inclusionTime
    }
    
    
    func removeUserContents(){
        let realm = try! Realm()
        if let auth = realm.objects(AuthResponse.self).first, let user = realm.objects(User.self).filter("id == %i", auth.userId).first{
            try! realm.write {
                user.contents.removeAll()
            }
        }
    }
    
    func addContents(array: [[String:Any]]) -> (Date?, Bool){
        let realm = try! Realm()
        var lastItemDate: Date?
        var firstItemDate: Date?
        var changes = false
        
        if let auth = realm.objects(AuthResponse.self).first, let user = realm.objects(User.self).filter("id == %i", auth.userId).first{
            
            var ids = [Int]()
            
            for (index,dict) in array.enumerated(){
                let content = Content(json: JSON(dict))
                ids.append(content.id)
                if index == 0{
                    firstItemDate = content.inclusionTime
                }
                if index == array.count - 1{
                    lastItemDate = content.inclusionTime
                }
                
                if realm.objects(User.self).first?.contents.filter("id == %i", content.id).count == 0{
                    changes = true
                    try! realm.write {
                        realm.add(content, update: true)
                        
                        if user.contents.index(of: content) == nil{
                            user.contents.append(content)
                        }
                        
                    }
                }
                
            }
            
            if let firstDate = firstItemDate, let lastDate = lastItemDate{
                if(self.removeUnexistingContentItems(from: lastDate, to: firstDate, apiItems: ids)){
                    changes = true
                }
            }
            
        }
        return (lastItemDate,changes)
    }
    
    func addContent(dict: [String:Any]){
        let realm = try! Realm()
        let content = Content(json: JSON(dict))
        
        if content.mimeType == "image/jpeg" || content.mimeType == "video/mp4" {
            if let auth = realm.objects(AuthResponse.self).first, let user = realm.objects(User.self).filter("id == %i", auth.userId).first{
                if realm.objects(User.self).first?.contents.filter("id == %i", content.id).count == 0{
                    try! realm.write {
                        realm.add(content, update: true)
                        
                        if user.contents.index(of: content) == nil{
                            user.contents.append(content)
                        }
                        
                    }
                }
            }
        }else{
            print(content.mimeType)
        }
      
    }
    
    func removeUnexistingContentItems(from: Date, to: Date, apiItems: [Int]) -> Bool{
        var changes = false
        let realm = try! Realm()
        if let auth = realm.objects(AuthResponse.self).first, let user = realm.objects(User.self).filter("id == %i", auth.userId).first{
            if apiItems.count == 10{
                
                let contents = user.contents.filter("inclusionTime <= %@ && inclusionTime >= %@", to, from)
                for content in contents{
                    var remove = true
                    for id in apiItems{
                        if content.id == id{
                            remove = false
                        }
                    }
                    if remove{
                        changes = true
                        try! realm.write {
                            user.contents.remove(at: user.contents.index(of: content)!)
                            realm.delete(content)
                            
                        }
                        
                    }
                }
            }
            else{
                
                let contents = user.contents.filter("inclusionTime <= %@", to)
                for content in contents{
                    var remove = true
                    for id in apiItems{
                        if content.id == id{
                            remove = false
                        }
                    }
                    if remove{
                        changes = true
                        
                        try! realm.write {
                            user.contents.remove(at: user.contents.index(of: content)!)
                            realm.delete(content)
                            
                        }
                        
                    }
                }
            }
            
        }
        
        return changes
        
    }
    
    func removeContentItem(id: Int){
        let realm = try! Realm()
        if let auth = realm.objects(AuthResponse.self).first, let user = realm.objects(User.self).filter("id == %i", auth.userId).first{
            if let content = user.contents.filter("id == %i",id).first{
                try! realm.write {
                    user.contents.remove(at: user.contents.index(of: content)!)
                    realm.delete(content)
                    
                }
            }
            
        }
        
    }
    
    func createImageContent(id: Int, idContent: Int){
        let realm = try! Realm()
        if let auth = realm.objects(AuthResponse.self).first, let user = realm.objects(User.self).filter("id == %i", auth.userId).first{
            let content = Content()
            content.inclusionTime = Date()
            content.mimeType = "image/jpeg"
            content.userCreator = user
            content.id = id
            content.idContent = idContent

            try! realm.write {
                realm.add(content, update: true)
                
                if user.contents.index(of: content) == nil{
                    user.contents.append(content)
                }
            }
        }
        
    }
    
    func createVideoContent(id: Int, idContent: Int){
        let realm = try! Realm()
        if let auth = realm.objects(AuthResponse.self).first, let user = realm.objects(User.self).filter("id == %i", auth.userId).first{
            let content = Content()
            content.inclusionTime = Date()
            content.mimeType = "video/mp4"
            content.userCreator = user
            content.id = id
            content.idContent = idContent

            try! realm.write {
                realm.add(content, update: true)
                
                if user.contents.index(of: content) == nil{
                    user.contents.append(content)
                }
                
            }
            
        }
        
    }
    
    
}

//
//  MeetingGuest.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.


import UIKit
import RealmSwift
import SwiftyJSON

class MeetingGuest: Object {
     @objc dynamic var userInfo: User?
     @objc dynamic var state = ""

    convenience required init(json: JSON) {
        self.init()
        
      //  id = json["id"].intValue
        state = json["state"].stringValue
        
        let jsonHost = json["userInfo"]

        
        let realm = try! Realm()
        try! realm.write {
            let user = realm.create(User.self, value: ["name": jsonHost["name"].stringValue, "lastname": jsonHost["lastname"].stringValue, "id": jsonHost["userId"].intValue, "idContentPhoto": jsonHost["idContentPhoto"].intValue], update: true)
            
            userInfo = user
        }
    }
}

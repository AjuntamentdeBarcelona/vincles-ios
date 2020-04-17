//
//  Content.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.



import UIKit
import RealmSwift
import SwiftyJSON

class Content: Object {
    @objc dynamic var id = 0
    @objc dynamic var idContent = 0
    @objc dynamic var inclusionTime = Date(timeIntervalSince1970: 1)
    @objc dynamic var mimeType = ""
    @objc dynamic var userCreator: User?
    @objc dynamic var userName = ""
    @objc dynamic var inclusionTimeInt: Int64 = 0

    override static func primaryKey() -> String? {
        return "id"
    }
    
    convenience required init(json: JSON, relation: String = "") {
        self.init()
      
        inclusionTimeInt = json["inclusionTime"].int64Value

        inclusionTime = Date(timeIntervalSince1970: TimeInterval(json["inclusionTime"].int64Value / 1000))
        id = json["id"].intValue
        mimeType = json["mimeType"].stringValue
        idContent = json["idContent"].intValue

        let jsonUser = json["userCreator"]
        userName =  jsonUser["name"].stringValue + " " + jsonUser["lastname"].stringValue
        let realm = try! Realm()
        try! realm.write {
            let user = realm.create(User.self, value: ["name": jsonUser["name"].stringValue, "lastname": jsonUser["lastname"].stringValue, "gender": jsonUser["gender"].stringValue, "active": jsonUser["active"].boolValue, "alias": jsonUser["alias"].stringValue, "id": jsonUser["id"].intValue, "idContentPhoto": jsonUser["idContentPhoto"].intValue], update: true)
            
            userCreator = user
        }
        
     
    }
}


/*
 {
 "id": 5024,
 "mimeType": "image/jpeg",
 "userCreator": {
 "id": 100,
 "name": "develop@i2cat.net",
 "lastname": "cognom",
 "alias": "alias",
 "gender": "FEMALE",
 "idContentPhoto": 5041,
 "photo": {
 "idContent": 5041,
 "photo": null,
 "photoMimeType": null
 },
 "active": true
 },
 "inclusionTime": 1518452683934
 },
 */
